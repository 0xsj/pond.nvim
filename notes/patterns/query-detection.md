# Query vs Statement Detection

## What

Determining whether SQL text should be executed as a query (returns rows) or a statement (returns affected count). Both SQLite and PostgreSQL backends use the same approach: match on uppercase prefix keywords.

## Why

The `Database` trait has a single `execute()` method. Internally, backends must choose between:
- `query()` / `query_map()` — returns rows
- `execute()` — returns affected row count

## Example

```rust
let upper = trimmed.to_uppercase();
let is_query = upper.starts_with("SELECT")
    || upper.starts_with("EXPLAIN")
    || upper.starts_with("WITH");
```

### SQLite keywords: `SELECT`, `PRAGMA`, `EXPLAIN`, `WITH`
### PostgreSQL keywords: `SELECT`, `EXPLAIN`, `WITH`, `SHOW`, `VALUES`, + `RETURNING` anywhere

## Gotchas

- **`WITH` (CTEs)** — can precede both queries (`WITH ... SELECT`) and mutations (`WITH ... INSERT`). Currently treated as a query, which works for the SELECT case. A `WITH ... INSERT` without `RETURNING` would fail since `query()` expects rows.
- **`RETURNING`** — PostgreSQL-specific. `INSERT ... RETURNING *` returns rows. Detected with `upper.contains("RETURNING")` rather than `starts_with`. This is a loose check but covers the practical cases.
- **`SHOW`** — PostgreSQL equivalent of SQLite's `PRAGMA` for reading config values.
- **`VALUES`** — PostgreSQL allows `VALUES (1, 'a'), (2, 'b')` as a standalone row constructor.
- **Case sensitivity** — always uppercase before matching. SQL keywords are case-insensitive.

## Related

[[rust-database-trait]]
