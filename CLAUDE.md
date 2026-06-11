# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

**ظل (Ẓill)** — Arabic for *shadow* — is a real-time AI assistant that works silently beside a
customer-service agent during a live call. Transcription is **automatic from call connect**: the
system streams the call audio and transcribes both speakers with speaker separation (diarization),
streaming the live transcript to the agent. **Get Answer** is a *separate* trigger — pressing it
identifies the customer's problem, searches a seeded company knowledge base, and surfaces **up to
three ranked, source-cited suggested replies** (recommended / more likely / maybe). In parallel it
watches the customer's text sentiment: if anger crosses a threshold or the customer explicitly asks
for a manager, it raises a one-time alert and opens a one-tap escalation dialog naming the relevant
supervisor. It is bilingual (Gulf Arabic and English). The full product specification
lives in `docs/PRD.md` and is the source of truth; read it before making architectural decisions.


## Commands

```bash
flutter pub get                 # install dependencies (run after editing pubspec.yaml)
flutter run -d chrome           # run the app (target is Flutter Web — see PRD §9)
flutter analyze                 # lint / static analysis (uses analysis_options.yaml)
dart format .                   # format
flutter test                    # run all tests
flutter test test/foo_test.dart # run a single test file
flutter test --name "pattern"   # run tests whose name matches a pattern
```

```bash
flutter build web                  # production build (passes)
```

```bash
# Real two-way call (backend/ is the Dart Frog signaling relay + static host)
dart pub global activate dart_frog_cli   # one-time
./tool/deploy_web.ps1                     # flutter build web + copy build/web/* → backend/public/
                                          #   (the tunnel serves this snapshot, NOT live source —
                                          #    re-run after any client change, then hard-reload)
$env:DEEPGRAM_API_KEY="<key>"; dart_frog dev   # from backend/ → :8080 (app + /signal + /transcribe)
cloudflared tunnel --url http://localhost:8080   # public HTTPS URL (mic needs HTTPS)
```

The **`backend/`** package (Dart Frog) is the start of the real backend:
- `routes/signal.dart` — thin WebSocket signaling relay (WebRTC offer/answer/ICE) + serves `public/`.
- `routes/transcribe.dart` — **Deepgram streaming STT relay** (`/transcribe?room=&role=&lang=&sr=`).
  Per-browser, role-based: each browser streams its own mic PCM; the route opens an outbound Deepgram
  socket per client (`nova-3`, `linear16`), tags transcripts with the connection's `role` (the speaker
  label — no `diarize`), and forwards them to the room's **agent** socket. Key from
  `DEEPGRAM_API_KEY` env (never shipped to client). KeepAlive every 8s; `CloseStream` on disconnect.
  Uses `interim_results=true` + `utterance_end_ms`: accumulates a per-connection utterance buffer and
  emits live partials (`final:false`) as the user speaks, committing one bubble per utterance
  (`final:true`) on `speech_final`/`UtteranceEnd` — so a sentence streams live and never fragments.

See `backend/README.md`. Gemini/Pinecone/Firestore orchestration come later.

## Tech Stack (target, per PRD §9)

| Layer           | Technology                        | Notes |
|-----------------|-----------------------------------|-------|
| Frontend        | Flutter Web                       | `flutter_webrtc` for audio capture + native WebSocket to the backend |
| Backend         | Dart Frog                         | Thin relay + orchestrator; single language across client and server |
| Streaming STT   | Deepgram                          | Low-latency streaming with built-in diarization; Arabic support (plain WebSocket) |
| LLM             | Gemini 3.5 Flash                  | JSON/structured-output mode; **two-pass** cycle per Get Answer (problem extraction → ranked replies), REST. Gemini 3.1 Pro = higher-reasoning fallback |
| Embeddings      | OpenAI `text-embedding-3-large`   | Multilingual AR+EN; 3072 dims — Pinecone index must match. Separate provider/key from the LLM (REST) |
| Vector DB       | Pinecone                          | Managed vector search for RAG retrieval (REST) |
| Operational DB  | Firebase Firestore                | Holds `agents`, `customers`, `supervisors`, `calls`, `escalations` |


**Backup:** Google Cloud Speech-to-Text if Deepgram's Gulf-Arabic accuracy underperforms.

## Key Conventions

- BLoC/Cubit states use **Equatable** for value-based equality
- States follow pattern: `Initial`, `Loading`, `Loaded/Success`, `Error`
- Cubits for all features.
- Cubit states use **sealed class** pattern (e.g., `sealed class ClassName extends Equatable`)
- Models use `copyWith()` pattern for immutable updates
- Code comments are written in **English** throughout the entire codebase
- Models in `lib/models/`.
- reusable widgets in `lib/widgets/`.
- Firestore documents use `SetOptions(merge: true)` for partial updates
- Firestore fields use snake_case, models use lowerCamelCase
- **Firestore collection names** use lowercase snake_case in code (e.g. `_db.collection('agents')`), matching the actual Firestore collection names exactly — never capitalize (e.g. `'AGENTS'` is wrong)
- Locally-scoped cubits are created via `BlocProvider` in the page, NOT registered in `main.dart`
- **Feature-grouped cubits**: when a feature needs more than one cubit, group them under `lib/cubits/<feature>_cubits/<specific_cubit>/`. Apply this pattern to every future feature with multiple cubits

## Code Rules

- Every widget must be a reusable widget, created in a single file under `lib/widgets/` and reused across pages — never build widgets inline in pages
- Every reusable function must be created in a single file under `lib/core/utils/` and imported where needed — never build utility functions inline in pages or cubits
- **Every new page** must have a named route registered in `lib/core/routes/app_routes.dart`. Page-to-page navigation must use `Navigator.pushNamed` / `pushReplacementNamed` / `pushNamedAndRemoveUntil` with the `AppRoutes.*` constants — never `MaterialPageRoute(builder: …)` inline
- **Route naming**: single-word page → all lowercase (e.g. `/home`, `/cart`); multi-word page → lowerCamelCase (e.g. `/paymentMethods`, `/orderDetail`, `/editBranch`). Always reference routes via `AppRoutes.<routeName>` constants, never raw strings
- Routed pages that need data must read it via `ModalRoute.of(context)!.settings.arguments`  Don't add required constructor params on routed pages.

## Architecture (target, per PRD)

Two-process system; the split exists for one reason — **API keys (Deepgram, Gemini, OpenAI,
Pinecone) and privileged Firestore access must never ship in the client.** The backend is a thin
relay + orchestrator.

- **Flutter Web client** — WebRTC audio capture, a single WebSocket to the backend, and the agent
  UI (live transcript, up to three suggested replies + citations, anger alert, escalation dialog).
  Reads display-only data (`customers`, `supervisors`) directly from Firestore.
- **Dart Frog backend** — WebSocket/session manager that relays audio to Deepgram (streaming STT
  with diarization), buffers the transcript, runs the two-pass analysis cycle, and **writes** what
  it computes (`calls`, `escalations`) to Firestore.

External services: **Deepgram** (streaming STT over WebSocket), **Gemini** (LLM, REST),
**OpenAI** (embeddings, REST), **Pinecone** (vector search, REST), **Firebase Firestore**
(operational data). None have official Dart SDKs in this stack — all are called via plain
WebSocket/REST.

### Firestore Structure

Customers collection at `customers/{customerId}` with fields: `name`(string), `phone_number`(string), `account_number`(string), `language_preference`(string), `recent_issues`(array), `created_at`(timestamp). Mapped by `CustomerModel` with `fromJson()`/`toJson()` handling Timestamp-DateTime conversion.

Agents collection at `agents/{agentsId}` with fields: `name`(string), `email`(string), `department`(string), `status`(string), `languages`(array), `created_at`(timestamp). Mapped by `AgentsModel` with `fromJson()`/`toJson()`.

Supervisors collection at `supervisors/{supervisorId}` with fields: `name`(string), `department`(string), `email`(string), `available`(boolean). Mapped by `CategoryModel` with `fromJson()`/`toJson()`.

Calls collection at `calls/{callId}` with fields: `agent_id`(string), `agent_name`(string), `customer_id`(string), `customer_name`(string), `started_at`(timestamp), `ended_at`(timestamp), `duration_sec`(number), `language`(string), `issue_category`(string), `transcript`(array), `anger_alert_fired`(boolean), `anger_peak_score`(number), `suggestion_used`(boolean), `escalated`(boolean), `supervisor_id`(string), `citations`(array), `outcome`(string). Mapped by `CallsModel` with `fromJson()`/`toJson()` handling Timestamp-DateTime conversion.

Escalations collection at `escalations/{escalationId}` with fields: `call_id`(string), `agent_id`(string), `customer_id`(string), `supervisor_id`(string), `reason`(string), `triggered_at`(timestamp), `agent_action`(string), `resolved_at`(timestamp). Mapped by `EscalationModel` with `fromJson()`/`toJson()` handling Timestamp-DateTime conversion.


### Load-bearing design rules

These are easy to violate and expensive to retrofit:

1. **Audio source is behind an interface.** The client exposes an `AudioSource` abstraction; the
   demo implementation is `SimulatedWebRtcSource`. Transcription, RAG, anger, and escalation logic
   must be source-agnostic so a future `SoftphoneSource` drops in without touching them.

2. **Storage is `snake_case`; Dart code is `camelCase`.** Convert at the data-access boundary only:
   deserialize `snake_case` → `camelCase` when reading Firestore/Pinecone metadata, serialize back
   when writing. No `snake_case` identifiers in Dart; no `camelCase` keys in storage.

3. **Two-pass Gemini cycle per Get Answer (Option B).** Each press: **Pass 1** reads the transcript
   and returns *exactly* `{language, problem_summary, anger_score, escalation_requested}` → embed
   `problem_summary` (not the raw transcript) with `text-embedding-3-large` → Pinecone top-K (K≈5)
   retrieval → **Pass 2** reads the retrieved chunks and returns *exactly*
   `{suggested_replies: [{label, answer, confidence, citations:[{document_id, title}]}]}`. Both
   calls are JSON-only — no prose around the JSON. See PRD §11 for the full shapes.

4. **Answers are grounded only in retrieved chunks.** Never let the model invent policy. Return
   **up to three** replies (most-to-least confident), each a distinct strategy with its own
   `citations`; the agent-facing Sources strip is the union across replies. Never pad to three. On a
   retrieval miss, return a single low-confidence (`maybe`) reply stating no reliable answer was
   found and suggesting escalation. Citations come from the matched chunks' metadata
   (`title`, `document_id`).

5. **Embedding model is OpenAI `text-embedding-3-large` (3072 dims).** A separate provider/key from
   the LLM. The Pinecone index dimension must match (3072) — changing the model breaks retrieval.
   Can be consolidated onto a Google embedding model later to drop the OpenAI dependency.

6. **Anger alert fires once per crossing.** Threshold default 7 (a configurable constant). Track an
   `alertFired` flag per session — there is no persistent "anger meter," and the alert must not
   re-fire on every chunk.

7. **Transcription is automatic from call connect; `Get Answer` only requests answers.** The live
   diarized transcript streams from the customer's first words — it does not wait for the button.
   `Get Answer` runs the two-pass cycle on the transcript captured so far; pressing again
   regenerates from the latest transcript. (Anger/escalation are evaluated per press; for truly
   continuous alerts, Pass 1 can run periodically over the streaming transcript.) The mocked demo
   now streams the scripted transcript **from call connect** (`_startTranscription` fires on the
   first `SessionConnected`); Get Answer only requests answers — matching the auto-transcription
   target, ready for the real Deepgram stream.

### Data model

Operational data is in **Firestore** collections (`agents`, `customers`, `supervisors`, `calls`,
`escalations`); references are stored as plain ID strings and resolved in the backend (no enforced
foreign keys). Knowledge content is in **Pinecone** as vectors + metadata. Full field definitions
are in PRD §10 — consult it rather than guessing field names.

## Project Structure (`lib/`)

Front-end demo is built and runs (`flutter run -d chrome`). Fully mocked — no backend yet.

```
lib/
├── main.dart                       # ZillApp: MultiBlocProvider (theme/locale/demo) + MaterialApp
├── core/
│   ├── constants/                  # app_constants.dart — Slate tokens + anger/debounce/top-K;
│   │                               #   webrtc_config.dart — useRealCall flag, STUN, signalingUrl()
│   ├── localization/               # app_strings.dart — EN/AR {en,ar} pairs (UI chrome)
│   ├── routes/                     # app_routes.dart — AppRoutes constants + onGenerateRoute
│   ├── theme/                      # app_colors (ThemeExtension), app_text_styles, app_theme (dark+light)
│   └── utils/                      # lang_text (langText/TextPair), time_format, json_time
├── models/                         # runtime (analysis_result, transcript_line, answer_option, citation,
│                                   #   enums) + Firestore-shape (customer, agents, supervisor, calls, escalation)
├── services/
│   ├── audio/                      # AudioSource interface + SimulatedWebRtcSource (rule #1);
│   │                               #   DeepgramTranscriptSource (real STT) + pcm_capture (web-only
│   │                               #   Web Audio mic→PCM, conditional-export stub/web)
│   ├── demo/                       # demo_script_service (scripted content), mock_analysis_service (debounced)
│   ├── socket/                     # signaling_service — WebSocket client to Dart Frog /signal
│   ├── webrtc/                     # peer_call_service — real RTCPeerConnection (live voice)
│   └── firestore/                  # (.gitkeep) future reference-data reads
├── cubits/
│   ├── app_cubits/                 # theme_cubit, locale_cubit (EN/AR+RTL), demo_cubit (mood) — global
│   ├── session_cubit/              # call lifecycle waiting→incoming→connected→ended + Get Answer
│   ├── call_cubits/                # transcript_cubit, answer_cubit, escalation_cubit
│   └── customer_cubit/             # customer phone lifecycle (no Shadow shown)
├── pages/
│   ├── home/                       # role chooser ("Choose a side.")
│   ├── customer/                   # phone screen (idle→ringing→connected→ended)
│   └── call/                       # agent console (cockpit)
└── widgets/                        # reusable UI — app_bar/, common/, home/, customer/, call/, app_shell,
                                    #   demo_controls_panel, background_stage
```

- **Demo control**: `app_cubits/demo_cubit` mood (calm/frustrated) drives all scripted content via
  `services/demo/`; surfaced through the floating `DemoControlsPanel` (the prototype's Tweaks panel).
- **Suggested replies**: 3 tiered options (`AnswerTier` enum: recommended/likely/maybe). The cockpit's
  "Don't use — re-read the call" button appends an angrier follow-up line and swaps in a second
  suggestion set (`DemoScriptService.analysis(round:)`); rounds cycle. `AnswerLoaded` carries `round`.
- **Responsive phone**: `PhoneFrame` keeps a fixed 360×720 design but scales uniformly (FittedBox)
  to fit the viewport height (`MediaQuery`, capped at 1.0) so the call UI never clips on short screens.
- **Customer phone-number field**: cosmetic `PhoneNumberField` (mock — no validation, not sent) above
  the `LanguageChoice` on the idle screen; controller owned by `_CustomerBodyState`.
- **Customer info strip**: agent header is `widgets/call/customer_info_strip.dart` (`CustomerInfoStrip`,
  was inline `_TopStrip`) — a "Previous issues" chip opens `PreviousIssuesDialog`
  (`widgets/call/previous_issues_dialog.dart`), a compact popup listing the customer's last issues as
  labeled rows (mock list shaped like ERD `previous_issues`: summary, category, resolved, source,
  created_at). Date via `formatShortDate` (`core/utils/time_format.dart`, intl).
- **Design reference**: the source prototype lives in `docs/design_ref/` (HTML/CSS/JSX). The Zill skin
  (`styles.css`) overrides Slate's serif with **Plus Jakarta Sans** for display+UI — fonts via
  `google_fonts` (Plus Jakarta Sans / JetBrains Mono / Tajawal for AR). Assets in `assets/`.
- **Real call** (`WebRtcConfig.useRealCall`, default on): customer/agent browsers actually hear each
  other over WebRTC. `CustomerCubit` = caller (offer), `SessionCubit` = callee (offer→ring→answer);
  both inject `SignalingService` + `PeerCallService`, mount a hidden `RemoteAudio` (1×1 `RTCVideoView`).
  Signaling events replace the demo timers; flag off restores the pure timer demo. LAN-only, STUN, no TURN.
- **Real transcription** (`WebRtcConfig.useRealTranscription`, default **off**): when on, the agent's
  `_startTranscription` uses `DeepgramTranscriptSource` (role `agent`) instead of the scripted source,
  and the customer page uplinks its mic (role `customer`, no UI). Both stream PCM to `/transcribe`;
  the agent renders the merged diarized transcript from connect. Flag off → scripted demo. Answers/
  anger stay scripted (`MockAnalysisService`). Needs a real call + HTTPS (mic) + `DEEPGRAM_API_KEY`.
- **Call language is customer-chosen** (Nova-3 streaming has no AR/EN auto-detect): the customer picks
  Arabic/English on the idle phone screen (`LanguageChoice` widget) **before** calling; `CustomerCubit`
  stores it as `callLang` and sends it on the WebRTC `offer`. `SessionCubit` captures it (`callLang`)
  and the agent transcribes in that language too — **independent of either browser's UI locale**. Both
  `DeepgramTranscriptSource`s use this `callLang`. `TranscriptLine.isFinal` (default `true`) distinguishes
  live partials from committed turns; `TranscriptCubit` upserts the live line per speaker and appends on
  final (only finals feed `customerText`/Firestore).
- **Stack added**: `flutter_bloc`, `equatable`, `google_fonts`, `flutter_svg`, `flutter_localizations`,
  `intl`, `flutter_webrtc`, `web_socket_channel`, `firebase_core`, `cloud_firestore`.
- **Firebase initialized**: `lib/firebase_options.dart` (flutterfire-generated, project `zill-ed319`,
  all platforms); `main()` is async and calls `Firebase.initializeApp` before `runApp`. Web SDK is
  bundled via the Dart packages — no `<script>` tags in `web/index.html`. No Firestore reads/writes
  wired yet (services + seeding are next M0/M1 items).
- **Firestore access is hybrid** (target): client reads reference data directly (`customers`, `supervisors`);
  all writes (`calls`, `escalations`) go through the backend over the WebSocket. Currently all mocked.
- Naming matches the conventions above — `core/routes/` (not `router/`), `_cubits` suffix on
  feature groups, snake_case folders.
- Tests: `test/escalation_cubit_test.dart` (one-time fire, rule #6), `test/models_test.dart`
  (snake_case⇄camelCase boundary), `test/widget_test.dart` (boots to Home).

## Demo scope

The build target is a scripted ~3-minute demo (PRD §16). Explicitly **out of scope**: real
telephony, auth/multi-tenant/billing, prosody emotion analysis, and production compliance/consent.
Keep changes inside the PRD's demo scope unless asked otherwise.

## Important Note
after every major change, please update this file (CLAUDE.md). BE CONCISE NO UNNECESSARY FILLER USE BULLET POINTS
