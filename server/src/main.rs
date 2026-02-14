mod db;
mod postgres;
mod protocol;
mod sqlite;

use std::collections::HashMap;
use std::io::{self, BufRead, Write};
use std::time::Instant;

use protocol::{ConnectParams, DisconnectParams, ExecuteParams, QueryResult, Request, Response};

const MAX_ROWS: usize = 1000;

fn main() {
    let stdin = io::stdin();
    let stdout = io::stdout();
    let mut out = stdout.lock();

    let mut connections: HashMap<String, Box<dyn db::Database>> = HashMap::new();
    let mut conn_counter: u64 = 0;

    for line in stdin.lock().lines() {
        let line = match line {
            Ok(l) => l,
            Err(_) => break,
        };

        let line = line.trim().to_string();
        if line.is_empty() {
            continue;
        }

        let req: Request = match serde_json::from_str(&line) {
            Ok(r) => r,
            Err(e) => {
                let resp = Response::error("".into(), "parse_error", e.to_string());
                let _ = writeln!(out, "{}", serde_json::to_string(&resp).unwrap());
                let _ = out.flush();
                continue;
            }
        };

        let resp = match req.method.as_str() {
            "connect" => handle_connect(&req, &mut connections, &mut conn_counter),
            "execute" => handle_execute(&req, &connections),
            "disconnect" => handle_disconnect(&req, &mut connections),
            "shutdown" => {
                let resp = Response::success(req.id, QueryResult::Shutdown);
                let _ = writeln!(out, "{}", serde_json::to_string(&resp).unwrap());
                let _ = out.flush();
                break;
            }
            _ => Response::error(req.id, "unknown_method", format!("unknown method: {}", req.method)),
        };

        let _ = writeln!(out, "{}", serde_json::to_string(&resp).unwrap());
        let _ = out.flush();
    }
}

fn handle_connect(
    req: &Request,
    connections: &mut HashMap<String, Box<dyn db::Database>>,
    counter: &mut u64,
) -> Response {
    let params: ConnectParams = match serde_json::from_value(req.params.clone()) {
        Ok(p) => p,
        Err(e) => return Response::error(req.id.clone(), "parse_error", e.to_string()),
    };

    match params.backend.as_str() {
        "sqlite" => {
            match sqlite::SqliteBackend::connect(&params.connection_string) {
                Ok(backend) => {
                    *counter += 1;
                    let conn_id = format!("conn_{}", counter);
                    connections.insert(conn_id.clone(), Box::new(backend));
                    Response::success(req.id.clone(), QueryResult::Connected { connection_id: conn_id })
                }
                Err(e) => Response::error(req.id.clone(), "connection_failed", e.to_string()),
            }
        }
        "postgresql" => {
            match postgres::PostgresBackend::connect(&params.connection_string) {
                Ok(backend) => {
                    *counter += 1;
                    let conn_id = format!("conn_{}", counter);
                    connections.insert(conn_id.clone(), Box::new(backend));
                    Response::success(req.id.clone(), QueryResult::Connected { connection_id: conn_id })
                }
                Err(e) => Response::error(req.id.clone(), "connection_failed", e.to_string()),
            }
        }
        other => Response::error(
            req.id.clone(),
            "connection_failed",
            format!("unsupported backend: {}", other),
        ),
    }
}

fn handle_execute(
    req: &Request,
    connections: &HashMap<String, Box<dyn db::Database>>,
) -> Response {
    let params: ExecuteParams = match serde_json::from_value(req.params.clone()) {
        Ok(p) => p,
        Err(e) => return Response::error(req.id.clone(), "parse_error", e.to_string()),
    };

    let db = match connections.get(&params.connection_id) {
        Some(db) => db,
        None => {
            return Response::error(
                req.id.clone(),
                "connection_not_found",
                format!("no connection with id: {}", params.connection_id),
            )
        }
    };

    let start = Instant::now();
    match db.execute(&params.sql) {
        Ok(result) => {
            let elapsed_ms = start.elapsed().as_millis() as u64;

            if result.columns == vec!["affected_rows"] {
                let affected = result.rows.first()
                    .and_then(|r| r.first())
                    .and_then(|v| v.as_u64())
                    .unwrap_or(0) as usize;
                Response::success(
                    req.id.clone(),
                    QueryResult::Affected { affected_rows: affected, elapsed_ms },
                )
            } else {
                let truncated = result.rows.len() > MAX_ROWS;
                let rows: Vec<Vec<serde_json::Value>> = if truncated {
                    result.rows.into_iter().take(MAX_ROWS).collect()
                } else {
                    result.rows
                };
                let row_count = rows.len();
                Response::success(
                    req.id.clone(),
                    QueryResult::Rows {
                        columns: result.columns,
                        rows,
                        row_count,
                        elapsed_ms,
                        truncated,
                    },
                )
            }
        }
        Err(e) => Response::error(req.id.clone(), "query_error", e.to_string()),
    }
}

fn handle_disconnect(
    req: &Request,
    connections: &mut HashMap<String, Box<dyn db::Database>>,
) -> Response {
    let params: DisconnectParams = match serde_json::from_value(req.params.clone()) {
        Ok(p) => p,
        Err(e) => return Response::error(req.id.clone(), "parse_error", e.to_string()),
    };

    if connections.remove(&params.connection_id).is_some() {
        Response::success(req.id.clone(), QueryResult::Disconnected)
    } else {
        Response::error(
            req.id.clone(),
            "connection_not_found",
            format!("no connection with id: {}", params.connection_id),
        )
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    // Unit test: handle_connect + handle_execute directly
    #[test]
    fn connect_and_query() {
        let mut connections: HashMap<String, Box<dyn db::Database>> = HashMap::new();
        let mut counter = 0u64;

        // Connect
        let connect_req: Request = serde_json::from_str(
            r#"{"id":"1","method":"connect","params":{"backend":"sqlite","connection_string":":memory:"}}"#
        ).unwrap();
        let resp = handle_connect(&connect_req, &mut connections, &mut counter);
        let json = serde_json::to_string(&resp).unwrap();
        assert!(json.contains("conn_1"));

        // Create table
        let exec_req: Request = serde_json::from_str(
            r#"{"id":"2","method":"execute","params":{"sql":"CREATE TABLE t (x INTEGER)","connection_id":"conn_1"}}"#
        ).unwrap();
        let resp = handle_execute(&exec_req, &connections);
        let json = serde_json::to_string(&resp).unwrap();
        assert!(json.contains("affected"));

        // Insert
        let exec_req: Request = serde_json::from_str(
            r#"{"id":"3","method":"execute","params":{"sql":"INSERT INTO t VALUES (42)","connection_id":"conn_1"}}"#
        ).unwrap();
        let resp = handle_execute(&exec_req, &connections);
        let json = serde_json::to_string(&resp).unwrap();
        assert!(json.contains("\"affected_rows\":1"));

        // Query
        let exec_req: Request = serde_json::from_str(
            r#"{"id":"4","method":"execute","params":{"sql":"SELECT * FROM t","connection_id":"conn_1"}}"#
        ).unwrap();
        let resp = handle_execute(&exec_req, &connections);
        let json = serde_json::to_string(&resp).unwrap();
        assert!(json.contains("\"row_count\":1"));
        assert!(json.contains("42"));
    }

    #[test]
    fn connection_not_found() {
        let connections: HashMap<String, Box<dyn db::Database>> = HashMap::new();
        let req: Request = serde_json::from_str(
            r#"{"id":"1","method":"execute","params":{"sql":"SELECT 1","connection_id":"nope"}}"#
        ).unwrap();
        let resp = handle_execute(&req, &connections);
        let json = serde_json::to_string(&resp).unwrap();
        assert!(json.contains("connection_not_found"));
    }

    #[test]
    fn disconnect() {
        let mut connections: HashMap<String, Box<dyn db::Database>> = HashMap::new();
        let mut counter = 0u64;

        let connect_req: Request = serde_json::from_str(
            r#"{"id":"1","method":"connect","params":{"backend":"sqlite","connection_string":":memory:"}}"#
        ).unwrap();
        handle_connect(&connect_req, &mut connections, &mut counter);
        assert!(connections.contains_key("conn_1"));

        let disc_req: Request = serde_json::from_str(
            r#"{"id":"2","method":"disconnect","params":{"connection_id":"conn_1"}}"#
        ).unwrap();
        let resp = handle_disconnect(&disc_req, &mut connections);
        let json = serde_json::to_string(&resp).unwrap();
        assert!(json.contains("disconnected"));
        assert!(!connections.contains_key("conn_1"));
    }

    #[test]
    fn postgresql_backend_dispatch() {
        let mut connections: HashMap<String, Box<dyn db::Database>> = HashMap::new();
        let mut counter = 0u64;

        // "postgresql" is a recognized backend — should get connection_failed, not unsupported
        let req: Request = serde_json::from_str(
            r#"{"id":"1","method":"connect","params":{"backend":"postgresql","connection_string":"postgresql://localhost:1/nonexistent_pond_test"}}"#
        ).unwrap();
        let resp = handle_connect(&req, &mut connections, &mut counter);
        let json = serde_json::to_string(&resp).unwrap();
        assert!(json.contains("connection_failed"));
        assert!(!json.contains("unsupported backend"));
    }

    #[test]
    fn unknown_method() {
        let mut connections: HashMap<String, Box<dyn db::Database>> = HashMap::new();
        let mut counter = 0u64;
        let req: Request = serde_json::from_str(
            r#"{"id":"1","method":"foobar","params":{}}"#
        ).unwrap();
        // Simulate dispatch
        let resp = match req.method.as_str() {
            "connect" => handle_connect(&req, &mut connections, &mut counter),
            "execute" => handle_execute(&req, &connections),
            "disconnect" => handle_disconnect(&req, &mut connections),
            _ => Response::error(req.id.clone(), "unknown_method", format!("unknown method: {}", req.method)),
        };
        let json = serde_json::to_string(&resp).unwrap();
        assert!(json.contains("unknown_method"));
    }
}
