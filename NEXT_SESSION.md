# OpenClaw — Resume Notes

**Last session:** 2026-05-03 21:05 MDT
**Branch:** `feat/local-dev-bringup` @ `3935ba4` (11 commits, NOT pushed)
**Working tree:** clean

## Read this first

Open `HANDOFF_TO_CODEX.md` § -1 for the full state. This file is a quick-resume index; the handoff has the truth.

## What ships in the build right now

Pure SwiftUI pastel pixel toy-world. Tap egg to hatch → tap snack to feed → tap TEACH to teach. Onboarding hint (egg) and feeding hint (snack) appear on first launch and dismiss on use. Pet has idle bob, blink, hatch flash, tap pulse, eating sprite swap, and a 6-pixel hex sparkle burst on feed. Stage progression hatchling → learner → toddler → buddy → bff gated on teach + bond. Claw closes with a scale-punch on grab.

## Hard rules (from CLAUDE.md and `docs/ART_DIRECTION.md`)

- Never expose OpenRouter, model names, or "AI setup" UI to the user.
- Never push to remote without Alex's explicit word.
- Never add crypto, marketplace, or financialized rarity language.
- Never edit generated `.plist` / `.entitlements` — edit `project.yml`, run `xcodegen generate`.
- KISS interaction model is locked: three taps (pet / snack / TEACH). Don't reintroduce DROP / FEED / slider.

## Backend

```bash
cd /Users/alexl/Projects/OpenClawStarter/server
npm run dev    # :8989
```

Local fallback path is the default since `OPENROUTER_FREE_MODEL` is a placeholder slug. Set a real OpenRouter free-tier slug in `server/.env` if you want LLM behavior; iOS doesn't change.

## iOS

```bash
xcrun simctl boot "iPhone 17"
cd /Users/alexl/Projects/OpenClawStarter
xcodebuild -project OpenClawStarter.xcodeproj -scheme OpenClawApp \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.5' \
  -configuration Debug build CODE_SIGNING_ALLOWED=NO
xcrun simctl install booted ~/Library/Developer/Xcode/DerivedData/OpenClawStarter-*/Build/Products/Debug-iphonesimulator/OpenClawApp.app
xcrun simctl launch booted com.openclaw.app
```

To re-test first-launch: `xcrun simctl uninstall booted com.openclaw.app` first.

## Tutorial state lives in UserDefaults

| Key                              | Meaning |
|----------------------------------|---------|
| `openclaw.petState.v1`           | Codable `PetState` (stage, mood/bond/hunger/energy, learnedTokens, etc.) |
| `openclaw.installToken`          | Anonymous identity (UUID, never shown) |
| `openclaw.hasOnboarded.v1`       | True after first egg tap. Hides the "tap the egg" hint. |
| `openclaw.firstFeedDone.v1`      | True after first `resolveCapsule`. Hides the "tap a snack to feed" hint. |

To reset onboarding flow without uninstalling, you can run on the simulator:
```bash
xcrun simctl spawn booted defaults delete com.openclaw.app
```

## Carry-forward queue (next iteration targets)

1. **Per-rig sprites** — `Species.swift` enumerates 8 species but only `orb`'s pet/blink/happy sprites are drawn. Author cat/bunny, bear/koala, axolotl/dragon variants in `Rendering/PixelArt.swift`. `Species.defaultBodyColor` already wired.
2. **Sound** — `ios/OpenClawApp/Audio/` does not exist. Bundle short chiptune WAVs for: wake chirp (E5), grab (A4+C5), miss (B4→A4→G4 descend), teach reinforcement (C5→E5→G5 ascend), stage transition (sparkle arpeggio). Wire through a `PetAudio` actor backed by `AVAudioPlayerNode`.
3. **"Looking up" pet frame** when claw is descending — `case .descending` in `ClawState` should swap to a `petCurious` sprite for anticipation.
4. **Third tutorial hint** — "tap TEACH" after first feed. Pattern: copy `firstFeedDone` → add `firstTeachDone`. Render `HintPanel` pointing at the TEACH button when `firstFeedDone && !firstTeachDone`.
5. **Mic teaching path** — `Speech/SpeechRecognizer.swift` is wired with the AVAudioSession fix from the earlier session but not invoked from `PixelTeachingPanel`. Add a 🎤 button next to the text field that toggles `recognizer.start() / stop()`, pipe `recognizer.transcript` into `teachingText`.
6. **Backend stage sync** — `PetVisibleResponse` only decodes `mode/text/animation/emotion/statePatch`. Either extend it with `stage` and apply server-side decisions, or formally embrace the iOS-side mirror in `PetViewModel.nextStage(after:)` and stop carrying server logic.
7. **Snack scarcity / variety** — `Snack.spawnReplacement` always respawns the same kind. Pick a different kind and slightly throttle so the world feels less infinite.

## Resume command for the iteration loop

```
/loop 10x review improve debug make better
```

Iter counter currently at `8` (in `/tmp/openclaw-loop-iter`). Reset with `echo 1 > /tmp/openclaw-loop-iter` if you want to start a fresh count of 10.
