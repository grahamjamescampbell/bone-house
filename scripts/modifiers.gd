class_name Modifiers
extends RefCounted

## Table modifiers. Each one changes one base rule and is shown to the player
## before they commit to the Table. To add a modifier: give it an id, a title,
## a one-line blurb, and a case in apply() that adjusts the TableRules.

const HEAVY_HAND := "heavy_hand"
const SHORT_LEASH := "short_leash"
const GLASS_TABLE := "glass_table"

const ALL := [HEAVY_HAND, SHORT_LEASH, GLASS_TABLE]

static func title(id: String) -> String:
	match id:
		HEAVY_HAND: return "Heavy Hand"
		SHORT_LEASH: return "Short Leash"
		GLASS_TABLE: return "Glass Table"
	return id

static func blurb(id: String) -> String:
	match id:
		HEAVY_HAND: return "A Skull rolled on a Push takes one banked Blade or Ward."
		SHORT_LEASH: return "Only two Pushes per hand, for you and the House."
		GLASS_TABLE: return "Both sides have only 10 HP."
	return ""

static func apply(id: String, rules: TableRules) -> void:
	match id:
		HEAVY_HAND:
			rules.skull_push_takes_banked = true
		SHORT_LEASH:
			rules.push_limit = 2
		GLASS_TABLE:
			rules.player_max_hp = 10
			rules.dealer_max_hp = 10
