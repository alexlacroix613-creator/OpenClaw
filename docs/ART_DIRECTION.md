# OpenClaw — Art Direction (v1)

> Authoritative visual brief. This document supersedes any earlier "cyber-Y2K", "Frutiger Aero", "glass terrarium", or "translucent" direction in the GDD or scaffold. Where prior copy contradicts this brief, this brief wins.

---

## 1. The world in one sentence

OpenClaw is a **pastel pixel toy-world** where you adopt and raise chibi creatures on cozy floating platforms. It feels like a hand-built diorama you carry in your pocket.

## 2. Visual reference direction

- Cute pixel chibi creatures
- Big heads, tiny bodies, short limbs
- Dark purple/navy pixel outlines
- Large square / glossy eyes
- Simple tiny mouths
- Pastel sky / platform world
- Floating snacks and items
- Chunky pixel UI panels
- Soft clouds, simple geometric trees and platforms
- Cozy, collectible game feel

## 3. Anti-list — what OpenClaw is NOT

- **Not realistic 3D.** No PBR, no normal maps, no soft shadows.
- **Not dark / cyberpunk.** No neon-on-black, no scanlines, no glitch.
- **Not a generic AI chatbot.** No chat trunk, no model picker, no message bubbles dominating the screen.
- **Not a finance / crypto app.** No tickers, no charts, no "value", no "floor price".
- **Not a sterile iOS utility.** No flat translucent system materials as the dominant aesthetic. No SF Symbols as primary illustration.

## 4. Color palette

All values are sRGB hex. The dark outline is a single token used everywhere.

| Token | Value | Use |
|---|---|---|
| `outline` | `#2A1B4D` | Every silhouette outline. 1 pixel at native scale. Never anti-aliased. |
| `sky.top` | `#FFD9E8` | Top of sky gradient (peach pink) |
| `sky.bot` | `#C9DFFF` | Bottom of sky gradient (baby blue) |
| `cloud.fill` | `#FFFFFF` | Cloud body |
| `cloud.shade` | `#E5ECFF` | Cloud underside |
| `platform.top` | `#B5E2A8` | Grass surface |
| `platform.side` | `#7FBA70` | Earth side |
| `platform.shade` | `#5C9954` | Earth deep shade |
| `tree.leaf` | `#6CC275` | Tree canopy |
| `tree.leaf.shade` | `#4FA258` | Canopy shade |
| `tree.trunk` | `#8B5E3C` | Tree trunk |
| `pet.pink` | `#F5C4D9` | Pink pet body |
| `pet.blue` | `#C2D5F0` | Blue pet body |
| `pet.cream` | `#FFE5A8` | Cream pet body |
| `pet.mint` | `#B7EBD2` | Mint pet body |
| `pet.lilac` | `#D9C8F5` | Lilac pet body |
| `pet.coral` | `#FFB99A` | Coral pet body |
| `pet.cloud` | `#FFFFFF` | Ghost / cloud pet body |
| `pet.charcoal` | `#3F3A4F` | Shadow pet body |
| `cheek` | `#FFB3D1` | Cheek blush spot |
| `eye.white` | `#FFFFFF` | Sclera |
| `eye.dark` | `#2A1B4D` | Pupil (== outline token) |
| `snack.apple` | `#FF9999` | Apple capsule |
| `snack.leaf` | `#B5E2A8` | Leaf capsule |
| `snack.honey` | `#FFD380` | Honey capsule |
| `snack.berry` | `#C9A0FF` | Berry capsule |
| `snack.shell` | `#FFE08A` | Egg/shell capsule |
| `snack.mystery` | `#B0AAFF` | Mystery capsule (rare) |
| `panel.fill` | `#FFFFFF` | HUD panel body |
| `panel.shadow` | `#2A1B4D33` | HUD panel hard drop-shadow |
| `panel.accent` | `#FFC9DD` | Pressed/active panel pink wash |

**Rule:** outlines are always `outline`. Pet body fill comes from one `pet.*` skin token. Snacks and props pick from `snack.*` or `tree.*`. Never improvise a new color outside this table — extend the table.

## 5. Typography

- Display label (HUD numbers, button labels): system rounded black, pixel-flavored. Use `Font.system(.caption2, design: .rounded).weight(.black)` and uppercase. Letter-spacing `+0.5`.
- Body / dialogue: system rounded heavy, sentence case, slightly wider tracking.
- Never use thin or light weights.
- Never use serif.

A real pixel font (e.g. *PixelOperator*, *Press Start 2P*) is the long-term goal but is not bundled in this repo yet. The system rounded-black is the closest stock approximation; treat it as a placeholder.

## 6. Pixel discipline

- All sprite art is rendered on an **integer pixel grid**. Use a `pixelScale` (default `4` to `8`, see §11) and snap every position to `floor(x / pixelScale) * pixelScale`.
- **Anti-aliasing is off** for sprite shapes (`SKShapeNode.isAntialiased = false`). Native pixel-doubled assets with sharp edges only.
- **Hard shadows only.** Drop shadows are 2px down-right of the silhouette in `outline` at 20% alpha, no blur.
- **No motion blur, no depth of field, no glow.** A "glow" is a 1-pixel ring of brighter color, not a Gaussian blur.

## 7. Motion language

| Action | Animation |
|---|---|
| Idle | Sprite breathes: scale 1.0 → 1.04 → 1.0 over 1.6s ease-in-out, `pixelScale`-aware (snap to whole pixels). |
| Blink | Eye row flips to a 1-pixel line for 120ms every 4–7s (jittered). |
| Bounce | Two 8px hops with a small squash (1.05 wide / 0.95 tall) on landing. |
| Happy | Cheek blush opacity 0 → 1 + sprite hop, 600ms total. |
| Curious | Sprite tilts 6° left / right / left over 700ms. |
| Eat | Mouth row swaps to "open" frame for 200ms × 3 with a small shake. |
| Miss | Sprite shakes side-to-side (±2px, 4 oscillations, 240ms) and eyes turn into "T_T". |
| Stage transition | White-flash overlay 80ms → particle burst (8 small pixel squares, 600ms) → land in new pose. |

All easing is **stepped**, not continuous. Pixel art looks worse with smooth interpolation. Use `.timingFunction(.linear)` plus discrete frame swaps where possible.

## 8. The pet (creature system v1)

### 8a. Eight base species (max)
1. `orb` — round blob with a face. Default first hatchling.
2. `kit` — cat/bunny rig. Triangular ears, slim limbs.
3. `cub` — bear/koala rig. Round ears, chunky body.
4. `axo` — axolotl/dragon/charm rig. External gills or fin frills, long tail.
5. `pup` — soft-snouted canine rig.
6. `chick` — soft-bird rig with stub wings.
7. `slime` — pure-blob rig with a translucent layer.
8. `shade` — ghost/charcoal rig with a wispy tail.

### 8b. Four rig families
A "rig" is the silhouette skeleton a sprite is drawn around. Multiple species share a rig.
- **Orb / Blob** — `orb`, `slime`, `shade`
- **Cat / Bunny** — `kit`
- **Bear / Koala** — `cub`, `pup`
- **Axolotl / Dragon / Charm** — `axo`, `chick` (chick is a soft variant)

Why this matters: the renderer composes a sprite by picking a rig + body color + trait overlays. Adding a new species is a new entry in the species table, not a new sprite from scratch.

### 8c. Modular trait slots
Every pet has the following composable slots:

| Slot | Examples | Notes |
|---|---|---|
| `body` | base shape per rig | required |
| `ears/horns/fins` | round ears, long ears, single horn, double horn, finlets | optional |
| `eyes` | square, oval, sparkle, sleepy, half-closed, heart | required |
| `chest emblem` | small heart, star, leaf, none | optional, rare |
| `skin/material` | matte, glossy, sparkle-dot, pearlescent, glow-edge | required |
| `accessory` | bow, scarf, tiny hat, antenna ball, nothing | optional |
| `mutation overlay` | pixel-freckles, halo, drifting petal, third eye | optional, very rare |

### 8d. Rarity (cosmetic only)

| Tier | Visual cue | Where it appears |
|---|---|---|
| Common | clean palette, default eyes | most pets |
| Uncommon | one extra trait slot filled | 1 in 4 |
| Rare | two extra slots, one alt skin | 1 in 16 |
| Special | unique skin material (e.g. pearlescent) | curated |
| Secret form | unique silhouette only reachable via in-fiction conditions | hidden |

**Rules — non-negotiable:**
- **No crypto.** No on-chain anything, no tokens, no wallets.
- **No marketplace.** No buy/sell, no auctions, no value display.
- **No financialized collectible language.** Never use "rarity floor", "value", "investment", "drop", "mint", "chase", "grail" in user-visible copy. Internal code names are fine if they don't leak to the UI.
- **Common pets must feel lovable and fully useful.** A common pet is not a downgrade. Trait differences are flavor, not power.
- Rarity affects appearance and discovery story only — never gameplay numbers.

## 9. The world

### 9a. Habitat
A single floating **platform** sits center-frame with the pet on it. The platform is a chunky 3D-ish slab (top grass plane in `platform.top`, side `platform.side`, bottom shade `platform.shade`). It hovers in pastel sky.

Behind the platform: 1–3 soft clouds drifting slowly, 1–2 simple geometric trees on smaller platforms further back (parallax-ready).

In front of / above the platform: floating snack capsules drift with gentle bob.

### 9b. Snacks and items (capsule replacements)
Each is a chunky pixel sprite ~14×14, outlined in `outline`:
- **Apple** — round red, leaf top, single highlight pixel.
- **Honey jar** — square jar, "B" label, drip.
- **Leaf** — green leaf with stem, used for grooming/tickle.
- **Berry** — three small purple dots in a triangle.
- **Egg / shell** — pastel speckled egg, surprise contents.
- **Mystery box** — purple cube with "?" — rare.

These replace what was previously called "capsules" and the old "claw machine terrarium".

### 9c. The claw
Drops from the top of the screen on a 1-pixel cable made of repeated chain links. Three-prong silhouette, all `outline`-stroked, white-filled. Snaps closed when it lands on a snack. Returns up with a small wiggle on success or a dejected sag on miss.

## 10. UI / HUD

- Panels are **chunky pixel rectangles**: white fill, 2-pixel `outline` border, 2px down-right hard shadow in `panel.shadow`. No corner radius beyond what a 1-pixel inset gives you.
- Pet status (name, stage, mood/bond/hunger pills) lives in a top-left panel.
- Action buttons (DROP, TEACH, FEED) are square pixel tiles with an icon glyph and a one-word label below. Pressed state offsets the tile 2px down-right and removes the shadow.
- Sliders are pixel tracks with a square knob, not iOS native.
- Modals slide up from the bottom on a 200ms stepped animation, not a smooth spring.

## 11. Scale and resolution

- Native pixel grid: **1 sprite-pixel = 4 device points** (`pixelScale = 4`) on iPhone. Round up to 6 or 8 on iPad.
- The pet sprite occupies roughly 14×14 sprite-pixels (≈56×56 pt).
- The platform is roughly 80 sprite-pixels wide.
- Cloud sprites are 16×8 to 24×10.
- Trees are 14×18.

A `PixelArt` SwiftUI helper accepts a `[String]` raster and a palette dictionary and renders at any `pixelScale`. See `ios/OpenClawApp/Rendering/PixelArt.swift`.

## 12. Sound

Cozy, soft, retro. 8-bit / 16-bit chiptune palette with reverb to round it off — never harsh.
- Wake chirp (`E5` triangle, short).
- Capsule grab (`A4 + C5` square, short).
- Capsule miss (descending `B4 → A4 → G4` square, soft).
- Teaching reinforcement (rising `C5 → E5 → G5`).
- Stage transition (sparkle arpeggio on chime instrument).

No sound shipped yet — file paths reserved at `ios/OpenClawApp/Audio/` (to be created).

## 13. Acceptance for "looks right"

A reviewer looking at a single screenshot must feel:
- "Cute," "cozy," "I want to take care of it."
- Not "tech demo," "prototype," "AI app."

Concrete checks:
- Pet has dark purple/navy outlines, not black, not gray.
- Eyes are visibly square/blocky, not perfectly round.
- The platform reads as floating, with hard pixel shading.
- At least 1 cloud and 1 tree are visible behind the platform.
- HUD panels have visible 2px borders and hard shadows, no soft material blur.
- No "Aero", no glass-morphism, no neon, no scanline overlay.

## 14. Banned legacy assets / language

The following must be deleted or renamed when encountered:

| Legacy | Replacement |
|---|---|
| `AeroBackdrop.swift` | `PixelHabitat.swift` |
| `AeroGlassShader.metal` | (deleted; not needed) |
| `cyber-Y2K`, `Frutiger Aero`, `aero glass`, `aurora`, `terrarium` | `pastel pixel toy-world`, `platform habitat` |
| `glass egg` (in copy) | `pixel egg` or `chibi egg` |
| `claw-machine room` | `claw + platform habitat` |

## 15. Hard guardrails (carry from CLAUDE.md and §8)

- Never expose OpenRouter, model names, or "AI setup" UI to the user.
- Never introduce crypto, tokens, marketplace, or financialized rarity language.
- Never use realistic 3D, dark cyberpunk, generic chatbot, or sterile-utility patterns.
- Common pets are first-class. Treat rarity as flavor.
