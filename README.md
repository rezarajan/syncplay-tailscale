# syncplay-tailscale

Private Syncplay server over Tailscale. No public ports required.

**Repository:** https://github.com/rezarajan/syncplay-tailscale

---

## Quick Start (Recommended)

Download the latest release from GitHub Releases.

1. Extract the archive
2. Copy the environment file:
   ```bash
   cp .env.example .env
   ```
3. Edit `.env`:
   - Set `TS_AUTHKEY`
   - Set `SYNCPLAY_PASSWORD`
   - Set `SYNCPLAY_SALT` (generate with `openssl rand -hex 32`)
4. Start:
   ```bash
   docker compose up -d
   ```

---

## Connecting

In your Syncplay client:

```
Host: syncplay.<your-tailnet>.ts.net
Port: 8999
Password: <SYNCPLAY_PASSWORD>
```

Alternatively, use the Tailscale IP of the machine.

---

## Sharing Access

To share the server with others:

1. Open the Tailscale admin console
2. Go to **Machines**
3. Select the `syncplay` machine
4. Click **Share**
5. Send the link

Users must:
- Install Tailscale
- Accept the share
- Connect using Syncplay

---

## Requirements

- Docker + Docker Compose
- Tailscale account
- Tailscale auth key

---

## Architecture

```
Syncplay client
    ↓ (TCP 8999 over tailnet)
Tailscale Serve (raw TCP)
    ↓
Syncplay server
```

Syncplay is a TCP service, so this uses raw TCP forwarding instead of HTTP.

---

## Building from Source

```bash
git clone https://github.com/rezarajan/syncplay-tailscale.git
cd syncplay-tailscale

cp .env.example .env
openssl rand -hex 32

mkdir -p tailscale/state data
docker compose up -d --build
```

---

## Image

Published images are available at:

```
ghcr.io/rezarajan/syncplay-tailscale:<version>
```

Releases use pinned versions.

---

## Common Commands

```bash
docker compose up -d
docker compose down
docker compose logs -f
```

---

## Security Notes

- Do not commit `.env`
- Use a strong password and salt
- Treat Tailscale share links as sensitive
- Tailscale provides transport encryption

---

## Troubleshooting

**Server not appearing in Tailscale**
- Verify `TS_AUTHKEY`
- Ensure `/dev/net/tun` is available
- Check container logs

**Clients cannot connect**
- Confirm share was accepted
- Verify port 8999
- Check logs:
  ```bash
  docker compose logs -f
  ```
