class_name TableRules
extends RefCounted

## The rules of one Table: the base rules, plus whatever modifiers this Table
## carries. The table controller reads everything from here, so changing how a
## Table plays means changing (or adding) a modifier, not editing game logic.

# --- Base rules --------------------------------------------------------------
var bust_limit := 3                  # Skulls in one hand that bust it
var bust_damage := 2                 # HP lost when you bust
var opening_skulls_count := true     # do Skulls on the opening roll count toward a bust?
var push_limit := -1                 # Pushes allowed per hand; -1 means unlimited
var skull_push_takes_banked := false # a Skull on a Push destroys a banked Blade/Ward
var player_max_hp := 20
var dealer_max_hp := 20

# --- Which modifiers are active (ids from Modifiers) -------------------------
var modifiers: Array[String] = []

static func create(ids: Array) -> TableRules:
	var rules := TableRules.new()
	for id in ids:
		Modifiers.apply(str(id), rules)
		rules.modifiers.append(str(id))
	return rules

func summary() -> String:
	if modifiers.is_empty():
		return "TABLE: Plain — the base rules."
	var parts := PackedStringArray()
	for id in modifiers:
		parts.append("%s — %s" % [Modifiers.title(id), Modifiers.blurb(id)])
	return "TABLE: " + "   |   ".join(parts)
