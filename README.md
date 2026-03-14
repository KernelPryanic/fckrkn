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

| Port        | Protocol            | Transport       | Disguise                          |
|-------------|---------------------|-----------------|-----------------------------------|
| `8443`      | VLESS + Reality     | TCP             | Impersonates `ya.ru` TLS          |
| `51820/udp` | VLESS + mKCP        | UDP (KCP)       | Looks like WireGuard VPN traffic  |
| `8080`      | VMess + XHTTP + TLS | XHTTP/SplitHTTP | Yandex Disk API traffic           |
| `8880`      | Trojan + XHTTP + TLS| XHTTP/SplitHTTP | Cloudflare alt-HTTPS traffic      |

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
vless://YOUR_VLESS_UUID@YOUR_SERVER:8443?security=reality&sni=ya.ru&fp=safari&pbk=YOUR_REALITY_PUBLIC_KEY&sid=YOUR_SHORT_ID&flow=xtls-rprx-vision&type=tcp#VLESS-Reality
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
vless://YOUR_VLESS_UUID@YOUR_SERVER:51820?type=kcp&headerType=wechat-video&seed=YOUR_KCP_SEED#VLESS-mKCP
```

---

### 3. VMess + XHTTP + TLS

Disguised as Yandex Disk API traffic. Uses XHTTP (SplitHTTP) transport over TLS.

| Setting        | Value                                              |
|----------------|----------------------------------------------------|
| Protocol       | VMess                                              |
| Address        | `YOUR_SERVER`                                      |
| Port           | `8080`                                             |
| UUID           | your VMess UUID                                    |
| AlterID        | `0`                                                |
| Transport      | XHTTP (SplitHTTP)                                  |
| Path           | `/v1/disk/resources/download`                      |
| Host           | `disk.yandex.ru`                                   |
| Security       | TLS                                                |
| SNI            | `disk.yandex.ru`                                   |
| ALPN           | `h2`                                               |
| Allow Insecure | Yes (self-signed certificate)                      |

---

### 4. Trojan + XHTTP + TLS

Password-based authentication over XHTTP transport. Simple to configure.

| Setting        | Value                                              |
|----------------|----------------------------------------------------|
| Protocol       | Trojan                                             |
| Address        | `YOUR_SERVER`                                      |
| Port           | `8880`                                             |
| Password       | your Trojan password                               |
| Transport      | XHTTP (SplitHTTP)                                  |
| Path           | `/trojan-xh`                                       |
| Security       | TLS                                                |
| ALPN           | `h2`                                               |
| Allow Insecure | Yes (self-signed certificate)                      |

#### Share Link

```
trojan://YOUR_TROJAN_PASSWORD@YOUR_SERVER:8880?security=tls&type=splithttp&path=%2Ftrojan-xh&allowInsecure=1#Trojan-XHTTP
```

---

## Shadowrocket (iOS) Notes

- Make sure Shadowrocket is updated to the latest version for XHTTP/SplitHTTP support
- For VLESS + Reality: set Peer fingerprint to `safari`
- For TLS connections with self-signed certs: enable "Allow Insecure" / skip certificate verification
- You can import configs by copying the share links above and opening them in Shadowrocket

## Recommended Priority

1. **VLESS + Reality** — Use this as your primary connection. Most resistant to detection.
2. **Trojan + XHTTP** — Good fallback if Reality is blocked.
3. **VMess + XHTTP** — Legacy fallback disguised as Yandex Disk traffic.
4. **VLESS + mKCP** — Use when TCP traffic is being throttled (switches to UDP).
