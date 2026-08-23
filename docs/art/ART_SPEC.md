# Art Spec - visual asset list

Everything below replaces the current placeholder polygons. Sizes are in
pixels at the game's baseline camera zoom of 1.0 (the grid tile is 48 px,
see BuildSystem.GRID). Design top-down / three-quarter "board game" view.

## Global style rules

- **Palette:** muted post-nuclear rust. Core ramps: ash greens (#3A4636
  family), oxidized orange/rust (#B4552D), faded AC-blue steel (#5C718A),
  UMR red-brown (#8A4A3B), bone/off-white for highlights. Keep 12-16 swatch
  values per ramp; no saturated primaries except pickups/UI accents.
- **Perspective:** straight top-down for flat things (ground, walls),
  slight 3/4 tilt acceptable for actors and structures.
- **Readability first:** player + enemies must be identifiable by silhouette
  alone at 50% zoom; enemies get warm/red rim accents, player gets cool.
- **Lighting:** renderer is gl_compatibility, no dynamic shadows. Bake light
  and contrast into textures; add a global vignette overlay instead.
- **File format:** PNG-24 with alpha. Sheets are horizontal strips, fixed
  frame width. Naming: `snake_case`, prefix by owner (`player_`,
  `enemy_chaser_`, ...).

## Folder layout to fill

```
assets/art/terrain/    ground tiles, borders, rocks, decals
assets/art/player/
assets/art/enemies/
assets/art/combat/     projectiles, muzzle flashes, impacts
assets/art/buildings/  wall, turret
assets/art/pickups/
assets/art/fx/
assets/art/ui/
assets/art/menu/
```

---

## P0 - gameplay-critical (do these first)

| Asset                    | Spec                                                        | Notes |
| ------------------------ | ----------------------------------------------------------- | ----- |
| ground_tile              | 48x48, 4 variants + edge variant                            | subtle ash-dirt noise, cracks; must tile seamlessly |
| border_wall              | 64x64, 1 tile + corner                                      | concrete slabs w/ rebar, reads as impassable |
| rock                     | 3 sizes: 96x96 / 72x72 / 48x48                              | collision is circle r=24-46 px, art centered |
| player_body              | 32x32, walk sheet 6 frames                                  | cool blue-gray suit, orange visor strip faces move-dir |
| enemy_chaser             | 28x28, walk 4 frames, death 4 frames                        | AC scout drone: faded blue, single red sensor eye |
| enemy_brute              | 44x44, walk 6 frames, attack lunge 2 frames                 | UMR siege frame: red-brown armor plates, slow gait |
| projectile               | 12x4 core + optional 16x16 glow halo                        | bright yellow-white tracer |
| pickup_scrap             | 10x10 (+20x20 glow halo)                                    | gear/plate chunk, rust-orange, gentle pulse anim |
| pickup_cell              | 10x10 (+20x20 glow halo)                                    | cyan battery cell |
| wall                     | 48x48 footprint, damaged state at <50% HP                   | sandbag/rebar barricade, cracks appear when damaged |
| turret_base + barrel     | base 36x36 static; barrel 30x10 rotates independently       | barrel pivot at 8 px from rear edge |
| hp_bar                   | frame 220x18 9-slice (8 px margins), fill 216x14            | green-to-red handled in code via tint |

## P1 - feel and feedback

| Asset                | Spec                                   | Notes |
| -------------------- | -------------------------------------- | ----- |
| muzzle_flash         | 24x24, 3 frames (~60 ms total)         | player + turret share |
| impact_spark         | 16x16, 3 frames                        | on projectile hit |
| explosion_small      | 48x48, 5 frames                        | enemy/wall death |
| dust_puff            | 24x24, 3 frames                        | footsteps, placements |
| build_ghost          | 48x48 outline versions of wall/turret  | code tints green/red; provide neutral white version |
| wave_banner          | 256x64                                 | "WAVE N" plaque behind HUD text |
| scrap/cell HUD icons | 18x18 each                             | match pickup silhouettes exactly |

## P2 - menu, story and polish

| Asset               | Spec                                        | Notes |
| ------------------- | ------------------------------------------- | ----- |
| menu_background     | 1920x1080 (safe-area crop ok)               | Glassfields skyline, dead superhighway, distant tower w/ blinking beacon |
| title_logo          | 512x128                                     | stencil military type, rust texture fill |
| button styles       | 220x48 9-slice: normal/hover/pressed        | 8 px margins |
| panel_background    | 9-slice any-size                            | settings panel |
| slider_knob + rail  | knob 24x24, rail 200x12                     | volume sliders |
| checkbox            | 24x24 off/on                                | fullscreen toggle |
| vignette            | 1920x1080 radial dark overlay               | multiply blend |
| radio_interlude_bg  | 1280x720                                    | story interludes: map + radio close-up |
| boss_portraits      | 512x512 x2 (Crawler-Titan, Archivist)       | finale set-pieces |
| ending_slides       | 1920x1080 x2                                | broadcast / quiet endings |

## Animation budgets

- Walk cycles 8-12 fps in-engine; draw at final size, no downscaling needed.
- Hit flash = code tint (no extra frame required).
- Death animations should end on a "wreck" pose usable as a temporary decal.

## Fonts (free/OFL, safe)

- UI/body: **Oxanium** or **Share Tech Mono** (both SIL OFL).
- Title/logo source lettering may be hand-drawn; do not trace commercial
  fonts.

## Technical checklist per asset

1. Exact canvas size listed above (frame width uniform across sheets).
2. Centered pivot unless noted (turret barrel exception documented).
3. Export PNG-24, no embedded color profile.
4. Drop into the matching `assets/art/...` folder; scene wiring swaps
   Polygon2D placeholders for Sprite2D nodes - keep names stable.
