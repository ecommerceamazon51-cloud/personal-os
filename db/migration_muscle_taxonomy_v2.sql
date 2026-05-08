-- =============================================================================
-- Migration: Muscle Taxonomy v2 — parent/child structure
-- =============================================================================
-- Purpose: replace the flat 22-muscle taxonomy with a parent/child structure
-- where each anatomical head is a first-class muscle with its own volume
-- target. The user-facing motivation: in the app, tapping a muscle group
-- shows per-head volume tracking, so a user can see "BF short head only got
-- 4 sets this week, you should add seated leg curl" rather than just
-- "hamstrings 23 sets, looks fine."
--
-- This is PR A of a two-PR sequence:
--
--   PR A (this file):
--     - Schema: add parent_muscle_id column to muscles
--     - Schema: add head_emphasis_notes column to exercises
--     - Data:   insert all new head/group/singleton rows
--     - Data:   rename muscle_ids where v2 changes them
--     - Data:   retire two v1 rows (traps_mid_lower, abductors)
--     - Data:   minimal rewrites of existing exercise JSONB references —
--               (a) rename swaps for the 6 renamed muscle_ids,
--               (b) split traps_mid_lower entries into traps_middle +
--                   traps_lower at equal weight as a holding pattern.
--               These are NOT re-authoring; per-exercise weight redistribution
--               and head_emphasis_notes population happen in PR B.
--     - View:   muscles_with_kind for derived group/head/singleton classification
--
--   PR B (separate, next):
--     - Re-author all 65 exercises in seed files in place to distribute
--       across heads with appropriate weights and head_emphasis_notes
--     - One-time data migration that truncates exercises + substitutes and
--       re-runs seeds on existing Supabase environments
--     - Update conventions doc §2 (per-head weighting, comprehensive 0.25
--       authoring, average-across-heads aggregation) and add new §13 for
--       parent/child structure
--     - Update spec §18
--
-- After PR A is applied:
--   - All v1 exercise references still resolve (chest renames to pectorals
--     via JSONB update; lats/biceps/etc. still exist as group rows)
--   - New head rows exist but no exercise references them yet
--   - Volume queries continue to work against the v1 data shape
--
-- Rollback path: revert is non-trivial because of the column adds and
-- renames. If this needs to roll back before PR B lands:
--   1. UPDATE exercises to rewrite 'pectorals' back to 'chest' in JSONB
--   2. Reverse the muscle_id renames (delts_*, spinal_erectors, rectus_abdominis)
--   3. Re-insert traps_mid_lower and abductors rows
--   4. DELETE the new head/singleton/group rows
--   5. ALTER TABLE muscles DROP COLUMN parent_muscle_id
--   6. ALTER TABLE exercises DROP COLUMN head_emphasis_notes
--   7. DROP VIEW muscles_with_kind
-- A reverse-migration file should be authored before this one is applied
-- to production if rollback is a real concern.
--
-- Transaction structure: this entire migration runs in a single transaction.
-- Unlike the movement_pattern enum extension (PR #4/#5), this migration does
-- NOT touch enum values, so the ALTER TYPE ADD VALUE / commit-before-use
-- gotcha doesn't apply here. One BEGIN/COMMIT covers everything.
-- =============================================================================

BEGIN;

-- ─── PART 1: Schema changes ─────────────────────────────────────────────────

-- 1a. Add parent_muscle_id to muscles
-- NULL = group-level row OR singleton (the muscles_with_kind view distinguishes)
-- Populated = head, points to its group's muscle_id
ALTER TABLE public.muscles
  ADD COLUMN IF NOT EXISTS parent_muscle_id TEXT
    REFERENCES public.muscles(muscle_id) ON DELETE RESTRICT;

CREATE INDEX IF NOT EXISTS idx_muscles_parent
  ON public.muscles (parent_muscle_id)
  WHERE parent_muscle_id IS NOT NULL;

-- Self-reference protection: a muscle cannot be its own parent.
-- (FK doesn't catch this — both sides resolve to the same row.)
ALTER TABLE public.muscles
  DROP CONSTRAINT IF EXISTS muscles_no_self_parent;
ALTER TABLE public.muscles
  ADD CONSTRAINT muscles_no_self_parent
    CHECK (parent_muscle_id IS NULL OR parent_muscle_id <> muscle_id);

COMMENT ON COLUMN public.muscles.parent_muscle_id IS
  'Parent muscle for the head/group structure. NULL = group-level row or singleton. Populated = anatomical head, references its group''s muscle_id. Use the muscles_with_kind view to derive group/head/singleton classification.';


-- 1b. Add head_emphasis_notes to exercises
-- Stores per-head form cues. Shape: {muscle_id: cue_text} where muscle_id
-- references one of the muscle rows in this exercise's `muscles` JSONB.
-- Example: {
--   "triceps_lateral": "Keep elbows tucked to maximize lateral head; flaring shifts toward long head.",
--   "triceps_long": "Overhead variants emphasize long head via shoulder flexion."
-- }
-- Not all heads need a cue — only ones where the form distinction matters.
-- NULL is fine for exercises with no per-head cues.
ALTER TABLE public.exercises
  ADD COLUMN IF NOT EXISTS head_emphasis_notes JSONB;

COMMENT ON COLUMN public.exercises.head_emphasis_notes IS
  'Per-head form cues for the exercise. JSONB object mapping muscle_id → cue text. Only populated for muscle heads where form distinguishes head emphasis. NULL when no per-head cues apply.';


-- ─── PART 2: v1 → v2 data transition ────────────────────────────────────────
-- Order matters here because of FK constraints (parent must exist before
-- child references it) and because some renames target rows that are about
-- to become parents.

-- 2a. Rename muscle_ids where v2 changes them.
-- chest → pectorals: a group row, was singleton in v1.
-- Display name stays user-friendly per design decision.
UPDATE public.muscles
SET muscle_id = 'pectorals',
    display_name = 'Chest'  -- user-friendly name; "Pectorals" is the muscle_id only
WHERE muscle_id = 'chest';

-- front_delts → delts_anterior, side_delts → delts_lateral, rear_delts → delts_posterior.
-- These are heads that will be parented to a new 'deltoids' group row in 2c.
-- Display names stay user-friendly ("Front Delts", "Side Delts", "Rear Delts").
UPDATE public.muscles SET muscle_id = 'delts_anterior'  WHERE muscle_id = 'front_delts';
UPDATE public.muscles SET muscle_id = 'delts_lateral'   WHERE muscle_id = 'side_delts';
UPDATE public.muscles SET muscle_id = 'delts_posterior' WHERE muscle_id = 'rear_delts';

-- lower_back → spinal_erectors: anatomically accurate muscle_id, display
-- stays "Lower Back" for users.
UPDATE public.muscles
SET muscle_id = 'spinal_erectors',
    display_name = 'Lower Back'
WHERE muscle_id = 'lower_back';

-- abs → rectus_abdominis: anatomically accurate muscle_id, display stays "Abs".
UPDATE public.muscles
SET muscle_id = 'rectus_abdominis',
    display_name = 'Abs'
WHERE muscle_id = 'abs';

-- 2b. Update existing exercise JSONB references for the renamed muscle_ids.
-- This is necessary because the muscles JSONB doesn't have an FK and won't
-- update via cascade. We're rewriting v1 exercise references to the new
-- v1-equivalent muscle_ids; full re-distribution to heads happens in PR B.
--
-- jsonb_set with a path is not enough here because we're rewriting nested
-- object values inside an array. Strategy: rebuild the array element by
-- element, swapping muscle_id where it matches.

UPDATE public.exercises
SET muscles = (
  SELECT jsonb_agg(
    CASE
      WHEN elem->>'muscle_id' = 'chest'       THEN jsonb_set(elem, '{muscle_id}', '"pectorals"')
      WHEN elem->>'muscle_id' = 'front_delts' THEN jsonb_set(elem, '{muscle_id}', '"delts_anterior"')
      WHEN elem->>'muscle_id' = 'side_delts'  THEN jsonb_set(elem, '{muscle_id}', '"delts_lateral"')
      WHEN elem->>'muscle_id' = 'rear_delts'  THEN jsonb_set(elem, '{muscle_id}', '"delts_posterior"')
      WHEN elem->>'muscle_id' = 'lower_back'  THEN jsonb_set(elem, '{muscle_id}', '"spinal_erectors"')
      WHEN elem->>'muscle_id' = 'abs'         THEN jsonb_set(elem, '{muscle_id}', '"rectus_abdominis"')
      ELSE elem
    END
  )
  FROM jsonb_array_elements(muscles) AS elem
),
updated_at = NOW()
WHERE muscles @> '[{"muscle_id": "chest"}]'
   OR muscles @> '[{"muscle_id": "front_delts"}]'
   OR muscles @> '[{"muscle_id": "side_delts"}]'
   OR muscles @> '[{"muscle_id": "rear_delts"}]'
   OR muscles @> '[{"muscle_id": "lower_back"}]'
   OR muscles @> '[{"muscle_id": "abs"}]';

-- 2c. Insert new group-level rows that don't exist yet in v1.
-- (deltoids is new; pectorals, spinal_erectors, rectus_abdominis already
-- exist via 2a renames. Most v1 muscle rows like quads/hamstrings/glutes
-- already exist and just need to be re-classified as groups by virtue of
-- having children — no UPDATE needed for them.)

INSERT INTO public.muscles (muscle_id, display_name, parent_muscle_id) VALUES
  ('deltoids', 'Deltoids', NULL),
  ('traps',    'Trapezius', NULL),  -- new group; v1 had only traps_upper and traps_mid_lower as flat rows
  ('rotator_cuff', 'Rotator Cuff', NULL)  -- entirely new
ON CONFLICT (muscle_id) DO NOTHING;

-- 2d. Now parent the existing delt rows to the new deltoids group.
UPDATE public.muscles SET parent_muscle_id = 'deltoids' WHERE muscle_id IN
  ('delts_anterior', 'delts_lateral', 'delts_posterior');

-- 2e. Handle traps. v1 has traps_upper (kept, parent to 'traps') and
-- traps_mid_lower (retired, split into traps_middle + traps_lower).
-- Before retiring traps_mid_lower we redistribute exercise references:
-- each exercise referencing traps_mid_lower gets its single entry replaced
-- by two entries (traps_middle + traps_lower) at the same weight.
-- This is a holding pattern; PR B will revisit weights per-exercise based
-- on the actual movement (rows favor middle, Y-raises favor lower, etc.).
--
-- LATERAL is required here because we're calling jsonb_array_elements on
-- a column from the outer UPDATE — without LATERAL, the subquery can't see
-- the outer row's `muscles` value.

UPDATE public.exercises e
SET muscles = sub.new_muscles,
    updated_at = NOW()
FROM (
  SELECT
    e2.exercise_id,
    (
      -- Keep all entries that aren't traps_mid_lower
      SELECT jsonb_agg(elem)
      FROM jsonb_array_elements(e2.muscles) AS elem
      WHERE elem->>'muscle_id' <> 'traps_mid_lower'
    )
    ||
    (
      -- Append traps_middle + traps_lower for each traps_mid_lower entry
      -- (there should only ever be one per exercise, but the SQL handles
      -- the general case)
      SELECT jsonb_agg(replacement)
      FROM jsonb_array_elements(e2.muscles) AS old_elem,
           LATERAL (
             VALUES
               (jsonb_build_object('muscle_id', 'traps_middle',
                                   'weight', (old_elem->>'weight')::numeric)),
               (jsonb_build_object('muscle_id', 'traps_lower',
                                   'weight', (old_elem->>'weight')::numeric))
           ) AS r(replacement)
      WHERE old_elem->>'muscle_id' = 'traps_mid_lower'
    )
    AS new_muscles
  FROM public.exercises e2
  WHERE e2.muscles @> '[{"muscle_id": "traps_mid_lower"}]'
) sub
WHERE e.exercise_id = sub.exercise_id;

-- Now insert traps_middle + traps_lower as new heads, and re-parent traps_upper.
INSERT INTO public.muscles (muscle_id, display_name, parent_muscle_id) VALUES
  ('traps_middle', 'Mid Traps',   'traps'),
  ('traps_lower',  'Lower Traps', 'traps')
ON CONFLICT (muscle_id) DO NOTHING;

UPDATE public.muscles SET parent_muscle_id = 'traps' WHERE muscle_id = 'traps_upper';

-- Now traps_mid_lower can safely be deleted (no exercise references it,
-- no FK pointing at it from parent_muscle_id).
DELETE FROM public.muscles WHERE muscle_id = 'traps_mid_lower';

-- 2f. Handle abductors retirement.
-- v1 abductors row → folded into glute medius/minimus.
-- We don't redistribute existing exercise references here because abductors
-- isn't currently used by any exercise in batches 1-5 (verify with the
-- query in PART 4). If it WAS used, PR B's per-exercise re-authoring would
-- handle it cleanly. We just delete the row.
DELETE FROM public.muscles WHERE muscle_id = 'abductors';


-- ─── PART 3: Insert all new head and singleton rows ────────────────────────
-- Order: parent groups already exist (either kept from v1 or inserted in 2c).
-- Now we insert heads under those parents, plus the new singletons.

-- Quads heads (parent: quads, kept from v1)
INSERT INTO public.muscles (muscle_id, display_name, parent_muscle_id) VALUES
  ('quads_rectus_femoris',     'Rectus Femoris',     'quads'),
  ('quads_vastus_lateralis',   'Vastus Lateralis',   'quads'),
  ('quads_vastus_medialis',    'Vastus Medialis',    'quads'),
  ('quads_vastus_intermedius', 'Vastus Intermedius', 'quads')
ON CONFLICT (muscle_id) DO NOTHING;

-- Hamstrings heads (parent: hamstrings, kept from v1)
INSERT INTO public.muscles (muscle_id, display_name, parent_muscle_id) VALUES
  ('hamstrings_bf_long',         'Biceps Femoris (Long Head)',  'hamstrings'),
  ('hamstrings_bf_short',        'Biceps Femoris (Short Head)', 'hamstrings'),
  ('hamstrings_semitendinosus',  'Semitendinosus',              'hamstrings'),
  ('hamstrings_semimembranosus', 'Semimembranosus',             'hamstrings')
ON CONFLICT (muscle_id) DO NOTHING;

-- Glutes heads (parent: glutes, kept from v1)
INSERT INTO public.muscles (muscle_id, display_name, parent_muscle_id) VALUES
  ('glutes_max',     'Glute Max',     'glutes'),
  ('glutes_medius',  'Glute Medius',  'glutes'),
  ('glutes_minimus', 'Glute Minimus', 'glutes')
ON CONFLICT (muscle_id) DO NOTHING;

-- Calves heads (parent: calves, kept from v1)
INSERT INTO public.muscles (muscle_id, display_name, parent_muscle_id) VALUES
  ('calves_gastrocnemius', 'Gastrocnemius', 'calves'),
  ('calves_soleus',        'Soleus',        'calves')
ON CONFLICT (muscle_id) DO NOTHING;

-- Adductors heads (parent: adductors, kept from v1)
INSERT INTO public.muscles (muscle_id, display_name, parent_muscle_id) VALUES
  ('adductors_magnus', 'Adductor Magnus', 'adductors'),
  ('adductors_short',  'Short Adductors', 'adductors')
ON CONFLICT (muscle_id) DO NOTHING;

-- Hip flexor heads (parent: hip_flexors, kept from v1)
INSERT INTO public.muscles (muscle_id, display_name, parent_muscle_id) VALUES
  ('hip_flexors_iliopsoas',  'Iliopsoas',           'hip_flexors'),
  ('hip_flexors_tfl',        'TFL',                 'hip_flexors'),
  ('hip_flexors_sartorius',  'Sartorius',           'hip_flexors')
ON CONFLICT (muscle_id) DO NOTHING;

-- Pectoral heads (parent: pectorals, renamed from chest in 2a)
INSERT INTO public.muscles (muscle_id, display_name, parent_muscle_id) VALUES
  ('pectorals_clavicular', 'Upper Chest',  'pectorals'),
  ('pectorals_sternal',    'Mid Chest',    'pectorals'),
  ('pectorals_abdominal',  'Lower Chest',  'pectorals')
ON CONFLICT (muscle_id) DO NOTHING;

-- Lats functional regions (parent: lats, kept from v1)
-- Note: these are functional regions, not anatomical heads. Documented in
-- the conventions doc.
INSERT INTO public.muscles (muscle_id, display_name, parent_muscle_id) VALUES
  ('lats_upper', 'Upper Lats', 'lats'),
  ('lats_lower', 'Lower Lats', 'lats')
ON CONFLICT (muscle_id) DO NOTHING;

-- Biceps heads (parent: biceps, kept from v1)
INSERT INTO public.muscles (muscle_id, display_name, parent_muscle_id) VALUES
  ('biceps_long',  'Biceps Long Head',  'biceps'),
  ('biceps_short', 'Biceps Short Head', 'biceps')
ON CONFLICT (muscle_id) DO NOTHING;

-- Triceps heads (parent: triceps, kept from v1)
INSERT INTO public.muscles (muscle_id, display_name, parent_muscle_id) VALUES
  ('triceps_long',    'Triceps Long Head',    'triceps'),
  ('triceps_lateral', 'Triceps Lateral Head', 'triceps'),
  ('triceps_medial',  'Triceps Medial Head',  'triceps')
ON CONFLICT (muscle_id) DO NOTHING;

-- Forearms heads (parent: forearms, kept from v1)
INSERT INTO public.muscles (muscle_id, display_name, parent_muscle_id) VALUES
  ('forearms_wrist_flexors',   'Wrist Flexors',   'forearms'),
  ('forearms_wrist_extensors', 'Wrist Extensors', 'forearms'),
  ('forearms_brachioradialis', 'Brachioradialis', 'forearms'),
  ('forearms_grip',            'Grip',            'forearms')
ON CONFLICT (muscle_id) DO NOTHING;

-- Neck heads (parent: neck, kept from v1)
INSERT INTO public.muscles (muscle_id, display_name, parent_muscle_id) VALUES
  ('neck_flexors',   'Neck Flexors',   'neck'),
  ('neck_extensors', 'Neck Extensors', 'neck')
ON CONFLICT (muscle_id) DO NOTHING;

-- Rotator cuff heads (parent: rotator_cuff, new in 2c)
INSERT INTO public.muscles (muscle_id, display_name, parent_muscle_id) VALUES
  ('rotator_cuff_supraspinatus', 'Supraspinatus', 'rotator_cuff'),
  ('rotator_cuff_infraspinatus', 'Infraspinatus', 'rotator_cuff'),
  ('rotator_cuff_teres_minor',   'Teres Minor',   'rotator_cuff'),
  ('rotator_cuff_subscapularis', 'Subscapularis', 'rotator_cuff')
ON CONFLICT (muscle_id) DO NOTHING;

-- New singletons (parent_muscle_id = NULL by default)
INSERT INTO public.muscles (muscle_id, display_name) VALUES
  ('teres_major',          'Teres Major'),
  ('serratus_anterior',    'Serratus Anterior'),
  ('brachialis',           'Brachialis'),
  ('transverse_abdominis', 'Transverse Abs')
ON CONFLICT (muscle_id) DO NOTHING;


-- ─── PART 4: View for derived group/head/singleton classification ──────────
-- Per design discussion: don't add a `muscle_kind` column (avoids two
-- sources of truth). Compute the classification in a view.

CREATE OR REPLACE VIEW public.muscles_with_kind AS
SELECT
  m.muscle_id,
  m.display_name,
  m.parent_muscle_id,
  CASE
    WHEN m.parent_muscle_id IS NOT NULL THEN 'head'
    WHEN EXISTS (
      SELECT 1 FROM public.muscles c WHERE c.parent_muscle_id = m.muscle_id
    ) THEN 'group'
    ELSE 'singleton'
  END AS muscle_kind
FROM public.muscles m;

COMMENT ON VIEW public.muscles_with_kind IS
  'Adds derived muscle_kind classification (group/head/singleton) to the muscles table. Use this view in queries that need to filter by kind. The classification is derived from parent_muscle_id presence and child existence — never stored to avoid two-sources-of-truth bugs.';


COMMIT;


-- ─── PART 5: Verification queries (run after migration) ────────────────────
-- All should return zero rows or the expected counts. Not part of the
-- transaction; run manually to confirm.
--
-- Expected v2 row breakdown:
--   15 groups: quads, hamstrings, glutes, calves, adductors, hip_flexors,
--              pectorals, lats, biceps, triceps, forearms, neck,
--              deltoids, traps, rotator_cuff
--   44 heads:  4 quad + 4 ham + 3 glute + 2 calf + 2 add + 3 hf
--              + 3 pec + 2 lat + 2 bi + 3 tri + 4 forearm + 2 neck
--              + 3 delt + 3 trap + 4 rotator_cuff
--   8 singletons: rhomboids, spinal_erectors, rectus_abdominis, obliques,
--                 teres_major, serratus_anterior, brachialis, transverse_abdominis
--   TOTAL: 67 rows

-- Expected: 67
-- SELECT COUNT(*) FROM public.muscles;

-- Expected: group=15, head=44, singleton=8
-- SELECT muscle_kind, COUNT(*) FROM public.muscles_with_kind GROUP BY muscle_kind;

-- Expected: zero rows (no orphan parent references)
-- SELECT muscle_id, parent_muscle_id FROM public.muscles
-- WHERE parent_muscle_id IS NOT NULL
--   AND parent_muscle_id NOT IN (SELECT muscle_id FROM public.muscles);

-- Expected: zero rows (no v1 muscle_ids remaining in exercises JSONB)
-- SELECT exercise_id, name, muscles FROM public.exercises
-- WHERE muscles @> '[{"muscle_id": "chest"}]'
--    OR muscles @> '[{"muscle_id": "front_delts"}]'
--    OR muscles @> '[{"muscle_id": "side_delts"}]'
--    OR muscles @> '[{"muscle_id": "rear_delts"}]'
--    OR muscles @> '[{"muscle_id": "lower_back"}]'
--    OR muscles @> '[{"muscle_id": "abs"}]'
--    OR muscles @> '[{"muscle_id": "traps_mid_lower"}]'
--    OR muscles @> '[{"muscle_id": "abductors"}]';

-- Expected: zero rows (no exercise references a muscle_id that doesn't exist)
-- SELECT e.exercise_id, e.name, elem->>'muscle_id' AS missing_muscle
-- FROM public.exercises e,
--      jsonb_array_elements(e.muscles) AS elem
-- WHERE elem->>'muscle_id' NOT IN (SELECT muscle_id FROM public.muscles);

-- Sanity check — display names for v2 muscle_ids should be user-friendly:
--   Expected: rectus_abdominis → "Abs", spinal_erectors → "Lower Back",
--             pectorals → "Chest", delts_anterior → "Front Delts", etc.
-- SELECT muscle_id, display_name FROM public.muscles
-- WHERE muscle_id IN ('rectus_abdominis', 'spinal_erectors', 'pectorals',
--                     'delts_anterior', 'delts_lateral', 'delts_posterior')
-- ORDER BY muscle_id;


-- ─── Post-migration TODO ────────────────────────────────────────────────────
-- 1. Apply this migration to Supabase via SQL Editor (PR A merges to main
--    when applied + verified, NOT when merged to git — same convention as PR #5).
-- 2. PR B: re-author all 65 exercises across 5 seed files in place. Fill in
--    head_emphasis_notes per exercise. Update conventions doc §2 + new §13.
-- 3. PR B includes a one-time data migration that TRUNCATEs exercises +
--    exercise_substitutes and re-runs the rewritten seed files, so existing
--    Supabase environments pick up the v2 muscle distributions.
