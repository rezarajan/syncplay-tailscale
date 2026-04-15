# syncplay-tailscale

> Private, Dockerized Syncplay server exposed over Tailscale using raw TCP Serve.

**Repository:** `rezarajan/syncplay-tailscale`

This project packages a Syncplay server and a Tailscale sidecar into a small Docker Compose stack.
The result is a private Syncplay endpoint that is reachable from your tailnet without opening a public port.

---

## What this gives you

- **Syncplay server** running in Docker
- **Tailscale sidecar** that joins your tailnet
- **Tailscale Serve raw TCP forwarding** on port `8999`
- A setup that is simple to share with friends through **Tailscale device sharing**

---

## Why this architecture

Syncplay is a **TCP service**, not an HTTP app.
That means the correct Tailscale integration is **raw TCP forwarding**, not an HTTPS reverse proxy.

```text
Syncplay client
    |
    | tailnet TCP 8999
    v
Tailscale Serve raw TCP
    |
    | 127.0.0.1:8999 in shared network namespace
    v
Syncplay server container
```

The Syncplay container uses the Tailscale container's network namespace, so Tailscale Serve can forward directly to `127.0.0.1:8999`.

---

## Prerequisites

You need:

- Docker Engine
- Docker Compose plugin
- A Tailscale account
- A Tailscale **auth key** for the container node
- A Syncplay client on each machine that will connect

---

## Quick start

### 1. Clone the repository

```bash
git clone https://github.com/rezarajan/syncplay-tailscale.git
cd syncplay-tailscale
```

### 2. Create your env file

```bash
cp .env.example .env
openssl rand -hex 32
```

Paste the generated value into `SYNCPLAY_SALT`.

### 3. Create a Tailscale auth key

In the Tailscale admin console:

1. Open **Settings** or **Admin Console**
2. Go to **Keys**
3. Create an **auth key** for a new device
4. Copy it into `.env`:

```dotenv
TS_AUTHKEY=tskey-auth-xxxxxxxxxxxxxxxx
```

Use an **auth key**, not an API key. The auth key is what lets the Tailscale container register itself as a machine.


### 6. Start the stack

```bash
mkdir -p tailscale/state data
docker compose up -d --build
```

### 7. Check the logs

```bash
docker compose logs -f tailscale
docker compose logs -f syncplay
```

Once the Tailscale node is up, it should appear in your tailnet as the machine name set by `TS_HOSTNAME`.

---

## How to connect

In your Syncplay client, connect to:

```text
syncplay.<your-tailnet>.ts.net:8999
```

or use the machine's Tailscale IP and port `8999`.

Typical client values:

- **Host:** `syncplay.your-tailnet.ts.net`
- **Port:** `8999`
- **Password:** the value of `SYNCPLAY_PASSWORD`
- **TLS:** disabled unless you explicitly enabled Syncplay-native TLS

### Example

```text
Server: syncplay.example-tailnet.ts.net
Port: 8999
Password: correct-horse-battery-staple
```

---

## Sharing with friends over Tailscale

You have two practical options.

### Option A: invite them to your tailnet

This is best for recurring users you trust.

### Option B: share only this machine

This is usually the cleaner option for a Syncplay server.

To share just this server:

1. Open the Tailscale admin console
2. Go to **Machines**
3. Select the `syncplay` machine
4. Open the machine menu
5. Click **Share**
6. Send the generated share link to your friend

Your friend accepts the share from their own Tailscale account, and the machine becomes visible to them without exposing the rest of your tailnet.

### What your friend does

1. Install Tailscale
2. Sign in to their Tailscale account
3. Accept the machine share
4. Install Syncplay
5. Connect to the shared machine name or shared Tailscale IP on port `8999`

This is a good fit for Syncplay because they only need inbound access to this one server.

---

## Configuration reference

### Syncplay variables

| Variable | Purpose |
|---|---|
| `SYNCPLAY_VERSION` | Version of Syncplay used for image build |
| `SYNCPLAY_PORT` | Server port inside the container namespace |
| `SYNCPLAY_PASSWORD` | Optional Syncplay server password |
| `SYNCPLAY_SALT` | Salt used for password handling |
| `SYNCPLAY_ISOLATE_ROOM` | Whether to isolate rooms from one another |
| `SYNCPLAY_DISABLE_READY` | Disable ready-state support |
| `SYNCPLAY_DISABLE_CHAT` | Disable chat |
| `SYNCPLAY_MAX_CHAT_MESSAGE_LENGTH` | Optional chat length limit |
| `SYNCPLAY_MAX_USERNAME_LENGTH` | Optional username length limit |
| `SYNCPLAY_MOTD_FILE` | Optional MOTD file path |
| `SYNCPLAY_STATS_DB_FILE` | Optional stats DB file path |
| `SYNCPLAY_TLS_PATH` | Optional Syncplay-native TLS path |

### Tailscale variables

| Variable | Purpose |
|---|---|
| `TS_AUTHKEY` | Tailscale auth key for node enrollment |
| `TS_HOSTNAME` | Tailscale machine hostname |
| `TS_EXTRA_ARGS` | Optional extra flags such as tags |

---

## Daily operations

### Start

```bash
docker compose up -d
```

### Stop

```bash
docker compose down
```

### Rebuild after changing the Syncplay version

```bash
docker compose build --no-cache
docker compose up -d
```

### Follow logs

```bash
docker compose logs -f syncplay
docker compose logs -f tailscale
```

### Check rendered Compose config

```bash
docker compose config
```

---

## GitHub Container Registry

The image publish workflow pushes to:

```text
ghcr.io/rezarajan/syncplay-tailscale
```

Once published, you can switch the Compose file from `build:` to `image:` if you want to deploy prebuilt images instead of building locally.

Example:

```yaml
image: ghcr.io/rezarajan/syncplay-tailscale:latest
```

---

## GitHub Actions release flow

This repository is set up so you should not have to edit a version in multiple places.

Use `.syncplay-version` as the single source of truth.

### Normal bump flow

1. Change `.syncplay-version`
2. Commit and push
3. CI validates the build
4. Publish workflow builds and pushes the image

### Release flow

1. Create a Git tag or GitHub Release
2. The publish workflow builds and tags the image accordingly

### Manual one-off build

Use `workflow_dispatch` and pass a version override when needed.

---

## Security notes

- Keep `.env` out of Git
- Treat Tailscale share links as sensitive
- Use a strong `SYNCPLAY_PASSWORD`
- Use a long random `SYNCPLAY_SALT`
- Persist `tailscale/state` so the node identity survives restarts
- Prefer Tailscale transport security instead of trying to terminate TLS externally for Syncplay

---

## Troubleshooting

### The Tailscale machine never appears

Check:

- `TS_AUTHKEY` is valid
- the key is not expired or revoked
- the container can access `/dev/net/tun`
- `tailscale/state` is writable

### Friends cannot connect

Check:

- the machine was shared successfully
- they accepted the share
- they are using the correct machine name or Tailscale IP
- Syncplay is listening on `8999`
- the password matches

### Syncplay starts but clients still fail

Check logs:

```bash
docker compose logs -f syncplay
docker compose logs -f tailscale
```

Confirm the service is rendered as raw TCP Serve and not an HTTP/HTTPS proxy.

---

## Development notes

This project intentionally keeps the runtime simple:

- one Syncplay process
- one Tailscale sidecar
- raw TCP forwarding only
- configuration through environment variables
- no public ingress required

That makes it a good fit for small private watch parties and low-maintenance homelab deployment.
