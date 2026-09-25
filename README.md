# Boustrophedon

Face each backward word on a saved National Gallery caption. People who already keep paintings on this device turn a maker name or a title into an ox-plough line, then tap every retrograde stichos until the work shelves as faced.

## Architecture

The product is a closed fold `Idle | Turned | Faced` over works. `FurrowStore` is the only place that pattern-matches that fold. Turn writes a furrow that is artist XOR title with every other token letter-reversed. Face rights a retrograde stichos. A miss writes a yaw and keeps the same line. A fourth case would be a defect.

That fold fits the job because the home verb is sequential and local: one open furrow at a time, no parallel grade or shop state, and retract is the inverse of the newest mark.

## Turn-then-face

Home never leaves the furrow. Turn samples a saved work that is not faced and whose chosen field still has two tokens. Face files when the tap hits a still-backward word. The last true face folds the work to Saved. Empty crate writes Level. That is the reason to open this app instead of a gallery browser.

## Art

Style: 3D glass render, glassmorphism, studio-lit ox-plough furrow, a caption line of stichoi with every other word turned retrograde, refraction and soft bloom, isolated subjects, quiet uncluttered ground, hospitable daylight, no text.

Prompts used:

- `bph_AppIcon` — A single 3D glass ox-plough furrow loaded with reversed caption tablets, glassmorphism, subject centred filling the canvas edge to edge, no text, no letters, no words, no alpha, no transparency, no rounded corners, no drop shadow outside the canvas
- `bph_Splash` — A tall vertical 3D glass ox-plough furrow, a line of stichoi receding, quiet uncluttered centre band for a wordmark, glassmorphism, no readable text
- `bph_Onboarding1` — Solid wooden plough furrow with a line of caption tablets, isolated cutout, opaque wood and clay, no text
- `bph_Onboarding2` — A hand tapping one solid retrograde caption tablet on a furrow, isolated cutout, no text
- `bph_Onboarding3` — A faced furrow with caption tablets seated forward, isolated cutout, no text
- `bph_EmptyHome` — A solid closed wooden plough waiting to cut a furrow, isolated cutout, no text
- `bph_EmptyList` — A solid empty wooden crate, isolated cutout, no text
- `bph_CardBackdrop` — An abstract soft daylight field behind an ox-plough furrow, low contrast, fill the canvas, no readable text
- `bph_ControlFace` — The face of a single solid caption tablet, isolated cutout, no text
- `bph_TwistHero` — A plough furrow beside caption tablets with every other tablet turned, isolated cutout, no text
- `bph_SuccessMark` — A solid brass ox-plough share, isolated cutout, no text
- `bph_HeaderDecor` — A wide solid wooden furrow rail, isolated cutout, no text
- `bph_OxFurrow` — Isolated solid wooden ox-plough furrow, cutout, no text
- `bph_RetrogradeStichos` — Isolated solid caption tablet turned backward, cutout, no readable letter
- `bph_FacedCaption` — Isolated solid line of faced caption tablets on a furrow, cutout, no text

## Difference

This batch neighbour quizzes hang, rank, or seat. Boustrophedon rights letter-reversed words in place on one locked furrow. Explore, Saved, and Settings are sheets. The collection voice is The National Gallery, London.

## Build

```bash
cd apps/Boustrophedon
xcodegen generate
xcodebuild -scheme Boustrophedon -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build
```
