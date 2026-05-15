-- =============================================================================
-- Seed Exercises — v1 Draft (5 representative exercises for format review)
-- Updated for muscle taxonomy v2 — per-head distributions and head_emphasis_notes added.
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
--   - Muscle weights: v2 per-head distributions. See docs/exercise_authoring_conventions.md
--     §13 (taxonomy), §14 (biomechanical patterns). Weights use full range
--     including intermediates (0.3, 0.4, 0.6, 0.7, 0.85).
--   - head_emphasis_notes: JSONB object keyed by muscle_id, form-cue text only.
--     NULL for exercises where no form distinction meaningfully shifts emphasis.
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
