-- =============================================================================
-- Migration 034b Part 2 — 9 gap-fill exercises (catalog coverage)
-- =============================================================================
-- RUN ONLY AFTER part 1 has committed.
-- Postgres error 55P04 will occur if you paste both parts as one query.
--
-- Purpose: add one dedicated exercise per uncovered muscle head, so
-- generateAutoPlan no longer emits "no exercises in catalog" warnings for:
--   neck_flexors, neck_extensors, forearms_wrist_flexors,
--   forearms_wrist_extensors, peroneals, glutes_minimus, serratus_anterior,
--   glutes_medius, hip_flexors_iliopsoas
--
-- Warning-clearance constraint: each exercise's target head must be the
-- getStrongestHead() winner — i.e. the sole max qualifying weight (≥0.5) or
-- the alphabetically-first muscle among those tied at max weight.
-- All 9 exercises below satisfy this as sole-winner at 1.0.
--
-- ID space: 0085–0093. IDs 0001–0084 are taken. IDs 0085–0093 confirmed
-- unused in live DB (102 live exercises include a 1001–1019 block not in SQL).
--
-- Family UUIDs (new families, no prior exercises share them):
--   bbbbbbbb-0001 → neck exercises (#85, #86)
--   bbbbbbbb-0002 → wrist exercises (#87, #88)
--   bbbbbbbb-0003 → ankle eversion (#89)
--   bbbbbbbb-0004 → hip abduction (#90, #92)
--   bbbbbbbb-0005 → serratus (#91)
--   bbbbbbbb-0006 → hip flexor (#93)
-- =============================================================================

-- ─── #85 Weighted Neck Flexion — clears: neck_flexors ────────────────────────
-- getStrongestHead winner: neck_flexors (1.0, sole qualifying head)
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position, authored_by, verified
) VALUES (
  'aaaaaaaa-0085-0000-0000-000000000001',
  'Weighted Neck Flexion',
  ARRAY['neck flexion', 'plate neck flexion', 'lying neck curl'],
  'lifting',
  'neck_flexion', NULL, 'bilateral',
  '[
    {"muscle_id": "neck_flexors", "weight": 1.0}
  ]'::jsonb,
  NULL,
  'bodyweight', 'weight plate or neck harness', 2.50, 1.25,
  ARRAY['hypertrophy', 'joint_health'], 'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::text[], '[]'::jsonb,
  'bbbbbbbb-0001-0000-0000-000000000001', NULL,
  'stretched', 'system', FALSE
) ON CONFLICT (exercise_id) DO NOTHING;

-- ─── #86 Weighted Neck Extension — clears: neck_extensors ────────────────────
-- getStrongestHead winner: neck_extensors (1.0); traps_upper at 0.25 is below
-- the ≥0.5 qualifying threshold and does not compete.
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position, authored_by, verified
) VALUES (
  'aaaaaaaa-0086-0000-0000-000000000001',
  'Weighted Neck Extension',
  ARRAY['neck extension', 'plate neck extension', 'prone neck extension'],
  'lifting',
  'neck_extension', NULL, 'bilateral',
  '[
    {"muscle_id": "neck_extensors", "weight": 1.0},
    {"muscle_id": "traps_upper",    "weight": 0.25}
  ]'::jsonb,
  NULL,
  'bodyweight', 'weight plate or neck harness', 2.50, 1.25,
  ARRAY['hypertrophy', 'joint_health'], 'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::text[], '[]'::jsonb,
  'bbbbbbbb-0001-0000-0000-000000000001', NULL,
  'stretched', 'system', FALSE
) ON CONFLICT (exercise_id) DO NOTHING;

-- ─── #87 Wrist Curl — clears: forearms_wrist_flexors ─────────────────────────
-- getStrongestHead winner: forearms_wrist_flexors (1.0); grip at 0.4 and
-- brachioradialis at 0.25 are both below the ≥0.5 qualifying threshold.
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position, authored_by, verified
) VALUES (
  'aaaaaaaa-0087-0000-0000-000000000001',
  'Wrist Curl',
  ARRAY['wrist flexion', 'dumbbell wrist curl', 'seated wrist curl', 'barbell wrist curl'],
  'lifting',
  'wrist_flexion', NULL, 'bilateral',
  '[
    {"muscle_id": "forearms_wrist_flexors",   "weight": 1.0},
    {"muscle_id": "forearms_grip",            "weight": 0.4},
    {"muscle_id": "forearms_brachioradialis", "weight": 0.25}
  ]'::jsonb,
  NULL,
  'dumbbell', NULL, 2.50, 1.25,
  ARRAY['hypertrophy', 'joint_health'], 'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::text[], '[]'::jsonb,
  'bbbbbbbb-0002-0000-0000-000000000001', NULL,
  'stretched', 'system', FALSE
) ON CONFLICT (exercise_id) DO NOTHING;

-- ─── #88 Reverse Wrist Curl — clears: forearms_wrist_extensors ───────────────
-- getStrongestHead winner: forearms_wrist_extensors (1.0); brachioradialis at
-- 0.25 and grip at 0.25 are both below the ≥0.5 qualifying threshold.
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position, authored_by, verified
) VALUES (
  'aaaaaaaa-0088-0000-0000-000000000001',
  'Reverse Wrist Curl',
  ARRAY['wrist extension', 'dumbbell reverse wrist curl', 'wrist extensor curl'],
  'lifting',
  'wrist_extension', NULL, 'bilateral',
  '[
    {"muscle_id": "forearms_wrist_extensors", "weight": 1.0},
    {"muscle_id": "forearms_brachioradialis", "weight": 0.25},
    {"muscle_id": "forearms_grip",            "weight": 0.25}
  ]'::jsonb,
  NULL,
  'dumbbell', NULL, 2.50, 1.25,
  ARRAY['hypertrophy', 'joint_health'], 'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::text[], '[]'::jsonb,
  'bbbbbbbb-0002-0000-0000-000000000001', NULL,
  'stretched', 'system', FALSE
) ON CONFLICT (exercise_id) DO NOTHING;

-- ─── #89 Ankle Eversion — clears: peroneals ──────────────────────────────────
-- getStrongestHead winner: peroneals (1.0, sole qualifying head)
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position, authored_by, verified
) VALUES (
  'aaaaaaaa-0089-0000-0000-000000000001',
  'Ankle Eversion',
  ARRAY['ankle eversion', 'cable ankle eversion', 'peroneal raise', 'peroneal strengthening'],
  'lifting',
  'ankle_eversion', NULL, 'unilateral',
  '[
    {"muscle_id": "peroneals", "weight": 1.0}
  ]'::jsonb,
  NULL,
  'cable', 'cable ankle cuff or resistance band', 5.00, 2.50,
  ARRAY['joint_health', 'hypertrophy'], 'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::text[], '[]'::jsonb,
  'bbbbbbbb-0003-0000-0000-000000000001', NULL,
  'stretched', 'system', FALSE
) ON CONFLICT (exercise_id) DO NOTHING;

-- ─── #90 Hip Abduction Machine — clears: glutes_minimus ──────────────────────
-- Also covers glutes_medius at 0.9, but medius is cleared by #92 (sole winner
-- there at 1.0). Having two exercises in the same family for the same gap heads
-- is intentional — #90 primary target is minimus, #92 is medius.
--
-- Weight layout: glutes_minimus=1.0 (sole getStrongestHead winner — no ties),
-- glutes_medius=0.9 (qualifying but not top), hip_flexors_tfl=0.7 (qualifying),
-- glutes_max=0.25 (below threshold, not qualifying).
--
-- Why not both at 1.0: glutes_medius < glutes_minimus alphabetically, so if
-- tied, medius wins the tiebreak and minimus stays without a primary-path
-- candidate. Setting minimus to sole 1.0 avoids that dependency entirely.
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position, authored_by, verified
) VALUES (
  'aaaaaaaa-0090-0000-0000-000000000001',
  'Hip Abduction — Machine',
  ARRAY['hip abduction', 'machine hip abduction', 'outer thigh machine', 'seated hip abduction'],
  'lifting',
  'hip_abduction', NULL, 'bilateral',
  '[
    {"muscle_id": "glutes_minimus",  "weight": 1.0},
    {"muscle_id": "glutes_medius",   "weight": 0.9},
    {"muscle_id": "hip_flexors_tfl", "weight": 0.7},
    {"muscle_id": "glutes_max",      "weight": 0.25}
  ]'::jsonb,
  '{
    "glutes_minimus": "Co-primary hip abductor alongside the medius — both muscles dominate hip abduction and cannot be independently isolated in machine work. Minimus set as sole top-weight (1.0) so it is the getStrongestHead winner; medius at 0.9 is cleared by Lateral Band Walk (#92)."
  }'::jsonb,
  'machine', NULL, 10.00, 5.00,
  ARRAY['hypertrophy', 'stability'], 'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::text[], '[]'::jsonb,
  'bbbbbbbb-0004-0000-0000-000000000001', NULL,
  'stretched', 'system', FALSE
) ON CONFLICT (exercise_id) DO NOTHING;

-- ─── #91 Serratus Punch — clears: serratus_anterior ──────────────────────────
-- getStrongestHead winner: serratus_anterior (1.0); pectorals_sternal and
-- delts_anterior both at 0.25, below the ≥0.5 qualifying threshold.
-- Uses existing pattern horizontal_push — no new enum value needed.
-- Execution: arm extended at start, drive scapula into end-range protraction
-- against cable resistance. The press muscles are passive; serratus is the
-- only agonist.
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position, authored_by, verified
) VALUES (
  'aaaaaaaa-0091-0000-0000-000000000001',
  'Serratus Punch',
  ARRAY['serratus punch', 'cable serratus punch', 'scapular protraction press', 'serratus press'],
  'lifting',
  'horizontal_push', NULL, 'unilateral',
  '[
    {"muscle_id": "serratus_anterior", "weight": 1.0},
    {"muscle_id": "pectorals_sternal", "weight": 0.25},
    {"muscle_id": "delts_anterior",    "weight": 0.25}
  ]'::jsonb,
  '{
    "serratus_anterior": "Arm is already extended at the start — this is pure end-range scapular protraction against cable resistance, not a press. Drive the shoulder blade forward after the arm is locked out. The pec and front delt are passengers; serratus is the only agonist."
  }'::jsonb,
  'cable', NULL, 5.00, 2.50,
  ARRAY['hypertrophy', 'joint_health'], 'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::text[], '[]'::jsonb,
  'bbbbbbbb-0005-0000-0000-000000000001', NULL,
  'shortened', 'system', FALSE
) ON CONFLICT (exercise_id) DO NOTHING;

-- ─── #92 Lateral Band Walk — clears: glutes_medius ───────────────────────────
-- getStrongestHead winner: glutes_medius (1.0, sole head at max weight).
-- hip_flexors_tfl=0.7, glutes_minimus=0.5 — both qualify but are below max.
-- Same family as #90 (hip_abduction). #90 clears minimus; this clears medius.
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position, authored_by, verified
) VALUES (
  'aaaaaaaa-0092-0000-0000-000000000001',
  'Lateral Band Walk',
  ARRAY['band walk', 'lateral walk', 'monster walk', 'crab walk', 'side band walk'],
  'lifting',
  'hip_abduction', NULL, 'alternating',
  '[
    {"muscle_id": "glutes_medius",         "weight": 1.0},
    {"muscle_id": "hip_flexors_tfl",       "weight": 0.7},
    {"muscle_id": "glutes_minimus",        "weight": 0.5},
    {"muscle_id": "glutes_max",            "weight": 0.3},
    {"muscle_id": "quads_vastus_lateralis","weight": 0.25},
    {"muscle_id": "calves_gastrocnemius",  "weight": 0.25}
  ]'::jsonb,
  '{
    "glutes_medius": "Band above the knees shifts load toward the hip joint — more medius, less TFL. Band at ankles increases the TFL share. Above knees is the standard prescription for glute medius emphasis."
  }'::jsonb,
  'band', 'resistance band above knees or at ankles', NULL, NULL,
  ARRAY['hypertrophy', 'stability'], 'isolation', 'late',
  'reps_only', TRUE, FALSE,
  ARRAY['unilateral_balance'], '[]'::jsonb,
  'bbbbbbbb-0004-0000-0000-000000000001', NULL,
  'mid', 'system', FALSE
) ON CONFLICT (exercise_id) DO NOTHING;

-- ─── #93 Weighted Hanging Knee Raise — clears: hip_flexors_iliopsoas ─────────
-- getStrongestHead winner: hip_flexors_iliopsoas (1.0, sole head at max weight).
-- Qualifying heads: iliopsoas=1.0, rectus_abdominis=0.6, hip_flexors_tfl=0.5,
-- quads_rectus_femoris=0.5, transverse_abdominis=0.5 — all below 1.0.
-- Uses existing pattern anti_extension — no new enum value needed.
-- quads_rectus_femoris listed under quads per §13 taxonomy convention (cross-
-- listed muscle trained as hip flexor here, not as knee extensor).
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position, authored_by, verified
) VALUES (
  'aaaaaaaa-0093-0000-0000-000000000001',
  'Weighted Hanging Knee Raise',
  ARRAY['hanging knee raise', 'weighted knee raise', 'weighted hanging knee curl', 'loaded knee raise'],
  'lifting',
  'anti_extension', NULL, 'bilateral',
  '[
    {"muscle_id": "hip_flexors_iliopsoas",  "weight": 1.0},
    {"muscle_id": "rectus_abdominis",       "weight": 0.6},
    {"muscle_id": "hip_flexors_tfl",        "weight": 0.5},
    {"muscle_id": "quads_rectus_femoris",   "weight": 0.5},
    {"muscle_id": "transverse_abdominis",   "weight": 0.5},
    {"muscle_id": "forearms_grip",          "weight": 0.4},
    {"muscle_id": "obliques",               "weight": 0.25}
  ]'::jsonb,
  '{
    "hip_flexors_iliopsoas": "Bent knee shifts the limiting factor from abs to iliopsoas — the straight-leg version is an abs exercise; the knee raise is a hip flexor exercise. External load (dumbbell between feet or ankle weight) loads the iliopsoas, not the rectus.",
    "quads_rectus_femoris": "Hip flexion stimulus on rectus femoris — listed under quads per taxonomy convention (cross-listed muscle). The training stimulus here is hip flexion, not knee extension."
  }'::jsonb,
  'bodyweight', 'pull-up bar; dumbbell between feet or ankle weight', 2.50, 1.25,
  ARRAY['hypertrophy', 'stability'], 'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['grip_intensive'], '[]'::jsonb,
  'bbbbbbbb-0006-0000-0000-000000000001', NULL,
  'stretched', 'system', FALSE
) ON CONFLICT (exercise_id) DO NOTHING;

-- =============================================================================
-- Post-apply verification — run in Supabase SQL Editor after both parts apply
-- =============================================================================
--
-- 1. Confirm 6 new enum values exist (expected: 6 rows)
--
--   SELECT enumlabel
--   FROM pg_enum
--   WHERE enumtypid = 'movement_pattern'::regtype
--     AND enumlabel IN (
--       'neck_flexion', 'neck_extension',
--       'wrist_flexion', 'wrist_extension',
--       'hip_abduction', 'ankle_eversion'
--     )
--   ORDER BY enumlabel;
--
-- 2. Confirm all 9 exercises were inserted (expected: 9 rows)
--
--   SELECT exercise_id, name, movement_pattern_primary
--   FROM public.exercises
--   WHERE exercise_id IN (
--     'aaaaaaaa-0085-0000-0000-000000000001',
--     'aaaaaaaa-0086-0000-0000-000000000001',
--     'aaaaaaaa-0087-0000-0000-000000000001',
--     'aaaaaaaa-0088-0000-0000-000000000001',
--     'aaaaaaaa-0089-0000-0000-000000000001',
--     'aaaaaaaa-0090-0000-0000-000000000001',
--     'aaaaaaaa-0091-0000-0000-000000000001',
--     'aaaaaaaa-0092-0000-0000-000000000001',
--     'aaaaaaaa-0093-0000-0000-000000000001'
--   )
--   ORDER BY exercise_id;
--
-- 3. Simulate getStrongestHead for all 9 — verify correct winner per exercise.
--    getStrongestHead: max qualifying weight (≥0.5); alphabetical tiebreak.
--    Expected result column strongest_head:
--      #85 → neck_flexors
--      #86 → neck_extensors
--      #87 → forearms_wrist_flexors
--      #88 → forearms_wrist_extensors
--      #89 → peroneals
--      #90 → glutes_minimus           ← sole 1.0; medius at 0.9 does not tie
--      #91 → serratus_anterior
--      #92 → glutes_medius
--      #93 → hip_flexors_iliopsoas
--
--   WITH muscles_expanded AS (
--     SELECT
--       e.exercise_id,
--       e.name,
--       m->>'muscle_id'         AS muscle_id,
--       (m->>'weight')::numeric AS weight
--     FROM public.exercises e,
--          jsonb_array_elements(e.muscles) m
--     WHERE e.exercise_id IN (
--       'aaaaaaaa-0085-0000-0000-000000000001',
--       'aaaaaaaa-0086-0000-0000-000000000001',
--       'aaaaaaaa-0087-0000-0000-000000000001',
--       'aaaaaaaa-0088-0000-0000-000000000001',
--       'aaaaaaaa-0089-0000-0000-000000000001',
--       'aaaaaaaa-0090-0000-0000-000000000001',
--       'aaaaaaaa-0091-0000-0000-000000000001',
--       'aaaaaaaa-0092-0000-0000-000000000001',
--       'aaaaaaaa-0093-0000-0000-000000000001'
--     )
--     AND (m->>'weight')::numeric >= 0.5
--   ),
--   max_weights AS (
--     SELECT exercise_id, MAX(weight) AS max_weight
--     FROM muscles_expanded
--     GROUP BY exercise_id
--   ),
--   strongest AS (
--     SELECT DISTINCT ON (me.exercise_id)
--       me.exercise_id,
--       me.name,
--       me.muscle_id AS strongest_head,
--       me.weight    AS top_weight
--     FROM muscles_expanded me
--     JOIN max_weights mw ON me.exercise_id = mw.exercise_id
--     WHERE me.weight = mw.max_weight
--     ORDER BY me.exercise_id, me.muscle_id   -- alphabetical tiebreak
--   )
--   SELECT name, strongest_head, top_weight
--   FROM strongest
--   ORDER BY exercise_id;
--
-- 4. Confirm no existing exercises were touched (expected: 0 rows)
--
--   SELECT exercise_id, name
--   FROM public.exercises
--   WHERE updated_at > NOW() - INTERVAL '2 minutes'
--     AND exercise_id NOT IN (
--       'aaaaaaaa-0085-0000-0000-000000000001',
--       'aaaaaaaa-0086-0000-0000-000000000001',
--       'aaaaaaaa-0087-0000-0000-000000000001',
--       'aaaaaaaa-0088-0000-0000-000000000001',
--       'aaaaaaaa-0089-0000-0000-000000000001',
--       'aaaaaaaa-0090-0000-0000-000000000001',
--       'aaaaaaaa-0091-0000-0000-000000000001',
--       'aaaaaaaa-0092-0000-0000-000000000001',
--       'aaaaaaaa-0093-0000-0000-000000000001'
--     );
