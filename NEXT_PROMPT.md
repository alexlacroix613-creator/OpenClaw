# Prompt for next OpenClaw session

> Paste this into Claude Code after macOS + Xcode have updated.

---

You are the lead engineer continuing the **OpenClaw** prototype — a magic-first iOS virtual pet (SwiftUI app + SpriteKit claw machine + TypeScript Express backend + OpenRouter behind a model router with local fallback).

## User context
- User is Alex (CEO/Founder, Siempre Spirits — non-technical for iOS work).
- Do not ask Alex to run terminal commands unless one is genuinely required.
- Be the lead engineer. Inspect the machine, fix issues, report cleanly.

## Project state (carried forward)
- Repo: `/Users/alexl/Projects/OpenClawStarter`
- Branch: `feat/local-dev-bringup` (3 commits, NOT pushed)
- Backend: Express on **`:8989`** (8787/8788 collide with existing Python services; do NOT change the port without reading why in `NEXT_SESSION.md`).
- iOS scaffold: complete and internally consistent. Info.plist + entitlements regenerate idempotently from `project.yml` — do not edit the generated `.plist`/`.entitlements` files directly; edit `project.yml`.
- Combobulator todo `#5` ("OpenClaw — finish Xcode install + simulator smoke test") is the live task tracking this work at https://app.siempretequila.com/tasks.

## Read first (do not skip)
1. `/Users/alexl/Projects/OpenClawStarter/NEXT_SESSION.md` — full carry-forward
2. `/Users/alexl/Projects/OpenClawStarter/README.md` — build order
3. `/Users/alexl/Projects/OpenClawStarter/docs/GDD.md` — design pillars + zero-setup first minute
4. `/Users/alexl/Projects/OpenClawStarter/docs/APP_REVIEW_RISKS.md` — copy rules + permission framing

## Your job (in order)

### 1. Verify Xcode is now installed and switch the active toolchain
```
ls -d /Applications/Xcode.app
xcode-select -p
xcodebuild -version
```
If Xcode.app exists but `xcode-select -p` still points at CommandLineTools, run:
```
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -license accept
```
(`sudo` is the one exception — Alex must approve in the prompt.)

### 2. Regenerate the Xcode project + start the backend
```
cd /Users/alexl/Projects/OpenClawStarter
xcodegen generate
cd server && npm run dev    # leaves :8989 listening; keep running in background
```

### 3. Build the iOS app for an iPhone 15 simulator (iOS 17+)
```
cd /Users/alexl/Projects/OpenClawStarter
xcodebuild -project OpenClawStarter.xcodeproj \
  -scheme OpenClawApp \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -configuration Debug build | tail -40
```
Fix any compile errors. Most likely surfaces:
- `AVAudioSession` setup missing in `SpeechRecognizer.swift` — add `.record` category before `audioEngine.start()` if mic input is silent.
- Code-signing for extensions in personal-team mode — set `CODE_SIGN_STYLE=Automatic` (already in `project.yml`) and pick the team in Xcode if needed.

### 4. Run the zero-setup first minute (the GDD Section "Zero-Setup First Minute")
Boot the simulator with `xcrun simctl boot 'iPhone 15'`, install the built `.app`, launch, and verify:
- Glass egg appears immediately (local pet runtime)
- Tapping the egg triggers a local reaction
- Backend bootstrap fires async (`tail /tmp/openclaw-server.log` shows the POST)
- Mic permission prompt copy reads "Teach it your first sound"
- Teaching a text fragment echoes back as `xxx...` (fallback path proves OpenRouter is optional)

Take a screenshot with `xcrun simctl io 'iPhone 15' screenshot /tmp/openclaw-first-minute.png`.

### 5. Close the loop on the Combobulator todo
The live task tracking this work is `user_tasks.id=5` for `alex@siempretequila.com` on `tenant-001`, in the SQLite DB at `~/.combobulator/db.sqlite` on Optimus. When the simulator smoke test passes, mark it done:
```
ssh optimus "sqlite3 ~/.combobulator/db.sqlite \"UPDATE user_tasks SET status='done', completed_at=$(date +%s)000, updated_at=$(date +%s)000 WHERE id=5;\""
```

## Constraints (carry from CLAUDE.md)
- Never work on `main`. New work cuts from `feat/local-dev-bringup`.
- Never `rm -rf`; back up to `.backup/` first.
- Never push to remote without Alex's explicit word.
- Never expose OpenRouter to the user inside the app — keys stay server-side only, app must work in degraded local mode.
- Permission strings are story moments, not setup screens — match the copy already in `Privacy/ConsentCopy.swift`.

## Known soft gaps (address opportunistically, not blocking)
- `inMemoryStore.ts` wipes on server restart — defer SQLite until persistence is needed.
- `PetPiPHost.swift` exists but isn't wired into `RootView`.
- No app icon, launch screen image, or production assets.
- No SnapKit code yet (only documented in GDD).

## Deliverable
A status report in the same shape as last session:
- What runs / what builds / what's blocked
- Files changed (one line each)
- Single next command if Alex truly needs to run one
- Screenshot path if simulator session worked
