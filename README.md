# OpenClaw Starter Kit

Magic-first iOS virtual pet scaffold: no user-facing AI setup, no model picker, no API-key screens.

The app creates a local pet instantly, silently bootstraps a backend pet identity, and hides OpenRouter behind the server-side model router.

## Included

```text
OpenClawStarter/
  project.yml                         # XcodeGen project spec
  ios/OpenClawApp/                    # SwiftUI app scaffold
  ios/OpenClawBroadcastExtension/     # ReplayKit watch-mode skeleton
  ios/OpenClawWidgetExtension/        # Live Activity / Dynamic Island widget
  ios/Shared/                         # ActivityKit shared attributes
  server/src/                         # TypeScript backend + OpenRouter router
  docs/                               # GDD and review notes
```

## Product rule

The user must never configure AI.

```text
A glass egg appears.
It wakes up.
It reacts locally.
It learns through speech.
It remembers.
Later, it floats, knocks, dreams, and shares.
```

Infrastructure:

```text
iOS App -> OpenClaw Backend -> Model Router -> OpenRouter / fallback rules
```

## Backend quick start

```bash
cd server
cp .env.example .env
npm install
npm run dev
```

The server runs at:

```text
http://localhost:8787
```

Put `OPENROUTER_API_KEY` only on the server. Never ship it inside the iOS app.

## iOS quick start

This uses `XcodeGen` instead of a hand-authored `.xcodeproj`.

```bash
brew install xcodegen
cd OpenClawStarter
xcodegen generate
open OpenClawStarter.xcodeproj
```

Set the backend URL in:

```text
ios/OpenClawApp/API/PetAPI.swift
```

Simulator default:

```text
http://127.0.0.1:8787
```

## Build order

1. Local pet runtime + claw room
2. Backend bootstrap + OpenRouter model router
3. Tabula-rasa teaching loop
4. Memory bubbles
5. PiP companion window
6. Live Activity / Dynamic Island
7. Snapchat handoff
8. ReplayKit watch mode

## Constraints

- PiP is not a true global overlay; this scaffold uses a sample-buffer PiP companion stream.
- Dynamic Island is a Live Activity, not a permanent pet HUD.
- ReplayKit watch mode must be explicitly started by the user.
- Snapchat Creative Kit should be a user-approved handoff, not silent autonomous sending.
- OpenRouter Free Tier is useful for dev/alpha, not as the only production brain.

## Magic-first permission pattern

| Capability | User-facing ritual |
|---|---|
| Microphone | “Teach it your first sound.” |
| Speech recognition | “Help it understand the sound.” |
| Notifications | “Let it tap the glass.” |
| PiP | “Let it float beside you.” |
| Screen broadcast | “Open its eyes for this session.” |
| Snapchat | “It made something for your camera.” |

## Status

Foundation only. App source, extensions, backend route, model router, tabula-rasa prompt, and fallback logic are included. You still need production assets, persistence, auth, deployment, Snap credentials, and App Store privacy review materials.
