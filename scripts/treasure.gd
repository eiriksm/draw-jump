extends Node2D

## A treasure chest that scrolls left with the world.
## When the player reaches it, the level ends.

signal collected

const CHEST_COLOR := Color(0.8, 0.6, 0.1)
const CHEST_DARK := Color(0.6, 0.4, 0.05)
const CHEST_LID := Color(0.9, 0.7, 0.15)
const GOLD_COLOR := Color(1.0, 0.85, 0.2)
const SPARKLE_COLOR := Color(1.0, 1.0, 0.6)

var scroll_speed := 200.0
var _sparkle_time := 0.0


func _process(delta: float) -> void:
	position.x -= scroll_speed * delta
	_sparkle_time += delta
	queue_redraw()


func _draw() -> void:
	# Chest body.
	draw_rect(Rect2(-20, -20, 40, 24), CHEST_COLOR, true)
	# Chest dark band.
	draw_rect(Rect2(-20, -10, 40, 4), CHEST_DARK, true)
	# Chest lid (slightly wider, on top).
	draw_rect(Rect2(-22, -30, 44, 12), CHEST_LID, true)
	# Gold coins peeking out.
	draw_circle(Vector2(-6, -24), 5.0, GOLD_COLOR)
	draw_circle(Vector2(6, -26), 5.0, GOLD_COLOR)
	draw_circle(Vector2(0, -28), 5.0, GOLD_COLOR)

	# Sparkle effect.
	var sparkle_alpha := 0.5 + 0.5 * sin(_sparkle_time * 4.0)
	var sparkle := SPARKLE_COLOR
	sparkle.a = sparkle_alpha
	for offset in [Vector2(-12, -40), Vector2(14, -38), Vector2(0, -46)]:
		_draw_sparkle(offset, 4.0, sparkle)


func _draw_sparkle(pos: Vector2, size: float, color: Color) -> void:
	draw_line(pos + Vector2(-size, 0), pos + Vector2(size, 0), color, 2.0)
	draw_line(pos + Vector2(0, -size), pos + Vector2(0, size), color, 2.0)


func check_collected(player_x: float) -> bool:
	if abs(position.x - player_x) < 40.0:
		collected.emit()
		return true
	return false
