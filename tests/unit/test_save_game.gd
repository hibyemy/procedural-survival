extends GutTest

const TEST_PATH := "user://test_save_progress.cfg"


func before_each() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))


func after_each() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_PATH))


func test_fresh_save_starts_at_chapter_one() -> void:
	assert_eq(SaveGame.load_unlocked_chapter(TEST_PATH), 1)
	assert_eq(SaveGame.load_best_endless_wave(TEST_PATH), 0)


func test_unlock_advances_monotonically() -> void:
	SaveGame.unlock_chapter(3, TEST_PATH)
	assert_eq(SaveGame.load_unlocked_chapter(TEST_PATH), 3)
	SaveGame.unlock_chapter(2, TEST_PATH)
	assert_eq(SaveGame.load_unlocked_chapter(TEST_PATH), 3)


func test_unlock_clamps_to_catalog_size() -> void:
	SaveGame.unlock_chapter(99, TEST_PATH)
	assert_eq(SaveGame.load_unlocked_chapter(TEST_PATH), ChapterCatalog.count())


func test_endless_best_only_grows() -> void:
	SaveGame.record_endless_wave(7, TEST_PATH)
	SaveGame.record_endless_wave(4, TEST_PATH)
	assert_eq(SaveGame.load_best_endless_wave(TEST_PATH), 7)
	SaveGame.record_endless_wave(12, TEST_PATH)
	assert_eq(SaveGame.load_best_endless_wave(TEST_PATH), 12)
