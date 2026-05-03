-- =============================================================================
-- Seed Exercises — v1 Draft (5 representative exercises for format review)
-- =============================================================================
-- Purpose: lock the authoring conventions before batching the remaining 25-45.
-- Mix:
--   1. Barbell Back Squat        — bilateral main compound, variation_attributes
--   2. Pull-Up                   — bodyweight, relative_to_bodyweight=true
--   3. Dumbbell Lateral Raise    — single-muscle isolation, late position
--   4. Bulgarian Split Squat     — unilateral, unilateral_balance demand
--   5. Leg Press                 — machine, equipment_specific, contrast w/ squat
--
-- Conventions used (documented for review):
--   - Muscle weights: 1.0 for muscles that are clearly the *target* (the muscle
--     that limits the lift, the muscle that grows). 0.5 for genuine synergists.
--     0.25 only when meaningfully challenged in a way the user would notice
--     fatiguing — not for every contracting muscle.
--   - Units: all load_increment_* values in POUNDS (lbs). v1 is lbs-only;
--     kg support is a future feature, will not retroactively change these rows.
--   - variation_attributes: flat key→string map. Keys used here: grip, stance,
--     bar_position. Null when the exercise has no meaningful variation axis.
--   - demands: drawn from a controlled vocabulary (~15 tags). See spec §18 + the
--     conventions doc.
--   - aliases: 2-4 common forms a user might actually type.
--   - exercise_family_id: pre-generated UUIDs so substitutes can reference each
--     other before any are inserted. Same family_id = variations of same lift.
-- =============================================================================

-- Pre-generate UUIDs so we can wire up exercise_substitutes in the same script.
-- (Using fixed UUIDs here for review readability; real seed run can use gen_random_uuid().)

-- Family IDs (group variations of the same lift)
-- squat_family       = 11111111-1111-1111-1111-111111111111
-- pullup_family      = 22222222-2222-2222-2222-222222222222
-- lateral_family     = 33333333-3333-3333-3333-333333333333
-- splitsquat_family  = 44444444-4444-4444-4444-444444444444
-- legpress_family    = 55555555-5555-5555-5555-555555555555

-- Exercise IDs
-- back_squat        = aaaaaaaa-0001-0000-0000-000000000001
-- pull_up           = aaaaaaaa-0002-0000-0000-000000000001
-- lateral_raise_db  = aaaaaaaa-0003-0000-0000-000000000001
-- bulgarian_split   = aaaaaaaa-0004-0000-0000-000000000001
-- leg_press         = aaaaaaaa-0005-0000-0000-000000000001


-- ─── 1. Barbell Back Squat ──────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0001-0000-0000-000000000001',
  'Barbell Back Squat',
  ARRAY['back squat', 'high-bar squat', 'barbell squat', 'BB squat'],
  'lifting',
  'squat', NULL, 'bilateral',
  '[
    {"muscle_id": "quads",      "weight": 1.0},
    {"muscle_id": "glutes",     "weight": 0.5},
    {"muscle_id": "adductors",  "weight": 0.5},
    {"muscle_id": "lower_back", "weight": 0.25},
    {"muscle_id": "abs",        "weight": 0.25}
  ]'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['deep_knee_flexion', 'ankle_dorsiflexion', 'axial_loading', 'thoracic_extension'],
  '[]'::jsonb,
  '11111111-1111-1111-1111-111111111111',
  '{"bar_position": "high_bar", "stance": "shoulder_width"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 2. Pull-Up ─────────────────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0002-0000-0000-000000000001',
  'Pull-Up',
  ARRAY['pullup', 'pull up', 'overhand pull-up'],
  'lifting',
  'vertical_pull', NULL, 'bilateral',
  '[
    {"muscle_id": "lats",            "weight": 1.0},
    {"muscle_id": "biceps",          "weight": 0.5},
    {"muscle_id": "rhomboids",       "weight": 0.5},
    {"muscle_id": "traps_mid_lower", "weight": 0.5},
    {"muscle_id": "rear_delts",      "weight": 0.25},
    {"muscle_id": "forearms",        "weight": 0.25},
    {"muscle_id": "abs",             "weight": 0.25}
  ]'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  -- Increments apply when adding a weight belt; user starts at bodyweight (0 added).
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY['shoulder_flexion', 'grip_intensive'],
  '[]'::jsonb,
  '22222222-2222-2222-2222-222222222222',
  '{"grip": "pronated"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 3. Dumbbell Lateral Raise ──────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0003-0000-0000-000000000001',
  'Dumbbell Lateral Raise',
  ARRAY['lateral raise', 'side raise', 'DB lateral', 'side lateral raise'],
  'lifting',
  'vertical_push', NULL, 'bilateral',
  -- Lateral raise is genuinely a side_delts isolation. Front/rear delts are
  -- not meaningfully challenged by a clean side raise.
  '[
    {"muscle_id": "side_delts", "weight": 1.0}
  ]'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '33333333-3333-3333-3333-333333333333',
  NULL,
  'shortened',
  'system', FALSE
);

-- ─── 4. Bulgarian Split Squat ───────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0004-0000-0000-000000000001',
  'Bulgarian Split Squat',
  ARRAY['BSS', 'rear-foot elevated split squat', 'RFESS', 'split squat'],
  'lifting',
  'lunge_split', 'squat', 'unilateral',
  -- Quad-dominant unilateral. Glutes work hard at depth; hip_flexors of trail
  -- leg are stretched but not loaded enough to count as 0.25 here.
  '[
    {"muscle_id": "quads",      "weight": 1.0},
    {"muscle_id": "glutes",     "weight": 0.5},
    {"muscle_id": "adductors",  "weight": 0.5},
    {"muscle_id": "abs",        "weight": 0.25}
  ]'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  -- Default loading is dumbbells; barbell variant would be a separate exercise
  -- in the same family.
  ARRAY['strength', 'hypertrophy', 'stability'],
  'secondary_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['deep_knee_flexion', 'unilateral_balance', 'hip_flexion'],
  '[]'::jsonb,
  '44444444-4444-4444-4444-444444444444',
  '{"stance": "split"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 5. Leg Press ───────────────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0005-0000-0000-000000000001',
  '45-Degree Leg Press',
  ARRAY['leg press', 'plate-loaded leg press', 'sled press'],
  'lifting',
  'squat', NULL, 'bilateral',
  -- Same primary pattern as squat but no axial load and no balance demand —
  -- so quads are still 1.0 but the lower_back/abs stabilizer entries from
  -- the squat correctly drop off here.
  '[
    {"muscle_id": "quads",     "weight": 1.0},
    {"muscle_id": "glutes",    "weight": 0.5},
    {"muscle_id": "adductors", "weight": 0.5}
  ]'::jsonb,
  'machine', 'leg_press', 10.00, 5.00,
  ARRAY['hypertrophy', 'strength'],
  'secondary_compound', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['deep_knee_flexion'],
  '[]'::jsonb,
  '55555555-5555-5555-5555-555555555555',
  NULL,
  'stretched',
  'system', FALSE
);


-- =============================================================================
-- Substitution graph (just enough to test the structure)
-- =============================================================================
-- Demonstrates the directed-graph property: leg press ← back squat is
-- "regression" (easier, no axial load), but back squat ← leg press is
-- "progression" (harder, requires more skill + stability).

INSERT INTO public.exercise_substitutes (exercise_id, substitute_id, similarity_score, reason) VALUES
  -- Back squat alternatives
  ('aaaaaaaa-0001-0000-0000-000000000001', 'aaaaaaaa-0005-0000-0000-000000000001', 0.70, 'regression'),
  ('aaaaaaaa-0001-0000-0000-000000000001', 'aaaaaaaa-0004-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),

  -- Leg press alternatives
  ('aaaaaaaa-0005-0000-0000-000000000001', 'aaaaaaaa-0001-0000-0000-000000000001', 0.70, 'progression'),
  ('aaaaaaaa-0005-0000-0000-000000000001', 'aaaaaaaa-0004-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),

  -- Bulgarian split squat alternatives
  ('aaaaaaaa-0004-0000-0000-000000000001', 'aaaaaaaa-0001-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0004-0000-0000-000000000001', 'aaaaaaaa-0005-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern');
