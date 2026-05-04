-- =============================================================================
-- Seed Exercises — Batch 3 (12 exercises: lifting library completion)
-- =============================================================================
-- Purpose: close major coverage gaps in the lifting domain after batch 2.
-- After this batch the DB has 29 exercises (batch 1: 5, batch 2: 12, batch 3:
-- 12). Conventions §12 caps v1 at ~50, leaving ~20 slots for batch 4+.
--
-- Mix:
--   Push completion
--    18.  Incline Barbell Bench Press
--    19.  Incline Dumbbell Bench Press
--    20.  Dip (parallel-bar, chest-bias forward lean)
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
-- Conventions adhered to (see docs/exercise_authoring_conventions.md):
--   - §1: variations are separate rows. Inclines join bench_family. Chin-up
--     joins pullup_family with grip: supinated. Hammer curl gets its own
--     family (different muscle weighting from BB curl — brachialis/forearm
--     bias).
--   - §2: muscle-weighting discipline. 1.0 only for clear targets. Surfaced
--     decisions inline where judgment was required (chin-up biceps, dip
--     chest, etc.).
--   - §3: demands drawn from the closed vocabulary. No new tags introduced.
--   - §4: variation_attributes uses established keys only.
--   - §5: all load_increment values in lbs.
--   - §6: 2-4 aliases per exercise; no duplicates of name field.
--   - §10: directed substitutes; cross-batch refs use batch-1 / batch-2 UUIDs.
--
-- Decisions confirmed in chat before drafting / revised at v2:
--   - Dip authored as TRIPCEPS-BIAS (upright torso) default per v2 review;
--     chest-bias forward-lean variant would be a separate row in same family.
--     Reasoning: typical commercial gym geometry forces upright torso, making
--     triceps-bias the realistic default. (v1 had chest-bias; revised in v2.)
--   - Chin-up biceps at 1.0 (supinated grip → biceps co-limit with lats).
--   - Hammer curl gets its own row (not folded into BB curl aliases).
--   - Lat pulldown is NOT a regression of pull-up; treated as
--     same_pattern_different_equipment.
--   - Five exercises (leg curl, leg extension, calf raise, BB curl, tricep
--     pushdown) use awkward movement_pattern values pending a schema enum
--     extension. TODO(schema) comments inline; followup tracked in TODO.md.
--
-- All `progression_eligible` = TRUE.
-- All `authored_by` = 'system', `verified` = FALSE — pending review.
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
-- Exercise IDs (continuing aaaaaaaa-XXXX-... scheme):
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
  -- DECISION (surfaced for confirmation): movement_pattern_primary stays
  -- 'horizontal_push' even at 30-45° incline. The schema's available patterns
  -- are horizontal_push and vertical_push; an incline press is mechanically
  -- between the two but closer to horizontal_push for muscle action (chest
  -- still primary, not delts). Going vertical_push would mis-categorize this
  -- alongside OHP. If a "diagonal_push" pattern is later added, revisit.
  --
  -- Chest 1.0 — still the target on incline (specifically upper chest fibers,
  -- but at our muscle-id resolution it's just 'chest').
  -- Front_delts 0.5 → could argue 1.0 here: incline shifts noticeable load
  -- onto front delts, and on a steep incline (45°+) some lifters' delts
  -- co-limit with chest. Sticking with 0.5 per §2 default-to-fewer-1.0s,
  -- consistent with flat bench. Worth revisiting if user feedback shows
  -- inclines feel like a delt lift.
  -- Triceps 0.5 — same as flat bench.
  '[
    {"muscle_id": "chest",       "weight": 1.0},
    {"muscle_id": "front_delts", "weight": 0.5},
    {"muscle_id": "triceps",     "weight": 0.5}
  ]'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  -- shoulder_external_rotation: same logic as flat bench (review-applied
  -- to flat bench in batch 2). Bottom position loads ER.
  -- shoulder_flexion: incline angle pushes the press more toward shoulder
  -- flexion than flat bench does — meaningful enough to tag here but not
  -- on flat.
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
  -- Same muscle weights as incline BB bench. Differences (greater stretch,
  -- unilateral stabilization) are not visible at the 1.0/0.5/0.25 resolution
  -- — same logic as flat BB vs flat DB bench (batch 2).
  '[
    {"muscle_id": "chest",       "weight": 1.0},
    {"muscle_id": "front_delts", "weight": 0.5},
    {"muscle_id": "triceps",     "weight": 0.5}
  ]'::jsonb,
  'dumbbell', NULL, 5.00, 2.50,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['shoulder_external_rotation', 'shoulder_flexion'],
  '[]'::jsonb,
  '99999999-9999-9999-9999-999999999999',
  '{"incline": "incline", "grip": "pronated"}'::jsonb,
  -- Note: many users rotate to neutral grip on DB inclines. If wanting to
  -- track that as a distinct lift, separate row in same family.
  'stretched',
  'system', FALSE
);

-- ─── 20. Dip (Parallel-Bar, Chest-Bias) ─────────────────────────────────────
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
  'aaaaaaaa-0020-0000-0000-000000000001',
  'Dip',
  ARRAY['parallel bar dip', 'tricep dip', 'weighted dip'],
  'lifting',
  'horizontal_push', 'vertical_push', 'bilateral',
  -- DECISION (revised after review): triceps-bias variant as the default,
  -- not chest-bias. Reasoning: at typical commercial gyms with assisted-dip
  -- stations or shorter parallel bars, the geometry forces a more upright
  -- torso, which shifts emphasis to triceps. The chest-bias forward-lean
  -- variant requires long bars and clearance that most users won't have —
  -- treating it as the exception, not the default. If chest-bias dip is
  -- added later, it's a separate row in this family with chest 1.0 /
  -- triceps 0.5 / front_delts 0.5.
  --
  -- Triceps 1.0 — target on upright dip (elbow extension is the prime
  -- mover with vertical torso).
  -- Chest 0.5 — meaningful synergist; even on upright dip the chest still
  -- contributes to shoulder extension/adduction at the bottom. Not a
  -- 0.25 stabilizer — it does real work.
  -- Front_delts 0.5 — same logic as before; deeper shoulder extension
  -- at the bottom than bench, real synergist contribution.
  --
  -- movement_pattern_primary stays 'horizontal_push' (relative to torso the
  -- press direction is forward) with secondary 'vertical_push' (the body
  -- moves vertically). This pattern combo accurately captures that dips
  -- share recruitment with both bench AND OHP — unchanged from v1.
  '[
    {"muscle_id": "triceps",     "weight": 1.0},
    {"muscle_id": "chest",       "weight": 0.5},
    {"muscle_id": "front_delts", "weight": 0.5}
  ]'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  -- Same load_increment defaults as pull-up (bodyweight-loaded per §5).
  ARRAY['strength', 'hypertrophy'],
  -- DECISION (revised): default_role downgraded from 'main_compound' to
  -- 'secondary_compound'. Triceps-dominant upright dip is closer to a
  -- strong accessory than a main lift for most lifters; pairs as a
  -- triceps-focused supplement to a horizontal pressing main lift.
  'secondary_compound', 'early',
  'weighted_bodyweight', TRUE, TRUE,
  -- relative_to_bodyweight = TRUE: bodyweight is part of the working load.
  -- shoulder_flexion is wrong here (movement is shoulder extension, not
  -- flexion). shoulder_external_rotation is real at the bottom of a deep
  -- dip — applying same logic as bench.
  ARRAY['shoulder_external_rotation'],
  '[]'::jsonb,
  'dddddddd-dddd-dddd-dddd-dddddddddddd',
  -- variation_attributes: capturing the chest-vs-tricep distinction.
  -- Adding a new value 'chest_lean' to no established key wouldn't be
  -- right; using the closest existing concept (forward lean as a stance
  -- variable doesn't exist either). Leaving NULL and letting the row name
  -- + family carry the distinction. If we later add a `torso` key to the
  -- conventions doc, revisit.
  NULL,
  'stretched',
  'system', FALSE
);

-- ─── 21. Chin-Up (Supinated) ────────────────────────────────────────────────
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
  'aaaaaaaa-0021-0000-0000-000000000001',
  'Chin-Up',
  ARRAY['chinup', 'chin up', 'supinated pull-up'],
  'lifting',
  'vertical_pull', NULL, 'bilateral',
  -- DECISION (confirmed in chat): biceps 1.0, not 0.5.
  -- Supinated grip places biceps in their strongest mechanical position
  -- (forearm supinated → long head + short head fully engaged). On a heavy
  -- chin-up many lifters fail because of bicep fatigue, not lat fatigue.
  -- That meets §2's "muscle that limits the lift" criterion. This is also
  -- what differentiates chin-up from pull-up at the muscle-weighting level —
  -- without it, why have separate rows? (§1: separate rows when muscle
  -- weightings differ.)
  --
  -- Lats 1.0 — still a clear target. Two 1.0s here is a deliberate call
  -- (chin-up genuinely has two co-limiting prime movers). Same logic that
  -- gave conventional DL two 1.0s after batch 2 review.
  --
  -- Other synergists same as pull-up. Forearms drops because supinated grip
  -- is less grip-intensive than pronated (the bar sits in the palm
  -- differently); not enough to keep the 0.25 entry.
  '[
    {"muscle_id": "lats",            "weight": 1.0},
    {"muscle_id": "biceps",          "weight": 1.0},
    {"muscle_id": "rhomboids",       "weight": 0.5},
    {"muscle_id": "traps_mid_lower", "weight": 0.5},
    {"muscle_id": "rear_delts",      "weight": 0.25},
    {"muscle_id": "abs",             "weight": 0.25}
  ]'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  ARRAY['strength', 'hypertrophy'],
  'main_compound', 'early',
  'weighted_bodyweight', TRUE, TRUE,
  -- shoulder_flexion: applies less than pull-up (bar starts closer to face
  -- on supinated grip), but still in the demand. Keeping for consistency
  -- with pull-up. grip_intensive dropped (see muscle reasoning).
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
  -- Same muscle pattern as pull-up minus the bodyweight component. Lats 1.0,
  -- standard pulling synergists at 0.5. Biceps 0.5 (not 1.0 like chin-up) —
  -- pronated/wide grip default mirrors pull-up biology.
  -- No abs entry — pulldown is seated/supported, no anti-extension demand.
  -- No rear_delts 0.25 — the cable angle on a typical pulldown machine
  -- emphasizes lats more than rear delts; rear delts contribute but at
  -- below-stabilizer level.
  '[
    {"muscle_id": "lats",            "weight": 1.0},
    {"muscle_id": "biceps",          "weight": 0.5},
    {"muscle_id": "rhomboids",       "weight": 0.5},
    {"muscle_id": "traps_mid_lower", "weight": 0.5}
  ]'::jsonb,
  'cable', 'lat_pulldown', 10.00, 5.00,
  -- equipment_specific = 'lat_pulldown': common machine type, same pattern
  -- as schema's 'leg_press' specific tag. load_increment 10/5 per §5
  -- machine defaults; cable stacks typically come in 10-lb increments.
  ARRAY['hypertrophy', 'strength'],
  'secondary_compound', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['shoulder_flexion'],
  '[]'::jsonb,
  'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
  '{"grip": "pronated"}'::jsonb,
  -- Many users do pulldowns supinated or neutral — those would be separate
  -- rows in this family per §1.
  'stretched',
  'system', FALSE
);

-- ─── 23. Seated Cable Row ───────────────────────────────────────────────────
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
  'aaaaaaaa-0023-0000-0000-000000000001',
  'Seated Cable Row',
  ARRAY['cable row', 'seated row', 'low cable row'],
  'lifting',
  'horizontal_pull', NULL, 'bilateral',
  -- Mirrors chest-supported DB row's muscle profile (the seated/supported
  -- horizontal pull). Lats 1.0, mid-back synergists 0.5, biceps 0.5. No
  -- lower_back 0.5 (seated supports the spine) and no forearms 0.25 (cable
  -- handles are typically more wrist-friendly than a barbell, less grip-
  -- limiting). Same reasoning batch 2 used to drop those for chest-supported
  -- row vs BB row.
  '[
    {"muscle_id": "lats",            "weight": 1.0},
    {"muscle_id": "rhomboids",       "weight": 0.5},
    {"muscle_id": "traps_mid_lower", "weight": 0.5},
    {"muscle_id": "rear_delts",      "weight": 0.5},
    {"muscle_id": "biceps",          "weight": 0.5}
  ]'::jsonb,
  'cable', 'cable_row_machine', 10.00, 5.00,
  ARRAY['hypertrophy', 'strength'],
  'secondary_compound', 'anywhere',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'ffffffff-ffff-ffff-ffff-ffffffffffff',
  '{"grip": "neutral"}'::jsonb,
  -- Default neutral handle (V-bar) — most common cable row setup. Wide-grip
  -- pronated cable row would be a separate row in this family.
  'stretched',
  'system', FALSE
);

-- ─── 24. Lying Leg Curl ─────────────────────────────────────────────────────
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
  'aaaaaaaa-0024-0000-0000-000000000001',
  'Lying Leg Curl',
  ARRAY['leg curl', 'prone leg curl', 'hamstring curl'],
  'lifting',
  'hinge', NULL, 'bilateral',
  -- TODO(schema): movement_pattern_primary should be 'knee_flexion' (or a
  -- generic 'isolation') once the movement_pattern enum is extended. Using
  -- 'hinge' as the closest-available fit; see TODO.md for the migration
  -- followup. Not a great fit — knee flexion isolation is mechanically
  -- different from hip-hinge.
  --
  -- Hamstrings 1.0 — uncontested target. Pure isolation, no synergists at
  -- 0.5: gastrocnemius (calves) crosses the knee and contributes minor
  -- flexion, but not enough to track here. Glutes do nothing on a lying
  -- curl (hip stays extended on the pad).
  '[
    {"muscle_id": "hamstrings", "weight": 1.0}
  ]'::jsonb,
  'machine', 'leg_curl', 10.00, 5.00,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '11111111-2222-3333-4444-555555555555',
  NULL,
  -- 'shortened': peak tension at peak knee flexion (curled position).
  -- Conventions §8 explicitly cites leg curl as a 'shortened' example.
  'shortened',
  'system', FALSE
);

-- ─── 25. Leg Extension ──────────────────────────────────────────────────────
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
  'aaaaaaaa-0025-0000-0000-000000000001',
  'Leg Extension',
  ARRAY['leg ext', 'knee extension', 'machine leg extension'],
  'lifting',
  'squat', NULL, 'bilateral',
  -- TODO(schema): movement_pattern_primary should be 'knee_extension' (or a
  -- generic 'isolation') once the movement_pattern enum is extended. Using
  -- 'squat' as the closest-available fit; see TODO.md for the migration
  -- followup. The squat pattern's core action is knee extension under hip
  -- flexion — leg extension isolates just the knee piece, so it's the
  -- closest fit but not a real match.
  --
  -- Quads 1.0 — uncontested target. Pure isolation. Rectus femoris crosses
  -- the hip but the seated position locks hip flexion, so no hip flexor
  -- contribution worth tracking.
  '[
    {"muscle_id": "quads", "weight": 1.0}
  ]'::jsonb,
  'machine', 'leg_extension', 10.00, 5.00,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '22222222-3333-4444-5555-666666666666',
  NULL,
  -- 'shortened': peak tension at full knee extension (legs straight).
  -- Classic peak-contraction isolation, mirrors leg curl's profile in the
  -- opposite direction.
  'shortened',
  'system', FALSE
);

-- ─── 26. Standing Calf Raise ────────────────────────────────────────────────
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
  'aaaaaaaa-0026-0000-0000-000000000001',
  'Standing Calf Raise',
  ARRAY['calf raise', 'standing calf', 'machine calf raise'],
  'lifting',
  'plyometric', NULL, 'bilateral',
  -- TODO(schema): movement_pattern_primary should be 'ankle_extension' (or
  -- a generic 'isolation') once the movement_pattern enum is extended. Using
  -- 'plyometric' as a deliberately bad fit; see TODO.md for migration
  -- followup. This is the WORST of the five enum compromises — plyometric
  -- implies ballistic/explosive action, which a slow-tempo calf raise is
  -- not. Closest available only because it captures ankle plantarflexion
  -- as primary action; nothing else in the enum does even that.
  --
  -- Calves 1.0 — uncontested target. Standing calf specifically loads
  -- gastrocnemius (knee straight = gastroc engaged); seated calf raise
  -- (future row in this family) shifts emphasis to soleus. Both are
  -- 'calves' at our muscle-id resolution.
  '[
    {"muscle_id": "calves", "weight": 1.0}
  ]'::jsonb,
  'machine', 'standing_calf_raise', 10.00, 5.00,
  -- equipment_primary = 'machine'. Standing calf raise can be done with a
  -- barbell on the back (calf raise off a plate) but the dedicated machine
  -- is the canonical execution and the load progression is cleaner. BB
  -- variant would be a separate row in this family.
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '33333333-4444-5555-6666-777777777777',
  NULL,
  -- 'stretched': bottom of ROM (heel below platform, gastrocnemius
  -- maximally lengthened) is where peak tension lives. This is the
  -- canonical stretched-position isolation.
  'stretched',
  'system', FALSE
);

-- ─── 27. Barbell Curl ───────────────────────────────────────────────────────
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
  'aaaaaaaa-0027-0000-0000-000000000001',
  'Barbell Curl',
  ARRAY['BB curl', 'barbell bicep curl', 'standing barbell curl'],
  'lifting',
  'vertical_pull', NULL, 'bilateral',
  -- TODO(schema): movement_pattern_primary should be 'elbow_flexion' (or a
  -- generic 'isolation') once the movement_pattern enum is extended. Using
  -- 'vertical_pull' as the closest-available fit; see TODO.md for migration
  -- followup. Calling a curl a 'vertical_pull' is the same kind of
  -- compromise as calling leg extension a 'squat' — captures the directional
  -- vibe (bar moves vertically toward body) but not the actual mechanic
  -- (single-joint elbow flexion vs multi-joint pull).
  --
  -- Biceps 1.0 — clear target.
  -- Forearms 0.25 — supinated bar grip mildly works the brachioradialis;
  -- not as much as hammer curl (which is why hammer is a separate row),
  -- but enough for a stabilizer entry on heavy curls.
  -- No abs entry: brief bracing on standing curl, not enough to track.
  '[
    {"muscle_id": "biceps",   "weight": 1.0},
    {"muscle_id": "forearms", "weight": 0.25}
  ]'::jsonb,
  'barbell', NULL, 5.00, 2.50,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '44444444-5555-6666-7777-888888888888',
  '{"grip": "supinated"}'::jsonb,
  -- 'mid': peak tension is roughly mid-range (forearm parallel to ground)
  -- where the moment arm on the bicep is longest. Not stretched (bottom is
  -- a relatively unloaded hang) and not shortened (top is contracted but
  -- moment arm shortens). Conventions §8 default for "most rows, leg press"
  -- = mid; same logic.
  'mid',
  'system', FALSE
);

-- ─── 28. Triceps Pushdown (Cable) ───────────────────────────────────────────
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
  'aaaaaaaa-0028-0000-0000-000000000001',
  'Triceps Pushdown',
  ARRAY['tricep pushdown', 'cable pushdown', 'rope pushdown'],
  'lifting',
  'vertical_push', NULL, 'bilateral',
  -- TODO(schema): movement_pattern_primary should be 'elbow_extension' (or
  -- a generic 'isolation') once the movement_pattern enum is extended. Using
  -- 'vertical_push' as the closest-available fit; see TODO.md for migration
  -- followup. Same compromise as BB curl in the opposite direction —
  -- captures the directional vibe (cable moves vertically downward) but
  -- not the actual mechanic (single-joint elbow extension vs multi-joint
  -- press).
  --
  -- Triceps 1.0 — clear target. Pure isolation; no synergist entries.
  '[
    {"muscle_id": "triceps", "weight": 1.0}
  ]'::jsonb,
  'cable', 'cable_pushdown', 5.00, 2.50,
  -- DECISION: load_increment_default = 5.00 not 10.00. Cable pushdown is
  -- typically done at lighter weights where 10-lb jumps are too aggressive.
  -- Conventions §5 lists cable as "5.00 or 10.00 (gym-dep.)" — going with
  -- 5 for this isolation use-case. Override at user level if their gym only
  -- has 10-lb increments.
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '55555555-6666-7777-8888-999999999999',
  '{"grip": "pronated"}'::jsonb,
  -- Default pronated bar attachment. Rope (neutral) and reverse (supinated)
  -- pushdowns would be separate rows in this family.
  -- 'shortened': peak tension at full extension (arms locked out at sides).
  -- Classic peak-contraction isolation.
  'shortened',
  'system', FALSE
);

-- ─── 29. Dumbbell Hammer Curl ───────────────────────────────────────────────
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
  'aaaaaaaa-0029-0000-0000-000000000001',
  'Dumbbell Hammer Curl',
  ARRAY['hammer curl', 'DB hammer curl', 'neutral grip curl'],
  'lifting',
  'vertical_pull', NULL, 'bilateral',
  -- DECISION (confirmed in chat): separate row from BB curl, not folded
  -- into aliases. Justification: neutral grip recruits brachialis and
  -- brachioradialis substantially more than supinated curls. That's a
  -- meaningful muscle weighting difference, which §1 says triggers a
  -- separate row.
  --
  -- Biceps 1.0 — still target (brachialis is part of the 'biceps' muscle
  -- group at our resolution; we don't track brachialis separately).
  -- Forearms 0.5 — bumped from BB curl's 0.25 to 0.5 here. Brachioradialis
  -- is a forearm muscle and is HEAVILY recruited in neutral grip curls;
  -- many users feel hammer curls more in their forearms than their biceps.
  -- Meets §2's "meaningful synergist that fatigues and would be sore"
  -- criterion solidly.
  '[
    {"muscle_id": "biceps",   "weight": 1.0},
    {"muscle_id": "forearms", "weight": 0.5}
  ]'::jsonb,
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
--
-- NOTE on within-family bench edges (incline BB ↔ incline DB ↔ flat BB
-- ↔ flat DB): same enum issue flagged in batch 2's substitute header —
-- same equipment within a variation family doesn't fit any reason tag
-- cleanly. Using `same_pattern_different_equipment` for cross-equipment
-- (BB↔DB) and `same_muscles_different_pattern` for cross-incline
-- (flat↔incline same equipment), accepting the same enum-stretch.

INSERT INTO public.exercise_substitutes (exercise_id, substitute_id, similarity_score, reason) VALUES
  -- ── 18. Incline BB bench ─────────────────────────────────────────────────
  ('aaaaaaaa-0018-0000-0000-000000000001', 'aaaaaaaa-0019-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0018-0000-0000-000000000001', 'aaaaaaaa-0012-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0018-0000-0000-000000000001', 'aaaaaaaa-0016-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),

  -- ── 19. Incline DB bench ─────────────────────────────────────────────────
  ('aaaaaaaa-0019-0000-0000-000000000001', 'aaaaaaaa-0018-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0019-0000-0000-000000000001', 'aaaaaaaa-0013-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0019-0000-0000-000000000001', 'aaaaaaaa-0017-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),

  -- Reciprocal: flat BB bench (batch 2) → incline BB (and DB) as new
  -- variations in same family. Adding to batch 2's outgoing edges.
  ('aaaaaaaa-0012-0000-0000-000000000001', 'aaaaaaaa-0018-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0013-0000-0000-000000000001', 'aaaaaaaa-0019-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),

  -- ── 20. Dip ──────────────────────────────────────────────────────────────
  -- Triceps-bias dip (revised default per review). Closest substitutes are
  -- triceps-pattern lifts: pushdown (isolation, same target) and OHP
  -- (compound with triceps as 0.5 synergist). Bench remains a substitute
  -- because chest is still 0.5 here and dip can fill a horizontal-press
  -- slot at lower priority.
  ('aaaaaaaa-0020-0000-0000-000000000001', 'aaaaaaaa-0028-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0020-0000-0000-000000000001', 'aaaaaaaa-0016-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0020-0000-0000-000000000001', 'aaaaaaaa-0012-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),

  -- ── 21. Chin-up ──────────────────────────────────────────────────────────
  -- Within pullup_family: pull-up. Across families: lat pulldown (vertical
  -- pull alternative).
  ('aaaaaaaa-0021-0000-0000-000000000001', 'aaaaaaaa-0002-0000-0000-000000000001', 0.85, 'same_muscles_different_pattern'),
  -- Reason: same family, different grip = different muscle weighting; same
  -- enum-stretch as the squat within-family edges in batch 2.
  ('aaaaaaaa-0021-0000-0000-000000000001', 'aaaaaaaa-0022-0000-0000-000000000001', 0.65, 'same_pattern_different_equipment'),
  -- chin-up regression: lat pulldown (cable, supinated grip variant).
  -- Note: lat_pulldown is authored pronated by default; in practice users
  -- swap grips. Substitute edge captures the "I can't do chins" use case.

  -- Reciprocal: pull-up (batch 1) → chin-up
  ('aaaaaaaa-0002-0000-0000-000000000001', 'aaaaaaaa-0021-0000-0000-000000000001', 0.85, 'same_muscles_different_pattern'),

  -- Reciprocal: BB OHP (batch 2) → dip (revised dip is triceps-bias, so
  -- OHP and dip now share triceps + front_delts as the synergist pair;
  -- meaningful substitute for users without an OHP setup).
  ('aaaaaaaa-0016-0000-0000-000000000001', 'aaaaaaaa-0020-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),

  -- ── 22. Lat pulldown ─────────────────────────────────────────────────────
  -- Confirmed in chat: pulldown ↔ pull-up is same_pattern_different_equipment,
  -- not regression/progression (different lifts, not graded versions).
  ('aaaaaaaa-0022-0000-0000-000000000001', 'aaaaaaaa-0002-0000-0000-000000000001', 0.75, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0022-0000-0000-000000000001', 'aaaaaaaa-0021-0000-0000-000000000001', 0.65, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0022-0000-0000-000000000001', 'aaaaaaaa-0023-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),

  -- Reciprocal: pull-up (batch 1) → lat pulldown
  ('aaaaaaaa-0002-0000-0000-000000000001', 'aaaaaaaa-0022-0000-0000-000000000001', 0.75, 'same_pattern_different_equipment'),

  -- ── 23. Seated cable row ─────────────────────────────────────────────────
  ('aaaaaaaa-0023-0000-0000-000000000001', 'aaaaaaaa-0015-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  ('aaaaaaaa-0023-0000-0000-000000000001', 'aaaaaaaa-0014-0000-0000-000000000001', 0.65, 'progression'),
  -- Reason: BB row is a progression for cable row users — adds lumbar
  -- loading and grip demand. Per conventions §10 progression definition.
  ('aaaaaaaa-0023-0000-0000-000000000001', 'aaaaaaaa-0022-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),

  -- Reciprocal: BB row (batch 2) → cable row (regression edge)
  ('aaaaaaaa-0014-0000-0000-000000000001', 'aaaaaaaa-0023-0000-0000-000000000001', 0.65, 'regression'),
  -- Reciprocal: chest-supported row (batch 2) → cable row (cross-equipment)
  ('aaaaaaaa-0015-0000-0000-000000000001', 'aaaaaaaa-0023-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),

  -- ── 24. Lying leg curl ───────────────────────────────────────────────────
  -- Hamstring isolation has limited substitutes; closest are RDL (compound
  -- with hamstring focus) and the related stretched-vs-shortened pairing.
  -- Only one substitute here is honest — could pad with seated leg curl but
  -- that's a future row. §10 says "at least one"; we're at one.
  ('aaaaaaaa-0024-0000-0000-000000000001', 'aaaaaaaa-0010-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),

  -- ── 25. Leg extension ────────────────────────────────────────────────────
  -- Quad isolation; closest substitutes are quad-dominant compounds.
  ('aaaaaaaa-0025-0000-0000-000000000001', 'aaaaaaaa-0005-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0025-0000-0000-000000000001', 'aaaaaaaa-0001-0000-0000-000000000001', 0.40, 'same_muscles_different_pattern'),
  -- Note: lower scores than e.g. row substitutes because leg extension is
  -- truly isolated quads-only; the compound substitutes hit quads with very
  -- different stimulus/skill profiles.

  -- ── 26. Standing calf raise ──────────────────────────────────────────────
  -- Calves coverage is sparse in the DB right now. No good in-DB substitute
  -- until a seated calf raise / leg-press calf raise lands. Including the
  -- minimum one substitute (leg press, which incidentally hits calves at
  -- end-range). Honestly sub-0.25 — this is the "at least one" floor.
  ('aaaaaaaa-0026-0000-0000-000000000001', 'aaaaaaaa-0005-0000-0000-000000000001', 0.30, 'same_muscles_different_pattern'),
  -- DECISION (surfaced for review): including a 0.30 substitute violates
  -- conventions §10 "<0.25 don't bother" only narrowly. The floor on the
  -- coverage rule is "at least one substitute"; this is the least-bad
  -- option until calf raise variants are added in batch 4. If review
  -- prefers, drop this row and accept that calf raise has zero substitutes
  -- in v1.

  -- ── 27. Barbell curl ─────────────────────────────────────────────────────
  ('aaaaaaaa-0027-0000-0000-000000000001', 'aaaaaaaa-0029-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  -- BB curl ↔ hammer: same primary muscle, different forearm bias. Within-
  -- arm-day swap, not within a single family (different family per §1).
  ('aaaaaaaa-0027-0000-0000-000000000001', 'aaaaaaaa-0021-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern'),
  -- BB curl → chin-up: chin-up hits biceps as a 1.0 target. For a user with
  -- no curl access, chin-up is a real biceps stimulus.

  -- ── 28. Triceps pushdown ─────────────────────────────────────────────────
  -- Pushdown is shortened-position triceps isolation; closest substitutes
  -- now include dip (revised to triceps-bias default — strong relationship,
  -- both target triceps with overlapping stimulus). OHP is the cross-pattern
  -- compound that hits triceps as 0.5 synergist. Without overhead extension
  -- or skull crusher in the DB, that's the honest substitute set.
  ('aaaaaaaa-0028-0000-0000-000000000001', 'aaaaaaaa-0020-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0028-0000-0000-000000000001', 'aaaaaaaa-0016-0000-0000-000000000001', 0.40, 'same_muscles_different_pattern'),

  -- ── 29. Hammer curl ──────────────────────────────────────────────────────
  ('aaaaaaaa-0029-0000-0000-000000000001', 'aaaaaaaa-0027-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  ('aaaaaaaa-0029-0000-0000-000000000001', 'aaaaaaaa-0021-0000-0000-000000000001', 0.45, 'same_muscles_different_pattern');
