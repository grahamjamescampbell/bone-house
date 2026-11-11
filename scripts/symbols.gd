class_name Sym
extends RefCounted

## Placeholder symbol set for the Bone House prototype.
## Coin / Blade / Ward / Favor / Skull is explicitly the FIRST PASS set from
## the design doc, flagged there as "under active reconsideration" — swap
## the Kind enum and the match statements below once the real symbols
## are settled, nothing else in the project needs to change.
##
## These are genuine six-sided dice, not a flat 5-way randomizer: Coin
## takes two of the six faces (the House's cut runs a little in its own
## favor), everything else gets one. FACES is the physical face layout;
## roll() is what every die-rolling call site should use instead of
## reaching into FACES directly.

enum Kind { COIN, BLADE, WARD, FAVOR, SKULL }

const COUNT := 5

const FACES: Array[int] = [Kind.COIN, Kind.COIN, Kind.BLADE, Kind.WARD, Kind.FAVOR, Kind.SKULL]

static func roll(rng: RandomNumberGenerator) -> int:
	return FACES[rng.randi_range(0, FACES.size() - 1)]

static func symbol_color(kind: int) -> Color:
	match kind:
		Kind.COIN:
			return Color(0.92, 0.78, 0.35)
		Kind.BLADE:
			return Color(0.90, 0.30, 0.28)
		Kind.WARD:
			return Color(0.35, 0.80, 0.72)
		Kind.FAVOR:
			return Color(0.72, 0.52, 0.92)
		Kind.SKULL:
			return Color(1.0, 0.22, 0.20)
		_:
			return Color.WHITE

static func symbol_name(kind: int) -> String:
	match kind:
		Kind.COIN:
			return "Coin"
		Kind.BLADE:
			return "Blade"
		Kind.WARD:
			return "Ward"
		Kind.FAVOR:
			return "Favor"
		Kind.SKULL:
			return "Skull"
		_:
			return "?"
