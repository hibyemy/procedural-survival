# LEVEL STYLE MATRIX - unique identity per chapter

Every chapter gets its own VISUAL style and its own THEME TRACK so no two
levels feel alike. Shared systems (combat/siege stingers, UI, SFX) stay
consistent on purpose - identity lives in the level bed, variety without
fragmenting the game.

## Two-layer music architecture

| Layer | Scope | Files | Status |
| ----- | ----- | ----- | ------ |
| State layer | whole game | menu / exploration / combat / siege / game_over / victory | SAMPLED - your 6 files in `/audio` |
| Identity layer | one per chapter | `theme_ch1.ogg` ... `theme_ch9.ogg` | TO GENERATE (prompts below) |

### Sample inventory -> slot mapping (your current takes)

Rename/convert (trim -> loop-check -> OGG q0.9 -> -16 LUFS) into
`assets/audio/music/`:

| Your file (`/audio`) | Engine slot | Fits because |
| -------------------- | ----------- | ------------ |
| Cold War Analog Electronic Soundtrack.mp3 | `menu.ogg` | pad-led, broadcast mood |
| Ambient Ruined City Soundscape..mp3 | `exploration.ogg` | near-ambient bed |
| Retro Synth Driving Instrumental Track (1).mp3 | `combat.ogg` | driving pulse anchor |
| Industrial Electronic Composition Request.mp3 | `siege.ogg` | metal-percussion weight |
| Mournful Cold War Instrumental Cue.mp3 | `game_over.ogg` | unresolved grief cue |
| Cold War Synth Finale.mp3 | `victory.ogg` | resolution payoff |

Engine note (Phase 6 wiring): ChapterConfig gains `theme_track: StringName`;
MusicDirector plays the chapter theme during build phase, then hands off to
combat/siege on wave start, back to the theme on clear. Themes loop
seamlessly; state-layer rules unchanged (OST_PLAN.md).

## How to read each card

STYLE = what your eyes get (palette bias within the locked ramps of
ART_SPEC.md, signature props, light/tint modifier, the one unique visual
hook tied to that chapter's mechanic).
OST = what your ears get (style name, key/BPM, signature sounds, ready
Lyria seed prompt, engine filename).

---

## ACT I

### Ch.1 THE GLASSFIELDS - "Ashfall Rust"

- **STYLE:** Overcast flat daylight, ash-green ground bias with creeping
  moss decals; rust dominates props: tram wreck (cover), chain-link runs,
  tilted power pylons. Tint modifier: none - this is the neutral baseline
  every later level deviates from.
- **Hook visual:** wind-blown ash particles drifting one direction; flags
  and cables all lean the same way.
- **OST "Dust Western"** - D minor, 66 BPM. Mournful harmonica-like synth
  lead over bowed drones; sparse dust-stomp percussion. The ruin as a
  abandoned frontier.
- **Lyria seed:** late Cold War analog electronics meets deserted-western
  mournfulness: distant harmonica-toned synth lead playing a slow descending
  phrase, bowed string-saw drone bed, sparse dusty percussion like slow
  footsteps on gravel, faint wind noise.
- **File:** `assets/audio/music/theme_ch1.ogg`

### Ch.2 SWITCHBOARD TUNNELS - "Underground Exchange"

- **STYLE:** Near-black steel-and-concrete tileset; visibility comes from
  painted lamp pools (radial light decals) around fixtures; pipe runs and
  cable trays line walls; painted sector numbers on floors. Dark-cycle
  mechanic shown by lamp pools dying to embers.
- **Hook visual:** wall rotary phones and patch panels; a blinking "LINE
  BUSY" lamp above each defend-event room.
- **OST "Relay Room"** - F minor, 72 BPM. Telephone relay clicks and
  teletype chatter AS the percussion section; warm close-ceiling reverb;
  no drums at all - machines converse instead.
- **Lyria seed:** claustrophobic underground bunker ambience built from
  vintage telephone exchange sounds: mechanical relay clicks forming
  rhythmic patterns, teletype machine ticks, low concrete-room reverb,
  a muted piano motif far away in the dark.
- **File:** `theme_ch2.ogg`

### Ch.3 MERIDIAN YARDS - "The Line Never Sleeps"

- **STYLE:** Gray-green concrete floor with conveyor stripes and hazard
  chevrons; sodium-orange lamp tint (warmest level in the game); assembly
  arms frozen mid-weld as landmark props; sparks particle ambience.
- **Hook visual:** conveyor belts still creep along - purely decorative,
  deeply unsettling.
- **OST "Assembly Funk"** - A minor, 88 BPM. Stamped-metal percussion loops,
  steam-hiss backbeats, driving single-note bass ostinato, factory siren
  long-tones as chorus hits.
- **Lyria seed:** industrial mechanical groove: percussion made of stamped
  metal sheets and hydraulic hisses, relentless single-note synth bass
  ostinato, factory warning siren swelling occasionally like a distant
  chorus, tape-saturated and oily.
- **File:** `theme_ch3.ogg`

## ACT II

### Ch.4 THE KILL LINE - "Scorched Parade"

- **STYLE:** Scorched browns over ash base; crater decals double as gameplay
  slow zones (cracked rim highlight); shell casings litter tiles; wrecked
  armor hulls as free cover; permanent red-dusk tint + drifting smoke
  columns mark active spawn edges.
- **Hook visual:** pincer spawns telegraphed by two smoke columns rising on
  the chosen edges before the wave drops.
- **OST "Broken March"** - G minor, 96 BPM halting processional. Snare
  battery field-drum patterns, detuned bugle-tone synth quoting taps, low
  drone artillery rumbles on downbeats.
- **Lyria seed:** war-torn military processional played by ghosts: field
  snare drum battery patterns that keep breaking formation, a detuned
  bugle-like synth playing a funeral-taps motif, sub-bass booms like
  distant artillery landing on the beat.
- **File:** `theme_ch4.ogg`

### Ch.5 RESERVOIR SEVEN - "Turbine Rain"

- **STYLE:** Wet blue-gray concrete, puddle decals reflecting lamp light
  (static fake reflections), rain-streak overlay layer, mist banks; dam
  face as north border art.
- **Hook visual:** EMP pulses announced by every puddle flickering dark for
  a heartbeat BEFORE the shutdown hits - players learn to read the water.
- **OST "Hydro Static"** - E minor, 74 BPM, lilt 3/4. Tuned water drips
  arpeggiating against deep hydro-electric bass swells; rain static bed;
  turbine hum drone underneath everything.
- **Lyria seed:** cavernous hydroelectric hall in the rain: pitched water
  drips tuned into a gentle repeating arpeggio, immense soft bass swells
  like turbines breathing, steady rain static, everything slightly wet and
  reverberant.
- **File:** `theme_ch5.ogg`

### Ch.6 CONCORD OVERLOOK - "White Noise Watch"

- **STYLE:** Pale rock and snow-patch tiles; radar dish silhouettes on the
  horizon border; thin arctic white-blue light, long painted shadows;
  frost vignette corners.
- **Hook visual:** hostile gun nests are painted snow-camo until they
  activate - then signal-red sensor strips wake up across the map.
- **OST "Radar Hymn"** - C minor, 60 BPM. Sonar/radar ping arpeggios fading
  into icy pad choirs; glacial slowness; wind whiteness behind.
- **Lyria seed:** lonely arctic early-warning station: sonar ping tones
  echoing into vast reverb, cold crystalline pad choir, slow breathing
  wind, a sense of enormous empty altitude and patient machines.
- **File:** `theme_ch6.ogg`

## ACT III

### Ch.7 DOWNLINE SUBSTATION - "Live Wire"

- **STYLE:** Dark grid-floor tiles with cable runs that glow faint cyan -
  captured nodes literally re-light their district of the map; ceramic
  insulator stacks, transformer hum-boxes; electric-blue is the ONLY bright
  color allowed here.
- **Hook visual:** capture progress = cable run charging from node outward,
  frame-lit floor tiles flipping on like dominoes.
- **OST "Mains Hum"** - B-flat minor, 78 BPM. 50 Hz mains hum as tonic drone,
  arc-spark tick percussion, voltage-rise sweeps between sections; capture
  stingers add one chord tone each.
- **Lyria seed:** electrified night at a power substation: continuous low
  electrical hum drone as the home note, sharp arc-spark ticks dancing as
  hi-hats, rising voltage sweep synths between phrases, dangerous but
  danceable energy.
- **File:** `theme_ch7.ogg`

### Ch.8 ANTENNA FIELD - "Carrier Wave Choir"

- **STYLE:** Dry ash-grass tiles under a forest of dish silhouettes; guy-wire
  lines crossing overhead (pure decor); twilight bone-light sky decal with
  the deepest shadow contrast in the game; dishes emit faint red standby
  dots.
- **Hook visual:** when the Custodian Pair's shield rotates, nearby dishes
  briefly resonate - ripple decals pulse toward it, hinting the mechanic.
- **OST "Ghost Broadcast"** - D minor, 70 BPM. Wordless vocoded choir pads
  filtered through shortwave radio tuning; antenna-feedback resonance
  tones; beauty and wrongness in equal measure.
- **Lyria seed:** haunted radio telescope field at dusk: ethereal vowel-like
  synth choir passing through shortwave static filters, resonant feedback
  tones rising from metal antennas, distant numbers-station fragments
  dissolving before they resolve.
- **File:** `theme_ch8.ogg`

### Ch.9 LIGHTHOUSE ARRAY - "Sixteen Minutes"

- **STYLE:** Bone-white ceremonial tiles, cleanest space in the game; both
  faction banners faded to identical gray hanging together; sweeping beacon
  light pools animate across the arena; transmitter tower center-piece with
  slow strobing aviation lights.
- **Hook visual:** each Archivist phase tints the beacons - blue (AC), rust
  (UMR), red (purge), white (desperation) - readable phase telegraph.
- **OST "Stand Down"** - A minor resolving to C major, 84 BPM. A finale
  medley quoting every chapter's signature sound in wave order, building to
  the handshake motif; final section = first true major-key warmth, reserved
  exclusively for the STAND DOWN moment.
- **Lyria seed (Pro, ~3 min):** finale suite combining earlier motifs:
  opens funereal with bugle and snare quotes [0:00-0:40], industrial rhythm
  section joins [0:40-1:20], radar pings and water-drop arpeggios weave
  through [1:20-2:00], everything converges into a rising chorale
  [2:00-2:40], ending on a warm resolved major chord with bells
  [2:40-3:00].
- **File:** `theme_ch9.ogg` (plus victory.ogg stays as the standalone win
  sting)
