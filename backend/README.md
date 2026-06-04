# Ẓill signaling backend

A thin [Dart Frog](https://dart-frog.dev) WebSocket relay that lets the customer
and agent browsers exchange WebRTC offer/answer/ICE, and serves the built Flutter
web app. The actual voice connects **peer-to-peer** over your LAN — this server
only carries the page download + signaling.

## One-time setup

```bash
dart pub global activate dart_frog_cli   # installs the `dart_frog` command
dart pub get
```

## Run the real call (two computers on the same WiFi)

1. **Build the web app and stage it** (from the repo root):

   ```bash
   flutter build web
   ```

   Copy everything in `build/web/` into `backend/public/`.

2. **Start the relay** (from `backend/`):

   ```bash
   dart_frog dev          # serves http://localhost:8080  (app + /signal)
   ```

3. **Expose it over HTTPS with a tunnel** (HTTPS is required for mic access):

   ```bash
   cloudflared tunnel --url http://localhost:8080
   # or:  ngrok http 8080
   ```

   It prints a public HTTPS URL, e.g. `https://<random>.trycloudflare.com`.

4. **Both machines** open that printed URL and allow the mic:
   - Friend → **I'm the Customer** → Call.
   - You → **I'm the Employee** → the console rings → Answer → you're talking.

The tunnel URL changes each run; share the new one each time. The app derives the
`wss://…/signal` address from whatever origin it loads from, so nothing is
hard-coded.

## Local sanity check (no tunnel)

With `dart_frog dev` running, open `http://localhost:8080` in two tabs
(`localhost` is a secure context, so the mic works). Pick Customer in one and
Employee in the other.
