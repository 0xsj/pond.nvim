use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize)]
pub struct Request {
    pub id: String,
    pub method: String,
    #[serde(default)]
    pub params: serde_json::Value,
}

#[derive(Debug, Deserialize)]
pub struct ConnectParams {
    pub backend: String,
    pub connection_string: String,
}

#[derive(Debug, Deserialize)]
pub struct ExecuteParams {
    pub sql: String,
    pub connection_id: String,
}

#[derive(Debug, Deserialize)]
pub struct DisconnectParams {
    pub connection_id: String,
}

#[derive(Debug, Serialize)]
pub struct Response {
    pub id: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub result: Option<QueryResult>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub error: Option<ErrorResult>,
}

#[derive(Debug, Serialize)]
#[serde(tag = "type")]
pub enum QueryResult {
    #[serde(rename = "connected")]
    Connected { connection_id: String },
    #[serde(rename = "rows")]
    Rows {
        columns: Vec<String>,
        rows: Vec<Vec<serde_json::Value>>,
        row_count: usize,
        elapsed_ms: u64,
        #[serde(skip_serializing_if = "std::ops::Not::not")]
        truncated: bool,
    },
    #[serde(rename = "affected")]
    Affected {
        affected_rows: usize,
        elapsed_ms: u64,
    },
    #[serde(rename = "disconnected")]
    Disconnected,
    #[serde(rename = "shutdown")]
    Shutdown,
}

#[derive(Debug, Serialize)]
pub struct ErrorResult {
    pub code: String,
    pub message: String,
}

impl Response {
    pub fn success(id: String, result: QueryResult) -> Self {
        Self {
            id,
            result: Some(result),
            error: None,
        }
    }

    pub fn error(id: String, code: impl Into<String>, message: impl Into<String>) -> Self {
        Self {
            id,
            result: None,
            error: Some(ErrorResult {
                code: code.into(),
                message: message.into(),
            }),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_connect_request() {
        let json = r#"{"id":"req_1","method":"connect","params":{"backend":"sqlite","connection_string":"/path/to/db.sqlite"}}"#;
        let req: Request = serde_json::from_str(json).unwrap();
        assert_eq!(req.id, "req_1");
        assert_eq!(req.method, "connect");
        let params: ConnectParams = serde_json::from_value(req.params).unwrap();
        assert_eq!(params.backend, "sqlite");
        assert_eq!(params.connection_string, "/path/to/db.sqlite");
    }

    #[test]
    fn parse_execute_request() {
        let json = r#"{"id":"req_2","method":"execute","params":{"sql":"SELECT * FROM users","connection_id":"conn_1"}}"#;
        let req: Request = serde_json::from_str(json).unwrap();
        assert_eq!(req.method, "execute");
        let params: ExecuteParams = serde_json::from_value(req.params).unwrap();
        assert_eq!(params.sql, "SELECT * FROM users");
        assert_eq!(params.connection_id, "conn_1");
    }

    #[test]
    fn parse_shutdown_request() {
        let json = r#"{"id":"req_4","method":"shutdown"}"#;
        let req: Request = serde_json::from_str(json).unwrap();
        assert_eq!(req.method, "shutdown");
    }

    #[test]
    fn serialize_rows_result() {
        let resp = Response::success(
            "req_2".into(),
            QueryResult::Rows {
                columns: vec!["id".into(), "name".into()],
                rows: vec![
                    vec![serde_json::json!(1), serde_json::json!("Alice")],
                    vec![serde_json::json!(2), serde_json::json!("Bob")],
                ],
                row_count: 2,
                elapsed_ms: 12,
                truncated: false,
            },
        );
        let json = serde_json::to_string(&resp).unwrap();
        assert!(json.contains("\"type\":\"rows\""));
        assert!(json.contains("\"row_count\":2"));
        assert!(!json.contains("truncated"));
    }

    #[test]
    fn serialize_affected_result() {
        let resp = Response::success(
            "req_2".into(),
            QueryResult::Affected {
                affected_rows: 3,
                elapsed_ms: 5,
            },
        );
        let json = serde_json::to_string(&resp).unwrap();
        assert!(json.contains("\"affected_rows\":3"));
    }

    #[test]
    fn serialize_error() {
        let resp = Response::error("req_1".into(), "connection_failed", "unable to open database file");
        let json = serde_json::to_string(&resp).unwrap();
        assert!(json.contains("\"code\":\"connection_failed\""));
        assert!(!json.contains("\"result\""));
    }

    #[test]
    fn roundtrip_connected() {
        let resp = Response::success("r1".into(), QueryResult::Connected { connection_id: "conn_1".into() });
        let json = serde_json::to_string(&resp).unwrap();
        assert!(json.contains("\"connection_id\":\"conn_1\""));
        assert!(json.contains("\"type\":\"connected\""));
    }
}
