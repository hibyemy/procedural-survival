extends Node
## Crossfading background music. Tracks live at
## res://assets/audio/music/<name>.ogg (see docs/audio/OST_PLAN.md); missing
## files are silently skipped. Reacts to run events automatically.

const TRACKS := {
	&"menu": "res://assets/audio/music/menu.ogg",
	&"exploration": "res://assets/audio/music/exploration.ogg",
	&"combat": "res://assets/audio/music/combat.ogg",
	&"siege": "res://assets/audio/music/siege.ogg",
	&"game_over": "res://assets/audio/music/game_over.ogg",
	&"victory": "res://assets/audio/music/victory.ogg",
}
const FADE_SECONDS := 0.8

var _players: Array[AudioStreamPlayer] = []
var _active := 0
var _current_track := &""
var _tweens: Array[Tween] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in 2:
		var player := AudioStreamPlayer.new()
		player.bus = &"Music"
		add_child(player)
		_players.append(player)
	Events.wave_started.connect(_on_wave_started)
	Events.player_died.connect(func() -> void: play_track(&"game_over"))
	Events.run_won.connect(func() -> void: play_track(&"victory"))


func play_track(track_name: StringName, fade_seconds := FADE_SECONDS) -> void:
	if track_name == _current_track or not TRACKS.has(track_name):
		return
	var path: String = TRACKS[track_name]
	if not ResourceLoader.exists(path):
		return
	_current_track = track_name
	_crossfade_to(load(path), fade_seconds)


func current_track() -> StringName:
	return _current_track


func stop_music(fade_seconds := FADE_SECONDS) -> void:
	_current_track = &""
	for i in 2:
		_fade_player(i, 0.0, fade_seconds)


func _crossfade_to(stream: AudioStream, fade_seconds: float) -> void:
	if stream is AudioStreamOggVorbis:
		stream.loop = true
	var incoming := 1 - _active
	_players[incoming].stream = stream
	_players[incoming].volume_db = -40.0
	_players[incoming].play()
	_fade_player(incoming, 0.0, fade_seconds)
	_fade_player(_active, -40.0, fade_seconds)
	if _players[_active].playing and fade_seconds > 0.0:
		get_tree().create_timer(fade_seconds + 0.1).timeout.connect(_stop_if_idle)
	_active = incoming


func _stop_if_idle() -> void:
	for player in _players:
		if player.volume_db <= -39.0:
			player.stop()


func _fade_player(index: int, target_db: float, fade_seconds: float) -> void:
	if _tweens[index] != null and _tweens[index].is_valid():
		_tweens[index].kill()
	var tween := create_tween()
	tween.tween_property(_players[index], "volume_db", target_db, maxf(fade_seconds, 0.01))
	_tweens[index] = tween


func _on_wave_started(number: int, heavy: bool) -> void:
	play_track(&"siege" if heavy else &"combat")
