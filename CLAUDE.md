# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

**ظل (Ẓill)** — Arabic for *shadow* — is a real-time AI assistant that works silently beside a
customer-service agent during a live call. When the agent presses **Get Answer** at call start, the
system streams the call audio, transcribes both speakers with speaker separation (diarization),
identifies the customer's problem, searches a seeded company knowledge base, and surfaces a grounded
suggested answer with source citations. In parallel it watches the customer's text sentiment: if
anger crosses a threshold or the customer explicitly asks for a manager, it raises a one-time alert
and opens a one-tap escalation dialog naming the relevant supervisor. It is bilingual (Gulf Arabic
and English), The full product specification
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

There is currently no backend code. The PRD calls for a **Dart Frog** backend (a separate
package); when it is added, it will have its own `dart_frog dev` workflow and `pubspec.yaml`.

## Tech Stack (target, per PRD §9)

| Layer           | Technology                        | Notes |
|-----------------|-----------------------------------|-------|
| Frontend        | Flutter Web                       | `flutter_webrtc` for audio capture + native WebSocket to the backend |
| Backend         | Dart Frog                         | Thin relay + orchestrator; single language across client and server |
| Streaming STT   | Deepgram                          | Low-latency streaming with built-in diarization; Arabic support (plain WebSocket) |
| LLM             | OpenAI (GPT-4o-class)             | JSON/structured-output mode; one call returns answer + citations + anger + escalation (REST) |
| Embeddings      | OpenAI `text-embedding-3-large`   | Multilingual (Arabic + English); **3072 dims — Pinecone index must match** |
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

Two-process system; the split exists for one reason — **API keys (Deepgram, OpenAI, Pinecone) and
privileged Firestore access must never ship in the client.** The backend is a thin relay +
orchestrator.

- **Flutter Web client** — WebRTC audio capture, a single WebSocket to the backend, and the agent
  UI (live transcript, suggested answer + citations, anger alert, escalation dialog).
- **Dart Frog backend** — WebSocket/session manager that relays audio to Deepgram (streaming STT
  with diarization), buffers the transcript, runs the analysis cycle, and reads/writes Firestore.

External services: **Deepgram** (streaming STT over WebSocket), **OpenAI** (LLM + embeddings, REST),
**Pinecone** (vector search, REST), **Firebase Firestore** (operational data). None have official
Dart SDKs in this stack — all are called via plain WebSocket/REST.

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

3. **One structured OpenAI call per analysis cycle.** Each cycle: embed the latest customer problem
   text → Pinecone top-K (K≈5) retrieval → single OpenAI call (JSON mode) → parse. The model must
   return *exactly* the JSON shape in PRD §11 (`language`, `problem_summary`, `suggested_answer`,
   `citations`, `anger_score`, `escalation_requested`, `confidence`) and nothing else.

4. **Answers are grounded only in retrieved chunks.** Never let the model invent policy; on a
   retrieval miss it must say so and set `confidence: low`. Citations come from the matched chunks'
   metadata (`title`, `document_id`).

5. **Pinecone index dimension is 3072** to match `text-embedding-3-large`. The embedding model is
   locked; changing it breaks retrieval.

6. **Anger alert fires once per crossing.** Threshold default 7 (a configurable constant). Track an
   `alertFired` flag per session — there is no persistent "anger meter," and the alert must not
   re-fire on every chunk.

7. **`Get Answer` means "start listening now."** It is the call-start trigger; speech before the
   press is not captured. Analysis is debounced to fire at most once every ~6–8s.

### Data model

Operational data is in **Firestore** collections (`agents`, `customers`, `supervisors`, `calls`,
`escalations`); references are stored as plain ID strings and resolved in the backend (no enforced
foreign keys). Knowledge content is in **Pinecone** as vectors + metadata. Full field definitions
are in PRD §10 — consult it rather than guessing field names.

## Demo scope

The build target is a scripted ~3-minute demo (PRD §16). Explicitly **out of scope**: real
telephony, auth/multi-tenant/billing, prosody emotion analysis, and production compliance/consent.
Keep changes inside the PRD's demo scope unless asked otherwise.

## Important Note
after every major change, please update this file (CLAUDE.md). BE CONCISE NO UNNECESSARY FILLER USE BULLET POINTS
