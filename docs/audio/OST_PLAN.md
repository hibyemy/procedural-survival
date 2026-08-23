# Procedural Survival - Original Soundtrack Plan (Lyria 3 Pro edition)

Every track below is designed to be generated with **Google Lyria 3**, not
composed from scratch. The engine already knows these exact file paths:
finish a track, run it through the post-processing pipeline at the bottom,
drop it in the listed location, and it plays automatically.

## Generation stack

| Stage | Model | Why |
| ----- | ----- | --- |
| Prompt iteration | `lyria-3-clip-preview` (30 s clips) | fast + cheap vibe-checking before committing |
| Final renders | `lyria-3-pro-preview` (~184 s max) | full-length, structure-aware, timestamp control |

Verified model behavior (per Google's docs, March 2026):

- Text or image prompts; **instrumental-only is fully supported**.
- Structure control via section tags (`[Intro]`, `[Verse]`, ...) and
  timestamps (`[0:00 - 0:30] ...`); duration steered by prompt
  ("create a 2-minute song").
- Specify **BPM, key, instruments, mood adjectives** explicitly - vague
  prompts give generic output.
- **Single-turn only**: no iterative editing. To change anything, regenerate
  with a revised prompt. Change ONE variable per regeneration.
- Results vary run-to-run even with identical prompts: generate 3-4 takes,
  keep the best.
- Requests naming real artists are blocked by safety filters. Describe the
  *production style* instead.
- Output: MP3 (convert to OGG for Godot). All audio carries an inaudible
  SynthID watermark.
- Usage rights depend on your access route (Gemini API / Vertex AI /
  consumer app) - confirm the commercial-use terms of whichever you use.

## Global rules for every prompt

1. Always append the phrase **"Instrumental only. No vocals, no lyrics."**
2. Never name artists/bands; describe era + production instead
   ("late-1970s analog synth soundtrack production, tape saturation").
3. Always state BPM and key.
4. Use timestamps to lay out the arrangement you want.
5. Keep the shared style anchor (below) as the opening sentence of every
   prompt so all six tracks sound like one OST.

### Shared style anchor (prepend verbatim)

> Late Cold War analog electronic soundtrack, circa 1979-1986: monophonic
> synth leads, warm detuned pad beds, vintage drum machine, shortwave radio
> static texture, tape hiss and vinyl crackle. Melancholy, lonely but
> purposeful - scavenging the ruins of a war fought by machines.

### The leitmotif (adjusted expectation)

A generative model will not reliably reproduce an exact melody across
tracks. Instead, every prompt below describes the same *conceptual motif* -
"a sparse three-note descending motif on a thin synth lead". Generate all
tracks, then hand-pick takes whose motifs happen to rhyme. That selection
step IS your leitmotif work now.

## Delivery specs

| Spec | Value |
| ---- | ----- |
| Format | convert generated MP3 -> OGG Vorbis q~0.9 (Godot-native) |
| Sample rate | 44.1 kHz stereo (resample from 48 kHz render) |
| Loudness | normalize every track to **-16 LUFS integrated**, true peak <= -1 dBTP |
| Looping | see per-track targets; seamless-loop recipe at bottom |
| Naming | exactly as listed, lowercase snake_case |

```
assets/audio/music/menu.ogg
assets/audio/music/exploration.ogg
assets/audio/music/combat.ogg
assets/audio/music/siege.ogg
assets/audio/music/game_over.ogg
assets/audio/music/victory.ogg
```

Missing files are silently skipped by the engine, so build incrementally.

---

## Track briefs with ready-to-paste prompts

Each prompt already contains the style anchor's intent; paste as-is into
Pro, iterate in Clip first by pasting just the first two sentences.

### 1. `menu.ogg` - "Last Broadcast"

- **Plays:** main menu + settings screen, looping forever.
- **Job:** premise in 10 seconds - civilization ended, someone still transmits.
- **Target:** ~90 s, seamless loop.

**Prompt:**

> Create a 90-second instrumental piece: late Cold War analog electronic
> soundtrack, circa 1979-1986, with monophonic synth leads, warm detuned pad
> beds, vintage drum-machine pulse, and shortwave radio static texture. In
> A minor at 80 BPM. Melancholy, lonely but purposeful. [0:00-0:15] Slow
> arpeggiated synth figure alone over a warm pad. [0:15-0:45] Add a soft
> bass pulse and faint morse-code blips like a numbers station, plus distant
> wind noise. [0:45-0:75] Introduce a sparse three-note descending motif on
> a thin synth lead. [0:75-0:90] Strip back to pad and arpeggio for a
> loopable ending. Instrumental only. No vocals, no lyrics.

**Loop edit:** the timestamped strip-back ending should butt cleanly against
bar 1; verify and micro-crossfade if needed.

### 2. `exploration.ogg` - "Ashfall Ambience"

- **Plays:** in-run between waves (build/loot phase); crossfades out when
  combat starts.
- **Job:** meditative eye-of-the-storm; must never compete for attention.
- **Target:** ~120 s, seamless loop.

**Prompt:**

> Create a 2-minute near-ambient instrumental bed: late-1970s analog
> electronics, sub-bass drone on D, filtered wind-like noise sweeps through
> ruined-city space, very quiet metallic pings once every ten seconds, and
> occasional vinyl crackle. Around 70 BPM felt tempo, D Dorian, free and
> breathing. Midway, introduce a barely-present three-note descending synth
> motif, then let it dissolve again. No drums. Sparse, hollow, slightly
> uneasy but calm. Instrumental only. No vocals, no lyrics.

**Loop edit:** drones loop easily; check the noise sweeps don't peak near
the seam.

### 3. `combat.ogg` - "Scavengers' Waltz"

- **Plays:** standard chaser waves; back to exploration when cleared.
- **Job:** raise heart rate without panic; steady rhythmic anchor for kiting.
- **Target:** ~90 s, seamless loop, no big mid-loop jumps.

**Prompt:**

> Create a 90-second driving instrumental track: late-1970s analog synth
> production with tape saturation. Pulse-bass eighth notes, dry punchy drum
> machine (kick on 1 and 3, noise snare on 2 and 4), staccato string-synth
> stabs answering the bass, and a fast three-note descending lead motif in A
> minor at 100 BPM. Tense, propulsive, focused. Keep the midrange open -
> sparse mix, no wall of sound. [0:00-0:10] Bass and drums alone. [0:10-0:70]
> Full pattern with stabs and motif. [0:70-0:90] Drop the lead, keep groove
> for a loopable outro. Instrumental only. No vocals, no lyrics.

### 4. `siege.ogg` - "Steel Rain"

- **Plays:** heavy waves containing brutes; must feel categorically more
  dangerous than combat.
- **Job:** dread + weight; something enormous walking toward you.
- **Target:** ~90 s, seamless loop.

**Prompt:**

> Create a 90-second heavy industrial-electronic instrumental: half-time
> feel at 120 BPM where the kick lands like slow footsteps, a detuned saw
> drone a fifth below the root in F minor, percussion built from metal
> impacts and chain hits instead of snares, and one dissonant cluster chord
> held underneath that never resolves. Oppressive, massive, dread-inducing.
> [0:00-0:15] Drone and footsteps alone. [0:15-0:65] Industrial percussion
> builds in layers. [0:65-0:85] Add a slowly rising siren-like filtered
> sweep. [0:85-0:90] Cut the sweep, return to drone for the loop point.
> Instrumental only. No vocals, no lyrics.

### 5. `game_over.ogg` - "Static Requiem"

- **Plays:** death screen (tree paused; music autoload keeps running).
  One-shot, fades after one pass - looping NOT required.
- **Perfect Clip-model job:** 30 s is exactly enough. Prototype here, and if
  a Clip take is great, ship it as-is.
- **Target:** 15-25 s, no cadence - the fight isn't finished.

**Prompt:**

> Create a 20-second mournful instrumental cue: slowed-down, detuned
> morse-code-style blips playing a sparse descending figure over a decaying
> warm analog pad, with faint radio static dissolving into silence. Late
> Cold War electronics, tape hiss. Ends unresolved on a suspended chord with
> no final cadence. Grieving but quiet. Instrumental only. No vocals, no
> lyrics.

### 6. `victory.ogg` - "Dawn Signal"

- **Plays:** story-mode win. One-shot, tail into silence.
- **Job:** the ONLY hopeful cue - payoff for the whole run.

**Prompt:**

> Create a 40-second uplifting-but-weathered instrumental finale: late Cold
> War analog synths turning warm for the first time. A gentle 4-on-the-floor
> pulse lifts into a sustained major resolution in C major around 80 BPM;
> bell-like plucked tones play a rising three-note motif answering the
> earlier descending one; radio static fades out over the first eight bars
> like a broadcast finally getting through. Bittersweet dawn, hard-won hope.
> [0:00-0:12] Solo bells over static. [0:12-0:28] Pulse enters, pads bloom.
> [0:28-0:40] Full sustained chord, slow decay to silence. Instrumental
> only. No vocals, no lyrics.

---

## Post-generation pipeline (every track)

1. **QC pass:** listen end-to-end for AI artifacts - flanged cymbals,
   garbled "vocal-like" ghosts, sudden timbre swaps at section borders.
   Regenerate if bad (change one variable only).
2. **Trim:** remove leading/trailing silence (leave 50 ms head, ~300 ms tail).
3. **Loop surgery** (looping tracks only):
   - In Audacity: pick the loop region (usually cutting the intro), duplicate
     the last 0.3-0.5 s onto the start as a crossfade, use Effect > Fade
     shapes / Crossfade Clips for an equal-power blend.
   - Verify: loop it 5x on headphones at LOW volume - clicks hide otherwise.
   - Pragmatic fallback for ambient beds: leave a 1 s fade-out and let the
     engine's 0.8 s crossfading mask the seam.
4. **Convert:** MP3 -> WAV (44.1 kHz) -> OGG Vorbis q0.9 (e.g. ffmpeg:
   `ffmpeg -i in.mp3 -ar 44100 -q:a 9 out.ogg`).
5. **Normalize:** -16 LUFS integrated, true peak <= -1 dBTP.
6. **Name + place** exactly per the paths table; boot the game and confirm
   each trigger point fires the right track.

## Production tips

- Iterate prompts in **Clip** (cheap, fast); only render finals in **Pro**.
- Generate 3-4 takes per track and choose the best - variance is a feature.
- If a take is 90% right, do NOT try to edit it; re-roll with one changed
  sentence (e.g., swap "tape saturation" for "clean analog", or nudge BPM).
- Keep every accepted prompt + take filename in a log next to this file -
  single-turn means your prompt history is your only "project file".
- Mix headroom is handled by the -16 LUFS normalize step; gunshots and UI
  sounds sit ON TOP of these beds by design (see `SFX_GUIDE.md`).
