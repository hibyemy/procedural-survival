class_name ChapterConfig
extends Resource
## Data-driven definition of one story chapter. Built in code by
## ChapterCatalog; consumed by main, WaveDirector and the menu.

var id := 1
var title := ""
var style_name := ""
var intro_text := ""
var outro_text := ""
var target_waves := 8
var arena_size := Vector2(2000, 1200)
var rock_count := 12

# Enemy roster gates (-1 = never appears). Values are the first wave the
# type joins the composition pool.
var brutes_from_wave := -1
var skirmishers_from_wave := -1
var gunners_from_wave := -1
var repair_drones_from_wave := -1

# Chapter mechanics.
var emp_pulses := false
var dark_cycles := false
var protect_target := false

# Set-pieces: &"crawler_titan" implemented; others reserved.
var boss_id := StringName()

var repair_kit_unlocked := false


func has_boss() -> bool:
	return boss_id != StringName()
