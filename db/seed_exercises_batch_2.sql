-- =============================================================================
-- Seed Exercises — Batch 2 (12 exercises: squat completion, hinge, push, pull)
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
-- Conventions adhered to (see docs/exercise_authoring_conventions.md):
--   - §1: variations are separate rows; low-bar / front / goblet share squat
--     family with batch-1 high-bar back squat. Conv DL, RDL, hip thrust each
--     get their own family (different lifts, different muscle weightings,
--     different patterns within hinge umbrella).
--   - §2: muscle-weighting discipline. 1.0 only for clear targets; default to
--     fewer 1.0s when borderline. 0.25 only when meaningfully challenged
--     (forearms on heavy DL, abs on standing OHP — both cited as correct
--     examples in §2). Decisions surfaced inline below where judgment was
--     required.
--   - §3: demands drawn from the closed vocabulary. No new tags introduced.
--     One candidate ("front_rack_position") considered and rejected — see
--     Front Squat note below.
--   - §4: variation_attributes uses established keys only (bar_position,
--     stance, incline). All snake_case.
--   - §5: all load_increment values in lbs.
--   - §6: 2-4 aliases per exercise.
--   - §10: directed substitutes; cross-batch refs use batch-1 UUIDs.
--
-- All `relative_to_bodyweight` = FALSE for this batch (no bodyweight-loaded
-- movements; everything is externally loaded barbell/dumbbell/cable).
-- All `progression_eligible` = TRUE (all standard loaded lifts).
-- All `authored_by` = 'system', `verified` = FALSE — pending review.
-- =============================================================================

-- Pre-generated UUIDs so substitutes wire up in one script.
-- Family IDs (§1: variations of same lift share a family_id)
--   squat_family       = 11111111-1111-1111-1111-111111111111   (batch 1; reused for low-bar/front/goblet)
--   pullup_family      = 22222222-2222-2222-2222-222222222222   (batch 1)
--   lateral_family     = 33333333-3333-3333-3333-333333333333   (batch 1)
--   splitsquat_family  = 44444444-4444-4444-4444-444444444444   (batch 1)
--   legpress_family    = 55555555-5555-5555-5555-555555555555   (batch 1)
--   deadlift_family    = 66666666-6666-6666-6666-666666666666   (NEW; conv DL + future variants like sumo, deficit)
--   rdl_family         = 77777777-7777-7777-7777-777777777777   (NEW; RDL + future variants like DB RDL, single-leg RDL)
--   hip_thrust_family  = 88888888-8888-8888-8888-888888888888   (NEW; barbell HT + future variants like single-leg, B-stance)
--   bench_family       = 99999999-9999-9999-9999-999999999999   (NEW; flat BB + flat DB + future incline/decline variants)
--   row_family         = bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb   (NEW; BB row + chest-supported DB row + future variants)
--   ohp_family         = cccccccc-cccc-cccc-cccc-cccccccccccc   (NEW; standing BB OHP + seated DB OHP + future variants)
--
-- Note: each hinge lift gets its own family (deadlift / rdl / hip_thrust)
-- because conventions §1 treats different muscle weightings + different
-- patterns as separate lifts, not variations of one. The "hinge" pattern is
-- the umbrella, not the family.
--
-- Exercise IDs (continuing batch-1 scheme aaaaaaaa-XXXX-...)
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
  -- Low-bar shifts the bar onto the rear delts and produces a more horizontal
  -- torso → longer hip moment arm, shorter knee moment arm. Per conventions §2:
  -- "glutes at 1.0 only on hip-dominant variants (low-bar wide-stance, sumo)."
  -- Quads stay 1.0 — they are still a target on any squat. Hamstrings pick up
  -- 0.5 (meaningful synergist on the hip-dominant pattern; not a primary).
  -- Wider stance (typical for low-bar) → adductors 0.5 retained. Lower-back 0.25
  -- and abs 0.25 carry over from high-bar; the more horizontal torso slightly
  -- increases lumbar demand but not enough to bump to 0.5.
  -- Movement_pattern_secondary = 'hinge' to flag the increased posterior-chain
  -- contribution; differentiates from high-bar (which has secondary = NULL).
  '[
    {"muscle_id": "quads",      "weight": 1.0},
    {"muscle_id": "glutes",     "weight": 1.0},
    {"muscle_id": "hamstrings", "weight": 0.5},
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
  '{"bar_position": "low_bar", "stance": "wide"}'::jsonb,
  'stretched',
  'system', FALSE
);

-- ─── 7. Barbell Front Squat ─────────────────────────────────────────────────
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
  'aaaaaaaa-0007-0000-0000-000000000001',
  'Barbell Front Squat',
  ARRAY['front squat', 'BB front squat', 'clean-grip front squat'],
  'lifting',
  'squat', NULL, 'bilateral',
  -- Bar in front rack → upright torso → quad-dominant, less glute, less posterior
  -- chain. Abs work hard to resist the bar pulling the torso into flexion;
  -- per conventions §2 this is a meaningful synergist (would be sore if
  -- isolated, fatigues during the set), so 0.5 not 0.25. Glutes drop from
  -- the 1.0 of low-bar back to 0.5 (clearly not the target on front squat).
  -- Lower_back 0.25 carries over (axially loaded). Adductors 0.5 retained
  -- (still a squat).
  -- PROPOSED NEW DEMAND CANDIDATE: front_rack_position — REJECTED. The wrist
  -- mobility / shoulder external rotation requirement is meaningful but is
  -- already covered by `shoulder_external_rotation` and (debatably)
  -- `thoracic_extension`. Adding a more specific tag would be silent vocab
  -- creep. Tagging shoulder_external_rotation here.
  '[
    {"muscle_id": "quads",      "weight": 1.0},
    {"muscle_id": "glutes",     "weight": 0.5},
    {"muscle_id": "adductors",  "weight": 0.5},
    {"muscle_id": "abs",        "weight": 0.5},
    {"muscle_id": "lower_back", "weight": 0.25}
  ]'::jsonb,
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
  ARRAY['goblet squat', 'DB goblet squat', 'KB goblet squat'],
  'lifting',
  'squat', NULL, 'bilateral',
  -- Goblet squat is a regression / warm-up for the squat pattern.
  -- DECISION: Quads remain 1.0. The target muscle on a quad-dominant squat
  -- doesn't change because of load ceiling — quads are still the muscle that
  -- limits the lift and the muscle the user is "training." That the user
  -- can't load it heavily enough to drive serious hypertrophy is captured by
  -- default_role = 'accessory' and the lack of 'strength' modality, not by
  -- demoting quads. (Surfacing this for confirmation — see reply.)
  -- Glutes 0.5, adductors 0.5 — same as front squat. Abs 0.25: front-loaded
  -- (one DB at chest) creates real anti-extension demand even at light load,
  -- though not enough to bump to 0.5 the way front squat does.
  -- equipment_primary: 'dumbbell' since DB is the more common default;
  -- KB goblet would technically warrant a separate row per §1 (different
  -- equipment) but is so close to identical in execution that it's covered
  -- by aliases for v1. If the model later distinguishes them by load-range
  -- semantics, split it into a separate row.
  '[
    {"muscle_id": "quads",      "weight": 1.0},
    {"muscle_id": "glutes",     "weight": 0.5},
    {"muscle_id": "adductors",  "weight": 0.5},
    {"muscle_id": "abs",        "weight": 0.25}
  ]'::jsonb,
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
  -- DECISION (surfaced for confirmation): three muscles at 1.0.
  -- The deadlift is unusual: it has multiple genuine targets, not one.
  -- - Glutes 1.0 — primary hip extensor at lockout, the muscle that limits
  --   the lift for many lifters.
  -- - Hamstrings 1.0 — primary hip extensor off the floor; also fatigue-
  --   limiting on heavy sets.
  -- - Lower_back 1.0 — UNIQUE TO DEADLIFT vs other lifts. On squats, the
  --   lower back is a 0.25 stabilizer (supports the bar). On deadlift, the
  --   spinal erectors are loaded under significant moment arm and are often
  --   what fails first on a heavy attempt. This meets §2's "muscle that
  --   limits the lift" criterion. Promoting from the 0.25 stabilizer slot
  --   to the 1.0 target slot is the principled call.
  -- Quads 0.5 — meaningful off the floor, not primary.
  -- Traps_upper 0.5 — heavy isometric to support the bar through the lift;
  --   meaningful synergist that would fatigue and be sore.
  -- Forearms 0.25 — grip-intensive heavy DL, cited explicitly in conventions
  --   §2 as a correct 0.25 entry.
  -- Adductors omitted — not meaningful at conventional stance.
  -- Abs omitted — bracing happens but the spinal erectors do the work; abs
  --   at 0.25 here would just be noise.
  -- This is the only batch-2 exercise with three 1.0s. The conventions
  -- "default to fewer 1.0s" guidance is a tiebreaker for borderline calls;
  -- here all three are distinct, primary, and limit-determining, so the
  -- guidance doesn't bind.
  '[
    {"muscle_id": "glutes",       "weight": 1.0},
    {"muscle_id": "hamstrings",   "weight": 1.0},
    {"muscle_id": "lower_back",   "weight": 1.0},
    {"muscle_id": "quads",        "weight": 0.5},
    {"muscle_id": "traps_upper",  "weight": 0.5},
    {"muscle_id": "forearms",     "weight": 0.25}
  ]'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['lumbar_loading', 'hip_flexion', 'grip_intensive'],
  '[]'::jsonb,
  '66666666-6666-6666-6666-666666666666',
  '{"stance": "conventional"}'::jsonb,
  -- DECISION (loaded_position): 'stretched'. Peak tension occurs at the
  -- bottom (off-the-floor position) where the hips are most flexed and the
  -- moment arm on the lower back is largest. This is borderline (some
  -- argue 'mid' since the sticking point is often just past the knees),
  -- but the hip flexion at start of pull qualifies under conventions §8
  -- "stretched: peak tension at the bottom of ROM." Surfacing for review.
  'stretched',
  'system', FALSE
);

-- ─── 10. Romanian Deadlift (RDL) — Barbell ──────────────────────────────────
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
  'aaaaaaaa-0010-0000-0000-000000000001',
  'Romanian Deadlift',
  ARRAY['RDL', 'barbell RDL', 'BB romanian deadlift'],
  'lifting',
  'hinge', NULL, 'bilateral',
  -- Hamstrings 1.0 — clear target (loaded at hip flexion / stretched
  -- position), confirmed by prompt.
  -- DECISION (surfaced for confirmation): Glutes 0.5, not 1.0.
  -- RDL hits glutes well at lockout, but the ENTIRE point of the RDL is the
  -- stretched-hamstring position. If glutes were the target, you'd
  -- programme a hip thrust. Per conventions §2 "default to fewer 1.0s when
  -- borderline" → 0.5. (Would flip to 1.0 if review prefers; both are
  -- defensible.)
  -- Lower_back 0.5 — loaded under tension throughout the movement (longer
  --   moment arm than squat, and unsupported unlike good morning's safety
  --   bar). Not 1.0 because hamstrings are the clear primary, but solidly
  --   0.5: a meaningful synergist that fatigues and would be sore.
  -- Forearms 0.25 — grip-intensive at heavy loads, classic 0.25 case.
  -- No adductors entry (negligible at standard stance), no quads entry
  -- (knees stay nearly locked — minimal contribution).
  '[
    {"muscle_id": "hamstrings",   "weight": 1.0},
    {"muscle_id": "glutes",       "weight": 0.5},
    {"muscle_id": "lower_back",   "weight": 0.5},
    {"muscle_id": "forearms",     "weight": 0.25}
  ]'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'secondary_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['lumbar_loading', 'hip_flexion', 'grip_intensive'],
  '[]'::jsonb,
  '77777777-7777-7777-7777-777777777777',
  NULL,
  -- 'stretched': RDL's whole identity is the stretched hamstring at the
  -- bottom. Unambiguous per conventions §8.
  'stretched',
  'system', FALSE
);

-- ─── 11. Hip Thrust — Barbell ───────────────────────────────────────────────
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
  'aaaaaaaa-0011-0000-0000-000000000001',
  'Barbell Hip Thrust',
  ARRAY['hip thrust', 'BB hip thrust', 'barbell hip thrust'],
  'lifting',
  'hinge', NULL, 'bilateral',
  -- Glutes 1.0 — uncontested target.
  -- DECISION (surfaced for confirmation): Hamstrings 0.5.
  -- Hip thrust is INTENTIONALLY positioned (torso angle, foot placement
  -- close to hips) to maximize glute contribution and minimize hamstring.
  -- Hamstrings still contribute as hip extensors and to maintain knee
  -- flexion against load, but they're not the target by design. 0.5 is the
  -- right call (meaningful synergist, would fatigue, would be sore).
  -- 0.25 felt like under-weighting a real contributor. 1.0 would conflict
  -- with the design intent of the lift.
  -- Quads omitted — minor isometric only.
  -- Lower_back omitted — torso is supported on bench through the lift;
  --   passive support, not loaded.
  -- Adductors omitted — minor.
  -- Abs omitted — pelvic positioning matters but bracing is brief.
  '[
    {"muscle_id": "glutes",     "weight": 1.0},
    {"muscle_id": "hamstrings", "weight": 0.5}
  ]'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'secondary_compound', 'anywhere',
  -- DECISION (surfaced for confirmation): performance_metric = 'weight_x_reps'.
  -- Standard barbell + bench setup, clean rep counting. Confirmed.
  'weight_x_reps', TRUE, FALSE,
  ARRAY['hip_flexion'],
  '[]'::jsonb,
  '88888888-8888-8888-8888-888888888888',
  NULL,
  -- 'shortened': peak tension occurs at the TOP of the rep (hips extended,
  -- glutes maximally contracted). Hip thrust is the canonical
  -- peak-contraction lower-body movement. Conventions §8 explicitly cites
  -- "peak-contraction isolation" as 'shortened'; hip thrust is the
  -- compound analogue.
  'shortened',
  'system', FALSE
);

-- ─── 12. Barbell Bench Press — Flat ─────────────────────────────────────────
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
  'aaaaaaaa-0012-0000-0000-000000000001',
  'Barbell Bench Press',
  ARRAY['bench press', 'flat bench', 'BB bench', 'barbell bench'],
  'lifting',
  'horizontal_push', NULL, 'bilateral',
  -- Chest 1.0 — uncontested target.
  -- DECISION (surfaced for confirmation): Triceps 0.5, Front_delts 0.5.
  -- Both are real synergists in horizontal pressing, both fatigue during
  -- a working set, both would be sore if the lift were programmed in
  -- isolation from triceps/delt accessories. Per conventions §2 default
  -- ("default to fewer 1.0s") triceps stays 0.5 not 1.0; close-grip bench
  -- (a future row in this family) is where triceps would arguably be 1.0.
  -- Front delts 0.5 NOT 0.25: 0.25 would imply stabilizer-only, but front
  -- delts contribute primary force in horizontal pressing — they're a
  -- genuine synergist, not a stabilizer. (Spec's bench-press hint in the
  -- prompt header was 0.5/0.5; matching it.)
  -- No 0.25 entries: triceps and front delts at 0.5 cover the synergists;
  -- adding lat (slight isometric) or biceps (zero) would be noise.
  '[
    {"muscle_id": "chest",       "weight": 1.0},
    {"muscle_id": "triceps",     "weight": 0.5},
    {"muscle_id": "front_delts", "weight": 0.5}
  ]'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"incline": "flat", "grip": "pronated"}'::jsonb,
  -- 'stretched': peak tension at the bottom (bar at chest, pecs maximally
  -- stretched). Standard for any pressing movement.
  'stretched',
  'system', FALSE
);

-- ─── 13. Dumbbell Bench Press — Flat ────────────────────────────────────────
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
  'aaaaaaaa-0013-0000-0000-000000000001',
  'Dumbbell Bench Press',
  ARRAY['DB bench', 'dumbbell bench', 'flat DB bench', 'DB flat bench'],
  'lifting',
  'horizontal_push', NULL, 'bilateral',
  -- Same muscle weights as BB bench. The DB version offers greater stretch
  -- and unilateral stabilization, but at the muscle-weight resolution we
  -- track (1.0/0.5/0.25), the targets and synergists are the same.
  -- The differences live in: (a) loaded_position (still stretched, but
  -- arguably more so — same tag), (b) substitution graph (DB is a
  -- regression for trainees with pressing imbalances), (c) future
  -- demand tag if "unilateral_stabilization" is ever added to vocab —
  -- not adding here per §3 closed vocabulary.
  '[
    {"muscle_id": "chest",       "weight": 1.0},
    {"muscle_id": "triceps",     "weight": 0.5},
    {"muscle_id": "front_delts", "weight": 0.5}
  ]'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
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
  -- Note: Pendlay row is technically a stricter variant (bar reset on floor
  -- each rep) and could justify a separate row in the same family. Folding
  -- into aliases for v1 since most users use the terms interchangeably.
  'lifting',
  'horizontal_pull', NULL, 'bilateral',
  -- Lats 1.0 — clear target.
  -- DECISION (surfaced for confirmation): Rhomboids 0.5 AND traps_mid_lower
  -- 0.5 (both at 0.5, neither at 1.0). Both are heavily worked in any
  -- horizontal row, but neither is "the muscle that limits the lift" —
  -- that's the lats. Bumping one to 1.0 over the other would be arbitrary;
  -- bumping both would over-assign 1.0. Per conventions §2 default,
  -- both stay 0.5.
  -- Rear_delts 0.5 — meaningful synergist in any row pulling the elbow
  -- back; classic mid-back-day burn target.
  -- Biceps 0.5 — assist in any pull; would fatigue first for some users.
  -- Lower_back 0.5 — bent-over hold creates real lumbar loading (NOT just
  -- a stabilizer here as it is on squats — the hinged position means the
  -- erectors are working under significant tension throughout the set).
  -- Promoting to 0.5 with `lumbar_loading` demand tag is the consistent
  -- application of conventions §2 examples ("Lower back on barbell back
  -- squat" cited as a 0.25 case BECAUSE axially loaded with bar on top;
  -- here the geometry is different — back is horizontal under load, more
  -- like RDL than back squat).
  -- Forearms 0.25 — grip-intensive on heavy rows.
  '[
    {"muscle_id": "lats",            "weight": 1.0},
    {"muscle_id": "rhomboids",       "weight": 0.5},
    {"muscle_id": "traps_mid_lower", "weight": 0.5},
    {"muscle_id": "rear_delts",      "weight": 0.5},
    {"muscle_id": "biceps",          "weight": 0.5},
    {"muscle_id": "lower_back",      "weight": 0.5},
    {"muscle_id": "forearms",        "weight": 0.25}
  ]'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['lumbar_loading', 'hip_flexion', 'grip_intensive'],
  '[]'::jsonb,
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  '{"grip": "pronated"}'::jsonb,
  -- 'stretched': peak tension at the bottom (arms extended, lats stretched).
  'stretched',
  'system', FALSE
);

-- ─── 15. Chest-Supported Dumbbell Row ───────────────────────────────────────
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
  'aaaaaaaa-0015-0000-0000-000000000001',
  'Chest-Supported Dumbbell Row',
  ARRAY['chest-supported row', 'CSR', 'incline DB row', 'prone DB row'],
  'lifting',
  'horizontal_pull', NULL, 'bilateral',
  -- Same upper-back targets as BB row, but the bench support removes
  -- lower-back load and reduces grip demand somewhat. This is precisely
  -- why it's a regression / pull-back-day specialist.
  -- Lats 1.0 (target unchanged), rhomboids/mid-traps/rear-delts/biceps
  -- all 0.5 (same synergists). Lower_back DROPPED — bench support removes
  -- the loading that justified 0.5 on BB row. Forearms also dropped to
  -- keep the entry list focused on what's distinguishing — grip is still
  -- present but less limit-determining than on BB row.
  '[
    {"muscle_id": "lats",            "weight": 1.0},
    {"muscle_id": "rhomboids",       "weight": 0.5},
    {"muscle_id": "traps_mid_lower", "weight": 0.5},
    {"muscle_id": "rear_delts",      "weight": 0.5},
    {"muscle_id": "biceps",          "weight": 0.5}
  ]'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['hypertrophy', 'strength'],
  'secondary_compound', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  '{"grip": "neutral", "incline": "incline"}'::jsonb,
  -- 'stretched': arms hang straight down at bottom, lats stretched.
  'stretched',
  'system', FALSE
);

-- ─── 16. Standing Barbell Overhead Press ────────────────────────────────────
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
  'aaaaaaaa-0016-0000-0000-000000000001',
  'Standing Barbell Overhead Press',
  ARRAY['OHP', 'standing press', 'BB overhead press', 'military press'],
  'lifting',
  'vertical_push', NULL, 'bilateral',
  -- Front_delts 1.0 — clear target.
  -- DECISION (surfaced for confirmation): Triceps 0.5, Side_delts 0.5.
  -- Triceps: same logic as bench — meaningful pressing synergist, but front
  -- delts are the target. 0.5 is consistent with bench. (Could argue 1.0
  -- on a strict-press where lockout is the sticking point, but defaulting
  -- to fewer 1.0s.)
  -- Side delts 0.25 (review-confirmed): they assist abduction at the upper
  -- portion of the press, but contribution is small enough to be a
  -- stabilizer-tier callout, not a synergist. Reserves the ≥0.5 weighting
  -- (and weekly volume credit) for direct lateral work like the lateral
  -- raise (batch 1).
  -- Traps_upper 0.5 — significant upward rotation under load.
  -- Abs 0.25 — anti-extension while standing under bar; conventions §2
  -- explicitly cites "abs on overhead press" as a correct 0.25 case.
  '[
    {"muscle_id": "front_delts",  "weight": 1.0},
    {"muscle_id": "triceps",      "weight": 0.5},
    {"muscle_id": "traps_upper",  "weight": 0.5},
    {"muscle_id": "side_delts",   "weight": 0.25},
    {"muscle_id": "abs",          "weight": 0.25}
  ]'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['overhead_rom', 'shoulder_flexion', 'axial_loading', 'thoracic_extension'],
  -- axial_loading: the bar rests on the front of the shoulders during
  -- setup and bottom of rep, transmitting load through the spine while
  -- standing — qualifies under conventions §3.
  '[]'::jsonb,
  'cccccccc-cccc-cccc-cccc-cccccccccccc',
  '{"grip": "pronated"}'::jsonb,
  -- 'stretched': bar at shoulder level, delts at relative stretch.
  'stretched',
  'system', FALSE
);

-- ─── 17. Seated Dumbbell Overhead Press ─────────────────────────────────────
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
  'aaaaaaaa-0017-0000-0000-000000000001',
  'Seated Dumbbell Overhead Press',
  ARRAY['seated DB OHP', 'seated DB press', 'seated dumbbell press', 'DB shoulder press'],
  'lifting',
  'vertical_push', NULL, 'bilateral',
  -- Same shoulder-press synergist pattern as standing BB OHP, BUT:
  -- - axial_loading demand drops (back is supported by bench).
  -- - abs 0.25 drops for the same reason.
  -- This is the consistent application of conventions §2 example: "Abs on
  -- overhead press (resists extension)" at 0.25 — the demand exists when
  -- standing, not when seated against a backrest.
  -- Traps_upper retained at 0.5 — upward rotation demand is the same.
  -- Side_delts 0.25 retained from standing BB OHP (review-confirmed) —
  -- stabilizer-tier contribution; reserves ≥0.5 for direct lateral work.
  '[
    {"muscle_id": "front_delts",  "weight": 1.0},
    {"muscle_id": "triceps",      "weight": 0.5},
    {"muscle_id": "traps_upper",  "weight": 0.5},
    {"muscle_id": "side_delts",   "weight": 0.25}
  ]'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'secondary_compound', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['overhead_rom', 'shoulder_flexion'],
  '[]'::jsonb,
  'cccccccc-cccc-cccc-cccc-cccccccccccc',
  '{"grip": "neutral"}'::jsonb,
  -- Note: many users rotate to pronated at top — neutral represents the
  -- typical bottom/start position. If wanting to track a strict pronated
  -- DB press, that's a separate row.
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
  -- ── 6. Low-bar back squat ────────────────────────────────────────────────
  -- Closest substitute: high-bar back squat (same equipment, same family,
  -- different muscle distribution).
  ('aaaaaaaa-0006-0000-0000-000000000001', 'aaaaaaaa-0001-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  -- Front squat: same equipment, different bar position, different muscle
  -- bias. Strong same-family substitute.
  ('aaaaaaaa-0006-0000-0000-000000000001', 'aaaaaaaa-0007-0000-0000-000000000001', 0.75, 'same_pattern_different_equipment'),
  -- Conventional deadlift: posterior-chain alternative when low-bar squat
  -- not available.
  ('aaaaaaaa-0006-0000-0000-000000000001', 'aaaaaaaa-0009-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),

  -- ── 7. Front squat ───────────────────────────────────────────────────────
  ('aaaaaaaa-0007-0000-0000-000000000001', 'aaaaaaaa-0001-0000-0000-000000000001', 0.80, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0007-0000-0000-000000000001', 'aaaaaaaa-0008-0000-0000-000000000001', 0.65, 'regression'),
  ('aaaaaaaa-0007-0000-0000-000000000001', 'aaaaaaaa-0006-0000-0000-000000000001', 0.75, 'same_pattern_different_equipment'),

  -- ── 8. Goblet squat ──────────────────────────────────────────────────────
  -- Goblet is itself a regression; substitutes are progressions / nearby.
  ('aaaaaaaa-0008-0000-0000-000000000001', 'aaaaaaaa-0001-0000-0000-000000000001', 0.65, 'progression'),
  ('aaaaaaaa-0008-0000-0000-000000000001', 'aaaaaaaa-0007-0000-0000-000000000001', 0.65, 'progression'),
  ('aaaaaaaa-0008-0000-0000-000000000001', 'aaaaaaaa-0005-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),

  -- Reciprocal: high-bar back squat (batch 1) → goblet (regression)
  -- and high-bar back squat → low-bar / front squat substitutes added here
  -- so batch 1's back squat now connects to the new family rows. (Adding
  -- to the batch-1 row's outgoing edges; non-destructive — these are new
  -- INSERTs, not updates.)
  ('aaaaaaaa-0001-0000-0000-000000000001', 'aaaaaaaa-0006-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0001-0000-0000-000000000001', 'aaaaaaaa-0007-0000-0000-000000000001', 0.80, 'same_pattern_different_equipment'),
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
  -- No reverse edge to BB row (per prompt: regression direction only).
  -- But CSR users may benefit from pull-up as a vertical alternative.
  ('aaaaaaaa-0015-0000-0000-000000000001', 'aaaaaaaa-0002-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),

  -- ── 16. Standing barbell OHP ─────────────────────────────────────────────
  ('aaaaaaaa-0016-0000-0000-000000000001', 'aaaaaaaa-0017-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  -- Cross-pattern: BB bench shares triceps + front delts (different primary).
  ('aaaaaaaa-0016-0000-0000-000000000001', 'aaaaaaaa-0012-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),

  -- ── 17. Seated dumbbell OHP ──────────────────────────────────────────────
  ('aaaaaaaa-0017-0000-0000-000000000001', 'aaaaaaaa-0016-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0017-0000-0000-000000000001', 'aaaaaaaa-0013-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern');
