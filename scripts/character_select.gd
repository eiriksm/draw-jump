extends Control

## Character selection screen – lets the player pick between cat and giraffe
## then transitions to the game scene, passing the chosen character via metadata.


func _ready() -> void:
	$CatButton.pressed.connect(_on_cat_selected)
	$GiraffeButton.pressed.connect(_on_giraffe_selected)


func _on_cat_selected() -> void:
	_start_game("cat")


func _on_giraffe_selected() -> void:
	_start_game("giraffe")


func _start_game(character: String) -> void:
	# Store selection in a global autoload-free way: write to metadata on the
	# scene tree so the game scene can read it.
	get_tree().set_meta("selected_character", character)
	get_tree().change_scene_to_file("res://scenes/game.tscn")
