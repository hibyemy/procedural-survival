class_name ChapterCatalog
extends RefCounted
## Canonical definitions of all nine story chapters (see
## docs/plan/IMPLEMENTATION_PLAN.md section 4 and docs/story/STORYBOARD.md).


static func all() -> Array[ChapterConfig]:
	var chapters: Array[ChapterConfig] = []
	chapters.append(_glassfields())
	chapters.append(_switchboard_tunnels())
	chapters.append(_meridian_yards())
	chapters.append(_kill_line())
	chapters.append(_reservoir_seven())
	chapters.append(_concord_overlook())
	chapters.append(_downline_substation())
	chapters.append(_antenna_field())
	chapters.append(_lighthouse_array())
	return chapters


static func get_chapter(chapter_id: int) -> ChapterConfig:
	for config in all():
		if config.id == chapter_id:
			return config
	return all()[0]


static func count() -> int:
	return all().size()


static func _base(id: int, title: String, style_name: String) -> ChapterConfig:
	var config := ChapterConfig.new()
	config.id = id
	config.title = title
	config.style_name = style_name
	return config


static func _glassfields() -> ChapterConfig:
	var c := _base(1, "The Glassfields", "Ashfall Rust")
	c.target_waves = 8
	c.arena_size = Vector2(2000, 1200)
	c.rock_count = 10
	c.brutes_from_wave = 7
	c.protect_target = true
	c.intro_text = "Nightly drone sweeps hit the camp. The old relay shack still decodes fragments of a broadcast nobody should be able to hear. Keep it standing."
	c.outro_text = "The relay spits out a switching code - hardline only. The Switchboard tunnels it is."
	return c


static func _switchboard_tunnels() -> ChapterConfig:
	var c := _base(2, "Switchboard Tunnels", "Underground Exchange")
	c.target_waves = 10
	c.arena_size = Vector2(2304, 1440)
	c.rock_count = 16
	c.dark_cycles = true
	c.intro_text = "The Switchboard enclave kept the hardline grid alive for forty years. Down here the lights fail and the machines hunt by sound. Build for what you hear."
	c.outro_text = "Confirmed: the broadcast is real - AND being re-recorded, year after year. Someone is out there editing both sides into one message."
	return c


static func _meridian_yards() -> ChapterConfig:
	var c := _base(3, "Meridian Yards", "Assembly Funk")
	c.target_waves = 12
	c.arena_size = Vector2(2304, 1440)
	c.rock_count = 18
	c.brutes_from_wave = 3
	c.repair_kit_unlocked = true
	c.intro_text = "Meridian assembly lines never got the memo about the war ending. Siege frames walk the floors. Salvage the repair rig before you need it."
	c.outro_text = "A brute scanned you, marked you ASSET, and withdrew. The machines are talking about you now."
	return c


static func _kill_line() -> ChapterConfig:
	var c := _base(4, "The Kill Line", "Broken March")
	c.target_waves = 12
	c.arena_size = Vector2(2560, 1536)
	c.rock_count = 14
	c.skirmishers_from_wave = 4
	c.boss_id = &"crawler_titan"
	c.intro_text = "The old front line. Craters slow you down; assaults come from two edges at once. And something is walking the rails."
	c.outro_text = "The Titan folds into the bridge it was crossing. The rails are quiet for the first time since '86."
	return c


static func _reservoir_seven() -> ChapterConfig:
	var c := _base(5, "Reservoir Seven", "Hydro Static")
	c.target_waves = 12
	c.arena_size = Vector2(2304, 1440)
	c.rock_count = 12
	c.emp_pulses = true
	c.gunners_from_wave = 5
	c.intro_text = "The dam's defense grid cycles EMP pulses - your turrets will die for five seconds at a time. Walls and positioning have to carry the gap."
	c.outro_text = "Spillway overloaded. The flood takes the assault with it. Overlook arrays are silent ahead - too silent."
	return c


static func _concord_overlook() -> ChapterConfig:
	var c := _base(6, "Concord Overlook", "Radar Hymn")
	c.target_waves = 12
	c.arena_size = Vector2(2304, 1440)
	c.rock_count = 13
	c.gunners_from_wave = 1
	c.boss_id = &"aa_battery"
	c.intro_text = "An AC early-warning station, defenses intact and hostile. Gunners hold range; the nests wake as waves arrive. Silence the AA battery."
	c.outro_text = "With Overlook blind, the Switchboard triangulates the re-recorder: one substation away from the Array itself."
	return c


static func _downline_substation() -> ChapterConfig:
	var c := _base(7, "Downline Substation", "Mains Hum")
	c.target_waves = 12
	c.arena_size = Vector2(2560, 1536)
	c.rock_count = 15
	c.repair_drones_from_wave = 4
	c.intro_text = "The substation feeds the Array. Hold breaker nodes to re-light the grid - every district you take thins the spawns and the dark."
	c.outro_text = "Rolling blackouts shrink to one switching hall. Through the fence: dishes, hundreds of them, waiting."
	return c


static func _antenna_field() -> ChapterConfig:
	var c := _base(8, "Antenna Field", "Ghost Broadcast")
	c.target_waves = 13
	c.arena_size = Vector2(2816, 1728)
	c.rock_count = 16
	c.skirmishers_from_wave = 2
	c.gunners_from_wave = 5
	c.repair_drones_from_wave = 7
	c.intro_text = "A forest of dead dishes guards the fence. Custodians patrol in pairs under one rotating shield - hit whichever one steps outside."
	c.outro_text = "Fence power cut during a reload cycle. Beyond it, the towers. Sixteen minutes of fire wrote this place; tonight it answers."
	return c


static func _lighthouse_array() -> ChapterConfig:
	var c := _base(9, "Lighthouse Array", "Stand Down")
	c.target_waves = 15
	c.arena_size = Vector2(3200, 1920)
	c.rock_count = 14
	c.brutes_from_wave = 4
	c.skirmishers_from_wave = 3
	c.gunners_from_wave = 2
	c.repair_drones_from_wave = 5
	c.boss_id = &"archivist"
	c.intro_text = "THE ARCHIVIST: half AC strategist, half UMR logistics engine, convinced by forty years of contradictory orders that the war is still running. Complete the handshake. STAND DOWN."
	c.outro_text = "The handshake completes. The Archivist receives the one order it never got. Across the zone, fires light in answer."
	return c
