extends Node
## Per-session run configuration chosen in the main menu. The menu writes it,
## the game scene reads it. seed_override of 0 means "use the default seed".

const MODE_ENDLESS := &"endless"
const MODE_STORY := &"story"

var mode: StringName = MODE_ENDLESS
var chapter := 1
var seed_override := 0


func configure(run_mode: StringName, run_chapter: int, custom_seed: int) -> void:
	mode = run_mode
	chapter = maxi(run_chapter, 1)
	seed_override = custom_seed


func configure_endless(custom_seed: int = 0) -> void:
	configure(MODE_ENDLESS, 1, custom_seed)


func configure_story(run_chapter: int, custom_seed: int = 0) -> void:
	configure(MODE_STORY, run_chapter, custom_seed)


func is_story() -> bool:
	return mode == MODE_STORY


static func is_mode_story(check_mode: StringName) -> bool:
	return check_mode == MODE_STORY


func reset_to_endless() -> void:
	configure_endless(0)
