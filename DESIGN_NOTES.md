# Bone House — prototype notes

This is a first playable vertical slice of the core loop described in the
design doc and scratchpad: roll, bank, push, stick, against a Dealer that
genuinely rolls its own dice. It's deliberately narrow — no map, no Charms,
no dice upgrades, no meta-progression, no sound. The goal was to get the
Bank/Push tension itself on its feet and feel whether it's actually fun
before building anything on top of it, per the design doc's own "Next
Steps" section.

## What's implemented

- A 5-die player pool. Roll, then bank or push (reroll) each unbanked die
  freely, any number of times. Rolling a Skull locks that die red and adds
  one to your Debt Track immediately — it can't be rerolled away. Three
  Skulls busts the hand: you lose whatever you'd banked and take 2 damage.
- A Dealer with its own 5-die pool, seeded once when the Table scene loads
  (see `_reseed_dealer()` in `table_controller.gd`) so its behavior is
  consistent for the life of that Table, per the "Dealer rolls too" section
  of the design doc. Its bank/push logic is a simple threshold heuristic:
  it keeps every Blade and Ward it rolls, keeps pushing whatever's left
  hoping for more, and stops once it's banked 4+ combined Blade/Ward or
  has taken 2 Skulls. This is a first guess, not a tuned opponent.
- Combat resolution: whichever showdown shape you land on later, this
  prototype implements the **blackjack-style** candidate from the design
  doc — you stick first, the Dealer reveals after. The **poker-style**
  simultaneous reveal is the other open candidate and isn't built here.
- Blade/Ward resolve as a flat 1-for-1 exchange: your Blade total minus
  the Dealer's Ward is the damage you deal, and vice versa. This is the
  simplest of the four Ward models floated in conversation (flat exchange,
  standing Guard, parry/counter, or conversion-to-another-resource) —
  picked purely to get something playable, not because it's the answer.
- Coin banks to Gold, Favor banks to Favor. Both are tracked but don't do
  anything yet (no shop, no meta-progression).
- Win a Table by dropping the Dealer to 0 HP; lose it by dropping to 0
  yourself. "NEW TABLE" resets HP/currency and reseeds the Dealer.

## Deliberately not implemented yet

- **The symbol set itself.** Coin / Blade / Ward / Favor / Skull is still
  the first-pass placeholder the design doc flags as "under active
  reconsideration." It's isolated in `scripts/symbols.gd` — the enum, the
  colors, and the vector glyphs each symbol draws — so replacing the whole
  set later is a change in one file, not a rewrite.
- Dice pool size changing mid-run (sacrifice, Fuse, winning a die from the
  Dealer). Pool is fixed at 5-for-5 for both sides here.
- Charms, dice upgrades (Reface/Weight/Infuse/Fuse), the node map, the
  Debt Track carrying over between hands/floors, Gold/Favor actually being
  spendable, and the knuckle-carving acquisition ritual.
- Any of the three Inscryption-style tension-reduction ideas (learnable
  seeded Dealer, a lost hand feeding something forward, a reactive move
  after the reveal) — the Dealer's seed exists, but nothing surfaces it to
  the player as learnable yet.

## Graphics

Everything is drawn in code with `_draw()` calls — no image assets at all.
Dice are vector line-art on black (`scripts/die_visual.gd`): a square
border plus a small glyph per symbol (circle for Coin, a little dagger for
Blade, a hexagon for Ward, a star for Favor, a skull for... Skull). Player
dice are green, Dealer dice are amber, a banked die's border turns white,
a Skulled die's border turns red. HP bars are the same approach — an
outline plus a proportional fill rectangle, no texture.

## Running it

Open `project.godot` in Godot 4.3+ and hit Play. "SIT AT THE TABLE" on the
title screen drops you into the one Table that exists right now.
