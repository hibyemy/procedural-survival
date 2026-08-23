# Procedural Survival — Original Soundtrack Plan

This document is the brief for every background music track in the game.
The engine already knows these exact file paths, so when you finish a track,
export it to the listed location and it plays automatically. No code changes
needed.

---

## Global aesthetic direction

- **Era feel:** late Cold War analog electronics. Think 1979–1986: tape
  saturation, vinyl hiss, monophonic synth leads, drum machines (LinnDrum /
  TR-808 style), shortwave radio static as texture.
- **Mood arc:** the world ended in an afternoon; everything you hear is what
  is left. Music should feel *lonely but purposeful* — scavenging, not doom.
- **Harmonic language:** minor keys, mostly Aeolian and Dorian. Avoid major
  resolutions except for the victory track. Suspended chords and pedal tones
  create tension without fatigue during long loops.
- **Tempo map:** menu ~80 BPM, exploration ~70 BPM, combat ~100 BPM, siege
  ~120 BPM. Never faster; this is a survival game, not an action game.

## Delivery specs (all tracks)

| Spec         | Value                                        |
| ------------ | -------------------------------------------- |
| Format       | OGG Vorbis (quality ~0.9) or WAV → Godot re-imports |
| Sample rate  | 44.1 kHz                                     |
| Channels     | Stereo                                       |
| Loudness     | -16 LUFS integrated (music bus sits at -6 dB under SFX) |
| Looping      | Seamless loop; set `loop = true` on import (Godot OGG importer has a Loop checkbox), or leave off for one-shots noted below |
| Naming       | lowercase snake_case exactly as listed       |

**File locations:**

```
assets/audio/music/menu.ogg
assets/audio/music/exploration.ogg
assets/audio/music/combat.ogg
assets/audio/music/siege.ogg
assets/audio/music/game_over.ogg
assets/audio/music/victory.ogg
```

If a file does not exist the game silently skips it, so you can add tracks
incrementally.

---

## Track-by-track plans

### 1. `menu.ogg` — "Last Broadcast" (main menu)

- **When it plays:** main menu, settings screen, any time no run is active.
  Loops forever until the player starts a mode.
- **Job:** establish the premise in 10 seconds — civilization ended, but
  someone is still transmitting. This is the player's first impression.
- **Content:** slow arpeggiated synth figure (A minor, ~80 BPM) over a warm
  pad bed. Layer a faint **numbers-station style voice/morse motif** every
  8 bars — this is your story hook in audio form (the "broadcast" the story
  mode revolves around). Add distant wind noise.
- **Structure:** A (8 bars) → B (8 bars, adds bass pulse) → back to A. Loop
  seamlessly at bar 1 of A. Target length 60–90 s so the loop point isn't
  noticeable.
- **Avoid:** percussion louder than the pad; the menu should invite reading
  the buttons, not compete with them.

### 2. `exploration.ogg` — "Ashfall Ambience" (in-run, between waves)

- **When it plays:** the moment a run starts, and during the lull after a
  wave is cleared while the next wave timer counts down. Crossfades out when
  combat begins.
- **Job:** make the build/loot phase feel meditative and slightly uneasy —
  the eye of the storm. This is where players plan, so nothing should demand
  attention.
- **Content:** near-ambient. Sub-bass drone (root note only, D), sparse
  filtered noise sweeps like wind through ruins, occasional metallic pings
  (very quiet, once per 8–12 s). Melody optional; if present keep it to a
  single 3-note motif that recurs across ALL combat tracks — a leitmotif the
  player will subconsciously recognize.
- **Tempo/key:** ~70 BPM felt tempo or free-time; D Dorian.
- **Loop:** 90–120 s seamless.

### 3. `combat.ogg` — "Scavengers' Waltz" (standard wave)

- **When it plays:** on `wave_started`, for waves composed mainly of chasers.
  Crossfades back to `exploration` when the wave is cleared.
- **Job:** raise the heart rate without panic. The player is kiting and
  shooting; give them a steady rhythmic anchor to move to.
- **Content:** driving pulse bass (eighth notes), punchy but dry drum
  pattern (kick on 1 & 3, snare/noise on 2 & 4), staccato string-synth
  stabs answering the bass. Bring in the shared leitmotif from track 2 at
  double speed in the lead line. Keep frequency space clear around 2–4 kHz
  so gunfire SFX cut through.
- **Tempo/key:** ~100 BPM, A minor.
- **Loop:** 60–90 s seamless. Avoid big arrangement jumps mid-loop — waves
  can last anywhere from 20 s to 2 min.

### 4. `siege.ogg` — "Steel Rain" (heavy wave / brutes on field)

- **When it plays:** on `wave_started` when the wave includes brutes (the
  director passes a "heavy" flag). This must feel categorically more
  dangerous than `combat`.
- **Job:** dread + weight. Brutes are slow tanks; the music should sound
  like something enormous is walking toward you.
- **Content:** half-time feel (~120 BPM with kick landing like footsteps),
  detuned saw drone a fifth below the root, industrial percussion (metal
  impacts, chain hits instead of snare), dissonant cluster chord that never
  resolves. Optional low male vocal Drone or cello sample. Save ONE new
  element for the final 25% of the loop (a rising siren-like filter sweep)
  so extended fights escalate naturally.
- **Tempo/key:** 120 BPM half-time, F minor.
- **Loop:** 75–100 s seamless.

### 5. `game_over.ogg` — "Static Requiem" (death screen)

- **When it plays:** the instant `player_died` fires (tree is paused — the
  audio autoload keeps running). Does NOT need to loop longer than ~20 s;
  fade to silence after one pass if easier than looping.
- **Job:** grief, then resolve into quiet determination — the retry button
  is right there.
- **Content:** the numbers-station morse motif from the menu, slowed to half
  speed and detuned, over a decaying pad. End on an unresolved suspended
  chord (no cadence — the fight isn't finished).
- **Length:** 15–25 s, one-shot (loop off).

### 6. `victory.ogg` — "Dawn Signal" (story mode win)

- **When it plays:** when `run_won` fires in story mode (final wave
  cleared / objective complete).
- **Job:** the ONLY moment of hope in the OST. Payoff for the whole run.
- **Content:** take the 3-note leitmotif and finally resolve it to the
  relative MAJOR. Warm pad + real-feeling bell/plucked tone playing the
  motif, gentle 4-on-the-floor pulse lifting into a sustained major chord.
  Radio static fades OUT over the first 8 bars — the broadcast got through.
- **Length:** 30–45 s, one-shot, tail into silence.

### 7. (Optional stretch) `wave_horn` stinger

- 2–4 s brass/synth alarm hit played by the SFX system (not music) at each
  wave start. See `SFX_GUIDE.md`.

---

## Production tips

1. **Compose exploration first.** Its 3-note leitmotif seeds every other
   track; writing it last means retrofitting everything else.
2. **Stems pay off later.** If your DAW makes it cheap, bounce drums / bass
   / pads / lead separately. A future dynamic-mix feature (adding layers as
   waves escalate) needs stems, not full mixes.
3. **Check loops on headphones at low volume** — clicks at loop points hide
   otherwise. Leave 1–2 bars of tail overlap when bouncing.
4. **Mix for ducking:** assume gunshots, explosions and UI blips play ON TOP
   of everything. Keep 2–4 kHz relatively open in all combat mixes.
