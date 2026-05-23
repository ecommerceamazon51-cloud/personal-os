-- ============================================================================
-- PR #28 — Tier 1 Catalog Expansion
-- ============================================================================
-- What this migration does:
--   1. Adds 2 new movement_pattern enum values:
--        spinal_extension   — for exercises that load the spinal erectors
--        scapular_elevation — for shrugs, Y-raises, face pulls, wall slides
--   2. Inserts 19 new exercises filling coverage gaps identified by the
--      per-head audit:
--        lateral delts (2 → 4 primary)
--        lower chest / pectorals_abdominal (0 → 4 primary)
--        upper traps (1 → 4 primary)
--        lower traps (1 → 4 primary)
--        soleus / calves_soleus (1 → 3 primary)
--        spinal erectors (3 → 7 primary)
--
-- TWO-PASS EXECUTION REQUIRED
-- ─────────────────────────────────────────────────────────────────────────────
-- Postgres error 25001: ALTER TYPE ... ADD VALUE cannot run inside a
-- transaction. Supabase SQL Editor wraps all statements in an implicit
-- transaction, so the two ALTER TYPE statements MUST be pasted and run
-- ALONE in Pass 1, committed, and only then followed by Pass 2.
--
-- PASS 1: Paste lines below the "PASS 1" header down to the STOP boundary.
--         Hit Run. Wait for success.
-- PASS 2: Paste lines below the "PASS 2" header to the end of the file.
--         Hit Run. Verify count with the query at the bottom.
-- ============================================================================


-- ============================================================================
-- PASS 1 — Paste ONLY these two lines. Run them. Let them commit.
-- ============================================================================

ALTER TYPE movement_pattern ADD VALUE 'spinal_extension';
ALTER TYPE movement_pattern ADD VALUE 'scapular_elevation';

-- ============================================================
-- STOP. Run Pass 1 first and let it commit before running Pass 2.
-- ============================================================


-- ============================================================================
-- PASS 2 — Run this entire block AFTER Pass 1 has committed.
--          All INSERTs use ON CONFLICT DO NOTHING — safe to re-run.
-- ============================================================================

BEGIN;

-- ─── LATERAL DELTS ──────────────────────────────────────────────────────────

-- 1. Machine Lateral Raise
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1001-0000-0000-000000000001',
  'Machine Lateral Raise',
  ARRAY['lateral raise machine', 'shoulder machine'],
  'lifting',
  'shoulder_abduction', NULL, 'bilateral',
  '[
    {"muscle_id": "delts_lateral",              "weight": 1.0},
    {"muscle_id": "delts_anterior",             "weight": 0.3},
    {"muscle_id": "delts_posterior",            "weight": 0.25},
    {"muscle_id": "rotator_cuff_supraspinatus", "weight": 0.4},
    {"muscle_id": "traps_upper",                "weight": 0.3}
  ]'::jsonb,
  '{
    "delts_lateral": "Machine version locks the arc and removes the need for stabilization, so you can push closer to failure with cleaner form. Best when fatigue accumulates and dumbbell form breaks down."
  }'::jsonb,
  'machine', NULL, 5.00, 2.50,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'aaaaaadd-dddd-dddd-dddd-dddddddddddd',
  '{"equipment_type": "machine"}'::jsonb,
  'mid',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- 2. Leaning Dumbbell Lateral Raise
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1002-0000-0000-000000000001',
  'Leaning Dumbbell Lateral Raise',
  ARRAY['leaning lateral raise', 'single arm lateral raise', 'lean-away lateral'],
  'lifting',
  'shoulder_abduction', NULL, 'unilateral',
  '[
    {"muscle_id": "delts_lateral",              "weight": 1.0},
    {"muscle_id": "rotator_cuff_supraspinatus", "weight": 0.4},
    {"muscle_id": "traps_upper",                "weight": 0.25},
    {"muscle_id": "obliques",                   "weight": 0.25},
    {"muscle_id": "forearms_grip",              "weight": 0.25}
  ]'::jsonb,
  '{
    "delts_lateral": "Leaning away from the working arm increases the range of motion at the bottom — the loaded stretch hits the lateral fibers harder than the upright dumbbell version where the bottom goes slack."
  }'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'aaaaaadd-dddd-dddd-dddd-dddddddddddd',
  '{"equipment_type": "dumbbell", "stance": "leaning"}'::jsonb,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- ─── LOWER TRAPS ────────────────────────────────────────────────────────────

-- 3. Cable Y-Raise
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1003-0000-0000-000000000001',
  'Cable Y-Raise',
  ARRAY['cable Y', 'low cable Y-raise'],
  'lifting',
  'scapular_elevation', 'shoulder_abduction', 'bilateral',
  '[
    {"muscle_id": "traps_lower",                 "weight": 1.0},
    {"muscle_id": "delts_posterior",             "weight": 0.6},
    {"muscle_id": "delts_lateral",               "weight": 0.5},
    {"muscle_id": "rotator_cuff_supraspinatus",  "weight": 0.4},
    {"muscle_id": "rotator_cuff_infraspinatus",  "weight": 0.4},
    {"muscle_id": "rhomboids",                   "weight": 0.4},
    {"muscle_id": "traps_middle",                "weight": 0.3}
  ]'::jsonb,
  '{
    "traps_lower": "Arms pulled up and out in a Y shape with thumbs leading recruits lower trap fibers that prone Y-raises target but with constant cable tension throughout. Best done with light loads and slow control."
  }'::jsonb,
  'cable', NULL, 2.50, 1.25,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  NULL,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- ─── LOWER CHEST ────────────────────────────────────────────────────────────

-- 4. Decline Barbell Bench Press
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1004-0000-0000-000000000001',
  'Decline Barbell Bench Press',
  ARRAY['decline bench', 'decline BB press'],
  'lifting',
  'horizontal_push', NULL, 'bilateral',
  '[
    {"muscle_id": "pectorals_abdominal",          "weight": 1.0},
    {"muscle_id": "pectorals_sternal",            "weight": 0.7},
    {"muscle_id": "pectorals_clavicular",         "weight": 0.3},
    {"muscle_id": "triceps_lateral",              "weight": 0.6},
    {"muscle_id": "triceps_long",                 "weight": 0.5},
    {"muscle_id": "triceps_medial",               "weight": 0.5},
    {"muscle_id": "delts_anterior",               "weight": 0.4},
    {"muscle_id": "serratus_anterior",            "weight": 0.3},
    {"muscle_id": "rotator_cuff_subscapularis",   "weight": 0.25},
    {"muscle_id": "forearms_grip",                "weight": 0.25}
  ]'::jsonb,
  '{
    "pectorals_abdominal": "Decline angle changes the line of force so the lower chest fibers (running from sternum down to ribs) are most aligned with the press. The bottom position loads the abdominal fibers at full stretch.",
    "pectorals_clavicular": "Upper chest contribution drops significantly on decline — the angle works against the clavicular fibers'\'' line of pull. Pair with incline work to balance."
  }'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['shoulder_external_rotation'],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"grip": "pronated", "incline": "decline"}'::jsonb,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- 5. Decline Dumbbell Bench Press
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1005-0000-0000-000000000001',
  'Decline Dumbbell Bench Press',
  ARRAY['decline DB press', 'decline dumbbell press'],
  'lifting',
  'horizontal_push', NULL, 'bilateral',
  '[
    {"muscle_id": "pectorals_abdominal",          "weight": 1.0},
    {"muscle_id": "pectorals_sternal",            "weight": 0.7},
    {"muscle_id": "pectorals_clavicular",         "weight": 0.3},
    {"muscle_id": "triceps_lateral",              "weight": 0.6},
    {"muscle_id": "triceps_long",                 "weight": 0.5},
    {"muscle_id": "triceps_medial",               "weight": 0.5},
    {"muscle_id": "delts_anterior",               "weight": 0.4},
    {"muscle_id": "serratus_anterior",            "weight": 0.3},
    {"muscle_id": "rotator_cuff_subscapularis",   "weight": 0.25},
    {"muscle_id": "forearms_grip",                "weight": 0.25}
  ]'::jsonb,
  '{
    "pectorals_abdominal": "Dumbbells extend the range of motion at the bottom, getting a deeper stretch on the lower chest fibers than the barbell version where the bar stops on the chest."
  }'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['shoulder_external_rotation'],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"grip": "neutral_or_pronated", "incline": "decline"}'::jsonb,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- 6. Chest Dip
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1006-0000-0000-000000000001',
  'Chest Dip',
  ARRAY['chest-focused dip', 'leaning dip', 'wide dip'],
  'lifting',
  'horizontal_push', 'vertical_push', 'bilateral',
  '[
    {"muscle_id": "pectorals_abdominal",          "weight": 1.0},
    {"muscle_id": "pectorals_sternal",            "weight": 0.7},
    {"muscle_id": "pectorals_clavicular",         "weight": 0.3},
    {"muscle_id": "triceps_lateral",              "weight": 0.6},
    {"muscle_id": "triceps_long",                 "weight": 0.5},
    {"muscle_id": "triceps_medial",               "weight": 0.5},
    {"muscle_id": "delts_anterior",               "weight": 0.4},
    {"muscle_id": "serratus_anterior",            "weight": 0.4},
    {"muscle_id": "rotator_cuff_subscapularis",   "weight": 0.25},
    {"muscle_id": "forearms_grip",                "weight": 0.25}
  ]'::jsonb,
  '{
    "pectorals_abdominal": "Forward lean and flared elbows convert the dip from a tricep movement into a chest movement — the line of force shifts so lower pec fibers do the bulk of the work. Distinct from the upright tricep-focused Dip."
  }'::jsonb,
  'bodyweight', 'dip bars', 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY['shoulder_external_rotation'],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"lean": "forward", "elbow_flare": "out"}'::jsonb,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- 7. Cable Fly — High to Low
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1007-0000-0000-000000000001',
  'Cable Fly — High to Low',
  ARRAY['high to low cable fly', 'high pulley fly', 'decline cable fly'],
  'lifting',
  'horizontal_push', NULL, 'bilateral',
  '[
    {"muscle_id": "pectorals_abdominal",  "weight": 1.0},
    {"muscle_id": "pectorals_sternal",    "weight": 0.7},
    {"muscle_id": "delts_anterior",       "weight": 0.3},
    {"muscle_id": "serratus_anterior",    "weight": 0.25},
    {"muscle_id": "biceps_short",         "weight": 0.25}
  ]'::jsonb,
  '{
    "pectorals_abdominal": "Pulling from high to low matches the fiber direction of the lower chest — the abdominal head fibers run from the lower sternum up and out, so a downward-and-inward arc loads them through their natural line of pull."
  }'::jsonb,
  'cable', NULL, 2.50, 1.25,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"angle": "high_to_low"}'::jsonb,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- ─── UPPER TRAPS ────────────────────────────────────────────────────────────

-- 8. Barbell Shrug
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1008-0000-0000-000000000001',
  'Barbell Shrug',
  ARRAY['BB shrug', 'barbell shoulder shrug'],
  'lifting',
  'scapular_elevation', NULL, 'bilateral',
  '[
    {"muscle_id": "traps_upper",    "weight": 1.0},
    {"muscle_id": "traps_middle",   "weight": 0.4},
    {"muscle_id": "forearms_grip",  "weight": 0.6},
    {"muscle_id": "rhomboids",      "weight": 0.3}
  ]'::jsonb,
  '{
    "traps_upper": "Pure shoulder elevation with no rotation — the upper traps'\'' direct fiber line. Heavy loading possible because the upper traps recover fast and respond well to high volume."
  }'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"equipment_type": "barbell"}'::jsonb,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- 9. Dumbbell Shrug
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1009-0000-0000-000000000001',
  'Dumbbell Shrug',
  ARRAY['DB shrug', 'dumbbell shoulder shrug'],
  'lifting',
  'scapular_elevation', NULL, 'bilateral',
  '[
    {"muscle_id": "traps_upper",    "weight": 1.0},
    {"muscle_id": "traps_middle",   "weight": 0.4},
    {"muscle_id": "forearms_grip",  "weight": 0.7},
    {"muscle_id": "rhomboids",      "weight": 0.3}
  ]'::jsonb,
  '{
    "traps_upper": "Dumbbells let the arms hang neutrally at the sides instead of in front (as with a barbell), which can feel more natural and reduces forward shoulder pull. Grip becomes the limiter at heavy loads — straps help."
  }'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"equipment_type": "dumbbell"}'::jsonb,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- 10. Trap Bar Shrug
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1010-0000-0000-000000000001',
  'Trap Bar Shrug',
  ARRAY['hex bar shrug'],
  'lifting',
  'scapular_elevation', NULL, 'bilateral',
  '[
    {"muscle_id": "traps_upper",    "weight": 1.0},
    {"muscle_id": "traps_middle",   "weight": 0.4},
    {"muscle_id": "forearms_grip",  "weight": 0.7},
    {"muscle_id": "rhomboids",      "weight": 0.3}
  ]'::jsonb,
  '{
    "traps_upper": "Trap bar'\''s neutral grip and centered load position let you go heavier than dumbbell or barbell shrugs without grip or wrist limiting the set. Best for heavy upper-trap strength work."
  }'::jsonb,
  'specialty_bar', 'trap_bar', 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"equipment_type": "trap_bar"}'::jsonb,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- ─── LOWER TRAPS (continued) ─────────────────────────────────────────────────

-- 11. Prone Y-Raise
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1011-0000-0000-000000000001',
  'Prone Y-Raise',
  ARRAY['prone Y', 'incline bench Y-raise', 'prone dumbbell Y'],
  'lifting',
  'scapular_elevation', NULL, 'bilateral',
  '[
    {"muscle_id": "traps_lower",                "weight": 1.0},
    {"muscle_id": "delts_posterior",            "weight": 0.6},
    {"muscle_id": "rotator_cuff_supraspinatus", "weight": 0.5},
    {"muscle_id": "rotator_cuff_infraspinatus", "weight": 0.4},
    {"muscle_id": "rhomboids",                  "weight": 0.4},
    {"muscle_id": "traps_middle",               "weight": 0.4},
    {"muscle_id": "delts_lateral",              "weight": 0.3}
  ]'::jsonb,
  '{
    "traps_lower": "Lying face down on an incline bench removes momentum and forces the lower traps to lift the load through pure scapular upward rotation and depression. Light weights are the rule — anything over 10 lb usually means traps_upper takes over."
  }'::jsonb,
  'dumbbell', 'incline bench', 2.50, 1.25,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"position": "prone", "shape": "Y"}'::jsonb,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- 12. Wall Slide
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1012-0000-0000-000000000001',
  'Wall Slide',
  ARRAY['wall slide scap Y', 'scapular wall slide'],
  'lifting',
  'scapular_elevation', NULL, 'bilateral',
  '[
    {"muscle_id": "traps_lower",                "weight": 0.9},
    {"muscle_id": "traps_middle",               "weight": 0.5},
    {"muscle_id": "rotator_cuff_supraspinatus", "weight": 0.5},
    {"muscle_id": "delts_posterior",            "weight": 0.4},
    {"muscle_id": "rhomboids",                  "weight": 0.4},
    {"muscle_id": "serratus_anterior",          "weight": 0.3}
  ]'::jsonb,
  '{
    "traps_lower": "Bodyweight movement that grooves the lower trap activation pattern without significant loading. Best used as warm-up or postural work, not a hypertrophy driver — the 0.9 weight reflects activation quality, not loading magnitude."
  }'::jsonb,
  'bodyweight', 'wall', 0.00, 0.00,
  ARRAY['hypertrophy'],
  'accessory', 'anywhere',
  'bodyweight_x_reps', FALSE, TRUE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  NULL,
  'mid',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- 13. Face Pull (High Angle)
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1013-0000-0000-000000000001',
  'Face Pull (High Angle)',
  ARRAY['high face pull', 'overhead face pull', 'lower trap face pull'],
  'lifting',
  'scapular_elevation', 'horizontal_pull', 'bilateral',
  '[
    {"muscle_id": "traps_lower",                "weight": 1.0},
    {"muscle_id": "delts_posterior",            "weight": 0.6},
    {"muscle_id": "traps_middle",               "weight": 0.5},
    {"muscle_id": "rotator_cuff_infraspinatus", "weight": 0.5},
    {"muscle_id": "rotator_cuff_teres_minor",   "weight": 0.4},
    {"muscle_id": "rhomboids",                  "weight": 0.4},
    {"muscle_id": "forearms_grip",              "weight": 0.25}
  ]'::jsonb,
  '{
    "traps_lower": "Pulling the rope to the forehead with elbows traveling up and back (not just horizontal) loads the lower traps via scapular depression and upward rotation. Distinct from the standard horizontal Face Pull which targets rear delts and mid traps."
  }'::jsonb,
  'cable', 'rope attachment', 2.50, 1.25,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"angle": "high", "elbow_path": "overhead"}'::jsonb,
  'mid',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- ─── SOLEUS ─────────────────────────────────────────────────────────────────

-- 14. Seated Calf Raise
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1014-0000-0000-000000000001',
  'Seated Calf Raise',
  ARRAY['seated calf', 'soleus raise'],
  'lifting',
  'ankle_plantarflexion', NULL, 'bilateral',
  '[
    {"muscle_id": "calves_soleus",          "weight": 1.0},
    {"muscle_id": "calves_gastrocnemius",   "weight": 0.4},
    {"muscle_id": "peroneals",              "weight": 0.3},
    {"muscle_id": "tibialis_anterior",      "weight": 0.25}
  ]'::jsonb,
  '{
    "calves_soleus": "Bent knee position shortens the gastrocnemius and takes it out of the movement, so the soleus does the work. The soleus is slow-twitch dominant — respond best to higher reps (12-25) and longer time under tension."
  }'::jsonb,
  'machine', 'seated calf raise', 5.00, 2.50,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"position": "seated"}'::jsonb,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- 15. Leg Press Calf Raise
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1015-0000-0000-000000000001',
  'Leg Press Calf Raise',
  ARRAY['calf press', 'leg press calf'],
  'lifting',
  'ankle_plantarflexion', NULL, 'bilateral',
  '[
    {"muscle_id": "calves_gastrocnemius",   "weight": 1.0},
    {"muscle_id": "calves_soleus",          "weight": 0.5},
    {"muscle_id": "peroneals",              "weight": 0.3}
  ]'::jsonb,
  '{
    "calves_gastrocnemius": "Straight leg position lets the gastrocnemius work through its full range. The leg press platform allows heavy loading with the spine supported — useful when standing calf raises load the lower back too much.",
    "calves_soleus": "Soleus still contributes (it works at every knee angle) but the dominant role goes to gastroc when the knee is extended."
  }'::jsonb,
  'machine', 'leg press', 10.00, 5.00,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"position": "leg_press"}'::jsonb,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- ─── SPINAL ERECTORS ────────────────────────────────────────────────────────

-- 16. Back Extension
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1016-0000-0000-000000000001',
  'Back Extension',
  ARRAY['45-degree back extension', 'hyperextension', 'Roman chair back extension'],
  'lifting',
  'spinal_extension', NULL, 'bilateral',
  '[
    {"muscle_id": "spinal_erectors",              "weight": 1.0},
    {"muscle_id": "glutes_max",                   "weight": 0.6},
    {"muscle_id": "hamstrings_bf_long",           "weight": 0.5},
    {"muscle_id": "hamstrings_semimembranosus",   "weight": 0.5},
    {"muscle_id": "hamstrings_semitendinosus",    "weight": 0.5}
  ]'::jsonb,
  '{
    "spinal_erectors": "Rounding slightly at the top vs keeping a flat back shifts emphasis: rounded back = more spinal erector work, flat back with hip hinge = more glute/hamstring work. The flat-back variation overlaps with hinge work."
  }'::jsonb,
  'machine', '45 degree hyperextension bench', 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'accessory', 'late',
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"angle": "45", "emphasis": "spinal"}'::jsonb,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- 17. Reverse Hyper
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1017-0000-0000-000000000001',
  'Reverse Hyper',
  ARRAY['reverse hyperextension', 'Westside reverse hyper'],
  'lifting',
  'spinal_extension', 'hinge', 'bilateral',
  '[
    {"muscle_id": "spinal_erectors",              "weight": 1.0},
    {"muscle_id": "glutes_max",                   "weight": 0.7},
    {"muscle_id": "hamstrings_bf_long",           "weight": 0.5},
    {"muscle_id": "hamstrings_semimembranosus",   "weight": 0.5},
    {"muscle_id": "hamstrings_semitendinosus",    "weight": 0.5}
  ]'::jsonb,
  '{
    "spinal_erectors": "Torso fixed, legs move — opposite of back extension. Traction effect on the lumbar spine at the bottom plus loaded extension at the top. Often used by powerlifters for low-back recovery in addition to strength."
  }'::jsonb,
  'machine', 'reverse hyper', 10.00, 5.00,
  ARRAY['strength', 'hypertrophy'],
  'accessory', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  NULL,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- 18. GHD Back Raise
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1018-0000-0000-000000000001',
  'GHD Back Raise',
  ARRAY['GHD hyperextension', 'glute ham developer back raise'],
  'lifting',
  'spinal_extension', NULL, 'bilateral',
  '[
    {"muscle_id": "spinal_erectors",              "weight": 1.0},
    {"muscle_id": "glutes_max",                   "weight": 0.5},
    {"muscle_id": "hamstrings_bf_long",           "weight": 0.5},
    {"muscle_id": "hamstrings_semimembranosus",   "weight": 0.4},
    {"muscle_id": "hamstrings_semitendinosus",    "weight": 0.4}
  ]'::jsonb,
  '{
    "spinal_erectors": "Horizontal body position vs 45° back extension — different leverage means the spinal erectors work harder at the top (shortened position) where the lever arm is longest. Complement to back extension, not a replacement."
  }'::jsonb,
  'machine', 'glute ham developer', 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'accessory', 'late',
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"position": "horizontal"}'::jsonb,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

-- 19. Jefferson Curl
-- NOTE: movement_pattern_primary is 'spinal_extension' even though the movement
-- involves intentional spinal flexion. This exercise is categorized by its target
-- muscle (spinal erectors = spinal extensors) rather than movement direction.
-- The erectors work eccentrically through their full lengthened range.
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles, head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified,
  created_at, updated_at
) VALUES (
  'aaaaaaaa-1019-0000-0000-000000000001',
  'Jefferson Curl',
  ARRAY['weighted spinal flexion', 'Jefferson curl-up'],
  'lifting',
  'spinal_extension', NULL, 'bilateral',
  '[
    {"muscle_id": "spinal_erectors",              "weight": 1.0},
    {"muscle_id": "hamstrings_bf_long",           "weight": 0.6},
    {"muscle_id": "hamstrings_semimembranosus",   "weight": 0.6},
    {"muscle_id": "hamstrings_semitendinosus",    "weight": 0.6},
    {"muscle_id": "glutes_max",                   "weight": 0.4},
    {"muscle_id": "forearms_grip",                "weight": 0.3}
  ]'::jsonb,
  '{
    "spinal_erectors": "Slow controlled spinal flexion under load — trains the erectors eccentrically through their full lengthened range. Start very light (10-25 lb). Builds robustness and end-range strength but is not a primary hypertrophy driver — pair with back extension for volume."
  }'::jsonb,
  'dumbbell', NULL, 2.50, 1.25,
  ARRAY['hypertrophy'],
  'accessory', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"loading": "dumbbell"}'::jsonb,
  'stretched',
  'system', FALSE,
  now(), now()
) ON CONFLICT DO NOTHING;

COMMIT;

-- ============================================================================
-- VERIFICATION — Run after Pass 2 commits
-- ============================================================================
-- Expected: 19 rows
-- SELECT COUNT(*) FROM exercises
-- WHERE exercise_id IN (
--   'aaaaaaaa-1001-0000-0000-000000000001',
--   'aaaaaaaa-1002-0000-0000-000000000001',
--   'aaaaaaaa-1003-0000-0000-000000000001',
--   'aaaaaaaa-1004-0000-0000-000000000001',
--   'aaaaaaaa-1005-0000-0000-000000000001',
--   'aaaaaaaa-1006-0000-0000-000000000001',
--   'aaaaaaaa-1007-0000-0000-000000000001',
--   'aaaaaaaa-1008-0000-0000-000000000001',
--   'aaaaaaaa-1009-0000-0000-000000000001',
--   'aaaaaaaa-1010-0000-0000-000000000001',
--   'aaaaaaaa-1011-0000-0000-000000000001',
--   'aaaaaaaa-1012-0000-0000-000000000001',
--   'aaaaaaaa-1013-0000-0000-000000000001',
--   'aaaaaaaa-1014-0000-0000-000000000001',
--   'aaaaaaaa-1015-0000-0000-000000000001',
--   'aaaaaaaa-1016-0000-0000-000000000001',
--   'aaaaaaaa-1017-0000-0000-000000000001',
--   'aaaaaaaa-1018-0000-0000-000000000001',
--   'aaaaaaaa-1019-0000-0000-000000000001'
-- );
--
-- Enum verification (run after Pass 1):
-- SELECT enumlabel FROM pg_enum
-- WHERE enumtypid = 'movement_pattern'::regtype
--   AND enumlabel IN ('spinal_extension', 'scapular_elevation');
-- Expected: 2 rows
--
-- Universal orphan check:
-- SELECT e.exercise_id, e.name, elem->>'muscle_id' AS missing_muscle
-- FROM public.exercises e, jsonb_array_elements(e.muscles) AS elem
-- WHERE elem->>'muscle_id' NOT IN (SELECT muscle_id FROM public.muscles);
-- Expected: 0 rows always
-- ============================================================================
