# FCKRKN

A simple setup to f*ck roskomposor and censorship overall, that you can (and should) run yourself. Works on all major Russian internet providers. But not limited to Russia.

## Setup

1. Generate a UUID:
   ```
   uuidgen
   ```

2. Replace placeholders in `Dockerfile` and `config.json`:
   - `YOUR_SUBDOMAIN` → your [DuckDNS](https://www.duckdns.org/) subdomain
   - `00000000-0000-0000-0000-000000000000` → your generated UUID

## Run

```
docker compose up -d
```

Server runs on port 443.

## Client Configuration

| Setting | Value |
|---------|-------|
| Address | `YOUR_SUBDOMAIN.duckdns.org` |
| Port | `443` |
| ID (UUID) | your generated UUID |
| AlterId | `0` |
| Security | `aes-128-gcm` |
| Network | `ws` |
| TLS | `tls` |
| Allow Insecure | `true` |
| SNI | `YOUR_SUBDOMAIN.duckdns.org` |
| Path | `/api/v2/data` |
