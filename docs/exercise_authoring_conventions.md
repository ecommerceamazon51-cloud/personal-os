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

## 2. Muscle weightings (v2: per-head + comprehensive 0.25)

**Major change vs v1:** weights are now authored against per-head muscle
rows (e.g. `triceps_lateral`), not flat group rows (e.g. `triceps`). See §13
for the parent/child muscle taxonomy. Group-level scores are derived by
averaging across heads at query time (see "Group-level aggregation" below).

### Three-tier values
- **1.0**: target muscle head. The head that limits the lift. The head
  that grows from doing it. The head a user would say they're "training"
  when they pick this exercise.
- **0.5**: meaningful synergist head. Genuinely contributes force,
  fatigues during the set, would be felt sore if isolated.
- **0.25**: minor contributor worth tracking. Goes through real ROM under
  load OR contributes a non-trivial stabilization role with meaningful
  load.

Intermediate values (0.3, 0.4, 0.6, 0.7, 0.8, 0.85) are also allowed and
encouraged when the head's contribution falls between tiers. Don't force
everything into 1.0 / 0.5 / 0.25 if 0.4 is more accurate. The pilot
exercises (see §13 examples) use these intermediate values heavily.

### When to use 1.0
A head gets 1.0 only if it's clearly the *target*. Default to fewer 1.0s,
not more. A back squat has the three vasti at 1.0 each because they're all
the workhorse muscles of the lift; rectus femoris gets less because it's
a two-joint muscle (see §13 patterns). When unsure between 0.5 and 1.0,
go with 0.5 or an intermediate like 0.7.

### Comprehensive 0.25 authoring (changed from v1)

**v1 rule:** "Skip 0.25 unless the muscle is meaningfully challenged in a
way the user would notice."

**v2 rule:** List any muscle head that goes through meaningful ROM under
load, even slightly. Skip pure isometric stabilization unless it's notable
(spinal erectors on a back squat = notable; lateral delts on a back squat
= not).

**Why the change.** v2 stores muscle contributions comprehensively even
when they don't count toward the current volume rule (≥0.5; see "Volume
calculation note" below). Advanced users with high recovery capacity
(enhanced lifters, double-day training, high-frequency programs) will want
0.25 entries counted in future user profiles. The current volume math
doesn't change; the data is just there when we need it.

Examples of *correct* 0.25 entries (v2):
- Hamstrings (3 heads) on back squat — co-contract through ROM to stabilize
  the knee during descent. v1 missed this. Real contribution, just small.
- Pec sternal on pull-up — adducts the shoulder slightly at the bottom of
  the rep. Real.
- Calves gastrocnemius on back squat — light ankle stabilization through ROM.
- Forearms grip on pull-up — sustained hanging load. Real.
- Obliques on Bulgarian split squat (bump to 0.4) — anti-rotation under
  unilateral load.
- Rotator cuff infraspinatus + teres minor on pull-up — active throughout
  the pull.

Examples of *incorrect* 0.25 entries (v2):
- Lateral delts on back squat — pure isometric, no meaningful ROM,
  no significant load through the shoulder.
- Abs on bicep curl — no real bracing demand.
- Lower back on leg press — back is supported by the seat.
- Triceps on pull-up at the bottom — technically extending the elbow but
  with zero load resistance (gravity is already doing the work).

### Test: does the head get listed?
1. Does the head go through meaningful range of motion during the exercise?
2. Is that range of motion happening under load (not just under bodyweight
   while the load is elsewhere)?

If yes to both → list it at 0.25 or higher.
If yes to (1) but no to (2) → usually skip; consider 0.25 only if the
position-without-load still matters (rare).
If no to (1) → skip unless it's a notable isometric stabilizer like
spinal erectors on a back squat.

### Volume calculation note
Spec §18: "Only muscle heads weighted ≥ 0.5 count toward weekly volume."
The 0.25 entries are stored for completeness, advanced user profiles, and
future configurable volume rules. Don't try to game weekly volume targets
by inflating 0.25s to 0.5.

### Group-level aggregation: average across ALL heads in the group

Group-level volume = arithmetic mean of all head weights in the group,
treating untrained heads as 0.

**Example.** A leg curl trains 3 hamstring heads but not BF short head:
- BF long: 1.0
- BF short: 0 (not listed)
- Semitendinosus: 1.0
- Semimembranosus: 0.8

Group score = (1.0 + 0 + 1.0 + 0.8) / 4 = 0.7

If you instead averaged only the listed heads ((1.0 + 1.0 + 0.8) / 3 = 0.93),
you'd inflate the group score by ignoring the head the exercise doesn't
actually train. Counting untrained heads as zero is the honest answer.

**This matters for substitution decisions.** When the recommender compares
"this exercise vs that one for muscle group X," group scores need to reflect
real training reality. Lat pulldown should NOT look like a 1.0 hamstring
exercise just because the user did it.

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
4. Muscle weightings — apply §2 conventions strictly. **Author against
   per-head muscle_ids** (see §13). Apply the comprehensive 0.25 rule
   and the two-question test in §2.
5. `head_emphasis_notes` — populate for any head where form distinguishes
   emphasis (grip width, foot position, elbow path, etc.). See §13.
6. Equipment + load increments — apply §5 defaults unless exercise
   warrants override.
7. Programming role — modality, default_role, session_position.
8. Performance metric — apply §9 table.
9. Demands — pick from §3 vocabulary; flag any new tag explicitly.
10. variation_attributes — apply §4; null if no axis.
11. loaded_position — apply §8 heuristic.
12. Substitutes — at least one; apply §10 rules. May reference
    not-yet-inserted exercises by name; resolve to UUIDs at insert time.

---

## 12. What NOT to do

- Do not invent new `demands` tags without flagging them.
- Do not flatten variations into one row with averaged muscle weights.
- Do not author against v1 flat muscle_ids (`triceps`, `chest`). Use per-head
  ids (`triceps_lateral`, `pectorals_sternal`). See §13.
- Do not give 1.0 to every head that "works hard" — only to the *target* head.
- Do not skip 0.25 entries for heads that go through ROM under load
  (changed from v1 — see §2 comprehensive 0.25 rule).
- Do not inflate 0.25 entries to 0.5 just to make them count toward volume.
  Use intermediate values (0.3, 0.4) honestly when contribution falls
  between tiers.
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

---

## 13. Parent/child muscle taxonomy (v2)

### Structure

The `muscles` table has a `parent_muscle_id` column that creates a
parent/child hierarchy. Use the `muscles_with_kind` view to classify:

- **Group** (e.g. `triceps`): parent row with children. No exercise should
  reference a group directly — always reference its heads.
- **Head** (e.g. `triceps_lateral`): child row with `parent_muscle_id` set.
  This is what exercises reference.
- **Singleton** (e.g. `brachialis`, `rhomboids`): no parent, no children.
  Reference directly.

Current taxonomy: 15 groups, 44 heads, 8 singletons. 67 rows total.

### Display names

User-friendly, NOT anatomical. Display name "Chest" maps to muscle_id
`pectorals`. "Lower Back" maps to `spinal_erectors`. "Abs" maps to
`rectus_abdominis`. The muscle_id is for the schema and code; the
display_name is what users see in the app.

When authoring, reference muscles by muscle_id, not display_name.

### Functional regions vs anatomical heads

Most heads are true anatomical heads (`triceps_long` is the long head of
the triceps brachii). Two exceptions are *functional regions* that we model
as heads for training purposes:

- **`lats_upper` / `lats_lower`**: the latissimus dorsi is one anatomical
  muscle with one origin and one insertion. We split it because the upper
  and lower fibers have different orientations that respond to different
  exercises (wide-grip pulls vs close-grip pulls). Not anatomically two
  heads. Treated as heads for taxonomy purposes because the training
  distinction is real and the per-head view is valuable.

- **`forearms_*`**: the four forearm "heads" are not heads of one muscle.
  They group ~20 forearm muscles into four functional categories: wrist
  flexors, wrist extensors, brachioradialis, grip (finger flexors).
  Modeled as heads under a `forearms` group because users think about the
  forearm as one body part with different training emphases.

When you find a similar case in the future (the muscle is anatomically one
unit but training-meaningfully splits), document the split here and treat
it the same way.

### Cross-listed muscles (rectus femoris)

Rectus femoris is anatomically both a quad (knee extensor) and a hip
flexor. In our taxonomy it lives under `quads` as `quads_rectus_femoris`,
not under `hip_flexors`. This avoids duplicate rows.

When authoring an exercise that trains rectus femoris via hip flexion
(hanging leg raise, etc.), list it under quads with appropriate weight and
add a `head_emphasis_notes` entry explaining that this is hip-flexion work,
not knee-extension work. The volume math doesn't care which function
trained it; the per-head total still reflects real training stress.

### Unilateral exercises: weights are per working side

A unilateral exercise row (Bulgarian split squat, single-arm row, etc.)
represents one rep on the working side. Muscle weights describe what the
working side does. The trail/non-working side is ignored.

When the user logs "4 sets of BSS," that's 4 sets per side; the per-head
volume math runs against the working-side weights. The recommender treats
unilateral sets as full sets toward weekly volume — it does NOT halve
them because both sides need recovery and the working set is the
biologically relevant unit.

### Group-level scores (recap from §2)

Group volume = mean of head weights, including unlisted heads as 0. This
makes "exercise X is bad for group Y" show up correctly when X trains
only some of Y's heads. See §2 for the full rule.

---

## 14. Authoring patterns from the v2 pilot

These are the recurring biomechanical patterns surfaced by re-authoring
the first 5 exercises (Back Squat, Pull-Up, Lateral Raise, BSS, Leg Press).
Apply them consistently across all future authoring.

### 14.1 Two-joint muscles get a discount

When a muscle crosses two joints and the exercise moves both joints in
opposing directions, the muscle is partially shortened at one joint while
lengthened at the other. The stimulus is real but smaller than a
single-joint muscle doing the same job.

- **Rectus femoris on squat / leg press**: hip flexion at the bottom
  shortens it; knee extension at the top lengthens it. Weight = 0.7-0.85
  (vs the vasti at 1.0).
- **Biceps long head on close-grip pulling**: shoulder flexion shortens
  it; elbow flexion lengthens it. Slightly de-emphasized vs short head
  on close-grip work.
- **Gastrocnemius on seated calf raise**: knee bent shortens it, so the
  stimulus is much lower. Seated calf raise weights gastroc at 0.3 or
  less; soleus gets 1.0.

When the exercise moves both joints in the SAME direction (e.g. RDL
extends both hip and knee), the two-joint muscle doesn't get this
discount — it gets full credit.

### 14.2 Bilateral vs unilateral changes abductor work dramatically

Glute medius and minimus are pure abductors. They barely fire on bilateral
compounds because the body's center of mass is between the feet — no
abduction demand. They fire hard on unilateral compounds because they're
preventing pelvic drop toward the non-working side.

- Bilateral squat: `glutes_medius` at 0.3 max. `glutes_minimus` usually
  omitted.
- Bulgarian split squat / single-leg work: `glutes_medius` at 0.6,
  `glutes_minimus` at 0.4. Real training stress.

Same pattern applies to obliques (anti-rotation is bigger on unilateral).

### 14.3 Lat region emphasis follows grip width and elbow path

`lats_upper` and `lats_lower` are functional regions distinguished by
fiber orientation. Exercise emphasis follows the elbow path:

- **Wide grip, elbows flared (wide-grip pull-up, wide-grip pulldown)**:
  upper-lat dominant. Weight upper at 1.0, lower at 0.6-0.7.
- **Close grip, elbows tucked (close-grip pulldown, straight-arm
  pulldown, neutral-grip pull-up)**: lower-lat dominant. Weight lower
  at 1.0, upper at 0.6-0.8.
- **Shoulder-width pronated pull-up (default)**: lower-lat slight
  edge. Lower 1.0, upper 0.8.
- **Rows (most variants)**: mid-emphasis. Both heads roughly equal
  (0.7-0.9 each), depending on elbow path.

### 14.4 Grip orientation routes biceps vs brachialis

The forearm position during elbow flexion routes the load through
different muscles:

- **Supinated (palms up)**: biceps-dominant. Both biceps heads at 1.0
  or near-1.0. Brachialis at 0.5. Brachioradialis at 0.3.
- **Pronated (palms down)**: brachialis and brachioradialis dominant.
  Biceps heads drop to 0.4-0.6. Brachialis at 0.7-1.0. Brachioradialis
  at 0.7-1.0.
- **Neutral (palms facing each other)**: balanced. Brachialis at 0.8-1.0.
  Brachioradialis at 0.6. Biceps heads at 0.6 each.

This is why "pronated pull-up" and "supinated chin-up" are separate
exercise rows — the upper-arm muscle distribution genuinely differs.

### 14.5 Machine isolation removes stabilizers

When a machine constrains the movement path or supports the torso,
delete the stabilizer entries that the free-weight equivalent had.

Back squat → leg press loses:
- spinal_erectors (seat supports torso)
- rectus_abdominis / obliques (no bracing demand)
- glutes_medius / minimus (no balance demand)
- forearms_grip (handles, not load)

Quad weights stay the same; only the support structure changes. This is
the cleanest example of why per-head authoring matters: the user picking
leg press over squat is making a real tradeoff, and the volume tracking
now reflects it (~same quad credit, much less glute / no core credit).

### 14.6 Form-dependent emphasis goes in `head_emphasis_notes`

Where a form choice meaningfully shifts head emphasis, document the cue.
Don't repeat anatomical truth that applies to every variant of the
exercise — only call out the cue that distinguishes head emphasis.

Good `head_emphasis_notes` entries (cue-driven):
- "Foot position low on leg press platform = vasti emphasis (this
  default). Feet high = hip-dominant, shifts to glute/hamstring."
- "Lead with the elbow, raise to ~90° — going higher shifts work to upper
  traps without adding lateral delt stimulus."
- "Wide grip emphasizes upper lats. This shoulder-width default splits
  work toward lower lats."

Skippable `head_emphasis_notes` entries:
- "The lateral head of the triceps does elbow extension." (Anatomical
  truth; not a cue.)
- "Push the weight up." (Too generic.)

### 14.7 What to deliberately NOT include

Common temptations to add muscles that shouldn't be listed:
- Isometric stabilizers with no ROM and no real load (lateral delts
  on back squat, traps on bicep curl).
- Antagonist co-contraction at trivial levels (triceps on pull-up at
  the bottom — zero-resistance extension).
- Muscles that contract but aren't loaded (hip flexors on most lifts —
  they hold leg position but don't bear load).
- Heads that would be loaded by the exercise's mechanics but aren't
  because of body position (BF short head on most knee-extension-dominant
  work — pure knee flexor, doesn't fire on knee extension).

When in doubt, skip the entry. The per-head view is more useful when
every listed head represents a real training contribution.

---

## 15. Authoring example: complete v2 exercise

Reference template showing all the v2 patterns applied. Drawn from the
pilot — see `db/seed_exercises_v1_draft.sql` for the canonical form.

**Bulgarian Split Squat** (unilateral, dumbbell, quad-dominant):

```sql
muscles JSONB:
[
  {"muscle_id": "quads_rectus_femoris",       "weight": 0.7},
  {"muscle_id": "quads_vastus_lateralis",     "weight": 1.0},
  {"muscle_id": "quads_vastus_medialis",      "weight": 1.0},
  {"muscle_id": "quads_vastus_intermedius",   "weight": 1.0},
  {"muscle_id": "glutes_max",                 "weight": 0.7},
  {"muscle_id": "glutes_medius",              "weight": 0.6},
  {"muscle_id": "glutes_minimus",             "weight": 0.4},
  {"muscle_id": "adductors_magnus",           "weight": 0.5},
  {"muscle_id": "adductors_short",            "weight": 0.4},
  {"muscle_id": "hamstrings_bf_long",         "weight": 0.3},
  {"muscle_id": "hamstrings_semitendinosus",  "weight": 0.3},
  {"muscle_id": "hamstrings_semimembranosus", "weight": 0.3},
  {"muscle_id": "spinal_erectors",            "weight": 0.3},
  {"muscle_id": "rectus_abdominis",           "weight": 0.3},
  {"muscle_id": "obliques",                   "weight": 0.4},
  {"muscle_id": "hip_flexors_iliopsoas",      "weight": 0.25},
  {"muscle_id": "hip_flexors_tfl",            "weight": 0.25},
  {"muscle_id": "calves_gastrocnemius",       "weight": 0.25},
  {"muscle_id": "calves_soleus",              "weight": 0.25},
  {"muscle_id": "forearms_grip",              "weight": 0.25}
]

head_emphasis_notes JSONB:
{
  "glutes_medius": "Big upgrade vs bilateral squat — the medius works hard to prevent the pelvis from dropping toward the rear leg. This is the muscle that's sore the day after a hard set even when you didn't feel it during the lift.",
  "obliques": "Anti-rotation work — the unilateral load wants to rotate the torso toward the working leg. Obliques fire harder than they would on a bilateral squat."
}
```

Patterns applied:
- §14.1: rectus femoris discounted (0.7) vs vasti (1.0).
- §14.2: glutes_medius (0.6) and glutes_minimus (0.4) listed because
  unilateral; obliques bumped to 0.4 for anti-rotation.
- §2 comprehensive 0.25: hamstrings, calves, hip flexors, grip all listed.
- §14.6: `head_emphasis_notes` only on the heads with form-meaningful cues
  (glute medius story, obliques explanation). Skipped for the quads (no
  unique cue here) and the small entries.
- §13 unilateral convention: weights describe one working side. The
  user's 4 sets become 4 sets per leg.
