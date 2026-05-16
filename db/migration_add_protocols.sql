-- =============================================================================
-- Migration: Add 10 Mobility/Skill/Conditioning Protocols + Fix Jump Rope
-- =============================================================================
-- Purpose: Insert 10 non-hypertrophy protocols used in Day 4 (Combat/Active
--   Recovery) and Day 0 (Recovery + Mobility) into the exercises table.
--   These are logging targets for the WORKOUTS dict, not volume-tracking
--   exercises. None carry the 'hypertrophy' modality; they will not pollute
--   per-head volume totals.
--
--   After this migration, all WORKOUTS items should resolve to exercise_ids.
--
--   Exercises added (IDs 75–84):
--     #75  Shadow Boxing              ['skill', 'conditioning']
--     #76  Heavy Bag Rounds           ['skill', 'conditioning', 'power']
--     #77  Core Circuit               ['stability']
--     #78  Stretching / Mobility      ['mobility']
--     #79  Walk / Light Cardio        ['conditioning']
--     #80  Foam Roll Full Body        ['mobility']
--     #81  Hip Flexor Stretch         ['mobility', 'joint_health']
--     #82  Thoracic Extension         ['mobility', 'joint_health']
--     #83  Dead Hang                  ['mobility', 'joint_health']
--     #84  Chin Tucks + Wall Angels   ['mobility', 'joint_health']
--
--   Also fixes:
--     #65  Jump Rope — adds 'plyometric' to training_modality.
--          movement_pattern_primary is already 'plyometric'; the modality
--          array only had ['conditioning', 'power']. Corrected here.
--
-- Muscle ID checks (run before authoring, confirmed before insert):
--   rectus_abdominis     ✅ singleton (PR A taxonomy, remains in v2)
--   obliques             ✅ singleton (PR A taxonomy)
--   transverse_abdominis ✅ singleton (PR A taxonomy)
--   forearms_grip        ✅ head under forearms group (PR A taxonomy)
--
-- NOTE on substitution edges: none added in this PR. Protocols are not
--   meaningfully substitutable for each other in the hypertrophy sense —
--   foam rolling is not a substitute for dead hangs. The substitution graph
--   is left empty for all 10 new rows. Add edges in a follow-up if needed.
--
-- IMPORTANT: Run in Supabase SQL Editor as a single block.
--   All INSERTs use ON CONFLICT DO NOTHING — safe to re-run.
--   Additive-only migration; the UPDATE on Jump Rope is idempotent.
--   No TRUNCATE, no deletes.
-- =============================================================================

BEGIN;


-- =============================================================================
-- PART 1: Fix Jump Rope (#65) — add 'plyometric' to training_modality
-- =============================================================================
-- movement_pattern_primary was already 'plyometric' when #65 was authored.
-- The training_modality array only had ['conditioning', 'power']. Each bounce
-- is a plyometric ground contact; the modality should reflect that so users
-- can filter for plyometric exercises and get Jump Rope.

UPDATE public.exercises
SET
  training_modality = ARRAY['conditioning', 'power', 'plyometric'],
  updated_at = NOW()
WHERE exercise_id = 'aaaaaaaa-0065-0000-0000-000000000001';


-- =============================================================================
-- PART 2: New exercise families
-- =============================================================================
-- Combat sports family — Shadow Boxing and Heavy Bag Rounds are genuine
-- variations of the same modality (unarmed striking practice). Both use
-- the same movement pattern and skill set; the distinction is target
-- (air vs bag) and resistance (none vs impact).
--   aaaaaaf6-f6f6-f6f6-f6f6-f6f6f6f6f6f6
--
-- All other protocols receive NULL exercise_family_id — they are standalone
-- entries that have no meaningful variation family (e.g. "Foam Roll Lower
-- Body" is not a variation family worth seeding yet).


-- ─── 75. Shadow Boxing ───────────────────────────────────────────────────────
-- Standing, free-movement striking at no resistance. Used for footwork,
-- technique, and low-level conditioning.
--
-- movement_pattern 'skill': the dominant activity is technique practice —
--   footwork, head movement, combination sequencing. No single movement
--   pattern (squat, hinge, etc.) captures what shadow boxing actually is.
--   'skill' is the correct enum value per the schema's "Other" category.
--
-- equipment_primary 'none': shadow boxing requires zero equipment
--   (unlike Heavy Bag which needs a bag). Boxing gloves are optional
--   accessories and not tracked here.
--
-- performance_metric 'time': the standard prescription is "X rounds of
--   Y minutes" or total time. Simpler than rounds_x_duration for a
--   free-moving drill where round structure varies.
--
-- progression_eligible TRUE: round duration and total volume both progress.
--   A beginner might do 2 rounds x 2 min; advanced 6 rounds x 3 min.
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
  'aaaaaaaa-0075-0000-0000-000000000001',
  'Shadow Boxing',
  ARRAY['shadow boxing', 'shadowboxing', 'shadow work'],
  'martial_arts',
  'skill', NULL, 'bilateral',
  '[]'::jsonb,
  -- muscles: empty. Shadow boxing is skill practice and low-level conditioning.
  -- No individual muscle head is trained in a way that produces hypertrophy
  -- signal worth tracking. The cardiovascular/neurological adaptations are
  -- captured by the modality and performance_metric, not muscle weights.
  NULL,
  'none', NULL, NULL, NULL,
  ARRAY['skill', 'conditioning'],
  'accessory', 'anywhere',
  'time', TRUE, FALSE,
  ARRAY['dynamic_skill'],
  '[]'::jsonb,
  'aaaaaaf6-f6f6-f6f6-f6f6-f6f6f6f6f6f6', NULL,
  'none',
  'system', FALSE
)
ON CONFLICT (exercise_id) DO NOTHING;


-- ─── 76. Heavy Bag Rounds ────────────────────────────────────────────────────
-- Striking practice on a heavy bag — punches, kicks, elbows. Adds resistance
-- (impact force feedback) and power output relative to shadow boxing.
--
-- equipment_primary 'bag': exists in the exercise_equipment enum.
--
-- training_modality adds 'power' (vs shadow boxing): striking a heavy bag
--   is ballistic work with intent to produce peak force, not just technique.
--
-- Same family as Shadow Boxing (#75): both are combat sports striking
--   practice. The bag is what distinguishes them.
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
  'aaaaaaaa-0076-0000-0000-000000000001',
  'Heavy Bag Rounds',
  ARRAY['heavy bag', 'bag work', 'bag rounds'],
  'martial_arts',
  'skill', NULL, 'bilateral',
  '[]'::jsonb,
  -- muscles: empty. Per-strike force modeling is too variable to express
  -- as head weights — it depends entirely on which strike is thrown.
  -- The conditioning demand is captured by the modality.
  NULL,
  'bag', NULL, NULL, NULL,
  ARRAY['skill', 'conditioning', 'power'],
  'accessory', 'anywhere',
  'time', TRUE, FALSE,
  ARRAY['dynamic_skill'],
  '[]'::jsonb,
  'aaaaaaf6-f6f6-f6f6-f6f6-f6f6f6f6f6f6', NULL,
  'none',
  'system', FALSE
)
ON CONFLICT (exercise_id) DO NOTHING;


-- ─── 77. Core Circuit ────────────────────────────────────────────────────────
-- Generic placeholder for a timed circuit of core exercises — planks,
-- hollow holds, mountain climbers, etc. Composition varies by session.
--
-- movement_pattern 'anti_extension': the most common core circuit pattern
--   (planks, hollow holds, rollouts). Not a perfect fit for a variable-
--   composition circuit, but the best single value from the existing enum.
--   Flagged in PR description.
--
-- muscles: the spec requests rectus_abdominis 0.7, obliques 0.5,
--   transverse_abdominis 0.5. All three muscle_ids confirmed present.
--   These represent a reasonable average of a typical core circuit.
--   Using time as performance_metric not rpe_only — tracking circuit
--   duration is more actionable than RPE for a conditioning item.
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
  'aaaaaaaa-0077-0000-0000-000000000001',
  'Core Circuit',
  ARRAY['core circuit', 'ab circuit', 'core workout'],
  'lifting',
  'anti_extension', NULL, 'bilateral',
  '[
    {"muscle_id": "rectus_abdominis",     "weight": 0.7},
    {"muscle_id": "obliques",             "weight": 0.5},
    {"muscle_id": "transverse_abdominis", "weight": 0.5}
  ]'::jsonb,
  -- head_emphasis_notes: NULL — no rival heads to distinguish for a
  -- generic circuit placeholder. Notes will live in the program itself.
  NULL,
  'bodyweight', NULL, NULL, NULL,
  ARRAY['stability'],
  'accessory', 'late',
  'time', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  NULL, NULL,
  'none',
  'system', FALSE
)
ON CONFLICT (exercise_id) DO NOTHING;


-- ─── 78. Stretching / Mobility ───────────────────────────────────────────────
-- Generic full-body stretching session — static and dynamic stretches,
-- PNF, or a flexibility-focused cooldown. Composition varies by session.
--
-- progression_eligible FALSE: duration is the variable, not load. There is
--   no meaningful "progression" for a stretching session — tracking is
--   "did you do it" not "are you improving." Flexibility gains are tracked
--   indirectly via performance on loaded exercises, not via this row.
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
  'aaaaaaaa-0078-0000-0000-000000000001',
  'Stretching / Mobility',
  ARRAY['stretching', 'flexibility session', 'mobility session'],
  'mobility',
  'mobility', NULL, 'bilateral',
  '[]'::jsonb,
  NULL,
  'none', NULL, NULL, NULL,
  ARRAY['mobility'],
  'accessory', 'late',
  'time', FALSE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  NULL, NULL,
  'none',
  'system', FALSE
)
ON CONFLICT (exercise_id) DO NOTHING;


-- ─── 79. Walk / Light Cardio ─────────────────────────────────────────────────
-- Low-intensity aerobic activity — walking, incline treadmill, easy bike,
-- easy rower. The exact modality varies; what's consistent is the low
-- intensity and recovery purpose.
--
-- movement_pattern 'locomotion': the most accurate value for walking/moving
--   through space at low intensity. The existing enum includes this.
--
-- session_position 'anywhere': commonly used as warmup (10-min walk before
--   lifting) or cooldown / active recovery (post-session 20-min walk).
--
-- progression_eligible FALSE: this is "did you do it" tracking. Volume
--   accumulation from walking is incidental to the recovery goal.
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
  'aaaaaaaa-0079-0000-0000-000000000001',
  'Walk / Light Cardio',
  ARRAY['walking', 'light cardio', 'incline walk'],
  'conditioning',
  'locomotion', NULL, 'bilateral',
  '[]'::jsonb,
  NULL,
  'none', NULL, NULL, NULL,
  ARRAY['conditioning'],
  'accessory', 'anywhere',
  'time', FALSE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  NULL, NULL,
  'none',
  'system', FALSE
)
ON CONFLICT (exercise_id) DO NOTHING;


-- ─── 80. Foam Roll Full Body ─────────────────────────────────────────────────
-- Self-myofascial release using a foam roller. Done as warmup, cooldown,
-- or standalone recovery session.
--
-- equipment_primary 'none': foam roller has no canonical value in the
--   exercise_equipment enum. Using 'none' + equipment_specific per the
--   Jump Rope pattern (which also uses 'none' + equipment_specific).
--   Flag for §5 amendment if foam roller becomes the first of a
--   recovery-equipment category.
--
-- progression_eligible FALSE: there is no progression variable for foam
--   rolling beyond "did you spend 10 minutes rolling."
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
  'aaaaaaaa-0080-0000-0000-000000000001',
  'Foam Roll Full Body',
  ARRAY['foam rolling', 'foam roll', 'SMR'],
  'mobility',
  'mobility', NULL, 'bilateral',
  '[]'::jsonb,
  NULL,
  'none', 'foam_roller', NULL, NULL,
  ARRAY['mobility'],
  'accessory', 'anywhere',
  'time', FALSE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  NULL, NULL,
  'none',
  'system', FALSE
)
ON CONFLICT (exercise_id) DO NOTHING;


-- ─── 81. Hip Flexor Stretch ──────────────────────────────────────────────────
-- Targeted hip flexor stretch — kneeling lunge, couch stretch, or
-- standing hip flexor stretch. Addresses the iliopsoas / rectus femoris
-- tightness common in people with sedentary lifestyles.
--
-- training_modality ['mobility', 'joint_health']: listed as joint_health
--   because persistent hip flexor tightness is a primary contributor to
--   anterior pelvic tilt, lumbar overextension, and hip impingement. This
--   is preventive joint care, not just flexibility work.
--
-- muscles: empty. Stretching exercises produce ROM adaptation, not
--   hypertrophy signal. The hip flexors are the passive target, not the
--   prime mover performing the stretch.
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
  'aaaaaaaa-0081-0000-0000-000000000001',
  'Hip Flexor Stretch',
  ARRAY['hip flexor', 'couch stretch', 'kneeling hip flexor stretch'],
  'mobility',
  'mobility', NULL, 'bilateral',
  '[]'::jsonb,
  NULL,
  'none', NULL, NULL, NULL,
  ARRAY['mobility', 'joint_health'],
  'accessory', 'late',
  'time', FALSE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  NULL, NULL,
  'none',
  'system', FALSE
)
ON CONFLICT (exercise_id) DO NOTHING;


-- ─── 82. Thoracic Extension ──────────────────────────────────────────────────
-- Foam roller or block thoracic extension drill. Extends the upper back
-- over a fulcrum (foam roller, tennis ball stack, or thoracic block) to
-- open the thoracic spine. Critical for overhead ROM and posture.
--
-- training_modality ['mobility', 'joint_health']: thoracic extension is
--   a prerequisite for safe overhead pressing and rack position in front
--   squats/cleans. Restricted T-spine is a joint-health risk for the
--   shoulder and cervical spine.
--
-- demands: 'thoracic_extension' is in the §3 vocabulary — it means the
--   exercise REQUIRES this ROM. That logic is slightly backwards here (the
--   drill is developing the ROM), so leaving demands empty. Flagged in
--   PR description.
--
-- equipment_specific 'foam_roller_or_block': foam roller is the most
--   common tool; thoracic extension blocks and tennis ball stacks also work.
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
  'aaaaaaaa-0082-0000-0000-000000000001',
  'Thoracic Extension',
  ARRAY['T-spine extension', 'thoracic mob', 'foam roller T-spine'],
  'mobility',
  'mobility', NULL, 'bilateral',
  '[]'::jsonb,
  NULL,
  'none', 'foam_roller_or_block', NULL, NULL,
  ARRAY['mobility', 'joint_health'],
  'accessory', 'anywhere',
  'time', FALSE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  NULL, NULL,
  'none',
  'system', FALSE
)
ON CONFLICT (exercise_id) DO NOTHING;


-- ─── 83. Dead Hang ───────────────────────────────────────────────────────────
-- Hanging from a pull-up bar with arms straight, body relaxed. Used for
-- shoulder decompression, spinal decompression, and grip endurance.
--
-- movement_pattern 'vertical_pull': dead hang is the starting position of
--   a vertical pull. No pull occurs, but the mechanical context (hanging
--   from a bar with an overhead grip) is identical. The closest enum value.
--
-- muscles [forearms_grip 0.5]:
--   forearms_grip 0.5 — grip strength/endurance is the primary training
--   stimulus. Dead hangs do build grip capacity in a way that carries over
--   to pulling strength (bar hangs before pull-up PRs is a documented
--   protocol). Weight 0.5 rather than 1.0 because the grip is sustained
--   isometric, not dynamic — meaningful but below the full 1.0 of a
--   grip-dominant concentric exercise like a barbell row.
--
-- head_emphasis_notes: explains the dual purpose — decompression + grip.
--   This is the one protocol where head_emphasis_notes is warranted
--   because the muscle entry (forearms_grip) would otherwise look like
--   a grip-training exercise. The note clarifies the joint-health context.
--
-- relative_to_bodyweight TRUE: the load IS the user's bodyweight, same as
--   a pull-up. Bodyweight changes affect the demand on the grip.
--
-- loaded_position 'stretched': peak load on the grip is at full hang
--   (arms straight, shoulder girdle decompressed). Consistent with the
--   §8 definition of stretched as peak tension at the bottom of ROM.
--
-- progression_eligible TRUE: hang time is the progression variable.
--   Starting at 10–15s and progressing toward 60–90s is a legitimate
--   training adaptation.
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
  'aaaaaaaa-0083-0000-0000-000000000001',
  'Dead Hang',
  ARRAY['dead hang', 'bar hang', 'passive hang'],
  'lifting',
  'vertical_pull', NULL, 'bilateral',
  '[
    {"muscle_id": "forearms_grip", "weight": 0.5}
  ]'::jsonb,
  -- forearms_grip: sustained isometric load at full hang. Below 1.0
  -- because this is isometric endurance, not dynamic concentric work.
  '{"forearms_grip": "Dead hangs train grip endurance and decompress the shoulder and spine — not a hypertrophy stimulus. Primary purpose is joint health (shoulder, spinal traction) with a real grip-endurance training effect. Progress by extending hang duration, not by adding load."}'::jsonb,
  'bodyweight', NULL, NULL, NULL,
  ARRAY['mobility', 'joint_health'],
  'accessory', 'late',
  'time', TRUE, TRUE,
  ARRAY['grip_intensive'],
  '[]'::jsonb,
  NULL, NULL,
  'stretched',
  'system', FALSE
)
ON CONFLICT (exercise_id) DO NOTHING;


-- ─── 84. Chin Tucks + Wall Angels ────────────────────────────────────────────
-- Paired cervical health drill:
--   Chin tucks (cervical retraction): pull the chin straight back,
--     creating a "double chin." Targets deep cervical flexors and
--     counteracts forward head posture.
--   Wall angels: stand with back flat against a wall, slide arms up and
--     down in a Y/W/T pattern. Trains scapular control and posterior
--     shoulder mobility.
--
-- Authored as a single row because the two movements are prescribed
-- together, both serve cervical/shoulder posture correction, and
-- separating them would create an awkward substitution problem
-- (they have no meaningful individual substitutes yet).
--
-- performance_metric 'rpe_only': quality reps matter more than a
--   count target. The drill is done until form degrades, not for a
--   fixed set/rep scheme. RPE captures "did you do this well" better
--   than a rep count would.
--
-- progression_eligible FALSE per §9: rpe_only exercises default to FALSE.
--   These drills are not progressively loaded — the "progress" is that
--   they become easier (forward head posture improves, scapular control
--   improves) and eventually become less necessary.
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
  'aaaaaaaa-0084-0000-0000-000000000001',
  'Chin Tucks + Wall Angels',
  ARRAY['chin tucks', 'wall angels', 'cervical retraction'],
  'mobility',
  'mobility', NULL, 'bilateral',
  '[]'::jsonb,
  NULL,
  'none', NULL, NULL, NULL,
  ARRAY['mobility', 'joint_health'],
  'accessory', 'anywhere',
  'rpe_only', FALSE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  NULL, NULL,
  'none',
  'system', FALSE
)
ON CONFLICT (exercise_id) DO NOTHING;


COMMIT;


-- =============================================================================
-- PART 3: Verification queries (run after migration, not part of transaction)
-- =============================================================================

-- Expected: 84 rows (74 from prior PRs + 10 new protocols)
-- SELECT COUNT(*) FROM public.exercises;

-- Expected: all 10 new rows present
-- SELECT exercise_id, name, training_modality
-- FROM public.exercises
-- WHERE exercise_id IN (
--   'aaaaaaaa-0075-0000-0000-000000000001',
--   'aaaaaaaa-0076-0000-0000-000000000001',
--   'aaaaaaaa-0077-0000-0000-000000000001',
--   'aaaaaaaa-0078-0000-0000-000000000001',
--   'aaaaaaaa-0079-0000-0000-000000000001',
--   'aaaaaaaa-0080-0000-0000-000000000001',
--   'aaaaaaaa-0081-0000-0000-000000000001',
--   'aaaaaaaa-0082-0000-0000-000000000001',
--   'aaaaaaaa-0083-0000-0000-000000000001',
--   'aaaaaaaa-0084-0000-0000-000000000001'
-- )
-- ORDER BY exercise_id;

-- Expected: 0 rows (none of the new rows carry 'hypertrophy')
-- SELECT exercise_id, name, training_modality
-- FROM public.exercises
-- WHERE exercise_id IN (
--   'aaaaaaaa-0075-0000-0000-000000000001', 'aaaaaaaa-0076-0000-0000-000000000001',
--   'aaaaaaaa-0077-0000-0000-000000000001', 'aaaaaaaa-0078-0000-0000-000000000001',
--   'aaaaaaaa-0079-0000-0000-000000000001', 'aaaaaaaa-0080-0000-0000-000000000001',
--   'aaaaaaaa-0081-0000-0000-000000000001', 'aaaaaaaa-0082-0000-0000-000000000001',
--   'aaaaaaaa-0083-0000-0000-000000000001', 'aaaaaaaa-0084-0000-0000-000000000001'
-- )
-- AND training_modality @> ARRAY['hypertrophy'];

-- Confirm Jump Rope fix — Expected: ['conditioning', 'power', 'plyometric']
-- SELECT training_modality FROM public.exercises
-- WHERE exercise_id = 'aaaaaaaa-0065-0000-0000-000000000001';

-- Expected: 0 rows (no exercise references a muscle_id that doesn't exist)
-- SELECT e.exercise_id, e.name, elem->>'muscle_id' AS missing_muscle
-- FROM public.exercises e,
--      jsonb_array_elements(e.muscles) AS elem
-- WHERE elem->>'muscle_id' NOT IN (SELECT muscle_id FROM public.muscles);
