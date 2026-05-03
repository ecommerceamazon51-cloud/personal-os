# Claude Code Batching Prompt — Exercise Seed Data, Batch 2

Paste the entire prompt below into Claude Code. It assumes the conventions
doc and the v1 draft are committed to the repo.

---

## PROMPT TO PASTE

I need you to draft the next batch of 10–15 exercises for the seed data.
Do NOT insert them into the database yet — output them as SQL INSERT
statements in a new file `db/seed_exercises_batch_2.sql` for me to review
before any insert runs.

### Required reading before you start

1. `db/seed_exercises_v1_draft.sql` — the 5 reviewed exercises. Match this
   format EXACTLY: same column order, same `'[...]'::jsonb` formatting for
   muscles, same use of `ARRAY[...]` for text arrays, same comment style.
2. `docs/exercise_authoring_conventions.md` (or wherever the conventions
   doc lives in this repo) — every rule applies. Particular attention to:
   - §1: variations are separate rows, not attributes
   - §2: muscle weighting discipline (1.0 only for true target muscles;
     0.25 only when meaningfully challenged)
   - §3: demands vocabulary is closed — flag any new tag explicitly
   - §5: all load increments in pounds (lbs)
3. `db/schema.sql` lines 269–386 — the `exercises` and
   `exercise_substitutes` table definitions, all enum values.
4. `workout_module_v1_spec.md` §18 — the spec section the schema implements.

### What to draft

A coherent batch of 12 exercises that fills out the most important gaps
in the database. Specifically:

**Squat family completion (3 exercises):**
- Barbell Back Squat — Low-Bar variant (different muscle weights from
  high-bar already in batch 1: glute-dominant, more posterior chain)
- Barbell Front Squat (more quad, more abs, less glute, thoracic demand)
- Goblet Squat (dumbbell or kettlebell, used as regression / warm-up)

**Hinge pattern (3 exercises):**
- Conventional Deadlift
- Romanian Deadlift (RDL) — barbell
- Hip Thrust — barbell

**Horizontal push (2 exercises):**
- Barbell Bench Press — Flat
- Dumbbell Bench Press — Flat

**Horizontal pull (2 exercises):**
- Barbell Bent-Over Row
- Chest-Supported Dumbbell Row (regression option)

**Vertical push (2 exercises):**
- Standing Barbell Overhead Press
- Seated Dumbbell Overhead Press

### Output format

Single SQL file with:
1. A leading comment block listing the exercises in this batch and any
   conventions notes.
2. INSERT statements for `public.exercises`, in the order listed above.
3. INSERT statements for `public.exercise_substitutes` at the end, wiring
   up at least:
   - Each squat variant connecting to back squat (batch 1) and to each
     other (`same_pattern_different_equipment` or `regression`/`progression`)
   - Conventional deadlift ↔ RDL (`same_muscles_different_pattern`)
   - Barbell bench ↔ Dumbbell bench (`same_pattern_different_equipment`)
   - Barbell row ↔ Chest-supported row (`regression` direction only)
   - Standing OHP ↔ Seated DB OHP (`same_pattern_different_equipment`)
   - 2–4 substitutes per exercise total, including cross-batch refs.

Use fixed UUIDs in the same readable scheme batch 1 used:
`aaaaaaaa-XXXX-0000-0000-000000000001` where XXXX is a zero-padded counter
starting at 0006.

Family UUIDs: keep batch 1's existing families
(`11111111-...`=squat, `22222222-...`=pullup, `44444444-...`=split squat,
`55555555-...`=leg press) and add new ones for hinge, bench, row, ohp.
Pick readable patterns: `66666666-...`=hinge_dl, `77777777-...`=hinge_rdl,
`88888888-...`=hinge_thrust, `99999999-...`=bench, `aaaaaaaa-...`=row,
`bbbbbbbb-...`=ohp.

### Decisions I want you to surface, not silently make

For each of these, either resolve per the conventions doc or flag
explicitly in a comment with your reasoning:

1. **Goblet squat muscle weights** — quads still 1.0? Or does the limited
   load (max ~1 dumbbell) change which muscle is genuinely the target?
2. **Conventional deadlift** — hamstrings 1.0 or 0.5? Glutes 1.0 or 0.5?
   Lower back: meaningful 0.5 or 1.0 here vs 0.25 on squats?
3. **RDL** — hamstrings should be 1.0 (it's the target). Glutes 1.0 or 0.5?
4. **Hip thrust** — glutes are clearly 1.0. What about hamstrings?
5. **Bench press** — chest 1.0. Triceps 0.5 or 1.0? Front delts 0.5 or
   0.25? (Conventions §2 default: triceps 0.5, front delts 0.5.)
6. **Bent-over row** — lats 1.0. What about rhomboids and mid traps —
   both 0.5, or one 1.0?
7. **OHP** — front delts 1.0. Triceps 0.5 or 1.0? Side delts: 0.5 or 0.25?
8. **Performance metric for hip thrust** — `weight_x_reps` is right but
   confirm.
9. **`relative_to_bodyweight`** — should be FALSE for everything in this
   batch (no bodyweight-loaded movements). Confirm.
10. **Loaded position for deadlift / RDL** — RDL is `stretched` (target
    is loaded at hip flexion). Conventional deadlift is more arguably
    `stretched` but could be `mid`. Pick and justify.

### Hard rules — do not violate

- DO NOT invent new `demands` tags. If a movement seems to need a tag
  not in conventions §3, add a comment `-- PROPOSED NEW DEMAND: <tag> for
  <reason>` and leave the tag out of the INSERT. I'll add it to the
  vocabulary if approved.
- DO NOT collapse variations into one row. Low-bar back squat is a
  separate row from high-bar back squat (already in batch 1).
- DO NOT use kg anywhere.
- DO NOT insert into the live database. Output the file only.
- DO NOT exceed 4 aliases per exercise.
- DO NOT add 0.25 muscle entries for every contracting muscle. Apply the
  conventions §2 discipline strictly.

### When done

Reply with:
1. The path to the file you created.
2. A bullet list of any decisions from the "Decisions to surface" section
   that you want me to confirm before the next batch.
3. A bullet list of any proposed new `demands` tags, with justification.
4. Any places where the conventions doc gave you ambiguous guidance and
   you had to make a judgment call. (Be specific — quote the line and
   say what you decided and why.)

Do not insert anything. Do not draft additional exercises beyond the 12
listed. Do not modify the conventions doc or batch 1 file.
