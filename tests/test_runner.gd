extends SceneTree

## Test runner that validates core game logic without loading scenes
## that contain imported resources (textures), which segfault in headless CI.
## Exit code 0 = all tests passed, 1 = failures.


func _init() -> void:
	var failures := 0

	print("=== DrawJump Test Suite ===\n")

	failures += _test_player_script_loads()
	failures += _test_game_script_loads()
	failures += _test_character_select_script_loads()
	failures += _test_background_script_loads()
	failures += _test_jump_velocity_constants()
	failures += _test_gravity_constant()
	failures += _test_fart_velocity_constant()
	failures += _test_jump_sets_velocity()
	failures += _test_pony_jumps_higher()
	failures += _test_fart_when_clicking_in_air()
	failures += _test_single_fart_per_jump()
	failures += _test_fart_resets_on_landing()
	failures += _test_landing_resets_state()
	failures += _test_unicorn_front_flip()
	failures += _test_pony_no_front_flip()
	failures += _test_character_select_scene_parseable()
	failures += _test_game_scene_parseable()
	failures += _test_project_main_scene()

	print("\n=== Results: %d failure(s) ===" % failures)

	if failures > 0:
		quit(1)
	else:
		quit(0)


# ---- Script loading tests ----

func _test_player_script_loads() -> int:
	print("Test: Player script loads...")
	var script := load("res://scripts/player.gd") as GDScript
	if script == null:
		print("  FAIL: Could not load player.gd")
		return 1
	print("  PASS")
	return 0


func _test_game_script_loads() -> int:
	print("Test: Game script loads...")
	var script := load("res://scripts/game.gd") as GDScript
	if script == null:
		print("  FAIL: Could not load game.gd")
		return 1
	print("  PASS")
	return 0


func _test_character_select_script_loads() -> int:
	print("Test: Character select script loads...")
	var script := load("res://scripts/character_select.gd") as GDScript
	if script == null:
		print("  FAIL: Could not load character_select.gd")
		return 1
	print("  PASS")
	return 0


func _test_background_script_loads() -> int:
	print("Test: Background script loads...")
	var script := load("res://scripts/background.gd") as GDScript
	if script == null:
		print("  FAIL: Could not load background.gd")
		return 1
	print("  PASS")
	return 0


# ---- Player constant tests ----

func _test_jump_velocity_constants() -> int:
	print("Test: Player has correct jump velocity constants...")
	var script := load("res://scripts/player.gd") as GDScript
	if script == null:
		print("  FAIL: Could not load script")
		return 1

	var source: String = script.source_code
	if "JUMP_VELOCITY" not in source:
		print("  FAIL: JUMP_VELOCITY constant not found")
		return 1
	if "unicorn" not in source or "pony" not in source:
		print("  FAIL: Expected both unicorn and pony entries in JUMP_VELOCITY")
		return 1
	print("  PASS")
	return 0


func _test_gravity_constant() -> int:
	print("Test: Player has GRAVITY constant...")
	var script := load("res://scripts/player.gd") as GDScript
	if script == null:
		print("  FAIL: Could not load script")
		return 1

	var source: String = script.source_code
	if "GRAVITY" not in source:
		print("  FAIL: GRAVITY constant not found")
		return 1
	print("  PASS")
	return 0


func _test_fart_velocity_constant() -> int:
	print("Test: Player has FART_VELOCITY constant...")
	var script := load("res://scripts/player.gd") as GDScript
	if script == null:
		print("  FAIL: Could not load script")
		return 1

	var source: String = script.source_code
	if "FART_VELOCITY" not in source:
		print("  FAIL: FART_VELOCITY constant not found")
		return 1
	print("  PASS")
	return 0


# ---- Player jump logic tests ----

func _test_jump_sets_velocity() -> int:
	print("Test: Jumping sets upward velocity...")
	var player := _make_player("unicorn")
	if player == null:
		return 1

	player.jump()
	if player.velocity_y >= 0.0:
		print("  FAIL: velocity_y should be negative after jump, got %f" % player.velocity_y)
		player.queue_free()
		return 1
	if player._is_on_ground:
		print("  FAIL: _is_on_ground should be false after jump")
		player.queue_free()
		return 1

	print("  PASS")
	player.queue_free()
	return 0


func _test_pony_jumps_higher() -> int:
	print("Test: Pony jumps higher than unicorn...")
	var unicorn := _make_player("unicorn")
	var pony := _make_player("pony")
	if unicorn == null or pony == null:
		return 1

	unicorn.jump()
	pony.jump()

	# More negative velocity = higher jump.
	if pony.velocity_y >= unicorn.velocity_y:
		print("  FAIL: Pony velocity (%f) should be more negative than unicorn (%f)" % [pony.velocity_y, unicorn.velocity_y])
		unicorn.queue_free()
		pony.queue_free()
		return 1

	print("  PASS")
	unicorn.queue_free()
	pony.queue_free()
	return 0


# ---- Fart mechanic tests ----

func _test_fart_when_clicking_in_air() -> int:
	print("Test: Clicking in the air triggers a fart boost...")
	var player := _make_player("unicorn")
	if player == null:
		return 1

	player.jump()

	# Simulate a few frames so gravity slows the upward velocity.
	for i in range(10):
		player._process(0.016)

	var pre_fart_velocity: float = player.velocity_y

	# Click again while in air — should fart.
	player.jump()

	if player.velocity_y >= pre_fart_velocity:
		print("  FAIL: Fart should give upward boost, velocity was %f, now %f" % [pre_fart_velocity, player.velocity_y])
		player.queue_free()
		return 1

	if player.velocity_y >= 0.0:
		print("  FAIL: Fart velocity should be negative (upward), got %f" % player.velocity_y)
		player.queue_free()
		return 1

	print("  PASS")
	player.queue_free()
	return 0


func _test_single_fart_per_jump() -> int:
	print("Test: Can only fart once per jump...")
	var player := _make_player("unicorn")
	if player == null:
		return 1

	player.jump()

	# Simulate a few frames.
	for i in range(10):
		player._process(0.016)

	# First fart.
	player.jump()

	# Simulate a few more frames so gravity changes velocity.
	for i in range(5):
		player._process(0.016)

	var pre_second_fart_velocity: float = player.velocity_y

	# Try to fart again — should be ignored.
	player.jump()

	if player.velocity_y != pre_second_fart_velocity:
		print("  FAIL: Second fart should be ignored, velocity changed from %f to %f" % [pre_second_fart_velocity, player.velocity_y])
		player.queue_free()
		return 1

	print("  PASS")
	player.queue_free()
	return 0


func _test_fart_resets_on_landing() -> int:
	print("Test: Fart ability resets after landing...")
	var player := _make_player("unicorn")
	if player == null:
		return 1

	player.jump()

	# Simulate a few frames, then fart.
	for i in range(10):
		player._process(0.016)
	player.jump()  # Fart

	# Let the player land.
	for i in range(200):
		player._process(0.016)
		if player._is_on_ground:
			break

	if not player._is_on_ground:
		print("  FAIL: Player did not land")
		player.queue_free()
		return 1

	# Jump again and verify we can fart again.
	player.jump()
	for i in range(10):
		player._process(0.016)

	var pre_fart_velocity: float = player.velocity_y

	player.jump()  # Should fart again

	if player.velocity_y >= pre_fart_velocity:
		print("  FAIL: Should be able to fart again after landing, velocity unchanged")
		player.queue_free()
		return 1

	print("  PASS")
	player.queue_free()
	return 0


func _test_landing_resets_state() -> int:
	print("Test: Landing resets player to ground state...")
	var player := _make_player("unicorn")
	if player == null:
		return 1

	player.jump()

	# Simulate enough time for the player to fall back down.
	# With GRAVITY=1200 and initial velocity around -450,
	# it takes about 0.75s to return to ground. Simulate in steps.
	for i in range(100):
		player._process(0.016)  # ~60fps steps
		if player._is_on_ground:
			break

	if not player._is_on_ground:
		print("  FAIL: Player did not land after simulated frames")
		player.queue_free()
		return 1

	if player.velocity_y != 0.0:
		print("  FAIL: velocity_y should be 0 after landing, got %f" % player.velocity_y)
		player.queue_free()
		return 1

	if player.position.y != player.ground_y:
		print("  FAIL: Player y should equal ground_y after landing")
		player.queue_free()
		return 1

	print("  PASS")
	player.queue_free()
	return 0


# ---- Front flip tests ----

func _test_unicorn_front_flip() -> int:
	print("Test: Unicorn rotates during jump (front flip)...")
	var player := _make_player("unicorn")
	if player == null:
		return 1

	player.jump()

	# Simulate a few frames so the unicorn is mid-air.
	for i in range(10):
		player._process(0.016)

	if player.rotation == 0.0:
		print("  FAIL: Unicorn rotation should be non-zero mid-jump, got %f" % player.rotation)
		player.queue_free()
		return 1

	# Let the jump finish.
	for i in range(100):
		player._process(0.016)
		if player._is_on_ground:
			break

	if player.rotation != 0.0:
		print("  FAIL: Unicorn rotation should be 0 after landing, got %f" % player.rotation)
		player.queue_free()
		return 1

	print("  PASS")
	player.queue_free()
	return 0


func _test_pony_no_front_flip() -> int:
	print("Test: Pony does not rotate during jump...")
	var player := _make_player("pony")
	if player == null:
		return 1

	player.jump()

	# Simulate a few frames so the pony is mid-air.
	for i in range(10):
		player._process(0.016)

	if player.rotation != 0.0:
		print("  FAIL: Pony rotation should remain 0, got %f" % player.rotation)
		player.queue_free()
		return 1

	print("  PASS")
	player.queue_free()
	return 0


# ---- Scene file tests ----

func _test_character_select_scene_parseable() -> int:
	print("Test: Character select scene file exists and is valid...")

	var file := FileAccess.open("res://scenes/character_select.tscn", FileAccess.READ)
	if file == null:
		print("  FAIL: Could not open character_select.tscn")
		return 1

	var content := file.get_as_text()
	file.close()

	if "character_select.gd" not in content:
		print("  FAIL: Scene does not reference character_select.gd")
		return 1
	if "CatButton" not in content:
		print("  FAIL: Scene does not contain CatButton")
		return 1
	if "PonyButton" not in content:
		print("  FAIL: Scene does not contain PonyButton")
		return 1
	if "unicorn.png" not in content:
		print("  FAIL: Scene does not reference unicorn.png")
		return 1
	if "pony.png" not in content:
		print("  FAIL: Scene does not reference pony.png")
		return 1

	print("  PASS")
	return 0


func _test_game_scene_parseable() -> int:
	print("Test: Game scene file exists and is valid...")

	var file := FileAccess.open("res://scenes/game.tscn", FileAccess.READ)
	if file == null:
		print("  FAIL: Could not open game.tscn")
		return 1

	var content := file.get_as_text()
	file.close()

	if "game.gd" not in content:
		print("  FAIL: Scene does not reference game.gd")
		return 1
	if "player.gd" not in content:
		print("  FAIL: Scene does not reference player.gd")
		return 1
	if "background.gd" not in content:
		print("  FAIL: Scene does not reference background.gd")
		return 1
	if "Player" not in content:
		print("  FAIL: Scene does not contain Player node")
		return 1
	if "Background" not in content:
		print("  FAIL: Scene does not contain Background node")
		return 1

	print("  PASS")
	return 0


func _test_project_main_scene() -> int:
	print("Test: Project main scene points to character select...")

	var file := FileAccess.open("res://project.godot", FileAccess.READ)
	if file == null:
		print("  FAIL: Could not open project.godot")
		return 1

	var content := file.get_as_text()
	file.close()

	if "character_select.tscn" not in content:
		print("  FAIL: Main scene is not character_select.tscn")
		return 1

	print("  PASS")
	return 0


# ---- Helpers ----

func _make_player(character: String) -> Sprite2D:
	var script := load("res://scripts/player.gd") as GDScript
	if script == null:
		print("  FAIL: Could not load player.gd")
		return null

	var sprite := Sprite2D.new()
	sprite.set_script(script)
	sprite.position = Vector2(150, 500)
	root.add_child(sprite)

	# _ready() has run — set character type and ground_y.
	sprite.character_type = character
	sprite.ground_y = 500.0

	return sprite
