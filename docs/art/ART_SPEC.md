# ART SPEC - pixel art direction (2.5D top-down)

Supersedes the earlier polygon-placeholder specs. Everything renders as
**16 px-native pixel art scaled x3** in-engine (see IMPLEMENTATION_PLAN
3.1). Design view: straight top-down for flat things, 3/4 tilt for actors
and structures - classic indie "2.5D board-game" look.

## 1. Resolution and scaling rules

- Native canvas: **16x16 px per tile**. Actors 10-20 px native.
- Export at native size; NEVER pre-scale. Engine scales x3 with nearest
  filtering - one source of truth, crisp at any window size.
- Frame sheets: horizontal strips, uniform frame width, no spacing padding.

## 2. Palette locks

Four ramps plus two signal accents. Use ONLY these values (minor ±2 value
steps allowed for dithering):

| Ramp | Shades (dark -> light) |
| ---- | ---------------------- |
| Steel (AC tech) | #1A2028 #2C3A47 #4A6076 #7A93AB #B8C9DB |
| Rust (UMR/scrap) | #2E1A12 #59291A #8F4520 #C46A2E #E89A55 |
| Ash (environment) | #14181A #232B24 #37452F #55603C #7C8853 |
| Bone (UI/highlights) | #17151C #26222E #4A4358 #8B8098 #D9D2E0 |
| Signal red | #D94F3D |
| Signal cyan | #58C7D4 |

Rules:
- Outline color: #101014, selective only (outer silhouette + underside).
- Light source: top-left. Two-tone shading minimum per surface (base +
  shadow), rim highlight on bottom-right edges.
- No anti-aliasing, no gradients - use dithering sparingly (16% max density
  areas) for transitions.
- Enemies read warm/red-accented, player reads cool - keep this split.

## 3. Folder layout to fill

```
assets/art/terrain/    tilesets x5 themes, borders, rocks, decals
assets/art/player/
assets/art/enemies/
assets/art/combat/     projectiles, muzzle flashes, impacts
assets/art/buildings/
assets/art/pickups/
assets/art/fx/
assets/art/ui/
assets/art/menu/
```

## 4. Asset list and specs

### P0 - gameplay critical

| Asset | Native spec | Notes |
| ----- | ----------- | ----- |
| ground_tileset (x5 sector themes) | 16x16 tiles, 6-10 tiles each + edge/corner | Glassfields rust lot, Meridian factory, Kill Line battlefield, Overlook mountain, Lighthouse complex |
| border_wall | 16x16 + corner tiles | concrete slab, 8 px drawn top face |
| rock | 16x16 / 24x24 / 32x32 (multi-tile) | collision stays circle in code |
| player | 14x18 native; idle 2f, walk 6f side view (flip for left), hurt 1f | cool steel suit, orange visor strip = facing cue; up/down dirs optional P2 |
| enemy_chaser | 12x12; walk 4f, death 4f ending in wreck pose | AC drone, faded blue + one red eye |
| enemy_brute | 20x22; walk 6f, attack lunge 2f | UMR frame, rust plates, slow gait |
| projectile | 6x3 core (+8x8 glow) | yellow-white tracer |
| pickup_scrap / cell | 6x6 (+12x12 halo) | gear chunk orange / battery cyan, 2f pulse |
| wall | 16x16 + damaged overlay | sandbag-rebar barricade |
| turret_base + barrel | base 16x16 static; barrel 14x5 rotates, pivot 4 px from rear | muzzle flash anchors to barrel tip |
| hp_bar kit | UI-space: frame 74x6 9-slice, fill 70x4 | rendered x3 by Control scale |
| blob_shadow | 8x3 ellipse, black 40% | under every actor |

### P1 - feel and feedback

muzzle_flash 8x8x3f; impact_spark 8x8x3f; explosion_small 24x24x5f;
dust_puff 8x8x3f; build_ghost neutral-white 16x16 versions of wall/turret;
wave_banner 96x24; HUD icons scrap/cell 12x12 matching pickups exactly;
vignette overlay (UI space).

### P2 - menu, story, bosses

menu_background 320x180 scene (scaled full-screen); title_logo 160x48;
button styles 64x20 9-slice normal/hover/pressed; panel 9-slice; slider
rail 64x6 + knob 8x8; checkbox 10x10 off/on; radio_interlude_bg 320x180;
boss sprites: Crawler-Titan 48x28 (walk 8f on rails, salvo telegraph 2f),
Archivist core 32x32 (idle rotate 6f, purge charge 4f); ending slides
320x180 x2.

## 5. Sector tileset art direction (ties to STORYBOARD)

| Sector | Ground story | Tile mood |
| ------ | ------------ | --------- |
| Glassfields | rust-belt lots, ash grass creeping back | ash greens + rust decals, tram rails |
| Meridian Yards | factory floor | concrete grays-green, conveyor stripes, hazard chevrons |
| Kill Line | old front line | scorched earth, craters, shell casings decals |
| Concord Overlook | mountain early-warning post | cold gray-blue rock, snow patches, radar dishes |
| Lighthouse Array | broadcast complex | bone-white tiles, cable runs, beacon light pools |

Each theme reuses the same ramps - variation via decal density and hue
bias, never new colors.

## 6. Fonts (free, OFL)

UI/body: Oxanium or Share Tech Mono. Pixel-perfect alternative if wanted:
monogram (CC0). Title logo hand-drawn from stencil letterforms.

## 7. Technical checklist per asset

1. Exact native canvas sizes above; uniform frame width on strips.
2. Centered pivot except turret barrel (documented offset) and actors
   (origin = feet, so sprite drawn with feet at bottom-center).
3. PNG-24 alpha, no color profile, no AA.
4. Name `snake_case`, prefix by owner (`player_`, `enemy_chaser_`).
5. Silhouette test: readable at 50% zoom AND converted to pure black -
   if it fails, redesign shape not details.
