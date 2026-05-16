-- =============================================================================
-- Migration: Add 6 missing hypertrophy exercises + fix lateral raise orphan
-- =============================================================================
-- Purpose: Add the following exercises used in the current WORKOUTS split
--   that were missing from the exercises table:
--
--   #66  Cable Fly — Flat            (Day 1, pump set)
--   #67  Cable Fly — Low to High     (Day 5)
--   #68  Straight Arm Pulldown       (Day 5, lat isolation)
--   #69  Preacher Curl — EZ Bar      (Day 3)
--   #70  Cable Overhead Tricep Ext   (Day 3)
--   #71  Rear Delt Fly — Cable       (Day 3)
--
--   Also fixes the Dumbbell Lateral Raise (exercise #3) substitution graph
--   orphan: it had zero outbound edges, which the substitute picker would
--   fail on. Adds the 0003 → 0054 edge to Cable Lateral Raise.
--
-- IMPORTANT: Run in Supabase SQL Editor as a single block.
--   All INSERTs use ON CONFLICT DO NOTHING — safe to re-run.
--   This is an additive-only migration; nothing is truncated or deleted.
-- =============================================================================

BEGIN;

-- =============================================================================
-- NEW EXERCISE FAMILIES
-- =============================================================================
-- Cable Fly family (flat + low-to-high share one family; differ by cable
-- height, which redistributes pectoral head emphasis per §14.6):
--   aaaaaaf0-f0f0-f0f0-f0f0-f0f0f0f0f0f0
--
-- Straight Arm Pulldown family (cable lat isolation; new family per §1
-- because it's mechanically distinct from pull-up compound work):
--   aaaaaaf1-f1f1-f1f1-f1f1-f1f1f1f1f1f1
--
-- Rear Delt Fly — Cable family (free-arm-path cable rear delt isolation;
-- distinct from face pull family and reverse pec deck per §1):
--   aaaaaaf2-f2f2-f2f2-f2f2-f2f2f2f2f2f2
--
-- Preacher Curl shares the Barbell Curl family (44444444-5555-6666-7777-...):
--   same biceps curl family; preacher variant.
--
-- Overhead Tricep Extension shares the Lying Triceps Extension family
--   (aaaaaabb-bbbb-bbbb-bbbb-bbbbbbbbbbbb): both are stretched-position
--   long-head triceps exercises; equipment differs (cable vs barbell) but
--   the training effect is the same programming rationale.


-- ─── 66. Cable Fly — Flat ───────────────────────────────────────────────────
-- Cables set at chest height, arms parallel to floor, sternal-dominant.
-- The horizontal adduction arc at chest height aligns directly with the
-- sternal fibers' line of pull — this is the flat fly's defining feature.
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
  'aaaaaaaa-0066-0000-0000-000000000001',
  'Cable Fly — Flat',
  ARRAY['cable fly', 'cable chest fly', 'flat cable fly', 'standing cable fly'],
  'lifting',
  'horizontal_push', NULL, 'bilateral',
  -- pectorals_sternal 1.0 — chest-height cables with horizontal arm path
  --   load the sternal (mid-chest) fibers directly. Horizontal adduction at
  --   chest height is exactly the sternal fibers' line of pull.
  -- pectorals_clavicular 0.5, pectorals_abdominal 0.5 — both contribute
  --   across ROM but are not the primary target at this cable height.
  -- delts_anterior 0.3 — slight front delt involvement as arms sweep inward.
  -- serratus_anterior 0.3 — scapular protraction in the contracted position,
  --   same as bench press.
  -- rotator_cuff_subscapularis 0.25 — internal rotation component at the
  --   shoulder during the adduction arc (same as bench).
  '[
    {"muscle_id": "pectorals_sternal",          "weight": 1.0},
    {"muscle_id": "pectorals_clavicular",       "weight": 0.5},
    {"muscle_id": "pectorals_abdominal",        "weight": 0.5},
    {"muscle_id": "delts_anterior",             "weight": 0.3},
    {"muscle_id": "serratus_anterior",          "weight": 0.3},
    {"muscle_id": "rotator_cuff_subscapularis", "weight": 0.25}
  ]'::jsonb,
  '{
    "pectorals_sternal": "Cables at chest height with arms parallel to the floor hits the sternal (mid-chest) fibers directly — the entire fly should feel like a mid-chest squeeze, not an upper-chest lift. Slight forward hinge at the hips is normal; avoid excessive torso rotation.",
    "pectorals_clavicular": "Chest-height cable setup reduces clavicular emphasis compared to the low-to-high variant. To bias upper chest, lower the cable pulleys to hip height and let the arms sweep upward."
  }'::jsonb,
  'cable', NULL, 5.00, 2.50,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'aaaaaaf0-f0f0-f0f0-f0f0-f0f0f0f0f0f0',
  '{"incline": "flat"}'::jsonb,
  'stretched',
  -- Arms wide at the start = pecs at full stretch under cable tension.
  -- Cable provides consistent tension at the stretched position (vs DB fly
  -- where tension drops at the bottom). This is the programming rationale.
  'system', FALSE
);


-- ─── 67. Cable Fly — Low to High ────────────────────────────────────────────
-- Cables set at hip/ankle height, arms sweeping upward and inward.
-- The upward arc aligns with the clavicular (upper chest) fibers, which
-- run from the clavicle downward and inward — opposite orientation to the
-- sternal fibers. Per §14.6, cable height determines head bias.
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
  'aaaaaaaa-0067-0000-0000-000000000001',
  'Cable Fly — Low to High',
  ARRAY['low-to-high cable fly', 'low cable fly', 'cable upper chest fly', 'incline cable fly'],
  'lifting',
  'horizontal_push', NULL, 'bilateral',
  -- pectorals_clavicular 1.0 — the upward sweep from hip-height cables
  --   aligns with the clavicular head's fiber direction (clavicle → sternum,
  --   angled downward-medially). This is the defining feature of this variant.
  -- pectorals_sternal 0.6 — still meaningfully loaded; both pec regions
  --   contribute to horizontal adduction regardless of cable angle, but the
  --   sternal head is no longer the primary target.
  -- pectorals_abdominal 0.3 — minimal; the upward angle reduces the
  --   abdominal-head moment arm vs a flat or decline angle.
  -- delts_anterior 0.4 — slightly more front delt than flat fly because
  --   the arm sweeps upward, adding a shoulder flexion component.
  -- serratus_anterior 0.3 — scapular protraction, same as flat variant.
  -- rotator_cuff_subscapularis 0.25 — internal rotation component, same.
  '[
    {"muscle_id": "pectorals_clavicular",       "weight": 1.0},
    {"muscle_id": "pectorals_sternal",          "weight": 0.6},
    {"muscle_id": "pectorals_abdominal",        "weight": 0.3},
    {"muscle_id": "delts_anterior",             "weight": 0.4},
    {"muscle_id": "serratus_anterior",          "weight": 0.3},
    {"muscle_id": "rotator_cuff_subscapularis", "weight": 0.25}
  ]'::jsonb,
  '{
    "pectorals_clavicular": "Cables set at hip height — the upward sweeping arc from wide-low to narrow-high traces the fiber direction of the clavicular (upper chest) head. This is the unique training purpose of this variant. Without the upward sweep, the upper-chest bias disappears.",
    "pectorals_sternal": "Still contributes on every rep since both pec regions run the horizontal adduction arc. But the sternal fibers are not in their optimal line of pull here — for mid-chest isolation, use the flat variant (cables at chest height).",
    "delts_anterior": "The upward sweep of the hands adds a shoulder flexion component that the flat variant does not have. Worth tracking combined with OHP and bench for anterior delt volume management."
  }'::jsonb,
  'cable', NULL, 5.00, 2.50,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'aaaaaaf0-f0f0-f0f0-f0f0-f0f0f0f0f0f0',
  -- Same family as Cable Fly — Flat. Cable height is the variation axis;
  -- same equipment, same pattern, same ROM — only the pec head emphasis
  -- distribution changes (§14.6 pattern).
  '{"incline": "incline"}'::jsonb,
  -- 'incline' captures the upward sweep angle (upper-chest bias) per §4.
  'stretched',
  -- Arms wide and low at the start = pecs at full stretch under cable
  -- tension. Same stretch-bias rationale as the flat variant.
  'system', FALSE
);


-- ─── 68. Straight Arm Pulldown ──────────────────────────────────────────────
-- Cable, straight arms, handle sweeps from overhead to thighs in an arc.
-- Pure lat isolation: elbows remain locked, all movement at the shoulder.
-- No elbow flexion — this is shoulder extension, not a row or pull-up.
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
  'aaaaaaaa-0068-0000-0000-000000000001',
  'Straight Arm Pulldown',
  ARRAY['straight-arm pulldown', 'stiff arm pulldown', 'straight arm lat pulldown', 'cable pullover'],
  'lifting',
  'vertical_pull', NULL, 'bilateral',
  -- vertical_pull: the handle starts overhead and sweeps down to the thighs.
  -- Per §14.3: elbow-tucked / close arm path → lower-lat dominant.
  --   Straight arms with elbows pointed toward the floor = elbows "close"
  --   during the pull — lower-lat-dominant (1.0) with upper-lat secondary (0.6).
  --
  -- teres_major 0.5 — synergist in shoulder extension; same adduction/
  --   extension action as lats, co-activates on every rep.
  --
  -- triceps_long 0.4 — IMPORTANT: this is the long head's SHOULDER EXTENSION
  --   function, not its elbow extension function. The long head is biarticular;
  --   it crosses the shoulder joint and shortens during shoulder extension.
  --   Arms stay straight throughout (zero elbow extension loading); this is
  --   a 0.4 shoulder contribution only. List it with a note because this
  --   entry is non-obvious and easy to misread as an elbow-extension credit.
  --
  -- delts_posterior 0.25 — minor shoulder extension assistance.
  '[
    {"muscle_id": "lats_lower",      "weight": 1.0},
    {"muscle_id": "lats_upper",      "weight": 0.6},
    {"muscle_id": "teres_major",     "weight": 0.5},
    {"muscle_id": "triceps_long",    "weight": 0.4},
    {"muscle_id": "delts_posterior", "weight": 0.25}
  ]'::jsonb,
  '{
    "lats_lower": "Elbows angled toward the floor throughout the full arc is what keeps this lower-lat dominant. If elbows flare wide, upper-lat emphasis increases.",
    "lats_upper": "Some upper-lat contribution regardless of arm path; lower than a wide-grip pull because the straight-arm position is mechanically closer to a close-elbow pull per §14.3.",
    "triceps_long": "This is the long head''s shoulder extension role — not elbow extension. Arms stay locked straight; the triceps contribute by shortening as the shoulder extends. This is a pure shoulder-extension credit (0.4), not an elbow-extension credit. Do not program this exercise as triceps work — it is a lat isolation exercise."
  }'::jsonb,
  'cable', NULL, 5.00, 2.50,
  ARRAY['hypertrophy'],
  'accessory', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  'aaaaaaf1-f1f1-f1f1-f1f1-f1f1f1f1f1f1',
  '{"grip": "pronated"}'::jsonb,
  -- Typical grip on a straight bar or lat bar: pronated (palms facing down).
  -- Rope attachment variant is more of a grip-style note than a separate row.
  'stretched',
  -- Lats at full stretch at the top of the rep (arms overhead). The cable
  -- provides constant tension at this stretched position — the programming
  -- advantage over free-weight pullovers.
  'system', FALSE
);


-- ─── 69. Preacher Curl — EZ Bar ─────────────────────────────────────────────
-- Bench-supported curl on a preacher pad, EZ-bar (semi-supinated grip).
-- The preacher pad angles the upper arm forward — shoulder flexion position —
-- which SHORTENS the biceps long head and forces the short head to do more
-- of the work. Contrast with incline DB curl (#53), which EXTENDS the shoulder
-- behind the torso, stretching the long head for opposite head bias.
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
  'aaaaaaaa-0069-0000-0000-000000000001',
  'Preacher Curl — EZ Bar',
  ARRAY['preacher curl', 'EZ bar preacher curl', 'spider curl', 'Scott curl'],
  'lifting',
  'elbow_flexion', NULL, 'bilateral',
  -- elbow_flexion isolation. The preacher pad constrains the upper arm
  -- and removes momentum — no cheating at the bottom, no hip drive.
  --
  -- biceps_short 1.0 — the preacher pad places the shoulder in flexion
  --   (arm in front of the torso). Shoulder flexion shortens the long head
  --   (which is biarticular at the shoulder), making the long head
  --   mechanically disadvantaged. The short head, which crosses the shoulder
  --   at a different angle, becomes the relatively more-emphasized head.
  --
  -- biceps_long 0.7 — still contributes throughout elbow flexion ROM; just
  --   not in its optimal length-tension position. Lower than short head here,
  --   and lower than in incline DB curl (where it's 1.0).
  --
  -- brachialis 0.5 — EZ-bar grip is semi-supinated (hands angled ~45° from
  --   fully supinated). Semi-supination gives brachialis more contribution
  --   than a fully supinated straight barbell curl (brachioradialis at 0.4).
  --   Brachialis is a pure elbow flexor with no grip-orientation sensitivity.
  --
  -- forearms_brachioradialis 0.4 — EZ-bar's semi-supinated grip shifts load
  --   here vs a straight bar. More contribution than on a fully supinated
  --   barbell curl.
  '[
    {"muscle_id": "biceps_short",              "weight": 1.0},
    {"muscle_id": "biceps_long",               "weight": 0.7},
    {"muscle_id": "brachialis",                "weight": 0.5},
    {"muscle_id": "forearms_brachioradialis",  "weight": 0.4}
  ]'::jsonb,
  '{
    "biceps_short": "The preacher pad''s angled surface places the shoulder in flexion, which shortens the long head before the rep even starts. The short head is forced to do proportionally more work — the opposite of incline DB curl, which extends the shoulder behind the torso and biases the long head. Program preacher + incline DB curl together to train both heads across their respective stretch ranges.",
    "biceps_long": "Mechanically disadvantaged here because shoulder flexion pre-shortens it. It still contracts hard throughout the curl, but you won''t feel the same peak-stretch stimulus that incline DB curl provides. The preacher pad does eliminate cheating at the bottom — so the long head still gets a quality full-ROM contraction, just from a shorter starting position.",
    "brachialis": "EZ-bar''s semi-supinated grip (vs a straight bar''s full supination) shifts more load to brachialis than a standard barbell curl. Brachialis is a pure elbow flexor that doesn''t care about grip orientation — reliable contributor on every rep."
  }'::jsonb,
  'barbell', 'ez_bar', 5.00, 2.50,
  -- equipment_primary barbell (EZ-bar is a barbell variant).
  -- equipment_specific ez_bar discriminates for users who have/lack one.
  -- EZ-bar is semi-supinated, not fully supinated — closer to supinated
  -- than neutral; using grip: supinated per §4 (closest established value).
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY[]::TEXT[],
  '[]'::jsonb,
  '44444444-5555-6666-7777-888888888888',
  -- Shares the Barbell Curl family. Same biceps curl category; the preacher
  -- pad is a setup variation, not a fundamentally different lift family.
  '{"grip": "supinated"}'::jsonb,
  -- EZ-bar is semi-supinated (between supinated and neutral); using
  -- 'supinated' per §4 (closest established value; full supination
  -- on a straight barbell shifts to the long head more than EZ-bar does).
  'stretched',
  -- The preacher pad stretches the biceps at full elbow extension at the
  -- bottom — this is one of the defining programming features vs barbell
  -- curl (which has reduced tension at the bottom). Constant cable-style
  -- tension at the stretched position without needing cable equipment.
  'system', FALSE
);


-- ─── 70. Cable Overhead Tricep Extension ────────────────────────────────────
-- Cable, rope or bar attachment, arms overhead, elbow extension from behind
-- the head to lockout overhead. The overhead position stretches the triceps
-- long head at both the shoulder and elbow joints simultaneously — this is
-- the maximum-stretch position for the long head.
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
  'aaaaaaaa-0070-0000-0000-000000000001',
  'Cable Overhead Tricep Extension',
  ARRAY['overhead tricep extension', 'cable overhead extension', 'rope overhead extension', 'tricep overhead extension'],
  'lifting',
  'elbow_extension', NULL, 'bilateral',
  -- elbow_extension isolation. Cable attachment (rope most common) faces
  -- away from the pulley, arms extended overhead.
  --
  -- triceps_long 1.0 — the long head is the entire rationale for this
  --   exercise. Overhead position puts the long head in maximal stretch:
  --   the shoulder is flexed (arm overhead), which stretches the long head
  --   at its shoulder attachment, while the elbow is also flexed at the start
  --   of the rep, stretching it further at the elbow. This combined stretch
  --   is greater than in skull crushers (#51), which only flex the elbow.
  --
  -- triceps_lateral 0.6, triceps_medial 0.6 — all three triceps heads
  --   participate in elbow extension; lateral and medial don't benefit from
  --   the shoulder-position stretch (they don't cross the shoulder joint),
  --   so they're meaningful but not the primary driver.
  --
  -- rectus_abdominis 0.25 — anti-extension bracing. The overhead load
  --   wants to pull the lumbar into extension; abs fire to resist.
  '[
    {"muscle_id": "triceps_long",      "weight": 1.0},
    {"muscle_id": "triceps_lateral",   "weight": 0.6},
    {"muscle_id": "triceps_medial",    "weight": 0.6},
    {"muscle_id": "rectus_abdominis",  "weight": 0.25}
  ]'::jsonb,
  '{
    "triceps_long": "The overhead position puts the long head at maximal stretch — it crosses both the shoulder and elbow, so flexing both joints simultaneously stretches it from both ends. Keep elbows pointed forward (not flaring) to maintain shoulder flexion throughout and preserve the stretch. This is the cable equivalent of skull crushers but with constant tension, making the bottom stretched position the loaded position vs skulls'' variable load.",
    "triceps_lateral": "Lateral and medial heads do full elbow extension work on every rep. But they don''t benefit from the overhead position the way the long head does — they don''t cross the shoulder joint. If the lateral head is the explicit training goal, pushdowns are the better choice (shortened-bias, lateral dominant)."
  }'::jsonb,
  'cable', NULL, 5.00, 2.50,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['overhead_rom'],
  -- Requires shoulder mobility to maintain arms overhead through the full
  -- elbow extension ROM without lumbar hyperextension compensation.
  '[]'::jsonb,
  'aaaaaabb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
  -- Shares the Lying Triceps Extension (skull crusher) family. Both are
  -- stretched-position, long-head-dominant triceps isolation exercises.
  -- Equipment differs (cable vs barbell) but programming rationale is
  -- identical: stretched-bias triceps to complement pushdown's shortened-bias.
  '{"grip": "neutral"}'::jsonb,
  -- Rope attachment with hands side by side = neutral grip.
  'stretched',
  -- Long head at maximal stretch at the start of each rep (arms overhead,
  -- elbows bent). This is the programming reason to choose this over pushdowns.
  'system', FALSE
);


-- ─── 71. Rear Delt Fly — Cable ──────────────────────────────────────────────
-- Two cables at shoulder height, arms swept horizontally outward and back.
-- Distinct from Reverse Pec Deck (#55): cable's free arm path allows mild
-- external rotation at end range, unlike the machine's fixed arc.
-- Distinct from Face Pull (#42): no high-elbow row, no pronounced external
-- rotation cue — this is a purer horizontal abduction movement.
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
  'aaaaaaaa-0071-0000-0000-000000000001',
  'Rear Delt Fly — Cable',
  ARRAY['cable rear delt fly', 'cable reverse fly', 'bent-over cable fly', 'cable rear fly'],
  'lifting',
  'horizontal_pull', NULL, 'bilateral',
  -- horizontal_pull: same classification as face pull and reverse pec deck.
  -- The rear delt's primary action is horizontal abduction (sweeping the
  -- arm back from in front of the body). No dedicated pattern in the enum;
  -- horizontal_pull is the correct fit (same rationale as #42 and #55).
  --
  -- delts_posterior 1.0 — primary target. Arms at shoulder height,
  --   sweeping horizontally outward and back = the rear delt's strongest
  --   line of pull.
  --
  -- rhomboids 0.5 — scapular retraction at end range; the rhomboids pull
  --   the shoulder blades together as arms reach the back position.
  --
  -- traps_middle 0.5 — same scapular retraction role as rhomboids;
  --   mid-trap is the primary scapular retractor alongside rhomboids.
  --
  -- traps_lower 0.25 — minor scapular depression-retraction at end range.
  --
  -- rotator_cuff_infraspinatus 0.35 — the cable's free arm path allows
  --   mild external rotation as the arm sweeps back (unlike pec deck's
  --   fixed arc). More external rotation than reverse pec deck, less
  --   than face pull's pronounced external rotation cue.
  --
  -- rotator_cuff_teres_minor 0.25 — same external rotation contribution.
  '[
    {"muscle_id": "delts_posterior",            "weight": 1.0},
    {"muscle_id": "rhomboids",                  "weight": 0.5},
    {"muscle_id": "traps_middle",               "weight": 0.5},
    {"muscle_id": "traps_lower",                "weight": 0.25},
    {"muscle_id": "rotator_cuff_infraspinatus", "weight": 0.35},
    {"muscle_id": "rotator_cuff_teres_minor",   "weight": 0.25}
  ]'::jsonb,
  '{
    "delts_posterior": "Arms at shoulder height, sweep wide as if trying to put your elbows behind you. The cue to feel is the back of the shoulder (rear delt), not the mid-back rhomboids. Slightly higher elbow position (elbows at or above wrist level) keeps the rear delt as the prime mover vs letting the rhomboids dominate.",
    "rotator_cuff_infraspinatus": "The cable''s free arm path allows mild external rotation at end range that the fixed-arc pec deck machine does not. Less pronounced than the face pull''s explicit external rotation cue, but a real contribution. Programs well alongside face pulls for cumulative rotator cuff health volume."
  }'::jsonb,
  'cable', NULL, 5.00, 2.50,
  ARRAY['hypertrophy'],
  'isolation', 'late',
  'weight_x_reps', TRUE, FALSE,
  ARRAY['shoulder_external_rotation'],
  '[]'::jsonb,
  'aaaaaaf2-f2f2-f2f2-f2f2-f2f2f2f2f2f2',
  NULL,
  'shortened',
  -- Rear delts are most contracted (shortened) at end range — arms swept
  -- back wide behind the body. Same shortened-bias rationale as Reverse
  -- Pec Deck (#55) and Face Pull (#42).
  'system', FALSE
);


-- =============================================================================
-- SUBSTITUTION GRAPH ADDITIONS
-- =============================================================================
-- Fixes the existing orphan + adds outbound/inbound edges for all 6 new
-- exercises. All use ON CONFLICT DO NOTHING (PK = (exercise_id, substitute_id)).
-- =============================================================================

INSERT INTO public.exercise_substitutes (exercise_id, substitute_id, similarity_score, reason)
VALUES

  -- ── Fix: Dumbbell Lateral Raise (3) orphan ─────────────────────────────────
  -- Had 0 outbound edges; substitute picker would return empty for this exercise.
  ('aaaaaaaa-0003-0000-0000-000000000001', 'aaaaaaaa-0054-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  -- → Cable Lateral Raise: same shoulder_abduction pattern; constant cable
  --   tension vs DB's shortened-bias. Near-identical target, different
  --   loaded_position profile.

  -- ── 66. Cable Fly — Flat ───────────────────────────────────────────────────
  -- Outbound from #66
  ('aaaaaaaa-0066-0000-0000-000000000001', 'aaaaaaaa-0067-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  -- → Cable Fly — Low to High: same family, same cable setup, cable height
  --   is the only difference. Strong substitute; head emphasis shifts from
  --   sternal to clavicular.
  ('aaaaaaaa-0066-0000-0000-000000000001', 'aaaaaaaa-0013-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  -- → DB Bench Press: same pec muscles, compound vs isolation. Lower score
  --   because bench adds elbow extension (triceps) and is far more demanding.
  --   Use when no cables are available.

  -- Inbound to #66
  ('aaaaaaaa-0067-0000-0000-000000000001', 'aaaaaaaa-0066-0000-0000-000000000001', 0.85, 'same_pattern_different_equipment'),
  -- Low-to-High → Flat: same family. Shifts emphasis from clavicular to sternal.
  ('aaaaaaaa-0013-0000-0000-000000000001', 'aaaaaaaa-0066-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  -- DB Bench → Cable Fly Flat: isolation alternative to compound chest work.

  -- ── 67. Cable Fly — Low to High ────────────────────────────────────────────
  -- (Outbound 0067→0066 and inbound 0066→0067 already covered above)
  -- Additional outbound from #67
  ('aaaaaaaa-0067-0000-0000-000000000001', 'aaaaaaaa-0012-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),
  -- → Barbell Bench Press (flat): same pec muscles, compound vs isolation,
  --   + different head emphasis (clavicular→sternal). Weak substitute;
  --   only when no cable available and upper chest isolation is the goal.

  -- ── 68. Straight Arm Pulldown ──────────────────────────────────────────────
  -- Outbound from #68
  ('aaaaaaaa-0068-0000-0000-000000000001', 'aaaaaaaa-0002-0000-0000-000000000001', 0.55, 'same_muscles_different_pattern'),
  -- → Pull-Up: same lat-dominant target; compound vs isolation + bodyweight
  --   vs cable. Reasonable substitute when cables aren't available.

  -- Inbound to #68
  ('aaaaaaaa-0002-0000-0000-000000000001', 'aaaaaaaa-0068-0000-0000-000000000001', 0.50, 'same_muscles_different_pattern'),
  -- Pull-Up → Straight Arm Pulldown: same lat target; isolation regression
  --   option for high-volume lat days when compound pull fatigue is a concern.

  -- ── 69. Preacher Curl — EZ Bar ─────────────────────────────────────────────
  -- Outbound from #69
  ('aaaaaaaa-0069-0000-0000-000000000001', 'aaaaaaaa-0053-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  -- → Incline DB Curl: same biceps target, opposite head bias. Preacher
  --   = short-head dominant; incline = long-head dominant. Score is 0.65
  --   because they complement each other rather than being direct substitutes
  --   (different head emphasis is the reason for not being closer).
  ('aaaaaaaa-0069-0000-0000-000000000001', 'aaaaaaaa-0027-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
  -- → Barbell Curl: same biceps target, different position/momentum.
  --   Preacher pad removes momentum; barbell curl allows more loading.
  --   Strong substitute since both are full-supination (or near) biceps curls.

  -- Inbound to #69
  ('aaaaaaaa-0053-0000-0000-000000000001', 'aaaaaaaa-0069-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  -- Incline DB Curl → Preacher Curl: complement pair (long-head vs short-head).
  ('aaaaaaaa-0027-0000-0000-000000000001', 'aaaaaaaa-0069-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
  -- Barbell Curl → Preacher Curl: preacher as strict-form alternative.

  -- ── 70. Cable Overhead Tricep Extension ─────────────────────────────────────
  -- Outbound from #70
  ('aaaaaaaa-0070-0000-0000-000000000001', 'aaaaaaaa-0051-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  -- → Lying Triceps Extension (Skull Crusher): same long-head-dominant
  --   stretched-position rationale. Cable vs barbell; constant tension vs
  --   variable load. Score 0.65 because loaded_position is identical
  --   (stretched) but equipment and shoulder position differ.
  ('aaaaaaaa-0070-0000-0000-000000000001', 'aaaaaaaa-0028-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  -- → Triceps Pushdown: same triceps target, opposite loaded_position
  --   (shortened-bias vs stretched-bias). Reasonable substitute when
  --   overhead position isn't accessible.

  -- Inbound to #70
  ('aaaaaaaa-0051-0000-0000-000000000001', 'aaaaaaaa-0070-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  -- Skull Crusher → Overhead Extension: constant-tension alternative with
  --   same long-head stretch rationale.
  ('aaaaaaaa-0028-0000-0000-000000000001', 'aaaaaaaa-0070-0000-0000-000000000001', 0.65, 'same_muscles_different_pattern'),
  -- Pushdown → Overhead Extension: progression toward stretched-bias work
  --   when adding loaded_position variety to triceps programming.

  -- ── 71. Rear Delt Fly — Cable ───────────────────────────────────────────────
  -- Outbound from #71
  ('aaaaaaaa-0071-0000-0000-000000000001', 'aaaaaaaa-0042-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
  -- → Face Pull: rear delt primary target in both; face pull adds high-elbow
  --   path and explicit external rotation cue. Score 0.75: same target,
  --   slightly different muscle distribution (face pull has more rotator cuff).
  ('aaaaaaaa-0071-0000-0000-000000000001', 'aaaaaaaa-0055-0000-0000-000000000001', 0.70, 'same_pattern_different_equipment'),
  -- → Reverse Pec Deck: same rear delt isolation, machine vs cable. Machine
  --   fixes the arm path (no external rotation); score 0.70.

  -- Inbound to #71
  ('aaaaaaaa-0042-0000-0000-000000000001', 'aaaaaaaa-0071-0000-0000-000000000001', 0.75, 'same_muscles_different_pattern'),
  -- Face Pull → Rear Delt Fly Cable: free-arm-path alternative when the
  --   cable station is in use for face pull setup.
  ('aaaaaaaa-0055-0000-0000-000000000001', 'aaaaaaaa-0071-0000-0000-000000000001', 0.70, 'same_pattern_different_equipment')
  -- Reverse Pec Deck → Rear Delt Fly Cable: cable alternative to the machine.

ON CONFLICT DO NOTHING;

COMMIT;
