-- =============================================================================
-- Migration: Extend movement_pattern enum + clean up batch 1–3 closest-fit stubs
-- =============================================================================
-- Purpose: replace the six closest-fit `movement_pattern_primary` values that
-- batches 1 and 3 used as workarounds (because the enum lacked appropriate
-- isolation/anti-pattern values). After this migration, no exercise in the DB
-- uses a pattern that doesn't actually describe its mechanic.
--
-- Why now: spec §18's canonical pattern list and the schema enum both need to
-- carry the new values BEFORE batch 4 lands, because batch 4 introduces core
-- exercises (anti_extension, anti_lateral_flexion) and bodyweight isolation
-- variants that would otherwise compound the closest-fit debt.
--
-- Affected rows (all updated in this migration):
--   1. Dumbbell Lateral Raise (batch 1)   vertical_push   → shoulder_abduction
--   2. Lying Leg Curl         (batch 3)   hinge           → knee_flexion
--   3. Leg Extension          (batch 3)   squat           → knee_extension
--   4. Standing Calf Raise    (batch 3)   plyometric      → ankle_plantarflexion
--   5. Barbell Curl           (batch 3)   vertical_pull   → elbow_flexion
--   6. Triceps Pushdown       (batch 3)   vertical_push   → elbow_extension
--
-- Spec §18 follow-up: the canonical movement_pattern list in
-- docs/workout_module_v1_spec.md §18 must be updated in the same PR to add
-- the new values. The schema is the runtime source of truth, but the spec is
-- the design source of truth — keep them in sync.
--
-- Rollback: PostgreSQL does not support removing values from an enum without
-- recreating the type. If this migration needs to be rolled back, the
-- recovery path is to revert the six UPDATE statements (the new enum values
-- can stay unused). Don't try to DROP TYPE.
-- =============================================================================

-- ─── Add new enum values ────────────────────────────────────────────────────
-- IMPORTANT: ALTER TYPE ADD VALUE and any statement that REFERENCES the new
-- value cannot share a transaction. Postgres rejects this with error 55P04
-- ("unsafe use of new value ... New enum values must be committed before
-- they can be used"), even on current versions. This file is therefore
-- structured as two parts: the ADD VALUE statements run on their own
-- (auto-committed, no BEGIN/COMMIT), then a separate transaction handles
-- the UPDATEs that reference them.
--
-- To apply: run Part 1 first, wait for it to complete, then run Part 2.
-- Do NOT paste the whole file as a single query — it will fail.

-- ─── PART 1: Add new enum values (run as its own query, no transaction) ────

-- Isolation patterns (single-joint movements). The squat/hinge/push/pull
-- patterns describe multi-joint compounds; isolation work needs its own
-- patterns so the recommender can distinguish "another quad lift" from
-- "another knee-extension isolation."

ALTER TYPE movement_pattern ADD VALUE IF NOT EXISTS 'knee_flexion';
ALTER TYPE movement_pattern ADD VALUE IF NOT EXISTS 'knee_extension';
ALTER TYPE movement_pattern ADD VALUE IF NOT EXISTS 'elbow_flexion';
ALTER TYPE movement_pattern ADD VALUE IF NOT EXISTS 'elbow_extension';

-- ankle_plantarflexion: anatomically correct term for the calf-raise action
-- (rising onto toes). "Ankle extension" is ambiguous — different anatomy
-- traditions disagree on whether plantarflexion is "extension" or "flexion."
-- Plantarflexion is unambiguous. Longer to type but cheaper than confusion.
ALTER TYPE movement_pattern ADD VALUE IF NOT EXISTS 'ankle_plantarflexion';

-- shoulder_abduction: lateral raise primary action. Distinct from vertical
-- push (overhead pressing) — the lateral raise is single-joint shoulder
-- abduction, not a press.
ALTER TYPE movement_pattern ADD VALUE IF NOT EXISTS 'shoulder_abduction';

-- Anti-patterns (core stabilization). The schema already had `rotation` and
-- `anti_rotation`; adding the other two members of the anti-pattern family
-- so plank/ab wheel/hanging leg raise and side plank/suitcase carry can
-- author cleanly.
ALTER TYPE movement_pattern ADD VALUE IF NOT EXISTS 'anti_extension';
ALTER TYPE movement_pattern ADD VALUE IF NOT EXISTS 'anti_lateral_flexion';

-- ─── PART 2: Update existing rows (run as a separate query) ─────────────────
-- The ALTER TYPE statements above must be committed before this part runs.
-- These UPDATEs are wrapped in a transaction so all 6 succeed-or-fail
-- together.

BEGIN;

-- ─── Update existing rows from closest-fit stubs to correct patterns ────────

-- 1. Dumbbell Lateral Raise (batch 1)
-- Was: vertical_push (closest-fit; raise is shoulder-direction work but not
-- a press). Now: shoulder_abduction.
UPDATE public.exercises
SET movement_pattern_primary = 'shoulder_abduction',
    updated_at = NOW()
WHERE exercise_id = 'aaaaaaaa-0003-0000-0000-000000000001'
  AND name = 'Dumbbell Lateral Raise';

-- 2. Lying Leg Curl (batch 3)
-- Was: hinge (closest-fit; mechanic is knee-flexion isolation, not hip-hinge).
UPDATE public.exercises
SET movement_pattern_primary = 'knee_flexion',
    updated_at = NOW()
WHERE exercise_id = 'aaaaaaaa-0024-0000-0000-000000000001'
  AND name = 'Lying Leg Curl';

-- 3. Leg Extension (batch 3)
-- Was: squat (closest-fit; mechanic is knee-extension isolation, not
-- multi-joint squat).
UPDATE public.exercises
SET movement_pattern_primary = 'knee_extension',
    updated_at = NOW()
WHERE exercise_id = 'aaaaaaaa-0025-0000-0000-000000000001'
  AND name = 'Leg Extension';

-- 4. Standing Calf Raise (batch 3)
-- Was: plyometric (deliberately bad fit; calf raise is slow-tempo, not
-- ballistic). Now: ankle_plantarflexion. This was the worst of the six stubs.
UPDATE public.exercises
SET movement_pattern_primary = 'ankle_plantarflexion',
    updated_at = NOW()
WHERE exercise_id = 'aaaaaaaa-0026-0000-0000-000000000001'
  AND name = 'Standing Calf Raise';

-- 5. Barbell Curl (batch 3)
-- Was: vertical_pull (closest-fit; bar moves vertically toward body, but
-- mechanic is single-joint elbow flexion).
UPDATE public.exercises
SET movement_pattern_primary = 'elbow_flexion',
    updated_at = NOW()
WHERE exercise_id = 'aaaaaaaa-0027-0000-0000-000000000001'
  AND name = 'Barbell Curl';

-- 6. Triceps Pushdown (batch 3)
-- Was: vertical_push (closest-fit; cable moves vertically downward, but
-- mechanic is single-joint elbow extension).
UPDATE public.exercises
SET movement_pattern_primary = 'elbow_extension',
    updated_at = NOW()
WHERE exercise_id = 'aaaaaaaa-0028-0000-0000-000000000001'
  AND name = 'Triceps Pushdown';

-- ─── Verification queries (run after migration to confirm) ──────────────────
-- Expected: zero rows from each.
--
--   -- Should be 0: any exercise still using a stubbed pattern
--   SELECT exercise_id, name, movement_pattern_primary
--   FROM public.exercises
--   WHERE exercise_id IN (
--     'aaaaaaaa-0003-0000-0000-000000000001',
--     'aaaaaaaa-0024-0000-0000-000000000001',
--     'aaaaaaaa-0025-0000-0000-000000000001',
--     'aaaaaaaa-0026-0000-0000-000000000001',
--     'aaaaaaaa-0027-0000-0000-000000000001',
--     'aaaaaaaa-0028-0000-0000-000000000001'
--   ) AND movement_pattern_primary IN ('vertical_push', 'vertical_pull',
--                                      'hinge', 'squat', 'plyometric');
--
--   -- Should return 8 rows: all new enum values present
--   SELECT enumlabel FROM pg_enum
--   WHERE enumtypid = 'movement_pattern'::regtype
--     AND enumlabel IN ('knee_flexion', 'knee_extension', 'elbow_flexion',
--                       'elbow_extension', 'ankle_plantarflexion',
--                       'shoulder_abduction', 'anti_extension',
--                       'anti_lateral_flexion');

COMMIT;

-- ─── Post-migration TODO ────────────────────────────────────────────────────
-- 1. Update docs/workout_module_v1_spec.md §18 movement_pattern list to
--    include the 8 new values (currently lists only the original 14).
-- 2. Remove the TODO(schema) comments from the merged batch 3 SQL file
--    (or leave as historical context — author's call). The five TODO
--    comments in batch 3 referencing this migration are now resolved.
-- 3. Mark the conventions doc and CLAUDE.md if they reference the old
--    enum list anywhere.
