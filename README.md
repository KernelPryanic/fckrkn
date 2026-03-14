# FCKRKN

A simple setup to f*ck roskomposor and censorship overall, that you can (and should) run yourself. Works on all major Russian internet providers. But not limited to Russia.

## Setup

1. Generate UUIDs for VMess and VLESS:
   ```
   uuidgen  # for VMess
   uuidgen  # for VLESS
   ```

2. Generate Reality x25519 keypair:
   ```
   docker run --rm teddysun/xray:latest xray x25519
   ```
   This outputs a `PrivateKey` (for server config) and a public key (for client config).

3. Generate a Reality Short ID:
   ```
   openssl rand -hex 8
   ```

4. Generate a Trojan password:
   ```
   openssl rand -base64 24
   ```

5. Generate a KCP seed:
   ```
   openssl rand -hex 16
   ```

6. Replace all placeholders in `config.json`:
   - `00000000-0000-0000-0000-000000000000` -> your VMess UUID
   - `11111111-1111-1111-1111-111111111111` -> your VLESS UUID
   - `YOUR_REALITY_PRIVATE_KEY` -> private key from step 2
   - `YOUR_SHORT_ID` -> short ID from step 3
   - `YOUR_TROJAN_PASSWORD` -> password from step 4
   - `YOUR_KCP_SEED` -> seed from step 5

## Build

```
docker compose build --no-cache
```

## Run

```
docker compose up -d
```

## Ports

| Port        | Protocol            | Transport  | Disguise                              |
|-------------|---------------------|------------|---------------------------------------|
| `8443`      | VLESS + Reality     | TCP        | Impersonates `ya.ru` TLS              |
| `51820/udp` | VLESS + mKCP        | UDP (KCP)  | Looks like WireGuard VPN traffic      |
| `8080`      | VMess + WS + TLS    | WebSocket  | Yandex Disk API traffic               |
| `8880`      | Trojan + gRPC + TLS | gRPC       | Yandex internal API (`api.yandex.net`)|
| `2096`      | Trojan + WS + TLS   | WebSocket  | Yandex push notifications             |

## Client Configuration

Replace `YOUR_SERVER` with your server address/IP.

---

### 1. VLESS + Reality (Recommended)

Best anti-censorship option. Impersonates Yandex TLS fingerprint. Undetectable by DPI.

| Setting        | Value                                              |
|----------------|----------------------------------------------------|
| Protocol       | VLESS                                              |
| Address        | `YOUR_SERVER`                                      |
| Port           | `8443`                                             |
| UUID           | your VLESS UUID                                    |
| Flow           | `xtls-rprx-vision`                                 |
| Transport      | TCP                                                |
| Security       | Reality                                            |
| SNI            | `ya.ru`                                            |
| Public Key     | your Reality public key                            |
| Short ID       | your short ID                                      |
| Fingerprint    | `chrome` (or `safari` on iOS)                      |

#### Share Link

```
vless://YOUR_VLESS_UUID@YOUR_SERVER:8443?encryption=none&security=reality&sni=ya.ru&fp=safari&pbk=YOUR_REALITY_PUBLIC_KEY&sid=YOUR_SHORT_ID&flow=xtls-rprx-vision&type=tcp#VLESS-Reality
```

---

### 2. VLESS + mKCP (UDP)

Bypasses TCP throttling. Uses UDP disguised as WeChat video call packets.

| Setting        | Value                                              |
|----------------|----------------------------------------------------|
| Protocol       | VLESS                                              |
| Address        | `YOUR_SERVER`                                      |
| Port           | `51820`                                            |
| UUID           | your VLESS UUID                                    |
| Transport      | KCP                                                |
| Header Type    | `wechat-video`                                     |
| Seed           | your KCP seed                                      |
| Security       | None                                               |

#### Share Link

```
vless://YOUR_VLESS_UUID@YOUR_SERVER:51820?encryption=none&security=none&type=kcp&headerType=wechat-video&seed=YOUR_KCP_SEED#VLESS-mKCP
```

---

### 3. VMess + WS + TLS

Disguised as Yandex Disk API traffic. WebSocket transport over TLS.

| Setting        | Value                                              |
|----------------|----------------------------------------------------|
| Protocol       | VMess                                              |
| Address        | `YOUR_SERVER`                                      |
| Port           | `8080`                                             |
| UUID           | your VMess UUID                                    |
| AlterID        | `0`                                                |
| Transport      | WebSocket                                          |
| Path           | `/v1/disk/resources/download`                      |
| Host           | `disk.yandex.ru`                                   |
| Security       | TLS                                                |
| SNI            | `disk.yandex.ru`                                   |
| Allow Insecure | Yes (self-signed certificate)                      |

---

### 4. Trojan + gRPC + TLS

Password-based authentication over gRPC transport. Disguised as Yandex internal API.

| Setting        | Value                                              |
|----------------|----------------------------------------------------|
| Protocol       | Trojan                                             |
| Address        | `YOUR_SERVER`                                      |
| Port           | `8880`                                             |
| Password       | your Trojan password                               |
| Transport      | gRPC                                               |
| Service Name   | `trojan-grpc`                                      |
| Security       | TLS                                                |
| SNI            | `api.yandex.net`                                   |
| ALPN           | `h2`                                               |
| Allow Insecure | Yes (self-signed certificate)                      |

#### Share Link

```
trojan://YOUR_TROJAN_PASSWORD@YOUR_SERVER:8880?security=tls&alpn=h2&type=grpc&serviceName=trojan-grpc&sni=api.yandex.net&allowInsecure=1#Trojan-gRPC
```

---

### 5. Trojan + WS + TLS (Fallback)

WebSocket fallback. Widest client compatibility. Disguised as Yandex push notification stream.

| Setting        | Value                                              |
|----------------|----------------------------------------------------|
| Protocol       | Trojan                                             |
| Address        | `YOUR_SERVER`                                      |
| Port           | `2096`                                             |
| Password       | your Trojan password                               |
| Transport      | WebSocket                                          |
| Path           | `/v1/notifications/stream`                         |
| Security       | TLS                                                |
| SNI            | `push.yandex.ru`                                   |
| Allow Insecure | Yes (self-signed certificate)                      |

#### Share Link

```
trojan://YOUR_TROJAN_PASSWORD@YOUR_SERVER:2096?security=tls&type=ws&path=%2Fv1%2Fnotifications%2Fstream&sni=push.yandex.ru&allowInsecure=1#Trojan-WS
```

---

## Shadowrocket (iOS) Notes

- For VLESS + Reality: set Peer fingerprint to `safari`
- For TLS connections with self-signed certs: enable "Allow Insecure" / skip certificate verification
- You can import configs by copying the share links above and opening them in Shadowrocket
- mKCP connectivity test may show timeout — this is normal, the connection still works

## Recommended Priority

1. **VLESS + Reality** — Use this as your primary connection. Most resistant to detection.
2. **Trojan + gRPC** — Good fallback if Reality is blocked. Looks like Yandex internal API.
3. **VMess + WS** — Fallback disguised as Yandex Disk traffic.
4. **Trojan + WS** — Widest client compatibility. Use if gRPC doesn't work in your client.
5. **VLESS + mKCP** — Use when TCP traffic is being throttled (switches to UDP).
