extends Sprite2D

## Player character that sits on the ground and jumps when the screen is clicked.
## Jump height depends on the selected character (giraffe jumps higher).

const GRAVITY := 1200.0

## Jump impulse per character type (pixels/sec upward).
const JUMP_VELOCITY := {
	"cat": -450.0,
	"giraffe": -620.0,
}

var velocity_y := 0.0
var ground_y := 0.0
var character_type := "cat"
var _is_on_ground := true


func _ready() -> void:
	ground_y = position.y


func _process(delta: float) -> void:
	if not _is_on_ground:
		velocity_y += GRAVITY * delta
		position.y += velocity_y * delta

		if position.y >= ground_y:
			position.y = ground_y
			velocity_y = 0.0
			_is_on_ground = true


func jump() -> void:
	if not _is_on_ground:
		return
	_is_on_ground = false
	velocity_y = JUMP_VELOCITY.get(character_type, JUMP_VELOCITY["cat"])
