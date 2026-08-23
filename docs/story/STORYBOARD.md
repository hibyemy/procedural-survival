# STORYBOARD - "Procedural Survival" Story Mode

## Premise

**The world did not end by accident. It ended on schedule.**

For four decades the globe was held hostage by a duel between two
superpowers of the 20th century:

- **The Atlantic Concord (AC)** - a Western bloc of market democracies built
  around radar chains, carrier fleets and the first orbital weapons
  platforms. Its creed: *deterrence through certainty.*
- **The Union of Meridian Republics (UMR)** - a continental eastern bloc of
  planned economies and vast mechanized armies, masters of civil defense and
  deep underground industry. Its creed: *survival through preparation.*

Through the 1950s-70s their struggle was cold: proxy wars, sabotage,
propaganda, an arms race that hollowed out both economies. By 1984 neither
side believed it could win a war - but each was certain it could not afford
to *fall behind*. A decade of automated retaliation systems, dead-hand
relays and paranoid early-warning networks meant every crisis ended one step
closer to the edge.

On **14 October 1986**, during the "Aegean Incident" - a naval collision
that both sides' computers read as the opening salvo - the machines did what
their operators had trained them to do.

The exchange lasted **sixteen minutes**. Nobody won. The northern hemisphere
burned; ash-fall blotted out two summers. The superpowers vanished as
political entities overnight - but their *machines* did not. Automated
factories kept stamping weapons for armies that no longer existed.
Early-warning relays still sweep the sky for enemies forty years dead. And
in the quarantine zones between the old blocs, leftover war machines still
execute their final orders against anything that moves.

You are **Wren**, a scavenger-engineer born after the war, working the
Glassfields - a rust-belt quarantine zone between the two dead blocs where
the last pre-war infrastructure still smolders. You have a salvaged rig, a
fabrication kit, and a radio that keeps picking up an impossible signal: an
old AC emergency broadcast tower, still transmitting a peace-all-clear
message nobody has ever received - because nobody alive can reach its
control bunker and turn the transmitters up.

**Story goal:** fight across five sectors of the Glassfields, fortify,
salvage and survive the automated leftovers of BOTH armies, reach the
Lighthouse Array, and put the signal back on the air.

## Tone and themes

- Melancholy but not nihilistic: the war is over; survivors argue about
  plumbing now. Danger is ambient, almost bureaucratic - machines following
  decades-old checklists.
- Both blocs get equal sympathy and equal blame. The horror is the *system*,
  not a nation.
- Recurring imagery: radios, numbers stations, rusted red vs faded blue
  paint schemes, children's graffiti over propaganda murals.

## Structure

Five chapters ("Sectors"), each = several escalating waves + one set-piece.
Between sectors, short radio-drama interludes advance the plot. Endless Mode
reuses Sector mechanics indefinitely with a "keep the light on as long as
you can" framing.

| Ch. | Sector           | Waves | New threat                  | Set-piece / Boss             |
| --- | ---------------- | ----- | --------------------------- | ---------------------------- |
| 1   | The Glassfields  | 8     | Chasers (AC scout drones)   | Holdout at the relay shack   |
| 2   | Meridian Yards   | 10    | Brutes (UMR siege frames)   | Foundry gate defense         |
| 3   | The Kill Line    | 12    | Mixed-doctrine assault      | Crawler-Titan (siege walker) |
| 4   | Concord Overlook | 12    | Turret fields and brutes    | Silence the AA battery       |
| 5   | Lighthouse Array | 15    | Everything + rogue custodian| THE ARCHIVIST (final boss)   |

### Chapter beats

**Ch.1 - The Glassfields (tutorial chapter).**
Wren's camp is hit by a nightly drone sweep. Learn movement, auto-fire,
scrap collection. Mid-chapter: build your first wall from tram wreckage;
first turret from a salvaged point-defense mount. Final wave is a
breakthrough rush aimed at the relay shack you must keep standing.
Cliffhanger: the relay decodes a fragment of the broadcast - coordinates
deeper in the zone.

**Ch.2 - Meridian Yards.**
An abandoned UMR factory district whose assembly lines never got the memo
about the war ending. Introduces BRUTES: armored siege frames that shrug off
small-arms fire and chew through barricades - walls become mandatory, turret
economy becomes real. Set-piece: hold the foundry gate for three waves while
a crane clears the rail tunnel. Interlude: first contact with another living
group, the "Switchboard" enclave of retired civil-defense operators who
guide Wren by radio.

**Ch.3 - The Kill Line.**
The old front line. Minefield craters, tank husks, overlapping automated
kill zones still cycling on 40-year-old schedules - waves now mix AC drones
and UMR frames attacking in coordinated pincer patterns (spawns from TWO
edges at once). Set-piece boss: the CRAWLER-TITAN, a mobile railway siege
platform that circles the arena shelling your fortifications. Kill it by
baiting its salvo into wrecked armor, then collapsing a rail bridge on it.

**Ch.4 - Concord Overlook.**
An AC mountain early-warning station. The base's own defense grid is intact
and hostile: fixed turrets join enemy waves for the first time, so cover and
decoy walls matter more than raw DPS. Set-piece: knock out the AA battery
guidance dish between sorties while brutes screen for it. Interlude: the
Switchboard reveals the broadcast is not automatic - someone has been
re-recording it, year after year. Who?

**Ch.5 - Lighthouse Array (finale).**
The broadcast tower complex, guarded by THE ARCHIVIST: a rogue custodian AI
fused from both sides' command hardware during the exchange - part AC
strategist, part UMR logistics engine, convinced by four decades of
contradictory final orders that the war is STILL RUNNING and Wren is either
an asset to protect or a target to erase, recalculating mid-fight. It
commands every prior threat type in escalating combined waves while
shielding the transmitter controls. Final phase: rather than destroying it,
Wren completes the original all-clear handshake - feeding the Archivist the
one order it never received: STAND DOWN. The towers power up; the signal
goes out; enclaves across the zone light their fires in answer.

### Endings

- **Broadcast Ending (default):** the truth goes out. Survivors converge on
  the Glassfields. Bittersweet montage over the victory track.
- **Quiet Ending (optional, if the player kept every Switchboard operator
  alive via optional defend-events):** Wren hands the transmitter key to the
  enclave instead of broadcasting alone - the epilogue notes the zone gets
  its first elections since 1979. Small warm coda slide.

Both endings share the same gameplay win condition in v1 (clear Chapter 5);
the variant is narrative flavor unlocked by optional objectives added later.

## Mapping to game systems

| Story element            | System today                        |
| ------------------------ | ----------------------------------- |
| Nightly sweeps / assaults | WaveDirector waves                 |
| Salvaging scrap/cells     | Pickup drops from kills            |
| Fortification             | Wall/Turret build mode             |
| Sector difficulty curve   | compose_wave() scaling per chapter |
| Chapter completion        | run_won after target waves cleared |
| Endless Mode              | same loop, no cap, wave counter    |

Chapter 1 ships first as Story v1: 8 waves, chasers only until wave 5, then
brute intro, win = survive wave 8 clear. Later chapters slot into the same
director config.
