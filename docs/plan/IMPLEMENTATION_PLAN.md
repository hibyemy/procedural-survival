# IMPLEMENTATION PLAN - "Procedural Survival" full game

From working demo to shippable indie title. Narrative canon lives in
`docs/story/STORYBOARD.md`; visual rules in `docs/art/ART_SPEC.md`; music in
`docs/audio/OST_PLAN.md`. This doc is the build order.

## 1. Product definition

- **Genre:** top-down 2.5D pixel-art survival base-defense, roguelite waves.
- **Fantasy:** one scavenger-engineer holding automated war leftovers at bay
  with salvaged fortifications, across the ruins of two dead superpowers.
- **Modes:** Story (3 acts, 9 chapters, 2h15m+ first run) + Endless (score attack).
- **Target:** PC (Windows first), gl_compatibility renderer, 60 fps on
  integrated graphics.
- **Quality bar:** polished itch.io indie demo - coherent palette, real
  game-feel juice, no placeholder polygons visible by v1.0.

## 2. Core pillars (every feature serves one)

1. **Fortify under pressure** - building is the fantasy; combat creates the
   pressure that makes walls meaningful.
2. **Readable chaos** - any player can parse any fight at a glance.
3. **Deterministic runs** - seed-driven arenas and waves; retryable.
4. **The machines' war** - enemies act like automation following old orders;
   flavor carries tone cheaply.

## 3. Technical foundations to add

### 3.1 Pixel-art render pipeline (Phase 6)
- Native art resolution: **16 px tiles**, actors 10-20 px native.
- World units stay as-is (48 px cells); sprites import native and render
  scaled **x3**; project texture filter = **Nearest**.
- Crisp pixels, ZERO changes to physics/nav/build math.
- Enable pixel snapping on the camera/viewport to stop sub-pixel shimmer.

### 3.2 Scene structure for depth ("2.5D")
- Level becomes Y-sorted (`y_sort_enabled`); sprite offsets so node origin
  = feet.
- Blob drop-shadows: shared dark ellipse sprite under every actor.
- Walls/tall props get front-face illusion: 16x16 footprint plus 8 px drawn
  side above origin.
- Parallax backgrounds only in menu/interludes; arenas stay flat ground +
  vignette overlay.

### 3.3 Data-driven chapters
- New `ChapterConfig` Resource: id, title, interlude_text,
  arena_template_id, rock_density range, target_waves, composition curve
  params, blueprint whitelist, boss_id (optional), protect_target
  (optional), victory_text.
- WaveDirector consumes ChapterConfig; existing compose_wave stays as the
  endless-mode curve generator.
- Endless = synthetic infinite config; best wave persisted.

### 3.4 Progress and saves
- `user://save.cfg`: unlocked_chapter, best_endless_wave.
- Menu gains CHAPTER SELECT row (locked entries show padlock) and endless
  best display.

## 4. Story mode level design (5 chapters)

Arena templates are parameterized variants of the existing procedural
generator (rect size, rock count/radius ranges, hazard props, border style).

### Ch.1 The Glassfields (tutorial, 8 waves)
- Layout: 2000x1200 open lot, sparse rocks (8), rust-belt props (tram
  wreck as cover, chain fences as decor).
- Teaches: move/auto-fire (w1-2), pickups (w2), wall granted (w4), turret
  granted (w6), brute intro scripted solo (w7).
- Set-piece: relay shack - protect-target building (40 HP) placed north;
  final wave is a breakthrough rush biased toward it; chapter fails if it
  falls.
- Exit: clear w8 -> victory -> interlude slide -> unlock Ch.2.

### Ch.2 Switchboard Tunnels (10 waves)
- Layout: 2304x1440 underground bunker; corridor-heavy rock fields; low
  light ambience.
- New mechanics: DARK CYCLES (6 s vision shrink every ~40 s) and
  DEFEND-EVENTS (radioed side-room holds, 20 s, bonus salvage + ending
  flag).
- Set-piece: reactor room breach seals the exit (scripted wave surge).

### Ch.3 Meridian Yards (12 waves)
- Layout: 2304x1440 factory yard; dense rock fields forming corridors;
  conveyor-line floor decals.
- Brutes standard from w3; blueprint reward after w5: **Repair Kit**
  (interact on damaged structure, costs scrap) - maintenance economy.
- Set-piece: foundry gate chokepoint where spawns narrow to a 2-cell-wide
  corridor during final waves (spawn template modifier).
- Exit: clear w12.

### Ch.4 The Kill Line (12 waves)
- Layout: 2560x1536 battlefield; crater decals as slow zones (-30% speed),
  wrecked armor props as free cover blocks; pincer template - two spawn
  edges active per wave.
- New enemy: **Skirmisher** - fast, 2 HP, sine-offset zigzag pathing;
  punishes static turret lines.
- BOSS set-piece: **Crawler-Titan** (rail siege walker, 120 HP, 3 phases):
  circles the border ring, telegraphed 1 s line salvo that shreds
  structures, spawns chaser escorts; weak point exposed while turning
  between rails. Kill = scripted bridge-collapse win, remaining waves void.
- Optional: three timed supply caches.

### Ch.5 Reservoir Seven (12 waves)
- Layout: 2304x1440 dam campus in drizzle; water-edge borders; pump-house
  props.
- New mechanic: EMP PULSES - map-wide turret shutdown for 5 s every ~45 s
  with a warning tone; walls/positioning must carry the gap.
- Set-piece: spillway overload floods the final assault (scripted win).

### Ch.6 Concord Overlook (12 waves)
- Layout: 2304x1440 mountain station; plateau rocks fake elevation; fixed
  hostile AC gun nests activate per wave - destructible (40 HP) or avoided.
- New enemy: **Gunner** - stops at 220 px range, fires projectiles at the
  player; walls block shots, making cover defensive at last.
- Set-piece: **AA Battery** multi-part boss - dish core plus 4 shield
  pylons; pylons gate core damage; map-wide mortar telegraphs every 6 s
  force repositioning between pylons.

### Ch.7 Downline Substation (12 waves)
- Layout: 2560x1536 power-grid substation; breaker-node props; cable-run
  floor decals.
- New enemy: **Repair Drone** - heals nearby enemies 1 HP/s, 4 HP, priority
  target or pushes stall.
- New mechanic: CAPTURE NODES - stand beside breakers to convert sectors;
  held nodes raise light level and thin spawns, but converting draws
  retaliation waves.
- Set-piece: rolling blackouts shrink the defensible footprint wave by wave
  until only the switching hall remains.

### Ch.8 Antenna Field (13 waves)
- Layout: 2816x1728 dish forest; symmetric approach lanes; fence line at
  the far edge.
- Mini-boss set-piece: **Custodian PAIR** - two walkers sharing one rotating
  shield bubble; only the walker outside the bubble is vulnerable; forces
  target-switching under fire.
- Mid-chapter CHOICE: defend the arriving Switchboard relay van to the end
  (hard optional, flags Quiet Ending) or push through.
- Exit: cut fence power during a Custodian reload cycle.

### Ch.9 Lighthouse Array (15 waves, finale)
- Layout: 3200x1920 broadcast complex; symmetric avenues; indestructible
  transmitter tower center-piece.
- FINAL BOSS: **THE ARCHIVIST** (200 HP, 4 phases): stationary command core
  rotating doctrines - AC phase (gunner escorts), UMR phase (brute + repair
  drone push), purge phase (telegraphed map laser sweep), desperation phase
  (enrage, mixed everything). Narrative finish: STAND DOWN handshake beats
  it without destroying - final wave clear + core at 0 = broadcast ending.

**Campaign runtime target:** ~140 min across chapters + ~6 min interludes +
retry buffer = **2h15m+ first playthrough** (see STORYBOARD runtime table).

## 5. Systems roadmap

| System | Phase | Notes |
| ------ | ----- | ----- |
| Sprite swap pipeline (Polygon2D -> AnimatedSprite2D) | 6 | keep node names; swap visuals only |
| ChapterConfig + chapter select UI | 6 | Resource-driven, menu row |
| Interlude screens (text + portrait slide) | 6 | reuses radio_interlude_bg art |
| Protect-target objective | 7 | HealthComponent on prop; fail state |
| Objective manager (defend-events, capture nodes, timed caches) | 7 | shared objective scheduler |
| Dark cycles / rolling blackouts (vision + footprint shrink) | 7 | global modifier timer |
| Boss framework (phases, telegraphs, weak points) | 7 | boss_base.gd + per-boss scripts |
| New enemies: Skirmisher, Gunner, Repair Drone | 8 | extend KIND_STATS + behaviors |
| Enemy projectile variant (targets player) | 8 | Projectile gains faction mask param |
| EMP pulse cycle (turret shutdown windows) | 8 | warning tone + global disable |
| Paired-shield mini-boss (Custodian Pair) | 8 | linked shield rotation logic |
| Repair Kit blueprint + structure HP UI | 8 | interact prompt when near damaged wall |
| Crater slow zones / decals with gameplay effect | 8 | Area2D speed multiplier |
| Pincer spawn template (2 edges) | 8 | WaveDirector spawn edge list |
| Game-feel juice pack | 9 | screenshake, hit-stop 40 ms, muzzle flash, damage flash, death poofs, placement dust |
| Audio integration full pass | 9 | all OST tracks wired, SFX manifest complete |
| Endless mutator curve + best-wave save | 9 | every-5-waves modifier pick |
| Export: Windows build + itch.io page | 10 | export templates, icon, splash |

## 6. Milestones and acceptance gates

Every phase ends with: full GUT suite green + both smokes clean + manual
playtest of the touched loop.

| Milestone | Exit criteria |
| --------- | ------------- |
| M1 Art pipeline live (end Ph.6) | player/chaser/ground use real pixel art at x3 nearest; zero visual regressions headless |
| M2 Story skeleton (end Ph.7) | menu -> ch1 -> interlude -> ch2 playable start-to-finish via chapter select; save persists |
| M3 Combat depth (end Ph.8) | all 6 enemy types + 2 bosses + 1 mini-boss functional in test arenas |
| M4 Content complete (end Ph.9) | all 9 chapters beatable; measured first-run time >= 2h; endless 20+ waves stable; juice pass applied |
| M5 Release candidate (end Ph.10) | exported exe runs on a clean machine; credits/licensing docs complete |

Rough solo-dev sizing (9-chapter scope): Ph.6 = 1-2 wk, Ph.7 = 2-3 wk,
Ph.8 = 3-4 wk, Ph.9 = 4-5 wk, Ph.10 = 1 wk. Total ~12-15 wk to RC.
Scope guard: chapters ship in vertical-slice order (Ch.1 -> Ch.2 -> ...);
no new chapter content starts before the previous one is beatable and
tested.

## 7. Asset acquisition strategy

Free-first (CC0), custom-second:

| Need | Source | License |
| ---- | ------ | ------- |
| Ground/border tiles, rocks, industrial props | Kenney Roguelike/RPG + Modern City + Caves & Dungeons packs (16 px) | CC0 |
| UI kit (buttons, panels, sliders) | Kenney UI Pack (pixel variants) | CC0 |
| Explosions/impacts flipbooks | Kenney Particle Pack + custom palette swap | CC0 |
| Characters/bosses | AI-generated concept -> cleanup/redraw (see AI_CHARACTER_PROMPTS.md) | ours |
| Anything Kenney cannot cover | OpenGameArt filtered CC0, else hand-drawn in Aseprite | check per asset |

Rule: never mix a non-CC0 asset into the repo without a CREDITS.md entry
(docs/audio/SFX_GUIDE.md house rule applies to art too).

## 8. Risks and mitigations

- **AI art inconsistency** -> style anchor + hex-locked palettes + one
  cleanup pass in Aseprite (see character prompts doc).
- **Boss scope creep** -> bosses are phase-state machines over existing
  HealthComponent/projectile systems; no new engine tech required.
- **Enemy count perf** -> hard cap stays 36 alive; nav repath staggered;
  sprites are single draw calls.
- **Scope creep overall** -> Ch.1 ships as vertical slice BEFORE Ch.2-5
  content begins; pillars arbitrate every "wouldn't it be cool".
