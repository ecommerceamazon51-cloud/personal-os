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
