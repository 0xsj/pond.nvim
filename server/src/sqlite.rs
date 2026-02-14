use anyhow::{Context, Result};
use rusqlite::{params, Connection, types::Value as SqliteValue};
use serde_json::Value;

use crate::db::{Database, QueryResult};

pub struct SqliteBackend {
    conn: Connection,
}

impl SqliteBackend {
    pub fn connect(connection_string: &str) -> Result<Self> {
        let conn = Connection::open(connection_string)
            .with_context(|| format!("failed to open SQLite database: {}", connection_string))?;
        conn.execute_batch("PRAGMA journal_mode=WAL;")
            .context("failed to set WAL mode")?;
        Ok(Self { conn })
    }
}

fn sqlite_to_json(val: SqliteValue) -> Value {
    match val {
        SqliteValue::Null => Value::Null,
        SqliteValue::Integer(i) => Value::Number(i.into()),
        SqliteValue::Real(f) => serde_json::Number::from_f64(f)
            .map(Value::Number)
            .unwrap_or(Value::Null),
        SqliteValue::Text(s) => Value::String(s),
        SqliteValue::Blob(b) => Value::String(format!("<blob {} bytes>", b.len())),
    }
}

impl Database for SqliteBackend {
    fn execute(&self, sql: &str) -> Result<QueryResult> {
        let trimmed = sql.trim();

        // Determine if this is a statement that returns rows
        let upper = trimmed.to_uppercase();
        let is_query = upper.starts_with("SELECT")
            || upper.starts_with("PRAGMA")
            || upper.starts_with("EXPLAIN")
            || upper.starts_with("WITH");

        if is_query {
            let mut stmt = self.conn.prepare(trimmed)
                .context("failed to prepare statement")?;

            let columns: Vec<String> = stmt
                .column_names()
                .into_iter()
                .map(String::from)
                .collect();

            let col_count = columns.len();
            let rows: Vec<Vec<Value>> = stmt
                .query_map(params![], |row| {
                    let mut vals = Vec::with_capacity(col_count);
                    for i in 0..col_count {
                        let val: SqliteValue = row.get_unwrap(i);
                        vals.push(sqlite_to_json(val));
                    }
                    Ok(vals)
                })
                .context("failed to execute query")?
                .collect::<std::result::Result<Vec<_>, _>>()
                .context("failed to read rows")?;

            Ok(QueryResult { columns, rows })
        } else {
            let affected = self.conn.execute(trimmed, params![])
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

    fn memory_db() -> SqliteBackend {
        SqliteBackend::connect(":memory:").unwrap()
    }

    #[test]
    fn connect_memory() {
        let _db = memory_db();
    }

    #[test]
    fn create_and_query() {
        let db = memory_db();
        db.execute("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)").unwrap();
        db.execute("INSERT INTO users (name) VALUES ('Alice')").unwrap();
        db.execute("INSERT INTO users (name) VALUES ('Bob')").unwrap();

        let result = db.execute("SELECT id, name FROM users ORDER BY id").unwrap();
        assert_eq!(result.columns, vec!["id", "name"]);
        assert_eq!(result.rows.len(), 2);
        assert_eq!(result.rows[0][1], Value::String("Alice".into()));
        assert_eq!(result.rows[1][1], Value::String("Bob".into()));
    }

    #[test]
    fn affected_rows() {
        let db = memory_db();
        db.execute("CREATE TABLE t (x INTEGER)").unwrap();
        db.execute("INSERT INTO t VALUES (1)").unwrap();
        db.execute("INSERT INTO t VALUES (2)").unwrap();
        db.execute("INSERT INTO t VALUES (3)").unwrap();

        let result = db.execute("DELETE FROM t WHERE x > 1").unwrap();
        assert_eq!(result.columns, vec!["affected_rows"]);
        assert_eq!(result.rows[0][0], Value::Number(2.into()));
    }

    #[test]
    fn query_error() {
        let db = memory_db();
        let result = db.execute("SELECT * FROM nonexistent");
        assert!(result.is_err());
    }

    #[test]
    fn null_and_types() {
        let db = memory_db();
        db.execute("CREATE TABLE t (a INTEGER, b REAL, c TEXT, d BLOB)").unwrap();
        db.execute("INSERT INTO t VALUES (42, 3.14, 'hello', X'DEADBEEF')").unwrap();
        db.execute("INSERT INTO t VALUES (NULL, NULL, NULL, NULL)").unwrap();

        let result = db.execute("SELECT * FROM t ORDER BY rowid").unwrap();
        assert_eq!(result.rows[0][0], Value::Number(42.into()));
        assert_eq!(result.rows[0][2], Value::String("hello".into()));
        assert_eq!(result.rows[1][0], Value::Null);
    }
}
