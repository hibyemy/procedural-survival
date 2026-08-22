extends GutTest


func test_same_seed_produces_identical_sequence() -> void:
	var first: Array[int] = []
	var second: Array[int] = []
	RngService.reset(42)
	for i in 10:
		first.append(RngService.stream(&"terrain").randi())
	RngService.reset(42)
	for i in 10:
		second.append(RngService.stream(&"terrain").randi())
	assert_eq(first, second)


func test_stream_is_cached_by_name() -> void:
	RngService.reset(7)
	assert_same(RngService.stream(&"a"), RngService.stream(&"a"))


func test_different_streams_diverge() -> void:
	RngService.reset(42)
	var a := RngService.fork(&"x", 1).randi()
	RngService.reset(42)
	var b := RngService.fork(&"y", 1).randi()
	assert_ne(a, b)


func test_fork_is_deterministic_per_salt() -> void:
	RngService.reset(99)
	var a := RngService.fork(&"chunk", 17).randf()
	RngService.reset(99)
	var b := RngService.fork(&"chunk", 17).randf()
	assert_eq(a, b)


func test_default_seed_is_stable() -> void:
	RngService.reset()
	var expected := [RngService.stream(&"t").randi(), RngService.stream(&"t").randi()]
	RngService.reset()
	var actual := [RngService.stream(&"t").randi(), RngService.stream(&"t").randi()]
	assert_eq(actual, expected)
