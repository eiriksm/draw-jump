extends Node2D

## Main game scene — scrolls the world to the left and lets the player jump.

const SCROLL_SPEED := 200.0
const PLAYER_Y := 436

@onready var player: Sprite2D = $Player
@onready var background: Node2D = $Background


func _ready() -> void:
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


func _process(delta: float) -> void:
	# Scroll background layers.
	background.scroll(delta, SCROLL_SPEED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		player.jump()
	elif event is InputEventScreenTouch and event.pressed:
		player.jump()
