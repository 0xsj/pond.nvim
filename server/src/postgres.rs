use std::sync::Mutex;

use anyhow::{Context, Result};
use postgres::{types::Type, Client, NoTls, Row};
use serde_json::Value;

use crate::db::{Database, QueryResult};

pub struct PostgresBackend {
    client: Mutex<Client>,
}

impl PostgresBackend {
    pub fn connect(connection_string: &str) -> Result<Self> {
        // Try TLS first, fall back to no-TLS for local connections
        let client = match try_connect_tls(connection_string) {
            Ok(c) => c,
            Err(_) => Client::connect(connection_string, NoTls)
                .with_context(|| format!("failed to connect to PostgreSQL: {}", connection_string))?,
        };
        Ok(Self {
            client: Mutex::new(client),
        })
    }
}

fn try_connect_tls(connection_string: &str) -> Result<Client> {
    let tls_connector = native_tls::TlsConnector::new()?;
    let connector = postgres_native_tls::MakeTlsConnector::new(tls_connector);
    let client = Client::connect(connection_string, connector)?;
    Ok(client)
}

fn extract<'a, T, F>(row: &'a Row, col_idx: usize, convert: F) -> Value
where
    T: postgres::types::FromSql<'a>,
    F: FnOnce(T) -> Value,
{
    match row.try_get::<_, Option<T>>(col_idx) {
        Ok(Some(v)) => convert(v),
        Ok(None) => Value::Null,
        Err(_) => Value::Null,
    }
}

fn pg_to_json(row: &Row, col_idx: usize) -> Value {
    let col_type = row.columns()[col_idx].type_();

    match *col_type {
        Type::BOOL => extract(row, col_idx, |v: bool| Value::Bool(v)),
        Type::INT2 => extract(row, col_idx, |v: i16| Value::Number((v as i64).into())),
        Type::INT4 | Type::OID => extract(row, col_idx, |v: i32| Value::Number((v as i64).into())),
        Type::INT8 => extract(row, col_idx, |v: i64| Value::Number(v.into())),
        Type::FLOAT4 => extract(row, col_idx, |v: f32| {
            serde_json::Number::from_f64(v as f64)
                .map(Value::Number)
                .unwrap_or(Value::Null)
        }),
        Type::FLOAT8 => extract(row, col_idx, |v: f64| {
            serde_json::Number::from_f64(v)
                .map(Value::Number)
                .unwrap_or(Value::Null)
        }),
        Type::TEXT | Type::VARCHAR | Type::BPCHAR | Type::NAME => {
            extract(row, col_idx, |v: String| Value::String(v))
        }
        Type::BYTEA => extract(row, col_idx, |v: Vec<u8>| {
            Value::String(format!("<blob {} bytes>", v.len()))
        }),
        Type::TIMESTAMP => extract(row, col_idx, |v: chrono::NaiveDateTime| {
            Value::String(v.format("%Y-%m-%dT%H:%M:%S%.f").to_string())
        }),
        Type::TIMESTAMPTZ => {
            extract(row, col_idx, |v: chrono::DateTime<chrono::Utc>| {
                Value::String(v.to_rfc3339())
            })
        }
        Type::DATE => extract(row, col_idx, |v: chrono::NaiveDate| {
            Value::String(v.format("%Y-%m-%d").to_string())
        }),
        Type::TIME => extract(row, col_idx, |v: chrono::NaiveTime| {
            Value::String(v.format("%H:%M:%S%.f").to_string())
        }),
        Type::UUID => extract(row, col_idx, |v: uuid::Uuid| Value::String(v.to_string())),
        Type::JSON | Type::JSONB => extract(row, col_idx, |v: Value| v),
        _ => {
            // Fallback: try extracting as String (works for TEXT-like types)
            match row.try_get::<_, Option<String>>(col_idx) {
                Ok(Some(v)) => Value::String(v),
                Ok(None) => Value::Null,
                Err(_) => Value::String(format!("<unsupported type: {}>", col_type.name())),
            }
        }
    }
}

impl Database for PostgresBackend {
    fn execute(&self, sql: &str) -> Result<QueryResult> {
        let trimmed = sql.trim();
        let upper = trimmed.to_uppercase();

        let is_query = upper.starts_with("SELECT")
            || upper.starts_with("EXPLAIN")
            || upper.starts_with("WITH")
            || upper.starts_with("SHOW")
            || upper.starts_with("VALUES")
            || upper.contains("RETURNING");

        let mut client = self
            .client
            .lock()
            .map_err(|e| anyhow::anyhow!("lock poisoned: {}", e))?;

        if is_query {
            let stmt = client
                .prepare(trimmed)
                .context("failed to prepare query")?;

            let columns: Vec<String> = stmt.columns().iter().map(|c| c.name().to_string()).collect();
            let col_count = columns.len();

            let rows = client
                .query(&stmt, &[])
                .context("failed to execute query")?;

            let json_rows: Vec<Vec<Value>> = rows
                .iter()
                .map(|row| (0..col_count).map(|i| pg_to_json(row, i)).collect())
                .collect();

            Ok(QueryResult {
                columns,
                rows: json_rows,
            })
        } else {
            let affected = client
                .execute(trimmed, &[])
                .context("failed to execute statement")?;

            Ok(QueryResult {
                columns: vec!["affected_rows".into()],
                rows: vec![vec![Value::Number(affected.into())]],
            })
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn connect_test_db() -> Option<PostgresBackend> {
        if std::env::var("POND_TEST_PG").is_err() {
            eprintln!("Skipping: set POND_TEST_PG=1 and ensure local PostgreSQL is running");
            return None;
        }
        let url = std::env::var("POND_TEST_PG_URL")
            .unwrap_or_else(|_| "postgresql://localhost/postgres".to_string());
        Some(PostgresBackend::connect(&url).expect("failed to connect to test database"))
    }

    #[test]
    fn connect_and_select() {
        let Some(db) = connect_test_db() else {
            return;
        };
        let result = db
            .execute("SELECT 1 as num, 'hello' as greeting")
            .unwrap();
        assert_eq!(result.columns, vec!["num", "greeting"]);
        assert_eq!(result.rows.len(), 1);
        assert_eq!(result.rows[0][0], Value::Number(1.into()));
        assert_eq!(result.rows[0][1], Value::String("hello".into()));
    }

    #[test]
    fn type_mapping() {
        let Some(db) = connect_test_db() else {
            return;
        };
        let result = db
            .execute(
                "SELECT \
                 true as b, \
                 42::int4 as i4, \
                 99::int8 as i8, \
                 3.14::float8 as f, \
                 null::text as n, \
                 now()::timestamptz as ts, \
                 current_date as d, \
                 '\\xDEADBEEF'::bytea as blob",
            )
            .unwrap();

        assert_eq!(result.rows[0][0], Value::Bool(true));
        assert_eq!(result.rows[0][1], Value::Number(42.into()));
        assert_eq!(result.rows[0][2], Value::Number(99.into()));
        assert!(matches!(result.rows[0][3], Value::Number(_)));
        assert_eq!(result.rows[0][4], Value::Null);
        assert!(matches!(result.rows[0][5], Value::String(_))); // timestamp
        assert!(matches!(result.rows[0][6], Value::String(_))); // date
        assert!(matches!(result.rows[0][7], Value::String(_))); // blob description
    }

    #[test]
    fn execute_statement() {
        let Some(db) = connect_test_db() else {
            return;
        };
        // CREATE TEMP TABLE so we don't pollute the database
        db.execute("CREATE TEMP TABLE pond_test (id serial, name text)")
            .unwrap();
        let result = db
            .execute("INSERT INTO pond_test (name) VALUES ('Alice')")
            .unwrap();
        assert_eq!(result.columns, vec!["affected_rows"]);
        assert_eq!(result.rows[0][0], Value::Number(1.into()));

        let result = db.execute("SELECT * FROM pond_test").unwrap();
        assert_eq!(result.rows.len(), 1);
    }

    #[test]
    fn query_error() {
        let Some(db) = connect_test_db() else {
            return;
        };
        let result = db.execute("SELECT * FROM pond_nonexistent_table_xyz");
        assert!(result.is_err());
    }
}
