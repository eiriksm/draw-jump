extends TextureButton

## Rotation amount in degrees per click.
const ROTATE_DEGREES := 90.0

## Duration of the rotation tween in seconds.
const TWEEN_DURATION := 0.3

var _target_rotation := 0.0
var _is_rotating := false


func _ready() -> void:
	pivot_offset = size / 2.0
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	if _is_rotating:
		return
	_is_rotating = true
	_target_rotation += ROTATE_DEGREES

	var tween := create_tween()
	tween.tween_property(self, "rotation_degrees", _target_rotation, TWEEN_DURATION)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
	tween.finished.connect(_on_tween_finished)


func _on_tween_finished() -> void:
	_is_rotating = false
