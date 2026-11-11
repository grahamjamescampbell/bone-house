class_name DieVisual
extends Control

## A single die, drawn as vector line-art (no sprites). Click to bank/unbank
## once it has a result. Skulled dice lock themselves and cannot be clicked.

signal clicked(id: int)

enum State { EMPTY, LIVE, BANKED, SKULLED }

var id: int = 0
var symbol: int = -1
var state: int = State.EMPTY
var pool_color: Color = Color(0.35, 0.95, 0.55)

func _init() -> void:
	custom_minimum_size = Vector2(76, 76)
	mouse_filter = Control.MOUSE_FILTER_PASS

func setup(die_id: int, base_color: Color) -> void:
	id = die_id
	pool_color = base_color
	queue_redraw()

func set_empty() -> void:
	symbol = -1
	state = State.EMPTY
	queue_redraw()

func roll(new_symbol: int) -> void:
	symbol = new_symbol
	state = State.SKULLED if new_symbol == Sym.Kind.SKULL else State.LIVE
	queue_redraw()

func toggle_bank() -> void:
	if state == State.LIVE:
		state = State.BANKED
	elif state == State.BANKED:
		state = State.LIVE
	queue_redraw()

func is_live() -> bool:
	return state == State.LIVE

func is_banked() -> bool:
	return state == State.BANKED

func is_skulled() -> bool:
	return state == State.SKULLED

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if state == State.LIVE or state == State.BANKED:
			clicked.emit(id)

func _draw() -> void:
	var size := get_size()
	var pad := 4.0
	var rect := Rect2(Vector2(pad, pad), size - Vector2(pad * 2.0, pad * 2.0))

	var outline_color := pool_color
	var line_width := 2.0

	match state:
		State.EMPTY:
			outline_color = Color(pool_color.r, pool_color.g, pool_color.b, 0.25)
		State.SKULLED:
			outline_color = Sym.symbol_color(Sym.Kind.SKULL)
			line_width = 2.5
		State.BANKED:
			outline_color = Color.WHITE
			line_width = 3.0

	draw_rect(rect, outline_color, false, line_width)

	if state == State.EMPTY:
		return

	var center := size / 2.0
	var r: float = min(size.x, size.y) * 0.26
	var sym_color := Sym.symbol_color(symbol)
	_draw_symbol(symbol, center, r, sym_color)

func _draw_symbol(kind: int, center: Vector2, r: float, color: Color) -> void:
	match kind:
		Sym.Kind.COIN:
			draw_arc(center, r, 0.0, TAU, 24, color, 2.0, true)
			draw_line(center - Vector2(r * 0.55, 0.0), center + Vector2(r * 0.55, 0.0), color, 2.0)
		Sym.Kind.BLADE:
			var tip := center + Vector2(-r, -r)
			var hilt := center + Vector2(r * 0.6, r * 0.6)
			draw_line(tip, hilt, color, 3.0)
			var guard_dir := (hilt - tip).normalized().rotated(PI / 2.0) * (r * 0.35)
			var guard_center := center + Vector2(r * 0.15, r * 0.15)
			draw_line(guard_center - guard_dir, guard_center + guard_dir, color, 2.5)
		Sym.Kind.WARD:
			var pts := PackedVector2Array()
			for i in range(6):
				var a := TAU / 6.0 * i - PI / 2.0
				pts.append(center + Vector2(cos(a), sin(a)) * r)
			pts.append(pts[0])
			draw_polyline(pts, color, 2.2)
		Sym.Kind.FAVOR:
			var pts2 := PackedVector2Array()
			for i in range(10):
				var a2 := TAU / 10.0 * i - PI / 2.0
				var rad := r if i % 2 == 0 else r * 0.42
				pts2.append(center + Vector2(cos(a2), sin(a2)) * rad)
			pts2.append(pts2[0])
			draw_polyline(pts2, color, 2.0)
		Sym.Kind.SKULL:
			draw_arc(center + Vector2(0.0, -r * 0.15), r * 0.8, 0.0, TAU, 20, color, 2.0, true)
			draw_circle(center + Vector2(-r * 0.3, -r * 0.2), r * 0.12, color)
			draw_circle(center + Vector2(r * 0.3, -r * 0.2), r * 0.12, color)
			draw_line(center + Vector2(-r * 0.25, r * 0.35), center + Vector2(r * 0.25, r * 0.35), color, 2.0)
