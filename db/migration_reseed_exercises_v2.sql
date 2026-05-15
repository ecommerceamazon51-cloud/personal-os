-- =============================================================================
-- Migration: Reseed exercises with muscle taxonomy v2 (PR B of 2)
-- =============================================================================
-- Purpose: Truncate the exercise tables and re-seed all 65 exercises with
--   per-head muscle distributions and head_emphasis_notes (PR B authoring).
--
-- IMPORTANT: Run in Supabase SQL Editor as a single block.
--   exercise_substitutes truncated first (FK constraint).
--   All 65 exercises and ~155 substitute edges re-inserted in one transaction.
-- =============================================================================

BEGIN;

-- Clear both tables in one statement to satisfy FK constraint
TRUNCATE TABLE public.exercise_substitutes, public.exercises;

-- =========================================================================
-- Source: v1 draft (exercises 1-5)
-- =========================================================================

-- ─── 1. Barbell Back Squat ──────────────────────────────────────────────────
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
  authored_by, verified
) VALUES (
  'aaaaaaaa-0001-0000-0000-000000000001',
  'Barbell Back Squat',
  ARRAY['back squat', 'high-bar squat', 'barbell squat', 'BB squat'],
  'lifting',
  'squat', NULL, 'bilateral',
  '[
    {"muscle_id": "quads_rectus_femoris",       "weight": 0.85},
    {"muscle_id": "quads_vastus_lateralis",     "weight": 1.0},
    {"muscle_id": "quads_vastus_medialis",      "weight": 1.0},
    {"muscle_id": "quads_vastus_intermedius",   "weight": 1.0},
    {"muscle_id": "glutes_max",                 "weight": 0.6},
    {"muscle_id": "glutes_medius",              "weight": 0.3},
    {"muscle_id": "adductors_magnus",           "weight": 0.6},
    {"muscle_id": "adductors_short",            "weight": 0.3},
    {"muscle_id": "spinal_erectors",            "weight": 0.4},
    {"muscle_id": "rectus_abdominis",           "weight": 0.25},
    {"muscle_id": "obliques",                   "weight": 0.25},
    {"muscle_id": "hamstrings_bf_long",         "weight": 0.25},
    {"muscle_id": "hamstrings_semitendinosus",  "weight": 0.25},
    {"muscle_id": "hamstrings_semimembranosus", "weight": 0.25},
    {"muscle_id": "calves_gastrocnemius",       "weight": 0.25}
  ]'::jsonb,
  '{
    "quads_rectus_femoris": "Trains less than the vasti because it''s a two-joint muscle — hip flexion at the bottom shortens it while knee extension at the top lengthens it, partially canceling out. The vasti get the full ROM benefit.",
    "spinal_erectors": "High-bar squat (this exercise) loads them less than low-bar or front squat because the torso stays more upright. They''re still bracing the load axially.",
    "hamstrings_bf_long": "Co-contracts to stabilize the knee during the descent. Not a primary trainer for hamstrings — use RDL or leg curl for that."
  }'::jsonb,
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
  muscles, head_emphasis_notes,
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
    {"muscle_id": "lats_upper",                  "weight": 0.8},
    {"muscle_id": "lats_lower",                  "weight": 1.0},
    {"muscle_id": "teres_major",                 "weight": 0.7},
    {"muscle_id": "biceps_long",                 "weight": 0.6},
    {"muscle_id": "biceps_short",                "weight": 0.5},
    {"muscle_id": "brachialis",                  "weight": 0.6},
    {"muscle_id": "forearms_brachioradialis",    "weight": 0.5},
    {"muscle_id": "forearms_grip",               "weight": 0.7},
    {"muscle_id": "forearms_wrist_flexors",      "weight": 0.25},
    {"muscle_id": "rhomboids",                   "weight": 0.5},
    {"muscle_id": "traps_middle",                "weight": 0.5},
    {"muscle_id": "traps_lower",                 "weight": 0.5},
    {"muscle_id": "delts_posterior",             "weight": 0.4},
    {"muscle_id": "rotator_cuff_infraspinatus",  "weight": 0.25},
    {"muscle_id": "rotator_cuff_teres_minor",    "weight": 0.25},
    {"muscle_id": "pectorals_sternal",           "weight": 0.25},
    {"muscle_id": "rectus_abdominis",            "weight": 0.25},
    {"muscle_id": "obliques",                    "weight": 0.25}
  ]'::jsonb,
  '{
    "lats_upper": "Wide grip emphasizes upper lats more; this default (shoulder-width pronated) splits the work toward lower lats. Use wide-grip pull-up variant to shift emphasis here.",
    "lats_lower": "Pronated pull-up at shoulder width drives the elbows down into the torso, which is the lower lat''s strongest line of pull. This is where most of the lat work goes on this variant.",
    "teres_major": "Often called the lat''s little helper — same shoulder adduction/extension action as the lats. Hard to undertrain on pulling; gets credit alongside lats on every pull-up rep.",
    "biceps_long": "Pronated grip (this variant) reduces biceps long head contribution vs supinated chin-up. Switch to chin-up if biceps emphasis is the goal.",
    "biceps_short": "Same caveat as long head — pronated grip de-emphasizes biceps overall.",
    "brachialis": "Pronated grip + neutral-ish forearm position emphasizes brachialis (and brachioradialis) more than biceps. This is part of why pronated pull-ups train the upper arm differently than chin-ups.",
    "forearms_grip": "Sustained hanging load makes this grip-intensive. Heavy grip work on every rep, especially the lowering phase.",
    "traps_lower": "Scapular depression at the top of the rep is where lower traps work hardest. Cue ''pull your shoulder blades into your back pockets'' to emphasize."
  }'::jsonb,
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
  muscles, head_emphasis_notes,
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
  'shoulder_abduction', NULL, 'bilateral',
  '[
    {"muscle_id": "delts_lateral",                "weight": 1.0},
    {"muscle_id": "delts_anterior",               "weight": 0.3},
    {"muscle_id": "delts_posterior",              "weight": 0.25},
    {"muscle_id": "rotator_cuff_supraspinatus",   "weight": 0.5},
    {"muscle_id": "traps_upper",                  "weight": 0.4},
    {"muscle_id": "forearms_grip",                "weight": 0.25}
  ]'::jsonb,
  '{
    "delts_lateral": "The whole point of the exercise. Lead with the elbow, raise to ~90° (parallel with the floor) — going higher shifts work to upper traps without adding lateral delt stimulus. Slight internal rotation (pinkies up) increases lateral delt activation.",
    "delts_anterior": "Forward drift of the arms (raising slightly in front of the body instead of pure lateral) shifts work here. Stay strict to the side to keep the focus on lateral.",
    "rotator_cuff_supraspinatus": "Initiates the first ~15° of abduction before the lateral delt takes over. Trained on every rep regardless of form. This is one of the few exercises that loads supraspinatus through ROM — worth knowing for shoulder health.",
    "traps_upper": "Engages more as the dumbbells rise above shoulder height. If you only want lateral delts, stop at parallel and the upper traps stay quieter."
  }'::jsonb,
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
  muscles, head_emphasis_notes,
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
  '[
    {"muscle_id": "quads_rectus_femoris",       "weight": 0.7},
    {"muscle_id": "quads_vastus_lateralis",     "weight": 1.0},
    {"muscle_id": "quads_vastus_medialis",      "weight": 1.0},
    {"muscle_id": "quads_vastus_intermedius",   "weight": 1.0},
    {"muscle_id": "glutes_max",                 "weight": 0.7},
    {"muscle_id": "glutes_medius",              "weight": 0.6},
    {"muscle_id": "glutes_minimus",             "weight": 0.4},
    {"muscle_id": "adductors_magnus",           "weight": 0.5},
    {"muscle_id": "adductors_short",            "weight": 0.4},
    {"muscle_id": "hamstrings_bf_long",         "weight": 0.3},
    {"muscle_id": "hamstrings_semitendinosus",  "weight": 0.3},
    {"muscle_id": "hamstrings_semimembranosus", "weight": 0.3},
    {"muscle_id": "spinal_erectors",            "weight": 0.3},
    {"muscle_id": "rectus_abdominis",           "weight": 0.3},
    {"muscle_id": "obliques",                   "weight": 0.4},
    {"muscle_id": "hip_flexors_iliopsoas",      "weight": 0.25},
    {"muscle_id": "hip_flexors_tfl",            "weight": 0.25},
    {"muscle_id": "calves_gastrocnemius",       "weight": 0.25},
    {"muscle_id": "calves_soleus",              "weight": 0.25},
    {"muscle_id": "forearms_grip",              "weight": 0.25}
  ]'::jsonb,
  '{
    "quads_rectus_femoris": "Lower than the vasti for the two-joint reason (same as squat), AND because the trail leg''s hip is extended — which stretches its rectus femoris but doesn''t load it through ROM.",
    "glutes_max": "Trains harder than on a back squat because the unilateral stance forces the working glute to handle full body weight + load. Lean slightly forward to shift more here.",
    "glutes_medius": "Big upgrade vs bilateral squat — works hard to prevent the pelvis from dropping toward the rear leg. Often the muscle that''s sore the day after a hard set.",
    "glutes_minimus": "Same story as medius — unilateral stance is what activates the small abductors. Worth tracking because most lifters undertrain these.",
    "obliques": "Anti-rotation work — the unilateral load wants to rotate the torso toward the working leg. Fires harder than on a bilateral squat.",
    "hip_flexors_iliopsoas": "Working leg''s iliopsoas fires briefly at the top to bring the knee back. Light overall — don''t program this for hip flexor development.",
    "hip_flexors_tfl": "Working leg''s TFL fires alongside glute medius for pelvic stability."
  }'::jsonb,
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
  muscles, head_emphasis_notes,
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
    {"muscle_id": "quads_rectus_femoris",       "weight": 0.7},
    {"muscle_id": "quads_vastus_lateralis",     "weight": 1.0},
    {"muscle_id": "quads_vastus_medialis",      "weight": 1.0},
    {"muscle_id": "quads_vastus_intermedius",   "weight": 1.0},
    {"muscle_id": "glutes_max",                 "weight": 0.5},
    {"muscle_id": "adductors_magnus",           "weight": 0.5},
    {"muscle_id": "adductors_short",            "weight": 0.3},
    {"muscle_id": "hamstrings_bf_long",         "weight": 0.25},
    {"muscle_id": "hamstrings_semitendinosus",  "weight": 0.25},
    {"muscle_id": "hamstrings_semimembranosus", "weight": 0.25},
    {"muscle_id": "calves_gastrocnemius",       "weight": 0.25}
  ]'::jsonb,
  '{
    "quads_rectus_femoris": "Same two-joint reason as squat — hip flexion at the bottom shortens it while knee extension at the top lengthens it. The seated/reclined position accentuates this slightly more than a standing squat.",
    "quads_vastus_lateralis": "Foot position changes head emphasis: feet low on the platform = more knee flexion = vasti emphasis (this default). Feet high on platform = more hip-dominant = glute/hamstring emphasis.",
    "glutes_max": "Lower than squat (0.5 vs 0.6) because no axial load and no balance demand means glutes only work through hip extension, not stabilization. Foot position high on platform shifts emphasis here.",
    "hamstrings_bf_long": "Light co-contraction for knee stability — same story as squat. Feet-high platform setup increases hamstring contribution; default position keeps it minimal."
  }'::jsonb,
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

-- =========================================================================
-- Source: batch 2 (exercises 6-17)
-- =========================================================================

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

-- =========================================================================
-- Source: batch 3 (exercises 18-29)
-- =========================================================================

-- ─── 18. Incline Barbell Bench Press ────────────────────────────────────────
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
  'aaaaaaaa-0018-0000-0000-000000000001',
  'Incline Barbell Bench Press',
  ARRAY['incline bench', 'incline BB bench', 'incline barbell press'],
  'lifting',
  'horizontal_push', NULL, 'bilateral',
  -- Incline (~30-45°) shifts emphasis to pectorals_clavicular (upper chest) and
  -- increases anterior delt contribution. pectorals_clavicular rises to 1.0
  -- (the defining target of incline pressing). pectorals_sternal drops to 0.7
  -- (still works but secondary to upper fibers). pectorals_abdominal drops to 0.3
  -- (minimal at incline). delts_anterior rises to 0.6 (more shoulder-flexion
  -- component than flat bench; can co-limit at steep inclines).
  -- triceps_long slightly higher than flat bench (shoulder more flexed = long head
  -- on slightly more stretch).
  '[
    {"muscle_id": "pectorals_clavicular",       "weight": 1.0},
    {"muscle_id": "pectorals_sternal",          "weight": 0.7},
    {"muscle_id": "pectorals_abdominal",        "weight": 0.3},
    {"muscle_id": "triceps_lateral",            "weight": 0.6},
    {"muscle_id": "triceps_long",               "weight": 0.6},
    {"muscle_id": "triceps_medial",             "weight": 0.5},
    {"muscle_id": "delts_anterior",             "weight": 0.6},
    {"muscle_id": "serratus_anterior",          "weight": 0.3},
    {"muscle_id": "rotator_cuff_subscapularis", "weight": 0.25},
    {"muscle_id": "forearms_grip",              "weight": 0.25}
  ]'::jsonb,
  '{
    "pectorals_clavicular": "Upper (clavicular) fibers are the target of incline pressing. The inclined angle shifts the line of force toward shoulder flexion, which is what the clavicular head is built for.",
    "pectorals_sternal": "Still active but secondary to the upper chest — the inclined angle shifts horizontal adduction emphasis away from the sternal fibers.",
    "delts_anterior": "More contribution than flat bench because the inclined angle adds a shoulder-flexion component to the press. At steep inclines (45°+) the delts can co-limit with the upper chest.",
    "triceps_long": "Shoulder is more flexed than flat bench, putting the long head in a slightly longer line of pull. More long head work here than on flat bench."
  }'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['shoulder_external_rotation', 'shoulder_flexion'],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"incline": "incline", "grip": "pronated"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 19. Incline Dumbbell Bench Press ───────────────────────────────────────
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
  'aaaaaaaa-0019-0000-0000-000000000001',
  'Incline Dumbbell Bench Press',
  ARRAY['incline DB bench', 'incline dumbbell press', 'DB incline press'],
  'lifting',
  'horizontal_push', NULL, 'bilateral',
  -- Same primary targets as incline BB bench. Greater stretch at the bottom
  -- (DBs can travel below shoulder height) noted in head_emphasis_notes.
  -- At per-head distribution resolution the targets are identical.
  '[
    {"muscle_id": "pectorals_clavicular",       "weight": 1.0},
    {"muscle_id": "pectorals_sternal",          "weight": 0.7},
    {"muscle_id": "pectorals_abdominal",        "weight": 0.3},
    {"muscle_id": "triceps_lateral",            "weight": 0.6},
    {"muscle_id": "triceps_long",               "weight": 0.6},
    {"muscle_id": "triceps_medial",             "weight": 0.5},
    {"muscle_id": "delts_anterior",             "weight": 0.6},
    {"muscle_id": "serratus_anterior",          "weight": 0.3},
    {"muscle_id": "rotator_cuff_subscapularis", "weight": 0.25},
    {"muscle_id": "forearms_grip",              "weight": 0.25}
  ]'::jsonb,
  '{
    "pectorals_clavicular": "Upper chest is the target — same as incline BB bench. The DB version allows a deeper stretch at the bottom, which may increase the stretch-mediated hypertrophy stimulus.",
    "delts_anterior": "More pronounced than flat bench. At steep inclines the delts can become co-limiting with the upper chest.",
    "triceps_long": "Inclined angle puts the shoulder in more flexion than flat bench, increasing long head contribution vs flat pressing."
  }'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['shoulder_external_rotation', 'shoulder_flexion'],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"incline": "incline", "grip": "pronated"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 20. Dip (Parallel-Bar, Triceps-Bias) ───────────────────────────────────
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
  'aaaaaaaa-0020-0000-0000-000000000001',
  'Dip',
  ARRAY['parallel bar dip', 'tricep dip', 'weighted dip'],
  'lifting',
  'horizontal_push', 'vertical_push', 'bilateral',
  -- Triceps-bias upright torso default. All three triceps heads are near-primary:
  -- triceps_lateral 1.0 (most active in elbow extension at neutral shoulder).
  -- triceps_long 0.9 (shoulder extension at the bottom + full elbow bend = good
  -- stretch for the long head even without overhead position).
  -- triceps_medial 0.8 (active throughout, especially in final lockout).
  -- Chest contributes to shoulder extension/adduction: pectorals_sternal 0.5,
  -- pectorals_clavicular 0.25 (less upper chest on upright dip).
  -- delts_anterior 0.4 — assists the push-up motion.
  '[
    {"muscle_id": "triceps_lateral",            "weight": 1.0},
    {"muscle_id": "triceps_long",               "weight": 0.9},
    {"muscle_id": "triceps_medial",             "weight": 0.8},
    {"muscle_id": "pectorals_sternal",          "weight": 0.5},
    {"muscle_id": "pectorals_clavicular",       "weight": 0.25},
    {"muscle_id": "delts_anterior",             "weight": 0.4},
    {"muscle_id": "serratus_anterior",          "weight": 0.3},
    {"muscle_id": "rotator_cuff_subscapularis", "weight": 0.25},
    {"muscle_id": "forearms_grip",              "weight": 0.25}
  ]'::jsonb,
  '{
    "triceps_long": "Long head is stretched at the bottom of the dip — elbow bent + shoulder in mild extension gives it a good ROM. This is why dips are among the best compound exercises for overall triceps mass despite not being overhead.",
    "pectorals_sternal": "Even on upright dip, pecs contribute to shoulder adduction through the press. Forward lean (chest-bias variant) would raise this to ~1.0 and drop triceps.",
    "delts_anterior": "Assists the push-up motion, particularly in the upper range where shoulder flexion becomes a contributor."
  }'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  ARRAY['strength', 'hypertrophy'],
  'secondary_compound', 'early',
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY['shoulder_external_rotation'],
  '[]'::jsonb,
  'dddddddd-dddd-dddd-dddd-dddddddddddd',
  NULL,
  'stretched',
  'system', FALSE
);

-- ─── 21. Chin-Up (Supinated) ────────────────────────────────────────────────
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
  'aaaaaaaa-0021-0000-0000-000000000001',
  'Chin-Up',
  ARRAY['chinup', 'chin up', 'supinated pull-up'],
  'lifting',
  'vertical_pull', NULL, 'bilateral',
  -- Supinated grip → biceps dominant (Pattern 4: supinated = biceps long head
  -- in strongest position). biceps_long and biceps_short both at 1.0 —
  -- on heavy sets many lifters feel bicep fatigue before lat fatigue.
  -- That meets conventions "muscle that limits the lift" criterion.
  -- This is what separates chin-up from pull-up at per-head resolution.
  -- brachialis 0.5 (less dominant than pronated pull-up; biceps take over).
  -- Lat region: supinated at shoulder-width → balanced, lats_lower slightly dominant.
  -- forearms_grip 0.5 (supinated grip is slightly less grip-intensive than pronated).
  '[
    {"muscle_id": "lats_lower",                 "weight": 1.0},
    {"muscle_id": "lats_upper",                 "weight": 0.8},
    {"muscle_id": "teres_major",                "weight": 0.7},
    {"muscle_id": "biceps_long",                "weight": 1.0},
    {"muscle_id": "biceps_short",               "weight": 0.9},
    {"muscle_id": "brachialis",                 "weight": 0.5},
    {"muscle_id": "forearms_brachioradialis",   "weight": 0.4},
    {"muscle_id": "forearms_grip",              "weight": 0.5},
    {"muscle_id": "rhomboids",                  "weight": 0.5},
    {"muscle_id": "traps_middle",               "weight": 0.5},
    {"muscle_id": "traps_lower",                "weight": 0.5},
    {"muscle_id": "delts_posterior",            "weight": 0.3},
    {"muscle_id": "rotator_cuff_infraspinatus", "weight": 0.25},
    {"muscle_id": "rectus_abdominis",           "weight": 0.25},
    {"muscle_id": "obliques",                   "weight": 0.25}
  ]'::jsonb,
  '{
    "biceps_long": "Supinated grip is the biceps long head''s strongest position. This is the defining difference between chin-up and pull-up — many lifters reach bicep failure before lat failure on heavy sets.",
    "biceps_short": "Both heads are highly active supinated. Together they often co-limit with the lats on near-max sets — two 1.0 targets is the correct call here.",
    "brachialis": "Less dominant than on pronated pull-up because the supinated biceps take over elbow flexion. Still contributes but is no longer the primary elbow flexor.",
    "lats_lower": "Supinated shoulder-width grip drives similar lower-lat emphasis to the pronated pull-up. Wide-grip pronated work shifts emphasis toward upper lats."
  }'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY['shoulder_flexion'],
  '[]'::jsonb,
  '22222222-2222-2222-2222-222222222222',
  '{"grip": "supinated"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 22. Lat Pulldown ───────────────────────────────────────────────────────
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
  'aaaaaaaa-0022-0000-0000-000000000001',
  'Lat Pulldown',
  ARRAY['pulldown', 'cable pulldown', 'wide-grip pulldown'],
  'lifting',
  'vertical_pull', NULL, 'bilateral',
  -- Wide pronated grip → upper-lat dominant (Pattern 3: wide = upper 1.0,
  -- lower 0.6-0.7). Pronated grip → brachialis dominant over biceps (Pattern 4).
  -- Machine/seated removes abs and core stabilizer entries (Pattern 5).
  -- No forearms_wrist_flexors — cable handles reduce the wrist-stability demand
  -- vs hanging from a bar.
  '[
    {"muscle_id": "lats_upper",                 "weight": 1.0},
    {"muscle_id": "lats_lower",                 "weight": 0.7},
    {"muscle_id": "teres_major",                "weight": 0.7},
    {"muscle_id": "brachialis",                 "weight": 0.7},
    {"muscle_id": "biceps_long",                "weight": 0.5},
    {"muscle_id": "biceps_short",               "weight": 0.5},
    {"muscle_id": "forearms_brachioradialis",   "weight": 0.4},
    {"muscle_id": "forearms_grip",              "weight": 0.5},
    {"muscle_id": "rhomboids",                  "weight": 0.5},
    {"muscle_id": "traps_middle",               "weight": 0.5},
    {"muscle_id": "traps_lower",                "weight": 0.4},
    {"muscle_id": "delts_posterior",            "weight": 0.3}
  ]'::jsonb,
  '{
    "lats_upper": "Wide-grip pulldown is upper-lat dominant — the wide hand placement creates a pulling angle that loads upper lat fibers preferentially. Switch to close-grip or neutral-grip attachment for lower lat emphasis.",
    "brachialis": "Pronated wide grip emphasizes brachialis over biceps. If biceps development is the goal, switch to a supinated or neutral close-grip pulldown.",
    "traps_lower": "Active during scapular depression at the bottom of the rep. Cue: pull shoulder blades down and into the back pockets to increase lower trap engagement."
  }'::jsonb,
  'cable', 'lat_pulldown', 10.00, 5.00,
  ARRAY['hypertrophy', 'strength'],
  'secondary_compound', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['shoulder_flexion'],
  '[]'::jsonb,
  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
  '{"grip": "pronated"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 23. Seated Cable Row ───────────────────────────────────────────────────
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
  'aaaaaaaa-0023-0000-0000-000000000001',
  'Seated Cable Row',
  ARRAY['cable row', 'seated row', 'low cable row'],
  'lifting',
  'horizontal_pull', NULL, 'bilateral',
  -- Neutral V-bar grip (default) + machine/seated support.
  -- Neutral grip → brachialis dominant (Pattern 4: neutral = brachialis 0.8).
  -- Rows = balanced lats (Pattern 3): lats_lower 1.0, lats_upper 0.8.
  -- Machine support removes spinal_erectors (Pattern 5).
  -- Cable handles are wrist-friendly; forearms_grip at 0.4 (below BB row's 0.6).
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
    "brachialis": "Neutral V-bar grip shifts elbow flexion to brachialis — same principle as hammer curl. You get upper-back + brachialis development in one movement.",
    "lats_lower": "Elbows close to the body on a neutral row favor lower lat emphasis. For more upper lats, use a wider pronated grip."
  }'::jsonb,
  'cable', 'cable_row_machine', 10.00, 5.00,
  ARRAY['hypertrophy', 'strength'],
  'secondary_compound', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'ffffffff-ffff-ffff-ffff-ffffffffffff',
  '{"grip": "neutral"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 24. Lying Leg Curl ─────────────────────────────────────────────────────
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
  'aaaaaaaa-0024-0000-0000-000000000001',
  'Lying Leg Curl',
  ARRAY['leg curl', 'prone leg curl', 'hamstring curl'],
  'lifting',
  'hinge', NULL, 'bilateral',
  -- Machine knee flexion isolation. All hamstring heads cross the knee.
  -- Lying (prone) position = hip extended → bi-articular heads (bf_long, semis)
  -- are also stretched at the hip, giving them better force-generating length.
  -- bf_short only crosses the knee; still contributes fully to knee flexion
  -- but without the hip-extension pre-stretch advantage → 0.9.
  -- calves_gastrocnemius: crosses the knee and contributes to knee flexion,
  -- especially in the early ROM. Two-joint shortening reduces its contribution
  -- as the knee approaches full flexion.
  '[
    {"muscle_id": "hamstrings_bf_long",         "weight": 1.0},
    {"muscle_id": "hamstrings_semitendinosus",  "weight": 1.0},
    {"muscle_id": "hamstrings_semimembranosus", "weight": 1.0},
    {"muscle_id": "hamstrings_bf_short",        "weight": 0.9},
    {"muscle_id": "calves_gastrocnemius",       "weight": 0.4}
  ]'::jsonb,
  '{
    "hamstrings_bf_long": "Prone position extends the hip, stretching the bi-articular heads (BF long, semis) across the hip. This optimal length-tension position is why lying leg curl is a better hamstring isolator than seated or standing versions for the hip-crossing heads.",
    "calves_gastrocnemius": "Gastroc crosses the knee and assists knee flexion, especially through the early ROM. As the knee approaches full flexion, gastroc shortens and loses mechanical advantage — its contribution diminishes near the peak contracted position."
  }'::jsonb,
  'machine', 'leg_curl', 10.00, 5.00,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '11111111-2222-3333-4444-555555555555',
  NULL,
  'shortened',
  'system', FALSE
);

-- ─── 25. Leg Extension ──────────────────────────────────────────────────────
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
  'aaaaaaaa-0025-0000-0000-000000000001',
  'Leg Extension',
  ARRAY['leg ext', 'knee extension', 'machine leg extension'],
  'lifting',
  'squat', NULL, 'bilateral',
  -- Machine knee extension isolation. All four quad heads extend the knee.
  -- quads_rectus_femoris: seated position (hip at ~90°) puts RF in active
  -- insufficiency — shortened at the hip end while contracting at the knee.
  -- Vasti are pure knee extensors, so they generate full force without the
  -- cross-joint penalty → vasti are at 1.0, RF at 0.6.
  -- This is the opposite of the common "leg extension isolates upper quad"
  -- framing — at the biomechanical level, vasti are more productive here.
  '[
    {"muscle_id": "quads_vastus_lateralis",     "weight": 1.0},
    {"muscle_id": "quads_vastus_medialis",      "weight": 1.0},
    {"muscle_id": "quads_vastus_intermedius",   "weight": 1.0},
    {"muscle_id": "quads_rectus_femoris",       "weight": 0.6}
  ]'::jsonb,
  '{
    "quads_rectus_femoris": "Seated position (hip ~90° flexed) puts RF in active insufficiency — it is already shortened at the hip while trying to shorten at the knee. Vasti generate more force here because they only cross the knee.",
    "quads_vastus_medialis": "VMO (lower portion) is especially active in the final 15-30° of knee extension — the lockout phase. Full ROM to lockout recruits VMO specifically."
  }'::jsonb,
  'machine', 'leg_extension', 10.00, 5.00,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '22222222-3333-4444-5555-666666666666',
  NULL,
  'shortened',
  'system', FALSE
);

-- ─── 26. Standing Calf Raise ────────────────────────────────────────────────
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
  'aaaaaaaa-0026-0000-0000-000000000001',
  'Standing Calf Raise',
  ARRAY['calf raise', 'standing calf', 'machine calf raise'],
  'lifting',
  'plyometric', NULL, 'bilateral',
  -- Knee straight = gastrocnemius fully engaged (crosses both knee and ankle;
  -- knee-straight position allows full stretch from ankle to hip attachment).
  -- Soleus also contributes to plantarflexion but is partly overshadowed by
  -- gastroc when the knee is extended. For soleus isolation, use seated calf
  -- raise (knee bent shortens gastroc).
  '[
    {"muscle_id": "calves_gastrocnemius",       "weight": 1.0},
    {"muscle_id": "calves_soleus",              "weight": 0.6}
  ]'::jsonb,
  '{
    "calves_gastrocnemius": "Knee straight (standing) puts gastroc in a lengthened position, allowing full contribution through the full ankle ROM. This is why standing calf raise loads gastroc significantly more than seated.",
    "calves_soleus": "Active in all plantarflexion regardless of knee angle, but partially overshadowed by gastroc when the knee is straight. For soleus focus, use seated calf raise."
  }'::jsonb,
  'machine', 'standing_calf_raise', 10.00, 5.00,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '33333333-4444-5555-6666-777777777777',
  NULL,
  'stretched',
  'system', FALSE
);

-- ─── 27. Barbell Curl ───────────────────────────────────────────────────────
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
  'aaaaaaaa-0027-0000-0000-000000000001',
  'Barbell Curl',
  ARRAY['BB curl', 'barbell bicep curl', 'standing barbell curl'],
  'lifting',
  'vertical_pull', NULL, 'bilateral',
  -- Supinated grip (fixed on BB curl) = biceps dominant (Pattern 4:
  -- supinated = biceps long head in strongest position).
  -- brachialis 0.5 — still active but biceps are dominant supinated.
  -- forearms_brachioradialis 0.4, forearms_grip 0.4 — mild contribution.
  '[
    {"muscle_id": "biceps_long",                "weight": 1.0},
    {"muscle_id": "biceps_short",               "weight": 0.9},
    {"muscle_id": "brachialis",                 "weight": 0.5},
    {"muscle_id": "forearms_brachioradialis",   "weight": 0.4},
    {"muscle_id": "forearms_grip",              "weight": 0.4},
    {"muscle_id": "forearms_wrist_flexors",     "weight": 0.25}
  ]'::jsonb,
  '{
    "biceps_long": "Supinated grip is the long head''s strongest position. In the top third of the curl the long head also assists shoulder flexion, adding a small bonus ROM.",
    "brachialis": "Less dominant than on hammer or pronated curls, but it is a pure elbow flexor so it contributes throughout. Brachialis training adds thickness under the biceps and increases overall arm size.",
    "forearms_brachioradialis": "Active in elbow flexion regardless of grip. Hammer curl (neutral grip) shifts much more work here for lifters focused on forearm development."
  }'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '44444444-5555-6666-7777-888888888888',
  '{"grip": "supinated"}'::jsonb,
  'mid',
  'system', FALSE
);

-- ─── 28. Triceps Pushdown (Cable) ───────────────────────────────────────────
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
  'aaaaaaaa-0028-0000-0000-000000000001',
  'Triceps Pushdown',
  ARRAY['tricep pushdown', 'cable pushdown', 'rope pushdown'],
  'lifting',
  'vertical_push', NULL, 'bilateral',
  -- Shoulder neutral (elbows at sides) = triceps_lateral is most active.
  -- triceps_long is less active because the shoulder is NOT elevated —
  -- the long head needs overhead position to be fully on stretch.
  -- This is the key distinction between pushdown and overhead extension.
  -- triceps_medial 0.9 — highly active throughout, especially at lockout.
  '[
    {"muscle_id": "triceps_lateral",            "weight": 1.0},
    {"muscle_id": "triceps_medial",             "weight": 0.9},
    {"muscle_id": "triceps_long",               "weight": 0.4},
    {"muscle_id": "forearms_grip",              "weight": 0.25}
  ]'::jsonb,
  '{
    "triceps_lateral": "Primary head for pushdown — elbow extension with the shoulder at neutral is the lateral head''s strongest position. The clean lockout sensation at the bottom of pushdowns is largely lateral head contraction.",
    "triceps_long": "The shoulder is not elevated, so the long head does not get the stretched-position stimulus it gets on skull crushers or overhead extensions. Pushdown builds the outer heads; add overhead tricep work for full long head development.",
    "triceps_medial": "The deep medial head is highly active throughout, especially contributing to the final lockout phase."
  }'::jsonb,
  'cable', 'cable_pushdown', 5.00, 2.50,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '55555555-6666-7777-8888-999999999999',
  '{"grip": "pronated"}'::jsonb,
  'shortened',
  'system', FALSE
);

-- ─── 29. Dumbbell Hammer Curl ───────────────────────────────────────────────
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
  'aaaaaaaa-0029-0000-0000-000000000001',
  'Dumbbell Hammer Curl',
  ARRAY['hammer curl', 'DB hammer curl', 'neutral grip curl'],
  'lifting',
  'vertical_pull', NULL, 'bilateral',
  -- Neutral grip (the defining feature) = brachialis dominant (Pattern 4:
  -- neutral = brachialis 0.8-1.0, biceps 0.6). Brachialis is a pure elbow
  -- flexor with no supination role, so neutral grip is its best position.
  -- forearms_brachioradialis 0.7 — heavily recruited in neutral grip curls;
  -- many lifters feel hammer curls more in their forearms than their biceps.
  '[
    {"muscle_id": "brachialis",                 "weight": 1.0},
    {"muscle_id": "biceps_long",                "weight": 0.6},
    {"muscle_id": "biceps_short",               "weight": 0.6},
    {"muscle_id": "forearms_brachioradialis",   "weight": 0.7},
    {"muscle_id": "forearms_grip",              "weight": 0.4},
    {"muscle_id": "forearms_wrist_flexors",     "weight": 0.25}
  ]'::jsonb,
  '{
    "brachialis": "Neutral grip shifts elbow flexion to brachialis — it is a pure elbow flexor with no supination role, so this is its optimal position. Training brachialis adds thickness under the biceps and increases total arm girth.",
    "biceps_long": "Less active than on supinated barbell curl because the neutral grip does not put biceps in its strongest position.",
    "forearms_brachioradialis": "Heavily recruited in neutral grip curls — often the muscle lifters feel most on this exercise. Hammer curl is one of the few exercises that trains brachioradialis directly through ROM."
  }'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '66666666-7777-8888-9999-aaaaaaaaaaaa',
  '{"grip": "neutral"}'::jsonb,
  'mid',
  'system', FALSE
);


-- =============================================================================
-- Substitution graph (batch 3 + cross-batch)
-- =============================================================================
-- Directional. Targeting 2-4 substitutes per exercise per conventions §10.
-- Cross-batch refs:
--   pull_up           = aaaaaaaa-0002-0000-0000-000000000001  (batch 1)
--   bb_bench          = aaaaaaaa-0012-0000-0000-000000000001  (batch 2)
--   db_bench          = aaaaaaaa-0013-0000-0000-000000000001  (batch 2)
--   bb_row            = aaaaaaaa-0014-0000-0000-000000000001  (batch 2)
--   chest_supported_row = aaaaaaaa-0015-0000-0000-000000000001 (batch 2)
--   bb_ohp            = aaaaaaaa-0016-0000-0000-000000000001  (batch 2)
--   db_ohp            = aaaaaaaa-0017-0000-0000-000000000001  (batch 2)
--   lateral_raise     = aaaaaaaa-0003-0000-0000-000000000001  (batch 1)
--   rdl               = aaaaaaaa-0010-0000-0000-000000000001  (batch 2)
--   leg_press         = aaaaaaaa-0005-0000-0000-000000000001  (batch 1)
--   back_squat        = aaaaaaaa-0001-0000-0000-000000000001  (batch 1)

INSERT INTO public.exercise_substitutes (exercise_id, substitute_id, similarity_score, reason) VALUES
  -- ── 18. Incline BB bench ─────────────────────────────────────────────────
  ('aaaaaaaa-0018-0000-0000-000000000001', 'aaaaaaaa-0019-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0018-0000-0000-000000000001', 'aaaaaaaa-0012-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0018-0000-0000-000000000001', 'aaaaaaaa-0016-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),

  -- ── 19. Incline DB bench ─────────────────────────────────────────────────
  ('aaaaaaaa-0019-0000-0000-000000000001', 'aaaaaaaa-0018-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0019-0000-0000-000000000001', 'aaaaaaaa-0013-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0019-0000-0000-000000000001', 'aaaaaaaa-0017-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),

  -- Reciprocal: flat BB bench (batch 2) → incline BB (and DB).
  ('aaaaaaaa-0012-0000-0000-000000000001', 'aaaaaaaa-0018-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0013-0000-0000-000000000001', 'aaaaaaaa-0019-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),

  -- ── 20. Dip ──────────────────────────────────────────────────────────────
  ('aaaaaaaa-0020-0000-0000-000000000001', 'aaaaaaaa-0028-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0020-0000-0000-000000000001', 'aaaaaaaa-0016-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0020-0000-0000-000000000001', 'aaaaaaaa-0012-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),

  -- ── 21. Chin-up ──────────────────────────────────────────────────────────
  ('aaaaaaaa-0021-0000-0000-000000000001', 'aaaaaaaa-0002-0000-0000-000000000001', 0.85, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0021-0000-0000-000000000001', 'aaaaaaaa-0022-0000-0000-000000000001', 0.65, 'same_pattern_different_equipment'),

  -- Reciprocal: pull-up (batch 1) → chin-up
  ('aaaaaaaa-0002-0000-0000-000000000001', 'aaaaaaaa-0021-0000-0000-000000000001', 0.85, 'same_muscles_different_pattern'),

  -- Reciprocal: BB OHP (batch 2) → dip
  ('aaaaaaaa-0016-0000-0000-000000000001', 'aaaaaaaa-0020-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),

  -- ── 22. Lat pulldown ─────────────────────────────────────────────────────
  ('aaaaaaaa-0022-0000-0000-000000000001', 'aaaaaaaa-0002-0000-0000-000000000001', 0.75, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0022-0000-0000-000000000001', 'aaaaaaaa-0021-0000-0000-000000000001', 0.65, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0022-0000-0000-000000000001', 'aaaaaaaa-0023-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),

  -- Reciprocal: pull-up (batch 1) → lat pulldown
  ('aaaaaaaa-0002-0000-0000-000000000001', 'aaaaaaaa-0022-0000-0000-000000000001', 0.75, 'same_pattern_different_equipment'),

  -- ── 23. Seated cable row ─────────────────────────────────────────────────
  ('aaaaaaaa-0023-0000-0000-000000000001', 'aaaaaaaa-0015-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0023-0000-0000-000000000001', 'aaaaaaaa-0014-0000-0000-000000000001', 0.65, 'progression'),
  ('aaaaaaaa-0023-0000-0000-000000000001', 'aaaaaaaa-0022-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),

  -- Reciprocal: BB row (batch 2) → cable row
  ('aaaaaaaa-0014-0000-0000-000000000001', 'aaaaaaaa-0023-0000-0000-000000000001', 0.65, 'regression'),
  -- Reciprocal: chest-supported row (batch 2) → cable row
  ('aaaaaaaa-0015-0000-0000-000000000001', 'aaaaaaaa-0023-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),

  -- ── 24. Lying leg curl ───────────────────────────────────────────────────
  ('aaaaaaaa-0024-0000-0000-000000000001', 'aaaaaaaa-0010-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),

  -- ── 25. Leg extension ────────────────────────────────────────────────────
  ('aaaaaaaa-0025-0000-0000-000000000001', 'aaaaaaaa-0005-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0025-0000-0000-000000000001', 'aaaaaaaa-0001-0000-0000-000000000001', 0.40, 'same_muscles_different_pattern'),

  -- ── 26. Standing calf raise ──────────────────────────────────────────────
  ('aaaaaaaa-0026-0000-0000-000000000001', 'aaaaaaaa-0005-0000-0000-000000000001', 0.30, 'same_muscles_different_pattern'),

  -- ── 27. Barbell curl ─────────────────────────────────────────────────────
  ('aaaaaaaa-0027-0000-0000-000000000001', 'aaaaaaaa-0029-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0027-0000-0000-000000000001', 'aaaaaaaa-0021-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),

  -- ── 28. Triceps pushdown ─────────────────────────────────────────────────
  ('aaaaaaaa-0028-0000-0000-000000000001', 'aaaaaaaa-0020-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0028-0000-0000-000000000001', 'aaaaaaaa-0016-0000-0000-000000000001', 0.40, 'same_muscles_different_pattern'),

  -- ── 29. Hammer curl ──────────────────────────────────────────────────────
  ('aaaaaaaa-0029-0000-0000-000000000001', 'aaaaaaaa-0027-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0029-0000-0000-000000000001', 'aaaaaaaa-0021-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern');

-- =========================================================================
-- Source: batch 4 (exercises 30-44)
-- =========================================================================

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

-- =========================================================================
-- Source: batch 5 (exercises 45-65)
-- =========================================================================

-- ─── 45. Glute Bridge ───────────────────────────────────────────────────────
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
  'aaaaaaaa-0045-0000-0000-000000000001',
  'Glute Bridge',
  ARRAY['floor bridge', 'bodyweight bridge', 'barbell glute bridge'],
  'lifting',
  'hinge', NULL, 'bilateral',
  -- Pattern: hinge. Same family as hip thrust per scope decision; the
  -- difference vs the existing barbell HT is feet-on-floor (lower ROM,
  -- shoulders on floor) instead of shoulders-on-bench. Mechanically a
  -- shorter-ROM hip thrust with the same primary muscle action.
  --
  -- glutes_max 1.0 — same as hip thrust; the lift IS peak hip extension contraction.
  -- glutes_medius 0.25 — bilateral cap applies; stabilizes knee position
  --   when knees are pushed outward. Less than unilateral variants.
  -- hamstrings_bf_long 0.5, semitendinosus 0.4, semimembranosus 0.4 —
  --   synergists in hip extension. Shorter ROM than hip thrust reduces
  --   hamstring stretch contribution.
  -- adductors_magnus 0.25 — stabilize knee position; user notices on heavy sets.
  '[
    {"muscle_id": "glutes_max",                 "weight": 1.0},
    {"muscle_id": "glutes_medius",              "weight": 0.25},
    {"muscle_id": "hamstrings_bf_long",         "weight": 0.5},
    {"muscle_id": "hamstrings_semitendinosus",  "weight": 0.4},
    {"muscle_id": "hamstrings_semimembranosus", "weight": 0.4},
    {"muscle_id": "adductors_magnus",           "weight": 0.25}
  ]'::jsonb,
  '{"glutes_medius": "Push your knees outward at the top — collapsing knees unloads glute medius and shifts stress to the lumbar spine."}'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  -- Loaded variant uses a barbell across hips (defaulting to bodyweight
  -- per §9 weighted_bodyweight metric — most users start without load).
  -- Increments match the convention for loaded bodyweight (2.50/1.25).
  ARRAY['hypertrophy', 'stability'],
  'accessory', 'anywhere',
  -- Default role 'accessory' — glute bridge sits between full hip thrust
  -- (compound) and pure isolation. It's a regression from HT and serves as
  -- a warmup/activation movement for many users; not load-driven enough to
  -- call secondary_compound, not single-joint enough to call isolation.
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY[]::TEXT[],
  -- No demands. Bridge requires minimal mobility (less hip flexion than
  -- HT because shoulders are on floor). Grip not loaded.
  '[]'::jsonb,
  '88888888-8888-8888-8888-888888888888',
  -- SHARES family with barbell hip thrust (aaaaaaaa-0011) — per scope
  -- decision: glute bridge + SL hip thrust + barbell hip thrust are all
  -- variants of the same lift, in regression → main → unilateral order.
  '{"range": "partial"}'::jsonb,
  -- Variation attribute marks the shorter ROM vs the canonical hip thrust.
  'shortened',
  -- Hip thrust family is canonically shortened-bias (peak contraction at
  -- top, no stretch at bottom). Bridge inherits that.
  'system', FALSE
);


-- ─── 46. Single-Leg Hip Thrust ──────────────────────────────────────────────
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
  'aaaaaaaa-0046-0000-0000-000000000001',
  'Single-Leg Hip Thrust',
  ARRAY['SL hip thrust', 'one-leg hip thrust', 'unilateral hip thrust'],
  'lifting',
  'hinge', NULL, 'unilateral',
  -- Unilateral progression of barbell HT. Same hip thrust family.
  --
  -- glutes_max 1.0 — single leg means double the relative load on the working
  --   glute; overcomes the bilateral hip thrust activation plateau.
  -- glutes_medius 0.5 — unilateral bypasses the bilateral cap (Pattern 2);
  --   glute medius is the only thing keeping the pelvis level on the working side.
  -- hamstrings_bf_long 0.5, semitendinosus 0.4, semimembranosus 0.4 —
  --   same role as bilateral HT, scaled to one leg.
  -- adductors_magnus 0.25 — pelvic stability becomes more important without
  --   the second leg's contribution.
  -- rectus_abdominis 0.25 — anti-rotation demand introduced by unilateral
  --   loading; not present in bilateral.
  '[
    {"muscle_id": "glutes_max",                 "weight": 1.0},
    {"muscle_id": "glutes_medius",              "weight": 0.5},
    {"muscle_id": "hamstrings_bf_long",         "weight": 0.5},
    {"muscle_id": "hamstrings_semitendinosus",  "weight": 0.4},
    {"muscle_id": "hamstrings_semimembranosus", "weight": 0.4},
    {"muscle_id": "adductors_magnus",           "weight": 0.25},
    {"muscle_id": "rectus_abdominis",           "weight": 0.25}
  ]'::jsonb,
  '{"glutes_medius": "Drive through your heel and actively resist your hip dropping — glute medius is the only thing keeping your pelvis level on the working side."}'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  -- Loading is typically a dumbbell on the working hip or a barbell across
  -- (less common). Default bodyweight; the unilateral nature means most
  -- users find bodyweight challenging for working sets without added load.
  ARRAY['hypertrophy', 'stability'],
  'secondary_compound', 'anywhere',
  -- 'secondary_compound' rather than accessory: single-leg work is more
  -- demanding than bilateral bridge and earns a programming role similar
  -- to BSS (which is also secondary_compound).
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY['unilateral_balance'],
  -- §3 demand. Single-leg hip thrust requires meaningful pelvic control
  -- to keep hips level; this is the defining characteristic of the variant.
  '[]'::jsonb,
  '88888888-8888-8888-8888-888888888888',
  -- SHARES family with barbell hip thrust + glute bridge.
  '{"stance": "split"}'::jsonb,
  -- Closest variation_attribute fit; "stance: split" is used for unilateral
  -- positioning per §4 (also used by Bulgarian split squat). Could argue
  -- a new "unilateral: true" attribute but that's redundant with the
  -- loading_type column.
  'shortened',
  'system', FALSE
);


-- ─── 47. Seated Leg Curl ────────────────────────────────────────────────────
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
  'aaaaaaaa-0047-0000-0000-000000000001',
  'Seated Leg Curl',
  ARRAY['seated hamstring curl', 'machine leg curl seated'],
  'lifting',
  'knee_flexion', NULL, 'bilateral',
  -- knee_flexion enum value (added in PR #4 migration). Same primary pattern
  -- as lying leg curl but different muscle-length stimulus per §1 — hip
  -- flexion (seated position) puts hamstrings in stretched position,
  -- which research shows produces more hamstring growth than the lying
  -- (hip-extended) variant. NOT a redundant variation; meaningfully
  -- distinct stimulus = separate row.
  --
  -- hamstrings_bf_long 1.0 — hip-flexed position maximally stretches the
  --   long biarticular head; this is the primary driver of the stimulus advantage.
  -- hamstrings_semitendinosus 1.0, hamstrings_semimembranosus 1.0 — also
  --   biarticular; all three stretch fully at the hip-flexed starting position.
  -- hamstrings_bf_short 0.7 — monoarticular (knee only), no hip-flexion
  --   stretch advantage; still loaded but contributes less to the stimulus edge.
  -- calves_gastrocnemius 0.25 — contributes to knee flexion (crosses both
  --   joints); calf cramping risk on heavy seated curls.
  '[
    {"muscle_id": "hamstrings_bf_long",         "weight": 1.0},
    {"muscle_id": "hamstrings_semitendinosus",  "weight": 1.0},
    {"muscle_id": "hamstrings_semimembranosus", "weight": 1.0},
    {"muscle_id": "hamstrings_bf_short",        "weight": 0.7},
    {"muscle_id": "calves_gastrocnemius",       "weight": 0.25}
  ]'::jsonb,
  '{"hamstrings_bf_long": "Lean slightly forward in the seat to increase hip flexion — more hip flexion stretches the hamstring origins further, which is why seated outperforms lying for growth."}'::jsonb,
  'machine', 'leg_curl_seated', 10.00, 5.00,
  -- equipment_specific differentiates from lying leg curl machine; some
  -- gyms have one but not the other.
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'aaaaa011-1111-1111-1111-111111111111',
  -- New family — separate from lying leg curl per scope reasoning. The
  -- hip-flexion vs hip-extension distinction makes these meaningfully
  -- different lifts even though both are knee_flexion isolation.
  NULL,
  'stretched',
  -- Per §8: hip-flexed position puts hamstrings in stretched position at
  -- the top of the curl. This is the entire reason the seated variant
  -- exists. Contrast with lying leg curl which is shortened-bias.
  'system', FALSE
);


-- ─── 48. Good Morning ───────────────────────────────────────────────────────
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
  'aaaaaaaa-0048-0000-0000-000000000001',
  'Good Morning',
  ARRAY['barbell good morning', 'GM', 'BB good morning'],
  'lifting',
  'hinge', NULL, 'bilateral',
  -- Loaded hinge variant. Bar across upper back (back-squat position)
  -- with hip-hinge motion; emphasizes hamstrings + lower back without the
  -- grip-limit and bilateral-floor-pull demands of conventional/RDL.
  --
  -- hamstrings_bf_long 1.0 — primary target via hip flexion under load.
  -- hamstrings_semitendinosus 0.85, hamstrings_semimembranosus 0.85 —
  --   slightly lower than bf_long because the bar-on-back position and
  --   knee-soft stance emphasizes the long biarticular head marginally more.
  -- spinal_erectors 1.0 — co-target. Bar at highest possible position on
  --   the body maximizes the erector moment arm. Limiting factor for most
  --   lifters; two 1.0s intentional (same rationale as conv DL).
  -- glutes_max 0.5 — synergist at hip extension; not 1.0 because if
  --   glutes were the target you'd program a hip thrust instead.
  -- adductors_magnus 0.25 — stabilize stance under spinal load.
  '[
    {"muscle_id": "hamstrings_bf_long",         "weight": 1.0},
    {"muscle_id": "hamstrings_semitendinosus",  "weight": 0.85},
    {"muscle_id": "hamstrings_semimembranosus", "weight": 0.85},
    {"muscle_id": "spinal_erectors",            "weight": 1.0},
    {"muscle_id": "glutes_max",                 "weight": 0.5},
    {"muscle_id": "adductors_magnus",           "weight": 0.25}
  ]'::jsonb,
  '{
    "spinal_erectors": "Keep your lower back arched — the bar position maximizes the erector moment arm. Any rounding transfers load to passive structures.",
    "hamstrings_bf_long": "The stretch should pull from your sit bones as you hinge forward — if you only feel your lower back, you are not hinging at the hips enough."
  }'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'secondary_compound', 'early',
  -- 'early' session_position because GMs are CNS-demanding and risk-managed
  -- carefully (lower back fatigue compromises form). Don't program GMs
  -- after deadlifts.
  'weight_x_reps', TRUE, FALSE,
  ARRAY['axial_loading', 'lumbar_loading', 'hip_flexion'],
  -- §3 demands. axial_loading because bar is on back. lumbar_loading
  -- specifically called out — this is the lift that most challenges the
  -- lumbar erectors per the §3 example. hip_flexion mobility needed at
  -- the bottom position.
  '[]'::jsonb,
  'aaaaaaff-ffff-ffff-ffff-ffffffffffff',
  -- New family — NOT an RDL variant. Bar position fundamentally changes
  -- the lift (axial load, different moment arms, different limiter).
  -- Same logic that makes back squat ≠ front squat ≠ goblet squat
  -- separate families also makes GM ≠ RDL.
  NULL,
  'stretched',
  -- Hamstrings stretched at the bottom; this is the canonical
  -- hamstring stretched-bias position alongside RDL.
  'system', FALSE
);


-- ─── 49. Single-Arm Dumbbell Row ────────────────────────────────────────────
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
  'aaaaaaaa-0049-0000-0000-000000000001',
  'Single-Arm Dumbbell Row',
  ARRAY['one-arm DB row', 'SA DB row', 'one-arm row', 'kroc row'],
  'lifting',
  'horizontal_pull', NULL, 'unilateral',
  -- Unilateral horizontal pull; hand on bench, opposite knee on bench.
  -- Distinguished from BB row (bilateral, more spinal load) and
  -- chest-supported DB row (bilateral, no anti-rotation demand).
  --
  -- lats_lower 1.0 — elbow-toward-hip path pulls the lower lat through
  --   full ROM; the primary target on the SA row.
  -- lats_upper 0.6 — also loaded throughout; less dominant than lower.
  -- rhomboids 0.5 — synergist in scapular retraction at the top.
  -- traps_middle 0.4, traps_lower 0.3 — scapular retraction synergists.
  -- brachialis 0.8 — neutral grip (palm facing in) routes elbow flexion
  --   to brachialis over biceps (Pattern 4).
  -- biceps_long 0.3, biceps_short 0.3 — assist elbow flexion; reduced
  --   weight vs supinated-grip rows because neutral grip deprioritizes them.
  -- delts_posterior 0.25 — assist scapular retraction; less than wider-
  --   elbow variants.
  -- rectus_abdominis 0.25 — anti-rotation demand from unilateral loading;
  --   distinguishes SA row from chest-supported DB row.
  '[
    {"muscle_id": "lats_lower",       "weight": 1.0},
    {"muscle_id": "lats_upper",       "weight": 0.6},
    {"muscle_id": "rhomboids",        "weight": 0.5},
    {"muscle_id": "traps_middle",     "weight": 0.4},
    {"muscle_id": "traps_lower",      "weight": 0.3},
    {"muscle_id": "brachialis",       "weight": 0.8},
    {"muscle_id": "biceps_long",      "weight": 0.3},
    {"muscle_id": "biceps_short",     "weight": 0.3},
    {"muscle_id": "delts_posterior",  "weight": 0.25},
    {"muscle_id": "rectus_abdominis", "weight": 0.25}
  ]'::jsonb,
  '{
    "lats_lower": "Drive your elbow toward your hip, not your shoulder — this pulls the lower lat through full ROM.",
    "brachialis": "Neutral grip loads brachialis over biceps — keep your palm facing in throughout the pull."
  }'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['hypertrophy', 'strength'],
  'secondary_compound', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['unilateral_balance', 'grip_intensive'],
  -- grip_intensive: SA row often the heaviest DB pull a user does;
  -- grip is a real factor especially on high-rep "kroc row" style sets.
  '[]'::jsonb,
  'aaaaa022-2222-2222-2222-222222222222',
  -- New family — separate from BB row (bilateral) and chest-supported
  -- DB row (bilateral, supported torso). The unilateral + free-torso
  -- combination is mechanically distinct.
  '{"stance": "split"}'::jsonb,
  -- Hand-on-bench, knee-on-bench position is most analogous to a split
  -- stance among the established §4 stance values. Not a perfect fit;
  -- could argue NULL.
  'stretched',
  -- DB hangs to full extension at the bottom, lat fully stretched.
  'system', FALSE
);


-- ─── 50. T-Bar Row ──────────────────────────────────────────────────────────
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
  'aaaaaaaa-0050-0000-0000-000000000001',
  'T-Bar Row',
  ARRAY['landmine row', 'T bar row', 'plate-loaded row'],
  'lifting',
  'horizontal_pull', NULL, 'bilateral',
  -- Mid-back biased horizontal pull. Wider elbow path + neutral grip
  -- (typical V-handle) shifts emphasis from lats (BB row, SA row) to
  -- traps_middle/traps_lower and rhomboids.
  --
  -- traps_middle 1.0 — primary target. Flared elbows and V-handle path
  --   specifically load mid-traps over lats.
  -- traps_lower 0.8 — closely related; lower trap also strongly recruited
  --   by the flared-elbow scapular depression at end-range.
  -- rhomboids 1.0 — co-target; scapular retraction is the centerpiece.
  --   Two 1.0s intentional per §2.
  -- lats_lower 0.5, lats_upper 0.4 — meaningful synergists; less emphasized
  --   than BB row (closer-elbow path) but still working hard.
  -- brachialis 0.8 — neutral V-handle grip routes elbow flexion to
  --   brachialis over biceps (Pattern 4).
  -- biceps_long 0.3, biceps_short 0.3 — assist elbow flexion; reduced
  --   by neutral grip.
  -- delts_posterior 0.5 — wider-elbow path increases rear delt contribution
  --   vs close-grip rows.
  -- spinal_erectors 0.25 — supports the bent-over position; user notices
  --   on heavy sets.
  -- forearms_grip 0.25 — grip on V-handle.
  '[
    {"muscle_id": "traps_middle",    "weight": 1.0},
    {"muscle_id": "traps_lower",     "weight": 0.8},
    {"muscle_id": "rhomboids",       "weight": 1.0},
    {"muscle_id": "lats_lower",      "weight": 0.5},
    {"muscle_id": "lats_upper",      "weight": 0.4},
    {"muscle_id": "brachialis",      "weight": 0.8},
    {"muscle_id": "biceps_long",     "weight": 0.3},
    {"muscle_id": "biceps_short",    "weight": 0.3},
    {"muscle_id": "delts_posterior", "weight": 0.5},
    {"muscle_id": "spinal_erectors", "weight": 0.25},
    {"muscle_id": "forearms_grip",   "weight": 0.25}
  ]'::jsonb,
  '{
    "traps_middle": "Flare your elbows and squeeze your shoulder blades together at the top — the V-handle path is specifically designed to target mid-traps over lats.",
    "delts_posterior": "The flared-elbow path forces rear delts to work hard at end-range — tuck elbows to shift emphasis to lats."
  }'::jsonb,
  'barbell', 'landmine', 5.00, 2.50,
  -- equipment_primary 'barbell' because most T-bar rows are landmine setups
  -- (one end of barbell pinned). Some gyms have dedicated T-bar machines
  -- (would be 'machine' equipment); the barbell+landmine variant is more
  -- common, so it's the default. equipment_specific marks the landmine
  -- attachment requirement.
  ARRAY['hypertrophy', 'strength'],
  'secondary_compound', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['lumbar_loading', 'grip_intensive'],
  -- Bent-over position loads the lower back without spinal compression
  -- (no bar on shoulders) — lumbar_loading per §3 distinction.
  '[]'::jsonb,
  'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  -- New T-bar family. Could share BB row family but the equipment +
  -- mechanic differences (landmine pivot, neutral grip handle, mid-back
  -- bias) push it into its own family per §1.
  '{"grip": "neutral"}'::jsonb,
  -- V-handle is the canonical T-bar grip.
  'stretched',
  -- Mid-back fully stretched at the bottom of the row.
  'system', FALSE
);


-- ─── 51. Lying Triceps Extension ────────────────────────────────────────────
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
  'aaaaaaaa-0051-0000-0000-000000000001',
  'Lying Triceps Extension',
  ARRAY['skullcrusher', 'lying tricep extension', 'EZ-bar skullcrusher'],
  'lifting',
  'elbow_extension', NULL, 'bilateral',
  -- elbow_extension enum value (added in PR #4 migration). Same primary
  -- pattern as triceps pushdown but very different muscle-length stimulus
  -- per §1 — overhead/lying position with shoulder flexion puts the
  -- long head of the triceps in stretched position, which research shows
  -- produces more triceps growth than the shoulder-neutral pushdown.
  --
  -- triceps_long 1.0 — long head is the entire reason to use this lift.
  --   The lying position with elbows overhead stretches the long head
  --   (which crosses the shoulder joint) maximally.
  -- triceps_lateral 0.7, triceps_medial 0.7 — also loaded throughout
  --   elbow extension; lower weight reflects the long-head-biased rationale.
  '[
    {"muscle_id": "triceps_long",    "weight": 1.0},
    {"muscle_id": "triceps_lateral", "weight": 0.7},
    {"muscle_id": "triceps_medial",  "weight": 0.7}
  ]'::jsonb,
  '{"triceps_long": "Lower the bar toward your forehead or slightly behind it — maintaining shoulder flexion deepens the long-head stretch. This is the entire reason to use this exercise over pushdowns."}'::jsonb,
  'barbell', 'ez_bar', 5.00, 2.50,
  -- Default to EZ-bar (most common variant). Straight bar and DB variants
  -- share this row via the equipment_specific column.
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'aaaaaabb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  -- New family. Skullcrusher is mechanically distinct from pushdown
  -- (different shoulder angle = different long-head stretch) and from
  -- close-grip bench (compound, multi-joint).
  NULL,
  'stretched',
  -- Long head stretched at the bottom of the lift; this is the
  -- programming reason to use this exercise. Per §8 cited in scope:
  -- "loaded_position variety" — the recommender should rotate
  -- stretched-bias and shortened-bias triceps work; this exercise
  -- complements pushdown's shortened-bias.
  'system', FALSE
);


-- ─── 52. Close-Grip Bench Press ─────────────────────────────────────────────
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
  'aaaaaaaa-0052-0000-0000-000000000001',
  'Close-Grip Bench Press',
  ARRAY['CGBP', 'close grip bench', 'narrow grip bench press'],
  'lifting',
  'horizontal_push', NULL, 'bilateral',
  -- Compound triceps lift. Same family as flat BB bench (bench_family),
  -- because per §1 grip width on a bench press is a separate row but
  -- still in the same family — same lift, different muscle bias.
  --
  -- triceps_long 1.0 — narrow grip with maintained shoulder flexion keeps
  --   the long head loaded throughout; the reason to program CGBP.
  -- triceps_lateral 0.9 — peaks at full lockout; borderline 0.9/1.0,
  --   going 0.9 to reflect that long head is the defining target.
  -- triceps_medial 0.7 — always active in elbow extension; less dominant.
  -- pectorals_sternal 0.5, pectorals_clavicular 0.3 — still meaningfully
  --   loaded; CGBP is not a pure triceps lift, chest does work especially
  --   in the bottom half. Demoted from bench's 1.0 because narrow grip
  --   reduces chest moment arm.
  -- delts_anterior 0.5 — synergist in pressing, same as flat bench.
  -- rectus_abdominis 0.25 — bracing under load, same as flat bench.
  '[
    {"muscle_id": "triceps_long",        "weight": 1.0},
    {"muscle_id": "triceps_lateral",     "weight": 0.9},
    {"muscle_id": "triceps_medial",      "weight": 0.7},
    {"muscle_id": "pectorals_sternal",   "weight": 0.5},
    {"muscle_id": "pectorals_clavicular","weight": 0.3},
    {"muscle_id": "delts_anterior",      "weight": 0.5},
    {"muscle_id": "rectus_abdominis",    "weight": 0.25}
  ]'::jsonb,
  '{
    "triceps_long": "Let the bar drift slightly toward your lower sternum on descent — maintaining shoulder flexion keeps the long head loaded throughout.",
    "triceps_lateral": "Drive to full lockout and squeeze hard at the top — the lateral head peaks at full extension."
  }'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'secondary_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['shoulder_flexion'],
  -- Less shoulder flexion than wide-grip bench but still some.
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  -- SHARES family with flat BB bench + flat DB bench. Per §1 example:
  -- "incline at 30° vs 45° = separate rows" implies different bench
  -- variants are separate rows, but they're still in the bench family.
  '{"grip": "pronated"}'::jsonb,
  -- Could add a "grip_width: narrow" attribute but no such key exists in
  -- §4. Going with grip: pronated (matching flat bench) and letting the
  -- name "Close-Grip Bench Press" carry the width info. Flag for §4
  -- amendment if grip_width needs to be a real attribute key.
  'stretched',
  -- Stretched at the bottom, same as flat bench.
  'system', FALSE
);


-- ─── 53. Incline Dumbbell Curl ──────────────────────────────────────────────
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
  'aaaaaaaa-0053-0000-0000-000000000001',
  'Incline Dumbbell Curl',
  ARRAY['incline DB curl', 'incline bicep curl', 'reclined DB curl'],
  'lifting',
  'elbow_flexion', NULL, 'bilateral',
  -- elbow_flexion isolation. Distinguished from BB curl by the incline
  -- bench position which extends the shoulder behind the torso, putting
  -- the long head of the biceps in stretched position. Per §8 cited in
  -- scope reasoning: stretched-bias biceps work, complementing BB curl's
  -- shortened/mid bias.
  --
  -- biceps_long 1.0 — supinated grip + shoulder-extended incline position
  --   puts the long head in maximal stretch; the entire reason for this variant.
  -- biceps_short 0.6 — supinated grip loads the short head too, but it
  --   does not benefit from the shoulder-extension stretch (not biarticular
  --   in the same way across the shoulder joint).
  -- forearms_brachioradialis 0.25 — brachioradialis contribution on
  --   supinated DB curl; meaningful on heavier sets.
  '[
    {"muscle_id": "biceps_long",             "weight": 1.0},
    {"muscle_id": "biceps_short",            "weight": 0.6},
    {"muscle_id": "forearms_brachioradialis","weight": 0.25}
  ]'::jsonb,
  '{"biceps_long": "Start each rep from a dead hang with shoulders fully extended behind you — the initial stretch is the entire point of the incline variation. Cutting the ROM at the bottom eliminates the stretched-bias stimulus."}'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'aaaaaacc-cccc-cccc-cccc-cccccccccccc',
  -- New family. Per §1 reasoning in scope: different muscle-length
  -- stimulus = separate row, and arguably separate family because the
  -- shoulder-extended position fundamentally changes the lift's training
  -- effect. Could share BB curl family; chose new family for clarity.
  '{"incline": "incline", "grip": "supinated"}'::jsonb,
  -- §4 incline + grip attributes both apply.
  'stretched',
  -- Per §8 explicitly. Long head stretched at the bottom; the programming
  -- reason for this lift is the stretched-bias stimulus.
  'system', FALSE
);


-- ─── 54. Cable Lateral Raise ────────────────────────────────────────────────
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
  'aaaaaaaa-0054-0000-0000-000000000001',
  'Cable Lateral Raise',
  ARRAY['cable side raise', 'low pulley lateral raise', 'cable lateral'],
  'lifting',
  'shoulder_abduction', NULL, 'unilateral',
  -- shoulder_abduction enum value (added in PR #4 migration). Single-arm
  -- unilateral typical (cross-body cable); same primary pattern as DB
  -- lateral but constant-tension loading profile distinguishes it
  -- meaningfully per §1.
  --
  -- delts_lateral 1.0 — uncontested target, same as DB lateral.
  --   The cross-body cable keeps tension at the bottom where the
  --   dumbbell version goes slack.
  '[
    {"muscle_id": "delts_lateral", "weight": 1.0}
  ]'::jsonb,
  '{"delts_lateral": "Raise to shoulder height only and keep a slight forward lean — going past parallel recruits traps to compensate. The cross-body cable keeps tension at the bottom where the dumbbell version goes slack."}'::jsonb,
  'cable', NULL, 5.00, 2.50,
  -- Cable load increments per §5 default for cable.
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'aaaaaadd-dddd-dddd-dddd-dddddddddddd',
  -- New family. DB lateral and cable lateral could share, but per §1's
  -- "equipment changes meaningfully" rule + the loaded_position
  -- difference (mid vs shortened), separate families is the cleaner call.
  NULL,
  'mid',
  -- Per §8 + scope reasoning: cable provides constant tension throughout
  -- the ROM, in contrast to DB lateral's shortened-bias (peak tension at
  -- top because gravity is vertical and DB moment arm peaks at the top).
  -- Cable lateral has no clear peak — load is even across the ROM. 'mid'
  -- captures this; could argue 'none' but per §8 'none' is for carries/
  -- conditioning specifically.
  'system', FALSE
);


-- ─── 55. Reverse Pec Deck ───────────────────────────────────────────────────
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
  'aaaaaaaa-0055-0000-0000-000000000001',
  'Reverse Pec Deck',
  ARRAY['rear delt fly machine', 'reverse fly machine', 'rear pec deck'],
  'lifting',
  'horizontal_pull', NULL, 'bilateral',
  -- horizontal_pull pattern (transverse abduction is the rear delt's
  -- horizontal-pull contribution). The rear delt has no dedicated
  -- isolation pattern in the enum; horizontal_pull is the closest fit
  -- and matches how face pull is patterned. Could argue this needs a
  -- new enum value (shoulder_horizontal_abduction) but per §3/§4
  -- discipline ("don't invent new tags ad-hoc") not adding here;
  -- flag for spec review if rear delt isolation grows into multiple
  -- exercises.
  --
  -- delts_posterior 1.0 — uncontested target. The reason to author this
  --   row is that batch 1-4 has rear delt coverage only via face pull
  --   at 0.25 weight; reverse pec deck is the actual rear delt isolation.
  -- rhomboids 0.5 — synergist in scapular retraction at end-range.
  -- traps_middle 0.5 — same scapular retraction role.
  -- traps_lower 0.3 — contributes to scapular depression-retraction;
  --   less than traps_middle but meaningful at end-range.
  -- No biceps entry — straight-arm machine, elbow doesn't flex.
  '[
    {"muscle_id": "delts_posterior", "weight": 1.0},
    {"muscle_id": "rhomboids",       "weight": 0.5},
    {"muscle_id": "traps_middle",    "weight": 0.5},
    {"muscle_id": "traps_lower",     "weight": 0.3}
  ]'::jsonb,
  '{"delts_posterior": "Initiate by pulling your elbows back rather than rotating at the wrists — elbows leading keeps rear delts loaded throughout. Wrist-led movement transfers to rhomboids at the back half."}'::jsonb,
  'machine', 'pec_deck_reverse', 10.00, 5.00,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'aaaaaaee-eeee-eeee-eeee-eeeeeeeeeeee',
  NULL,
  'shortened',
  -- Peak tension at the contracted (arms-out-wide) position; rear delts
  -- are fully shortened. Same shortened-bias as DB lateral for side delts.
  'system', FALSE
);


-- =============================================================================
-- EQUIPMENT EXPANSION (5 exercises, IDs 56–60)
-- =============================================================================


-- ─── 56. Trap Bar Deadlift ──────────────────────────────────────────────────
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
  'aaaaaaaa-0056-0000-0000-000000000001',
  'Trap Bar Deadlift',
  ARRAY['hex bar deadlift', 'trap bar DL', 'hex bar DL'],
  'lifting',
  'hinge', 'squat', 'bilateral',
  -- Pattern: hinge primary, squat secondary. The trap bar's neutral grip
  -- and centered load shifts the lift toward more knee flexion than
  -- conventional DL — many lifters describe trap bar DL as halfway
  -- between deadlift and squat. movement_pattern_secondary captures this.
  --
  -- quads_vastus_lateralis 1.0, quads_vastus_medialis 1.0,
  --   quads_vastus_intermedius 1.0 — distinguishing feature vs conv DL.
  --   Trap bar's more vertical torso + more knee flexion = quads do
  --   meaningfully more work than in conv DL (where they're ~0.5).
  -- quads_rectus_femoris 0.7 — two-joint discount applies (Pattern 1);
  --   hip-extended position limits RF contribution at the top.
  -- glutes_max 1.0 — same as conv DL; hip extension is primary mover.
  -- glutes_medius 0.25 — bilateral stabilizer cap.
  -- hamstrings_bf_long 0.5, hamstrings_semitendinosus 0.4,
  --   hamstrings_semimembranosus 0.4 — same role as conv DL but slightly
  --   less stretched because of the more squat-like position.
  -- spinal_erectors 1.0 — still axially loaded, still a back-strain lift.
  --   Trap bar can feel easier due to the more upright torso, but the
  --   erectors still do real work under heavy loads.
  -- traps_upper 0.5 — supporting the load via shrugged-shoulder position;
  --   trap bar DL is sometimes used as a trap builder.
  -- forearms_grip 0.25 — neutral grip is grippier than mixed/double-
  --   overhand; less grip-limited than conv DL but still meaningful.
  -- adductors_magnus 0.25 — stabilize stance.
  '[
    {"muscle_id": "quads_vastus_lateralis",    "weight": 1.0},
    {"muscle_id": "quads_vastus_medialis",     "weight": 1.0},
    {"muscle_id": "quads_vastus_intermedius",  "weight": 1.0},
    {"muscle_id": "quads_rectus_femoris",      "weight": 0.7},
    {"muscle_id": "glutes_max",                "weight": 1.0},
    {"muscle_id": "glutes_medius",             "weight": 0.25},
    {"muscle_id": "hamstrings_bf_long",        "weight": 0.5},
    {"muscle_id": "hamstrings_semitendinosus", "weight": 0.4},
    {"muscle_id": "hamstrings_semimembranosus","weight": 0.4},
    {"muscle_id": "spinal_erectors",           "weight": 1.0},
    {"muscle_id": "traps_upper",               "weight": 0.5},
    {"muscle_id": "forearms_grip",             "weight": 0.25},
    {"muscle_id": "adductors_magnus",          "weight": 0.25}
  ]'::jsonb,
  '{
    "quads_rectus_femoris": "Think ''leg press'' at the start — the trap bar''s upright torso means quads drive more than in a conventional deadlift.",
    "spinal_erectors": "Brace your entire torso before breaking the floor — the erectors still work maximally under heavy pulls despite the reduced forward moment arm."
  }'::jsonb,
  'specialty_bar', 'trap_bar', 5.00, 2.50,
  -- equipment_primary 'specialty_bar' per the schema enum (no dedicated
  -- 'trap_bar' value). equipment_specific carries the trap_bar
  -- discriminator for filtering ("user has trap bar" → match this row).
  -- Increments match conv DL.
  ARRAY['strength', 'hypertrophy', 'power'],
  -- 'power' modality applies — trap bar is the canonical strength-and-power
  -- lift for athletes; less technical than conv DL, allows more force
  -- expression. Currently 'power' isn't enumerated explicitly in the
  -- conventions; flagging for §3/§5 review if 'power' isn't already
  -- a known modality. (Spot-checked batch 4: 'power' is used. OK.)
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['axial_loading', 'grip_intensive'],
  '[]'::jsonb,
  'aaaaaa11-1111-1111-1111-111111111111',
  -- New family. Trap bar DL is mechanically distinct from conv DL
  -- (different bar position, different torso angle, different muscle
  -- distribution). Per §1, gets its own family.
  '{"grip": "neutral", "stance": "shoulder_width"}'::jsonb,
  'stretched',
  'system', FALSE
);


-- ─── 57. Safety Squat Bar Squat ─────────────────────────────────────────────
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
  'aaaaaaaa-0057-0000-0000-000000000001',
  'Safety Squat Bar Squat',
  ARRAY['SSB squat', 'yoke bar squat', 'safety bar squat'],
  'lifting',
  'squat', NULL, 'bilateral',
  -- Squat pattern. Same family is debatable — see family note below.
  --
  -- quads_vastus_lateralis 1.0, quads_vastus_medialis 1.0,
  --   quads_vastus_intermedius 1.0 — same as back squat; SSB is still a
  --   knee-dominant squat. SSB's pad pushes the lifter slightly forward,
  --   mimicking a front squat position.
  -- quads_rectus_femoris 0.7 — two-joint discount (Pattern 1).
  -- glutes_max 0.5 — same as high-bar back squat; quads primary, glutes
  --   still synergist.
  -- glutes_medius 0.25 — bilateral stabilizer cap.
  -- adductors_magnus 0.5, adductors_short 0.25 — same as back squat.
  -- spinal_erectors 0.5 — SSB is famous for its forward-pulling torque;
  --   heavier erector demand than straight-bar squat's 0.25. One of the
  --   programming reasons to use SSB (bracing demand).
  -- rhomboids 0.5 — SSB handles in front pull the lifter forward;
  --   scapular retractors work hard to maintain torso position.
  -- traps_middle 0.5, traps_lower 0.3 — same anti-forward-pull role
  --   as rhomboids; defining feature vs straight bar.
  -- rectus_abdominis 0.25 — bracing.
  '[
    {"muscle_id": "quads_vastus_lateralis",   "weight": 1.0},
    {"muscle_id": "quads_vastus_medialis",    "weight": 1.0},
    {"muscle_id": "quads_vastus_intermedius", "weight": 1.0},
    {"muscle_id": "quads_rectus_femoris",     "weight": 0.7},
    {"muscle_id": "glutes_max",               "weight": 0.5},
    {"muscle_id": "glutes_medius",            "weight": 0.25},
    {"muscle_id": "adductors_magnus",         "weight": 0.5},
    {"muscle_id": "adductors_short",          "weight": 0.25},
    {"muscle_id": "spinal_erectors",          "weight": 0.5},
    {"muscle_id": "rhomboids",                "weight": 0.5},
    {"muscle_id": "traps_middle",             "weight": 0.5},
    {"muscle_id": "traps_lower",              "weight": 0.3},
    {"muscle_id": "rectus_abdominis",         "weight": 0.25}
  ]'::jsonb,
  '{
    "spinal_erectors": "The forward-pulling handles mean your lower back works significantly harder than in a straight-bar squat — brace extra hard before each rep.",
    "rhomboids": "Actively drive your elbows down and squeeze the handles — fighting the bar''s forward pull is what loads the rhomboids."
  }'::jsonb,
  'specialty_bar', 'safety_squat_bar', 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['deep_knee_flexion', 'ankle_dorsiflexion', 'axial_loading',
        'thoracic_extension'],
  -- Same demands as back squat. SSB is often programmed for users with
  -- shoulder mobility issues that make back squat painful — but the
  -- thoracic_extension demand is still real (upright torso required).
  '[]'::jsonb,
  'aaaaaa22-2222-2222-2222-222222222222',
  -- New family — NOT shared with back squat per scope reasoning. SSB
  -- handles change torso angle, muscle distribution differs (more
  -- upper back demand). Same logic that makes front squat ≠ back squat
  -- separate families. Per §1's bar_position note, could go either way;
  -- chose new family for clarity since muscle weightings genuinely differ.
  '{"bar_position": "safety_squat", "stance": "shoulder_width"}'::jsonb,
  -- bar_position: safety_squat is in §4's established values list.
  'stretched',
  'system', FALSE
);


-- ─── 58. Kettlebell Swing ───────────────────────────────────────────────────
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
  'aaaaaaaa-0058-0000-0000-000000000001',
  'Kettlebell Swing',
  ARRAY['KB swing', 'Russian swing', 'two-hand kettlebell swing'],
  'lifting',
  'hinge', NULL, 'bilateral',
  -- Pattern: hinge with ballistic loading. Could argue 'plyometric' as
  -- primary but hinge is the dominant mechanic; the ballistic component
  -- is captured via demands tag. Russian-style (chest-height) default;
  -- American/overhead is a separate variant if added later.
  --
  -- glutes_max 1.0 — primary mover; the swing IS hip extension under
  --   ballistic load. Glutes are what propels the bell.
  -- hamstrings_bf_long 1.0 — co-target. Deep hip hinge with knees soft
  --   puts hamstrings in stretched/loaded position; elastic recoil from
  --   this loaded position is most of the lift's training effect.
  -- hamstrings_semitendinosus 0.8, hamstrings_semimembranosus 0.8 —
  --   also biarticular, loaded in the backswing hinge; slightly lower
  --   weight than bf_long per the loading pattern.
  -- spinal_erectors 0.5 — supports spine under repeated ballistic load.
  --   Less than a deadlift (lighter loads, no axial compression) but
  --   meaningful especially on long sets.
  -- forearms_grip 0.5 — grip on a heavy KB for high-rep ballistic work
  --   becomes a real factor; KB swing is often grip-limited.
  -- rectus_abdominis 0.25 — bracing during the float phase.
  '[
    {"muscle_id": "glutes_max",                 "weight": 1.0},
    {"muscle_id": "hamstrings_bf_long",         "weight": 1.0},
    {"muscle_id": "hamstrings_semitendinosus",  "weight": 0.8},
    {"muscle_id": "hamstrings_semimembranosus", "weight": 0.8},
    {"muscle_id": "spinal_erectors",            "weight": 0.5},
    {"muscle_id": "forearms_grip",              "weight": 0.5},
    {"muscle_id": "rectus_abdominis",           "weight": 0.25}
  ]'::jsonb,
  '{
    "hamstrings_bf_long": "Hike the bell aggressively between your legs — loading the hamstrings on the backswing creates the stretch-shortening cycle that drives the hip snap. The swing is not a squat.",
    "glutes_max": "Squeeze your glutes at the top of every rep to full hip lock-out — the swing ends at full hip extension, not at the bell''s peak height."
  }'::jsonb,
  'kettlebell', NULL, 8.00, NULL,
  -- Per §5: kettlebell increments are 4 or 8 lbs gym-dependent. Going
  -- with 8 (more common KB sizing). Micro-increments NULL per the
  -- conventions table — no half-pound jumps on KBs.
  ARRAY['power', 'conditioning', 'hypertrophy'],
  -- 'conditioning' modality applies — KB swings are commonly programmed
  -- as a conditioning tool (high-rep, low-rest). 'power' for ballistic
  -- hip drive. 'hypertrophy' less primary but real on volume work.
  'secondary_compound', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['hip_flexion', 'grip_intensive', 'dynamic_skill'],
  -- dynamic_skill per §3 — the timing of the swing (hike pass, hip snap,
  -- float) is a real skill that takes practice.
  '[]'::jsonb,
  'aaaaaa33-3333-3333-3333-333333333333',
  -- New family. KB swing is the first KB exercise; future KB variants
  -- (one-arm swing, snatch, clean) would share or sibling this family.
  '{"grip": "double_overhand"}'::jsonb,
  -- Two-hand grip on bell horns. Could argue this needs a new key in §4;
  -- using "grip" with a new value "double_overhand" — flag for §4
  -- amendment.
  'stretched',
  -- Glutes/hams stretched at the bottom of the hinge; this is the
  -- canonical loaded position for ballistic hinges.
  'system', FALSE
);


-- ─── 59. Farmer's Carry ─────────────────────────────────────────────────────
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
  'aaaaaaaa-0059-0000-0000-000000000001',
  'Farmer''s Carry',
  ARRAY['farmer carry', 'farmer walk', 'farmers walk', 'loaded carry'],
  'lifting',
  'carry', NULL, 'bilateral',
  -- carry pattern (already in enum). First exercise to use it.
  --
  -- forearms_grip 1.0 — primary target by training intent. Farmer's carry
  --   is the canonical grip-builder; the lift is grip-limited for almost
  --   every lifter.
  -- traps_upper 1.0 — co-target. Supporting heavy loads at the sides
  --   demands huge traps_upper isometric work; farmers are a canonical
  --   trap builder.
  -- rectus_abdominis 0.5 — bracing under load.
  -- transverse_abdominis 0.5 — the deep core works maximally to
  --   maintain IAP during loaded walking; added per v2 singleton coverage.
  -- obliques 0.5 — anti-flexion + lateral stability while walking.
  -- quads_vastus_lateralis 0.25 — walking under load; legs do real work.
  -- spinal_erectors 0.25 — supports the spine.
  '[
    {"muscle_id": "forearms_grip",          "weight": 1.0},
    {"muscle_id": "traps_upper",            "weight": 1.0},
    {"muscle_id": "rectus_abdominis",       "weight": 0.5},
    {"muscle_id": "transverse_abdominis",   "weight": 0.5},
    {"muscle_id": "obliques",               "weight": 0.5},
    {"muscle_id": "quads_vastus_lateralis", "weight": 0.25},
    {"muscle_id": "spinal_erectors",        "weight": 0.25}
  ]'::jsonb,
  '{
    "traps_upper": "Actively shrug your shoulders up and hold — letting them sag transfers load to the AC joint. Elevated, packed shoulders are the correct position throughout.",
    "forearms_grip": "Crush the handles actively rather than passively holding — grip fatigue ends most sets."
  }'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  -- Default to dumbbell; trap-bar farmers would be a separate row in this
  -- family if added later. Most users carry DBs.
  ARRAY['conditioning', 'stability', 'strength'],
  'accessory', 'late',
  -- Accessory + late: farmer's carry is a finisher in most programs.
  -- High systemic fatigue, programs late.
  'distance', TRUE, FALSE,
  -- Performance metric: distance. Could be time-based but distance is the
  -- canonical strongman metric (and most home programs prescribe
  -- "carry X for Y feet/yards").
  ARRAY['grip_intensive'],
  '[]'::jsonb,
  'aaaaaa44-4444-4444-4444-444444444444',
  -- New carry family — farmer's + suitcase share family per scope.
  '{"grip": "neutral"}'::jsonb,
  -- DB hangs at side, neutral grip.
  'none',
  -- Per §8: carries get loaded_position 'none'. No clear stretched/
  -- shortened position in a static-hold-while-walking lift.
  'system', FALSE
);


-- ─── 60. Suitcase Carry ─────────────────────────────────────────────────────
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
  'aaaaaaaa-0060-0000-0000-000000000001',
  'Suitcase Carry',
  ARRAY['one-arm carry', 'unilateral farmer carry', 'suitcase walk'],
  'lifting',
  'anti_lateral_flexion', 'carry', 'unilateral',
  -- Primary pattern: anti_lateral_flexion (the unilateral load creates
  -- a lateral bend force at the spine; resisting this is the entire
  -- training point of the lift). Secondary: carry (it's still a loaded
  -- carry mechanically).
  --
  -- This is the same conceptual move as side plank vs plank in batch 4 —
  -- the unilateral version recruits obliques as the anti-lateral-flexion
  -- prime mover.
  --
  -- obliques 1.0 — primary target on the contralateral side (load on
  --   right hand → left obliques resisting lateral bend). Same training
  --   intent as side plank.
  -- forearms_grip 1.0 — same grip demand as farmer's, scaled to one hand
  --   (effectively double the per-hand load for equivalent total weight).
  -- rectus_abdominis 0.5 — bracing + anti-flexion while walking under
  --   unilateral load.
  -- transverse_abdominis 0.5 — deep core IAP maintenance under asymmetric
  --   load; critical stability demand.
  -- traps_upper 0.5 — supporting the loaded side; less than farmer's
  --   because only one side is loaded.
  -- spinal_erectors 0.25 — same role as farmer's.
  '[
    {"muscle_id": "obliques",             "weight": 1.0},
    {"muscle_id": "forearms_grip",        "weight": 1.0},
    {"muscle_id": "rectus_abdominis",     "weight": 0.5},
    {"muscle_id": "transverse_abdominis", "weight": 0.5},
    {"muscle_id": "traps_upper",          "weight": 0.5},
    {"muscle_id": "spinal_erectors",      "weight": 0.25}
  ]'::jsonb,
  '{"obliques": "Walk tall and resist any lateral lean toward the loaded side — the anti-lean is the exercise. Tilting toward the weight eliminates the oblique stimulus entirely."}'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['conditioning', 'stability'],
  'accessory', 'late',
  'distance', TRUE, FALSE,
  ARRAY['grip_intensive', 'unilateral_balance'],
  -- unilateral_balance per §3 — controlling spinal position under
  -- asymmetric load is the defining demand.
  '[]'::jsonb,
  'aaaaaa44-4444-4444-4444-444444444444',
  -- SHARES family with farmer's carry. Bilateral vs unilateral version
  -- of the same fundamental movement (loaded walk).
  '{"grip": "neutral"}'::jsonb,
  'none',
  'system', FALSE
);


-- =============================================================================
-- PLYO + CONDITIONING (5 exercises, IDs 61–65)
-- =============================================================================


-- ─── 61. Box Jump ───────────────────────────────────────────────────────────
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
  'aaaaaaaa-0061-0000-0000-000000000001',
  'Box Jump',
  ARRAY['box jump up', 'plyo box jump', 'jump to box'],
  'lifting',
  'plyometric', 'squat', 'bilateral',
  -- First exercise to use the 'plyometric' enum value. Pattern is
  -- plyometric (ballistic, requires stretch-shortening cycle); secondary
  -- is squat (the lower-body shape of the takeoff is squat-pattern).
  --
  -- quads_vastus_lateralis 1.0, quads_vastus_medialis 1.0,
  --   quads_vastus_intermedius 1.0 — primary movers in the takeoff.
  -- quads_rectus_femoris 0.8 — two-joint discount (Pattern 1) applies
  --   but at a higher value than slow-tempo squats because ballistic
  --   movements recruit RF more strongly in the power phase.
  -- glutes_max 1.0 — co-target via hip extension at takeoff; plyometric
  --   power is generated jointly by both quads and glutes.
  -- calves_gastrocnemius 0.5 — meaningful contribution to ankle
  --   plantarflexion at takeoff; ballistic nature recruits calves more
  --   heavily than slow-tempo squat patterns.
  -- calves_soleus 0.3 — also contributes but less than gastrocnemius
  --   in an explosive context.
  -- hamstrings_bf_long 0.25 — assist hip extension; not primary but
  --   tracked because plyometric work fatigues hamstrings noticeably.
  '[
    {"muscle_id": "quads_vastus_lateralis",   "weight": 1.0},
    {"muscle_id": "quads_vastus_medialis",    "weight": 1.0},
    {"muscle_id": "quads_vastus_intermedius", "weight": 1.0},
    {"muscle_id": "quads_rectus_femoris",     "weight": 0.8},
    {"muscle_id": "glutes_max",               "weight": 1.0},
    {"muscle_id": "calves_gastrocnemius",     "weight": 0.5},
    {"muscle_id": "calves_soleus",            "weight": 0.3},
    {"muscle_id": "hamstrings_bf_long",       "weight": 0.25}
  ]'::jsonb,
  '{"glutes_max": "Land softly and absorb through your hips — controlling the deceleration eccentrically loads the glutes and drives adaptation just as much as the takeoff."}'::jsonb,
  'plyo_box', NULL, NULL, NULL,
  -- equipment_primary 'plyo_box' (already in schema enum). Increments
  -- NULL because progression is via box height, not added load.
  ARRAY['power', 'conditioning'],
  'main_compound', 'early',
  -- 'early' — plyometric work is CNS-intensive and requires fresh
  -- nervous system to execute safely. Programmed first on power days.
  'height', FALSE, TRUE,
  -- performance_metric 'height' — the metric is box height in inches.
  -- This is the §9 'height' use case verbatim. progression_eligible
  -- FALSE per §9 — height progression isn't via standard load
  -- increments; the recommender treats box-height as a discrete
  -- progression. relative_to_bodyweight TRUE — bodyweight IS the load.
  ARRAY['dynamic_skill', 'deep_knee_flexion'],
  '[]'::jsonb,
  'aaaaaa55-5555-5555-5555-555555555555',
  NULL,
  'none',
  -- 'none' — ballistic movement, no clear sustained loaded position.
  -- Per §8 not a clean fit, but better than 'mid' (implies even tension)
  -- or 'stretched' (implies sustained stretch). Going 'none' since the
  -- exercise is over in milliseconds.
  'system', FALSE
);


-- ─── 62. Sled Push ──────────────────────────────────────────────────────────
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
  'aaaaaaaa-0062-0000-0000-000000000001',
  'Sled Push',
  ARRAY['prowler push', 'sled prowler', 'pushing the prowler'],
  'conditioning',
  'locomotion', NULL, 'bilateral',
  -- domain 'conditioning' — first non-lifting domain in the seed batches.
  -- Per schema: domains are lifting/martial_arts/conditioning/mobility.
  -- Sled push is canonical conditioning equipment work.
  -- Pattern: locomotion (already in enum) — driving forward against
  -- resistance. Could argue squat/lunge but locomotion is the most
  -- accurate description; the lift is forward propulsion under load.
  --
  -- quads_vastus_lateralis 1.0, quads_vastus_medialis 1.0,
  --   quads_vastus_intermedius 1.0 — primary driver of forward propulsion;
  --   sled push is famous for building quad capacity.
  -- quads_rectus_femoris 0.7 — two-joint discount; hip-flexed driving
  --   position limits RF's contribution at the top of each step.
  -- glutes_max 1.0 — co-target; hip extension drives each step.
  -- calves_gastrocnemius 0.5 — ankle plantarflexion contributes to drive.
  -- calves_soleus 0.3 — also contributes; less than gastrocnemius.
  -- hamstrings_bf_long 0.5, hamstrings_semitendinosus 0.4,
  --   hamstrings_semimembranosus 0.4 — synergists in hip extension under
  --   heavy load.
  -- spinal_erectors 0.25 — supports spine in the bent-over driving position.
  '[
    {"muscle_id": "quads_vastus_lateralis",    "weight": 1.0},
    {"muscle_id": "quads_vastus_medialis",     "weight": 1.0},
    {"muscle_id": "quads_vastus_intermedius",  "weight": 1.0},
    {"muscle_id": "quads_rectus_femoris",      "weight": 0.7},
    {"muscle_id": "glutes_max",                "weight": 1.0},
    {"muscle_id": "calves_gastrocnemius",      "weight": 0.5},
    {"muscle_id": "calves_soleus",             "weight": 0.3},
    {"muscle_id": "hamstrings_bf_long",        "weight": 0.5},
    {"muscle_id": "hamstrings_semitendinosus", "weight": 0.4},
    {"muscle_id": "hamstrings_semimembranosus","weight": 0.4},
    {"muscle_id": "spinal_erectors",           "weight": 0.25}
  ]'::jsonb,
  '{}'::jsonb,
  'sled', NULL, 10.00, 5.00,
  -- 'sled' equipment per schema enum. Increments are plate-based; sleds
  -- are typically loaded with 25/45 plates so 10/5 increments aren't
  -- exact (most users add 25 or 45 at a time) but match the conventions
  -- §5 default for plate-loaded equipment.
  ARRAY['conditioning', 'power', 'strength'],
  'secondary_compound', 'late',
  -- 'late' — sled work is high-systemic-fatigue; programmed late or
  -- as a session finisher / dedicated conditioning day.
  'distance', TRUE, FALSE,
  -- Performance metric 'distance' — sled work prescribed by yards/feet.
  -- TODO(goals): for cut-goal users, calories may surface as secondary
  -- metric per goal-conditional metrics layer (see batch 5 header).
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'aaaaaa66-6666-6666-6666-666666666666',
  NULL,
  'none',
  'system', FALSE
);


-- ─── 63. Concept2 Rower ─────────────────────────────────────────────────────
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
  'aaaaaaaa-0063-0000-0000-000000000001',
  'Concept2 Rower',
  ARRAY['rowing machine', 'erg', 'concept2 erg', 'C2 rower', 'rower'],
  'conditioning',
  'horizontal_pull', 'hinge', 'bilateral',
  -- Pattern: horizontal_pull primary (the upper-body action is a
  -- horizontal row), hinge secondary (the lower-body action is a hinge).
  -- Could argue locomotion but rowing has more in common with strength
  -- patterns than with running-style locomotion. The hybrid nature is
  -- captured by primary + secondary.
  --
  -- The muscle distribution reflects the full-body nature of rowing —
  -- this is one of the few conditioning movements that's also a
  -- legitimate compound strength stimulus at sub-maximal intensities.
  --
  -- quads_vastus_lateralis 0.5, quads_vastus_medialis 0.5,
  --   quads_vastus_intermedius 0.5 — drive phase. Not 1.0 because rowing
  --   isn't quad-limiting the way a squat is.
  -- quads_rectus_femoris 0.4 — two-joint discount on the drive phase.
  -- glutes_max 0.5 — hip extension on drive.
  -- hamstrings_bf_long 0.5, hamstrings_semitendinosus 0.4,
  --   hamstrings_semimembranosus 0.4 — synergists in hip extension.
  -- lats_lower 0.5 — finish of the drive (arms pull handle to torso);
  --   elbow-to-belly path loads lower lat.
  -- lats_upper 0.4 — also loaded; less dominant.
  -- rhomboids 0.5 — scapular retraction at finish.
  -- spinal_erectors 0.5 — supports the catch position and finish;
  --   primary injury site under fatigue (forward rounding at catch).
  -- brachialis 0.3 — pronated grip on the handle routes arm pull to
  --   brachialis (Pattern 4).
  -- rectus_abdominis 0.25 — bracing throughout the stroke.
  -- No 1.0s — rowing is the canonical "no single muscle limits the
  -- exercise" movement.
  '[
    {"muscle_id": "quads_vastus_lateralis",    "weight": 0.5},
    {"muscle_id": "quads_vastus_medialis",     "weight": 0.5},
    {"muscle_id": "quads_vastus_intermedius",  "weight": 0.5},
    {"muscle_id": "quads_rectus_femoris",      "weight": 0.4},
    {"muscle_id": "glutes_max",                "weight": 0.5},
    {"muscle_id": "hamstrings_bf_long",        "weight": 0.5},
    {"muscle_id": "hamstrings_semitendinosus", "weight": 0.4},
    {"muscle_id": "hamstrings_semimembranosus","weight": 0.4},
    {"muscle_id": "lats_lower",                "weight": 0.5},
    {"muscle_id": "lats_upper",                "weight": 0.4},
    {"muscle_id": "rhomboids",                 "weight": 0.5},
    {"muscle_id": "spinal_erectors",           "weight": 0.5},
    {"muscle_id": "brachialis",                "weight": 0.3},
    {"muscle_id": "rectus_abdominis",          "weight": 0.25}
  ]'::jsonb,
  '{
    "lats_lower": "Pull the handle to your lower belly, not your chest — lower-belly rowing keeps elbows close and loads the lower lat through full ROM.",
    "spinal_erectors": "Brace before every catch — the forward-reach at the catch loads the erectors maximally. Rounding there under fatigue is the primary injury mechanism."
  }'::jsonb,
  'machine', 'concept2_rower', NULL, NULL,
  -- 'machine' equipment (no dedicated rower enum value). Damper setting
  -- is a parameter but not a load-increment in the lbs sense; NULL.
  ARRAY['conditioning'],
  'main_compound', 'late',
  -- 'main_compound' role despite being conditioning — for a rowing-
  -- focused session this is the main lift. 'late' position because it's
  -- typically the conditioning portion after lifting work.
  'distance', TRUE, FALSE,
  -- Performance metric 'distance' — Concept2 standard is meters. The
  -- rowing world's universal benchmark is the 2k row time, which is
  -- distance-fixed-time-variable. distance metric supports both that
  -- and the inverse (fixed-time, distance-variable workouts).
  -- TODO(goals): calories likely surfaces as secondary metric for
  -- cut-goal users per goal-conditional metrics layer.
  ARRAY['hip_flexion'],
  '[]'::jsonb,
  'aaaaaa77-7777-7777-7777-777777777777',
  NULL,
  'none',
  'system', FALSE
);


-- ─── 64. Air Bike ───────────────────────────────────────────────────────────
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
  'aaaaaaaa-0064-0000-0000-000000000001',
  'Air Bike',
  ARRAY['assault bike', 'echo bike', 'fan bike', 'airdyne'],
  'conditioning',
  'locomotion', NULL, 'alternating',
  -- Pattern: locomotion (cycling motion). loading_type 'alternating'
  -- because legs and arms work in alternating opposition (right leg
  -- + left arm drive together, then switch).
  --
  -- quads_vastus_lateralis 0.5, quads_vastus_medialis 0.5,
  --   quads_vastus_intermedius 0.5 — drive phase of pedal stroke.
  -- quads_rectus_femoris 0.4 — two-joint discount on pedaling.
  -- glutes_max 0.5 — hip extension on drive.
  -- hamstrings_bf_long 0.5, hamstrings_semitendinosus 0.4,
  --   hamstrings_semimembranosus 0.4 — pull phase (clipped pedals not
  --   assumed; hamstrings still work via hip flexion-extension cycle).
  -- calves_gastrocnemius 0.25 — ankle stabilization.
  -- pectorals_sternal 0.25 — push phase of arm cycle.
  -- lats_lower 0.25 — pull phase of arm cycle.
  -- delts_anterior 0.25 — push phase.
  -- Air bike's distinguishing feature: loads everything moderately rather
  -- than anything heavily — no primary mover target. Reflected in muscle
  -- weightings (no 1.0s, mostly 0.5s and 0.25s).
  '[
    {"muscle_id": "quads_vastus_lateralis",    "weight": 0.5},
    {"muscle_id": "quads_vastus_medialis",     "weight": 0.5},
    {"muscle_id": "quads_vastus_intermedius",  "weight": 0.5},
    {"muscle_id": "quads_rectus_femoris",      "weight": 0.4},
    {"muscle_id": "glutes_max",                "weight": 0.5},
    {"muscle_id": "hamstrings_bf_long",        "weight": 0.5},
    {"muscle_id": "hamstrings_semitendinosus", "weight": 0.4},
    {"muscle_id": "hamstrings_semimembranosus","weight": 0.4},
    {"muscle_id": "calves_gastrocnemius",      "weight": 0.25},
    {"muscle_id": "pectorals_sternal",         "weight": 0.25},
    {"muscle_id": "lats_lower",                "weight": 0.25},
    {"muscle_id": "delts_anterior",            "weight": 0.25}
  ]'::jsonb,
  '{}'::jsonb,
  'machine', 'air_bike', NULL, NULL,
  ARRAY['conditioning'],
  'accessory', 'late',
  'time', TRUE, FALSE,
  -- Performance metric 'time' per scope decision. The most common air
  -- bike prescription is "X minutes at Y RPM/effort" or intervals
  -- ("30 sec on, 30 sec off"). Time is the cleanest fit.
  -- TODO(goals): per scope decision and conversation, calories is the
  -- most useful air bike metric for cut-goal users (the explicit
  -- "burn 300 calories" use case). When goal-conditional metrics layer
  -- ships, this row should support calories as a secondary metric.
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'aaaaaa88-8888-8888-8888-888888888888',
  NULL,
  'none',
  'system', FALSE
);


-- ─── 65. Jump Rope ──────────────────────────────────────────────────────────
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
  'aaaaaaaa-0065-0000-0000-000000000001',
  'Jump Rope',
  ARRAY['skipping rope', 'jumping rope', 'speed rope'],
  'conditioning',
  'plyometric', NULL, 'bilateral',
  -- Pattern: plyometric. Each bounce is a low-amplitude plyometric
  -- contact; jump rope is the canonical low-intensity plyometric
  -- conditioning tool.
  --
  -- calves_gastrocnemius 1.0 — primary muscle by a wide margin. Jump rope
  --   is the canonical calf endurance/capacity builder. Per §2 "the muscle
  --   that limits the exercise" — calves cramp before anything else fatigues.
  -- calves_soleus 0.5 — also loaded; less dominant in the explosive
  --   bounce than gastrocnemius.
  -- quads_vastus_lateralis 0.25 — minimal knee flexion absorbs each landing.
  -- forearms_wrist_flexors 0.25 — wrist work to spin the rope on
  --   speed-rope style. Wrist flexors dominate the rope rotation.
  -- Note: heart-rate and respiratory demand are not muscle weights;
  -- captured in the conditioning modality, not as muscle entries.
  '[
    {"muscle_id": "calves_gastrocnemius",    "weight": 1.0},
    {"muscle_id": "calves_soleus",           "weight": 0.5},
    {"muscle_id": "quads_vastus_lateralis",  "weight": 0.25},
    {"muscle_id": "forearms_wrist_flexors",  "weight": 0.25}
  ]'::jsonb,
  '{"calves_gastrocnemius": "Stay on your toes and minimize ground contact time — the gastrocnemius functions as a spring here. Letting heels touch eliminates the plyometric stimulus."}'::jsonb,
  'none', 'jump_rope', NULL, NULL,
  -- equipment_primary 'none' (jump rope isn't in the equipment enum).
  -- equipment_specific carries the rope info for filtering. Could argue
  -- 'specialty_bar' or adding 'rope' to the enum; 'none' is honest about
  -- the lack of canonical equipment-category fit. Flag for §5 amendment
  -- if jump rope becomes the first of a category.
  ARRAY['conditioning', 'power'],
  'accessory', 'anywhere',
  'time', TRUE, TRUE,
  -- Performance metric 'time' per scope decision. Most common
  -- prescription is "X minutes" or rounds-of-time. Could also be
  -- 'rounds_x_duration' for double-under intervals; going 'time' as
  -- the single-row default. relative_to_bodyweight TRUE per §9 —
  -- bodyweight IS the load.
  ARRAY['dynamic_skill'],
  -- Coordination/timing skill is real on jump rope; double-unders are
  -- a meaningful skill progression.
  '[]'::jsonb,
  'aaaaaa99-9999-9999-9999-999999999999',
  NULL,
  'none',
  'system', FALSE
);


-- =============================================================================
-- Substitution graph
-- =============================================================================
-- Wires batch 5 exercises to existing exercises and to each other. Per §10:
-- aim for 2-4 substitutes per exercise; every exercise should have at least
-- one substitute. Reasons drawn from §10 controlled vocabulary.
--
-- Convention: A → B (A's substitute is B). Direction matters per §10.
-- =============================================================================

INSERT INTO public.exercise_substitutes (exercise_id, substitute_id, similarity_score, reason) VALUES

  -- ── Glute Bridge (45) ────────────────────────────────────────────────────
  ('aaaaaaaa-0045-0000-0000-000000000001', 'aaaaaaaa-0011-0000-0000-000000000001', 0.85, 'progression'),
    -- → Barbell Hip Thrust: same family, full ROM version
  ('aaaaaaaa-0045-0000-0000-000000000001', 'aaaaaaaa-0046-0000-0000-000000000001', 0.65, 'progression'),
    -- → Single-Leg Hip Thrust: harder unilateral version

  -- ── Single-Leg Hip Thrust (46) ───────────────────────────────────────────
  ('aaaaaaaa-0046-0000-0000-000000000001', 'aaaaaaaa-0011-0000-0000-000000000001', 0.85, 'regression'),
    -- → Barbell Hip Thrust: bilateral version, easier unilateral demand
  ('aaaaaaaa-0046-0000-0000-000000000001', 'aaaaaaaa-0045-0000-0000-000000000001', 0.65, 'regression'),
    -- → Glute Bridge: easiest of the family

  -- ── Seated Leg Curl (47) ─────────────────────────────────────────────────
  ('aaaaaaaa-0047-0000-0000-000000000001', 'aaaaaaaa-0024-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
    -- → Lying Leg Curl: same pattern, different muscle-length stimulus.
    -- Note: §10 vocabulary doesn't have an exact "different muscle-length"
    -- reason; same_pattern_different_equipment is the closest fit since
    -- the equipment (seated vs lying machine) is what differs. Flag for
    -- §10 vocabulary review.

  -- ── Good Morning (48) ────────────────────────────────────────────────────
  ('aaaaaaaa-0048-0000-0000-000000000001', 'aaaaaaaa-0010-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
    -- → Romanian Deadlift: similar muscles (hamstrings/lower_back/glutes),
    -- different bar position
  ('aaaaaaaa-0048-0000-0000-000000000001', 'aaaaaaaa-0024-0000-0000-000000000001', 0.45, 'regression'),
    -- → Lying Leg Curl: hamstring-only regression; loses the lower_back
    -- training but easier on the back if injured

  -- ── Single-Arm Dumbbell Row (49) ─────────────────────────────────────────
  ('aaaaaaaa-0049-0000-0000-000000000001', 'aaaaaaaa-0014-0000-0000-000000000001', 0.75, 'same_pattern_different_equipment'),
    -- → Barbell Bent-Over Row: bilateral version, different equipment
  ('aaaaaaaa-0049-0000-0000-000000000001', 'aaaaaaaa-0015-0000-0000-000000000001', 0.70, 'same_pattern_different_equipment'),
    -- → Chest-Supported DB Row: removes anti-rotation demand
  ('aaaaaaaa-0049-0000-0000-000000000001', 'aaaaaaaa-0050-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
    -- → T-Bar Row: bilateral mid-back biased version

  -- ── T-Bar Row (50) ───────────────────────────────────────────────────────
  ('aaaaaaaa-0050-0000-0000-000000000001', 'aaaaaaaa-0014-0000-0000-000000000001', 0.80, 'same_pattern_different_equipment'),
    -- → Barbell Bent-Over Row: very close substitute; T-bar is mid-back
    -- biased but BB row covers the same role
  ('aaaaaaaa-0050-0000-0000-000000000001', 'aaaaaaaa-0015-0000-0000-000000000001', 0.70, 'same_pattern_different_equipment'),
    -- → Chest-Supported DB Row: equipment alternative
  ('aaaaaaaa-0050-0000-0000-000000000001', 'aaaaaaaa-0049-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
    -- → Single-Arm DB Row: unilateral alternative

  -- ── Lying Triceps Extension (51) ─────────────────────────────────────────
  ('aaaaaaaa-0051-0000-0000-000000000001', 'aaaaaaaa-0028-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
    -- → Triceps Pushdown: same target muscle, opposite loaded_position
    -- (shortened-bias). Programs as a complement, not a 1:1 swap.
  ('aaaaaaaa-0051-0000-0000-000000000001', 'aaaaaaaa-0052-0000-0000-000000000001', 0.55, 'progression'),
    -- → Close-Grip Bench Press: compound triceps movement, harder

  -- ── Close-Grip Bench Press (52) ──────────────────────────────────────────
  ('aaaaaaaa-0052-0000-0000-000000000001', 'aaaaaaaa-0012-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
    -- → Barbell Bench Press (flat): same family, wider grip = chest bias
    -- vs CGBP's triceps bias
  ('aaaaaaaa-0052-0000-0000-000000000001', 'aaaaaaaa-0020-0000-0000-000000000001', 0.70, 'same_muscles_different_pattern'),
    -- → Dip: bodyweight compound triceps alternative
  ('aaaaaaaa-0052-0000-0000-000000000001', 'aaaaaaaa-0051-0000-0000-000000000001', 0.55, 'regression'),
    -- → Lying Triceps Extension: isolation regression for the triceps
    -- target

  -- ── Incline Dumbbell Curl (53) ───────────────────────────────────────────
  ('aaaaaaaa-0053-0000-0000-000000000001', 'aaaaaaaa-0027-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
    -- → Barbell Curl: same target, opposite loaded_position (mid vs
    -- stretched). Programs as a complement.
  ('aaaaaaaa-0053-0000-0000-000000000001', 'aaaaaaaa-0029-0000-0000-000000000001', 0.65, 'same_pattern_different_equipment'),
    -- → Dumbbell Hammer Curl: same equipment, different grip / muscle bias

  -- ── Cable Lateral Raise (54) ─────────────────────────────────────────────
  ('aaaaaaaa-0054-0000-0000-000000000001', 'aaaaaaaa-0003-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
    -- → Dumbbell Lateral Raise: same target, different loaded_position
    -- profile (constant tension vs shortened-bias)

  -- ── Reverse Pec Deck (55) ────────────────────────────────────────────────
  ('aaaaaaaa-0055-0000-0000-000000000001', 'aaaaaaaa-0042-0000-0000-000000000001', 0.80, 'same_muscles_different_pattern'),
    -- → Face Pull: rear delt focus, different equipment + slightly
    -- different mechanic (cable + rope, includes external rotation)
  ('aaaaaaaa-0055-0000-0000-000000000001', 'aaaaaaaa-0015-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),
    -- → Chest-Supported DB Row: includes meaningful rear delt work as
    -- part of the row; weaker substitute but available everywhere

  -- ── Trap Bar Deadlift (56) ───────────────────────────────────────────────
  ('aaaaaaaa-0056-0000-0000-000000000001', 'aaaaaaaa-0009-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
    -- → Conventional Deadlift: closest bilateral hinge alternative
  ('aaaaaaaa-0056-0000-0000-000000000001', 'aaaaaaaa-0041-0000-0000-000000000001', 0.75, 'same_pattern_different_equipment'),
    -- → Sumo Deadlift: another bilateral hinge variant; quads more
    -- involved (similar to trap bar)
  ('aaaaaaaa-0056-0000-0000-000000000001', 'aaaaaaaa-0001-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
    -- → Back Squat: trap bar's squat-leaning nature makes back squat a
    -- weaker but real substitute when no trap bar available

  -- ── Safety Squat Bar Squat (57) ──────────────────────────────────────────
  ('aaaaaaaa-0057-0000-0000-000000000001', 'aaaaaaaa-0001-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
    -- → Barbell Back Squat: closest substitute; SSB is the
    -- shoulder-mobility-friendly version
  ('aaaaaaaa-0057-0000-0000-000000000001', 'aaaaaaaa-0007-0000-0000-000000000001', 0.75, 'same_pattern_different_equipment'),
    -- → Front Squat: similar upright-torso demand
  ('aaaaaaaa-0057-0000-0000-000000000001', 'aaaaaaaa-0006-0000-0000-000000000001', 0.80, 'same_pattern_different_equipment'),
    -- → Low-Bar Back Squat: same back-squat family, different bar
    -- position

  -- ── Kettlebell Swing (58) ────────────────────────────────────────────────
  ('aaaaaaaa-0058-0000-0000-000000000001', 'aaaaaaaa-0010-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
    -- → Romanian Deadlift: slow-tempo hinge alternative; loses the
    -- ballistic component but trains same muscle group
  ('aaaaaaaa-0058-0000-0000-000000000001', 'aaaaaaaa-0011-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),
    -- → Barbell Hip Thrust: glute-focused alternative

  -- ── Farmer's Carry (59) ──────────────────────────────────────────────────
  ('aaaaaaaa-0059-0000-0000-000000000001', 'aaaaaaaa-0060-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
    -- → Suitcase Carry: same family, unilateral variant
  ('aaaaaaaa-0059-0000-0000-000000000001', 'aaaaaaaa-0009-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),
    -- → Conventional Deadlift: shares grip + traps demand; not a true
    -- substitute but available anywhere a barbell is

  -- ── Suitcase Carry (60) ──────────────────────────────────────────────────
  ('aaaaaaaa-0060-0000-0000-000000000001', 'aaaaaaaa-0059-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
    -- → Farmer's Carry: same family, bilateral variant
  ('aaaaaaaa-0060-0000-0000-000000000001', 'aaaaaaaa-0031-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
    -- → Side Plank: also anti_lateral_flexion; trains obliques
    -- isometrically rather than under loaded gait

  -- ── Box Jump (61) ────────────────────────────────────────────────────────
  ('aaaaaaaa-0061-0000-0000-000000000001', 'aaaaaaaa-0001-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),
    -- → Barbell Back Squat: same primary muscles, slow-tempo strength
    -- alternative; loses plyometric component but available when no
    -- box is present

  -- ── Sled Push (62) ───────────────────────────────────────────────────────
  ('aaaaaaaa-0062-0000-0000-000000000001', 'aaaaaaaa-0064-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
    -- → Air Bike: substitute conditioning tool when no sled available;
    -- different muscle bias but similar conditioning effect

  -- ── Concept2 Rower (63) ──────────────────────────────────────────────────
  ('aaaaaaaa-0063-0000-0000-000000000001', 'aaaaaaaa-0064-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
    -- → Air Bike: alternative conditioning machine when no rower
  ('aaaaaaaa-0063-0000-0000-000000000001', 'aaaaaaaa-0065-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),
    -- → Jump Rope: equipment-light conditioning fallback

  -- ── Air Bike (64) ────────────────────────────────────────────────────────
  ('aaaaaaaa-0064-0000-0000-000000000001', 'aaaaaaaa-0063-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
    -- → Concept2 Rower: alternative conditioning machine
  ('aaaaaaaa-0064-0000-0000-000000000001', 'aaaaaaaa-0062-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
    -- → Sled Push: alternative when air bike unavailable
  ('aaaaaaaa-0064-0000-0000-000000000001', 'aaaaaaaa-0065-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),
    -- → Jump Rope: equipment-light fallback

  -- ── Jump Rope (65) ───────────────────────────────────────────────────────
  ('aaaaaaaa-0065-0000-0000-000000000001', 'aaaaaaaa-0064-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
    -- → Air Bike: machine-based conditioning alternative
  ('aaaaaaaa-0065-0000-0000-000000000001', 'aaaaaaaa-0026-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern');
    -- → Standing Calf Raise: jump rope's primary muscle (calves) trained
    -- isolated and slow-tempo; loses the conditioning component


-- =============================================================================
-- End of batch 5
-- =============================================================================
-- Running totals after this batch lands:
--   Total exercises: 65 (44 + 21)
--   Total substitution edges: ~155 (119 + 36 new)
--
-- Equipment newly represented: kettlebell, specialty_bar (trap_bar +
--   safety_squat_bar via equipment_specific), plyo_box, sled, none (jump rope).
-- Movement patterns newly used: carry (farmer's, suitcase secondary),
--   plyometric (box jump, jump rope), locomotion (sled push, air bike).
-- Domains newly used: conditioning (sled, rower, air bike, jump rope).
-- Modalities newly used: power (KB swing, sled, box jump, jump rope),
--   conditioning (sled, rower, air bike, jump rope, KB swing, farmer's,
--   suitcase).
--
-- Open follow-up items flagged inline (also captured in chat for separate
-- tracking):


COMMIT;


-- =============================================================================
-- Verification queries (run separately after COMMIT to confirm data)
-- =============================================================================

-- SELECT COUNT(*) FROM public.exercises;
-- -- Expected: 65

-- SELECT COUNT(*) FROM public.exercise_substitutes;
-- -- Expected: ~155

-- SELECT exercise_id, name, jsonb_array_length(muscles) AS muscle_count,
--        head_emphasis_notes
-- FROM public.exercises ORDER BY name;

-- SELECT e.name, m->>'muscle_id' AS muscle_id, (m->>'weight')::numeric AS weight
-- FROM public.exercises e,
--      jsonb_array_elements(e.muscles) AS m
-- WHERE m->>'muscle_id' IN (
--   'glutes', 'hamstrings', 'adductors', 'abs', 'lower_back',
--   'lats', 'biceps', 'triceps', 'forearms', 'chest', 'quads', 'calves',
--   'rear_delts', 'front_delts', 'side_delts', 'traps_mid_lower'
-- );
-- -- Expected: 0 rows (confirms no v1 group-level IDs remain)