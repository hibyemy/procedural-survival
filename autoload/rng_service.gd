extends Node
## Deterministic RNG service. ALL gameplay randomness must flow through here.
## Streams are derived from base_seed + stream name, so the same seed always
## produces identical sequences per purpose (terrain, spawns, loot...).

const DEFAULT_SEED: int = 1337

var base_seed: int = DEFAULT_SEED

var _streams: Dictionary = {}


func reset(seed_value: int = DEFAULT_SEED) -> void:
	base_seed = seed_value
	_streams.clear()


func stream(stream_name: StringName) -> RandomNumberGenerator:
	if _streams.has(stream_name):
		return _streams[stream_name]
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([base_seed, String(stream_name)])
	_streams[stream_name] = rng
	return rng


func fork(stream_name: StringName, salt: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash([base_seed, String(stream_name), salt])
	return rng
