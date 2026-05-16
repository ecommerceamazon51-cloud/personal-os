-- =============================================================================
-- Migration: Add 3 specialty joint_health exercises + strengthen straight arm pulldown substitutes
-- =============================================================================
-- Purpose: Add the following exercises used in the current WORKOUTS split
--   (Day 2 — Legs Quad Dominant) that were missing from the exercises table:
--
--   #72  Sissy Squat         (Day 2, VMO/quad joint health)
--   #73  Tibialis Raise      (Day 2, tibialis anterior joint health)
--   #74  Poliquin Step-Up    (Day 2, VMO rehabilitation)
--
--   All three use training_modality: ['hypertrophy', 'joint_health'].
--   They are prescribed primarily for joint integrity — VMO development,
--   patellar tendon strengthening, shin splint prevention, ankle stability —
--   but they do build muscle. The dual modality reflects this per §15.
--
--   Also strengthens the Straight Arm Pulldown (#68) substitution graph:
--   PR #15 left it with only one outbound edge (→ Pull-Up). This PR adds:
--     #68 → #22 (Lat Pulldown): 0.70, same_muscles_different_pattern
--     #68 → #23 (Seated Cable Row): 0.55, same_muscles_different_pattern
--
-- ⚠️  MUSCLE ID GAP — tibialis_anterior:
--   Tibialis Raise's primary muscle (tibialis anterior) does NOT exist in the
--   muscles table. The v2 taxonomy (67 rows: 15 groups, 44 heads, 8 singletons)
--   covers calves_gastrocnemius and calves_soleus but has no anterior
--   compartment muscles (tibialis anterior, peroneals). Exercise #73 is
--   inserted with muscles: '[]' and will not contribute to volume tracking
--   until a follow-up PR extends the taxonomy. Documented in PR description.
--
-- IMPORTANT: Run in Supabase SQL Editor as a single block.
--   All INSERTs use ON CONFLICT DO NOTHING — safe to re-run.
--   Additive-only migration; nothing is truncated or deleted.
-- =============================================================================

BEGIN;

-- =============================================================================
-- NEW EXERCISE FAMILIES
-- =============================================================================
-- Sissy Squat family — new; mechanically distinct from all existing exercises.
--   Bilateral, knee_extension pattern, hip stays in extension throughout.
--   RF does NOT get the §14.1 two-joint discount (key authoring distinction):
--     aaaaaaf3-f3f3-f3f3-f3f3-f3f3f3f3f3f3
--
-- Tibialis Raise family — new; no equivalent in current catalog.
--   Only anterior-compartment exercise in the DB:
--     aaaaaaf4-f4f4-f4f4-f4f4-f4f4f4f4f4f4
--
-- Poliquin Step-Up family — new; small-step unilateral VMO drill.
--   Distinct from BSS (#4 family) and standard step-ups: the small step height
--   restricts ROM to terminal knee extension, making it knee-isolation rather
--   than a compound lunge-pattern movement despite the step-up form:
--     aaaaaaf5-f5f5-f5f5-f5f5-f5f5f5f5f5f5


-- ─── 72. Sissy Squat ─────────────────────────────────────────────────────────
-- Bilateral knee bend where the torso leans back and the knees travel
-- maximally forward over the toes. The hip stays in extension throughout —
-- no hip flexion occurs. The load is bodyweight or a weighted vest/plate.
--
-- Defining mechanical feature: rectus femoris does NOT get the §14.1 two-
-- joint discount here. In a regular squat, hip flexion at the bottom shortens
-- RF from above, partially canceling the knee-extension stimulus. In the sissy
-- squat, the hip stays in EXTENSION, placing RF at a LONGER working length
-- than in any squat variant. RF therefore gets 1.0, matching the vasti —
-- the opposite of the 0.85 it receives in the barbell back squat (#1).
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
  'aaaaaaaa-0072-0000-0000-000000000001',
  'Sissy Squat',
  ARRAY['sissy squat', 'bodyweight sissy squat', 'KOT sissy squat'],
  'lifting',
  'knee_extension', NULL, 'bilateral',
  -- knee_extension: single-joint movement at the knee only; no hip drive.
  -- Classified the same as leg extension (#25) — pure quad isolation despite
  -- appearing visually similar to a squat.
  --
  -- quads_rectus_femoris 1.0 — the §14.1 two-joint discount does NOT apply
  --   here. In a regular squat, hip flexion partially shortens RF (it's
  --   biarticular at the hip), reducing its stimulus to ~0.85 (#1). In the
  --   sissy squat, the hip stays in EXTENSION throughout: RF is not shortened
  --   from the hip side and works at a longer effective length alongside the
  --   vasti. This is the defining mechanical distinction that makes the sissy
  --   squat a uniquely strong rectus femoris exercise.
  --
  -- quads_vastus_lateralis 1.0, quads_vastus_medialis 1.0,
  -- quads_vastus_intermedius 1.0 — all vasti contribute through the full
  --   deep knee flexion / extension ROM. VMO (vastus medialis) emphasis is
  --   particularly strong at terminal knee extension at the top of the rep.
  --
  -- calves_gastrocnemius 0.25, calves_soleus 0.25 — the foot is the pivot
  --   point for the entire movement. Both calf heads stabilize the ankle
  --   under the body's weight through the extreme forward knee travel.
  --   Qualifies under §2 comprehensive 0.25: ROM under load.
  --
  -- spinal_erectors 0.3 — maintaining the lean-back incline throughout the
  --   set requires active erector bracing. Isometric contribution rather than
  --   dynamic strength work, but notable per §2 (real demand, sustained load).
  '[
    {"muscle_id": "quads_rectus_femoris",     "weight": 1.0},
    {"muscle_id": "quads_vastus_lateralis",   "weight": 1.0},
    {"muscle_id": "quads_vastus_medialis",    "weight": 1.0},
    {"muscle_id": "quads_vastus_intermedius", "weight": 1.0},
    {"muscle_id": "calves_gastrocnemius",     "weight": 0.25},
    {"muscle_id": "calves_soleus",            "weight": 0.25},
    {"muscle_id": "spinal_erectors",          "weight": 0.3}
  ]'::jsonb,
  '{
    "quads_rectus_femoris": "The sissy squat is unique among quad exercises: the hip stays in extension throughout, so rectus femoris does NOT get its usual two-joint discount (§14.1). With the hip neither flexing nor shortening RF from above, it works at a longer effective length alongside the vasti. RF gets 1.0 here vs 0.85 in the back squat — one of the only exercises where RF trains on par with the vasti.",
    "quads_vastus_medialis": "VMO works hardest at terminal knee extension — the last ~30° as you drive to full lockout at the top. This is the prehab mechanism: VMO underdevelopment is a leading cause of patellar tracking issues and anterior knee pain. The slow eccentric into deep flexion pre-loads the VMO for a strong concentric contraction at the top.",
    "spinal_erectors": "The lean-back position requires sustained isometric erector bracing throughout every set. Not a primary strength demand — more like holding a plank with heavy quad loading. Track it as a real but minor contribution at 0.3."
  }'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  -- bodyweight equipment; load_increment per §5 bodyweight-loaded defaults.
  -- Progression: add a weighted vest or hold a plate to the chest.
  ARRAY['hypertrophy', 'joint_health'],
  -- hypertrophy: genuine quad/RF mass builder, especially for the rectus
  --   femoris and VMO, which few exercises train at this length.
  -- joint_health: VMO development, patellar tendon strengthening, KOT-style
  --   joint prep. Knees-over-toes movement under progressive load is the core
  --   prescription of the joint health / ATG movement for patellar health.
  'isolation', 'late',
  -- isolation: single-joint knee extension only; no hip drive involved.
  -- late: specialty movement, prescribe after main compound quad work.
  'weight_x_reps', TRUE, TRUE,
  -- weight_x_reps per user instruction; relative_to_bodyweight TRUE because
  --   bodyweight is the working load (same rationale as pull-ups, dips, BSS).
  -- progression_eligible TRUE: progresses via vest weight, tempo, and ROM
  --   depth. §15 note: joint_health modality does not imply FALSE.
  ARRAY['deep_knee_flexion', 'ankle_dorsiflexion'],
  -- deep_knee_flexion: knees bend to or past 90° through the full ROM.
  -- ankle_dorsiflexion: extreme forward knee travel requires significant
  --   ankle ROM; lifters with poor dorsiflexion cannot perform this safely.
  -- NOTE: The user prompt requested 'knees_over_toes_tolerance' as a demand
  --   tag. This tag does NOT exist in the §3 demands vocabulary. Using
  --   deep_knee_flexion + ankle_dorsiflexion as the closest valid equivalents.
  --   Flag for review if 'knees_over_toes_tolerance' should be added as a
  --   16th canonical demand tag.
  '[]'::jsonb,
  'aaaaaaf3-f3f3-f3f3-f3f3-f3f3f3f3f3f3',
  NULL,
  -- No meaningful variation axis at this stage. The bodyweight vs weighted-
  -- vest dimension is captured via the metric + relative_to_bodyweight fields.
  -- A tempo attribute (paused, eccentric) could be added as a variation row
  -- in the future if a tempo-specific sissy squat is warranted.
  'stretched',
  -- Quads are at extreme length at the bottom of the rep: deep knee flexion
  -- with the hip in extension (not shortening RF from above). This is one of
  -- the deepest quad stretch positions achievable under load — the programming
  -- rationale alongside leg extension's shortened-bias for full-ROM quad coverage.
  'system', FALSE
);


-- ─── 73. Tibialis Raise ──────────────────────────────────────────────────────
-- Ankle dorsiflexion exercise: foot pulled toward the shin against resistance.
-- Standard form: tib bar strapped across the shin, foot starting plantarflexed
-- (toes down), then dorsiflex to bring toes up. Also performed standing with
-- heels against a wall and toes raising against bodyweight.
--
-- ⚠️  MUSCLE ID GAP: tibialis_anterior does NOT exist in the v2 muscles table.
--   The 67-row taxonomy (15 groups, 44 heads, 8 singletons) covers the calves
--   (calves_gastrocnemius, calves_soleus) but has no anterior compartment
--   muscles. tibialis_anterior is the sole primary mover of dorsiflexion;
--   the peroneals provide minor stabilization but also lack a muscle_id.
--
--   Resolution: muscles column set to '[]' (empty). This exercise will not
--   contribute to volume tracking until a follow-up PR adds tibialis_anterior
--   (and optionally peroneals) to the muscles table. The exercise row is still
--   inserted so the WORKOUTS dict can reference it by exercise_id.
--
--   Muscles that SHOULD be listed once the taxonomy is extended:
--     tibialis_anterior: 1.0 — sole primary dorsiflexor; the entire training
--       purpose of this exercise. Fully isolated and progressively loaded.
--     [peroneals]: 0.25 — stabilization during the dorsiflexion arc; would
--       require a new muscle_id or group added to the taxonomy.
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
  'aaaaaaaa-0073-0000-0000-000000000001',
  'Tibialis Raise',
  ARRAY['tib raise', 'tibialis anterior raise', 'dorsiflexion raise', 'tib bar raise'],
  'lifting',
  'ankle_plantarflexion', NULL, 'bilateral',
  -- ankle_plantarflexion: closest available movement_pattern for an ankle-
  --   dominant exercise. The actual movement is dorsiflexion (the reverse of
  --   plantarflexion), but no 'ankle_dorsiflexion' value exists in the enum.
  --   Using ankle_plantarflexion as the anatomical-region classifier.
  --   TODO: if the movement_pattern enum is extended, 'ankle_dorsiflexion'
  --   would be the correct specific value for this exercise.
  --
  -- ⚠️ EMPTY: see gap note above. Update after adding tibialis_anterior
  --   to the muscles table in a follow-up PR.
  '[]'::jsonb,
  -- ⚠️ NULL: no muscle rows to reference yet.
  -- When tibialis_anterior is added, populate:
  -- {
  --   "tibialis_anterior": "Peak stretch at the start (foot fully plantarflexed).
  --     Pull the toes toward the shin; the entire stimulus is in the anterior
  --     shin. The tib raise is the direct antagonist to the calf raise —
  --     program both to balance the ankle joint and prevent shin splints."
  -- }
  NULL,
  'bodyweight', NULL, 2.50, 1.25,
  -- equipment_primary bodyweight (wall variant is the baseline starting point).
  -- Progression: tib bar strapped across the shin for direct progressive overload.
  -- equipment_specific NULL because the tib bar is an optional upgrade, not
  -- required equipment; bodyweight wall variant is universally accessible.
  ARRAY['hypertrophy', 'joint_health'],
  -- joint_health primary: tibialis anterior is the primary muscle for shin
  --   splint prevention, ankle stability under dynamic loading (jumping, landing,
  --   running), and knee health via the kinetic chain. Underdeveloped tib
  --   anterior is one of the most common causes of athletic ankle/knee injuries.
  -- hypertrophy: tib anterior hypertrophies under progressive load; the tib
  --   bar variant allows the same progressive overload model as calf raises.
  'isolation', 'late',
  -- isolation: single-joint ankle dorsiflexion; no other joints involved.
  'weight_x_reps', TRUE, TRUE,
  -- relative_to_bodyweight TRUE (bodyweight is the working load in the wall
  -- variant; tib bar adds external load on top of bodyweight).
  ARRAY[]::TEXT[],
  -- No standard demands tags apply. The dorsiflexion ROM required is the
  -- point of the exercise, not a prerequisite demand on the lifter.
  '[]'::jsonb,
  'aaaaaaf4-f4f4-f4f4-f4f4-f4f4f4f4f4f4',
  NULL,
  'stretched',
  -- Peak tension at the start of the rep when the foot is fully plantarflexed
  -- (toes pointing down). Tibialis anterior is at full stretch in this position
  -- and shortens as the foot dorsiflexes upward. Loaded position: stretched.
  'system', FALSE
);


-- ─── 74. Poliquin Step-Up ────────────────────────────────────────────────────
-- Slow, deliberate step-up onto a small platform (4–6 inches). The small step
-- height deliberately restricts the movement to near-terminal knee extension
-- range — where VMO (vastus medialis oblique) is most active — while minimizing
-- hip extension contribution (glutes). The non-working leg is unsupported
-- (dangles), creating meaningful lateral hip stabilization demand.
--
-- Named after Charles Poliquin, who prescribed it for VMO development and knee
-- rehabilitation. The slow eccentric (3–4 seconds) is the mechanism: it keeps
-- VMO under tension throughout the descent rather than allowing a quick drop.
--
-- Per §13 unilateral convention: weights describe the working leg only.
-- The user logs "4 sets of Poliquin Step-Ups" = 4 sets per leg; both sides
-- need recovery and the recommender counts each working set toward volume.
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
  'aaaaaaaa-0074-0000-0000-000000000001',
  'Poliquin Step-Up',
  ARRAY['poliquin step up', 'VMO step-up', 'short step-up', 'terminal step-up'],
  'lifting',
  'lunge_split', NULL, 'unilateral',
  -- lunge_split: step-up pattern — one leg on platform, body elevated by
  --   the working leg. Per §13 unilateral convention, weights are for the
  --   working leg only.
  --
  -- quads_vastus_medialis 1.0 — VMO is the explicit training target.
  --   The small step height (4–6 inches) restricts the movement to the
  --   terminal knee extension range where VMO is most active. This is the
  --   Poliquin step-up's sole defining programming purpose.
  --
  -- quads_vastus_lateralis 0.7, quads_vastus_intermedius 0.7 — contribute
  --   throughout the step-up ROM; not the primary emphasis but genuinely
  --   loaded through the movement.
  --
  -- quads_rectus_femoris 0.6 — slight discount vs the vasti because the
  --   hip flexes a small amount as the working leg steps up (§14.1 two-joint
  --   rule applies here, unlike the sissy squat). Less discount than a full
  --   squat (0.85 there) because the step-up ROM is short.
  --
  -- glutes_max 0.4 — hip extension on the working leg to complete the step.
  --   Less demand than BSS because the small step height limits hip ROM.
  --
  -- glutes_medius 0.5, glutes_minimus 0.35 — unilateral pattern per §14.2.
  --   The dangling non-working leg creates pelvic drop demand; glute medius
  --   fires hard on the working side to maintain level pelvis throughout.
  --
  -- adductors_magnus 0.3 — working leg stabilization during the controlled
  --   eccentric descent, particularly as the leg controls lateral tracking.
  --
  -- hamstrings (3 heads) 0.25 each — knee joint co-contraction during the
  --   slow eccentric through terminal extension. No significant hamstring
  --   lengthening; qualifies as notable stabilization per §2 comprehensive
  --   0.25 rule (real ROM and load, even if small).
  --
  -- calves 0.25 each — ankle stabilization on the platform surface during
  --   the controlled movement.
  --
  -- obliques 0.3 — anti-rotation demand under unilateral loading, per §14.2.
  '[
    {"muscle_id": "quads_vastus_medialis",        "weight": 1.0},
    {"muscle_id": "quads_vastus_lateralis",       "weight": 0.7},
    {"muscle_id": "quads_vastus_intermedius",     "weight": 0.7},
    {"muscle_id": "quads_rectus_femoris",         "weight": 0.6},
    {"muscle_id": "glutes_max",                   "weight": 0.4},
    {"muscle_id": "glutes_medius",                "weight": 0.5},
    {"muscle_id": "glutes_minimus",               "weight": 0.35},
    {"muscle_id": "adductors_magnus",             "weight": 0.3},
    {"muscle_id": "hamstrings_bf_long",           "weight": 0.25},
    {"muscle_id": "hamstrings_semitendinosus",    "weight": 0.25},
    {"muscle_id": "hamstrings_semimembranosus",   "weight": 0.25},
    {"muscle_id": "calves_gastrocnemius",         "weight": 0.25},
    {"muscle_id": "calves_soleus",                "weight": 0.25},
    {"muscle_id": "obliques",                     "weight": 0.3}
  ]'::jsonb,
  '{
    "quads_vastus_medialis": "The small step height (4–6 inches) is intentional — it restricts the movement to terminal knee extension, where VMO is most active. Drive through the heel as you straighten the working leg at the top and feel the inner quad squeeze at lockout. Use a 3–4 second eccentric to keep VMO under load during descent. This is the textbook VMO rehab exercise for patellar tracking and anterior knee pain.",
    "glutes_medius": "The dangling non-working leg creates a pelvic drop demand that fires glute medius hard on the working side — per §14.2, unilateral exercises train glute medius meaningfully even when the exercise feels quad-focused. Consciously keep the pelvis level throughout rather than allowing it to hike toward the trailing leg side."
  }'::jsonb,
  'bodyweight', NULL, 2.50, 1.25,
  -- bodyweight equipment; bodyweight loaded increments per §5.
  -- Progression: hold light dumbbells at the sides or wear a weighted vest.
  ARRAY['hypertrophy', 'joint_health'],
  -- hypertrophy: VMO and quad hypertrophy under progressive resistance.
  -- joint_health: VMO underdevelopment is the primary cause of patellar
  --   tracking issues and anterior knee pain. The Poliquin step-up is the
  --   standard VMO rehabilitation prescription for these conditions.
  'isolation', 'late',
  -- isolation per user spec: the small step minimizes hip drive, making
  --   this knee-dominant despite being a step-up pattern. Classify as
  --   isolation for the purposes of programming role (not a compound movement
  --   in the way a BSS or leg press is).
  'weight_x_reps', TRUE, TRUE,
  -- relative_to_bodyweight TRUE (bodyweight is part of the working load).
  ARRAY['unilateral_balance'],
  -- unilateral_balance: standing on one leg on a small platform requires
  --   single-leg balance and stability throughout the controlled eccentric.
  '[]'::jsonb,
  'aaaaaaf5-f5f5-f5f5-f5f5-f5f5f5f5f5f5',
  NULL,
  'shortened',
  -- VMO emphasis comes at terminal knee extension (the top of the rep), which
  -- is the shortened/contracted position of the quads. Contrast with sissy
  -- squat (#72, loaded_position: stretched) — together they cover the full
  -- VMO ROM: stretched bias at depth (sissy squat) + shortened bias at lockout
  -- (Poliquin step-up).
  'system', FALSE
);


-- =============================================================================
-- SUBSTITUTION GRAPH ADDITIONS
-- =============================================================================
-- 1. Straight Arm Pulldown (#68): strengthens the single outbound edge left
--    by PR #15 (→ Pull-Up only).
-- 2. Sissy Squat (#72): outbound to quad alternatives + inbound from those.
-- 3. Tibialis Raise (#73): one weak outbound (tib anterior not substitutable
--    by anything in the current catalog; documented gap).
-- 4. Poliquin Step-Up (#74): outbound to VMO alternatives + inbound from those.
-- All use ON CONFLICT DO NOTHING (PK = (exercise_id, substitute_id)).
-- =============================================================================

INSERT INTO public.exercise_substitutes (exercise_id, substitute_id, similarity_score, reason)
VALUES

  -- ── 68. Straight Arm Pulldown — additional outbound edges ──────────────────
  -- PR #15 left #68 with only one outbound edge (→ Pull-Up #2). Two edges
  -- below improve substitute picker coverage for users who can't do pull-ups
  -- or whose cable station for straight arm pulldowns is occupied.
  ('aaaaaaaa-0068-0000-0000-000000000001', 'aaaaaaaa-0022-0000-0000-000000000001', 0.70, 'same_muscles_different_pattern'),
  -- → Lat Pulldown (#22): same cable, same lat-dominant target. Lat pulldown
  --   adds elbow flexion and uses more loading, but trains the same primary
  --   muscle (lats) with comparable cable tension. 0.70 because the lat target
  --   is nearly identical but the movement mechanics differ.
  ('aaaaaaaa-0068-0000-0000-000000000001', 'aaaaaaaa-0023-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  -- → Seated Cable Row (#23): same broad lat target, horizontal vs vertical
  --   pull. Weaker substitute (adds rhomboids/traps, changes pattern) but
  --   covers the "all vertical cable lat stations are in use" scenario.

  -- ── 72. Sissy Squat — outbound ───────────────────────────────────────────
  ('aaaaaaaa-0072-0000-0000-000000000001', 'aaaaaaaa-0007-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),
  -- → Front Squat (#7): same quad-dominant target; compound alternative when
  --   sissy squat is too knee-stressful or the equipment (wall, step) isn't
  --   accessible. Lower score: front squat adds hip extension and axial loading
  --   — a much more demanding and different movement.
  ('aaaaaaaa-0072-0000-0000-000000000001', 'aaaaaaaa-0004-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  -- → Bulgarian Split Squat (#4): unilateral quad/VMO alternative with more
  --   loading potential. BSS has significant hip involvement (unlike sissy
  --   squat), so the quad isolation purpose is partially lost, but the quad
  --   volume is comparable.
  ('aaaaaaaa-0072-0000-0000-000000000001', 'aaaaaaaa-0074-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  -- → Poliquin Step-Up (#74): VMO/knee-isolation pair. Both target quads at
  --   the knee with joint_health rationale. They differ in loaded_position
  --   (stretched vs shortened) — they complement more than substitute — but
  --   the quad target overlap justifies 0.65.

  -- ── 72. Sissy Squat — inbound ────────────────────────────────────────────
  ('aaaaaaaa-0007-0000-0000-000000000001', 'aaaaaaaa-0072-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),
  -- Front Squat → Sissy Squat: isolation option when compound quad volume
  --   is sufficient and the user wants direct RF/VMO work without hip fatigue.
  ('aaaaaaaa-0004-0000-0000-000000000001', 'aaaaaaaa-0072-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  -- BSS → Sissy Squat: bilateral isolation option when unilateral fatigue
  --   is a concern, or to add RF stimulus that BSS undertrains.

  -- ── 73. Tibialis Raise — outbound ────────────────────────────────────────
  -- NOTE: tibialis anterior is not meaningfully trained by any other exercise
  --   in the current catalog. This is the weakest substitution case in the DB.
  --   The edge below meets the §10 minimum-one-substitute requirement while
  --   explicitly acknowledging the substitute is poor. The gap should be
  --   addressed by adding anterior compartment exercises (Nordic heel walks,
  --   etc.) to the catalog in a future PR.
  ('aaaaaaaa-0073-0000-0000-000000000001', 'aaaaaaaa-0043-0000-0000-000000000001', 0.30, 'same_muscles_different_pattern'),
  -- → Walking Lunge — DB (#43): lunges involve tib anterior stabilization
  --   during the dynamic step but as an incidental demand, not the training
  --   target. This is a weak substitute (0.30) — listed to satisfy the minimum
  --   coverage rule, not as a genuine recommendation. A user who needs to
  --   sub tibialis anterior work has no good option in the current catalog.

  -- ── 74. Poliquin Step-Up — outbound ──────────────────────────────────────
  ('aaaaaaaa-0074-0000-0000-000000000001', 'aaaaaaaa-0004-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  -- → Bulgarian Split Squat (#4): unilateral quad/VMO alternative with more
  --   loading potential. BSS is the progression when the step-up becomes easy;
  --   both are unilateral quad exercises with similar glute medius demand.
  ('aaaaaaaa-0074-0000-0000-000000000001', 'aaaaaaaa-0072-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  -- → Sissy Squat (#72): same VMO/quad joint_health pair. Bilateral vs
  --   unilateral, stretched vs shortened — they cover complementary ROM halves
  --   but the quad/VMO target overlap justifies 0.65.
  ('aaaaaaaa-0074-0000-0000-000000000001', 'aaaaaaaa-0025-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  -- → Leg Extension (#25): machine isolation alternative when bodyweight
  --   step-up isn't accessible or single-leg balance is a limiting factor.

  -- ── 74. Poliquin Step-Up — inbound ───────────────────────────────────────
  ('aaaaaaaa-0004-0000-0000-000000000001', 'aaaaaaaa-0074-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  -- BSS → Poliquin Step-Up: regression when full BSS ROM is too demanding,
  --   or to isolate terminal extension specifically without the full unilateral
  --   squat load.
  ('aaaaaaaa-0025-0000-0000-000000000001', 'aaaaaaaa-0074-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern')
  -- Leg Extension → Poliquin Step-Up: functional alternative to the machine
  --   isolation; trains VMO with the addition of unilateral balance and
  --   stabilization demands.

ON CONFLICT DO NOTHING;

COMMIT;
