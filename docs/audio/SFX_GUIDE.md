# SFX Sourcing Guide (free & license-safe)

Background music is composed in-house (see `OST_PLAN.md`). Generic sound
effects can be pulled from free libraries. This guide lists **verified**
sources, what to grab from each, and the exact filenames the engine expects.

---

## Verified sources (license-checked Aug 2026)

### 1. Kenney.nl — RECOMMENDED, use first

- **License:** Creative Commons Zero (CC0 / public domain) — confirmed on
  kenney.nl/support: *"all game assets are public domain licensed (CC0).
  You're free to use them, even in commercial projects."*
- **Attribution:** not required.
- **Risk:** effectively zero. No account, no strings.
- **Relevant packs:** "Interface Sounds" (UI clicks), "Sci-Fi Sounds"
  (lasers, impacts), "Digital Audio" (retro blips), "Impact Sounds".
- URL: https://kenney.nl/assets?q=audio

### 2. OpenGameArt.org

- **License:** per-asset. The site does not accept NC/ND content at all, so
  everything is commercially usable, BUT licenses vary between CC0,
  CC-BY, CC-BY-SA and OGA-BY.
- **Rule of thumb:** filter/browse for CC0 → zero obligations. CC-BY is fine
  if you add the author + license to a CREDITS file. Avoid CC-BY-SA unless
  you accept share-alike on that asset file.
- **Verification note (from OGA founder):** "If something is licensed CC-BY,
  CC0, BSD, or MIT, it's safe to use in commercial software."
- URL: https://opengameart.org/art-search?keys=sound+effects (check the
  license badge on each asset page)

### 3. Freesound.org

- **License:** PER-FILE mix of CC0 / CC-BY / CC-BY-NC.
- **Rule:** search with the license filter set to **"Creative Commons 0"**:
  https://freesound.org/search/?q=&f=license:%22Creative+Commons+0%22
- **Never ship CC-BY-NC files** in any monetized or ad-supported build.
- Filtered link above guarantees safety; double-check the badge on the file
  page anyway.

### 4. Pixabay (sound effects section)

- **License:** Pixabay Content License (April 2023): free for commercial
  use, no attribution required. Pre-Jan-2019 uploads are CC0.
- **Caveat:** zero legal indemnification, and AI-generated content is mixed
  into the library. Fine for an indie project; if you ever need bulletproof
  provenance, prefer Kenney/OGA-CC0.
- URL: https://pixabay.com/sound-effects/

### Sources to AVOID despite appearing in searches

| Source                          | Why avoid                                  |
| ------------------------------- | ------------------------------------------ |
| BBC Sound Effects (RemArc)      | Personal/non-commercial use only           |
| Zapsplat free tier              | Requires attribution + account; terms change |
| Any "no copyright sound" YouTube rip | Provenance unverifiable               |
| Sounds ripped from other games  | Copyright infringement                     |

**House rule: keep a `docs/CREDITS.md`** listing every borrowed file with
source URL + license, even when attribution isn't required. It costs one
minute per file and makes future publishing painless.

---

## Required SFX manifest

Export each as OGG Vorbis (or WAV; mono preferred, 44.1 kHz, peak ≈ -3 dB)
to `assets/audio/sfx/<name>.ogg`. Missing files are silently skipped by the
engine, so build this list incrementally.

Priority order (P0 = game feels broken without it):

| Priority | File name          | Trigger                              | Sound direction                                   |
| -------- | ------------------ | ------------------------------------ | ------------------------------------------------- |
| P0       | `shoot.ogg`        | player fires                         | short energy weapon zap, 80–150 ms                |
| P0       | `impact.ogg`       | projectile hits anything             | soft thud/spark, shorter than shoot               |
| P0       | `pickup.ogg`       | resource collected                   | pleasant two-note blip up                         |
| P0       | `place.ogg`        | wall/turret built                    | heavy mechanical clunk + servo                    |
| P0       | `hurt.ogg`         | player takes damage                  | low grunt/radio static burst                      |
| P0       | `enemy_die.ogg`    | enemy dies                           | crunch + descending pitch                         |
| P1       | `turret_shot.ogg`  | turret fires                         | variant of shoot, lower pitch (reuse OK at start) |
| P1       | `build_deny.ogg`   | placement failed / unaffordable      | dull buzz, non-punishing                          |
| P1       | `structure_down.ogg` | wall/turret destroyed              | collapse rumble + debris                          |
| P1       | `wave_horn.ogg`    | wave starts (also heavy waves)       | distant alarm horn, 2–4 s, quiet                  |
| P1       | `ui_click.ogg`     | menu button press                    | clean tick                                        |
| P2       | `ui_back.ogg`      | settings back / cancel               | softer reverse tick                               |
| P2       | `player_die.ogg`   | death moment                         | power-down whine into static                      |
| P2       | `brute_step.ogg`   | brute footfalls (future)             | sub-heavy stomp                                   |
| P2       | `magnet.ogg`       | pickup enters magnet radius          | very subtle rising shimmer                        |

**Mixing targets:** music bus -6 dB relative to Master; SFX around -3 dB
peak each; never clip. The in-game Settings screen controls Master/Music/SFX
bus volumes live.

---

## Quick start recipe

1. Download Kenney "Interface Sounds" + "Sci-Fi Sounds" (CC0).
2. Map: ui_click/ui_back ← Interface pack; shoot/turret_shot/impact ← Sci-Fi
   pack lasers & phasers; place/structure_down ← Impact pack.
3. Rename to the manifest names above, drop into `assets/audio/sfx/`.
4. Run the game — done. Replace with custom recordings later where you want
   more character (especially `hurt`, `wave_horn`, `enemy_die`).
