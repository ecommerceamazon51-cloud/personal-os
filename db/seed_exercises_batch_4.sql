-- =============================================================================
-- Seed Exercises — Batch 4 (15 exercises: core domain + bodyweight + lifting gaps)
-- =============================================================================
-- Purpose: open three new coverage areas after batches 1–3:
--   1. Core domain (currently zero coverage; core is in every workout)
--   2. Bodyweight/home-gym progression ladder (currently zero coverage; users
--      without gym access need a complete program path)
--   3. Highest-value remaining lifting gaps
--
-- After this batch the DB has 44 exercises (batches 1–3: 29, batch 4: 15).
-- Conventions §12 was amended in this PR cycle to remove the ~50 hard cap
-- in favor of "stop and reassess every ~25" — see the conventions amendment
-- patch shipped alongside this SQL.
--
-- DEPENDENCY: this batch REQUIRES the movement_pattern enum migration to
-- be applied first. References used here that did not exist in batches 1–3:
--   - anti_extension       (plank, hanging leg raise, ab wheel)
--   - anti_lateral_flexion (side plank)
--   - rotation             (cable woodchop) — was already in enum, just unused
--   - anti_rotation        (Pallof press)   — was already in enum, just unused
-- The enum migration also retroactively cleans up six closest-fit stubs in
-- batches 1 and 3; that's a separate concern from this batch but lands in
-- the same PR cycle.
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
-- Conventions adhered to (see docs/exercise_authoring_conventions.md):
--   - §1: variations are separate rows. Sumo joins deadlift_family per the
--     conventions table that explicitly cites "Sumo vs conventional deadlift
--     → Separate rows." Push-up variants share a new pushup_family. Seated
--     calf raise joins calf_raise_family from batch 3.
--   - §2: muscle-weighting discipline. 1.0 only for clear targets. Anti-
--     pattern core exercises target 'abs' as 1.0 — the resistance to spinal
--     extension/lateral flexion is the abs' job. Decisions surfaced inline
--     where judgment was required (face pull rear delts vs upper back, etc.).
--   - §3: demands drawn from the closed vocabulary. No new tags introduced.
--     One candidate ("isometric_hold") considered for plank/side plank and
--     rejected — see plank note below. The performance_metric=time already
--     captures the isometric nature.
--   - §4: variation_attributes uses established keys only (stance for sumo,
--     grip for face pull, incline for push-up family).
--   - §5: all load_increment values in lbs. Bodyweight exercises follow the
--     §5 "Bodyweight (loaded)" defaults (2.50 / 1.25) when they're loadable
--     (push-up with weight vest, hanging leg raise with ankle weights), and
--     get NULL increments when load isn't standard (plank, side plank, ab
--     wheel where progression is via duration or ROM).
--   - §6: 2-4 aliases per exercise; no duplicates of the name field.
--   - §10: directed substitutes; cross-batch refs use prior-batch UUIDs.
--
-- Decisions confirmed in chat before drafting:
--   - Cap removed from conventions §12 (no hard upper limit; reassess every
--     ~25). This batch is sized at 15 to keep PR review manageable.
--   - Plank uses performance_metric=time. Adding load (plate on back) is a
--     future progression knob; schema would need a "time + load" combined
--     metric or a load_modifier column. Not pressing — flagged in TODO.md.
--   - Hanging leg raise gets its own row; toes-to-bar and windshield wipers
--     are separate rows in the same family, deferred to batch 5.
--   - Push-up family: incline (hands elevated → easier) is a regression;
--     pike (feet elevated, vertical-ish push) is a different pattern, not
--     just a progression — gets primary = vertical_push. Decline push-up
--     and one-arm push-up deferred to batch 5.
--   - Walking lunge gets its own row (lunge_split unilateral, but distinct
--     from BSS which is split-stance bilateral-with-rear-foot-elevated).
--   - Sumo DL movement_pattern stays 'hinge' (same as conventional); the
--     muscle-weighting differences (more glute/adductor, less hamstring/
--     lower back) are what make it a separate row, per §1.
--
-- All `progression_eligible` = TRUE except plank/side plank (time-based
-- isometric holds — progression is duration, captured by the metric, not
-- by load increments).
-- All `authored_by` = 'system', `verified` = FALSE — pending review.
-- =============================================================================

-- Pre-generated UUIDs.
-- Family IDs reused from prior batches:
--   deadlift_family     = 66666666-6666-6666-6666-666666666666 (sumo joins)
--   calf_raise_family   = 33333333-4444-5555-6666-777777777777 (seated joins)
--
-- New family IDs:
--   plank_family        = 77777777-8888-9999-aaaa-bbbbbbbbbbbb
--     (anti_extension family; plank + future variants like RKC plank, weighted
--     plank as a separate metric row)
--   side_plank_family   = 88888888-9999-aaaa-bbbb-cccccccccccc
--     (anti_lateral_flexion; side plank + future variants)
--   hanging_leg_family  = 99999999-aaaa-bbbb-cccc-dddddddddddd
--     (anti_extension dynamic; HLR + future toes-to-bar, windshield wipers,
--     knee tucks as regression)
--   ab_wheel_family     = aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee
--     (anti_extension; rollout + future kneeling vs standing variants)
--   cable_crunch_family = bbbbbbbb-cccc-dddd-eeee-ffffffffffff
--     (anti_extension loaded; cable crunch + future variants)
--   pallof_family       = cccccccc-dddd-eeee-ffff-000000000001
--     (anti_rotation; Pallof + future variants like half-kneeling, banded)
--   woodchop_family     = dddddddd-eeee-ffff-0000-000000000001
--     (rotation; cable woodchop + future variants like reverse, low-to-high)
--   pushup_family       = eeeeeeee-ffff-0000-1111-000000000001
--     (push-up + incline + decline + future one-arm, archer, deficit)
--     NB: pike push-up does NOT share this family — different primary
--     pattern (vertical_push). Pike gets its own family below.
--   pike_pushup_family  = ffffffff-0000-1111-2222-000000000001
--     (vertical_push bodyweight; pike + future handstand push-up progression)
--   inverted_row_family = 00000000-1111-2222-3333-100000000001
--     (horizontal_pull bodyweight; inverted row + future variants)
--   face_pull_family    = 11111111-2222-3333-4444-100000000001
--     (rear delt / upper back; face pull + future variants like reverse fly)
--   walking_lunge_family = 22222222-3333-4444-5555-100000000001
--     (lunge_split walking; walking lunge + future variants like reverse,
--     deficit, overhead)
--
-- Exercise IDs (continuing aaaaaaaa-XXXX-... scheme):
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
  -- Anti-extension is the textbook example of this pattern: prevent lumbar
  -- extension under gravitational load while in a horizontal position.
  --
  -- Abs 1.0 — uncontested target (resisting extension is the abs' primary
  -- function).
  -- Obliques 0.5 — meaningful synergist; they also resist extension and
  -- contribute to maintaining the rigid line. Not 1.0 because they're
  -- secondary to the rectus abdominis here; side plank is where obliques
  -- are 1.0.
  -- Glutes 0.25 — keep hips from sagging. Stabilizer-tier; user notices
  -- glute fatigue on long planks. Per §2, 0.25 entries should be muscles
  -- "a user would notice fatiguing during a heavy session" — applies here.
  -- No shoulder/front_delt entry: forearms-down position offloads most
  -- shoulder work.
  '[
    {"muscle_id": "abs",      "weight": 1.0},
    {"muscle_id": "obliques", "weight": 0.5},
    {"muscle_id": "glutes",   "weight": 0.25}
  ]'::jsonb,
  'bodyweight', NULL, NULL, NULL,
  -- Load increments NULL — plank progression is duration, not added load.
  -- Future: weighted plank (plate on back) would be a separate row in this
  -- family with metric weight_x_reps_per_time or similar; needs schema
  -- work to support combined metrics. Tracked as TODO; not pressing.
  ARRAY['stability', 'hypertrophy'],
  -- 'stability' is the primary modality for anti-pattern core work.
  -- 'hypertrophy' included because long plank holds do produce abs
  -- hypertrophy; not the primary goal but real.
  'isolation', 'late',
  'time', FALSE, TRUE,
  -- progression_eligible = FALSE: time-based progression is captured by the
  -- metric, but the standard "load increment" progression doesn't apply.
  -- The recommender should treat duration goals as the progression, which
  -- needs progression_eligible semantics extended for time-metric exercises.
  -- Setting FALSE for now; if/when the recommender handles time-based
  -- progression natively, this can flip to TRUE.
  -- relative_to_bodyweight = TRUE: bodyweight IS the load.
  ARRAY[]::TEXT[],
  -- No demands tags. Plank doesn't require notable mobility or skill.
  -- Could argue lumbar_loading but the spinal-compression interpretation
  -- doesn't fit a horizontal anti-extension hold; skipping.
  '[]'::jsonb,
  '77777777-8888-9999-aaaa-bbbbbbbbbbbb',
  NULL,
  'mid',
  -- 'mid': there's no stretched or shortened position in an isometric hold.
  -- Could argue 'none' but per §8 "no clear loaded position" is for carries/
  -- conditioning where there's a different reason. Plank does have peak
  -- tension on the abs throughout the hold; 'mid' captures "not bias-
  -- programmable" without being 'none'.
  'system', FALSE
);

-- ─── 31. Side Plank ─────────────────────────────────────────────────────────
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
  'aaaaaaaa-0031-0000-0000-000000000001',
  'Side Plank',
  ARRAY['lateral plank', 'side bridge', 'forearm side plank'],
  'lifting',
  'anti_lateral_flexion', NULL, 'unilateral',
  -- Anti-lateral-flexion: resist gravity pulling the hip toward the floor.
  -- loading_type = 'unilateral' because each side is trained separately
  -- (one side per set), matching how BSS and walking lunge are unilateral.
  --
  -- Obliques 1.0 — uncontested target on side plank. The lateral fibers of
  -- the abdominal wall are doing the work.
  -- Abs 0.5 — meaningful synergist; rectus abdominis contributes to the
  -- rigid trunk.
  -- Glutes 0.25 — gluteus medius keeps the top hip from rotating down.
  -- Side delts 0.25 — supporting shoulder bears bodyweight. Unlike plank
  -- (forearms-down, both arms), side plank loads one shoulder more
  -- noticeably.
  '[
    {"muscle_id": "obliques",   "weight": 1.0},
    {"muscle_id": "abs",        "weight": 0.5},
    {"muscle_id": "glutes",     "weight": 0.25},
    {"muscle_id": "side_delts", "weight": 0.25}
  ]'::jsonb,
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
  -- Aliases include "hanging knee raise" deliberately — knee-tuck variant
  -- is a regression of this exercise but realistically users type "knee
  -- raise" when they mean either. If we add a separate knee-tuck row in
  -- batch 5, drop this alias from there.
  'lifting',
  'anti_extension', NULL, 'bilateral',
  -- Dynamic anti-extension. The "anti" framing applies because the abs
  -- contract to flex the spine while resisting the leg-weight tendency to
  -- extend it back; primary visible action is concentric flexion of the
  -- pelvis toward the ribs.
  --
  -- Abs 1.0 — uncontested target (especially lower abs via posterior
  -- pelvic tilt, when performed with that cue rather than just hip flexion).
  -- Hip flexors 0.5 — meaningful synergist; if the user just lifts straight
  -- legs without posterior tilt, hip flexors do most of the work. Listed
  -- as 0.5 not 1.0 because a properly cued HLR puts abs as the limiter.
  -- Forearms 0.5 — grip is genuinely challenged on hanging variants. After
  -- 8-10 reps the grip often gives out before the abs.
  -- Lats 0.25 — passive engagement to hold the dead hang shape; user
  -- notices lat fatigue on long sets.
  -- Obliques 0.25 — synergist for trunk stabilization; bumps to 0.5 if
  -- user does single-side variants but those are separate rows.
  '[
    {"muscle_id": "abs",         "weight": 1.0},
    {"muscle_id": "hip_flexors", "weight": 0.5},
    {"muscle_id": "forearms",    "weight": 0.5},
    {"muscle_id": "lats",        "weight": 0.25},
    {"muscle_id": "obliques",    "weight": 0.25}
  ]'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  -- Load increments per §5 "Bodyweight (loaded)" defaults. Loading is via
  -- ankle weights or a dumbbell between the feet.
  ARRAY['hypertrophy', 'stability'],
  'isolation', 'late',
  'weighted_bodyweight', TRUE, TRUE,
  -- weighted_bodyweight per §9: bodyweight that *can* be loaded.
  ARRAY['shoulder_flexion', 'grip_intensive'],
  -- shoulder_flexion: dead hang from a bar requires overhead reach.
  -- grip_intensive: cited above as a real limiter.
  '[]'::jsonb,
  '99999999-aaaa-bbbb-cccc-dddddddddddd',
  NULL,
  'stretched',
  -- 'stretched': peak tension at the bottom (legs fully extended, abs
  -- lengthened). Top is shortened, bottom is the loaded stretch.
  'system', FALSE
);

-- ─── 33. Ab Wheel Rollout ───────────────────────────────────────────────────
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
  'aaaaaaaa-0033-0000-0000-000000000001',
  'Ab Wheel Rollout',
  ARRAY['ab wheel', 'wheel rollout', 'ab roller'],
  'lifting',
  'anti_extension', NULL, 'bilateral',
  -- Dynamic anti-extension under stretch — the abs eccentrically resist
  -- spinal extension as the wheel rolls forward, then concentrically
  -- shorten to bring the body back. This is one of the most demanding
  -- anti-extension exercises because the abs' moment arm against gravity
  -- is longest at full extension.
  --
  -- Abs 1.0 — clear target.
  -- Lats 0.5 — meaningful synergist; the lats drive shoulder extension to
  -- pull the wheel back. Not just stabilizers — actively pulling.
  -- Obliques 0.5 — significant trunk stabilization demand.
  -- Triceps 0.25 — straight-arm position; tricep stabilizes elbow against
  -- buckling. User notices on long sets.
  -- Front_delts 0.25 — anterior shoulder stabilization at peak extension.
  '[
    {"muscle_id": "abs",         "weight": 1.0},
    {"muscle_id": "lats",        "weight": 0.5},
    {"muscle_id": "obliques",    "weight": 0.5},
    {"muscle_id": "triceps",     "weight": 0.25},
    {"muscle_id": "front_delts", "weight": 0.25}
  ]'::jsonb,
  'bodyweight', 'ab_wheel', NULL, NULL,
  -- equipment_primary = bodyweight (no external load); equipment_specific
  -- captures the wheel itself as required equipment. NULL increments —
  -- progression is via ROM (knees → standing) and reps, not added load.
  ARRAY['hypertrophy', 'stability'],
  'isolation', 'late',
  'bodyweight_x_reps', TRUE, TRUE,
  -- bodyweight_x_reps not weighted_bodyweight: ab wheel doesn't have a
  -- standard loading method. Reps + ROM is the progression.
  ARRAY['shoulder_flexion'],
  -- shoulder_flexion: full rollout requires overhead-direction shoulder
  -- ROM. Users with limited shoulder mobility often can't get to full
  -- extension. No 'overhead_rom' tag because that implies vertical
  -- pressing posture; this is horizontal but flexed.
  '[]'::jsonb,
  'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
  NULL,
  'stretched',
  -- 'stretched': peak tension at full extension (arms extended, abs
  -- maximally lengthened against gravitational moment).
  'system', FALSE
);

-- ─── 34. Cable Crunch ───────────────────────────────────────────────────────
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
  'aaaaaaaa-0034-0000-0000-000000000001',
  'Cable Crunch',
  ARRAY['kneeling cable crunch', 'rope crunch', 'cable ab crunch'],
  'lifting',
  'anti_extension', NULL, 'bilateral',
  -- Cable crunch is loaded spinal flexion. Categorized as anti_extension
  -- here because (a) the abs' primary function is preventing/reversing
  -- spinal extension, (b) the recommender groups by primary pattern, and
  -- (c) keeping all loaded-abs work under one pattern is cleaner than
  -- splitting "spinal flexion" off as its own pattern. The anti-pattern
  -- naming is functional (what the abs are doing) not directional.
  --
  -- Abs 1.0 — clear target. Loaded spinal flexion is the highest-tension
  -- direct ab-targeting exercise available.
  -- Obliques 0.25 — minor synergist on a clean cable crunch (no rotation).
  -- No hip_flexor entry: kneeling position with hips fixed prevents
  -- significant hip flexion contribution, unlike sit-ups or HLR.
  '[
    {"muscle_id": "abs",      "weight": 1.0},
    {"muscle_id": "obliques", "weight": 0.25}
  ]'::jsonb,
  'cable', NULL, 5.00, 2.50,
  -- 5.00 default per §5 cable; some gyms have 10-lb-only cable stacks,
  -- author override possible per-gym (not at exercise level).
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'bbbbbbbb-cccc-dddd-eeee-ffffffffffff',
  '{"grip": "neutral"}'::jsonb,
  -- grip neutral for rope attachment (most common). Other attachments
  -- (straight bar overhead) would be variation_attributes-distinct but
  -- not separate rows.
  'shortened',
  -- 'shortened': peak tension at the contracted (crunched) position.
  -- Conventions §8 explicitly cites cable kickback as 'shortened'; same
  -- logic — peak-contraction loaded isolation.
  'system', FALSE
);

-- ─── 35. Pallof Press ───────────────────────────────────────────────────────
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
  'aaaaaaaa-0035-0000-0000-000000000001',
  'Pallof Press',
  ARRAY['pallof', 'standing pallof press', 'cable anti-rotation press'],
  'lifting',
  'anti_rotation', NULL, 'unilateral',
  -- Anti-rotation: cable pulls laterally, lifter resists trunk rotation.
  -- loading_type = unilateral because each side is trained separately
  -- (cable always pulls from one side; user faces the other direction
  -- for the second side).
  --
  -- Obliques 1.0 — primary anti-rotation muscles. Both internal and
  -- external obliques resist the trunk rotating toward the cable.
  -- Abs 0.5 — meaningful synergist; rectus contributes to overall trunk
  -- bracing.
  -- Front_delts 0.25 — pressing the cable handle out to arm's length is
  -- a brief shoulder action, but the movement is held isometric most
  -- of the rep (the press itself isn't the point; the resistance to
  -- rotation while pressed is). Stabilizer-tier.
  '[
    {"muscle_id": "obliques",    "weight": 1.0},
    {"muscle_id": "abs",         "weight": 0.5},
    {"muscle_id": "front_delts", "weight": 0.25}
  ]'::jsonb,
  'cable', NULL, 5.00, 2.50,
  ARRAY['stability'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'cccccccc-dddd-eeee-ffff-000000000001',
  '{"stance": "shoulder_width"}'::jsonb,
  'mid',
  -- 'mid' for anti-rotation isometric work. Same logic as plank.
  'system', FALSE
);

-- ─── 36. Cable Woodchop ─────────────────────────────────────────────────────
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
  'aaaaaaaa-0036-0000-0000-000000000001',
  'Cable Woodchop',
  ARRAY['woodchop', 'cable chop', 'high-to-low woodchop'],
  -- High-to-low is the canonical default. Reverse (low-to-high) and
  -- horizontal woodchop are separate rows in this family in batch 5+.
  'lifting',
  'rotation', NULL, 'unilateral',
  -- Active rotation pattern (unlike Pallof which is anti-rotation).
  -- unilateral: trained one side at a time.
  --
  -- Obliques 1.0 — prime movers in trunk rotation.
  -- Abs 0.5 — meaningful synergist for trunk bracing.
  -- Lats 0.5 — drives the diagonal pulling action; on a high-to-low
  -- woodchop the cable comes from above and the lats pull it down and
  -- across. Not stabilizer-tier — actively contributing force.
  -- Front_delts 0.25 — minor shoulder stabilization across the diagonal.
  '[
    {"muscle_id": "obliques",    "weight": 1.0},
    {"muscle_id": "abs",         "weight": 0.5},
    {"muscle_id": "lats",        "weight": 0.5},
    {"muscle_id": "front_delts", "weight": 0.25}
  ]'::jsonb,
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
  -- Push-up is the bodyweight equivalent of bench press. Same primary
  -- pattern, same target muscles, different loading shape (the user is
  -- the resistance, ground is fixed).
  --
  -- Chest 1.0 — clear target, mirroring bench press.
  -- Front_delts 0.5 — same as flat bench.
  -- Triceps 0.5 — same as flat bench.
  -- Abs 0.25 — anti-extension stabilization throughout the rep; on bench
  -- press the abs do less because the bench supports the body. On push-up
  -- the user IS the plank, so abs do more work. Worth tracking; user
  -- notices on long sets.
  -- Obliques 0.25 — same logic as abs; both contribute to the rigid line.
  '[
    {"muscle_id": "chest",       "weight": 1.0},
    {"muscle_id": "front_delts", "weight": 0.5},
    {"muscle_id": "triceps",     "weight": 0.5},
    {"muscle_id": "abs",         "weight": 0.25},
    {"muscle_id": "obliques",    "weight": 0.25}
  ]'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  -- Loaded via weight vest or plate on back. Per §5 bodyweight (loaded)
  -- defaults.
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  -- main_compound for bodyweight populations (home gym users). When a
  -- user has bench available, push-ups become accessory; the recommender
  -- handles role override at usage time per §7.
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY['shoulder_flexion'],
  -- shoulder_flexion captures the overhead-direction reach at top of
  -- push-up. Less than full overhead, but worth flagging for users with
  -- shoulder mobility constraints.
  '[]'::jsonb,
  'eeeeeeee-ffff-0000-1111-000000000001',
  '{"incline": "flat"}'::jsonb,
  -- 'incline' attribute used for push-up family (incline = hands elevated
  -- = easier; decline = feet elevated = harder). 'flat' for floor push-up.
  'stretched',
  -- 'stretched' at the bottom (chest near floor, pecs stretched).
  'system', FALSE
);

-- ─── 38. Incline Push-Up ────────────────────────────────────────────────────
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
  'aaaaaaaa-0038-0000-0000-000000000001',
  'Incline Push-Up',
  ARRAY['hands-elevated push-up', 'wall push-up', 'bench push-up'],
  -- Aliases include "wall push-up" — the steepest incline (hands on wall)
  -- is the same exercise; angle is on a continuum. If the recommender
  -- needs to distinguish wall vs bench specifically, that's an angle
  -- variation attribute later.
  'lifting',
  'horizontal_push', NULL, 'bilateral',
  -- Same pattern as flat push-up; less load fraction because the body's
  -- center of mass is higher relative to the hands. Functionally a
  -- regression — easier than flat push-up.
  --
  -- Same muscle weightings as flat push-up. The DIFFERENCE is total load,
  -- not load distribution. Per §1, equipment doesn't change here (still
  -- bodyweight) and muscle weightings don't change — but the conventions
  -- §1 example table explicitly cites "Bench press at exactly 30° vs 45°
  -- incline — Separate rows" because incline shifts emphasis.
  --
  -- Push-up incline is different from bench-press incline: bench-press
  -- incline shifts emphasis toward upper chest / front delts. Push-up
  -- incline doesn't redistribute — it just reduces total resistance.
  -- BUT we still author as separate rows because:
  -- (a) demands differ (incline push-up is accessible to a wider mobility
  --     and strength range)
  -- (b) it's a regression in the substitution graph
  -- (c) progression-ladder authoring per the amended §12 explicitly calls
  --     for separate variants at each difficulty tier
  --
  -- Identical muscle profile to flat push-up.
  '[
    {"muscle_id": "chest",       "weight": 1.0},
    {"muscle_id": "front_delts", "weight": 0.5},
    {"muscle_id": "triceps",     "weight": 0.5},
    {"muscle_id": "abs",         "weight": 0.25},
    {"muscle_id": "obliques",    "weight": 0.25}
  ]'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  ARRAY['strength', 'hypertrophy'],
  'accessory', 'anywhere',
  -- accessory not main_compound: this is a regression variant. If a user
  -- can't do flat push-ups yet, this is their main pushing movement and
  -- the program would override the role at usage time.
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY[]::TEXT[],
  -- No shoulder_flexion demand at this level; the angle reduces the
  -- ROM strain.
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
  -- DECISION: pike push-up gets primary = vertical_push, NOT horizontal_push.
  -- The hip-piked position rotates the press direction toward vertical;
  -- mechanically it's the bodyweight equivalent of OHP, not bench press.
  -- This is why it gets a different family (pike_pushup_family) from the
  -- standard push-up family — different primary pattern means different
  -- substitute-graph behavior per §1.
  --
  -- Front_delts 1.0 — clear target on a vertical-push variant, mirroring
  -- standing OHP.
  -- Triceps 0.5 — same as OHP.
  -- Traps_upper 0.5 — same as OHP (upward rotation demand at top).
  -- Chest 0.25 — minor contribution at the bottom of the press, much less
  -- than push-up.
  -- Abs 0.25 — anti-extension stabilization (same as push-up) plus the
  -- piked position adds some core demand.
  '[
    {"muscle_id": "front_delts", "weight": 1.0},
    {"muscle_id": "triceps",     "weight": 0.5},
    {"muscle_id": "traps_upper", "weight": 0.5},
    {"muscle_id": "chest",       "weight": 0.25},
    {"muscle_id": "abs",         "weight": 0.25}
  ]'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  ARRAY['strength', 'hypertrophy'],
  'secondary_compound', 'anywhere',
  -- secondary_compound: pike push-up is the bodyweight stepping stone
  -- toward handstand push-up (future row in this family). For users with
  -- access to OHP, pike is an accessory; for bodyweight-only users it's
  -- a main vertical push. Role override at usage time.
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY['overhead_rom', 'shoulder_flexion'],
  -- overhead_rom: the piked position approximates an overhead press
  -- direction; users with limited shoulder ROM struggle.
  '[]'::jsonb,
  'ffffffff-0000-1111-2222-000000000001',
  NULL,
  'stretched',
  -- 'stretched' at the bottom (head approaches floor, front delts
  -- maximally lengthened in the pressing direction).
  'system', FALSE
);

-- ─── 40. Inverted Row ───────────────────────────────────────────────────────
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
  'aaaaaaaa-0040-0000-0000-000000000001',
  'Inverted Row',
  ARRAY['bodyweight row', 'australian pull-up', 'horizontal pull-up'],
  'lifting',
  'horizontal_pull', NULL, 'bilateral',
  -- Inverted row is the bodyweight horizontal-pull primary. Mirrors
  -- barbell row mechanically; user hangs under a bar (or rings) and
  -- pulls chest to bar.
  --
  -- Lats 1.0 — clear target on horizontal pull, same as BB row.
  -- Rhomboids 0.5 — same as BB row.
  -- Mid/lower traps 0.5 — same as BB row.
  -- Biceps 0.5 — same as BB row.
  -- Rear_delts 0.25 — same logic as BB row (synergist on horizontal pull,
  -- not target-tier).
  -- Abs 0.25 — anti-extension stabilization while horizontal; user is
  -- effectively in a reverse-plank position throughout the rep.
  '[
    {"muscle_id": "lats",            "weight": 1.0},
    {"muscle_id": "rhomboids",       "weight": 0.5},
    {"muscle_id": "traps_mid_lower", "weight": 0.5},
    {"muscle_id": "biceps",          "weight": 0.5},
    {"muscle_id": "rear_delts",      "weight": 0.25},
    {"muscle_id": "abs",             "weight": 0.25}
  ]'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  -- Loaded via weight vest or plate on hips. Body angle is also a
  -- progression knob (steeper = harder), but at the row family level
  -- those are separate variants in batch 5+.
  ARRAY['strength', 'hypertrophy'],
  'secondary_compound', 'anywhere',
  -- secondary_compound for bodyweight users; accessory when BB row is
  -- in the program. Role override at usage time.
  'weighted_bodyweight', TRUE, TRUE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '00000000-1111-2222-3333-100000000001',
  '{"grip": "pronated"}'::jsonb,
  -- pronated default (overhand grip on a bar). Supinated and neutral
  -- variants would be separate rows in this family.
  'stretched',
  -- 'stretched' at the bottom (arms extended, lats lengthened).
  'system', FALSE
);

-- ─── 41. Sumo Deadlift ──────────────────────────────────────────────────────
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
  'aaaaaaaa-0041-0000-0000-000000000001',
  'Sumo Deadlift',
  ARRAY['sumo DL', 'wide-stance deadlift', 'sumo pull'],
  'lifting',
  'hinge', 'squat', 'bilateral',
  -- DECISION (consistent with batch 2 low-bar squat reasoning):
  -- movement_pattern_secondary = 'squat' on sumo DL because the wider
  -- stance and more upright torso make sumo more knee-extension-driven
  -- than conventional. Conventional DL has secondary = NULL (pure hinge);
  -- sumo gets the squat secondary to flag the increased quad contribution
  -- and shorter hip moment arm. This mirrors low-bar back squat (squat
  -- primary, hinge secondary) — same trick in the opposite direction.
  --
  -- Quads 1.0 — bumped to target-tier on sumo. The wide stance and upright
  -- torso make this much more quad-driven than conventional DL.
  -- Glutes 1.0 — wide stance + external hip rotation puts glutes (esp.
  -- glute max + medius) at target-tier. Per §2 conventions: "glutes at
  -- 1.0 only on hip-dominant variants (low-bar wide-stance, sumo)" —
  -- sumo DL is the explicit example.
  -- Adductors 1.0 — sumo's wide-stance external rotation makes adductors
  -- a true target. This is one of the few exercises where adductors hit
  -- 1.0; conventional DL has them at 0.5 max.
  -- Hamstrings 0.5 — still meaningful synergist but less than conventional
  -- (the more upright torso reduces hip-hinge moment).
  -- Lower_back 0.25 — still loaded but less than conventional (more
  -- upright torso = less spinal flexion moment).
  -- Forearms 0.5 — heavy DL grip demand same as conventional.
  -- Traps_upper 0.5 — isometric shrug to keep bar position, same as
  -- conventional.
  '[
    {"muscle_id": "quads",       "weight": 1.0},
    {"muscle_id": "glutes",      "weight": 1.0},
    {"muscle_id": "adductors",   "weight": 1.0},
    {"muscle_id": "hamstrings",  "weight": 0.5},
    {"muscle_id": "forearms",    "weight": 0.5},
    {"muscle_id": "traps_upper", "weight": 0.5},
    {"muscle_id": "lower_back",  "weight": 0.25}
  ]'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['hip_internal_rotation', 'grip_intensive'],
  -- DECISION: hip_INTERNAL_rotation flagged as the demand, NOT hip_external.
  -- Sumo stance requires the femurs to externally rotate AT THE HIP, which
  -- means the joint is positioned in external rotation — but the mobility
  -- demand is on the internal rotators (which must lengthen and the
  -- adductors must allow the wide stance). Anatomical convention can be
  -- argued either way; using hip_internal_rotation matches the existing
  -- §3 demands vocabulary which has hip_internal_rotation. If the spec
  -- ever adds hip_external_rotation, revisit. Open to feedback.
  --
  -- ankle_dorsiflexion: NOT included. Sumo's wide stance and upright
  -- torso reduce ankle ROM demand significantly compared to high-bar
  -- squat. Conventional DL also doesn't have it.
  '[]'::jsonb,
  '66666666-6666-6666-6666-666666666666',
  '{"stance": "sumo"}'::jsonb,
  -- stance = sumo per §4 vocabulary. Conventional DL has stance = conventional.
  'stretched',
  'system', FALSE
);

-- ─── 42. Face Pull ──────────────────────────────────────────────────────────
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
  'aaaaaaaa-0042-0000-0000-000000000001',
  'Face Pull',
  ARRAY['cable face pull', 'rope face pull', 'high face pull'],
  'lifting',
  'horizontal_pull', NULL, 'bilateral',
  -- horizontal_pull is the primary; face pull is mechanically a horizontal
  -- pull (cable-to-face, elbows high) with significant external rotation
  -- demand. Distinct from row family because the muscle bias is rear delts
  -- and upper back, not lats.
  --
  -- Rear_delts 1.0 — clear target. Face pull is one of the few exercises
  -- that loads rear delts as the primary; everything else in the DB has
  -- rear_delts at 0.25 or 0.5.
  -- Mid/lower traps 1.0 — also target-tier. Face pull is uniquely good
  -- for these because the high-elbow path forces scapular retraction and
  -- depression simultaneously.
  -- Rhomboids 0.5 — meaningful synergist for scap retraction.
  -- Side_delts 0.25 — minor contribution at the abducted-arm position.
  -- Forearms 0.25 — grip on rope.
  --
  -- DECISION: NO biceps entry. Unlike rows, face pull keeps the elbow
  -- relatively neutral (~90°) without significant elbow flexion change
  -- through the rep. Biceps are bystanders here.
  '[
    {"muscle_id": "rear_delts",      "weight": 1.0},
    {"muscle_id": "traps_mid_lower", "weight": 1.0},
    {"muscle_id": "rhomboids",       "weight": 0.5},
    {"muscle_id": "side_delts",      "weight": 0.25},
    {"muscle_id": "forearms",        "weight": 0.25}
  ]'::jsonb,
  'cable', NULL, 5.00, 2.50,
  ARRAY['hypertrophy', 'stability'],
  'accessory', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['shoulder_external_rotation'],
  -- shoulder_external_rotation: face pull's signature demand. Pulling the
  -- rope toward the face with elbows high and ends-of-rope flaring
  -- requires external rotation at end-range. This is the primary reason
  -- face pull is programmed for shoulder health, not just rear delt size.
  '[]'::jsonb,
  '11111111-2222-3333-4444-100000000001',
  '{"grip": "neutral"}'::jsonb,
  'shortened',
  -- 'shortened': peak tension at the contracted position (rope at face,
  -- scaps fully retracted). Same loaded-position profile as lateral
  -- raise — peak-contraction isolation-bias work.
  'system', FALSE
);

-- ─── 43. Walking Lunge — Dumbbell ───────────────────────────────────────────
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
  'aaaaaaaa-0043-0000-0000-000000000001',
  'Walking Lunge — Dumbbell',
  ARRAY['walking lunge', 'DB walking lunge', 'dumbbell lunge'],
  'lifting',
  'lunge_split', NULL, 'alternating',
  -- DECISION: loading_type = 'alternating' (not 'unilateral'). Walking
  -- lunge alternates legs continuously through a set; BSS does one full
  -- side, then the other. The schema enum has both values for this
  -- distinction.
  --
  -- lunge_split is the only exercise so far using this pattern as primary
  -- (BSS has it primary, but BSS is split-stance; walking is locomotive).
  -- Both legitimately fit lunge_split per the enum.
  --
  -- Quads 1.0 — primary target on each working leg.
  -- Glutes 1.0 — long stride length on walking lunge makes glutes a
  -- target, similar to sumo DL. Shorter strides drop this to 0.5; the
  -- default is long-stride (more glute, more hip flexor stretch).
  -- Hamstrings 0.5 — meaningful synergist on the lengthened lead leg.
  -- Adductors 0.5 — same as BSS reasoning.
  -- Hip flexors 0.5 — UNIQUE TO WALKING LUNGE in the lower-body lifts:
  -- the trail leg's hip flexor is dynamically stretched and then must
  -- contract to drive the leg forward to the next step. This is one of
  -- the few exercises where hip_flexors hit 0.5; most have them omitted.
  -- Abs 0.25 — anti-rotation/anti-extension during dumbbells-at-sides
  -- locomotion.
  '[
    {"muscle_id": "quads",       "weight": 1.0},
    {"muscle_id": "glutes",      "weight": 1.0},
    {"muscle_id": "hamstrings",  "weight": 0.5},
    {"muscle_id": "adductors",   "weight": 0.5},
    {"muscle_id": "hip_flexors", "weight": 0.5},
    {"muscle_id": "abs",         "weight": 0.25}
  ]'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy', 'stability'],
  'secondary_compound', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['unilateral_balance', 'hip_flexion', 'deep_knee_flexion'],
  '[]'::jsonb,
  '22222222-3333-4444-5555-100000000001',
  '{"stance": "split"}'::jsonb,
  -- stance: split (per §4 vocabulary; same as BSS). Future barbell walking
  -- lunge would be a separate row in this family.
  'stretched',
  -- 'stretched' at the bottom of each step (deep lunge; quads and trail-
  -- leg hip flexor at peak length).
  'system', FALSE
);

-- ─── 44. Seated Calf Raise ──────────────────────────────────────────────────
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
  'aaaaaaaa-0044-0000-0000-000000000001',
  'Seated Calf Raise',
  ARRAY['seated calf', 'machine seated calf raise', 'soleus raise'],
  'lifting',
  'ankle_plantarflexion', NULL, 'bilateral',
  -- Uses the new enum value from the migration (was previously stubbed in
  -- the enum gap; standing calf raise is being updated to this in the
  -- same PR cycle). NO TODO(schema) needed — the enum has the right value
  -- now.
  --
  -- Calves 1.0 — uncontested target. Seated position bends the knee,
  -- which slackens the gastrocnemius (which crosses the knee) and shifts
  -- emphasis to the soleus (which doesn't). This is the complement to
  -- standing calf raise — same family, different muscle bias.
  -- Per spec §18 the muscle list has only 'calves' (no gastroc/soleus
  -- split), so the muscle weighting is the same as standing calf raise;
  -- the actual emphasis difference is captured in equipment_specific
  -- (seated_calf_raise vs standing_calf_raise) and in family-level
  -- substitution semantics, NOT in muscle weights. If the muscle list
  -- ever splits gastroc/soleus, revisit.
  '[
    {"muscle_id": "calves", "weight": 1.0}
  ]'::jsonb,
  'machine', 'seated_calf_raise', 10.00, 5.00,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '33333333-4444-5555-6666-777777777777',
  -- Same family as standing calf raise (batch 3).
  NULL,
  'shortened',
  -- 'shortened': peak tension at full plantarflexion (toes pointed). Same
  -- profile as standing calf raise.
  'system', FALSE
);


-- =============================================================================
-- Substitution graph — batch 4 + cross-batch reciprocals
-- =============================================================================
-- Directional. Targeting 2-4 substitutes per exercise per conventions §10.
-- Cross-batch refs:
--   pull_up               = aaaaaaaa-0002-0000-0000-000000000001  (batch 1)
--   bb_bench              = aaaaaaaa-0012-0000-0000-000000000001  (batch 2)
--   db_bench              = aaaaaaaa-0013-0000-0000-000000000001  (batch 2)
--   bb_row                = aaaaaaaa-0014-0000-0000-000000000001  (batch 2)
--   chest_supported_row   = aaaaaaaa-0015-0000-0000-000000000001  (batch 2)
--   bb_ohp                = aaaaaaaa-0016-0000-0000-000000000001  (batch 2)
--   db_ohp                = aaaaaaaa-0017-0000-0000-000000000001  (batch 2)
--   conventional_dl       = aaaaaaaa-0009-0000-0000-000000000001  (batch 2)
--   rdl                   = aaaaaaaa-0010-0000-0000-000000000001  (batch 2)
--   bulgarian_split_squat = aaaaaaaa-0004-0000-0000-000000000001  (batch 1)
--   leg_press             = aaaaaaaa-0005-0000-0000-000000000001  (batch 1)
--   lat_pulldown          = aaaaaaaa-0022-0000-0000-000000000001  (batch 3)
--   cable_row             = aaaaaaaa-0023-0000-0000-000000000001  (batch 3)
--   dip                   = aaaaaaaa-0020-0000-0000-000000000001  (batch 3)
--   standing_calf_raise   = aaaaaaaa-0026-0000-0000-000000000001  (batch 3)

INSERT INTO public.exercise_substitutes (exercise_id, substitute_id, similarity_score, reason) VALUES
  -- ── 30. Plank ────────────────────────────────────────────────────────────
  -- Within-family progression target: side plank (different anti-pattern
  -- but same isometric bracing skill). Cross-family: ab wheel as the
  -- progression direction (dynamic anti-extension with greater demand).
  ('aaaaaaaa-0030-0000-0000-000000000001', 'aaaaaaaa-0033-0000-0000-000000000001', 0.55, 'progression'),
  ('aaaaaaaa-0030-0000-0000-000000000001', 'aaaaaaaa-0031-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0030-0000-0000-000000000001', 'aaaaaaaa-0032-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),

  -- ── 31. Side Plank ───────────────────────────────────────────────────────
  ('aaaaaaaa-0031-0000-0000-000000000001', 'aaaaaaaa-0030-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0031-0000-0000-000000000001', 'aaaaaaaa-0035-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),
  -- side plank → Pallof: both work obliques, different pattern.

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
  -- Pallof has limited substitutes — it's the only anti_rotation primary
  -- exercise in v1 so far. Side plank is the closest (anti_lateral_flexion
  -- shares stabilization purpose).
  ('aaaaaaaa-0035-0000-0000-000000000001', 'aaaaaaaa-0031-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0035-0000-0000-000000000001', 'aaaaaaaa-0036-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  -- Pallof ↔ woodchop: same equipment, opposite pattern (anti vs active
  -- rotation). Reasonable substitute when one is unavailable.

  -- ── 36. Cable Woodchop ───────────────────────────────────────────────────
  ('aaaaaaaa-0036-0000-0000-000000000001', 'aaaaaaaa-0035-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0036-0000-0000-000000000001', 'aaaaaaaa-0034-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),

  -- ── 37. Push-Up ──────────────────────────────────────────────────────────
  -- Push-up substitutes: family members (incline, pike) + cross-family
  -- (BB bench as the loaded equivalent / progression once weighted vest
  -- maxes out).
  ('aaaaaaaa-0037-0000-0000-000000000001', 'aaaaaaaa-0038-0000-0000-000000000001', 0.85, 'regression'),
  ('aaaaaaaa-0037-0000-0000-000000000001', 'aaaaaaaa-0012-0000-0000-000000000001', 0.75, 'progression'),
  -- Push-up → BB bench is a progression because BB bench has higher
  -- absolute load potential. Push-up is a regression of bench.
  ('aaaaaaaa-0037-0000-0000-000000000001', 'aaaaaaaa-0013-0000-0000-000000000001', 0.70, 'progression'),
  -- DB bench progression too (less load ceiling than BB but still
  -- progressable beyond a weighted-vest push-up).

  -- ── 38. Incline Push-Up ──────────────────────────────────────────────────
  ('aaaaaaaa-0038-0000-0000-000000000001', 'aaaaaaaa-0037-0000-0000-000000000001', 0.85, 'progression'),
  -- Incline → flat: progression direction.
  ('aaaaaaaa-0038-0000-0000-000000000001', 'aaaaaaaa-0012-0000-0000-000000000001', 0.55, 'progression'),

  -- ── 39. Pike Push-Up ─────────────────────────────────────────────────────
  -- Pike push-up substitutes: bodyweight progression family + cross-family
  -- (OHP as the loaded equivalent).
  ('aaaaaaaa-0039-0000-0000-000000000001', 'aaaaaaaa-0016-0000-0000-000000000001', 0.70, 'progression'),
  -- Pike → BB OHP: progression with external load.
  ('aaaaaaaa-0039-0000-0000-000000000001', 'aaaaaaaa-0017-0000-0000-000000000001', 0.65, 'progression'),
  -- Pike → DB OHP: similar progression.
  ('aaaaaaaa-0039-0000-0000-000000000001', 'aaaaaaaa-0037-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),

  -- ── 40. Inverted Row ─────────────────────────────────────────────────────
  ('aaaaaaaa-0040-0000-0000-000000000001', 'aaaaaaaa-0014-0000-0000-000000000001', 0.75, 'progression'),
  -- Inverted row → BB row: progression to loaded equivalent.
  ('aaaaaaaa-0040-0000-0000-000000000001', 'aaaaaaaa-0015-0000-0000-000000000001', 0.65, 'progression'),
  -- Inverted row → chest-supported DB row: similar progression.
  ('aaaaaaaa-0040-0000-0000-000000000001', 'aaaaaaaa-0023-0000-0000-000000000001', 0.65, 'progression'),
  -- Inverted row → seated cable row: similar progression.

  -- Reciprocal: BB row, DB row, cable row → inverted row as regression.
  -- These add OUTGOING edges to existing batch-2/3 rows — non-destructive
  -- inserts, not updates.
  ('aaaaaaaa-0014-0000-0000-000000000001', 'aaaaaaaa-0040-0000-0000-000000000001', 0.65, 'regression'),
  ('aaaaaaaa-0015-0000-0000-000000000001', 'aaaaaaaa-0040-0000-0000-000000000001', 0.65, 'regression'),
  ('aaaaaaaa-0023-0000-0000-000000000001', 'aaaaaaaa-0040-0000-0000-000000000001', 0.55, 'regression'),

  -- Reciprocal: bench → push-up as regression.
  ('aaaaaaaa-0012-0000-0000-000000000001', 'aaaaaaaa-0037-0000-0000-000000000001', 0.65, 'regression'),
  ('aaaaaaaa-0013-0000-0000-000000000001', 'aaaaaaaa-0037-0000-0000-000000000001', 0.65, 'regression'),

  -- Reciprocal: OHP → pike push-up as regression.
  ('aaaaaaaa-0016-0000-0000-000000000001', 'aaaaaaaa-0039-0000-0000-000000000001', 0.60, 'regression'),
  ('aaaaaaaa-0017-0000-0000-000000000001', 'aaaaaaaa-0039-0000-0000-000000000001', 0.60, 'regression'),

  -- ── 41. Sumo Deadlift ────────────────────────────────────────────────────
  -- Same family as conventional DL.
  ('aaaaaaaa-0041-0000-0000-000000000001', 'aaaaaaaa-0009-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  -- Both barbell deadlifts; the "different equipment" reason is loose
  -- here (same equipment, different stance) — closer to "same_muscles
  -- _different_pattern" actually. Going with same_pattern_different_
  -- equipment because the substitute_reason enum has no "same_pattern_
  -- different_stance" value, and stance IS the equipment-equivalent
  -- variation here. Open to feedback.
  ('aaaaaaaa-0041-0000-0000-000000000001', 'aaaaaaaa-0010-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  -- Sumo → RDL: similar muscle pool, different pattern emphasis.
  ('aaaaaaaa-0041-0000-0000-000000000001', 'aaaaaaaa-0006-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  -- Sumo → low-bar back squat: closer than to high-bar (both are wide-
  -- stance hip-dominant lifts).

  -- Reciprocal: conventional DL → sumo as same-family alternate.
  ('aaaaaaaa-0009-0000-0000-000000000001', 'aaaaaaaa-0041-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),

  -- ── 42. Face Pull ────────────────────────────────────────────────────────
  -- Face pull substitutes are tricky — it's the only rear-delt-target
  -- exercise in v1 so far. Closest alternatives are the upper-back row
  -- variants (different muscle bias but same general pattern direction).
  ('aaaaaaaa-0042-0000-0000-000000000001', 'aaaaaaaa-0015-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),
  -- Face pull → chest-supported DB row: shares rear delts and mid traps.
  ('aaaaaaaa-0042-0000-0000-000000000001', 'aaaaaaaa-0023-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),

  -- ── 43. Walking Lunge — DB ───────────────────────────────────────────────
  ('aaaaaaaa-0043-0000-0000-000000000001', 'aaaaaaaa-0004-0000-0000-000000000001', 0.75, 'same_pattern_different_equipment'),
  -- Walking lunge → BSS: both lunge_split, both unilateral-tier, same
  -- equipment family. Strong substitute.
  ('aaaaaaaa-0043-0000-0000-000000000001', 'aaaaaaaa-0001-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),
  -- Walking lunge → high-bar squat: cross-pattern fallback.
  ('aaaaaaaa-0043-0000-0000-000000000001', 'aaaaaaaa-0008-0000-0000-000000000001', 0.55, 'regression'),
  -- Walking lunge → goblet squat: regression direction (lighter load,
  -- bilateral, easier balance).

  -- Reciprocal: BSS → walking lunge as same-pattern alternate.
  ('aaaaaaaa-0004-0000-0000-000000000001', 'aaaaaaaa-0043-0000-0000-000000000001', 0.75, 'same_pattern_different_equipment'),

  -- ── 44. Seated Calf Raise ────────────────────────────────────────────────
  -- Same family as standing calf raise — they're complements (gastroc vs
  -- soleus emphasis). Per §10 they're not really regression/progression
  -- of each other; they're rotation targets.
  ('aaaaaaaa-0044-0000-0000-000000000001', 'aaaaaaaa-0026-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),

  -- Reciprocal: standing calf raise → seated as family alternate.
  ('aaaaaaaa-0026-0000-0000-000000000001', 'aaaaaaaa-0044-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment');
