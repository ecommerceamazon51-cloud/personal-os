# Applied Migrations Log

Tracks when migrations were actually applied to the Supabase database, separate from when their PRs merged to main. Per project convention, "merged to main ≠ applied to Supabase" — this file is the source of truth for what's live.

## PR #4 / PR #5 — Extend movement_pattern Enum
- **File:** `db/migration_extend_movement_pattern_enum.sql`
- **PR:** #4 (initial), #5 (transaction-split fix)
- **Merged to main:** 2026-05-06
- **Applied to Supabase:** Before 2026-05-15 — confirmed applied (retroactive entry; exact apply date unknown)
- **Verification:** `SELECT enumlabel FROM pg_enum WHERE enumtypid = 'movement_pattern'::regtype AND enumlabel IN ('knee_flexion','knee_extension','elbow_flexion','elbow_extension','ankle_plantarflexion','shoulder_abduction','anti_extension','anti_lateral_flexion');` → 8 rows confirmed
- **Notes:** Retroactive log entry — this migration was never logged when applied. Proof of apply: `migration_reseed_exercises_v2.sql` (applied 2026-05-15) uses all 8 new enum values in its INSERTs; the reseed's successful application on that date proves these values were already live. Adds `knee_flexion`, `knee_extension`, `elbow_flexion`, `elbow_extension`, `ankle_plantarflexion`, `shoulder_abduction`, `anti_extension`, `anti_lateral_flexion` to the `movement_pattern` enum, and corrects 6 exercise rows from closest-fit stubs to accurate patterns. The 6 UPDATEs in Part 2 are now no-ops — the reseed re-inserted those rows with the correct values. Apply note: requires a two-step run in SQL Editor — Part 1 (ALTER TYPE) and Part 2 (BEGIN/COMMIT block) must be pasted separately due to Postgres error 55P04.

## PR A — Muscle Taxonomy v2 Schema Migration
- **File:** `db/migration_muscle_taxonomy_v2.sql`
- **PR:** #8
- **Merged to main:** 2026-05-07
- **Applied to Supabase:** 2026-05-07
- **Verification:** All 6 PART 5 queries returned expected results
  - Total muscles: 67 (was 22 in v1)
  - Kind breakdown: group:15, head:44, singleton:8
  - Zero orphan parent references
  - Zero v1 muscle_ids remaining in exercises JSONB
  - Zero exercises referencing non-existent muscle_ids
  - Display names verified user-friendly for renames (Chest, Lower Back, Abs, etc.)
- **Notes:** Schema-only changes. Per-exercise muscle distribution re-authoring deferred to PR B. The `head_emphasis_notes JSONB` column added in this migration was missing from `db/schema.sql` until PR #13 synced the file to match the live DB (no DB change — file-only).

## PR B — Muscle Taxonomy v2 Exercise Re-Authoring
- **File:** `db/migration_reseed_exercises_v2.sql`
- **PR:** #10
- **Merged to main:** 2026-05-15
- **Applied to Supabase:** 2026-05-15
- **Verification:** All 6 verification queries passed
  - Total exercises: 65
  - Total substitution edges: ~150–165
  - Zero exercises referencing group-level muscle_ids
  - Zero exercises referencing non-existent muscle_ids
  - `head_emphasis_notes` populated on all 65 exercises (0 NULL)
  - Pilot 5 spot-check matched expected muscle counts (Squat 15, Pull-Up 18, Lateral Raise 6, BSS 20, Leg Press 11)
- **Notes:** Required a follow-up fix in PR #11 (combined TRUNCATE statements) before successful application. First apply attempt failed with FK constraint error 0A000.

## PR #11 — TRUNCATE Syntax Fix (reseed migration)
- **File:** `db/migration_reseed_exercises_v2.sql`
- **PR:** #11
- **Merged to main:** 2026-05-15
- **Notes:** Two-line fix combining sequential TRUNCATE statements into one. Resolved FK constraint blocker on PR B migration. Not separately applied to Supabase — fix was applied as part of the re-run of the corrected migration.

## PR #15 — Add 6 Missing Hypertrophy Exercises + Fix Lateral Raise Orphan
- **File:** `db/migration_add_missing_hypertrophy_exercises.sql`
- **PR:** #15
- **Merged to main:** (pending)
- **Applied to Supabase:** 2026-05-19 — confirmed applied (exact apply date unknown; verified via live DB count check)
- **Exercises added (IDs 66–71):**
  - #66 Cable Fly — Flat (Day 1 pump set)
  - #67 Cable Fly — Low to High (Day 5)
  - #68 Straight Arm Pulldown (Day 5, lat isolation)
  - #69 Preacher Curl — EZ Bar (Day 3)
  - #70 Cable Overhead Tricep Extension (Day 3)
  - #71 Rear Delt Fly — Cable (Day 3)
- **Also fixes:** Dumbbell Lateral Raise (#3) substitution orphan — had 0 outbound edges; adds edge to Cable Lateral Raise (#54).
- **Verification results:**
  - `SELECT COUNT(*) FROM exercises;` → 84 (cumulative after all 4 migrations applied; this migration takes count 65 → 71)
  - `SELECT COUNT(*) FROM exercises WHERE exercise_id IN ('aaaaaaaa-0066-0000-0000-000000000001','aaaaaaaa-0067-0000-0000-000000000001','aaaaaaaa-0068-0000-0000-000000000001','aaaaaaaa-0069-0000-0000-000000000001','aaaaaaaa-0070-0000-0000-000000000001','aaaaaaaa-0071-0000-0000-000000000001');` → 6
  - `SELECT COUNT(*) FROM exercise_substitutes WHERE exercise_id = 'aaaaaaaa-0003-0000-0000-000000000001';` → ≥ 1 (lateral raise orphan fixed)
- **Notes:** Retroactive log entry — migration was applied to Supabase before this doc update; status confirmed via live DB query on 2026-05-19. Additive-only migration (no TRUNCATE). All INSERTs use ON CONFLICT DO NOTHING.

## PR #16 — Add 3 Specialty Joint Health Exercises + Strengthen Straight Arm Pulldown Substitutes
- **File:** `db/migration_add_specialty_joint_health_exercises.sql`
- **PR:** #16
- **Merged to main:** (pending)
- **Applied to Supabase:** 2026-05-19 — confirmed applied (exact apply date unknown; verified via live DB count check)
- **Exercises added (IDs 72–74):**
  - #72 Sissy Squat (Day 2, VMO/quad joint health; `training_modality: ['hypertrophy', 'joint_health']`)
  - #73 Tibialis Raise (Day 2, tibialis anterior joint health; `training_modality: ['hypertrophy', 'joint_health']`)
  - #74 Poliquin Step-Up (Day 2, VMO rehabilitation; `training_modality: ['hypertrophy', 'joint_health']`)
- **Also adds:** 2 additional outbound edges for Straight Arm Pulldown (#68) — PR #15 left it with only one outbound edge (→ Pull-Up). Adds #68 → Lat Pulldown (#22) at 0.70, and #68 → Seated Cable Row (#23) at 0.55.
- **Verification results:**
  - `SELECT COUNT(*) FROM exercises WHERE exercise_id IN ('aaaaaaaa-0072-0000-0000-000000000001','aaaaaaaa-0073-0000-0000-000000000001','aaaaaaaa-0074-0000-0000-000000000001');` → 3
  - `SELECT COUNT(*) FROM exercise_substitutes WHERE exercise_id = 'aaaaaaaa-0068-0000-0000-000000000001';` → ≥ 3 (was 1 after PR #15; this adds 2 more)
  - `SELECT muscles FROM exercises WHERE exercise_id = 'aaaaaaaa-0073-0000-0000-000000000001';` → `[{"muscle_id":"tibialis_anterior","weight":1.0},{"muscle_id":"peroneals","weight":0.25}]` (backfilled by PR #17)
- **Known gap (resolved by PR #17):** `tibialis_anterior` did not exist in the v2 muscles table when this migration was authored. Exercise #73 was inserted with `muscles: '[]'`. PR #17 adds `tibialis_anterior` to the taxonomy and backfills #73.
- **Notes:** Retroactive log entry — migration was applied to Supabase before this doc update; status confirmed via live DB query on 2026-05-19. Additive-only migration (no TRUNCATE). All INSERTs use ON CONFLICT DO NOTHING. The `knees_over_toes_tolerance` demand tag requested for #72 does not exist in the §3 vocabulary; using `deep_knee_flexion` + `ankle_dorsiflexion` instead — flag for review if a new tag is warranted.

## PR #17 — Add Anterior-Compartment Muscles + Backfill Tibialis Raise
- **File:** `db/migration_add_anterior_compartment_muscles.sql`
- **PR:** #17
- **Merged to main:** (pending)
- **Applied to Supabase:** 2026-05-19 — confirmed applied (exact apply date unknown; verified via live DB count check)
- **Prerequisite:** PR #16 (`migration_add_specialty_joint_health_exercises.sql`) must be applied first — exercise #73 must exist as a row for the UPDATE in PART 2 to find it.
- **Muscles added:**
  - `tibialis_anterior` — singleton; prime mover of ankle dorsiflexion; anterior compartment
  - `peroneals` — singleton; covers peroneus longus + peroneus brevis; ankle eversion + lateral stability
- **Also fixes:** Tibialis Raise (#73) muscles JSONB — was `'[]'` (known gap from PR #16); now populated:
  - `tibialis_anterior: 1.0` (sole concentric mover)
  - `peroneals: 0.25` (ankle stabilizer)
- **Verification results:**
  - `SELECT COUNT(*) FROM muscles;` → 69 (was 67; +2 singletons)
  - `SELECT muscle_kind, COUNT(*) FROM muscles_with_kind GROUP BY muscle_kind;` → group=15, head=44, singleton=10 (was 8)
  - `SELECT muscle_id, display_name FROM muscles WHERE muscle_id IN ('tibialis_anterior', 'peroneals');` → both rows present
  - `SELECT muscles FROM exercises WHERE exercise_id = 'aaaaaaaa-0073-0000-0000-000000000001';` → 2-element array (tibialis_anterior 1.0, peroneals 0.25)
  - Orphan check: `SELECT e.exercise_id, e.name, elem->>'muscle_id' AS missing_muscle FROM exercises e, jsonb_array_elements(e.muscles) AS elem WHERE elem->>'muscle_id' NOT IN (SELECT muscle_id FROM muscles);` → 0 rows
- **Notes:** Retroactive log entry — migration was applied to Supabase before this doc update; status confirmed via live DB query on 2026-05-19. Additive-only migration (no TRUNCATE). INSERTs use ON CONFLICT DO NOTHING. The UPDATE on #73 is idempotent. Resolves the `tibialis_anterior` taxonomy gap explicitly documented in PR #16.

## PR #18 — Add 10 Mobility/Skill/Conditioning Protocols + Fix Jump Rope
- **File:** `db/migration_add_protocols.sql`
- **PR:** #18
- **Merged to main:** (pending)
- **Applied to Supabase:** 2026-05-19 — confirmed applied (exact apply date unknown; verified via live DB count check)
- **Exercises added (IDs 75–84):**
  - #75 Shadow Boxing (`['skill', 'conditioning']`)
  - #76 Heavy Bag Rounds (`['skill', 'conditioning', 'power']`)
  - #77 Core Circuit (`['stability']`)
  - #78 Stretching / Mobility (`['mobility']`)
  - #79 Walk / Light Cardio (`['conditioning']`)
  - #80 Foam Roll Full Body (`['mobility']`)
  - #81 Hip Flexor Stretch (`['mobility', 'joint_health']`)
  - #82 Thoracic Extension (`['mobility', 'joint_health']`)
  - #83 Dead Hang (`['mobility', 'joint_health']`)
  - #84 Chin Tucks + Wall Angels (`['mobility', 'joint_health']`)
- **Also fixes:** Jump Rope (#65) — adds `'plyometric'` to training_modality (was `['conditioning', 'power']`; now `['conditioning', 'power', 'plyometric']`)
- **Verification results:**
  - `SELECT COUNT(*) FROM exercises;` → 84
  - `SELECT name FROM exercises WHERE exercise_id IN ('aaaaaaaa-0075-0000-0000-000000000001','aaaaaaaa-0076-0000-0000-000000000001','aaaaaaaa-0077-0000-0000-000000000001','aaaaaaaa-0078-0000-0000-000000000001','aaaaaaaa-0079-0000-0000-000000000001','aaaaaaaa-0080-0000-0000-000000000001','aaaaaaaa-0081-0000-0000-000000000001','aaaaaaaa-0082-0000-0000-000000000001','aaaaaaaa-0083-0000-0000-000000000001','aaaaaaaa-0084-0000-0000-000000000001') ORDER BY exercise_id;` → Shadow Boxing, Heavy Bag Rounds, Core Circuit, Stretching / Mobility, Walk / Light Cardio, Foam Roll Full Body, Hip Flexor Stretch, Thoracic Extension, Dead Hang, Chin Tucks + Wall Angels
  - `SELECT training_modality FROM exercises WHERE exercise_id = 'aaaaaaaa-0065-0000-0000-000000000001';` → `{conditioning,power,plyometric}`
- **Notes:** Retroactive log entry — migration was applied to Supabase before this doc update; status confirmed via live DB query on 2026-05-19. Additive-only migration (no TRUNCATE). All INSERTs use ON CONFLICT DO NOTHING; the UPDATE on Jump Rope is idempotent. No substitution edges added — protocols are not meaningfully substitutable in the hypertrophy sense.

---

## Verification Protocol

**When applying a new migration:**
1. Paste the full SQL file into Supabase Dashboard → SQL Editor → Run
2. Run the migration's verification query immediately after
3. Record the actual result in this doc
4. Commit the doc update in the same work session as the apply — do not leave it as a follow-up

**When auditing this doc:**
Query the live DB directly before trusting the status here. Drift like the four entries above (applied but still marked "NOT YET APPLIED") is caused by applying migrations without updating the doc in the same session. If the doc says "NOT YET APPLIED" but you suspect otherwise, run the verification query first and update the doc if the result confirms the migration is live.

**Universal orphan check** — run after any migration that touches `exercises` or `muscles`:
```sql
SELECT e.exercise_id, e.name, elem->>'muscle_id' AS missing_muscle
FROM public.exercises e, jsonb_array_elements(e.muscles) AS elem
WHERE elem->>'muscle_id' NOT IN (SELECT muscle_id FROM public.muscles);
-- Expected: 0 rows always
```
