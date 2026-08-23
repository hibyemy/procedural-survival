# AI character art prompts + style continuity system

Use this to generate character/prop concepts and (with cleanup) production
sprites with image models (Retro Diffusion, PixelLab, Scenario, Stable
Diffusion + pixel LoRA, or general models for concept-only). The engine
expects the sheet specs in `ART_SPEC.md` - prompts below are written to hit
those specs.

## 1. The style anchor (paste verbatim in EVERY prompt)

Consistency comes from reusing one immutable descriptor block, the same
trick as the Lyria style anchor:

> 16-bit era top-down pixel art sprite, 3/4 perspective, on plain
> background. Limited palette of desaturated steel blue-grays, rust
> oranges, ash greens and bone off-whites; single-pixel selective dark
> outline; two-tone shading from a top-left light source; no gradients, no
> anti-aliasing. Late-20th-century post-apocalyptic military-scavenged
> design language.

Rules:
- Never paraphrase the anchor. Copy it exactly, every time.
- Keep ONE model/version per character line: generate all frames of a
  character in one session; switching models mid-character breaks style.
- Lock hex palettes per character (cards below); after generation,
  remap any stray colors to the ramp in Aseprite (or a palette-swap script).
- Generate a REFERENCE SHEET first (turnaround + expression poses), pick
  the best take, then generate animation frames describing that take.

## 2. Tool notes

- **Pixel-native tools** (Retro Diffusion, PixelLab) output usable pixel
  grids directly at small sizes - prefer these for final sprites.
- **General diffusion** output is concept-grade: use it as reference and
  redraw/clean in Aseprite. Do not ship raw downscales without a manual
  pixel-pass (jagged edges, color noise).
- Always add the NEGATIVE block from section 3.
- If your tool supports seeds: fix the seed per character card after a good
  first take, vary only the pose sentence.

## 3. Universal negative prompt (append always)

> blurry, anti-aliased, smooth shading, gradients, photorealistic, 3D
> render, thick outlines, saturated neon colors, text, watermark, multiple
> characters, isometric grid, side view, front view portrait

## 4. Character cards

### PLAYER - "Wren" (scavenger-engineer)

- Palette lock: steel #4A6076/#7A93AB body, bone #D9D2E0 trim, signal-red
  #D94F3D tool strap, visor strip #E89A55.
- Sheet spec: 14x18 native, walk 6f side view, idle 2f, hurt 1f.

**Prompt:**
[style anchor] A lone scavenger engineer seen from above at a slight
three-quarter angle, walking pose facing right. Slim figure in a patched
steel-blue jumpsuit with bone-white tape marks, a rust-orange tool bandolier,
small backpack with a coiled radio antenna, glowing amber visor strip across
the face. Feet visible under the torso, readable silhouette at tiny scale.
Sprite sheet, 6-frame walk cycle facing right on one horizontal strip, each
frame 14x18 pixels.

### ENEMY - Chaser (AC scout drone)

- Palette lock: faded AC blues #4A6076/#B8C9DB hull, one signal-red sensor.
- Sheet spec: 12x12, walk/hover 4f, death 4f ending in wreck.

**Prompt:**
[style anchor] A small hostile reconnaissance drone seen from directly
above, three-quarter tilt. Compact rounded-triangle hull in faded blue-gray
military paint with chipped edges, four stubby thruster nacelles, a single
glowing red optical sensor at the front. Slight hover wobble implied by
frame variation. Sprite sheet, 4-frame hover cycle plus 4-frame crash/wreck
sequence ending as burnt debris, horizontal strips, 12x12 pixels per frame.

### ENEMY - Brute (UMR siege frame)

- Palette lock: rust #59291A/#8F4520 armor plates, dark steel joints,
  red sensor slit.
- Sheet spec: 20x22, walk 6f, lunge 2f.

**Prompt:**
[style anchor] A hulking bipedal siege robot seen from above at three-quarter
angle, mid-stride facing right. Blocky riveted armor plates in oxidized
rust-red brown, exposed dark steel hydraulics at knees and shoulders, one
horizontal red sensor slit on a low wedge head, oversized blunt fists.
Slow heavy silhouette wider than tall details suggest. Sprite sheet, 6-frame
heavy walk cycle plus 2-frame lunging attack, horizontal strips, 20x22
pixels per frame.

### BOSS - Crawler-Titan (rail siege walker, Ch.3)

- Palette lock: mixed both-faction paint over rust, cyan capacitor glow.
- Sheet spec: 48x28 multi-tile, rail-walk 8f, salvo telegraph 2f.

**Prompt:**
[style anchor] A massive multi-legged railway siege platform seen from
directly above, occupying most of the frame horizontally. Six articulated
crab legs gripping rails, armored hull blending faded blue-gray and rust-red
panels from two different armies, cyan capacitor coils along the spine,
front cannon battery. Intimidating industrial silhouette with clear leg
animation potential. Sprite sheet, 8-frame rail-walking cycle, 48x28 pixels
per frame, plus 2 separate frames of cannon barrels charging with cyan glow.

### BOSS - THE ARCHIVIST (command core, Ch.5)

- Palette lock: bone-white ceramic casing, both faction accents (blue + rust
  stripes), signal-cyan core eye.
- Sheet spec: 32x32, idle rotate 6f, purge charge 4f.

**Prompt:**
[style anchor] A fused command-bunker AI core seen from directly above:
a circular bone-white ceramic housing with faded blue-gray and rust-red
stripes colliding down the middle like two armies stitched together, a
large central cyan lens eye, cable roots radiating outward into the floor,
scorch marks and field repairs. Authoritative, tragic, machine-bureaucrat
presence. Sprite sheet, 6-frame slow rotating idle plus 4-frame charging
glow sequence, 32x32 pixels per frame.

## 5. Acceptance checklist (per generated asset)

1. Palette audit: every pixel maps to the locked ramp (fix strays).
2. Outline pass: continuous selective outline, no orphan dark pixels inside.
3. Silhouette test: black-fill version readable at 50% zoom next to its
   rivals (player vs chaser vs brute must never blur together).
4. Frame consistency: feet/head anchoring steady across frames - no bobbing
   pivot; walk cycles loop cleanly forward AND backward.
5. Scale check beside existing sprites at x3: relative sizes obey ART_SPEC
   (brute clearly larger than player; chaser smaller).
6. Export: PNG-24, strip order left-to-right = frame order, no padding.
