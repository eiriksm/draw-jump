extends Node2D

## Procedural scrolling background with parallax layers.
## Draws sky, clouds, hills, and ground that continuously scroll left.

# ---------- tunables ----------
const CLOUD_COLOR := Color(1, 1, 1, 0.6)
const SKY_TOP := Color(0.35, 0.6, 0.85)
const SKY_BOTTOM := Color(0.65, 0.82, 0.95)
const HILL_FAR_COLOR := Color(0.45, 0.7, 0.45)
const HILL_NEAR_COLOR := Color(0.3, 0.6, 0.3)
const GROUND_COLOR := Color(0.55, 0.75, 0.35)
const GROUND_DIRT_COLOR := Color(0.6, 0.45, 0.25)

const VIEWPORT_W := 800.0
const VIEWPORT_H := 600.0
const GROUND_Y := 500.0

# Parallax speed multipliers (farther = slower).
const CLOUD_SPEED_MULT := 0.2
const FAR_HILL_SPEED_MULT := 0.35
const NEAR_HILL_SPEED_MULT := 0.6

# Cloud data: [x_offset, y, width, height] – positions wrap around.
var _clouds := [
	[0.0, 60.0, 100.0, 30.0],
	[250.0, 40.0, 80.0, 24.0],
	[500.0, 80.0, 120.0, 32.0],
	[700.0, 50.0, 90.0, 28.0],
]

# Hill data: [x_center_offset, half_width, height]
var _far_hills := [
	[0.0, 160.0, 100.0],
	[300.0, 200.0, 130.0],
	[600.0, 140.0, 90.0],
	[850.0, 180.0, 110.0],
]

var _near_hills := [
	[100.0, 120.0, 70.0],
	[400.0, 150.0, 90.0],
	[700.0, 130.0, 60.0],
	[950.0, 100.0, 80.0],
]

var _scroll_offset := 0.0


func scroll(delta: float, speed: float) -> void:
	_scroll_offset += speed * delta
	queue_redraw()


func _draw() -> void:
	# --- Sky gradient ---
	for y in range(int(GROUND_Y)):
		var t := float(y) / GROUND_Y
		var color := SKY_TOP.lerp(SKY_BOTTOM, t)
		draw_line(Vector2(0, y), Vector2(VIEWPORT_W, y), color)

	# --- Clouds ---
	var cloud_off := fmod(_scroll_offset * CLOUD_SPEED_MULT, VIEWPORT_W + 200.0)
	for c in _clouds:
		var cx: float = fmod(c[0] - cloud_off + VIEWPORT_W + 200.0, VIEWPORT_W + 200.0) - 100.0
		var cy: float = c[1]
		var cw: float = c[2]
		var ch: float = c[3]
		draw_rect(Rect2(cx - cw * 0.5, cy - ch * 0.5, cw, ch), CLOUD_COLOR, true)
		# Round ends.
		draw_circle(Vector2(cx - cw * 0.35, cy), ch * 0.5, CLOUD_COLOR)
		draw_circle(Vector2(cx + cw * 0.35, cy), ch * 0.5, CLOUD_COLOR)
		draw_circle(Vector2(cx, cy - ch * 0.2), ch * 0.55, CLOUD_COLOR)

	# --- Far hills ---
	_draw_hills(_far_hills, FAR_HILL_SPEED_MULT, HILL_FAR_COLOR, GROUND_Y)

	# --- Near hills ---
	_draw_hills(_near_hills, NEAR_HILL_SPEED_MULT, HILL_NEAR_COLOR, GROUND_Y)

	# --- Ground ---
	draw_rect(Rect2(0, GROUND_Y, VIEWPORT_W, VIEWPORT_H - GROUND_Y), GROUND_COLOR, true)
	# Dirt stripe at bottom.
	draw_rect(Rect2(0, GROUND_Y + 20, VIEWPORT_W, VIEWPORT_H - GROUND_Y - 20), GROUND_DIRT_COLOR, true)

	# Ground line.
	draw_line(Vector2(0, GROUND_Y), Vector2(VIEWPORT_W, GROUND_Y), Color(0.2, 0.4, 0.15), 2.0)


func _draw_hills(hills: Array, speed_mult: float, color: Color, base_y: float) -> void:
	var off := fmod(_scroll_offset * speed_mult, VIEWPORT_W + 400.0)
	for h in hills:
		var cx: float = fmod(h[0] - off + VIEWPORT_W + 400.0, VIEWPORT_W + 400.0) - 200.0
		var hw: float = h[1]
		var hh: float = h[2]
		# Draw each hill as a simple triangle / polygon.
		var pts := PackedVector2Array([
			Vector2(cx - hw, base_y),
			Vector2(cx - hw * 0.3, base_y - hh * 0.8),
			Vector2(cx, base_y - hh),
			Vector2(cx + hw * 0.3, base_y - hh * 0.8),
			Vector2(cx + hw, base_y),
		])
		draw_colored_polygon(pts, color)
