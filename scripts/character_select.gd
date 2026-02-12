extends Control

## Character selection screen – lets the player pick between unicorn and pony
## then transitions to the game scene, passing the chosen character via metadata.


func _ready() -> void:
	%CatButton.pressed.connect(_on_unicorn_selected)
	%PonyButton.pressed.connect(_on_pony_selected)


func _on_unicorn_selected() -> void:
	_start_game("unicorn")


func _on_pony_selected() -> void:
	_start_game("pony")


func _start_game(character: String) -> void:
	# Store selection in a global autoload-free way: write to metadata on the
	# scene tree so the game scene can read it.
	get_tree().set_meta("selected_character", character)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
