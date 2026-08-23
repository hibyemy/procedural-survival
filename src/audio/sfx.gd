extends Node
## One-shot sound effect player with a small voice pool. Effects live at
## res://assets/audio/sfx/<name>.ogg (see docs/audio/SFX_GUIDE.md); missing
## files are silently skipped.

const SFX_DIR := "res://assets/audio/sfx/"
const POOL_SIZE := 12


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func play(effect_name: StringName, volume_db: float = 0.0, pitch: float = 1.0) -> void:
	var path := SFX_DIR + String(effect_name) + ".ogg"
	if not ResourceLoader.exists(path):
		return
	var player := _acquire_player()
	player.stream = load(path)
	player.volume_db = volume_db
	player.pitch_scale = maxf(pitch, 0.05)
	player.play()


func _acquire_player() -> AudioStreamPlayer:
	for child in get_children():
		var player := child as AudioStreamPlayer
		if player != null and not player.playing:
			return player
	var player := AudioStreamPlayer.new()
	player.bus = &"SFX"
	add_child(player)
	return player
