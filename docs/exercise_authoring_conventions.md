# Exercise Seed Data — Authoring Conventions

This document defines the rules for authoring rows in the `exercises` and
`exercise_substitutes` tables. It exists because spec §18 defines the schema
shape but leaves real interpretation room — and bad authoring decisions
cascade into bad recommendations everywhere downstream. Lock this once, then
follow it for all seed exercises.

Source of truth: this doc. If it conflicts with anything in `CLAUDE.md`,
update `CLAUDE.md`.

---

## 1. Variations are separate exercises, not attributes

If a variation changes which muscles bear load — different bar position,
different stance, different grip width when grip-dominant — it gets its own
row, with its own muscle weightings, sharing the family's `exercise_family_id`.

Distinguishing rule for "separate row" vs "same row, attribute":

- **Separate row** if any of: muscle weightings differ, primary movement
  pattern differs, demands differ, or equipment changes meaningfully.
- **Same row + `variation_attributes`** only when the variation is cosmetic
  or affects technique without redistributing load (e.g. tempo notes, a
  specific pin height that's still the same effective lift).

Concrete examples:

| Variation                          | Decision        |
|------------------------------------|-----------------|
| High-bar vs low-bar back squat     | Separate rows   |
| Front squat vs back squat          | Separate rows   |
| Sumo vs conventional deadlift      | Separate rows   |
| Pronated vs supinated pull-up (chin-up) | Separate rows |
| Barbell vs dumbbell BSS            | Separate rows (equipment) |
| Bench press at exactly 30° vs 45° incline | Separate rows |
| Pause squat vs touch-and-go squat  | Same row + attribute (`tempo: paused`) |
| Slightly different foot width on leg press | Same row, no attribute |

When in doubt, make it a separate row. The recommender benefits from
granularity; the cost is a few more rows in a table whose total size is
governed by §12's functional-redundancy bar, not a fixed cap.

---

## 2. Muscle weightings

### Three-tier values
- **1.0**: target muscle. The muscle that limits the lift. The muscle that
  grows from doing it. The muscle a user would say they're "training" when
  they pick this exercise.
- **0.5**: meaningful synergist. Genuinely contributes force, fatigues
  during the set, would be felt sore if isolated.
- **0.25**: stabilizer worth tracking. Only for muscles a user would
  notice fatiguing during a heavy session.

### When to use 1.0
A muscle gets 1.0 only if it's clearly the *target*. Default to fewer 1.0s,
not more. A back squat has quads at 1.0; glutes at 1.0 only on hip-dominant
variants (low-bar wide-stance, sumo). When unsure between 0.5 and 1.0, go
with 0.5.

### When to omit a 0.25 entry
Skip 0.25 unless the muscle is meaningfully challenged in a way the user
would notice. Don't list every contracting muscle — that creates noise and
makes every compound look identical to filters. Better captured by a
`demands` tag (e.g. `lumbar_loading`) than a stabilizer entry.

Examples of *correct* 0.25 entries:
- Lower back on barbell back squat (axially loaded, supports bar)
- Abs on overhead press (resists extension)
- Forearms on heavy deadlift (grip)

Examples of *incorrect* 0.25 entries:
- Calves on every standing exercise (yes they contract; no it doesn't matter)
- Lower back on leg press (back is supported)
- Abs on bicep curl

### Volume calculation note
Spec §18: "Only muscles weighted ≥ 0.5 count toward weekly volume." The
0.25 entries are documentation/filtering, not volume. Don't try to game
weekly volume targets by adding 0.5 entries that should be 0.25.

---

## 3. Demands tag vocabulary

Controlled list. Don't invent new tags ad-hoc; if you need one that's not
here, propose it explicitly so it gets added to the canonical set.

### Mobility demands
- `overhead_rom`
- `deep_knee_flexion`
- `ankle_dorsiflexion`
- `thoracic_extension`
- `hip_flexion`
- `hip_internal_rotation`
- `shoulder_external_rotation`
- `shoulder_flexion`

### Loading demands
- `axial_loading` (spinal compression — barbell on back/shoulders)
- `lumbar_loading` (lower back bears load without spinal compression — RDL, good morning)
- `unilateral_balance`
- `grip_intensive`

### Skill demands
- `barbell_skill` (technical lifts — clean, snatch, jerk)
- `dynamic_skill` (plyometric, ballistic, athletic movements)

Cap is ~15 tags. If proposing a 16th, be ready to argue why it's not
already covered by the existing set.

---

## 4. `variation_attributes` shape

Flat key→string map. Snake_case keys, snake_case values. Null when the
exercise has no meaningful variation axis (e.g. lateral raise).

### Established keys + values

| Key            | Values                                                     |
|----------------|------------------------------------------------------------|
| `grip`         | `pronated` \| `supinated` \| `neutral` \| `mixed` \| `false` |
| `stance`       | `narrow` \| `shoulder_width` \| `wide` \| `sumo` \| `conventional` \| `split` |
| `bar_position` | `high_bar` \| `low_bar` \| `front` \| `safety_squat`       |
| `range`        | `full` \| `partial` \| `pause` \| `pin`                    |
| `incline`      | `flat` \| `incline` \| `decline`                           |
| `tempo`        | `paused` \| `eccentric` \| `explosive`                     |

Add new keys/values explicitly when needed; don't introduce them silently.

---

## 5. Equipment + load increments

### Units
**All `load_increment_default` and `load_increment_micro` values are in
pounds (lbs).** v1 is lbs-only. kg support is a future feature; the storage
plan adds a unit column to weight-bearing tables (workout_logs, events) at
that time, leaving exercise increments authored as lbs.

### Defaults by equipment
| Equipment      | `load_increment_default` | `load_increment_micro` |
|----------------|--------------------------|------------------------|
| Barbell        | 5.00                     | 2.50                   |
| Dumbbell       | 5.00                     | 2.50                   |
| Machine (stack)| 10.00                    | 5.00                   |
| Cable          | 5.00 or 10.00 (gym-dep.) | 2.50                   |
| Bodyweight (loaded) | 2.50                | 1.25                   |
| Kettlebell     | 4.00 or 8.00 (gym-dep.)  | NULL                   |

Override defaults when the specific exercise warrants it (e.g. trap-bar
deadlift might use 10/5 if 5-lb plates aren't typical for that lift in your
gym).

---

## 6. Aliases

2–4 entries. Cover the common forms a user might actually type, not every
synonym.

- Include: short forms, common abbreviations, alternate canonical names
- Skip: every regional variant, archaic names, training-style-specific names

Example: "Barbell Back Squat" gets `['back squat', 'high-bar squat', 'barbell squat', 'BB squat']`.
Not `['back squat', 'high-bar squat', 'barbell squat', 'BB squat', 'BBBS', 'olympic squat', 'high bar', 'high bar back squat', ...]`.

---

## 7. Session position

- `early`: heavy compounds with high CNS demand. Squats, deadlifts, bench,
  OHP, weighted pull-ups, cleans.
- `late`: high-rep isolation, calves, abs, lateral raises, finishers.
- `anywhere`: most accessories and secondary compounds. Default when
  uncertain.

A program can override session position at usage time. This field is the
*default* preference, not a hard rule.

---

## 8. `loaded_position`

Spec §18: stretch-bias programming variety.

- `stretched`: peak tension at the bottom of ROM (squat, RDL, dumbbell fly,
  pull-up at full hang)
- `mid`: peak tension in the middle of ROM (most rows, leg press)
- `shortened`: peak tension at the top/contracted position (lateral raise,
  cable kickback, leg curl)
- `none`: no clear loaded position (carries, isometrics, conditioning)

When in doubt, `stretched` for compounds, `shortened` for peak-contraction
isolation work, `mid` otherwise.

---

## 9. Performance metric selection

| Metric                  | Use for                                              |
|-------------------------|------------------------------------------------------|
| `weight_x_reps`         | Standard loaded lifts (barbell, dumbbell, machine, cable) |
| `bodyweight_x_reps`     | Pure bodyweight, never loaded (push-up, sit-up)      |
| `weighted_bodyweight`   | Bodyweight that *can* be loaded (pull-up, dip, BSS bodyweight) |
| `time`                  | Hold/duration drills (plank, hang, carry distance optional) |
| `distance`              | Conditioning runs, sled pushes by distance           |
| `rounds_x_duration`     | Circuit/EMOM/AMRAP work                              |
| `reps_only`             | Skill drills counted by quality reps                 |
| `height`                | Jumps, box jumps                                     |
| `rpe_only`              | Mobility/skill where load isn't the point           |

Set `progression_eligible = FALSE` for `rpe_only` and `reps_only` exercises
unless explicitly designed to progress.

Set `relative_to_bodyweight = TRUE` only for exercises where the user's
bodyweight is part of the working load (pull-ups, dips, BSS, push-ups).

---

## 10. Substitution graph authoring

Substitutes are directional. (A → B) and (B → A) are separate rows; their
reasons can differ (B is a regression of A; A is a progression of B).

### Reason tags
- `same_pattern_different_equipment`: barbell row → dumbbell row
- `same_muscles_different_pattern`: leg press → hack squat
- `regression`: easier version (back squat → leg press)
- `progression`: harder version (leg press → back squat)
- `injury_friendly_variant`: back squat → safety bar squat for someone with
  shoulder mobility issues

### Similarity score
Decimal 0.00–1.00. Eyeballed, not computed. Rough buckets:
- 0.85+ : near-identical (back squat ↔ safety bar squat)
- 0.65–0.84 : strong substitute (back squat → front squat)
- 0.45–0.64 : reasonable substitute (back squat → leg press)
- 0.25–0.44 : weak substitute, only if nothing better available
- <0.25 : don't bother including

Aim for 2–4 substitutes per exercise. More than that is noise.

### Coverage target
Every exercise should have at least one substitute. Main compounds
should have substitutes covering:
- Different equipment for same pattern
- A regression
- A progression (if one exists in the database)

---

## 11. Authoring workflow checklist

For each new exercise, in order:

1. Decide if it's a new family or a variation of an existing family.
   If variation → reuse `exercise_family_id`.
2. Fill identity (name, aliases, domain).
3. Movement classification — primary pattern, secondary if compound,
   loading type.
4. Muscle weightings — apply §2 conventions strictly.
5. Equipment + load increments — apply §5 defaults unless exercise
   warrants override.
6. Programming role — modality, default_role, session_position.
7. Performance metric — apply §9 table.
8. Demands — pick from §3 vocabulary; flag any new tag explicitly.
9. variation_attributes — apply §4; null if no axis.
10. loaded_position — apply §8 heuristic.
11. Substitutes — at least one; apply §10 rules. May reference
    not-yet-inserted exercises by name; resolve to UUIDs at insert time.

---

## 12. What NOT to do

- Do not invent new `demands` tags without flagging them.
- Do not add 0.25 entries for every contracting muscle.
- Do not give 1.0 to every muscle that "works hard" — only to the *target*.
- Do not flatten variations into one row with averaged muscle weights.
- Do not author in kg.
- Do not skip substitutes.
- Do not author exercises without a clear functional reason. There is no
  hard cap on total exercises in v1; depth is determined by:
    - Equipment coverage (full gym, home gym, bodyweight-only)
    - Progression-ladder completeness (regression → main → progression
      within a family, so beginners and advanced users have appropriate
      starting points and rotation targets per spec §10)
    - Training-level coverage (easier variants for fatigued/deloading
      users, harder variants for advanced lifters)
  Reassess scope every ~25 exercises rather than at a fixed total. If a
  proposed exercise is functionally redundant with one already in the DB
  (no new pattern, no new equipment, no new difficulty tier, no new
  muscle bias), don't author it.
