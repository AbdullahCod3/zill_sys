# Ẓill signaling backend

A thin [Dart Frog](https://dart-frog.dev) WebSocket relay that lets the customer
and agent browsers exchange WebRTC offer/answer/ICE, and serves the built Flutter
web app. The actual voice connects **peer-to-peer** over your LAN — this server
only carries the page download + signaling.

Beyond signaling, the relay also hosts **`/transcribe`** — a per-browser Deepgram
streaming STT relay. Each browser streams its own mic (linear16 PCM) to
`/transcribe?room=…&role=agent|customer&lang=ar|en&sr=48000`; the server opens an
outbound Deepgram socket per client, tags transcripts with that connection's role
(the speaker label), and forwards them to the room's agent socket. Keys stay
server-side.

## One-time setup

```bash
dart pub global activate dart_frog_cli   # installs the `dart_frog` command
dart pub get
```

### Deepgram key (required for `/transcribe`)

The transcription route reads the key from the `DEEPGRAM_API_KEY` environment
variable — it is never sent to the browser. Get a key from
<https://console.deepgram.com> → **API Keys**, then set it before starting:

```powershell
# PowerShell (from backend/)
$env:DEEPGRAM_API_KEY="<your-key>"; dart_frog dev
```

```bash
# bash
DEEPGRAM_API_KEY="<your-key>" dart_frog dev
```

The client only uses real transcription when `WebRtcConfig.useRealTranscription`
is `true` (default off — the scripted demo needs no key).

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
