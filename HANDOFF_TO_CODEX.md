# OpenClaw — Engineering Handoff

> Target reader: a fresh agent (Codex / GPT 5.5) picking up cold with **no chat context**.
> Do not trust prior commit messages or README enthusiasm. This document is the source of truth.
> Goal of this handoff: state honestly what exists, what doesn't, what's wrong, and what "good" looks like — so you can ship a build the user is willing to put in front of someone.

> **Visual direction was changed 2026-05-03 evening.** OpenClaw is now a **pastel pixel toy-world** virtual pet game (chibi creatures, dark purple/navy outlines, chunky pixel UI panels, soft clouds, geometric trees, floating snack capsules). The earlier "cyber-Y2K / Frutiger Aero" direction is dead — see §0a and `docs/ART_DIRECTION.md`. Where this handoff still references "Aero" or "glass" below, treat it as legacy context for the pivot, not a target.

---

## §-1. Current state — 2026-05-03 21:05 MDT

**Branch:** `feat/local-dev-bringup` @ `569d7f8` (NOT pushed). 14 commits ahead of `01cd6dc` baseline. `/loop 10x` ran to completion.

**Build:** `** BUILD SUCCEEDED **` for iPhone 17 / iOS 26.5 simulator (Xcode 26.5 Beta 3, Metal Toolchain present but not required since the .metal shader was deleted in the pixel pivot).

**Backend:** `npm run dev` listens on `127.0.0.1:8989`. Local fallback verified — `OPENROUTER_FREE_MODEL=openrouter/free` is a placeholder slug, so every event currently flows through `localFallbackReaction` deterministically; iOS cannot tell the difference and the app remains playable with no key.

**Latest iteration loop:** the user invoked `/loop 10x review improve debug make better` after the SpriteKit rip. Iters 1–7 shipped (counter at 8 in `/tmp/openclaw-loop-iter`); the loop was stopped on iter 8 by user request to write this handoff. The 7 commits are atomic and each named `feat(ios): iter N/10 — <subject>`.

### What iters 1–7 added (since the KISS rewrite)

| Iter | Commit  | What it shipped |
|------|---------|-----------------|
| 1    | `cb74bd5` | `Game/Haptics.swift` (light/medium/warning/success). Pet tap → light, eat → medium, miss → warning, hatch → success. Hatch flash overlay (white plus-lighter for 0.55s) + tap-pulse spring (1.0 → 1.10). |
| 2    | `67b59f5` | First-launch ritual: `hasOnboarded` persisted in UserDefaults. `HintPanel` overlay shows a soft pulsing glow ring + a chunky pixel "tap the egg" panel above the egg. Self-dismisses on first tap. |
| 3    | `c7fc26f` | `EatSparkle` view: 6 white pixel squares fan out from the pet anchor in a hex pattern over 0.6s on `resolveCapsule`. Drives off `eatSparkleUntil` timestamp on `PetViewModel`. |
| 4    | `6888a80` | Sprite priority ladder in `PixelPetView`: `egg → eating → blinking → idle`. Pet swaps to existing `petHappy` sprite during the eat window. |
| 5    | `3928fb3` | Stage progression on teach: hatchling → learner; learner → toddler @ bond > 0.35; toddler → buddy @ bond > 0.65; buddy → bff @ bond > 0.85. Each promotion fires the same `hatchFlashUntil` + `Haptics.hatch()` celebration. |
| 6    | `965660f` | Second-stage hint "tap a snack to feed". `firstFeedDone` flag persisted in UserDefaults. `OnboardingHint` was generalized into `HintPanel(text:anchor:glowAnchor:)`. |
| 7    | `3935ba4` | `PixelSprite.clawClosed` (prongs converge). `ClawSpriteView` swaps closed sprite during `.grabbing/.returning/.delivering`. Spring scale-punch 1.0 → 1.18 on grab. |
| 8    | `f760c9f` | Third tutorial hint "tap TEACH to grow it" gated on `firstFeedDone && !firstTeachDone`. `Snack.spawnReplacement` now picks a random different `Kind`. |
| 9    | `1250126` | UX clarity for two complaints. Pet alerted state (1.06 scale + 8pt lift, spring) while claw is in motion. Snacks subtle scale-pulse. Teaching modal: visible X close button, lowercase header, clearer copy ("type any short sound. it will try to copy." + placeholder "e.g. mi  ba  woo"), OK disabled on empty input, `.submitLabel(.done)` for return key, scrim 0.18 → 0.35. |
| 10   | `569d7f8` | Final audit pass. Egg speckles changed from apple-red to honey-tan (less spotty, more egg-like). Onboarding hint anchor moved up 30pt; snack-zone hint moved down 5% so panels don't overlap their targets. |

### How the user-facing flow looks now

1. Cold launch → pastel sky, drifting clouds, parallax trees, green floating platform with the pixel egg, six floating snack capsules, claw parked at the top with a dashed pixel cable hanging through. Status panel up top with bond/mood/full pills. Single TEACH button at the bottom.
2. **Soft pulsing glow ring around the egg + "tap the egg" pixel panel** above it — only on first launch.
3. Tap egg → success haptic → 0.55s white flash → stage transitions to hatchling → chibi pixel pet replaces the egg → onboarding hint dismisses.
4. **"tap a snack to feed" hint** appears in the snack zone — only until first feed.
5. Tap any snack → claw descends with a dashed-cable trail → closes on the snack with a scale-punch spring → returns up holding the snack → arcs over to the pet → snack disappears → pet swaps to `petHappy` sprite + 6-pixel hexagonal sparkle burst + medium haptic.
6. Open TEACH → type a sound → "OK" → pet echoes "abc..." → if pet was hatchling, promotes to learner with the same flash+haptic celebration.

### Files added in this session

```
docs/ART_DIRECTION.md                                 (full pixel-art spec)
docs/GDD.md                                           (existing, light copy update)
ios/OpenClawApp/Game/ClawWorldView.swift              (NEW — pure-SwiftUI claw world)
ios/OpenClawApp/Game/Haptics.swift                    (NEW)
ios/OpenClawApp/Game/Species.swift                    (NEW — 8 species + 4 rigs + traits)
ios/OpenClawApp/Rendering/PixelPalette.swift          (NEW)
ios/OpenClawApp/Rendering/PixelArt.swift              (NEW — sprite renderer + library)
ios/OpenClawApp/Rendering/PixelHabitat.swift          (NEW — sky + clouds + trees)
.backup/2026-05-03-pixel-pivot/AeroBackdrop.swift     (backup of removed file)
.backup/2026-05-03-pixel-pivot/AeroGlassShader.metal  (backup of removed file)
.backup/2026-05-03-spritekit-rip/ClawMachineScene.swift (backup of removed file)
.backup/2026-05-03-spritekit-rip/ClawMachineView.swift  (backup of removed file)
```

### Files removed (in active path; backups kept)

- `ios/OpenClawApp/Rendering/AeroBackdrop.swift`
- `ios/OpenClawApp/Rendering/AeroGlassShader.metal`
- `ios/OpenClawApp/Game/ClawMachineScene.swift`
- `ios/OpenClawApp/Game/ClawMachineView.swift`

### Known gaps to pick up next

These are the natural next-iter targets if you continue the loop:

1. **Pet sprite is the same for all 8 species.** `Species.swift` enumerates them all (orb/kit/cub/axo/pup/chick/slime/shade) but only the `orb` sprite (`PixelSprite.pet/petBlinking/petHappy`) is drawn. Author rig-specific sprites for the other 7. `Species.defaultBodyColor` is wired through; just need silhouettes per `RigFamily`.
2. **No sound.** `ios/OpenClawApp/Audio/` directory not yet created. Bundling small chiptune WAVs for chirp/grab/miss/teach is the next polish wedge.
3. **No "looking up" sprite when claw approaches.** Pet currently doesn't react to the claw descending. A `petCurious` frame swapped in during `case .descending` of `ClawState` is a cheap win.
4. **`PixelTeachingPanel` modal still uses `runtime.cancelTeaching()` on background tap-out** — but the mic/speech path (`SpeechRecognizer.swift`) isn't wired into the panel yet. Mic permission flow not exercised on first run.
5. **No teaching hint after first feed.** Tutorial chain is `egg-tap → snack-tap → ???`. A third `HintPanel` pointing at the TEACH button (gated on `firstFeedDone && !firstTeachDone`) would close the loop.
6. **Backend stage sync is ignored.** `PetVisibleResponse` decodes only `mode/text/animation/emotion/statePatch`. Server's `nextStage` logic in `respondToPetEvent.ts` doesn't reach iOS. Currently mirrored locally in `PetViewModel.nextStage(after:)`. Either add stage to the response type or accept the mirror.
7. **Snack respawn is unbounded.** Every grab spawns a fresh one of the same kind; over a long session there's no scarcity or variety throttle. Cosmetic only.

### KISS interaction model (locked)

The world has exactly three taps:
- **Tap pet** → wake (egg) / interact (chibi).
- **Tap floating snack** → claw fetches → drops on pet → reaction.
- **Tap TEACH** → modal → type/speak → echo.

DROP, FEED, slider — all permanently removed. Don't add them back. If you need a new world action, prefer a new tap target on something already on screen.

### Where to resume

```bash
cd /Users/alexl/Projects/OpenClawStarter/server && npm run dev &
xcrun simctl boot "iPhone 17"
cd /Users/alexl/Projects/OpenClawStarter
xcodegen generate    # only if you edit project.yml
xcodebuild -project OpenClawStarter.xcodeproj -scheme OpenClawApp \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  -configuration Debug build CODE_SIGNING_ALLOWED=NO
xcrun simctl uninstall booted com.openclaw.app  # to retest first-launch hints
xcrun simctl install booted ~/Library/Developer/Xcode/DerivedData/OpenClawStarter-*/Build/Products/Debug-iphonesimulator/OpenClawApp.app
xcrun simctl launch booted com.openclaw.app
```

To resume the iteration loop: `/loop 10x review improve debug make better` (counter is at 8 in `/tmp/openclaw-loop-iter`; the loop will pick up from iter 8 if you choose to count from there, or reset by writing `1` to that file).

---

## 0a. Art direction (CURRENT — read this first)

OpenClaw is a **pastel pixel toy-world** virtual pet game. Spec lives in `docs/ART_DIRECTION.md`. Summary:

- **Visual reference:** cute pixel chibi creatures, big heads / tiny bodies / short limbs, dark purple/navy pixel outlines, large square eyes, simple tiny mouths, pastel sky+platform world, floating snacks/items, chunky pixel UI panels, soft clouds, simple geometric trees and platforms.
- **NOT:** realistic 3D, dark cyberpunk, generic chatbot, finance/crypto, sterile iOS utility.
- **Creature system v1:** 8 base species max (`orb`, `kit`, `cub`, `axo`, `pup`, `chick`, `slime`, `shade`), 4 rig families (orb/blob, cat/bunny, bear/koala, axolotl/dragon/charm). Modular trait slots: body / ears-horns-fins / eyes / chest emblem / skin material / accessory / mutation overlay. Rarity is cosmetic only (common → secret form). **No crypto, no marketplace, no financialized rarity language. Common pets must feel lovable and fully useful.**
- **Banned legacy terms:** `cyber-Y2K`, `Frutiger Aero`, `glass terrarium`, `aurora`, `glass egg`. Use "pastel pixel toy-world", "platform habitat", "pixel egg" / "chibi egg".

The pixel-art layer that ships in this commit:
- `ios/OpenClawApp/Rendering/PixelPalette.swift` — every color token from `docs/ART_DIRECTION.md` §4.
- `ios/OpenClawApp/Rendering/PixelArt.swift` — `PixelSprite` + `PixelArt` Canvas-based renderer + sprite library (pet idle / blink / happy, egg, clouds, tree, platform, snacks: apple/honey/leaf/berry/shell/mystery).
- `ios/OpenClawApp/Rendering/PixelHabitat.swift` — pastel sky gradient + drifting clouds + parallax trees.
- `ios/OpenClawApp/Game/Species.swift` — Species + RigFamily + trait enums + `PetTraits.firstHatchling`. Currently only the `orb` species sprite is fully drawn; the other 7 species share that sprite as a placeholder until rig-specific sprites are authored.
- `ios/OpenClawApp/Game/ClawRoomView.swift` — rewritten to compose `PixelHabitat` + platform + chibi pet + chunky pixel HUD (DROP / TEACH / FEED) + pixel slider + pixel teaching modal.
- `ios/OpenClawApp/Game/ClawMachineScene.swift` — repainted: capsules are `SKSpriteNode`s rendered from `PixelSprite` rasterizations (snacks), claw is a chunky pixel sprite, cable is a 2px hard-stroked path with a pixel-stitched look, scene background is fully transparent so it sits over `PixelHabitat`.

Files removed (backed up to `.backup/2026-05-03-pixel-pivot/`):
- `ios/OpenClawApp/Rendering/AeroBackdrop.swift`
- `ios/OpenClawApp/Rendering/AeroGlassShader.metal`

The Metal Toolchain is no longer required by the build because there is no `.metal` source. You can keep it installed (it's already on disk) but a fresh checkout doesn't need it.

---

## 0. Truth-in-advertising — read first

The previous session got the app to **launch** on iOS 26.5 simulator and confirmed network round-trip to a local backend. That is not the same as "working." The user's verbatim feedback after seeing it run:

> "It doesnt even function, and the design is rediculous."

He is right on both counts. Concretely:

- **Function gap:** The pet does not feel alive. Tap-to-react has no animation. The teaching loop has no entry point unless you grab a "word" capsule. Mic permission is not exercised on first run. The backend returns empty text on bootstrap, so nothing visible changes after the network call. Stage transitions only fire on `tap_pet` (egg→hatchling) and `teaching_*` (hatchling→learner) — every other event silently no-ops on stage. There is no audio, no haptics, no first-minute ritual.
- **Design gap:** The egg is two black dots on a circle. The capsules are flat coloured circles in a row at the bottom, not capsules. The DROP button is a default SwiftUI capsule. The Frutiger Aero direction is asserted in the gradient and ignored everywhere else (no glass bevels, no chrome edges, no aurora highlights, no pixel-charm density, no claw with depth, no terrarium glass). The Metal shader (`AeroGlassShader.metal`) is compiled and shipped in the app bundle but **never applied** to any view.

Treat this handoff as a re-spec, not a continuation.

---

## 1. Mission

OpenClaw is a **magic-first virtual pet** that begins nonverbal and becomes personalized through teaching. The user never configures AI. Provider, keys, model routing, fallback — all invisible.

Three commitments that are non-negotiable:

| Commitment | What it means in code |
|---|---|
| **No AI setup screen** | App must never render a model picker, API-key field, or "OpenRouter" string. The word "OpenRouter" must not appear in any user-visible bundle resource. |
| **Magical onboarding** | First minute is a story, not a settings flow. Permission prompts are written as in-fiction beats (see `ios/OpenClawApp/Privacy/ConsentCopy.swift`). |
| **Local fallback always** | The app must remain playable with no network and no `OPENROUTER_API_KEY`. Today this works because the backend's `localFallbackReaction` returns plausible state patches and the iOS view model has its own `localReaction`. Never regress this. |

---

## 2. Repo facts (verified 2026-05-03)

| Fact | Value |
|---|---|
| Repo path | `/Users/alexl/Projects/OpenClawStarter` |
| Branch | `feat/local-dev-bringup` |
| HEAD | `ceaae8d fix(ios): unblock simulator launch on iOS 26.5 + Xcode 26 beta` |
| Pushed | **No** — never push without Alex's explicit word |
| Toolchain | Xcode 26.5 Beta 3 at `/Applications/Xcode-26.5.0-Beta.3.app` |
| iOS deployment target | 17.0 (project.yml line 5); SDK is iOS 26.5 |
| xcodegen | `/opt/homebrew/bin/xcodegen` v2.45.4 |
| Backend port | `127.0.0.1:8989` (8787/8788 collide with other Python services on this Mac — do not "fix" this) |
| OpenRouter env | `server/.env` carries `OPENROUTER_API_KEY=replace_on_server_only`. There is no real key; everything currently flows through the local fallback path. |

**Project regeneration rule.** `project.yml` is the source of truth. The `.xcodeproj`, `Info.plist` files for both extensions, and `.entitlements` files are regenerated by `xcodegen generate`. Do not hand-edit those generated files — your edits will be wiped. If you need plist or entitlement keys, add them under `info.properties` / `entitlements.properties` in `project.yml`.

---

## 3. Build & run procedure (verified working)

### 3a. Backend
```bash
cd /Users/alexl/Projects/OpenClawStarter/server
npm install              # only on first checkout; node_modules is gitignored
npm run dev              # leaves :8989 listening; tsx watches src/
```
Logs: `tsx` writes to stdout; in this session it was redirected to `/tmp/openclaw-server.log`.

Smoke checks:
```bash
curl -s http://127.0.0.1:8989/health
# {"ok":true,"service":"openclaw-server"}

curl -s -X POST http://127.0.0.1:8989/v1/pet/bootstrap \
  -H "Content-Type: application/json" \
  -d '{"petId":"pet-1","installToken":"tok-1","localTimestamp":"2026-05-03T00:00:00Z"}'
# {"mode":"chirp","text":"","animation":"egg_awaken",...}
```

### 3b. iOS (simulator)
```bash
cd /Users/alexl/Projects/OpenClawStarter
xcodegen generate
xcrun simctl boot "iPhone 17"        # iOS 26.5 stock device, prefer over custom
xcodebuild -project OpenClawStarter.xcodeproj \
  -scheme OpenClawApp \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  -configuration Debug build CODE_SIGNING_ALLOWED=NO
xcrun simctl install booted \
  ~/Library/Developer/Xcode/DerivedData/OpenClawStarter-*/Build/Products/Debug-iphonesimulator/OpenClawApp.app
xcrun simctl launch booted com.openclaw.app
```

### 3c. Toolchain dependencies (one-time, both already installed on this Mac)
- iOS 26.5 simulator runtime (mounted at `/Library/Developer/CoreSimulator/Volumes/iOS_23F5069b`)
- Metal Toolchain 17F5032f — `xcodebuild -downloadComponent MetalToolchain` (~688 MB). Required because `ios/OpenClawApp/Rendering/AeroGlassShader.metal` uses `[[ stitchable ]]` SwiftUI shader syntax, which the Xcode 26 beta does not ship by default.

### 3d. Common gotchas
- **App-extension Info.plist must include `CFBundleDisplayName`** on iOS 26.5, or `simctl install` fails with "Appex bundle … does not have a CFBundleDisplayName key". Already fixed in `project.yml` for both broadcast + widget.
- **Boot a stock simulator (iPhone 17) — do not create a fresh `iPhone 16 Pro OpenClaw` device.** Custom devices go through a long first-boot ritual (10+ min observed) where they hang at the Apple boot screen. The stock devices come pre-prepared.
- **`xcrun simctl list runtimes available` lies.** It hides runtimes that are mounted but not "available for download." Use `xcrun simctl list runtimes` (no filter).
- **Disk pressure.** This Mac runs with ~14 GB free. Don't run `xcodebuild -downloadAllPlatforms` (downloads tvOS + visionOS + watchOS too, ~30 GB).

---

## 4. File map (ground truth)

### iOS app (`ios/OpenClawApp/`)

| Path | Role | Notes |
|---|---|---|
| `App/OpenClawApp.swift` | `@main` SwiftUI app | 13 lines. Just hosts `RootView` with a `@StateObject PetViewModel`. |
| `App/RootView.swift` | First view, kicks off bootstrap | 12 lines. Renders `ClawRoomView` and calls `runtime.bootstrapIfNeeded()` in a `.task`. |
| `Game/PetState.swift` | Codable pet model + `PetStage` enum | `PetStage`: `egg, hatchling, learner, toddler, buddy, bff`. `PetState.newborn()` is the seed. |
| `Game/PetViewModel.swift` | `@MainActor` runtime | Persists to `UserDefaults` key `openclaw.petState.v1`. Holds the local-reaction logic. |
| `Game/ClawRoomView.swift` | Main composed screen | Contains `PetStatusBar`, `PetAvatarView`, `ClawMachineView`, slider+DROP, optional `teachingPanel`. The teaching panel is only mounted when `runtime.isTeaching` is true, which only flips when a "word" capsule is grabbed — meaning the user has no obvious way to teach a sound on first launch. |
| `Game/ClawMachineView.swift` | `UIViewRepresentable` wrapping `SKView` | Trivial bridge. Scene is constructed once in `ClawRoomView` body — that's a SwiftUI smell (recreated on every view init). |
| `Game/ClawMachineScene.swift` | `SKScene` + claw + 14 capsules | Capsules are `SKShapeNode` ellipses with a label glyph. Physics with gravity = -5.2. |
| `Rendering/PixelPalette.swift` | Color tokens for the pastel pixel toy-world | Every Color the app uses. Mirror of `docs/ART_DIRECTION.md` §4. |
| `Rendering/PixelArt.swift` | `PixelSprite` data + `PixelArt` Canvas renderer + sprite library | Pet (idle/blink/happy), egg, clouds, tree, platform, snacks (apple/honey/leaf/berry/shell/mystery). |
| `Rendering/PixelHabitat.swift` | Pastel sky + drifting clouds + parallax trees backdrop | Replaces the old `AeroBackdrop`. |
| `Speech/SpeechRecognizer.swift` | `SFSpeechRecognizer` + `AVAudioEngine` | Now configures `AVAudioSession(.playAndRecord, mode: .measurement)` before start (this session's fix). Not yet wired into `ClawRoomView`. |
| `Speech/PetSpeechSynthesizer.swift` | `AVSpeechSynthesizer` wrapper | Not yet invoked. |
| `API/PetAPI.swift` | Async POST client | Reads `OPENCLAW_API_BASE_URL` from Info.plist (defaults to `http://127.0.0.1:8989`). Sends `X-Install-Token` header from `DeviceIdentity.installToken` (UUID, persisted in UserDefaults). |
| `Privacy/ConsentCopy.swift` | Permission strings | Story-mode copy lives here. Mirror in `project.yml info.properties`. |
| `PiP/PetPiPHost.swift` | PiP companion scaffold | Not wired. Out of scope until base feels real. |
| `Activity/PetLiveActivityManager.swift` | Live Activity scaffold | Not wired. |
| `Snap/SnapShareService.swift` | Snap handoff scaffold | Not wired. |

### Backend (`server/src/`)

| Path | Role |
|---|---|
| `index.ts` | Express on `:8989`. `GET /health`, `POST /v1/pet/bootstrap`, `POST /v1/pet/event`. Bootstrap returns a hard-coded chirp; events route through `respondToPetEvent`. |
| `agent/respondToPetEvent.ts` | Calls `callOpenRouterJSON` with `tabulaRasaPrompt`; on any error returns `localFallbackReaction(event)`. Persists state patch via `patchPetState`. |
| `agent/localFallbackReaction.ts` | Pure function. The deterministic local pet brain. This must always succeed — the app's "works without OpenRouter" promise depends on it. |
| `agent/tabulaRasaPrompt.ts` | System prompt for the LLM. The pet is told to start nonverbal. |
| `agent/languageLearning.ts` | Lexicon update logic. |
| `agent/autonomyScheduler.ts` | Initiative tick scaffold. |
| `llm/modelRouter.ts` | `chooseModel(task, env)` — in `dev` always returns `OPENROUTER_FREE_MODEL` (defaulting to the literal string `"openrouter/free"`, which is not a real model — see §6). |
| `llm/openRouterClient.ts` | Thin HTTP wrapper around OpenRouter chat completions, JSON-mode. |
| `memory/inMemoryStore.ts` | RAM-only state by `installToken:petId`. **Wipes on restart.** |
| `memory/memoryPolicy.ts` | Memory layer policy stub. |
| `safety/redaction.ts` | Outbound safety filter stub. |
| `snap/createSnapSuggestion.ts` | Snap caption generator stub. |
| `types.ts` | Shared TS types: `PetStage`, etc. |

---

## 5. Network contract (what iOS sends, what server returns)

### `POST /v1/pet/bootstrap`
**Request body** (Zod-validated, `BootstrapSchema` in `server/src/index.ts`):
```json
{ "petId": "<uuid>", "installToken": "<uuid>", "localTimestamp": "<iso8601 string>" }
```
**Header:** `X-Install-Token: <uuid>` (overrides body's `installToken` if present).

**Response:**
```json
{
  "mode": "chirp",
  "text": "",                  // empty string when stage=egg, "pi...?" otherwise
  "animation": "egg_awaken",
  "emotion": "curious",
  "statePatch": { "moodDelta": 0.01, "bondDelta": 0, "energyDelta": -0.001, "hungerDelta": 0.001 }
}
```

### `POST /v1/pet/event`
**Request body** (`EventSchema`):
```json
{ "petId": "<uuid>", "eventType": "<string>", "text": "<string|null>", "localTimestamp": "<iso8601>" }
```
**Header:** `X-Install-Token: <uuid>` — **required**, returns 401 without it.

**Event types currently emitted by iOS:** `tap_pet`, `claw_capsule`, `teaching_text`. Server also accepts `teaching_audio`, `snap_event`, `screen_observation` but iOS doesn't send them.

**Response (success):** `AgentOutputSchema` from `respondToPetEvent.ts`:
```json
{
  "mode": "chirp" | "gesture" | "word_fragment" | "phrase" | "conversation",
  "text": "<string>",
  "animation": "<string>",
  "emotion": "<string>",
  "statePatch": { "moodDelta": <number>, "bondDelta": <number>, "energyDelta": <number>, "hungerDelta": <number> },
  "learningEvents": [...],
  "memoryCandidates": [...],
  "initiativeCandidate": ...
}
```

**Response (LLM fails):** Same shape, generated by `localFallbackReaction`. The fallback is deterministic per `eventType`. iOS cannot tell the difference — by design.

iOS decoder is `PetVisibleResponse` in `API/PetAPI.swift` — note it only decodes the first five fields. `learningEvents` / `memoryCandidates` / `initiativeCandidate` are dropped on the client today. **If you start using them, extend `PetVisibleResponse`.**

---

## 6. The dev-mode model is fake

`server/.env` ships with `OPENROUTER_FREE_MODEL=openrouter/free`. **There is no model named `openrouter/free` on OpenRouter.** What this means:

- In `dev` env, every `/v1/pet/event` call hits `callOpenRouterJSON` → OpenRouter rejects it → exception → `localFallbackReaction` runs → response returned.
- The user perceives this as "the AI works." It does not. They are seeing the deterministic fallback.
- This is fine for shipping the local-fallback contract, but **do not claim LLM behavior in demos.**

To exercise the real LLM in dev:
1. Replace `replace_on_server_only` in `server/.env` with a real OpenRouter key.
2. Replace each `OPENROUTER_*_MODEL` value with a real OpenRouter model slug (e.g. `meta-llama/llama-3.3-70b-instruct:free`, `anthropic/claude-3.5-haiku`, etc — the user is on Opus 4.7 in their own work; consult OpenRouter's model catalog at runtime).
3. Restart `npm run dev`.

The iOS app will not change. The model selection is invisible by design.

---

## 7. Severity-ranked gap list

### S0 — App is not enjoyable to use right now
1. **No first-minute ritual.** App opens directly into the claw room. No splash beat, no "wake the egg" gesture, no first-tap reveal. The GDD's "Zero-Setup First Minute" flow (`docs/GDD.md` §"Zero-Setup First Minute") is not implemented end-to-end.
2. **No teaching entry point on first launch.** `runtime.isTeaching` only flips on grabbing a "word" capsule. New users will not discover this. The flow needs an explicit "Teach it your first sound" beat that fires when stage transitions to `hatchling`.
3. **Pet has no idle life.** `PetAvatarView` is static except for a 1.05× scale on animations containing the substring "bounce". No breathing, no blink, no pulse on `egg_pulse`, no glow.
4. **Tap pet does nothing visible.** `handleTapPet` updates state but `PetAvatarView` doesn't visualize `currentAnimation` other than the bounce-scale check. Users tap, nothing happens, they put it down.
5. **Audio is silent.** No background ambient, no chirp on bootstrap, no sound on capsule grab. `PetSpeechSynthesizer` exists and is unused.
6. **No haptics.** Claw drop, capsule grab, miss — all silent. `UIImpactFeedbackGenerator` not referenced anywhere.

### S1 — Design does not match brief
7. **Egg is two black dots.** It needs to read as a glass capsule with internal liquid and a soft pulse. Aurora highlight, chromatic edge, breathing scale 0.98↔1.02 over 2.4s.
8. **Capsules are flat circles with one glyph.** Real "Y2K capsules" need a glossy two-tone sphere with a top highlight, bottom shadow, an inner glyph that looks etched. The current `SKShapeNode` ellipse fill is not enough — use `SKShapeNode` with gradient texture, or compose with `SKSpriteNode` rendering a pre-baked image.
9. **Claw has no depth.** Currently a rounded white rectangle. Needs a 3-prong silhouette and visible cable links (segments, not a single line).
10. **DROP button is default SwiftUI capsule.** Should read as a chunky Y2K plastic button with bevel, label letter-spaced and shadowed, depress on press with audible click + haptic.
11. **Backdrop has gradient + grid + blur orbs but no animation.** Frutiger Aero is not a static gradient — it has subtle parallax light. Animate the orbs slow-drifting; animate the grid gentle rotation; apply the unused `AeroGlassShader` as a `.layerEffect` on a top layer.
12. **No scanlines or pixel detail on the cyber-Y2K side.** `PixelCharmGrid` is a hidden charm — fine — but there's no scanline overlay, no crisp 1-px white frame around the terrarium, no datestamp/clock chrome.

### S2 — Architecture smells that will bite later
13. **`SKScene` constructed in `ClawRoomView` body** as a stored `private let`. SwiftUI re-instantiates the view often; `SKScene` should be in the `@StateObject` or wrapped in a `Coordinator`.
14. **`PetVisibleResponse` drops three fields** (`learningEvents`, `memoryCandidates`, `initiativeCandidate`). Once the agent layer becomes real, these need to flow into `PetState`.
15. **In-memory store wipes on backend restart.** Fine for prototype. Plan to swap for SQLite/`better-sqlite3` when persistence becomes load-bearing — schema in `server/src/memory/inMemoryStore.ts`.
16. **No retries / no backoff** on `URLSession` calls. A flaky network drops events silently into `lastBackendError` with no UI surfacing.
17. **Server rejects events without `X-Install-Token`** with 401 but iOS always sends it. No regression risk today; just be aware if you add a second client.

### S3 — Hygiene
18. `inMemoryStore` is keyed `${installToken}:${petId}` — fine, but there's no GC.
19. The unused `AeroGlassShader.metal` adds 690 MB of toolchain dependency for a shader the app doesn't render. Either wire it (preferred) or delete it.
20. iOS has no app icon, no launch screen image, no production assets.

---

## 8. The OpenRouter rule (verbatim, do not soften)

> The user must never see a model picker, an API-key field, the word "OpenRouter", or any provider name inside the app.

In code this means:
- No view ever renders `process.env.*` values or model slugs.
- `Bundle.main.object(forInfoDictionaryKey:)` lookups must not surface model names.
- "Sign in to" prompts that reference a third-party AI provider are forbidden.
- If the LLM call fails, the app must continue without telling the user "the AI is down" — fall back, display the same chirp/gesture animation it would have shown, log the error to `lastBackendError` (server-only diagnostic).

The "OpenRouter is invisible infrastructure" framing is in the GDD (`docs/GDD.md` §North Star). Treat it as mission-critical.

---

## 9. Recommended next moves (in priority order, ~1 day of work each)

### M1. Make the egg feel alive (S0-3)
**File:** `ios/OpenClawApp/Game/ClawRoomView.swift` → `PetAvatarView`.
- Replace the two black `Circle()` "eyes" with a single egg shape: a vertical capsule, 110×140, filled with `LinearGradient` from `#E8FBFF` to `#9DD9FF` to `#6EB7FF`, stroked with a 2px white→cyan gradient.
- Add an inner radial highlight at top-left (offset -22, -28, blur 18, white 0.55).
- Add `.scaleEffect` driven by `phase`-based `TimelineView` so the egg breathes 0.98↔1.02 over 2.4s.
- Add a subtle outer glow that pulses with `state.mood` (more glow = better mood).
- When `state.stage == .hatchling`, swap the egg silhouette for a translucent blob with two tiny bright "eyes" (still abstract, never anthropomorphic — the GDD calls for a "translucent cyber-Y2K creature").

**Acceptance:** A user opening the app sees the egg breathe before they touch it.

### M2. Wire the first-minute ritual (S0-1, S0-2, S0-4)
**Files:** `RootView.swift`, `ClawRoomView.swift`, new `App/FirstMinuteOrchestrator.swift`.
- On first launch (no `petState` in UserDefaults), show only the egg on a black/aero gradient. No status bar, no claw, no capsules.
- After 1.2s, fade in a single line: "tap to wake it" — typewriter style, white, 14pt rounded.
- On first tap: haptic medium, egg flashes white, transitions to hatchling state, line replaces with "teach it your first sound."
- Mic permission prompt fires here, with the copy from `Privacy/ConsentCopy.swift` ("Teach it your first sound. Your pet starts with no mapped human language; let it hear the sounds you want to teach.").
- After permission resolved, `runtime.isTeaching = true` directly — bypass the claw "word" capsule path.
- After first teaching event succeeds, the claw room reveals itself with a gentle bottom-up slide.

**Acceptance:** A user who has never seen this app reaches "I taught the egg a sound" in under 60 seconds without touching settings.

### M3. Make capsules look like capsules (S1-8)
**File:** `ios/OpenClawApp/Game/ClawMachineScene.swift` → `makeCapsule(type:)`.
- Replace `SKShapeNode(ellipseOf:)` with `SKSpriteNode(texture:)` where the texture is generated once at scene init via a small `SKView.texture(from: SKShapeNode)` recipe combining: bottom hemisphere in saturated colour, top hemisphere in `colour.lighten(0.4)`, white highlight ellipse offset to top-left, etched glyph in the centre.
- Pre-bake one texture per capsule type in a `static` cache so spawn doesn't pay cost-per-instance.

**Acceptance:** Capsules read as 3D candy / Gachapon shells, not flat dots.

### M4. Apply the Aero glass shader (S1-11, S3-19)
**Files:** `ios/OpenClawApp/Rendering/AeroBackdrop.swift`, possibly a new `AeroGlassEffect.swift`.
- Use `Shader(function: ShaderFunction(library: .default, name: "aeroGlass"), arguments: [...])` on a `.layerEffect` modifier wrapping `AeroBackdrop`.
- Drive `time` from a `TimelineView(.animation)`.
- Pass `size` from a `GeometryReader`.

**Acceptance:** Background has a slow shimmering wave + subtle scanline. Same shader file, no toolchain change required (Metal Toolchain is already installed).

### M5. Sound + haptics (S0-5, S0-6)
- Add a `PetAudio` actor: load a short "wake chirp" + "capsule click" + "miss whoosh" from bundle. Use `AVAudioPlayerNode` over a single `AVAudioEngine`.
- Wire `UIImpactFeedbackGenerator(style: .medium)` to: tap pet, drop claw start, capsule grab, miss.

**Acceptance:** App is no longer mute.

### M6. Stage transition VFX
When `stage` changes, run a 600ms transition animation: white flash, scale 1→1.2→1, particle burst (`SKEmitterNode`). Hatching is a moment, not a state assignment.

### M7. Real LLM key
Once M1–M6 land, the app is finally interesting enough to be worth a real OpenRouter key. Replace `OPENROUTER_FREE_MODEL` with a real free-tier slug (consult OpenRouter catalog) and restart server. iOS shouldn't change.

### M8. Polish: app icon, launch screen, accent assets
Defer until M1–M6 land. The icon should be the egg-on-aero composition.

---

## 10. Acceptance test for "this works"

Before reporting the next session as done, the agent must:

- [ ] Launch the app on iPhone 17 / iOS 26.5 simulator with no prior `UserDefaults` state (`xcrun simctl uninstall booted com.openclaw.app` first).
- [ ] Record a 60-second video (`xcrun simctl io booted recordVideo /tmp/openclaw-first-minute.mov`) showing: cold launch → egg breathing visible → "tap to wake" prompt → tap → hatch flash → "teach it your first sound" → mic permission accepted in fiction → user types a sound → pet echoes fragment → capsule reveal.
- [ ] Run the same flow with `npm run dev` not running. Pet must still hatch and echo. The simulator must show no error UI.
- [ ] Verify with `grep -ri "openrouter" ios/OpenClawApp/` returns zero matches in user-visible strings (matches in code comments are fine).
- [ ] Confirm the Metal shader is actually applied (capture a frame and verify the wave warp on the backdrop).
- [ ] Save the recording path in the next-session handoff.

---

## 11. Glossary of decisions already made

| Decision | Why |
|---|---|
| Backend on `:8989` | `:8787`/`:8788` are bound on this Mac by other services. Don't change without reading `NEXT_SESSION.md`. |
| `xcodegen` over hand-rolled `.xcodeproj` | Project survives multi-agent edits; plists regenerate idempotently. |
| `ProcessInfo.processInfo.environment` not used to override base URL | iOS apps don't read shell env. `OPENCLAW_API_BASE_URL` flows via Info.plist (set from `project.yml`). |
| `UserDefaults` for pet state on iOS | Prototype. Will swap for App Group + Codable file when PiP/widget need to read it cross-process. |
| In-memory store on server | Prototype. Schema sketched in `inMemoryStore.ts` will move to SQLite. |
| `installToken` instead of accounts | Anonymous-first. No login screen ever — that violates §8. |
| Zod schemas on every endpoint | Cheap, catches the kinds of errors LLM-generated client code makes. |

---

## 12. Hard rules (carry from `~/.claude/CLAUDE.md`)

- Never work on `main` / `master`. Cut new branches from `feat/local-dev-bringup`.
- Never `rm -rf` anything; copy to `.backup/<timestamp>/` first.
- Never push to remote without Alex's explicit instruction.
- Never amend commits — always create new ones.
- Never edit `.env` / credentials / generated `.plist` / generated `.entitlements`.
- Never run `sudo` without explicit approval.
- Edit `project.yml`, then `xcodegen generate`. Don't hand-edit the `.xcodeproj`.

---

## 13. Status snapshot at handoff time

```
2026-05-03 19:08 MDT
Branch       : feat/local-dev-bringup (4 commits, NOT pushed)
HEAD         : ceaae8d
Backend      : RUNNING on :8989 (local fallback path; no real OpenRouter key)
iOS          : BUILDS for iPhone 17/iOS 26.5 simulator
iOS launch   : SUCCEEDS; UI renders
Acceptance   : FAILS — see §0, §7
Recording    : /tmp/openclaw-content.png (still frame only)
Disk free    : ~13 GB
```

**Single next command for the receiving agent:**
```bash
cd /Users/alexl/Projects/OpenClawStarter && cat HANDOFF_TO_CODEX.md
```
Then start at §9 M1.
