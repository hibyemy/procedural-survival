class_name SaveGame
extends RefCounted
## Persistent campaign progress: highest unlocked chapter + endless best.

const SAVE_PATH := "user://save.cfg"


static func load_unlocked_chapter(path: String = SAVE_PATH) -> int:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return 1
	return clampi(int(config.get_value("progress", "unlocked_chapter", 1)), 1, ChapterCatalog.count())


static func unlock_chapter(chapter_id: int, path: String = SAVE_PATH) -> void:
	if chapter_id <= load_unlocked_chapter(path):
		return
	var config := ConfigFile.new()
	config.load(path)
	config.set_value("progress", "unlocked_chapter", clampi(chapter_id, 1, ChapterCatalog.count()))
	config.save(path)


static func load_best_endless_wave(path: String = SAVE_PATH) -> int:
	var config := ConfigFile.new()
	if config.load(path) != OK:
		return 0
	return maxi(int(config.get_value("progress", "best_endless_wave", 0)), 0)


static func record_endless_wave(wave_number: int, path: String = SAVE_PATH) -> void:
	if wave_number <= load_best_endless_wave(path):
		return
	var config := ConfigFile.new()
	config.load(path)
	config.set_value("progress", "best_endless_wave", wave_number)
	config.save(path)
