-- =============================================================================
-- Seed Exercises — Batch 2 (12 exercises: squat completion, hinge, push, pull)
-- Updated for muscle taxonomy v2 — per-head distributions and head_emphasis_notes added.
-- =============================================================================
-- Purpose: fill out the most important gaps after batch 1's 5 representative
-- exercises. NOT for live insertion until reviewed; format matches batch 1
-- (db/seed_exercises_v1_draft.sql) exactly.
--
-- Mix:
--   Squat family completion
--     6.  Barbell Back Squat — Low-Bar
--     7.  Barbell Front Squat
--     8.  Goblet Squat
--   Hinge pattern
--     9.  Conventional Deadlift
--    10.  Romanian Deadlift (RDL) — Barbell
--    11.  Hip Thrust — Barbell
--   Horizontal push
--    12.  Barbell Bench Press — Flat
--    13.  Dumbbell Bench Press — Flat
--   Horizontal pull
--    14.  Barbell Bent-Over Row
--    15.  Chest-Supported Dumbbell Row
--   Vertical push
--    16.  Standing Barbell Overhead Press
--    17.  Seated Dumbbell Overhead Press
--
-- Conventions adhered to (see docs/exercise_authoring_conventions.md v2):
--   - §1: variations are separate rows.
--   - §2: muscle-weighting discipline. Per-head v2 with intermediate weights.
--   - §13: all muscle_ids are per-head or singletons; no group references.
--   - §14: seven biomechanical patterns applied throughout.
--
-- All `relative_to_bodyweight` = FALSE for this batch.
-- All `progression_eligible` = TRUE.
-- All `authored_by` = 'system', `verified` = FALSE.
-- =============================================================================

-- Pre-generated UUIDs so substitutes wire up in one script.
-- Family IDs (§1: variations of same lift share a family_id)
--   squat_family       = 11111111-1111-1111-1111-111111111111   (batch 1; reused)
--   pullup_family      = 22222222-2222-2222-2222-222222222222   (batch 1)
--   lateral_family     = 33333333-3333-3333-3333-333333333333   (batch 1)
--   splitsquat_family  = 44444444-4444-4444-4444-444444444444   (batch 1)
--   legpress_family    = 55555555-5555-5555-5555-555555555555   (batch 1)
--   deadlift_family    = 66666666-6666-6666-6666-666666666666
--   rdl_family         = 77777777-7777-7777-7777-777777777777
--   hip_thrust_family  = 88888888-8888-8888-8888-888888888888
--   bench_family       = 99999999-9999-9999-9999-999999999999
--   row_family         = bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb
--   ohp_family         = cccccccc-cccc-cccc-cccc-cccccccccccc
--
-- Exercise IDs:
--   back_squat_low_bar   = aaaaaaaa-0006-0000-0000-000000000001
--   front_squat          = aaaaaaaa-0007-0000-0000-000000000001
--   goblet_squat         = aaaaaaaa-0008-0000-0000-000000000001
--   conventional_dl      = aaaaaaaa-0009-0000-0000-000000000001
--   rdl_barbell          = aaaaaaaa-0010-0000-0000-000000000001
--   hip_thrust_barbell   = aaaaaaaa-0011-0000-0000-000000000001
--   bench_press_bb       = aaaaaaaa-0012-0000-0000-000000000001
--   bench_press_db       = aaaaaaaa-0013-0000-0000-000000000001
--   bent_over_row_bb     = aaaaaaaa-0014-0000-0000-000000000001
--   chest_supported_row  = aaaaaaaa-0015-0000-0000-000000000001
--   ohp_standing_bb      = aaaaaaaa-0016-0000-0000-000000000001
--   ohp_seated_db        = aaaaaaaa-0017-0000-0000-000000000001


-- ─── 6. Barbell Back Squat — Low-Bar ────────────────────────────────────────
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
  'aaaaaaaa-0006-0000-0000-000000000001',
  'Barbell Back Squat — Low-Bar',
  ARRAY['low-bar squat', 'low bar back squat', 'powerlifting squat', 'low-bar back squat'],
  'lifting',
  'squat', 'hinge', 'bilateral',
  -- Low-bar shifts the bar onto the rear delts → more horizontal torso → longer
  -- hip moment arm, shorter knee moment arm. glutes_max rises to 1.0 (this is
  -- a hip-dominant squat variant per conventions §14). RF gets a larger two-joint
  -- discount than high-bar because the forward lean increases hip flexion at the
  -- bottom. Hamstrings become real synergists (0.5) instead of stabilizers (0.25).
  -- Spinal erectors bump to 0.5 from 0.4 (more horizontal torso = more lumbar demand).
  '[
    {"muscle_id": "quads_rectus_femoris",       "weight": 0.7},
    {"muscle_id": "quads_vastus_lateralis",     "weight": 1.0},
    {"muscle_id": "quads_vastus_medialis",      "weight": 1.0},
    {"muscle_id": "quads_vastus_intermedius",   "weight": 1.0},
    {"muscle_id": "glutes_max",                 "weight": 1.0},
    {"muscle_id": "glutes_medius",              "weight": 0.3},
    {"muscle_id": "adductors_magnus",           "weight": 0.7},
    {"muscle_id": "adductors_short",            "weight": 0.4},
    {"muscle_id": "hamstrings_bf_long",         "weight": 0.5},
    {"muscle_id": "hamstrings_semitendinosus",  "weight": 0.5},
    {"muscle_id": "hamstrings_semimembranosus", "weight": 0.5},
    {"muscle_id": "spinal_erectors",            "weight": 0.5},
    {"muscle_id": "rectus_abdominis",           "weight": 0.25},
    {"muscle_id": "obliques",                   "weight": 0.25},
    {"muscle_id": "calves_gastrocnemius",       "weight": 0.25}
  ]'::jsonb,
  '{
    "quads_rectus_femoris": "Lower bar position means a more horizontal torso, which increases hip flexion at the bottom and shortens rectus femoris more than on high-bar. Vasti get the full ROM benefit; RF does not.",
    "glutes_max": "Low-bar''s defining characteristic — the long hip moment arm loads glute max through full stretch at the bottom. This is why low-bar moves more weight than high-bar despite identical muscles.",
    "hamstrings_bf_long": "Posterior-chain dominant by design. The hamstrings assist hip extension through most of the lift — a step up from stabilizer (high-bar) to real synergist.",
    "spinal_erectors": "More work than on high-bar because the torso leans further forward. The erectors must resist a larger lumbar flexion moment throughout the rep."
  }'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['deep_knee_flexion', 'ankle_dorsiflexion', 'axial_loading', 'thoracic_extension'],
  '[]'::jsonb,
  '11111111-1111-1111-1111-111111111111',
  '{"bar_position": "low_bar", "stance": "wide"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 7. Barbell Front Squat ─────────────────────────────────────────────────
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
  'aaaaaaaa-0007-0000-0000-000000000001',
  'Barbell Front Squat',
  ARRAY['front squat', 'BB front squat', 'clean-grip front squat'],
  'lifting',
  'squat', NULL, 'bilateral',
  -- Bar in front rack → upright torso → most quad-dominant barbell squat.
  -- RF discount is smallest here (0.85) because hip flexion at bottom is minimized.
  -- glutes_max drops to 0.4 (short hip moment arm, not the primary mover).
  -- rectus_abdominis rises to 0.5 — the front-loaded bar creates real anti-extension
  -- demand; the core is a genuine synergist here, not just a brace.
  '[
    {"muscle_id": "quads_rectus_femoris",       "weight": 0.85},
    {"muscle_id": "quads_vastus_lateralis",     "weight": 1.0},
    {"muscle_id": "quads_vastus_medialis",      "weight": 1.0},
    {"muscle_id": "quads_vastus_intermedius",   "weight": 1.0},
    {"muscle_id": "glutes_max",                 "weight": 0.4},
    {"muscle_id": "glutes_medius",              "weight": 0.25},
    {"muscle_id": "adductors_magnus",           "weight": 0.5},
    {"muscle_id": "adductors_short",            "weight": 0.3},
    {"muscle_id": "rectus_abdominis",           "weight": 0.5},
    {"muscle_id": "obliques",                   "weight": 0.4},
    {"muscle_id": "spinal_erectors",            "weight": 0.3},
    {"muscle_id": "hamstrings_bf_long",         "weight": 0.25},
    {"muscle_id": "calves_gastrocnemius",       "weight": 0.25}
  ]'::jsonb,
  '{
    "quads_rectus_femoris": "Upright torso keeps the hip angle more open throughout the lift, reducing the two-joint canceling effect. More RF contribution here than on low-bar or even high-bar back squat.",
    "glutes_max": "Significantly lower than back squat variants — the upright torso shortens the hip moment arm and glutes contribute much less. Use back squat or hip thrust for glute emphasis.",
    "rectus_abdominis": "The bar in front creates a genuine anti-extension demand. Without core bracing the torso will fold forward. One of the few squat variations where abs are a true synergist."
  }'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['deep_knee_flexion', 'ankle_dorsiflexion', 'axial_loading', 'thoracic_extension', 'shoulder_external_rotation'],
  '[]'::jsonb,
  '11111111-1111-1111-1111-111111111111',
  '{"bar_position": "front", "stance": "shoulder_width"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 8. Goblet Squat ────────────────────────────────────────────────────────
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
  'aaaaaaaa-0008-0000-0000-000000000001',
  'Goblet Squat',
  ARRAY['DB goblet squat', 'KB goblet squat', 'dumbbell goblet squat'],
  'lifting',
  'squat', NULL, 'bilateral',
  -- Upright torso similar to front squat → quad-dominant. RF at 0.85 (same logic).
  -- glutes_max at 0.4 (less than back squat). rectus_abdominis at 0.4 (single
  -- counterbalance load at chest; less anti-extension demand than front rack).
  -- Bilateral rule → glutes_medius at 0.25, glutes_minimus omitted.
  '[
    {"muscle_id": "quads_rectus_femoris",       "weight": 0.85},
    {"muscle_id": "quads_vastus_lateralis",     "weight": 1.0},
    {"muscle_id": "quads_vastus_medialis",      "weight": 1.0},
    {"muscle_id": "quads_vastus_intermedius",   "weight": 1.0},
    {"muscle_id": "glutes_max",                 "weight": 0.4},
    {"muscle_id": "glutes_medius",              "weight": 0.25},
    {"muscle_id": "adductors_magnus",           "weight": 0.5},
    {"muscle_id": "adductors_short",            "weight": 0.3},
    {"muscle_id": "rectus_abdominis",           "weight": 0.4},
    {"muscle_id": "obliques",                   "weight": 0.3},
    {"muscle_id": "spinal_erectors",            "weight": 0.25},
    {"muscle_id": "hamstrings_bf_long",         "weight": 0.25},
    {"muscle_id": "calves_gastrocnemius",       "weight": 0.25}
  ]'::jsonb,
  '{
    "quads_rectus_femoris": "Upright goblet position (like front squat) keeps hip angle open at the bottom, so RF cancels less versus the vasti. Good for training all four quad heads in proportion.",
    "rectus_abdominis": "Single load held at the chest creates a mild anti-extension demand — present throughout but lighter than front squat because the load is lower."
  }'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['hypertrophy', 'mobility', 'stability'],
  'accessory', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['deep_knee_flexion', 'ankle_dorsiflexion'],
  '[]'::jsonb,
  '11111111-1111-1111-1111-111111111111',
  NULL,
  'stretched',
  'system', FALSE
);

-- ─── 9. Conventional Deadlift ───────────────────────────────────────────────
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
  'aaaaaaaa-0009-0000-0000-000000000001',
  'Conventional Deadlift',
  ARRAY['deadlift', 'conv DL', 'BB deadlift', 'conventional DL'],
  'lifting',
  'hinge', NULL, 'bilateral',
  -- Two muscles at 1.0: hamstrings_bf_long (primary hip extensor off the floor)
  -- and spinal_erectors (large flexion moment arm; often what fails on heavy attempts).
  -- glutes_max at 0.7 — dominant at lockout but hamstrings drive most of the pull.
  -- Quads at 0.4-0.5 — leg drive off the floor.
  -- traps_upper/middle at 0.6/0.4 — heavy isometric scapular support throughout.
  -- forearms_grip at 0.8 — often the limiting factor before primary muscles fail.
  -- Bilateral → glutes_medius at 0.25. adductors_magnus as hip extensor at 0.6.
  '[
    {"muscle_id": "hamstrings_bf_long",         "weight": 1.0},
    {"muscle_id": "hamstrings_semitendinosus",  "weight": 0.8},
    {"muscle_id": "hamstrings_semimembranosus", "weight": 0.8},
    {"muscle_id": "hamstrings_bf_short",        "weight": 0.25},
    {"muscle_id": "spinal_erectors",            "weight": 1.0},
    {"muscle_id": "glutes_max",                 "weight": 0.7},
    {"muscle_id": "glutes_medius",              "weight": 0.25},
    {"muscle_id": "quads_vastus_lateralis",     "weight": 0.5},
    {"muscle_id": "quads_vastus_medialis",      "weight": 0.5},
    {"muscle_id": "quads_vastus_intermedius",   "weight": 0.4},
    {"muscle_id": "quads_rectus_femoris",       "weight": 0.35},
    {"muscle_id": "adductors_magnus",           "weight": 0.6},
    {"muscle_id": "traps_upper",                "weight": 0.6},
    {"muscle_id": "traps_middle",               "weight": 0.4},
    {"muscle_id": "rhomboids",                  "weight": 0.4},
    {"muscle_id": "forearms_grip",              "weight": 0.8},
    {"muscle_id": "forearms_brachioradialis",   "weight": 0.3},
    {"muscle_id": "rectus_abdominis",           "weight": 0.4},
    {"muscle_id": "obliques",                   "weight": 0.4}
  ]'::jsonb,
  '{
    "hamstrings_bf_long": "Primary hip extensor from the floor. BF long crosses both hip and knee, making it the key hamstring head on a hip-dominant hinge. The hamstrings drive the first half of the pull.",
    "spinal_erectors": "On deadlift (unlike squat), the erectors work against a large flexion moment arm with the bar away from the body. They''re often what fails on a near-max attempt — hence the 1.0 weight.",
    "glutes_max": "Take over from hamstrings as primary hip extensor approaching lockout. The final third of the pull is glute-dominated.",
    "quads_rectus_femoris": "Hip flexion at the start position creates a mild two-joint discount. Quads contribute to the initial leg drive off the floor but are secondary to the posterior chain.",
    "forearms_grip": "Often the limiting factor before the primary muscles fail, especially double-overhand without straps. Mixed grip shifts the demand but grip is still a real constraint."
  }'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['lumbar_loading', 'hip_flexion', 'grip_intensive'],
  '[]'::jsonb,
  '66666666-6666-6666-6666-666666666666',
  '{"stance": "conventional"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 10. Romanian Deadlift (RDL) — Barbell ──────────────────────────────────
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
  'aaaaaaaa-0010-0000-0000-000000000001',
  'Romanian Deadlift',
  ARRAY['RDL', 'barbell RDL', 'BB romanian deadlift'],
  'lifting',
  'hinge', NULL, 'bilateral',
  -- hamstrings are the uncontested target — loaded at full stretch throughout.
  -- bf_long/semis at 1.0/0.9 (all three cross the hip). bf_short at 0.4
  -- (knee-only; knee stays slightly bent = some contribution).
  -- glutes_max 0.7 — active at hip extension (lockout), not the primary by design.
  -- spinal_erectors 0.6 — significant lumbar loading from the hinged position.
  -- forearms_grip 0.7 — heavy RDLs are grip-intensive; often fatigues before hamstrings.
  '[
    {"muscle_id": "hamstrings_bf_long",         "weight": 1.0},
    {"muscle_id": "hamstrings_semitendinosus",  "weight": 0.9},
    {"muscle_id": "hamstrings_semimembranosus", "weight": 0.9},
    {"muscle_id": "hamstrings_bf_short",        "weight": 0.4},
    {"muscle_id": "glutes_max",                 "weight": 0.7},
    {"muscle_id": "glutes_medius",              "weight": 0.25},
    {"muscle_id": "spinal_erectors",            "weight": 0.6},
    {"muscle_id": "adductors_magnus",           "weight": 0.5},
    {"muscle_id": "forearms_grip",              "weight": 0.7},
    {"muscle_id": "forearms_brachioradialis",   "weight": 0.3},
    {"muscle_id": "rectus_abdominis",           "weight": 0.3},
    {"muscle_id": "obliques",                   "weight": 0.3}
  ]'::jsonb,
  '{
    "hamstrings_bf_long": "The entire point of the RDL — loaded at length with the hip flexed and knee slightly bent. The eccentric phase (lowering) is where most of the stretch-mediated hypertrophy stimulus occurs. Control the descent.",
    "hamstrings_bf_short": "Crosses only the knee. Gets some work because the knee is not fully locked, but the hip-crossing heads (BF long, semis) are doing the heavy lifting.",
    "glutes_max": "Primarily active at the top — contributes to hip extension during the concentric phase. Lower overall than hip thrust because the hamstrings own the stretched position.",
    "spinal_erectors": "Resist lumbar flexion isometrically while the bar hangs far from the body. Lower back fatigue on heavy RDL is common — not a sign of bad form, a sign of real loading."
  }'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'secondary_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['lumbar_loading', 'hip_flexion', 'grip_intensive'],
  '[]'::jsonb,
  '77777777-7777-7777-7777-777777777777',
  NULL,
  'stretched',
  'system', FALSE
);

-- ─── 11. Hip Thrust — Barbell ───────────────────────────────────────────────
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
  'aaaaaaaa-0011-0000-0000-000000000001',
  'Barbell Hip Thrust',
  ARRAY['hip thrust', 'BB hip thrust', 'barbell hip thrust'],
  'lifting',
  'hinge', NULL, 'bilateral',
  -- glutes_max 1.0 — uncontested target. Peak contraction at the top.
  -- glutes_medius 0.3 — bilateral movement; pelvic stability role.
  -- hamstrings 0.5 — assist hip extension; knee-bent position limits full
  -- contribution (shortened position for BF long, which crosses the knee).
  -- adductors_magnus 0.4 — acts as hip extensor at lockout.
  -- Torso supported by bench → no spinal_erectors loading.
  '[
    {"muscle_id": "glutes_max",                 "weight": 1.0},
    {"muscle_id": "glutes_medius",              "weight": 0.3},
    {"muscle_id": "hamstrings_bf_long",         "weight": 0.5},
    {"muscle_id": "hamstrings_semitendinosus",  "weight": 0.5},
    {"muscle_id": "hamstrings_semimembranosus", "weight": 0.5},
    {"muscle_id": "adductors_magnus",           "weight": 0.4},
    {"muscle_id": "adductors_short",            "weight": 0.25},
    {"muscle_id": "calves_gastrocnemius",       "weight": 0.25}
  ]'::jsonb,
  '{
    "glutes_max": "Reaches peak contraction at the top (hips fully extended). The full-extension lockout is what separates hip thrust from RDL for glute development — glutes get both stretch and peak contraction.",
    "hamstrings_bf_long": "Foot position determines hamstring involvement. Feet close to the hips shorten the hamstrings at the bent-knee position, reducing their contribution. Feet further away increases hamstring ROM.",
    "adductors_magnus": "Functions as a hip extensor alongside glutes and hamstrings as the hips approach full extension. A secondary benefit most lifters don''t notice."
  }'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'secondary_compound', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['hip_flexion'],
  '[]'::jsonb,
  '88888888-8888-8888-8888-888888888888',
  NULL,
  'shortened',
  'system', FALSE
);

-- ─── 12. Barbell Bench Press — Flat ─────────────────────────────────────────
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
  'aaaaaaaa-0012-0000-0000-000000000001',
  'Barbell Bench Press',
  ARRAY['bench press', 'flat bench', 'BB bench', 'barbell bench'],
  'lifting',
  'horizontal_push', NULL, 'bilateral',
  -- pectorals_sternal 1.0 — flat bench is sternal-dominant (horizontal adduction).
  -- pectorals_clavicular and abdominal both at 0.6 (assist through ROM; not the primary).
  -- All three triceps heads at 0.5-0.6 — elbow extension throughout.
  -- triceps_lateral 0.6 slightly higher (more active in pressing arc).
  -- delts_anterior 0.5 — genuine pressing synergist via shoulder flexion.
  -- serratus_anterior 0.3 — scapular protraction under load.
  -- rotator_cuff_subscapularis 0.25 — internal rotation component at the shoulder.
  '[
    {"muscle_id": "pectorals_sternal",          "weight": 1.0},
    {"muscle_id": "pectorals_clavicular",       "weight": 0.6},
    {"muscle_id": "pectorals_abdominal",        "weight": 0.6},
    {"muscle_id": "triceps_lateral",            "weight": 0.6},
    {"muscle_id": "triceps_long",               "weight": 0.5},
    {"muscle_id": "triceps_medial",             "weight": 0.5},
    {"muscle_id": "delts_anterior",             "weight": 0.5},
    {"muscle_id": "serratus_anterior",          "weight": 0.3},
    {"muscle_id": "rotator_cuff_subscapularis", "weight": 0.25},
    {"muscle_id": "forearms_grip",              "weight": 0.25}
  ]'::jsonb,
  '{
    "pectorals_sternal": "Primary head for flat bench — horizontal adduction is exactly what the sternal fibers are built for. The majority of the chest work goes here.",
    "pectorals_clavicular": "Contributes more at the bottom of the press and more on incline variations. On flat, clavicular fibers assist but sternal fibers dominate.",
    "triceps_long": "Long head is less active than lateral here because the arm is not overhead (its shoulder attachment is not on stretch). Overhead tricep work — skull crushers, overhead extensions — loads the long head more.",
    "delts_anterior": "Assists shoulder flexion through the full pressing arc. Bench adds significant front-delt volume when combined with OHP — worth tracking to avoid anterior delt overuse."
  }'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['shoulder_external_rotation'],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"incline": "flat", "grip": "pronated"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 13. Dumbbell Bench Press — Flat ────────────────────────────────────────
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
  'aaaaaaaa-0013-0000-0000-000000000001',
  'Dumbbell Bench Press',
  ARRAY['DB bench', 'dumbbell bench', 'flat DB bench', 'DB flat bench'],
  'lifting',
  'horizontal_push', NULL, 'bilateral',
  -- Same primary targets as BB bench. The DB version allows a deeper stretch
  -- at the bottom (dumbbells can travel below chest height). At per-head
  -- resolution the distributions are identical; differences (greater stretch,
  -- unilateral stabilization demand) are captured in head_emphasis_notes.
  '[
    {"muscle_id": "pectorals_sternal",          "weight": 1.0},
    {"muscle_id": "pectorals_clavicular",       "weight": 0.6},
    {"muscle_id": "pectorals_abdominal",        "weight": 0.6},
    {"muscle_id": "triceps_lateral",            "weight": 0.6},
    {"muscle_id": "triceps_long",               "weight": 0.5},
    {"muscle_id": "triceps_medial",             "weight": 0.5},
    {"muscle_id": "delts_anterior",             "weight": 0.5},
    {"muscle_id": "serratus_anterior",          "weight": 0.3},
    {"muscle_id": "rotator_cuff_subscapularis", "weight": 0.25},
    {"muscle_id": "forearms_grip",              "weight": 0.25}
  ]'::jsonb,
  '{
    "pectorals_sternal": "Greater stretch at the bottom vs barbell — dumbbells can go lower than the chest. The increased stretch-to-contraction range may enhance hypertrophy stimulus vs barbell bench for the sternal head.",
    "pectorals_clavicular": "Neutral or semi-pronated grip (common on DB bench) allows elbows to track more naturally, which can shift slightly more work toward clavicular fibers vs strict pronated barbell bench.",
    "delts_anterior": "Independent arm movement adds a rotational stability demand not present on barbell bench. Slightly more delt stabilization work per rep."
  }'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['shoulder_external_rotation'],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"incline": "flat", "grip": "pronated"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 14. Barbell Bent-Over Row ──────────────────────────────────────────────
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
  'aaaaaaaa-0014-0000-0000-000000000001',
  'Barbell Bent-Over Row',
  ARRAY['BB row', 'bent-over row', 'barbell row', 'pendlay row'],
  'lifting',
  'horizontal_pull', NULL, 'bilateral',
  -- Pronated grip + shoulder-width → lower-lat dominant but rows are balanced
  -- (Pattern 3): lats_lower 1.0, lats_upper 0.9.
  -- Pronated grip → brachialis dominant over biceps (Pattern 4):
  -- brachialis 0.8, biceps_long/short 0.5.
  -- traps_mid_lower (v1) → split to traps_middle 0.5 + traps_lower 0.4.
  -- spinal_erectors 0.5 — hinged torso under load; erectors resist the
  -- significant flexion moment arm (more than squat, similar to RDL).
  '[
    {"muscle_id": "lats_lower",                 "weight": 1.0},
    {"muscle_id": "lats_upper",                 "weight": 0.9},
    {"muscle_id": "teres_major",                "weight": 0.7},
    {"muscle_id": "rhomboids",                  "weight": 0.6},
    {"muscle_id": "traps_middle",               "weight": 0.5},
    {"muscle_id": "traps_lower",                "weight": 0.4},
    {"muscle_id": "delts_posterior",            "weight": 0.5},
    {"muscle_id": "brachialis",                 "weight": 0.8},
    {"muscle_id": "biceps_long",                "weight": 0.5},
    {"muscle_id": "biceps_short",               "weight": 0.5},
    {"muscle_id": "forearms_brachioradialis",   "weight": 0.5},
    {"muscle_id": "forearms_grip",              "weight": 0.6},
    {"muscle_id": "spinal_erectors",            "weight": 0.5},
    {"muscle_id": "rectus_abdominis",           "weight": 0.3},
    {"muscle_id": "obliques",                   "weight": 0.3}
  ]'::jsonb,
  '{
    "lats_upper": "Grip width and elbow flare both affect lat emphasis. Wider grip shifts toward upper lats; shoulder-width pronated (this default) is slightly lower-lat dominant.",
    "brachialis": "Pronated grip puts biceps in a mechanically disadvantaged position and shifts elbow flexion work to brachialis. If biceps development is the goal, switch to a supinated or neutral grip row.",
    "biceps_long": "Reduced contribution vs supinated rowing because the pronated forearm weakens the biceps'' line of pull. The elbow flexion work goes to brachialis and brachioradialis instead.",
    "spinal_erectors": "The hinged torso position loads the erectors significantly against a large flexion moment arm. Heavy BB rows are a legitimate lower back stimulus — not just a carry-over from being in a hinge position."
  }'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['lumbar_loading', 'hip_flexion', 'grip_intensive'],
  '[]'::jsonb,
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  '{"grip": "pronated"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 15. Chest-Supported Dumbbell Row ───────────────────────────────────────
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
  'aaaaaaaa-0015-0000-0000-000000000001',
  'Chest-Supported Dumbbell Row',
  ARRAY['chest-supported row', 'CSR', 'incline DB row', 'prone DB row'],
  'lifting',
  'horizontal_pull', NULL, 'bilateral',
  -- Neutral grip + bench support. Neutral grip → brachialis 0.8, biceps 0.6
  -- (Pattern 4; slightly higher biceps than pronated because neutral is
  -- brachialis-dominant but allows more biceps than fully pronated).
  -- Bench support removes spinal_erectors loading vs BB row (machine Rule 5
  -- analogy: supported position removes the stabilizer demand).
  -- lats_lower 1.0, lats_upper 0.8 (rows are balanced; neutral grip).
  '[
    {"muscle_id": "lats_lower",                 "weight": 1.0},
    {"muscle_id": "lats_upper",                 "weight": 0.8},
    {"muscle_id": "teres_major",                "weight": 0.6},
    {"muscle_id": "rhomboids",                  "weight": 0.6},
    {"muscle_id": "traps_middle",               "weight": 0.5},
    {"muscle_id": "traps_lower",                "weight": 0.4},
    {"muscle_id": "delts_posterior",            "weight": 0.5},
    {"muscle_id": "brachialis",                 "weight": 0.8},
    {"muscle_id": "biceps_long",                "weight": 0.6},
    {"muscle_id": "biceps_short",               "weight": 0.6},
    {"muscle_id": "forearms_brachioradialis",   "weight": 0.4},
    {"muscle_id": "forearms_grip",              "weight": 0.4}
  ]'::jsonb,
  '{
    "brachialis": "Neutral grip emphasizes brachialis over biceps — same advantage as hammer curl over regular curl. This exercise gives you back + brachialis work in one movement.",
    "biceps_long": "Neutral grip (vs supinated) keeps biceps as a meaningful elbow flexor, just not dominant. More biceps contribution here than on the pronated BB row.",
    "lats_lower": "Chest support lets you focus entirely on the pull without lower-back fatigue limiting sets. Good option on high-volume pulling days when the erectors are already taxed."
  }'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['hypertrophy', 'strength'],
  'secondary_compound', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  '{"grip": "neutral", "incline": "incline"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 16. Standing Barbell Overhead Press ────────────────────────────────────
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
  'aaaaaaaa-0016-0000-0000-000000000001',
  'Standing Barbell Overhead Press',
  ARRAY['OHP', 'standing press', 'BB overhead press', 'military press'],
  'lifting',
  'vertical_push', NULL, 'bilateral',
  -- delts_anterior 1.0 — clear target (shoulder flexion in vertical plane).
  -- delts_lateral 0.35 — assists abduction in upper ROM; not the primary.
  -- triceps_long 0.6 — overhead position puts the long head on stretch
  -- (attached at shoulder = fully lengthened), making it more active than on bench.
  -- triceps_lateral 0.6 (most active in pressing), triceps_medial 0.5.
  -- traps_upper 0.6 — upward rotation at top of rep.
  -- serratus_anterior 0.4 — upward rotation throughout.
  -- rectus_abdominis / obliques 0.3 — anti-extension while standing under bar.
  -- rotator cuff at 0.25 — shoulder stabilization under overhead load.
  '[
    {"muscle_id": "delts_anterior",               "weight": 1.0},
    {"muscle_id": "delts_lateral",                "weight": 0.35},
    {"muscle_id": "triceps_lateral",              "weight": 0.6},
    {"muscle_id": "triceps_long",                 "weight": 0.6},
    {"muscle_id": "triceps_medial",               "weight": 0.5},
    {"muscle_id": "traps_upper",                  "weight": 0.6},
    {"muscle_id": "serratus_anterior",            "weight": 0.4},
    {"muscle_id": "rectus_abdominis",             "weight": 0.3},
    {"muscle_id": "obliques",                     "weight": 0.3},
    {"muscle_id": "rotator_cuff_supraspinatus",   "weight": 0.25},
    {"muscle_id": "rotator_cuff_infraspinatus",   "weight": 0.25},
    {"muscle_id": "forearms_grip",                "weight": 0.25},
    {"muscle_id": "forearms_wrist_flexors",       "weight": 0.25}
  ]'::jsonb,
  '{
    "delts_anterior": "Front delts are the primary mover for vertical pressing. They work through full ROM from bottom to top — one of the few exercises where they get both stretch and peak contraction.",
    "delts_lateral": "Assists abduction in the upper portion of the press (above ~90°). Not a primary trainer here — add lateral raises if lateral delts are underdeveloped.",
    "triceps_long": "Overhead position puts the long head in a stretched state (attached at the shoulder, arm elevated = fully lengthened). This is why overhead pressing builds the long head differently from bench pressing.",
    "rectus_abdominis": "Standing under a bar overhead creates an anti-extension demand — the spine wants to hyperextend under the load. Brace throughout to protect the lumbar spine."
  }'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['overhead_rom', 'shoulder_flexion', 'axial_loading', 'thoracic_extension'],
  '[]'::jsonb,
  'cccccccc-cccc-cccc-cccc-cccccccccccc',
  '{"grip": "pronated"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 17. Seated Dumbbell Overhead Press ─────────────────────────────────────
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
  'aaaaaaaa-0017-0000-0000-000000000001',
  'Seated Dumbbell Overhead Press',
  ARRAY['seated DB OHP', 'seated DB press', 'seated dumbbell press', 'DB shoulder press'],
  'lifting',
  'vertical_push', NULL, 'bilateral',
  -- Same primary targets as standing BB OHP with one key change: back support
  -- removes the anti-extension demand → drop rectus_abdominis and obliques.
  -- Core is not a meaningful synergist when seated against a backrest.
  -- All other distributions match standing OHP.
  '[
    {"muscle_id": "delts_anterior",               "weight": 1.0},
    {"muscle_id": "delts_lateral",                "weight": 0.35},
    {"muscle_id": "triceps_lateral",              "weight": 0.6},
    {"muscle_id": "triceps_long",                 "weight": 0.6},
    {"muscle_id": "triceps_medial",               "weight": 0.5},
    {"muscle_id": "traps_upper",                  "weight": 0.6},
    {"muscle_id": "serratus_anterior",            "weight": 0.4},
    {"muscle_id": "rotator_cuff_supraspinatus",   "weight": 0.25},
    {"muscle_id": "rotator_cuff_infraspinatus",   "weight": 0.25},
    {"muscle_id": "forearms_grip",                "weight": 0.25}
  ]'::jsonb,
  '{
    "delts_anterior": "Same primary role as standing OHP. Seated removes the balance challenge but the front delt stimulus is nearly identical.",
    "triceps_long": "Overhead position loads the long head through stretch — the single biggest advantage of overhead pressing versus bench for triceps long-head development.",
    "delts_lateral": "A larger ROM overhead than lateral raise but still secondary here. If lateral delts are a priority, add direct lateral raise work."
  }'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'secondary_compound', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['overhead_rom', 'shoulder_flexion'],
  '[]'::jsonb,
  'cccccccc-cccc-cccc-cccc-cccccccccccc',
  '{"grip": "neutral"}'::jsonb,
  'stretched',
  'system', FALSE
);


-- =============================================================================
-- Substitution graph (batch 2 + cross-batch)
-- =============================================================================
-- Directional. (A → B) and (B → A) are separate rows where appropriate.
-- Targeting 2-4 substitutes per exercise per conventions §10.
-- Cross-batch refs use batch-1 UUIDs:
--   back_squat (high-bar)   = aaaaaaaa-0001-0000-0000-000000000001
--   bulgarian_split_squat   = aaaaaaaa-0004-0000-0000-000000000001
--   leg_press               = aaaaaaaa-0005-0000-0000-000000000001
--   pull_up                 = aaaaaaaa-0002-0000-0000-000000000001

INSERT INTO public.exercise_substitutes (exercise_id, substitute_id, similarity_score, reason) VALUES
  -- NOTE on within-family squat edges (high-bar ↔ low-bar ↔ front, all barbell):
  -- These are same-equipment, same-primary-pattern variations differing in bar
  -- position and muscle distribution. The existing `substitute_reason` enum
  -- doesn't cleanly fit:
  --   - `same_pattern_different_equipment` is wrong (equipment is identical).
  --   - `same_muscles_different_pattern` is the closest available — using it
  --     here, accepting that "different pattern" stretches to mean "different
  --     mechanical bias within the squat pattern."
  -- Followup: propose a `same_pattern_same_equipment_variation` reason to
  -- the conventions doc owner so within-family barbell variations get a
  -- proper tag instead of corrupting an existing one. Until then, the
  -- exercise_family_id link is what truly carries this relationship; the
  -- reason tag is just the closest-available label for the recommender.

  -- ── 6. Low-bar back squat ────────────────────────────────────────────────
  -- Closest substitute: high-bar back squat (same family, different muscle
  -- distribution; see header note on reason tag).
  ('aaaaaaaa-0006-0000-0000-000000000001', 'aaaaaaaa-0001-0000-0000-000000000001', 0.85, 'same_muscles_different_pattern'),
  -- Front squat: same family, different bar position, different muscle bias.
  ('aaaaaaaa-0006-0000-0000-000000000001', 'aaaaaaaa-0007-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
  -- Conventional deadlift: posterior-chain alternative when low-bar squat
  -- not available.
  ('aaaaaaaa-0006-0000-0000-000000000001', 'aaaaaaaa-0009-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),

  -- ── 7. Front squat ───────────────────────────────────────────────────────
  ('aaaaaaaa-0007-0000-0000-000000000001', 'aaaaaaaa-0001-0000-0000-000000000001', 0.80, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0007-0000-0000-000000000001', 'aaaaaaaa-0008-0000-0000-000000000001', 0.65, 'regression'),
  ('aaaaaaaa-0007-0000-0000-000000000001', 'aaaaaaaa-0006-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),

  -- ── 8. Goblet squat ──────────────────────────────────────────────────────
  -- Goblet is itself a regression; substitutes are progressions / nearby.
  ('aaaaaaaa-0008-0000-0000-000000000001', 'aaaaaaaa-0001-0000-0000-000000000001', 0.65, 'progression'),
  ('aaaaaaaa-0008-0000-0000-000000000001', 'aaaaaaaa-0007-0000-0000-000000000001', 0.65, 'progression'),
  ('aaaaaaaa-0008-0000-0000-000000000001', 'aaaaaaaa-0005-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),

  -- Reciprocal: high-bar back squat (batch 1) → goblet (regression)
  -- and high-bar back squat → low-bar / front squat substitutes added here
  -- so batch 1's back squat now connects to the new family rows.
  ('aaaaaaaa-0001-0000-0000-000000000001', 'aaaaaaaa-0006-0000-0000-000000000001', 0.85, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0001-0000-0000-000000000001', 'aaaaaaaa-0007-0000-0000-000000000001', 0.80, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0001-0000-0000-000000000001', 'aaaaaaaa-0008-0000-0000-000000000001', 0.65, 'regression'),

  -- ── 9. Conventional deadlift ─────────────────────────────────────────────
  ('aaaaaaaa-0009-0000-0000-000000000001', 'aaaaaaaa-0010-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0009-0000-0000-000000000001', 'aaaaaaaa-0011-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0009-0000-0000-000000000001', 'aaaaaaaa-0006-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),

  -- ── 10. RDL ──────────────────────────────────────────────────────────────
  ('aaaaaaaa-0010-0000-0000-000000000001', 'aaaaaaaa-0009-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0010-0000-0000-000000000001', 'aaaaaaaa-0011-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),

  -- ── 11. Hip thrust ───────────────────────────────────────────────────────
  ('aaaaaaaa-0011-0000-0000-000000000001', 'aaaaaaaa-0010-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0011-0000-0000-000000000001', 'aaaaaaaa-0009-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0011-0000-0000-000000000001', 'aaaaaaaa-0006-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),

  -- ── 12. Barbell bench press ──────────────────────────────────────────────
  ('aaaaaaaa-0012-0000-0000-000000000001', 'aaaaaaaa-0013-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  -- Cross-pattern: BB OHP shares triceps + front delts (different primary).
  ('aaaaaaaa-0012-0000-0000-000000000001', 'aaaaaaaa-0016-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),

  -- ── 13. Dumbbell bench press ─────────────────────────────────────────────
  ('aaaaaaaa-0013-0000-0000-000000000001', 'aaaaaaaa-0012-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0013-0000-0000-000000000001', 'aaaaaaaa-0017-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),

  -- ── 14. Barbell bent-over row ────────────────────────────────────────────
  -- Per prompt: BB row → chest-supported row is regression direction ONLY.
  ('aaaaaaaa-0014-0000-0000-000000000001', 'aaaaaaaa-0015-0000-0000-000000000001', 0.70, 'regression'),
  ('aaaaaaaa-0014-0000-0000-000000000001', 'aaaaaaaa-0002-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),

  -- ── 15. Chest-supported DB row ───────────────────────────────────────────
  -- No reverse edge to BB row (regression direction only).
  ('aaaaaaaa-0015-0000-0000-000000000001', 'aaaaaaaa-0002-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),

  -- ── 16. Standing barbell OHP ─────────────────────────────────────────────
  ('aaaaaaaa-0016-0000-0000-000000000001', 'aaaaaaaa-0017-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  -- Cross-pattern: BB bench shares triceps + front delts (different primary).
  ('aaaaaaaa-0016-0000-0000-000000000001', 'aaaaaaaa-0012-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),

  -- ── 17. Seated dumbbell OHP ──────────────────────────────────────────────
  ('aaaaaaaa-0017-0000-0000-000000000001', 'aaaaaaaa-0016-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0017-0000-0000-000000000001', 'aaaaaaaa-0013-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern');
