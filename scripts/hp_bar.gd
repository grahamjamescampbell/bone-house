class_name HPBar
extends Control

## A bare vector HUD bar: outline + proportional fill, no texture assets.

var value: float = 1.0
var bar_color: Color = Color(0.35, 0.95, 0.55)

func _init() -> void:
	custom_minimum_size = Vector2(220, 22)

func set_ratio(r: float) -> void:
	value = clamp(r, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	var size := get_size()
	var pad := 2.0
	var rect := Rect2(Vector2(pad, pad), size - Vector2(pad * 2.0, pad * 2.0))
	draw_rect(rect, Color(1, 1, 1, 0.25), false, 2.0)

	var fill_color := bar_color
	if value < 0.25:
		fill_color = Color(0.95, 0.25, 0.25)
	elif value < 0.5:
		fill_color = Color(0.92, 0.75, 0.3)

	if value > 0.0:
		var inner := Rect2(rect.position + Vector2(2, 2), Vector2((rect.size.x - 4.0) * value, rect.size.y - 4.0))
		draw_rect(inner, fill_color, true)
