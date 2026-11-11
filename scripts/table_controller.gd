extends Control

## One Table, start to finish: roll / bank / push / stick against a Dealer
## that genuinely rolls its own seeded stock. Implements the design doc's
## "blackjack-style" showdown candidate (player sticks first, Dealer reveals
## after) as the prototype default — the poker-style simultaneous reveal is
## the other open candidate and is NOT implemented here. Ward resolves as a
## flat 1-for-1 block against the opposing side's Blade total: the simplest
## of the four Ward models discussed, chosen as the baseline to get a
## playable loop; Ward-as-parry / Ward-as-conversion are future work.
## Dice pool is fixed at 5 for both sides this prototype — Fuse, sacrifice,
## and the Dealer's-knuckle acquisition ritual are not implemented yet.

const DICE_COUNT := 5
const BUST_LIMIT := 3
const DEALER_BUST_LIMIT := 3
const DEALER_TARGET := 4
const DEALER_PUSH_LIMIT := 5
const BUST_DAMAGE := 2

const PLAYER_COLOR := Color(0.35, 0.95, 0.55)
const DEALER_COLOR := Color(0.92, 0.78, 0.35)

## Battlefield clash choreography. The real banked Blade/Ward dice (not
## copies) leave their row: attackers travel to the centre battlefield,
## defenders travel out to their own side's HP bar — all at once. Then each
## attacker resolves in sequence, one at a time with a beat between: if a
## defender is still waiting, the two meet and cancel; if not, the attacker
## reaches the HP bar and lands a hit. Player's attacks resolve fully before
## the House's reply, exactly as described. Every die fades once it is done
## and is quietly returned to its row, reset to empty, for the next hand.
const MOVE_TIME := 0.4
const BEAT := 0.5
const STRIKE_TIME := 0.38
const FADE_TIME := 0.22

## Same gap used everywhere a row of dice is spaced out: between dice within
## a row, and between a defence row and the HP bar it sits against.
const ROW_GAP := 10.0

var rng := RandomNumberGenerator.new()
var dealer_rng := RandomNumberGenerator.new()

var player_hp := 20
var player_max_hp := 20
var dealer_hp := 20
var dealer_max_hp := 20
var gold := 0
var favor := 0

var player_debt := 0
var dealer_debt := 0

var player_dice: Array[DieVisual] = []
var dealer_dice: Array[DieVisual] = []

var player_banked := {}
var hand_rolled := false
var game_over := false
var awaiting_continue := false
var animating := false

var message_label: Label
var player_hp_bar: HPBar
var dealer_hp_bar: HPBar
var gold_label: Label
var favor_label: Label
var player_debt_label: Label
var dealer_debt_label: Label
var battlefield: Control

var roll_btn: Button
var push_btn: Button
var stick_btn: Button
var restart_btn: Button
var exit_btn: Button

func _ready() -> void:
	rng.randomize()
	_reseed_dealer()
	anchor_right = 1.0
	anchor_bottom = 1.0

	_reset_banked(player_banked)
	_build_ui()
	_refresh_all()
	_start_hand()

func _reseed_dealer() -> void:
	# The Dealer's dice are a stock set seeded once per Table, per the design
	# doc — within one Table session the seed is fixed at entry; "NEW TABLE"
	# reseeds it, standing in for walking up to a fresh table.
	dealer_rng.seed = hash(str(Time.get_ticks_usec()) + "-table")

# ---------------------------------------------------------------- UI build --

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 1)
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)

	var margin := MarginContainer.new()
	margin.anchor_right = 1.0
	margin.anchor_bottom = 1.0
	margin.add_theme_constant_override("margin_left", 32)
	margin.add_theme_constant_override("margin_right", 32)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	# Dealer area
	var dealer_header := HBoxContainer.new()
	dealer_header.add_theme_constant_override("separation", 24)
	root.add_child(dealer_header)
	var dealer_title := Label.new()
	dealer_title.text = "THE HOUSE"
	dealer_title.add_theme_font_size_override("font_size", 22)
	dealer_title.add_theme_color_override("font_color", DEALER_COLOR)
	dealer_header.add_child(dealer_title)
	dealer_debt_label = Label.new()
	dealer_debt_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	dealer_debt_label.add_theme_font_size_override("font_size", 14)
	dealer_header.add_child(dealer_debt_label)
	var dealer_spacer := Control.new()
	dealer_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dealer_header.add_child(dealer_spacer)
	dealer_hp_bar = HPBar.new()
	dealer_hp_bar.bar_color = DEALER_COLOR
	dealer_header.add_child(dealer_hp_bar)

	var dealer_row := HBoxContainer.new()
	dealer_row.alignment = BoxContainer.ALIGNMENT_CENTER
	dealer_row.add_theme_constant_override("separation", int(ROW_GAP))
	root.add_child(dealer_row)
	for i in range(DICE_COUNT):
		var dv := DieVisual.new()
		dv.setup(i, DEALER_COLOR)
		dealer_row.add_child(dv)
		dealer_dice.append(dv)

	root.add_child(HSeparator.new())

	# Battlefield: the centre strip where banked Blade/Ward dice meet.
	battlefield = Control.new()
	battlefield.custom_minimum_size = Vector2(0, 110)
	battlefield.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	battlefield.mouse_filter = Control.MOUSE_FILTER_IGNORE
	battlefield.clip_contents = true
	root.add_child(battlefield)

	root.add_child(HSeparator.new())

	# Message log
	message_label = Label.new()
	message_label.text = "The House is waiting. Roll to begin."
	message_label.add_theme_font_size_override("font_size", 18)
	message_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.85))
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	message_label.custom_minimum_size = Vector2(0, 30)
	root.add_child(message_label)

	root.add_child(HSeparator.new())

	# Player area
	var player_row := HBoxContainer.new()
	player_row.alignment = BoxContainer.ALIGNMENT_CENTER
	player_row.add_theme_constant_override("separation", int(ROW_GAP))
	root.add_child(player_row)
	for i in range(DICE_COUNT):
		var dv2 := DieVisual.new()
		dv2.setup(i, PLAYER_COLOR)
		dv2.clicked.connect(_on_player_die_clicked)
		player_row.add_child(dv2)
		player_dice.append(dv2)

	var player_header := HBoxContainer.new()
	player_header.add_theme_constant_override("separation", 24)
	root.add_child(player_header)
	var player_title := Label.new()
	player_title.text = "YOU"
	player_title.add_theme_font_size_override("font_size", 22)
	player_title.add_theme_color_override("font_color", PLAYER_COLOR)
	player_header.add_child(player_title)
	player_debt_label = Label.new()
	player_debt_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	player_debt_label.add_theme_font_size_override("font_size", 14)
	player_header.add_child(player_debt_label)
	gold_label = Label.new()
	gold_label.add_theme_color_override("font_color", Sym.symbol_color(Sym.Kind.COIN))
	player_header.add_child(gold_label)
	favor_label = Label.new()
	favor_label.add_theme_color_override("font_color", Sym.symbol_color(Sym.Kind.FAVOR))
	player_header.add_child(favor_label)
	var player_spacer := Control.new()
	player_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_header.add_child(player_spacer)
	player_hp_bar = HPBar.new()
	player_hp_bar.bar_color = PLAYER_COLOR
	player_header.add_child(player_hp_bar)

	root.add_child(HSeparator.new())

	var button_row := HBoxContainer.new()
	button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	button_row.add_theme_constant_override("separation", 16)
	root.add_child(button_row)

	roll_btn = _make_button("ROLL", PLAYER_COLOR)
	roll_btn.pressed.connect(_on_roll_pressed)
	button_row.add_child(roll_btn)

	push_btn = _make_button("PUSH", Sym.symbol_color(Sym.Kind.WARD))
	push_btn.pressed.connect(_on_push_pressed)
	button_row.add_child(push_btn)

	stick_btn = _make_button("STICK", DEALER_COLOR)
	stick_btn.pressed.connect(_on_stick_pressed)
	button_row.add_child(stick_btn)

	restart_btn = _make_button("NEW TABLE", Color(1, 0.3, 0.3))
	restart_btn.pressed.connect(_on_restart_pressed)
	button_row.add_child(restart_btn)

	exit_btn = _make_button("EXIT", Color(0.65, 0.65, 0.6))
	exit_btn.pressed.connect(_on_exit_pressed)
	button_row.add_child(exit_btn)

func _make_button(text: String, color: Color) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(140, 44)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0, 0, 0, 0)
	normal.border_color = color
	normal.set_border_width_all(2)
	var hover := normal.duplicate()
	hover.bg_color = Color(color.r, color.g, color.b, 0.18)
	var disabled := normal.duplicate()
	disabled.border_color = Color(color.r, color.g, color.b, 0.25)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_stylebox_override("disabled", disabled)
	btn.add_theme_color_override("font_color", color)
	btn.add_theme_color_override("font_hover_color", color)
	btn.add_theme_color_override("font_disabled_color", Color(color.r, color.g, color.b, 0.4))
	btn.add_theme_font_size_override("font_size", 16)
	return btn

# -------------------------------------------------------------- game logic --

func _reset_banked(d: Dictionary) -> void:
	d[Sym.Kind.COIN] = 0
	d[Sym.Kind.BLADE] = 0
	d[Sym.Kind.WARD] = 0
	d[Sym.Kind.FAVOR] = 0

func _start_hand() -> void:
	player_debt = 0
	dealer_debt = 0
	hand_rolled = false
	awaiting_continue = false
	animating = false
	_reset_banked(player_banked)
	for dv in player_dice:
		dv.set_empty()
	for dv in dealer_dice:
		dv.set_empty()
	message_label.text = "Your move. Roll the bones."
	_refresh_all()

func _on_roll_pressed() -> void:
	if game_over:
		return
	if awaiting_continue:
		_start_hand()
		return
	if hand_rolled:
		return
	hand_rolled = true
	for dv in player_dice:
		var s := Sym.roll(rng)
		dv.roll(s)
		if s == Sym.Kind.SKULL:
			player_debt += 1
	if _check_player_bust():
		return
	message_label.text = "Bank what you like, push the rest, or stick."
	_refresh_all()

func _on_push_pressed() -> void:
	if game_over or not hand_rolled:
		return
	var any_live := false
	for dv in player_dice:
		if dv.is_live():
			any_live = true
			var s := Sym.roll(rng)
			dv.roll(s)
			if s == Sym.Kind.SKULL:
				player_debt += 1
	if not any_live:
		message_label.text = "Nothing left to push — bank it or stick."
		_refresh_all()
		return
	if _check_player_bust():
		return
	message_label.text = "Pushed. The House is patient."
	_refresh_all()

func _check_player_bust() -> bool:
	if player_debt >= BUST_LIMIT:
		player_hp -= BUST_DAMAGE
		message_label.text = "BUST. Three skulls — you flinched and it cost you %d." % BUST_DAMAGE
		if player_hp <= 0:
			_end_game(false)
		else:
			awaiting_continue = true
			_refresh_all()
		return true
	return false

func _on_player_die_clicked(id: int) -> void:
	if game_over or awaiting_continue or animating:
		return
	player_dice[id].toggle_bank()
	_refresh_all()

func _on_stick_pressed() -> void:
	if game_over or not hand_rolled or animating:
		return
	# Sticking ends the turn, so anything still live is banked automatically:
	# a live die can't help you any other way once you've stopped pushing.
	for dv in player_dice:
		if dv.is_live():
			dv.toggle_bank()
	for dv in player_dice:
		if dv.is_banked():
			player_banked[dv.symbol] += 1
	animating = true
	_refresh_all()
	_run_dealer_turn()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _run_dealer_turn() -> void:
	var banked := {}
	_reset_banked(banked)
	var debt := 0
	var active := DICE_COUNT
	var pushes := 0
	var busted := false

	while active > 0 and pushes < DEALER_PUSH_LIMIT:
		var results: Array[int] = []
		for i in range(active):
			results.append(Sym.roll(dealer_rng))
		var next_active := 0
		for s in results:
			if s == Sym.Kind.SKULL:
				debt += 1
			elif s == Sym.Kind.BLADE or s == Sym.Kind.WARD:
				banked[s] += 1
			else:
				next_active += 1
		active = next_active
		pushes += 1
		if debt >= DEALER_BUST_LIMIT:
			busted = true
			break
		if banked[Sym.Kind.BLADE] + banked[Sym.Kind.WARD] >= DEALER_TARGET or debt >= 2:
			break

	dealer_debt = debt
	if busted:
		_reset_banked(banked)

	var shown := 0
	for kind in [Sym.Kind.BLADE, Sym.Kind.WARD, Sym.Kind.COIN, Sym.Kind.FAVOR]:
		for n in range(banked[kind]):
			if shown < DICE_COUNT:
				dealer_dice[shown].roll(kind)
				dealer_dice[shown].state = DieVisual.State.BANKED
				dealer_dice[shown].queue_redraw()
				shown += 1
	for i in range(shown, DICE_COUNT):
		dealer_dice[i].set_empty()

	await _animate_clash(player_banked, banked)
	animating = false
	_resolve_hand(banked, busted)

# ------------------------------------------------------------- battlefield --

## The real dice, not copies, leave their rows: attackers head to the centre
## battlefield, defenders head out to their own side's HP bar, all at the
## same moment. Then the player's attacks resolve one at a time against
## whatever defence is waiting (a beat between each), and only once that's
## done does the House's reply resolve the same way against the player.
func _animate_clash(player_hand: Dictionary, dealer_hand: Dictionary) -> void:
	var player_attack: Array[DieVisual] = []
	var player_defence: Array[DieVisual] = []
	for dv in player_dice:
		if dv.is_banked():
			if dv.symbol == Sym.Kind.BLADE:
				player_attack.append(dv)
			elif dv.symbol == Sym.Kind.WARD:
				player_defence.append(dv)

	var dealer_attack: Array[DieVisual] = []
	var dealer_defence: Array[DieVisual] = []
	for dv in dealer_dice:
		if dv.is_banked():
			if dv.symbol == Sym.Kind.BLADE:
				dealer_attack.append(dv)
			elif dv.symbol == Sym.Kind.WARD:
				dealer_defence.append(dv)

	var player_coins: Array[DieVisual] = []
	var player_favors: Array[DieVisual] = []
	for dv in player_dice:
		if dv.is_banked():
			if dv.symbol == Sym.Kind.COIN:
				player_coins.append(dv)
			elif dv.symbol == Sym.Kind.FAVOR:
				player_favors.append(dv)

	var has_combat: bool = not (player_attack.is_empty() and player_defence.is_empty() \
			and dealer_attack.is_empty() and dealer_defence.is_empty())
	if not has_combat and player_coins.is_empty() and player_favors.is_empty():
		return

	var homes := {}
	if has_combat:
		await _run_combat(player_attack, player_defence, dealer_attack, dealer_defence, homes)

	if not player_coins.is_empty() or not player_favors.is_empty():
		message_label.text = "The House pays out."
		await _flow_currency(player_coins, player_favors, homes)

	_resync_row_order()

func _run_combat(player_attack: Array, player_defence: Array, dealer_attack: Array, dealer_defence: Array, homes: Dictionary) -> void:
	message_label.text = "Clash!"

	for i in range(player_attack.size()):
		_send_attack_to_field(player_attack[i], i, player_attack.size(), true, homes)
	for i in range(dealer_attack.size()):
		_send_attack_to_field(dealer_attack[i], i, dealer_attack.size(), false, homes)
	for i in range(player_defence.size()):
		_send_defence_to_bar(player_defence[i], i, player_defence.size(), player_hp_bar, true, homes)
	for i in range(dealer_defence.size()):
		_send_defence_to_bar(dealer_defence[i], i, dealer_defence.size(), dealer_hp_bar, false, homes)

	await get_tree().create_timer(MOVE_TIME + 0.1).timeout
	await get_tree().create_timer(BEAT).timeout

	if not player_attack.is_empty():
		message_label.text = "Your attacks come in."
	await _resolve_attack_phase(player_attack, dealer_defence, dealer_hp_bar, true, homes)
	await _fade_leftovers(dealer_defence, homes)

	await get_tree().create_timer(BEAT).timeout

	if not dealer_attack.is_empty():
		message_label.text = "The House strikes back."
	await _resolve_attack_phase(dealer_attack, player_defence, player_hp_bar, false, homes)
	await _fade_leftovers(player_defence, homes)

## Banked Coin and Favor dice flow into the Gold and Favor counters, which
## tick up as each die arrives; the die then fades and returns to its row.
func _flow_currency(coins: Array, favors: Array, homes: Dictionary) -> void:
	var delay := 0.0
	for dv in coins:
		_flow_one(dv, gold_label, true, delay, homes)
		delay += 0.15
	for dv in favors:
		_flow_one(dv, favor_label, false, delay, homes)
		delay += 0.15
	await get_tree().create_timer(delay + MOVE_TIME + FADE_TIME + 0.3).timeout

func _flow_one(dv: DieVisual, label: Label, is_gold: bool, delay: float, homes: Dictionary) -> void:
	_take_die(dv, homes)
	dv.pivot_offset = dv.size * 0.5
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	var target: Vector2 = label.global_position + label.size * 0.5 - dv.size * 0.5
	var move := create_tween()
	move.set_parallel(true)
	move.tween_property(dv, "global_position", target, MOVE_TIME + 0.1)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	move.tween_property(dv, "scale", Vector2(0.3, 0.3), MOVE_TIME + 0.1)
	await move.finished
	if is_gold:
		gold += 1
	else:
		favor += 1
	_refresh_all()
	var fade := create_tween()
	fade.tween_property(dv, "modulate:a", 0.0, FADE_TIME * 0.5)
	await fade.finished
	_return_home(dv, homes)

## Removals during the clash can interleave (several dice leave the same row
## before any of them come back), so the index a die held at removal time
## isn't reliably its original slot. Rather than fight that, every returned
## die is just appended back to its own row, and once the whole clash is
## done this snaps both rows back to the canonical player_dice/dealer_dice
## order in one pass.
func _resync_row_order() -> void:
	for i in range(player_dice.size()):
		var dv := player_dice[i]
		if dv.get_parent() != null:
			dv.get_parent().move_child(dv, i)
	for i in range(dealer_dice.size()):
		var dv2 := dealer_dice[i]
		if dv2.get_parent() != null:
			dv2.get_parent().move_child(dv2, i)

func _take_die(dv: DieVisual, homes: Dictionary) -> void:
	homes[dv] = dv.get_parent()
	var g: Vector2 = dv.global_position
	dv.get_parent().remove_child(dv)
	add_child(dv)
	dv.global_position = g

func _return_home(dv: DieVisual, homes: Dictionary) -> void:
	if not homes.has(dv):
		return
	var parent: Node = homes[dv]
	if dv.get_parent() != null:
		dv.get_parent().remove_child(dv)
	dv.modulate = Color(1, 1, 1, 1)
	dv.scale = Vector2.ONE
	dv.position = Vector2.ZERO
	dv.set_empty()
	parent.add_child(dv)
	homes.erase(dv)

func _send_attack_to_field(dv: DieVisual, i: int, n: int, player_side: bool, homes: Dictionary) -> void:
	_take_die(dv, homes)
	var bf_pos: Vector2 = battlefield.global_position
	var bf_size: Vector2 = battlefield.size
	if bf_size.x <= 0.0:
		bf_size = Vector2(600, 140)
	var half_w: float = bf_size.x * 0.46
	var x0: float = bf_pos.x if player_side else bf_pos.x + bf_size.x * 0.54
	var cx: float = x0 + (float(i) + 0.5) / float(n) * half_w
	var cy: float = bf_pos.y + bf_size.y * 0.5 - dv.size.y * 0.5
	var tw := create_tween()
	tw.tween_property(dv, "global_position", Vector2(cx - dv.size.x * 0.5, cy), MOVE_TIME)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

## Defence dice form a row against their own HP bar, spaced exactly like a
## dice row on the main playing field (same ROW_GAP between each other), and
## sitting that same ROW_GAP distance off the bar itself: above it for the
## player, below it for the House.
func _send_defence_to_bar(dv: DieVisual, i: int, n: int, hp_bar: HPBar, above: bool, homes: Dictionary) -> void:
	_take_die(dv, homes)
	var bar_pos: Vector2 = hp_bar.global_position
	var bar_size: Vector2 = hp_bar.size
	var dw: float = dv.size.x
	var dh: float = dv.size.y
	var total_w: float = float(n) * dw + float(max(n - 1, 0)) * ROW_GAP
	var start_x: float = bar_pos.x + bar_size.x * 0.5 - total_w * 0.5
	var x: float = start_x + float(i) * (dw + ROW_GAP)
	var y: float = (bar_pos.y - ROW_GAP - dh) if above else (bar_pos.y + bar_size.y + ROW_GAP)
	var tw := create_tween()
	tw.tween_property(dv, "global_position", Vector2(x, y), MOVE_TIME)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

## Resolves attackers one at a time, in order, with a beat between each: a
## waiting defender meets this attack and both cancel; with no defender left
## the attack lands on the HP bar instead.
func _resolve_attack_phase(attackers: Array, defenders: Array, hp_bar: HPBar, hits_dealer: bool, homes: Dictionary) -> void:
	for a in attackers:
		if defenders.size() > 0:
			var d: DieVisual = defenders.pop_front()
			await _strike_blocked(a, d, homes)
		else:
			await _strike_through(a, hp_bar, hits_dealer, homes)
		await get_tree().create_timer(BEAT).timeout

func _strike_blocked(a: DieVisual, d: DieVisual, homes: Dictionary) -> void:
	var meet: Vector2 = d.global_position
	var move := create_tween()
	move.tween_property(a, "global_position", meet, STRIKE_TIME)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await move.finished

	var flash := create_tween()
	flash.set_parallel(true)
	flash.tween_property(a, "modulate", Color(1.5, 1.5, 1.5), 0.08)
	flash.tween_property(d, "modulate", Color(1.5, 1.5, 1.5), 0.08)
	await flash.finished

	var fade := create_tween()
	fade.set_parallel(true)
	fade.tween_property(a, "modulate:a", 0.0, FADE_TIME)
	fade.tween_property(d, "modulate:a", 0.0, FADE_TIME)
	await fade.finished

	_return_home(a, homes)
	_return_home(d, homes)

func _strike_through(a: DieVisual, hp_bar: HPBar, hits_dealer: bool, homes: Dictionary) -> void:
	var target: Vector2 = hp_bar.global_position \
		+ Vector2(hp_bar.size.x * 0.5 - a.size.x * 0.5, hp_bar.size.y * 0.5 - a.size.y * 0.5)
	var move := create_tween()
	move.tween_property(a, "global_position", target, STRIKE_TIME)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await move.finished

	if hits_dealer:
		dealer_hp -= 1
	else:
		player_hp -= 1
	_refresh_all()

	var flash := create_tween()
	flash.tween_property(hp_bar, "modulate", Color(1.6, 1.3, 1.3), 0.08)
	flash.tween_property(hp_bar, "modulate", Color(1, 1, 1, 1), 0.12)

	var fade := create_tween()
	fade.tween_property(a, "modulate:a", 0.0, FADE_TIME)
	await fade.finished

	_return_home(a, homes)

func _fade_leftovers(list: Array, homes: Dictionary) -> void:
	if list.is_empty():
		return
	var fade := create_tween()
	fade.set_parallel(true)
	for dv in list:
		fade.tween_property(dv, "modulate:a", 0.0, FADE_TIME)
	await fade.finished
	for dv in list:
		_return_home(dv, homes)
	list.clear()

func _resolve_hand(dealer_banked: Dictionary, dealer_busted: bool) -> void:
	var player_dmg: int = max(0, player_banked[Sym.Kind.BLADE] - dealer_banked[Sym.Kind.WARD])
	var dealer_dmg: int = max(0, dealer_banked[Sym.Kind.BLADE] - player_banked[Sym.Kind.WARD])

	var lines := PackedStringArray()
	if dealer_busted:
		lines.append("The House busted on its own skulls.")
	lines.append("You dealt %d. The House dealt %d." % [player_dmg, dealer_dmg])
	message_label.text = " ".join(lines)

	_refresh_all()

	if dealer_hp <= 0:
		_end_game(true)
	elif player_hp <= 0:
		_end_game(false)
	else:
		awaiting_continue = true
		_refresh_all()

func _end_game(won: bool) -> void:
	game_over = true
	if won:
		message_label.text = "The House folds. Take a knuckle on your way out — you've earned a new die."
	else:
		message_label.text = "The House collects. Your debt remains."
	_refresh_all()

# ------------------------------------------------------------------- HUD ---

func _refresh_all() -> void:
	player_hp = clamp(player_hp, 0, player_max_hp)
	dealer_hp = clamp(dealer_hp, 0, dealer_max_hp)
	player_hp_bar.set_ratio(float(player_hp) / float(player_max_hp))
	dealer_hp_bar.set_ratio(float(dealer_hp) / float(dealer_max_hp))
	gold_label.text = "GOLD %d" % gold
	favor_label.text = "FAVOR %d" % favor
	player_debt_label.text = "Debt Track: %s" % _debt_pips(player_debt)
	dealer_debt_label.text = "House Debt Track: %s" % _debt_pips(dealer_debt)

	roll_btn.text = "CONTINUE" if awaiting_continue else "ROLL"
	roll_btn.disabled = game_over or animating or (hand_rolled and not awaiting_continue)
	push_btn.disabled = game_over or animating or awaiting_continue or not hand_rolled or not _has_live_die()
	stick_btn.disabled = game_over or animating or awaiting_continue or not hand_rolled
	restart_btn.disabled = animating

func _has_live_die() -> bool:
	for dv in player_dice:
		if dv.is_live():
			return true
	return false

func _debt_pips(count: int) -> String:
	var s := ""
	for i in range(BUST_LIMIT):
		s += "X" if i < count else "."
		if i < BUST_LIMIT - 1:
			s += " "
	return s

func _on_restart_pressed() -> void:
	game_over = false
	player_hp = player_max_hp
	dealer_hp = dealer_max_hp
	gold = 0
	favor = 0
	_reseed_dealer()
	_start_hand()
