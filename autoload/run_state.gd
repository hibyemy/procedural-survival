extends Node
## Per-session run configuration chosen in the main menu. The menu writes it,
## the game scene reads it. seed_override of 0 means "use the default seed".

const MODE_ENDLESS := &"endless"
const MODE_STORY := &"story"

const STORY_TARGET_WAVES := 8

var mode: StringName = MODE_ENDLESS
var target_waves := 0
var seed_override := 0


func configure(run_mode: StringName, waves_target: int, custom_seed: int) -> void:
	mode = run_mode
	target_waves = waves_target
	seed_override = custom_seed


func is_story() -> bool:
	return mode == MODE_STORY


static func is_mode_story(check_mode: StringName) -> bool:
	return check_mode == MODE_STORY


func reset_to_endless() -> void:
	mode = MODE_ENDLESS
	target_waves = 0
	seed_override = 0
