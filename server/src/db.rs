use anyhow::Result;
use serde_json::Value;

pub struct QueryResult {
    pub columns: Vec<String>,
    pub rows: Vec<Vec<Value>>,
}

pub trait Database: Send {
    fn execute(&self, sql: &str) -> Result<QueryResult>;
}
