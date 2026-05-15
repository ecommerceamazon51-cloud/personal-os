-- =============================================================================
-- Seed Exercises — Batch 4 (15 exercises: core domain + bodyweight + lifting gaps)
-- Updated for muscle taxonomy v2 — per-head distributions and head_emphasis_notes added.
-- =============================================================================
-- Purpose: open three new coverage areas after batches 1–3:
--   1. Core domain
--   2. Bodyweight/home-gym progression ladder
--   3. Highest-value remaining lifting gaps
--
-- After this batch the DB has 44 exercises (batches 1–3: 29, batch 4: 15).
--
-- Mix:
--   Core (7)
--    30.  Plank
--    31.  Side Plank
--    32.  Hanging Leg Raise
--    33.  Ab Wheel Rollout
--    34.  Cable Crunch
--    35.  Pallof Press
--    36.  Cable Woodchop
--   Bodyweight progression ladder (4)
--    37.  Push-Up
--    38.  Incline Push-Up
--    39.  Pike Push-Up
--    40.  Inverted Row
--   Lifting gaps (4)
--    41.  Sumo Deadlift
--    42.  Face Pull
--    43.  Walking Lunge — Dumbbell
--    44.  Seated Calf Raise
--
-- Conventions adhered to (see docs/exercise_authoring_conventions.md v2):
--   - §1: variations are separate rows.
--   - §13: all muscle_ids are per-head or singletons; no group references.
--   - §14: seven biomechanical patterns applied throughout.
--   - §2: comprehensive authoring; intermediate weights used.
--
-- Dip default: triceps-bias (upright torso) per review. See batch 3.
-- Face pull: rotator cuff heads added vs v1 (external rotation load is real).
-- All `progression_eligible` = TRUE except plank/side plank (time-based).
-- All `authored_by` = 'system', `verified` = FALSE.
-- =============================================================================

-- Pre-generated UUIDs.
-- Family IDs reused:
--   deadlift_family     = 66666666-6666-6666-6666-666666666666 (sumo joins)
--   calf_raise_family   = 33333333-4444-5555-6666-777777777777 (seated joins)
--
-- New family IDs:
--   plank_family        = 77777777-8888-9999-aaaa-bbbbbbbbbbbb
--   side_plank_family   = 88888888-9999-aaaa-bbbb-cccccccccccc
--   hanging_leg_family  = 99999999-aaaa-bbbb-cccc-dddddddddddd
--   ab_wheel_family     = aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee
--   cable_crunch_family = bbbbbbbb-cccc-dddd-eeee-ffffffffffff
--   pallof_family       = cccccccc-dddd-eeee-ffff-000000000001
--   woodchop_family     = dddddddd-eeee-ffff-0000-000000000001
--   pushup_family       = eeeeeeee-ffff-0000-1111-000000000001
--   pike_pushup_family  = ffffffff-0000-1111-2222-000000000001
--   inverted_row_family = 00000000-1111-2222-3333-100000000001
--   face_pull_family    = 11111111-2222-3333-4444-100000000001
--   walking_lunge_family= 22222222-3333-4444-5555-100000000001
--
-- Exercise IDs:
--   plank               = aaaaaaaa-0030-0000-0000-000000000001
--   side_plank          = aaaaaaaa-0031-0000-0000-000000000001
--   hanging_leg_raise   = aaaaaaaa-0032-0000-0000-000000000001
--   ab_wheel_rollout    = aaaaaaaa-0033-0000-0000-000000000001
--   cable_crunch        = aaaaaaaa-0034-0000-0000-000000000001
--   pallof_press        = aaaaaaaa-0035-0000-0000-000000000001
--   cable_woodchop      = aaaaaaaa-0036-0000-0000-000000000001
--   pushup              = aaaaaaaa-0037-0000-0000-000000000001
--   incline_pushup      = aaaaaaaa-0038-0000-0000-000000000001
--   pike_pushup         = aaaaaaaa-0039-0000-0000-000000000001
--   inverted_row        = aaaaaaaa-0040-0000-0000-000000000001
--   sumo_deadlift       = aaaaaaaa-0041-0000-0000-000000000001
--   face_pull           = aaaaaaaa-0042-0000-0000-000000000001
--   walking_lunge_db    = aaaaaaaa-0043-0000-0000-000000000001
--   seated_calf_raise   = aaaaaaaa-0044-0000-0000-000000000001


-- ─── 30. Plank ──────────────────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0030-0000-0000-000000000001',
  'Plank',
  ARRAY['front plank', 'forearm plank', 'prone plank'],
  'lifting',
  'anti_extension', NULL, 'bilateral',
  -- Anti-extension: prevent lumbar extension under gravitational load.
  -- rectus_abdominis 1.0 — primary anti-extension muscle.
  -- transverse_abdominis 0.7 — deep brace providing spinal stiffness.
  -- obliques 0.5 — meaningful synergist; contribute to maintaining the
  -- rigid line. glutes_max 0.25 — prevents hips from sagging.
  '[
    {"muscle_id": "rectus_abdominis",     "weight": 1.0},
    {"muscle_id": "transverse_abdominis", "weight": 0.7},
    {"muscle_id": "obliques",             "weight": 0.5},
    {"muscle_id": "glutes_max",           "weight": 0.25}
  ]'::jsonb,
  '{
    "rectus_abdominis": "Primary anti-extension muscle — its job is to prevent the spine from extending (hips sagging). The plank is the textbook anti-extension load.",
    "transverse_abdominis": "Deep brace muscle that stiffens the spine from the inside. Active throughout the hold — planks build core stiffness that crunches alone cannot develop."
  }'::jsonb,
  'bodyweight', NULL, NULL, NULL,
  ARRAY['stability', 'hypertrophy'],
  'isolation', 'late',
  'time', FALSE, TRUE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '77777777-8888-9999-aaaa-bbbbbbbbbbbb',
  NULL,
  'mid',
  'system', FALSE
);

-- ─── 31. Side Plank ─────────────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0031-0000-0000-000000000001',
  'Side Plank',
  ARRAY['lateral plank', 'side bridge', 'forearm side plank'],
  'lifting',
  'anti_lateral_flexion', NULL, 'unilateral',
  -- Anti-lateral-flexion: resist gravity pulling the hip toward the floor.
  -- loading_type = 'unilateral' (one side per set).
  -- obliques 1.0 — lateral abdominal wall is the primary mover here.
  -- rectus_abdominis 0.5 — meaningful synergist for rigid trunk.
  -- transverse_abdominis 0.5 — deep brace.
  -- glutes_medius 0.5 — unilateral load; prevents hip from dropping
  -- (not bilateral compound, so the ≤0.3 bilateral cap does not apply).
  -- glutes_minimus 0.3 — assists glute medius in the abducted position.
  -- delts_lateral 0.25 — supporting shoulder bears bodyweight.
  '[
    {"muscle_id": "obliques",             "weight": 1.0},
    {"muscle_id": "rectus_abdominis",     "weight": 0.5},
    {"muscle_id": "transverse_abdominis", "weight": 0.5},
    {"muscle_id": "glutes_medius",        "weight": 0.5},
    {"muscle_id": "glutes_minimus",       "weight": 0.3},
    {"muscle_id": "delts_lateral",        "weight": 0.25}
  ]'::jsonb,
  '{
    "obliques": "Side plank is the primary trainer for the lateral abdominal wall — resisting lateral flexion is exactly what the obliques are designed for.",
    "glutes_medius": "Works to prevent the hip from dropping toward the floor. This is a genuine unilateral abductor load — unlike bilateral squats where glute medius stays at ≤0.3, the side plank trains it through a real stabilization demand."
  }'::jsonb,
  'bodyweight', NULL, NULL, NULL,
  ARRAY['stability'],
  'isolation', 'late',
  'time', FALSE, TRUE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '88888888-9999-aaaa-bbbb-cccccccccccc',
  NULL,
  'mid',
  'system', FALSE
);

-- ─── 32. Hanging Leg Raise ──────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0032-0000-0000-000000000001',
  'Hanging Leg Raise',
  ARRAY['HLR', 'hanging knee raise', 'leg raise'],
  'lifting',
  'anti_extension', NULL, 'bilateral',
  -- Dynamic anti-extension. rectus_abdominis 1.0 (properly cued with
  -- posterior pelvic tilt). hip_flexors_iliopsoas 0.6 — also lifting the
  -- legs; form cue determines ab vs hip-flexor dominance (see notes).
  -- forearms_grip 0.7 — often limits the set before abs do.
  -- lats work passively in the dead hang: lats_lower/upper at 0.25.
  -- transverse_abdominis 0.5 — core bracing throughout.
  '[
    {"muscle_id": "rectus_abdominis",     "weight": 1.0},
    {"muscle_id": "transverse_abdominis", "weight": 0.5},
    {"muscle_id": "obliques",             "weight": 0.3},
    {"muscle_id": "hip_flexors_iliopsoas","weight": 0.6},
    {"muscle_id": "hip_flexors_tfl",      "weight": 0.3},
    {"muscle_id": "forearms_grip",        "weight": 0.7},
    {"muscle_id": "forearms_brachioradialis", "weight": 0.3},
    {"muscle_id": "lats_lower",           "weight": 0.25},
    {"muscle_id": "lats_upper",           "weight": 0.25}
  ]'::jsonb,
  '{
    "rectus_abdominis": "Posterior pelvic tilt is the key cue — tilt the pelvis back to curl it toward the ribs rather than just lifting the legs with hip flexors. The crunch at the bottom is where the abs dominate.",
    "hip_flexors_iliopsoas": "Without posterior pelvic tilt, iliopsoas does most of the work and abs contribute minimally. Heavy hip flexor dominance is the most common form breakdown on HLR.",
    "forearms_grip": "Grip often fails before the abs, especially past 8-10 reps. Chalk or straps are legitimate tools if grip is the limiting factor."
  }'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  ARRAY['hypertrophy', 'stability'],
  'isolation', 'late',
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY['shoulder_flexion', 'grip_intensive'],
  '[]'::jsonb,
  '99999999-aaaa-bbbb-cccc-dddddddddddd',
  NULL,
  'stretched',
  'system', FALSE
);

-- ─── 33. Ab Wheel Rollout ───────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0033-0000-0000-000000000001',
  'Ab Wheel Rollout',
  ARRAY['ab wheel', 'wheel rollout', 'ab roller'],
  'lifting',
  'anti_extension', NULL, 'bilateral',
  -- Dynamic anti-extension under maximum stretch. Abs eccentrically resist
  -- extension on the way out; lats drive shoulder extension to pull back.
  -- Dual demand: anti-extension + pulling = uniquely effective compound.
  -- lats_lower 0.6 — actively pull the wheel back on concentric phase.
  -- Arms fully extended overhead → triceps_long 0.4 (long head on stretch).
  -- serratus_anterior 0.4 — scapular stabilization with arms overhead.
  '[
    {"muscle_id": "rectus_abdominis",     "weight": 1.0},
    {"muscle_id": "transverse_abdominis", "weight": 0.6},
    {"muscle_id": "obliques",             "weight": 0.5},
    {"muscle_id": "lats_lower",           "weight": 0.6},
    {"muscle_id": "lats_upper",           "weight": 0.5},
    {"muscle_id": "teres_major",          "weight": 0.4},
    {"muscle_id": "serratus_anterior",    "weight": 0.4},
    {"muscle_id": "triceps_long",         "weight": 0.4},
    {"muscle_id": "triceps_lateral",      "weight": 0.3},
    {"muscle_id": "delts_anterior",       "weight": 0.3}
  ]'::jsonb,
  '{
    "rectus_abdominis": "Peak tension at full extension — the abs resist a massive flexion moment arm when the arms are overhead and the body is horizontal. One of the highest ab-loading exercises in this database.",
    "lats_lower": "The lats actively drive the wheel back on the concentric phase — this is a genuine lat rowing movement on top of the anti-extension work. The dual demand is what makes ab wheel uniquely effective.",
    "triceps_long": "Arms-extended overhead position puts the long head in a stretched state — same principle as overhead tricep extension. A secondary upper arm stimulus on every rollout rep."
  }'::jsonb,
  'bodyweight', 'ab_wheel', NULL, NULL,
  ARRAY['hypertrophy', 'stability'],
  'isolation', 'late',
  'bodyweight_x_reps', TRUE, TRUE,
  ARRAY['shoulder_flexion'],
  '[]'::jsonb,
  'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
  NULL,
  'stretched',
  'system', FALSE
);

-- ─── 34. Cable Crunch ───────────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0034-0000-0000-000000000001',
  'Cable Crunch',
  ARRAY['kneeling cable crunch', 'rope crunch', 'cable ab crunch'],
  'lifting',
  'anti_extension', NULL, 'bilateral',
  -- Loaded spinal flexion. Kneeling with hips fixed prevents hip flexor
  -- contribution — all load goes to rectus_abdominis.
  -- obliques 0.25 — minor on straight crunch, more with rotation.
  '[
    {"muscle_id": "rectus_abdominis",     "weight": 1.0},
    {"muscle_id": "obliques",             "weight": 0.25}
  ]'::jsonb,
  '{
    "rectus_abdominis": "Kneeling with hips fixed means pure spinal flexion — hip flexors cannot contribute. This is why cable crunch is more effective than sit-ups for direct ab training.",
    "obliques": "Minor synergist on a straight-down crunch. Add a slight rotation at the contracted position to increase oblique contribution."
  }'::jsonb,
  'cable', NULL, 5.00, 2.50,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'bbbbbbbb-cccc-dddd-eeee-ffffffffffff',
  '{"grip": "neutral"}'::jsonb,
  'shortened',
  'system', FALSE
);

-- ─── 35. Pallof Press ───────────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0035-0000-0000-000000000001',
  'Pallof Press',
  ARRAY['pallof', 'standing pallof press', 'cable anti-rotation press'],
  'lifting',
  'anti_rotation', NULL, 'unilateral',
  -- Anti-rotation: cable pulls laterally, lifter resists trunk rotation.
  -- loading_type = unilateral (cable always pulls from one side).
  -- obliques 1.0 — both internal and external obliques resist rotation.
  -- rectus_abdominis 0.5 — overall trunk brace.
  -- transverse_abdominis 0.5 — deep anti-rotation brace.
  -- delts_anterior 0.25 — pressing out to arm''s length is brief;
  -- the held isometric is where the work is.
  '[
    {"muscle_id": "obliques",             "weight": 1.0},
    {"muscle_id": "rectus_abdominis",     "weight": 0.5},
    {"muscle_id": "transverse_abdominis", "weight": 0.5},
    {"muscle_id": "delts_anterior",       "weight": 0.25}
  ]'::jsonb,
  '{
    "obliques": "Both internal and external obliques resist trunk rotation toward the cable. The moment the press is held extended, the obliques are under maximal anti-rotation load.",
    "transverse_abdominis": "The deep brace that stiffens the spine against rotation. Training anti-rotation with Pallof transfers directly to athletic movements and heavy lifting where trunk rigidity matters."
  }'::jsonb,
  'cable', NULL, 5.00, 2.50,
  ARRAY['stability'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'cccccccc-dddd-eeee-ffff-000000000001',
  '{"stance": "shoulder_width"}'::jsonb,
  'mid',
  'system', FALSE
);

-- ─── 36. Cable Woodchop ─────────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0036-0000-0000-000000000001',
  'Cable Woodchop',
  ARRAY['woodchop', 'cable chop', 'high-to-low woodchop'],
  'lifting',
  'rotation', NULL, 'unilateral',
  -- Active rotation (high-to-low default). obliques 1.0 (prime movers).
  -- lats_lower/upper 0.5/0.4 — on a high-to-low chop the lats pull the
  -- cable down and across diagonally; active contribution, not stabilizer.
  -- transverse_abdominis 0.4 — bracing throughout the rotation.
  '[
    {"muscle_id": "obliques",             "weight": 1.0},
    {"muscle_id": "rectus_abdominis",     "weight": 0.5},
    {"muscle_id": "transverse_abdominis", "weight": 0.4},
    {"muscle_id": "lats_lower",           "weight": 0.5},
    {"muscle_id": "lats_upper",           "weight": 0.4},
    {"muscle_id": "delts_anterior",       "weight": 0.3}
  ]'::jsonb,
  '{
    "obliques": "Prime movers in trunk rotation — external oblique on the rotating side, internal oblique on the opposite side work together to drive the chop.",
    "lats_lower": "On a high-to-low woodchop the lats contribute to pulling the cable down and across the body. This is an active lat contribution, not just stabilization."
  }'::jsonb,
  'cable', NULL, 5.00, 2.50,
  ARRAY['hypertrophy', 'stability'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'dddddddd-eeee-ffff-0000-000000000001',
  '{"grip": "neutral"}'::jsonb,
  'mid',
  'system', FALSE
);

-- ─── 37. Push-Up ────────────────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0037-0000-0000-000000000001',
  'Push-Up',
  ARRAY['pushup', 'push up', 'standard push-up', 'floor push-up'],
  'lifting',
  'horizontal_push', NULL, 'bilateral',
  -- Bodyweight bench press equivalent. pectorals and synergists mirror flat
  -- bench. Additional anti-extension core demand (user is the plank):
  -- rectus_abdominis 0.3 and obliques 0.3 — higher than on bench press
  -- because the plank body position adds genuine core loading.
  '[
    {"muscle_id": "pectorals_sternal",          "weight": 1.0},
    {"muscle_id": "pectorals_clavicular",       "weight": 0.6},
    {"muscle_id": "pectorals_abdominal",        "weight": 0.5},
    {"muscle_id": "triceps_lateral",            "weight": 0.6},
    {"muscle_id": "triceps_long",               "weight": 0.5},
    {"muscle_id": "triceps_medial",             "weight": 0.5},
    {"muscle_id": "delts_anterior",             "weight": 0.5},
    {"muscle_id": "serratus_anterior",          "weight": 0.3},
    {"muscle_id": "rectus_abdominis",           "weight": 0.3},
    {"muscle_id": "obliques",                   "weight": 0.3}
  ]'::jsonb,
  '{
    "pectorals_sternal": "Same primary target as flat bench press — horizontal pressing mechanics and pec emphasis are essentially identical.",
    "rectus_abdominis": "Plank body position adds anti-extension demand not present on bench press. Must resist the spine from sagging throughout every rep — this is why push-ups also train the core."
  }'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY['shoulder_flexion'],
  '[]'::jsonb,
  'eeeeeeee-ffff-0000-1111-000000000001',
  '{"incline": "flat"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 38. Incline Push-Up ────────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0038-0000-0000-000000000001',
  'Incline Push-Up',
  ARRAY['hands-elevated push-up', 'wall push-up', 'bench push-up'],
  'lifting',
  'horizontal_push', NULL, 'bilateral',
  -- Same muscle targets as flat push-up; less total load fraction (hands
  -- elevated = center of mass is higher). Identical muscle weights at
  -- per-head resolution — the difference is load, not distribution.
  '[
    {"muscle_id": "pectorals_sternal",          "weight": 1.0},
    {"muscle_id": "pectorals_clavicular",       "weight": 0.6},
    {"muscle_id": "pectorals_abdominal",        "weight": 0.5},
    {"muscle_id": "triceps_lateral",            "weight": 0.6},
    {"muscle_id": "triceps_long",               "weight": 0.5},
    {"muscle_id": "triceps_medial",             "weight": 0.5},
    {"muscle_id": "delts_anterior",             "weight": 0.5},
    {"muscle_id": "serratus_anterior",          "weight": 0.3},
    {"muscle_id": "rectus_abdominis",           "weight": 0.25},
    {"muscle_id": "obliques",                   "weight": 0.25}
  ]'::jsonb,
  '{
    "pectorals_sternal": "Hands elevated reduces the proportion of bodyweight being pressed. Same pec targets as flat push-up, lighter load.",
    "rectus_abdominis": "Same anti-extension demand as flat push-up but slightly reduced at the inclined angle."
  }'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  ARRAY['strength', 'hypertrophy'],
  'accessory', 'anywhere',
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'eeeeeeee-ffff-0000-1111-000000000001',
  '{"incline": "incline"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 39. Pike Push-Up ───────────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0039-0000-0000-000000000001',
  'Pike Push-Up',
  ARRAY['pike pushup', 'downward dog push-up', 'feet-elevated pike push-up'],
  'lifting',
  'vertical_push', NULL, 'bilateral',
  -- Hip-piked position → press direction toward vertical → front delts
  -- are the primary target (same as OHP). Separate family from push-up
  -- family because primary pattern differs.
  -- triceps_long at 0.6: shoulder is flexed in the piked position → long
  -- head is on stretch (same overhead-position advantage as standing OHP).
  -- pectorals_clavicular at 0.25 (minor at bottom of press).
  '[
    {"muscle_id": "delts_anterior",               "weight": 1.0},
    {"muscle_id": "delts_lateral",                "weight": 0.3},
    {"muscle_id": "triceps_lateral",              "weight": 0.6},
    {"muscle_id": "triceps_long",                 "weight": 0.6},
    {"muscle_id": "triceps_medial",               "weight": 0.5},
    {"muscle_id": "traps_upper",                  "weight": 0.5},
    {"muscle_id": "serratus_anterior",            "weight": 0.4},
    {"muscle_id": "pectorals_clavicular",         "weight": 0.25},
    {"muscle_id": "rectus_abdominis",             "weight": 0.3},
    {"muscle_id": "rotator_cuff_supraspinatus",   "weight": 0.25}
  ]'::jsonb,
  '{
    "delts_anterior": "The piked position rotates the press direction toward vertical — front delts become the primary mover, just like standing OHP. This is the bodyweight stepping stone toward handstand push-up.",
    "triceps_long": "Shoulder flexed in the piked position puts the long head in a stretched state — same overhead advantage as standing OHP vs flat bench."
  }'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  ARRAY['strength', 'hypertrophy'],
  'secondary_compound', 'anywhere',
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY['overhead_rom', 'shoulder_flexion'],
  '[]'::jsonb,
  'ffffffff-0000-1111-2222-000000000001',
  NULL,
  'stretched',
  'system', FALSE
);

-- ─── 40. Inverted Row ───────────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0040-0000-0000-000000000001',
  'Inverted Row',
  ARRAY['bodyweight row', 'australian pull-up', 'horizontal pull-up'],
  'lifting',
  'horizontal_pull', NULL, 'bilateral',
  -- Bodyweight horizontal pull. Pronated grip default → brachialis dominant
  -- over biceps (Pattern 4). Reverse-plank body position adds core
  -- anti-extension demand (rectus_abdominis, obliques).
  -- Lat emphasis: rows = balanced (Pattern 3), lats_lower slightly dominant.
  '[
    {"muscle_id": "lats_lower",                 "weight": 1.0},
    {"muscle_id": "lats_upper",                 "weight": 0.9},
    {"muscle_id": "teres_major",                "weight": 0.7},
    {"muscle_id": "rhomboids",                  "weight": 0.6},
    {"muscle_id": "traps_middle",               "weight": 0.5},
    {"muscle_id": "traps_lower",                "weight": 0.4},
    {"muscle_id": "delts_posterior",            "weight": 0.4},
    {"muscle_id": "brachialis",                 "weight": 0.8},
    {"muscle_id": "biceps_long",                "weight": 0.5},
    {"muscle_id": "biceps_short",               "weight": 0.5},
    {"muscle_id": "forearms_brachioradialis",   "weight": 0.4},
    {"muscle_id": "forearms_grip",              "weight": 0.4},
    {"muscle_id": "rectus_abdominis",           "weight": 0.3},
    {"muscle_id": "obliques",                   "weight": 0.25}
  ]'::jsonb,
  '{
    "brachialis": "Pronated overhand grip emphasizes brachialis over biceps — same pattern as barbell bent-over row.",
    "rectus_abdominis": "Reverse-plank body position means the abs work anti-extension throughout the set — additional core stimulus not present in cable or machine row alternatives.",
    "lats_lower": "Body angle affects emphasis: steeper angle (more vertical) increases lat contribution per rep. Adjust angle to manage difficulty and target emphasis."
  }'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  ARRAY['strength', 'hypertrophy'],
  'secondary_compound', 'anywhere',
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '00000000-1111-2222-3333-100000000001',
  '{"grip": "pronated"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 41. Sumo Deadlift ──────────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0041-0000-0000-000000000001',
  'Sumo Deadlift',
  ARRAY['sumo DL', 'wide-stance deadlift', 'sumo pull'],
  'lifting',
  'hinge', 'squat', 'bilateral',
  -- Sumo: wide stance + upright torso = more quad + adductor contribution,
  -- less lower back than conventional. adductors_magnus rises to 1.0
  -- (becomes a true hip extensor in wide external-rotation position).
  -- glutes_max 1.0 (hip-dominant variant per conventions). quads at full
  -- engagement (more upright torso = more leg drive). spinal_erectors
  -- drops to 0.4 (more upright torso = less lumbar moment arm).
  -- Bilateral → glutes_medius ≤ 0.3. forearms_grip 0.8 (same as conv DL).
  '[
    {"muscle_id": "quads_vastus_lateralis",     "weight": 1.0},
    {"muscle_id": "quads_vastus_medialis",      "weight": 1.0},
    {"muscle_id": "quads_vastus_intermedius",   "weight": 0.9},
    {"muscle_id": "quads_rectus_femoris",       "weight": 0.7},
    {"muscle_id": "glutes_max",                 "weight": 1.0},
    {"muscle_id": "glutes_medius",              "weight": 0.3},
    {"muscle_id": "adductors_magnus",           "weight": 1.0},
    {"muscle_id": "adductors_short",            "weight": 0.5},
    {"muscle_id": "hamstrings_bf_long",         "weight": 0.6},
    {"muscle_id": "hamstrings_semitendinosus",  "weight": 0.5},
    {"muscle_id": "hamstrings_semimembranosus", "weight": 0.5},
    {"muscle_id": "spinal_erectors",            "weight": 0.4},
    {"muscle_id": "traps_upper",                "weight": 0.6},
    {"muscle_id": "traps_middle",               "weight": 0.4},
    {"muscle_id": "forearms_grip",              "weight": 0.8},
    {"muscle_id": "forearms_brachioradialis",   "weight": 0.3}
  ]'::jsonb,
  '{
    "adductors_magnus": "Sumo''s wide stance makes adductor magnus a genuine target — it functions as a hip extensor in the abducted external-rotation position. One of the few lifts where adductors hit 1.0.",
    "glutes_max": "Wide stance + external hip rotation puts glute max at full target status — same reason it''s at 1.0 on low-bar wide-stance squat. Sumo is the canonical hip-dominant deadlift variant.",
    "spinal_erectors": "Significantly lower than conventional DL because the upright torso reduces the lumbar flexion moment arm. Sumo is back-friendlier than conventional for lifters with lower back issues.",
    "quads_vastus_lateralis": "More quad-dominant than conventional because the upright torso increases knee extension contribution off the floor. This is the squat component of sumo."
  }'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['hip_internal_rotation', 'grip_intensive'],
  '[]'::jsonb,
  '66666666-6666-6666-6666-666666666666',
  '{"stance": "sumo"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 42. Face Pull ──────────────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0042-0000-0000-000000000001',
  'Face Pull',
  ARRAY['cable face pull', 'rope face pull', 'high face pull'],
  'lifting',
  'horizontal_pull', NULL, 'bilateral',
  -- Rear delt primary + upper back target exercise. High-elbow pull forces
  -- scapular retraction and external rotation simultaneously.
  -- rotator_cuff added vs v1: external rotation at end-range is the defining
  -- demand of face pull; infraspinatus and teres_minor both work.
  -- No biceps entry — elbow angle stays near 90° with minimal elbow flexion
  -- change through the rep; biceps are not meaningfully involved.
  '[
    {"muscle_id": "delts_posterior",            "weight": 1.0},
    {"muscle_id": "traps_middle",               "weight": 0.8},
    {"muscle_id": "traps_lower",                "weight": 0.7},
    {"muscle_id": "rhomboids",                  "weight": 0.5},
    {"muscle_id": "rotator_cuff_infraspinatus", "weight": 0.5},
    {"muscle_id": "rotator_cuff_teres_minor",   "weight": 0.4},
    {"muscle_id": "delts_lateral",              "weight": 0.25},
    {"muscle_id": "forearms_grip",              "weight": 0.25}
  ]'::jsonb,
  '{
    "delts_posterior": "The primary target — face pull is one of the few exercises that loads the rear delt as the primary mover. High elbows pulling to the face with external rotation at the end is what isolates it.",
    "traps_middle": "High-elbow cable path forces scapular retraction and depression simultaneously, loading mid and lower traps together. Makes face pull uniquely effective for upper back posture work.",
    "rotator_cuff_infraspinatus": "External rotation at end-range is the movement that distinguishes face pull from a regular horizontal row. This is why face pull is programmed for shoulder health and injury prevention."
  }'::jsonb,
  'cable', NULL, 5.00, 2.50,
  ARRAY['hypertrophy', 'stability'],
  'accessory', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['shoulder_external_rotation'],
  '[]'::jsonb,
  '11111111-2222-3333-4444-100000000001',
  '{"grip": "neutral"}'::jsonb,
  'shortened',
  'system', FALSE
);

-- ─── 43. Walking Lunge — Dumbbell ───────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0043-0000-0000-000000000001',
  'Walking Lunge — Dumbbell',
  ARRAY['walking lunge', 'DB walking lunge', 'dumbbell lunge'],
  'lifting',
  'lunge_split', NULL, 'alternating',
  -- Weights describe the working (lead) leg per rep.
  -- Unilateral rule applies: glutes_medius 0.6, glutes_minimus 0.4.
  -- glutes_max 0.8 (long stride = hip extension demand; unilateral = more
  -- glute credit than bilateral squat).
  -- hip_flexors_iliopsoas 0.4: trail leg hip flexors are dynamically
  -- stretched and contract to drive the leg forward — unique to walking
  -- lunge vs stationary splits.
  -- forearms_grip 0.35: holding DBs for multiple steps.
  '[
    {"muscle_id": "quads_rectus_femoris",        "weight": 0.85},
    {"muscle_id": "quads_vastus_lateralis",      "weight": 1.0},
    {"muscle_id": "quads_vastus_medialis",       "weight": 1.0},
    {"muscle_id": "quads_vastus_intermedius",    "weight": 1.0},
    {"muscle_id": "glutes_max",                  "weight": 0.8},
    {"muscle_id": "glutes_medius",               "weight": 0.6},
    {"muscle_id": "glutes_minimus",              "weight": 0.4},
    {"muscle_id": "hamstrings_bf_long",          "weight": 0.4},
    {"muscle_id": "hamstrings_semitendinosus",   "weight": 0.4},
    {"muscle_id": "hamstrings_semimembranosus",  "weight": 0.4},
    {"muscle_id": "adductors_magnus",            "weight": 0.5},
    {"muscle_id": "adductors_short",             "weight": 0.35},
    {"muscle_id": "hip_flexors_iliopsoas",       "weight": 0.4},
    {"muscle_id": "hip_flexors_tfl",             "weight": 0.25},
    {"muscle_id": "spinal_erectors",             "weight": 0.3},
    {"muscle_id": "rectus_abdominis",            "weight": 0.3},
    {"muscle_id": "obliques",                    "weight": 0.4},
    {"muscle_id": "calves_gastrocnemius",        "weight": 0.25},
    {"muscle_id": "forearms_grip",               "weight": 0.35}
  ]'::jsonb,
  '{
    "glutes_medius": "Unilateral stepping pattern creates the same abductor demand as Bulgarian Split Squat — glute medius works hard to prevent pelvic drop. Often what''s sore the day after walking lunges.",
    "hip_flexors_iliopsoas": "Trail leg hip flexors are dynamically stretched and then contract to drive the leg forward for the next step — one of the few lower body exercises where hip flexors are a real contributor.",
    "obliques": "Anti-rotation demand from the alternating locomotion. Obliques resist trunk rotation with each step, which is why walking lunges transfer well to athletic movements."
  }'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy', 'stability'],
  'secondary_compound', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['unilateral_balance', 'hip_flexion', 'deep_knee_flexion'],
  '[]'::jsonb,
  '22222222-3333-4444-5555-100000000001',
  '{"stance": "split"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 44. Seated Calf Raise ──────────────────────────────────────────────────
INSERT INTO public.exercises (
  exercise_id, name, aliases, domain,
  movement_pattern_primary, movement_pattern_secondary, loading_type,
  muscles,
  head_emphasis_notes,
  equipment_primary, equipment_specific, load_increment_default, load_increment_micro,
  training_modality, default_role, session_position,
  performance_metric, progression_eligible, relative_to_bodyweight,
  demands, prerequisites,
  exercise_family_id, variation_attributes,
  loaded_position,
  authored_by, verified
) VALUES (
  'aaaaaaaa-0044-0000-0000-000000000001',
  'Seated Calf Raise',
  ARRAY['seated calf', 'machine seated calf raise', 'soleus raise'],
  'lifting',
  'ankle_plantarflexion', NULL, 'bilateral',
  -- Knee bent (seated) shortens the gastrocnemius, removing it from effective
  -- force production and shifting load to soleus (single-joint plantarflexor).
  -- calves_soleus 1.0 — this is the soleus isolation exercise.
  -- calves_gastrocnemius 0.3 — partial contribution in early ROM before
  -- becoming slack; two-joint shortening at the knee reduces it greatly.
  '[
    {"muscle_id": "calves_soleus",              "weight": 1.0},
    {"muscle_id": "calves_gastrocnemius",       "weight": 0.3}
  ]'::jsonb,
  '{
    "calves_soleus": "Knee bent (seated) shortens the gastrocnemius by slackening it at the knee, shifting all plantarflexion work to the soleus. This is the direct soleus isolation exercise.",
    "calves_gastrocnemius": "Two-joint shortening at the knee means gastroc is nearly slack here. The 0.3 weight reflects partial contribution in the early ROM before it becomes fully inactive."
  }'::jsonb,
  'machine', 'seated_calf_raise', 10.00, 5.00,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '33333333-4444-5555-6666-777777777777',
  NULL,
  'shortened',
  'system', FALSE
);


-- =============================================================================
-- Substitution graph — batch 4 + cross-batch reciprocals
-- =============================================================================
-- Directional. Targeting 2-4 substitutes per exercise per conventions §10.
-- Cross-batch refs:
--   pull_up               = aaaaaaaa-0002-0000-0000-000000000001
--   bb_bench              = aaaaaaaa-0012-0000-0000-000000000001
--   db_bench              = aaaaaaaa-0013-0000-0000-000000000001
--   bb_row                = aaaaaaaa-0014-0000-0000-000000000001
--   chest_supported_row   = aaaaaaaa-0015-0000-0000-000000000001
--   bb_ohp                = aaaaaaaa-0016-0000-0000-000000000001
--   db_ohp                = aaaaaaaa-0017-0000-0000-000000000001
--   conventional_dl       = aaaaaaaa-0009-0000-0000-000000000001
--   rdl                   = aaaaaaaa-0010-0000-0000-000000000001
--   bulgarian_split_squat = aaaaaaaa-0004-0000-0000-000000000001
--   leg_press             = aaaaaaaa-0005-0000-0000-000000000001
--   lat_pulldown          = aaaaaaaa-0022-0000-0000-000000000001
--   cable_row             = aaaaaaaa-0023-0000-0000-000000000001
--   dip                   = aaaaaaaa-0020-0000-0000-000000000001
--   standing_calf_raise   = aaaaaaaa-0026-0000-0000-000000000001

INSERT INTO public.exercise_substitutes (exercise_id, substitute_id, similarity_score, reason) VALUES
  -- ── 30. Plank ────────────────────────────────────────────────────────────
  ('aaaaaaaa-0030-0000-0000-000000000001', 'aaaaaaaa-0033-0000-0000-000000000001', 0.55, 'progression'),
  ('aaaaaaaa-0030-0000-0000-000000000001', 'aaaaaaaa-0031-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0030-0000-0000-000000000001', 'aaaaaaaa-0032-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),

  -- ── 31. Side Plank ───────────────────────────────────────────────────────
  ('aaaaaaaa-0031-0000-0000-000000000001', 'aaaaaaaa-0030-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0031-0000-0000-000000000001', 'aaaaaaaa-0035-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),

  -- ── 32. Hanging Leg Raise ────────────────────────────────────────────────
  ('aaaaaaaa-0032-0000-0000-000000000001', 'aaaaaaaa-0033-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0032-0000-0000-000000000001', 'aaaaaaaa-0034-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0032-0000-0000-000000000001', 'aaaaaaaa-0030-0000-0000-000000000001', 0.45, 'regression'),

  -- ── 33. Ab Wheel Rollout ─────────────────────────────────────────────────
  ('aaaaaaaa-0033-0000-0000-000000000001', 'aaaaaaaa-0030-0000-0000-000000000001', 0.55, 'regression'),
  ('aaaaaaaa-0033-0000-0000-000000000001', 'aaaaaaaa-0032-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0033-0000-0000-000000000001', 'aaaaaaaa-0034-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),

  -- ── 34. Cable Crunch ─────────────────────────────────────────────────────
  ('aaaaaaaa-0034-0000-0000-000000000001', 'aaaaaaaa-0032-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0034-0000-0000-000000000001', 'aaaaaaaa-0033-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0034-0000-0000-000000000001', 'aaaaaaaa-0030-0000-0000-000000000001', 0.40, 'regression'),

  -- ── 35. Pallof Press ─────────────────────────────────────────────────────
  ('aaaaaaaa-0035-0000-0000-000000000001', 'aaaaaaaa-0031-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0035-0000-0000-000000000001', 'aaaaaaaa-0036-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),

  -- ── 36. Cable Woodchop ───────────────────────────────────────────────────
  ('aaaaaaaa-0036-0000-0000-000000000001', 'aaaaaaaa-0035-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0036-0000-0000-000000000001', 'aaaaaaaa-0034-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),

  -- ── 37. Push-Up ──────────────────────────────────────────────────────────
  ('aaaaaaaa-0037-0000-0000-000000000001', 'aaaaaaaa-0038-0000-0000-000000000001', 0.85, 'regression'),
  ('aaaaaaaa-0037-0000-0000-000000000001', 'aaaaaaaa-0012-0000-0000-000000000001', 0.75, 'progression'),
  ('aaaaaaaa-0037-0000-0000-000000000001', 'aaaaaaaa-0013-0000-0000-000000000001', 0.70, 'progression'),

  -- ── 38. Incline Push-Up ──────────────────────────────────────────────────
  ('aaaaaaaa-0038-0000-0000-000000000001', 'aaaaaaaa-0037-0000-0000-000000000001', 0.85, 'progression'),
  ('aaaaaaaa-0038-0000-0000-000000000001', 'aaaaaaaa-0012-0000-0000-000000000001', 0.55, 'progression'),

  -- ── 39. Pike Push-Up ─────────────────────────────────────────────────────
  ('aaaaaaaa-0039-0000-0000-000000000001', 'aaaaaaaa-0016-0000-0000-000000000001', 0.70, 'progression'),
  ('aaaaaaaa-0039-0000-0000-000000000001', 'aaaaaaaa-0017-0000-0000-000000000001', 0.65, 'progression'),
  ('aaaaaaaa-0039-0000-0000-000000000001', 'aaaaaaaa-0037-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),

  -- ── 40. Inverted Row ─────────────────────────────────────────────────────
  ('aaaaaaaa-0040-0000-0000-000000000001', 'aaaaaaaa-0014-0000-0000-000000000001', 0.75, 'progression'),
  ('aaaaaaaa-0040-0000-0000-000000000001', 'aaaaaaaa-0015-0000-0000-000000000001', 0.65, 'progression'),
  ('aaaaaaaa-0040-0000-0000-000000000001', 'aaaaaaaa-0023-0000-0000-000000000001', 0.65, 'progression'),

  -- Reciprocals: BB row, DB row, cable row → inverted row as regression.
  ('aaaaaaaa-0014-0000-0000-000000000001', 'aaaaaaaa-0040-0000-0000-000000000001', 0.65, 'regression'),
  ('aaaaaaaa-0015-0000-0000-000000000001', 'aaaaaaaa-0040-0000-0000-000000000001', 0.65, 'regression'),
  ('aaaaaaaa-0023-0000-0000-000000000001', 'aaaaaaaa-0040-0000-0000-000000000001', 0.55, 'regression'),

  -- Reciprocals: bench → push-up, OHP → pike push-up.
  ('aaaaaaaa-0012-0000-0000-000000000001', 'aaaaaaaa-0037-0000-0000-000000000001', 0.65, 'regression'),
  ('aaaaaaaa-0013-0000-0000-000000000001', 'aaaaaaaa-0037-0000-0000-000000000001', 0.65, 'regression'),
  ('aaaaaaaa-0016-0000-0000-000000000001', 'aaaaaaaa-0039-0000-0000-000000000001', 0.60, 'regression'),
  ('aaaaaaaa-0017-0000-0000-000000000001', 'aaaaaaaa-0039-0000-0000-000000000001', 0.60, 'regression'),

  -- ── 41. Sumo Deadlift ────────────────────────────────────────────────────
  ('aaaaaaaa-0041-0000-0000-000000000001', 'aaaaaaaa-0009-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0041-0000-0000-000000000001', 'aaaaaaaa-0010-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0041-0000-0000-000000000001', 'aaaaaaaa-0006-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),

  -- Reciprocal: conventional DL → sumo.
  ('aaaaaaaa-0009-0000-0000-000000000001', 'aaaaaaaa-0041-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),

  -- ── 42. Face Pull ────────────────────────────────────────────────────────
  ('aaaaaaaa-0042-0000-0000-000000000001', 'aaaaaaaa-0015-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0042-0000-0000-000000000001', 'aaaaaaaa-0023-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),

  -- ── 43. Walking Lunge — DB ───────────────────────────────────────────────
  ('aaaaaaaa-0043-0000-0000-000000000001', 'aaaaaaaa-0004-0000-0000-000000000001', 0.75, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0043-0000-0000-000000000001', 'aaaaaaaa-0001-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0043-0000-0000-000000000001', 'aaaaaaaa-0008-0000-0000-000000000001', 0.55, 'regression'),

  -- Reciprocal: BSS → walking lunge.
  ('aaaaaaaa-0004-0000-0000-000000000001', 'aaaaaaaa-0043-0000-0000-000000000001', 0.75, 'same_pattern_different_equipment'),

  -- ── 44. Seated Calf Raise ────────────────────────────────────────────────
  ('aaaaaaaa-0044-0000-0000-000000000001', 'aaaaaaaa-0026-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),

  -- Reciprocal: standing calf raise → seated.
  ('aaaaaaaa-0026-0000-0000-000000000001', 'aaaaaaaa-0044-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment');
