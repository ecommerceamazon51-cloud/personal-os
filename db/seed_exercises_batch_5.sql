-- =============================================================================
-- Seed Exercises — Batch 5 (21 exercises, gap-analysis driven)
-- =============================================================================
-- Brings total from 44 → 65 exercises. Authored after the conventions §12
-- "reassess every ~25 exercises" checkpoint at the 44-exercise mark.
--
-- Scope sources:
--   - Tier 1 muscle/pattern gaps (11 exercises 45–55): hip thrust regression
--     and unilateral progression; alternate hamstring stimulus; loaded hinge
--     variant; back thickness (uni + T-bar); long-head triceps; compound
--     triceps; stretched-bias biceps; constant-tension lateral; rear delt
--     isolation.
--   - Equipment expansion (5 exercises 56–60): trap bar, safety squat bar,
--     kettlebell, two carry variants.
--   - Plyo + conditioning (5 exercises 61–65): plyometric, sled, rower,
--     air bike, jump rope. First exercises using `plyometric` movement
--     pattern, `conditioning` modality, and `sled`/`plyo_box` equipment
--     enum values.
--
-- Conventions adhered to (see docs/exercise_authoring_conventions.md):
--   - §1: glute bridge + single-leg hip thrust share existing hip thrust
--     family (88888888...) — different muscle weightings = separate rows
--     per family rule. Trap bar deadlift gets its own family (different
--     pattern than conv DL: more squat-like, neutral grip changes loading).
--   - §2: muscle weightings — defaulted to fewer 1.0s where borderline
--     (e.g. T-bar lats vs traps_mid_lower; close-grip bench triceps vs
--     chest).
--   - §8: loaded_position — incline DB curl 'stretched' (long head bias);
--     cable lateral 'mid' (constant tension throughout); reverse pec deck
--     'shortened'; box jump 'none'.
--   - §10: every new exercise has ≥1 substitute wired up at bottom.
--   - §12: each exercise here justifies its row by NEW pattern, NEW
--     equipment, NEW difficulty tier, or meaningfully different muscle
--     bias from anything already in the DB. None are functionally redundant.
--
-- Conventions NOT yet adhered to but flagged for follow-up:
--   - Performance metric `calories` does not exist in the enum. The four
--     conditioning rows (sled push, rower, air bike, jump rope) are
--     authored with the closest-fit metric (`time` or `distance`). When
--     the goal-conditional metrics layer is built, calories likely
--     surfaces as a secondary metric for cut-goal users — flagged inline
--     on each row with TODO(goals).
--   - Trap bar uses `specialty_bar` equipment value. The schema enum
--     doesn't have a dedicated `trap_bar`; specialty_bar is the closest
--     fit and matches how the safety squat bar is authored. If equipment
--     filtering needs to distinguish trap bar from SSB (e.g. "user has
--     trap bar but not SSB"), revisit via `equipment_specific` column.
--
-- Pre-generated UUIDs (families new in this batch):
--   trap_bar_dl_family   = aaaaaa11-1111-1111-1111-111111111111
--   ssb_squat_family     = aaaaaa22-2222-2222-2222-222222222222 (new family;
--     SSB squat is a separate lift from back squat — different bar position,
--     different torso angle, different muscle bias, NOT a back squat
--     variation per §1 examples)
--   kb_swing_family      = aaaaaa33-3333-3333-3333-333333333333
--   carry_family         = aaaaaa44-4444-4444-4444-444444444444 (farmer's +
--     suitcase share family — same locomotion-with-load mechanic, different
--     loading symmetry)
--   box_jump_family      = aaaaaa55-5555-5555-5555-555555555555
--   sled_push_family     = aaaaaa66-6666-6666-6666-666666666666
--   rower_family         = aaaaaa77-7777-7777-7777-777777777777
--   air_bike_family      = aaaaaa88-8888-8888-8888-888888888888
--   jump_rope_family     = aaaaaa99-9999-9999-9999-999999999999
--   t_bar_row_family     = aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa (separate
--     from BB row family — T-bar's chest-supported/landmine variants are
--     mid-back biased, not a row in the BB row family sense)
--   tricep_ext_family    = aaaaaabb-bbbb-bbbb-bbbb-bbbbbbbbbbbb (lying
--     extension + close-grip bench DON'T share a family — different
--     primary patterns. CGBP shares bench_family with flat BB bench.)
--   incline_curl_family  = aaaaaacc-cccc-cccc-cccc-cccccccccccc (separate
--     from BB curl family per §1: different stretch position changes
--     muscle bias)
--   cable_lateral_family = aaaaaadd-dddd-dddd-dddd-dddddddddddd (separate
--     from DB lateral family per §1: equipment change + loaded_position
--     change = separate row, and arguably separate family since the
--     constant-tension profile is fundamentally different)
--   reverse_pec_family   = aaaaaaee-eeee-eeee-eeee-eeeeeeeeeeee
--   good_morning_family  = aaaaaaff-ffff-ffff-ffff-ffffffffffff (separate
--     from RDL family — bar position changes the lift fundamentally)
--   seated_leg_curl_fam  = aaaaa011-1111-1111-1111-111111111111 (separate
--     from lying leg curl per §1 reasoning in scope: hip flexion changes
--     hamstring length, different muscle-length stimulus)
--   single_arm_row_fam   = aaaaa022-2222-2222-2222-222222222222 (separate
--     from BB row family — unilateral changes loading, anti-rotation
--     demand absent in bilateral rows)
--
-- Reused families:
--   hip_thrust_family    = 88888888-8888-8888-8888-888888888888 (shared
--     by glute bridge, single-leg hip thrust, and existing barbell HT)
--   bench_family         = 99999999-9999-9999-9999-999999999999 (shared
--     by close-grip bench press)
--
-- Exercise IDs in batch 5: aaaaaaaa-0045-* through aaaaaaaa-0065-*
-- =============================================================================


-- =============================================================================
-- TIER 1: MUSCLE / PATTERN GAPS (11 exercises, IDs 45–55)
-- =============================================================================


-- ─── 45. Glute Bridge ───────────────────────────────────────────────────────
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
  -- Glutes 1.0 — same as hip thrust, the lift IS hip extension to peak
  -- contraction.
  -- Hamstrings 0.5 — synergist in hip extension, slightly less involved
  -- here than in HT because the shorter ROM reduces hamstring stretch
  -- contribution. Still meaningful at lockout.
  -- Adductors 0.25 — stabilize knee position; user notices on heavy sets.
  -- No abs 0.25 — bridge is short-ROM and back-supported; abs less
  -- challenged than in standing/hanging movements.
  '[
    {"muscle_id": "glutes",     "weight": 1.0},
    {"muscle_id": "hamstrings", "weight": 0.5},
    {"muscle_id": "adductors",  "weight": 0.25}
  ]'::jsonb,
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
  -- Glutes 1.0 — single leg means double the relative load on the working
  -- glute, which is the entire point of the variation (overcomes the
  -- "hip thrust glute activation" plateau that bilateral HT can hit at
  -- high loads).
  -- Hamstrings 0.5 — same role as bilateral HT, scaled to one leg.
  -- Adductors 0.25 — pelvic stability becomes more important without the
  -- second leg's contribution.
  -- Abs 0.25 — anti-rotation demand introduced by unilateral loading.
  -- This is meaningful enough on a heavy single-leg HT to track; not
  -- present in bilateral.
  '[
    {"muscle_id": "glutes",     "weight": 1.0},
    {"muscle_id": "hamstrings", "weight": 0.5},
    {"muscle_id": "adductors",  "weight": 0.25},
    {"muscle_id": "abs",        "weight": 0.25}
  ]'::jsonb,
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
  -- Hamstrings 1.0 — uncontested target.
  -- Calves 0.25 — contribute to knee flexion (gastrocnemius crosses both
  -- joints); tracked because user notices calf cramping risk on heavy
  -- seated curls. Same logic as on lying leg curl.
  '[
    {"muscle_id": "hamstrings", "weight": 1.0},
    {"muscle_id": "calves",     "weight": 0.25}
  ]'::jsonb,
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
  -- Hamstrings 1.0 — primary target via hip flexion under load.
  -- Lower_back 1.0 — co-target. Unlike RDL where the bar's path keeps
  -- the moment arm shorter, GM has the bar at the highest possible
  -- position on the body, maximizing the moment arm on the lumbar
  -- spine. Lower back is the limiting factor for most lifters and
  -- meets the §2 "muscle that limits the lift" criterion. Two 1.0s
  -- here is intentional and correct.
  -- Glutes 0.5 — synergist at hip extension. Not 1.0; if glutes were
  -- the target you'd program a hip thrust (per the RDL row's reasoning).
  -- Erectors get the 1.0 lower_back entry.
  -- Adductors 0.25 — stabilize stance under spinal load.
  '[
    {"muscle_id": "hamstrings", "weight": 1.0},
    {"muscle_id": "lower_back", "weight": 1.0},
    {"muscle_id": "glutes",     "weight": 0.5},
    {"muscle_id": "adductors",  "weight": 0.25}
  ]'::jsonb,
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
  -- Lats 1.0 — primary target. The pull mechanic emphasizes lats over
  -- mid-back when elbow tracks close to the body (typical SA row form).
  -- Rhomboids 0.5 — synergist in scapular retraction at the top.
  -- Traps_mid_lower 0.5 — same reason, scapular retraction.
  -- Biceps 0.5 — elbow flexion against load.
  -- Rear_delts 0.25 — assist scapular retraction; less involved than in
  -- a wider-elbow row.
  -- Abs 0.25 — anti-rotation demand from unilateral loading; user
  -- notices on heavy sets. This is what distinguishes SA row's training
  -- effect from chest-supported DB row.
  '[
    {"muscle_id": "lats",            "weight": 1.0},
    {"muscle_id": "rhomboids",       "weight": 0.5},
    {"muscle_id": "traps_mid_lower", "weight": 0.5},
    {"muscle_id": "biceps",          "weight": 0.5},
    {"muscle_id": "rear_delts",      "weight": 0.25},
    {"muscle_id": "abs",             "weight": 0.25}
  ]'::jsonb,
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
  -- traps_mid_lower and rhomboids.
  --
  -- Traps_mid_lower 1.0 — primary target. The defining characteristic
  -- of T-bar row is the mid-back emphasis from the wider elbow flare.
  -- This is what distinguishes T-bar from BB row.
  -- Rhomboids 1.0 — co-target with traps_mid_lower; both are responsible
  -- for the scapular retraction the lift is built around. Two 1.0s
  -- intentional per §2 "the muscle that grows from doing it".
  -- Lats 0.5 — meaningful synergist; less emphasized than in BB row
  -- (closer-elbow path) but still working hard.
  -- Biceps 0.5 — elbow flexion against load.
  -- Rear_delts 0.5 — wider-elbow path increases rear delt contribution
  -- vs close-grip rows. Borderline 0.25/0.5; going 0.5 because the
  -- wide-grip mechanic specifically loads them.
  -- Lower_back 0.25 — supports the bent-over position; user notices on
  -- heavy sets.
  -- Forearms 0.25 — grip on V-handle.
  '[
    {"muscle_id": "traps_mid_lower", "weight": 1.0},
    {"muscle_id": "rhomboids",       "weight": 1.0},
    {"muscle_id": "lats",            "weight": 0.5},
    {"muscle_id": "biceps",          "weight": 0.5},
    {"muscle_id": "rear_delts",      "weight": 0.5},
    {"muscle_id": "lower_back",      "weight": 0.25},
    {"muscle_id": "forearms",        "weight": 0.25}
  ]'::jsonb,
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
  -- Triceps 1.0 — uncontested target; the long-head bias is the reason
  -- to do this lift over pushdown.
  -- No other entries — this is a clean isolation. Forearms grip the bar
  -- but not enough to count.
  '[
    {"muscle_id": "triceps", "weight": 1.0}
  ]'::jsonb,
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
  -- Triceps 1.0 — narrow grip puts triceps as the limiting factor for
  -- lockout strength. The reason to program CGBP over flat bench is
  -- triceps emphasis.
  -- Chest 0.5 — still meaningfully loaded; CGBP is not a pure
  -- triceps lift, the chest does work especially in the bottom half.
  -- Demoted from bench's 1.0 because narrow grip reduces chest moment
  -- arm. Borderline 0.5/1.0; going 0.5 per §2 "default to fewer 1.0s".
  -- Front_delts 0.5 — synergist in pressing, same as flat bench.
  -- Abs 0.25 — bracing under load, same as flat bench.
  '[
    {"muscle_id": "triceps",     "weight": 1.0},
    {"muscle_id": "chest",       "weight": 0.5},
    {"muscle_id": "front_delts", "weight": 0.5},
    {"muscle_id": "abs",         "weight": 0.25}
  ]'::jsonb,
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
  -- Biceps 1.0 — uncontested target.
  -- Forearms 0.25 — grip + brachioradialis contribution in supinated
  -- DB curl; meaningful enough on heavier sets to track.
  '[
    {"muscle_id": "biceps",   "weight": 1.0},
    {"muscle_id": "forearms", "weight": 0.25}
  ]'::jsonb,
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
  -- Side_delts 1.0 — uncontested target, same as DB lateral.
  -- No other entries — clean isolation, no synergists meaningful enough
  -- to track.
  '[
    {"muscle_id": "side_delts", "weight": 1.0}
  ]'::jsonb,
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
  -- Rear_delts 1.0 — uncontested target. The reason to author this row
  -- is that batch 1-4 has rear delt coverage only via face pull at 0.25
  -- weight (per scope analysis); reverse pec deck is the actual rear
  -- delt isolation lift.
  -- Rhomboids 0.5 — synergist in scapular retraction at end-range.
  -- Traps_mid_lower 0.5 — same role.
  -- No biceps entry — straight-arm machine, elbow doesn't flex.
  '[
    {"muscle_id": "rear_delts",      "weight": 1.0},
    {"muscle_id": "rhomboids",       "weight": 0.5},
    {"muscle_id": "traps_mid_lower", "weight": 0.5}
  ]'::jsonb,
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
  -- Quads 1.0 — distinguishing feature vs conv DL. Trap bar's more
  -- vertical torso + more knee flexion = quads do meaningfully more
  -- work than in conv DL (where they're 0.5).
  -- Glutes 1.0 — same as conv DL; hip extension is primary mover.
  -- Hamstrings 0.5 — same role as conv DL but slightly less stretched
  -- because of the more squat-like position.
  -- Lower_back 1.0 — still axially loaded, still a back-strain lift.
  -- Trap bar can feel easier on the back due to the more upright torso,
  -- but the lower back is still doing real work supporting the spine
  -- under load. 1.0 matches conv DL.
  -- Traps_upper 0.5 — supporting the load via shrugged-shoulder position
  -- (trap bar handles are at sides, traps stabilize). Meaningful enough
  -- to track; trap bar DL is sometimes used as a trap builder.
  -- Forearms 0.25 — grip; neutral grip is grippier than mixed/double-
  -- overhand on a barbell, so less grip-limited than conv DL but still
  -- meaningful on heavy sets.
  -- Adductors 0.25 — stabilize stance.
  '[
    {"muscle_id": "quads",       "weight": 1.0},
    {"muscle_id": "glutes",      "weight": 1.0},
    {"muscle_id": "hamstrings",  "weight": 0.5},
    {"muscle_id": "lower_back",  "weight": 1.0},
    {"muscle_id": "traps_upper", "weight": 0.5},
    {"muscle_id": "forearms",    "weight": 0.25},
    {"muscle_id": "adductors",   "weight": 0.25}
  ]'::jsonb,
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
  -- Quads 1.0 — same as back squat; SSB is still a knee-dominant squat.
  -- Glutes 0.5 — same as high-bar back squat, slightly less than low-bar.
  -- SSB's pad position pushes the lifter slightly forward, mimicking a
  -- front squat position; quads stay primary, glutes still synergist.
  -- Adductors 0.5 — same as back squat.
  -- Lower_back 0.5 — SSB is famous for its forward-pulling torque on the
  -- upper back/lower back. Heavier than back squat's 0.25; this is one
  -- of the reasons SSB is programmed (bracing demand). Going 0.5 here
  -- to capture the meaningful additional erector loading.
  -- Rhomboids 0.5 + Traps_mid_lower 0.5 — SSB handles in front pull the
  -- lifter forward; scapular retractors work hard to maintain torso
  -- position. This is the defining feature vs straight bar. (No generic
  -- upper_back muscle in the schema — split across the two muscles
  -- that actually do this work.)
  -- Abs 0.25 — bracing.
  '[
    {"muscle_id": "quads",           "weight": 1.0},
    {"muscle_id": "glutes",          "weight": 0.5},
    {"muscle_id": "adductors",       "weight": 0.5},
    {"muscle_id": "lower_back",      "weight": 0.5},
    {"muscle_id": "rhomboids",       "weight": 0.5},
    {"muscle_id": "traps_mid_lower", "weight": 0.5},
    {"muscle_id": "abs",             "weight": 0.25}
  ]'::jsonb,
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
  -- Glutes 1.0 — primary mover; the swing IS hip extension under
  -- ballistic load. Glutes are what propels the bell.
  -- Hamstrings 1.0 — co-target. The swing's setup (deep hip hinge with
  -- knees soft) puts hamstrings in stretched/loaded position; the
  -- elastic recoil from this loaded position is most of the lift's
  -- training effect. Two 1.0s correct here.
  -- Lower_back 0.5 — supports the spine under repeated ballistic load.
  -- Less than a deadlift (lighter loads, no axial compression) but
  -- meaningful, especially on long sets.
  -- Forearms 0.5 — grip on a heavy KB for high-rep ballistic work
  -- becomes a real factor; KB swing is often grip-limited.
  -- Abs 0.25 — bracing during the float phase.
  '[
    {"muscle_id": "glutes",     "weight": 1.0},
    {"muscle_id": "hamstrings", "weight": 1.0},
    {"muscle_id": "lower_back", "weight": 0.5},
    {"muscle_id": "forearms",   "weight": 0.5},
    {"muscle_id": "abs",        "weight": 0.25}
  ]'::jsonb,
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
  -- Forearms 1.0 — primary target by training intent. Farmer's carry
  -- is the canonical grip-builder; the lift is grip-limited for almost
  -- every lifter, and grip is what most users program it for.
  -- Traps_upper 1.0 — co-target. Supporting heavy loads at the sides
  -- demands huge traps_upper isometric work; farmers are also a
  -- canonical trap builder.
  -- Abs 0.5 — bracing under load; meaningful on heavy carries.
  -- Obliques 0.5 — anti-flexion + lateral stability while walking.
  -- Quads 0.25 — walking under load, calves and quads do real work.
  -- Lower_back 0.25 — supports the spine.
  '[
    {"muscle_id": "forearms",    "weight": 1.0},
    {"muscle_id": "traps_upper", "weight": 1.0},
    {"muscle_id": "abs",         "weight": 0.5},
    {"muscle_id": "obliques",    "weight": 0.5},
    {"muscle_id": "quads",       "weight": 0.25},
    {"muscle_id": "lower_back",  "weight": 0.25}
  ]'::jsonb,
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
  -- Obliques 1.0 — primary target on the contralateral side (load on
  -- right hand → left obliques resisting lateral bend). Same training
  -- intent as side plank.
  -- Forearms 1.0 — same grip demand as farmer's, scaled to one hand
  -- (effectively double the per-hand load for equivalent total weight).
  -- Abs 0.5 — bracing + anti-flexion while walking under unilateral load.
  -- Traps_upper 0.5 — supporting the loaded side. Less than farmer's
  -- because only one side is loaded; still meaningful.
  -- Lower_back 0.25 — same role as farmer's.
  '[
    {"muscle_id": "obliques",    "weight": 1.0},
    {"muscle_id": "forearms",    "weight": 1.0},
    {"muscle_id": "abs",         "weight": 0.5},
    {"muscle_id": "traps_upper", "weight": 0.5},
    {"muscle_id": "lower_back",  "weight": 0.25}
  ]'::jsonb,
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
  -- Quads 1.0 — primary mover in the takeoff.
  -- Glutes 1.0 — co-target via hip extension at takeoff. Two 1.0s
  -- because plyometric power is generated jointly by both — neither
  -- alone limits the lift.
  -- Calves 0.5 — meaningful contribution to ankle plantarflexion at
  -- takeoff. Higher weight than in slow-tempo squat patterns because
  -- the ballistic nature recruits calves more heavily.
  -- Hamstrings 0.25 — assist hip extension; not primary but tracked
  -- because plyometric work fatigues hamstrings noticeably.
  '[
    {"muscle_id": "quads",      "weight": 1.0},
    {"muscle_id": "glutes",     "weight": 1.0},
    {"muscle_id": "calves",     "weight": 0.5},
    {"muscle_id": "hamstrings", "weight": 0.25}
  ]'::jsonb,
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
  -- Quads 1.0 — primary driver of forward propulsion; sled push is
  -- famous for building quad capacity.
  -- Glutes 1.0 — co-target; hip extension drives each step.
  -- Calves 0.5 — ankle plantarflexion contributes to drive.
  -- Hamstrings 0.5 — synergist in hip extension under heavy load.
  -- Lower_back 0.25 — supports the spine in the bent-over driving
  -- position.
  '[
    {"muscle_id": "quads",      "weight": 1.0},
    {"muscle_id": "glutes",     "weight": 1.0},
    {"muscle_id": "calves",     "weight": 0.5},
    {"muscle_id": "hamstrings", "weight": 0.5},
    {"muscle_id": "lower_back", "weight": 0.25}
  ]'::jsonb,
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
  -- Quads 0.5 — drive phase. Not 1.0 because rowing isn't quad-limiting
  -- the way a squat is; quads contribute but legs are typically the
  -- strongest part of a rowing chain.
  -- Glutes 0.5 — hip extension on drive.
  -- Hamstrings 0.5 — synergist in hip extension.
  -- Lats 0.5 — finish of the drive (arms pull bar to torso).
  -- Rhomboids 0.5 — scapular retraction at finish.
  -- Lower_back 0.5 — supports the catch position and finish.
  -- Biceps 0.25 — assist arm pull; not primary but tracked.
  -- Abs 0.25 — bracing throughout the stroke.
  -- No 1.0s — rowing is the canonical "no single muscle limits the
  -- exercise" movement. The whole chain works together.
  '[
    {"muscle_id": "quads",       "weight": 0.5},
    {"muscle_id": "glutes",      "weight": 0.5},
    {"muscle_id": "hamstrings",  "weight": 0.5},
    {"muscle_id": "lats",        "weight": 0.5},
    {"muscle_id": "rhomboids",   "weight": 0.5},
    {"muscle_id": "lower_back",  "weight": 0.5},
    {"muscle_id": "biceps",      "weight": 0.25},
    {"muscle_id": "abs",         "weight": 0.25}
  ]'::jsonb,
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
  -- Quads 0.5 — drive phase of pedal stroke.
  -- Glutes 0.5 — hip extension on drive.
  -- Hamstrings 0.5 — pull phase (clipped pedals not assumed; hamstrings
  -- still work via hip flexion-extension cycle).
  -- Calves 0.25 — ankle stabilization.
  -- Pectorals 0.25 — push phase of arm cycle.
  -- Lats 0.25 — pull phase of arm cycle.
  -- Front_delts 0.25 — push phase.
  -- Air bike's distinguishing feature is that it loads everything
  -- moderately rather than anything heavily — there's no "primary
  -- mover" target. This is what makes it an effective conditioning
  -- tool but NOT a strength tool. Reflected in muscle weightings
  -- (no 1.0s, mostly 0.5s and 0.25s).
  '[
    {"muscle_id": "quads",       "weight": 0.5},
    {"muscle_id": "glutes",      "weight": 0.5},
    {"muscle_id": "hamstrings",  "weight": 0.5},
    {"muscle_id": "calves",      "weight": 0.25},
    {"muscle_id": "chest",       "weight": 0.25},
    {"muscle_id": "lats",        "weight": 0.25},
    {"muscle_id": "front_delts", "weight": 0.25}
  ]'::jsonb,
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
  -- Calves 1.0 — primary muscle, by a wide margin. Jump rope is the
  -- canonical calf endurance/capacity builder. Per §2 "the muscle that
  -- limits the exercise" — calves cramp before anything else fatigues.
  -- Quads 0.25 — minimal knee flexion absorbs each landing.
  -- Forearms 0.25 — wrist work to spin the rope on speed-rope style.
  -- Note: heart-rate and respiratory demand are not muscle weights;
  -- captured in the conditioning modality, not as muscle entries.
  '[
    {"muscle_id": "calves",   "weight": 1.0},
    {"muscle_id": "quads",    "weight": 0.25},
    {"muscle_id": "forearms", "weight": 0.25}
  ]'::jsonb,
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
--   1. TODO(goals): goal-conditional metrics layer for conditioning rows
--      (sled push, rower, air bike) — calories as secondary metric for
--      cut-goal users.
--   2. Flag for §10 vocabulary: a "different_muscle_length_stimulus" reason
--      could be cleaner than same_pattern_different_equipment for
--      seated→lying leg curl. Same applies to incline DB curl ↔ BB curl.
--   3. Flag for §4 vocabulary: "double_overhand" grip value (KB swing) and
--      "grip_width" key (close-grip bench) used here without prior
--      precedent. Either add to §4 or revise these rows.
--   4. Flag for §3 demands: 'power' modality and 'conditioning' modality
--      used implicitly throughout — these are training_modality values
--      (TEXT[] column) not §3 demands tags, but worth confirming the
--      conventions doc captures the controlled vocabulary for
--      training_modality somewhere. Spot-checked batch 4: 'power' and
--      'conditioning' both used, no doc — pre-existing gap, not a
--      batch-5 regression.
