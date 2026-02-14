# PostgreSQL Type Mapping

## What

Converting PostgreSQL column values to `serde_json::Value` for transport over JSON-RPC. The `postgres` crate uses a `FromSql` trait — you must know the Rust type at compile time, so we match on the column's `Type` OID to pick the right extraction.

## Why

PostgreSQL has a rich type system. We need to map each type to a JSON-compatible representation without losing information (where possible).

## Example

```rust
fn pg_to_json(row: &Row, col_idx: usize) -> Value {
    let col_type = row.columns()[col_idx].type_();
    match *col_type {
        Type::BOOL => extract(row, col_idx, |v: bool| Value::Bool(v)),
        Type::INT4 => extract(row, col_idx, |v: i32| Value::Number((v as i64).into())),
        Type::TIMESTAMPTZ => extract(row, col_idx, |v: DateTime<Utc>| Value::String(v.to_rfc3339())),
        // ...
    }
}

fn extract<'a, T, F>(row: &'a Row, col_idx: usize, convert: F) -> Value
where
    T: FromSql<'a>,
    F: FnOnce(T) -> Value,
{
    match row.try_get::<_, Option<T>>(col_idx) {
        Ok(Some(v)) => convert(v),
        Ok(None) => Value::Null,
        Err(_) => Value::Null,
    }
}
```

## Gotchas

- **`Option<T>` wrapping is essential** — without it, NULL values cause a runtime error instead of returning `Value::Null`.
- **`NUMERIC` is not natively supported** — falls through to the fallback. Would need `rust_decimal` crate for proper support. Currently renders as `<unsupported type: numeric>`.
- **`f64` NaN/Infinity** — `serde_json::Number::from_f64()` returns `None` for these. We map them to `Value::Null`.
- **`TIMESTAMPTZ` vs `TIMESTAMP`** — different Rust types (`DateTime<Utc>` vs `NaiveDateTime`). Must match the correct PG type to the correct Rust type or extraction silently fails.
- **Feature flags required** on the `postgres` crate: `with-chrono-0_4`, `with-uuid-1`, `with-serde_json-1`. Without these, `FromSql` impls don't exist and you get compile errors.
- **`CHAR` (the fixed-width type) vs `BPCHAR`** — PostgreSQL's `CHAR(n)` is internally `BPCHAR`. Match on `Type::BPCHAR`, not a hypothetical `Type::CHAR`.

## Type Coverage

| PG Type | Rust Type | JSON Output |
|---------|-----------|-------------|
| BOOL | `bool` | `true`/`false` |
| INT2/INT4/INT8 | `i16`/`i32`/`i64` | number |
| FLOAT4/FLOAT8 | `f32`/`f64` | number |
| TEXT/VARCHAR/BPCHAR/NAME | `String` | string |
| TIMESTAMP | `NaiveDateTime` | `"2024-01-15T10:30:00"` |
| TIMESTAMPTZ | `DateTime<Utc>` | RFC 3339 string |
| DATE | `NaiveDate` | `"2024-01-15"` |
| TIME | `NaiveTime` | `"10:30:00"` |
| UUID | `Uuid` | `"550e8400-..."` |
| JSON/JSONB | `serde_json::Value` | pass-through |
| BYTEA | `Vec<u8>` | `"<blob N bytes>"` |
| OID | `i32` | number |

## Related

[[rust-database-trait]]
