---
status: draft
---

# Open Questions

A running list of unanswered design questions from the design conversation. Each has a space for an answer, which gets developed over time. A question is ticked off once the answer is settled.

## Settled so far

- [x] **Can any face be replaced, including the Skull?**
  - Answer: Yes, any face can be replaced. Skulls never fully go away: starter dice always carry one, and custom dice may carry one super-powerful face plus two or three Skulls, making the trade-off stark.
- [x] **Should a new pressure system beyond Skulls be hidden or telegraphed?**
  - Answer: Telegraphed. An NPC such as a Pit Boss gets upset, offended or simply notices, in a dialogue-heavy sequence, and explains the house rules have been 'upgraded' because the player upgraded their dice.
- [x] **Build the game-over and shop scenes now?**
  - Answer: No. Hold off and develop a vertical slice first; loop spec to come from Graham.

## Push, Skulls and busts

- [ ] **Keep the destroy-banked rule (a Skull on a Push destroys a banked Blade/Ward), and merge it into main?**
  - Answer:
- [ ] **Is the victim of a destroyed die random, or should the player choose? Is there any warning before a Push?**
  - Answer:
- [ ] **Do Skulls on the opening roll count toward the three-Skull bust?** (Prototype: yes. Draft doc: they only take up a slot.)
  - Answer:
- [ ] **What does a bust cost?** (Prototype: 2 self-damage and the hand ends with no House attack. Draft doc: lose the hand's benefits and still take the opponent's attacks.)
  - Answer:
- [ ] **Does the bust limit scale with the number of dice or the Skull density of the loadout?** (With a fixed limit of 3, eight dice bust about 13.5% of opening rolls.)
  - Answer:
- [ ] **Do we still test escalating Skull odds, a Push cap and a persistent Debt Track on their own branches?**
  - Answer:
- [ ] **Is the Debt Track persistent between tables (Design Doc) or reset each hand (prototype)? And is the Skull Debt Track the same thing as the gold debt to the House?**
  - Answer:
- [ ] **How should the House's own Push behaviour work?** (Currently capped at 5 pushes with a stop heuristic; it was not retuned for the destroy rule.)
  - Answer:

## Run flow and game over

- [x] **How many Dealers stand between the player and each floor's Boss Table?**
  - Answer: Six tables plus the Boss Table, in a one-two-one-two shape: one table, a fork, one table, a fork, then the Boss. Two real path choices per floor.
- [ ] **What does 'cash out' mean mechanically after game over: what is kept, and what happens to the debt?**
  - Answer:
- [ ] **What is the transition when beating a Dealer moves the player to the next table?**
  - Answer:
- [ ] **2D or rudimentary 3D for the cash-out, leave-the-table and merchant scenes? (One option: a small wireframe 3D viewport for those scenes only.)**
  - Answer:
- [ ] **Is 'busts from a table' (first-time merchant trigger) the same event as game over, and what do we call a bust of a hand versus losing the table?**
  - Answer:

## The Dice Merchant and economy

- [ ] **Coin or Gold? Fix the name in the code and the docs. (Also 'Bone Merchant' appears once in the draft.)**
  - Answer:
- [ ] **How do paying down the debt and buying dice compete for Gold, and what happens if the player ignores the debt?**
  - Answer:
- [ ] **How many dice can be owned versus carried, and what Favor items raise the carry limit? Is the loadout locked per sit?**
  - Answer:
- [ ] **How fast should Favor accumulate, and what do the expensive Favor items cost?**
  - Answer:
- [ ] **How does the Merchant's inventory refresh?**
  - Answer:
- [ ] **Where does dice customising happen? (Away from the tables, location yet to be decided.)**
  - Answer:

## Customising and boss dice

- [ ] **Does extracting a face destroy the rest of the sacrificial or boss die? Is it one face per die?**
  - Answer:
- [ ] **What is the remodel cost curve, and is it counted per die?**
  - Answer:
- [ ] **How do effect faces work (fire, triple damage on three Blades)? When do they activate, do they take a normal slot, and what status system do they need?**
  - Answer:
- [ ] **Is there a cap on boss faces per die or per loadout?**
  - Answer:
- [ ] **Does refighting a beaten boss change anything (harder rematch, cost to re-enter, cooldown)?**
  - Answer:
- [ ] **Does every boss trait use the roll-it-first activation gate, or are some passive?**
  - Answer:
- [ ] **Is the split of plain-die rewards (early floors) and trait-die rewards (later floors) intentional?**
  - Answer:
- [ ] **How do the Dealers' themed dice per floor differ from the player's, and how does the Dealer AI generalise?**
  - Answer:

## The House upgrades when you do

- [ ] **What does the House react to: a single power rating or the specific kind of build the player made?**
  - Answer:
- [ ] **Is boss-essence taint (carrying a circle's faces draws that guardian's claim) a separate mechanic, or folded into the Pit Boss?**
  - Answer:
- [ ] **What does the player gain from the House escalating, so upgrading is not punished?**
  - Answer:
- [ ] **How can House rules be countered, and what does the counter cost?**
  - Answer:
- [ ] **How often do Pit Boss beats happen? (One per floor boundary is the simplest hook; three to five per run is realistic for the writing.)**
  - Answer:
- [ ] **Who is the Pit Boss, and is there a nod to Minos?**
  - Answer:

## Table modifiers and the floor map

- [ ] **Are the three base-rule decisions settled: opening-roll Skulls count toward a bust, what a bust costs, and is the base deliberately mild so modifiers carry the tension?**
  - Answer:
- [ ] **Which modifiers go in first, and what does each pay out? (Placeholders: Heavy Hand, The Toll, Rising Skulls, Short Leash, Open Hand, Glass Table, Greedy House.)**
  - Answer:
- [ ] **Do modifiers stack on one table, and how many can a table carry?**
  - Answer:
- [ ] **Does each floor's forced middle tables carry a signature modifier tied to its circle?**
  - Answer:
- [ ] **Is a run of nine floors with six tables each (63 table fights) the right length, or do early floors run shorter?**
  - Answer:
- [ ] **What does quitting a run keep, and how does that relate to cashing out after game over?**
  - Answer:

## Skull upgrades

- [ ] **Indulgence (working name): what happens to the die when a Skull is invalidated? (Working answer: it is rerolled with a real chance of the Skull coming back.) Can it also cancel a Toll or Heavy Hand trigger?**
  - Answer:
- [ ] **When exactly can invalidation be used: after faces are revealed and before the outcome resolves. Is a third-Skull bust held until the player has had the chance to use it?**
  - Answer:
- [ ] **How is Indulgence upgraded and priced: three uses per table in total, and what does each step cost?**
  - Answer:
- [ ] **Scribble boon: does a struck-through face last for the run or only a table?**
  - Answer:
- [ ] **Scribble boon: what limits how many faces can be struck? (With five starter dice and one Skull face each, striking three makes a bust impossible.)**
  - Answer:
- [ ] **Scribble boon: does a struck face leave its die locked for the hand (a dead slot) or still rerollable?**
  - Answer:
- [ ] **Paused: the boon that stops three Skulls ever happening (one die auto-rerolled). Permanent or recharging, and how does it avoid overlapping Indulgence? Return to this later.**
  - Answer:

## Parked

- Parked by Graham: anything beyond the core Skull and modifier systems at this stage is too complex for now and is not to be raised in suggestions.

## Housekeeping

- [ ] **Update the Design Doc: battlefield, auto-bank on Stick, destroy-on-Push, the Nine Circles setting, the new design-docs.**
  - Answer:
- [ ] **Delete or ignore the stale `design-doc.html` and `scratchpad.html` in the repo folder?**
  - Answer:
- [ ] **Let the battlefield stretch vertically to fix the gap under the buttons at 1080p?**
  - Answer:
- [ ] **Keep the fought dice visible until Continue is pressed?**
  - Answer:
- [ ] **Update `DESIGN_NOTES.md` for the d6 decision?**
  - Answer:
