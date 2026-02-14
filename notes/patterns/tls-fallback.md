# TLS Fallback for Database Connections

## What

When connecting to PostgreSQL, try TLS first (via `native-tls`), then fall back to plaintext (`NoTls`). This handles both remote servers that require TLS and local development servers that don't support it.

## Why

- Cloud databases (Supabase, RDS, Neon) require TLS
- Local `postgresql://localhost/mydb` connections typically don't have TLS configured
- Failing silently on TLS and retrying without it gives the best UX — no config needed

## Example

```rust
fn try_connect_tls(connection_string: &str) -> Result<Client> {
    let tls_connector = native_tls::TlsConnector::new()?;
    let connector = postgres_native_tls::MakeTlsConnector::new(tls_connector);
    Ok(Client::connect(connection_string, connector)?)
}

pub fn connect(connection_string: &str) -> Result<Self> {
    let client = match try_connect_tls(connection_string) {
        Ok(c) => c,
        Err(_) => Client::connect(connection_string, NoTls)?,
    };
    Ok(Self { client: Mutex::new(client) })
}
```

## Gotchas

- `native-tls` uses the **system TLS stack** — macOS SecureTransport, Windows SChannel, Linux OpenSSL. No vendored C libs needed on macOS.
- The TLS attempt may take a moment to fail on local connections. This is a one-time cost at connection time.
- If the server requires TLS with a specific CA cert, `native-tls::TlsConnector::new()` uses the system cert store. Custom CAs would need `TlsConnector::builder().add_root_certificate(...)`.

## Related

[[rust-database-trait]]
