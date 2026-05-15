-- =============================================================================
-- Seed Exercises — Batch 3 (12 exercises: lifting library completion)
-- Updated for muscle taxonomy v2 — per-head distributions and head_emphasis_notes added.
-- =============================================================================
-- Purpose: close major coverage gaps in the lifting domain after batch 2.
-- After this batch the DB has 29 exercises (batch 1: 5, batch 2: 12, batch 3: 12).
--
-- Mix:
--   Push completion
--    18.  Incline Barbell Bench Press
--    19.  Incline Dumbbell Bench Press
--    20.  Dip (parallel-bar, triceps-bias upright torso — revised default)
--   Pull completion
--    21.  Chin-Up (supinated)
--    22.  Lat Pulldown
--    23.  Seated Cable Row
--   Lower accessory
--    24.  Lying Leg Curl
--    25.  Leg Extension
--    26.  Standing Calf Raise
--   Arms
--    27.  Barbell Curl
--    28.  Triceps Pushdown (Cable)
--    29.  Dumbbell Hammer Curl
--
-- Conventions adhered to (see docs/exercise_authoring_conventions.md v2):
--   - §1: variations are separate rows.
--   - §13: all muscle_ids are per-head or singletons; no group references.
--   - §14: seven biomechanical patterns applied throughout.
--   - §2: comprehensive 0.25 authoring; intermediate weights used throughout.
--
-- Note on movement_pattern values for exercises 24-28: the movement_pattern enum
-- was extended in PR #4 to include knee_flexion, knee_extension, ankle_extension,
-- elbow_flexion, elbow_extension. The column values in these INSERTs retain the
-- original placeholder values per Rule 7 (only muscles + head_emphasis_notes
-- are modified in PR B). The live DB rows were updated by the PR #4 migration.
--
-- Dip default: revised to triceps-bias (upright torso) in batch 3 v2 review.
-- Chin-up biceps: 1.0 on both heads (supinated grip = biceps co-limits with lats).
-- All `progression_eligible` = TRUE.
-- All `authored_by` = 'system', `verified` = FALSE.
-- =============================================================================

-- Pre-generated UUIDs.
-- Family IDs reused from prior batches:
--   pullup_family       = 22222222-2222-2222-2222-222222222222   (chin-up joins)
--   bench_family        = 99999999-9999-9999-9999-999999999999   (inclines join)
--
-- New family IDs:
--   dip_family          = dddddddd-dddd-dddd-dddd-dddddddddddd
--   lat_pulldown_family = eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee
--   cable_row_family    = ffffffff-ffff-ffff-ffff-ffffffffffff
--   leg_curl_family     = 11111111-2222-3333-4444-555555555555
--   leg_extension_family= 22222222-3333-4444-5555-666666666666
--   calf_raise_family   = 33333333-4444-5555-6666-777777777777
--   bb_curl_family      = 44444444-5555-6666-7777-888888888888
--   pushdown_family     = 55555555-6666-7777-8888-999999999999
--   hammer_curl_family  = 66666666-7777-8888-9999-aaaaaaaaaaaa
--
-- Exercise IDs:
--   incline_bb_bench    = aaaaaaaa-0018-0000-0000-000000000001
--   incline_db_bench    = aaaaaaaa-0019-0000-0000-000000000001
--   dip                 = aaaaaaaa-0020-0000-0000-000000000001
--   chin_up             = aaaaaaaa-0021-0000-0000-000000000001
--   lat_pulldown        = aaaaaaaa-0022-0000-0000-000000000001
--   cable_row_seated    = aaaaaaaa-0023-0000-0000-000000000001
--   lying_leg_curl      = aaaaaaaa-0024-0000-0000-000000000001
--   leg_extension       = aaaaaaaa-0025-0000-0000-000000000001
--   standing_calf_raise = aaaaaaaa-0026-0000-0000-000000000001
--   bb_curl             = aaaaaaaa-0027-0000-0000-000000000001
--   tricep_pushdown     = aaaaaaaa-0028-0000-0000-000000000001
--   hammer_curl         = aaaaaaaa-0029-0000-0000-000000000001


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
