extends Sprite2D

## Player character that sits on the ground and jumps when the screen is clicked.
## Jump height depends on the selected character (pony jumps higher).
## Clicking while in the air triggers a fart that gives a small upward boost.

const GRAVITY := 1200.0

## Jump impulse per character type (pixels/sec upward).
const JUMP_VELOCITY := {
	"unicorn": -450.0,
	"pony": -620.0,
}

## Fart boost velocity when clicking in the air (one per jump).
const FART_VELOCITY := -250.0

var velocity_y := 0.0
var ground_y := 0.0
var character_type := "unicorn"
var _is_on_ground := true
var _jump_elapsed := 0.0
var _jump_duration := 0.0
var _has_farted := false
var _fart_clouds := []


func _ready() -> void:
	ground_y = position.y


func _process(delta: float) -> void:
	if not _is_on_ground:
		velocity_y += GRAVITY * delta
		position.y += velocity_y * delta

		# Unicorn does a front flip during the jump.
		if character_type == "unicorn" and _jump_duration > 0.0:
			_jump_elapsed += delta
			var progress := clampf(_jump_elapsed / _jump_duration, 0.0, 1.0)
			rotation = progress * TAU

		if position.y >= ground_y:
			position.y = ground_y
			velocity_y = 0.0
			_is_on_ground = true
			rotation = 0.0
			_has_farted = false

	# Animate fart clouds.
	var had_clouds := _fart_clouds.size() > 0
	var i := _fart_clouds.size() - 1
	while i >= 0:
		_fart_clouds[i]["elapsed"] += delta
		if _fart_clouds[i]["elapsed"] >= _fart_clouds[i]["duration"]:
			_fart_clouds.remove_at(i)
		i -= 1
	if had_clouds:
		queue_redraw()


func _draw() -> void:
	for cloud in _fart_clouds:
		var t: float = cloud["elapsed"] / cloud["duration"]
		var alpha: float = 0.6 * (1.0 - t)
		var radius: float = 8.0 + 20.0 * t
		var color := Color(0.45, 0.55, 0.2, alpha)
		# Draw cloud below the character in local space.
		draw_circle(Vector2(-5.0, 15.0), radius, color)
		draw_circle(Vector2(5.0, 18.0), radius * 0.8, color)
		draw_circle(Vector2(-8.0, 20.0), radius * 0.6, color)


func jump() -> void:
	if not _is_on_ground:
		fart()
		return
	_is_on_ground = false
	velocity_y = JUMP_VELOCITY.get(character_type, JUMP_VELOCITY["unicorn"])
	if character_type == "unicorn":
		_jump_elapsed = 0.0
		_jump_duration = 2.0 * absf(velocity_y) / GRAVITY


func fart() -> void:
	if _has_farted:
		return
	_has_farted = true
	velocity_y = FART_VELOCITY
	_fart_clouds.append({"elapsed": 0.0, "duration": 0.5})
	queue_redraw()
