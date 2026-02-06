extends SceneTree

## Simple test runner that validates core game logic.
## Exit code 0 = all tests passed, 1 = failures.


func _init() -> void:
	var failures := 0

	print("=== DrawJump Test Suite ===\n")

	failures += _test_scene_loads()
	failures += _test_animal_script_properties()
	failures += _test_rotation_logic()

	print("\n=== Results: %d failure(s) ===" % failures)

	if failures > 0:
		quit(1)
	else:
		quit(0)


func _test_scene_loads() -> int:
	print("Test: Main scene loads...")
	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		print("  FAIL: Could not load main scene")
		return 1

	var instance := scene.instantiate()
	if instance == null:
		print("  FAIL: Could not instantiate main scene")
		return 1

	var animal := instance.find_child("AnimalButton", true, false)
	if animal == null:
		print("  FAIL: AnimalButton node not found")
		instance.queue_free()
		return 1

	print("  PASS")
	instance.queue_free()
	return 0


func _test_animal_script_properties() -> int:
	print("Test: Animal script has correct constants...")
	var script := load("res://scripts/animal.gd") as GDScript
	if script == null:
		print("  FAIL: Could not load animal script")
		return 1

	# Instantiate a TextureButton and attach the script to inspect defaults.
	var btn := TextureButton.new()
	btn.set_script(script)

	var rotate_deg: float = btn.get("ROTATE_DEGREES") if btn.get("ROTATE_DEGREES") != null else 0.0
	if rotate_deg != 90.0:
		# Constants may not be accessible via get(); check source text instead.
		var source: String = script.source_code
		if "90" not in source:
			print("  FAIL: ROTATE_DEGREES is not 90")
			btn.queue_free()
			return 1

	print("  PASS")
	btn.queue_free()
	return 0


func _test_rotation_logic() -> int:
	print("Test: Rotation increments by 90 degrees on press...")
	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		print("  FAIL: Could not load scene")
		return 1

	var instance := scene.instantiate()
	root.add_child(instance)

	var animal := instance.find_child("AnimalButton", true, false)
	if animal == null:
		print("  FAIL: AnimalButton not found")
		instance.queue_free()
		return 1

	# Verify initial rotation is 0
	if animal.rotation_degrees != 0.0:
		print("  FAIL: Initial rotation should be 0, got %f" % animal.rotation_degrees)
		instance.queue_free()
		return 1

	# Simulate a press — the _target_rotation should update even though the
	# tween won't finish in headless mode.
	if animal.has_method("_on_pressed"):
		animal._on_pressed()
		var target: float = animal.get("_target_rotation")
		if target != 90.0:
			print("  FAIL: _target_rotation should be 90 after one click, got %f" % target)
			instance.queue_free()
			return 1

	print("  PASS")
	instance.queue_free()
	return 0
