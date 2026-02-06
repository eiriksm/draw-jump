extends SceneTree

## Simple test runner that validates core game logic without loading scenes
## that contain imported resources (textures), which segfault in headless CI.
## Exit code 0 = all tests passed, 1 = failures.


func _init() -> void:
	var failures := 0

	print("=== DrawJump Test Suite ===\n")

	failures += _test_script_loads()
	failures += _test_rotation_constants()
	failures += _test_rotation_logic()
	failures += _test_multiple_rotations()
	failures += _test_scene_file_parseable()

	print("\n=== Results: %d failure(s) ===" % failures)

	if failures > 0:
		quit(1)
	else:
		quit(0)


func _test_script_loads() -> int:
	print("Test: Animal script loads...")
	var script := load("res://scripts/animal.gd") as GDScript
	if script == null:
		print("  FAIL: Could not load animal.gd")
		return 1
	print("  PASS")
	return 0


func _test_rotation_constants() -> int:
	print("Test: Script has correct rotation constant...")
	var script := load("res://scripts/animal.gd") as GDScript
	if script == null:
		print("  FAIL: Could not load script")
		return 1

	var source: String = script.source_code
	if "ROTATE_DEGREES" not in source:
		print("  FAIL: ROTATE_DEGREES constant not found")
		return 1
	if "90.0" not in source and "90" not in source:
		print("  FAIL: Rotation not set to 90 degrees")
		return 1

	print("  PASS")
	return 0


func _test_rotation_logic() -> int:
	print("Test: Rotation increments by 90 degrees on press...")

	# Build a TextureButton with the script attached — no texture needed.
	var script := load("res://scripts/animal.gd") as GDScript
	if script == null:
		print("  FAIL: Could not load script")
		return 1

	var btn := TextureButton.new()
	btn.size = Vector2(128, 128)
	btn.set_script(script)
	root.add_child(btn)

	# _ready() will have run, connecting signals and setting pivot.
	# Verify initial state.
	if btn.rotation_degrees != 0.0:
		print("  FAIL: Initial rotation should be 0, got %f" % btn.rotation_degrees)
		btn.queue_free()
		return 1

	# Call _on_pressed directly to simulate a click.
	btn._on_pressed()
	var target: float = btn._target_rotation
	if target != 90.0:
		print("  FAIL: _target_rotation should be 90 after first click, got %f" % target)
		btn.queue_free()
		return 1

	print("  PASS")
	btn.queue_free()
	return 0


func _test_multiple_rotations() -> int:
	print("Test: Multiple rotations accumulate correctly...")

	var script := load("res://scripts/animal.gd") as GDScript
	if script == null:
		print("  FAIL: Could not load script")
		return 1

	var btn := TextureButton.new()
	btn.size = Vector2(128, 128)
	btn.set_script(script)
	root.add_child(btn)

	# First click
	btn._on_pressed()
	if btn._target_rotation != 90.0:
		print("  FAIL: Expected 90 after first click, got %f" % btn._target_rotation)
		btn.queue_free()
		return 1

	# _is_rotating is true, so a second call should be ignored.
	btn._on_pressed()
	if btn._target_rotation != 90.0:
		print("  FAIL: Should still be 90 while rotating, got %f" % btn._target_rotation)
		btn.queue_free()
		return 1

	# Simulate tween finishing, then click again.
	btn._is_rotating = false
	btn._on_pressed()
	if btn._target_rotation != 180.0:
		print("  FAIL: Expected 180 after second real click, got %f" % btn._target_rotation)
		btn.queue_free()
		return 1

	print("  PASS")
	btn.queue_free()
	return 0


func _test_scene_file_parseable() -> int:
	print("Test: Scene file exists and references script...")

	# Read the scene file as text to verify structure without triggering
	# resource loading (which would try to import the SVG texture).
	var file := FileAccess.open("res://scenes/main.tscn", FileAccess.READ)
	if file == null:
		print("  FAIL: Could not open main.tscn")
		return 1

	var content := file.get_as_text()
	file.close()

	if "animal.gd" not in content:
		print("  FAIL: Scene does not reference animal.gd")
		return 1

	if "AnimalButton" not in content:
		print("  FAIL: Scene does not contain AnimalButton node")
		return 1

	if "TextureButton" not in content:
		print("  FAIL: Scene does not use TextureButton type")
		return 1

	print("  PASS")
	return 0
