# Applied Migrations Log

Tracks when migrations were actually applied to the Supabase database, separate from when their PRs merged to main. Per project convention, "merged to main ≠ applied to Supabase" — this file is the source of truth for what's live.

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
- **Applied to Supabase:** NOT YET APPLIED — merge first, then apply manually via SQL Editor
- **Exercises added (IDs 66–71):**
  - #66 Cable Fly — Flat (Day 1 pump set)
  - #67 Cable Fly — Low to High (Day 5)
  - #68 Straight Arm Pulldown (Day 5, lat isolation)
  - #69 Preacher Curl — EZ Bar (Day 3)
  - #70 Cable Overhead Tricep Extension (Day 3)
  - #71 Rear Delt Fly — Cable (Day 3)
- **Also fixes:** Dumbbell Lateral Raise (#3) substitution orphan — had 0 outbound edges; adds edge to Cable Lateral Raise (#54).
- **Suggested verification queries after applying:**
  - `SELECT COUNT(*) FROM exercises;` — expect 71
  - `SELECT exercise_id, name FROM exercises WHERE exercise_id IN ('aaaaaaaa-0066-0000-0000-000000000001','aaaaaaaa-0067-0000-0000-000000000001','aaaaaaaa-0068-0000-0000-000000000001','aaaaaaaa-0069-0000-0000-000000000001','aaaaaaaa-0070-0000-0000-000000000001','aaaaaaaa-0071-0000-0000-000000000001');` — expect all 6 rows
  - `SELECT COUNT(*) FROM exercise_substitutes WHERE exercise_id = 'aaaaaaaa-0003-0000-0000-000000000001';` — expect ≥ 1 (orphan fixed)
  - Spot-check head_emphasis_notes on #69 (Preacher Curl), #70 (Overhead Ext) — expect non-null
- **Notes:** Additive-only migration (no TRUNCATE). Safe to re-run; all INSERTs use ON CONFLICT DO NOTHING.

## PR #16 — Add 3 Specialty Joint Health Exercises + Strengthen Straight Arm Pulldown Substitutes
- **File:** `db/migration_add_specialty_joint_health_exercises.sql`
- **PR:** #16
- **Merged to main:** (pending)
- **Applied to Supabase:** NOT YET APPLIED — merge first, then apply manually via SQL Editor
- **Exercises added (IDs 72–74):**
  - #72 Sissy Squat (Day 2, VMO/quad joint health; `training_modality: ['hypertrophy', 'joint_health']`)
  - #73 Tibialis Raise (Day 2, tibialis anterior joint health; `training_modality: ['hypertrophy', 'joint_health']`)
  - #74 Poliquin Step-Up (Day 2, VMO rehabilitation; `training_modality: ['hypertrophy', 'joint_health']`)
- **Also adds:** 2 additional outbound edges for Straight Arm Pulldown (#68) — PR #15 left it with only one outbound edge (→ Pull-Up). Adds #68 → Lat Pulldown (#22) at 0.70, and #68 → Seated Cable Row (#23) at 0.55.
- **⚠️ Known gap:** `tibialis_anterior` does not exist in the v2 muscles table (67-row taxonomy has no anterior compartment muscles). Exercise #73 is inserted with `muscles: '[]'` and will not contribute to volume tracking. A follow-up PR must add `tibialis_anterior` (and optionally `peroneals`) to the muscles table before #73 is useful for volume attribution.
- **Suggested verification queries after applying:**
  - `SELECT COUNT(*) FROM exercises;` — expect 74
  - `SELECT exercise_id, name FROM exercises WHERE exercise_id IN ('aaaaaaaa-0072-0000-0000-000000000001','aaaaaaaa-0073-0000-0000-000000000001','aaaaaaaa-0074-0000-0000-000000000001');` — expect all 3 rows
  - `SELECT COUNT(*) FROM exercise_substitutes WHERE exercise_id = 'aaaaaaaa-0068-0000-0000-000000000001';` — expect ≥ 3 (was 1 after PR #15; now adds 2 more)
  - `SELECT muscles FROM exercises WHERE exercise_id = 'aaaaaaaa-0072-0000-0000-000000000001';` — expect non-empty JSONB array (7 muscle entries)
  - `SELECT muscles FROM exercises WHERE exercise_id = 'aaaaaaaa-0073-0000-0000-000000000001';` — expect `[]` (known gap; tibialis_anterior not in taxonomy)
  - `SELECT head_emphasis_notes FROM exercises WHERE exercise_id IN ('aaaaaaaa-0072-0000-0000-000000000001','aaaaaaaa-0074-0000-0000-000000000001');` — expect non-null on both (#72 and #74); expect null on #73 (gap)
- **Notes:** Additive-only migration (no TRUNCATE). Safe to re-run; all INSERTs use ON CONFLICT DO NOTHING. The `knees_over_toes_tolerance` demand tag requested for #72 does not exist in the §3 vocabulary; using `deep_knee_flexion` + `ankle_dorsiflexion` instead — flag for review if a new tag is warranted.

## PR #17 — Add Anterior-Compartment Muscles + Backfill Tibialis Raise
- **File:** `db/migration_add_anterior_compartment_muscles.sql`
- **PR:** #17
- **Merged to main:** (pending)
- **Applied to Supabase:** NOT YET APPLIED — merge first, then apply manually via SQL Editor
- **Prerequisite:** PR #16 (`migration_add_specialty_joint_health_exercises.sql`) must be applied first — exercise #73 must exist as a row for the UPDATE in PART 2 to find it.
- **Muscles added:**
  - `tibialis_anterior` — singleton; prime mover of ankle dorsiflexion; anterior compartment
  - `peroneals` — singleton; covers peroneus longus + peroneus brevis; ankle eversion + lateral stability
- **Also fixes:** Tibialis Raise (#73) muscles JSONB — was `'[]'` (known gap from PR #16); now populated:
  - `tibialis_anterior: 1.0` (sole concentric mover)
  - `peroneals: 0.25` (ankle stabilizer)
- **Taxonomy state after applying:** 69 rows total (was 67); singleton count goes from 8 → 10; group and head counts unchanged.
- **Suggested verification queries after applying:**
  - `SELECT COUNT(*) FROM muscles;` — expect 69
  - `SELECT muscle_kind, COUNT(*) FROM muscles_with_kind GROUP BY muscle_kind;` — expect group=15, head=44, singleton=10
  - `SELECT muscle_id, display_name FROM muscles WHERE muscle_id IN ('tibialis_anterior', 'peroneals');` — expect both rows
  - `SELECT muscles FROM exercises WHERE exercise_id = 'aaaaaaaa-0073-0000-0000-000000000001';` — expect 2-element array (tibialis_anterior 1.0, peroneals 0.25)
  - `SELECT e.exercise_id, e.name, elem->>'muscle_id' AS missing_muscle FROM exercises e, jsonb_array_elements(e.muscles) AS elem WHERE elem->>'muscle_id' NOT IN (SELECT muscle_id FROM muscles);` — expect 0 rows
- **Notes:** Additive-only migration (no TRUNCATE). INSERTs use ON CONFLICT DO NOTHING. The UPDATE on #73 is idempotent. Resolves the `tibialis_anterior` taxonomy gap explicitly documented in PR #16.
