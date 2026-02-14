# Rust Database Trait Pattern

## What

A minimal trait (`Database`) with a single method (`execute`) that all backends implement. The server dispatches to backends via `Box<dyn Database>`, making the backend completely swappable at runtime.

## Why

Adding a new database backend requires only:
1. A new file implementing the trait
2. A new match arm in `handle_connect`

No changes to protocol, display, or Lua code.

## Example

```rust
// db.rs — the contract
pub trait Database: Send {
    fn execute(&self, sql: &str) -> Result<QueryResult>;
}

// sqlite.rs / postgres.rs — implementations
impl Database for SqliteBackend { ... }
impl Database for PostgresBackend { ... }

// main.rs — dispatch
let mut connections: HashMap<String, Box<dyn Database>> = HashMap::new();
match params.backend.as_str() {
    "sqlite" => { /* SqliteBackend::connect(...) */ }
    "postgresql" => { /* PostgresBackend::connect(...) */ }
}
```

## Gotchas

- The trait requires `Send` because the connection map could theoretically be shared. `Sync` is not required.
- `postgres::Client` needs `&mut self` for queries, but the trait uses `&self`. Solved with `Mutex<Client>`.
- `rusqlite::Connection` is fine with `&self` because its methods use interior mutability internally.
- `QueryResult` (in `db.rs`) is a different type from `protocol::QueryResult`. The db version is a simple `{columns, rows}` struct; the protocol version is a tagged enum for JSON serialization.

## Related

[[postgres-type-mapping]]
