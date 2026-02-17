extends Node2D

## Main game scene — scrolls the world to the left and lets the player jump.

const SCROLL_SPEED := 200.0
const PLAYER_Y := 436
const JUMPS_FOR_TREASURE := 8
const TREASURE_DELAY := 2.0

@onready var player: Sprite2D = $Player
@onready var background: Node2D = $Background
@onready var back_button: Button = %BackButton

var _jump_count := 0
var _treasure_spawned := false
var _level_ended := false
var _treasure: Node2D = null
var _level_complete_label: Label = null


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)

	var character: String = "unicorn"
	if get_tree().has_meta("selected_character"):
		character = get_tree().get_meta("selected_character")

	# Load the correct texture.
	var tex_path := "res://assets/%s.png" % character
	var tex := load(tex_path) as Texture2D
	if tex:
		player.texture = tex
		player.scale = Vector2(2.0, 2.0)

	player.character_type = character
	player.position = Vector2(150, PLAYER_Y)
	player.ground_y = PLAYER_Y
	player.jumped.connect(_on_player_jumped)


func _process(delta: float) -> void:
	if _level_ended:
		return

	# Scroll background layers.
	background.scroll(delta, SCROLL_SPEED)

	# Check if the player has reached the treasure.
	if _treasure and _treasure.check_collected(player.position.x):
		_end_level()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/character_select.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if _level_ended:
		return
	if event is InputEventMouseButton and event.pressed:
		player.jump()
	elif event is InputEventScreenTouch and event.pressed:
		player.jump()


func _on_player_jumped() -> void:
	_jump_count += 1
	if _jump_count == JUMPS_FOR_TREASURE and not _treasure_spawned:
		_treasure_spawned = true
		_start_treasure_timer()


func _start_treasure_timer() -> void:
	var timer := get_tree().create_timer(TREASURE_DELAY)
	timer.timeout.connect(_spawn_treasure)


func _spawn_treasure() -> void:
	var treasure_script := load("res://scripts/treasure.gd") as GDScript
	_treasure = Node2D.new()
	_treasure.set_script(treasure_script)
	_treasure.position = Vector2(900, PLAYER_Y)
	_treasure.scroll_speed = SCROLL_SPEED
	add_child(_treasure)


func _end_level() -> void:
	_level_ended = true
	if _treasure:
		_treasure.queue_free()
		_treasure = null

	# Show "Level Complete!" message.
	_level_complete_label = Label.new()
	_level_complete_label.text = "Level Complete!"
	_level_complete_label.add_theme_font_size_override("font_size", 48)
	_level_complete_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_level_complete_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_level_complete_label.set_anchors_preset(Control.PRESET_CENTER)
	_level_complete_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_level_complete_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	%BackButton.get_parent().add_child(_level_complete_label)

	# Return to character select after a short pause.
	var timer := get_tree().create_timer(3.0)
	timer.timeout.connect(_on_back_pressed)
