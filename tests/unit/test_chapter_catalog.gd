extends GutTest

func test_catalog_defines_nine_unique_chapters() -> void:
	var chapters := ChapterCatalog.all()
	assert_eq(chapters.size(), 9)
	var titles := {}
	for i in chapters.size():
		assert_eq(chapters[i].id, i + 1)
		assert_gt(chapters[i].title.length(), 0)
		assert_gt(chapters[i].intro_text.length(), 0)
		assert_gt(chapters[i].outro_text.length(), 0)
		titles[chapters[i].title] = true
	assert_eq(titles.size(), 9)


func test_chapter_one_is_the_tutorial_with_relay() -> void:
	var c := ChapterCatalog.get_chapter(1)
	assert_true(c.protect_target)
	assert_false(c.has_boss())
	assert_eq(c.target_waves, 8)
	assert_false(c.repair_kit_unlocked)


func test_mechanic_flags_land_on_the_right_chapters() -> void:
	assert_true(ChapterCatalog.get_chapter(2).dark_cycles)
	assert_true(ChapterCatalog.get_chapter(3).repair_kit_unlocked)
	assert_true(ChapterCatalog.get_chapter(5).emp_pulses)
	assert_false(ChapterCatalog.get_chapter(4).emp_pulses)
	assert_false(ChapterCatalog.get_chapter(6).dark_cycles)


func test_boss_assignments() -> void:
	assert_eq(ChapterCatalog.get_chapter(4).boss_id, StringName("crawler_titan"))
	assert_eq(ChapterCatalog.get_chapter(9).boss_id, StringName("archivist"))
	assert_eq(ChapterCatalog.get_chapter(2).boss_id, StringName())


func test_roster_gates_follow_the_storyboard() -> void:
	var ch3 := ChapterCatalog.get_chapter(3)
	assert_eq(ch3.brutes_from_wave, 3)
	var ch4 := ChapterCatalog.get_chapter(4)
	assert_eq(ch4.skirmishers_from_wave, 4)
	var ch5 := ChapterCatalog.get_chapter(5)
	assert_eq(ch5.gunners_from_wave, 5)
	var ch7 := ChapterCatalog.get_chapter(7)
	assert_eq(ch7.repair_drones_from_wave, 4)


func test_wave_targets_match_storyboard() -> void:
	var expected := [8, 10, 12, 12, 12, 12, 12, 13, 15]
	for i in expected.size():
		assert_eq(ChapterCatalog.get_chapter(i + 1).target_waves, expected[i], "chapter %d" % (i + 1))


func test_get_chapter_falls_back_to_first() -> void:
	assert_eq(ChapterCatalog.get_chapter(999).id, 1)
