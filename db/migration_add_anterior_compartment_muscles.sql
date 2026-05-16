-- =============================================================================
-- Migration: Add Anterior-Compartment Muscles + Backfill Tibialis Raise
-- =============================================================================
-- Purpose: Extend the v2 muscle taxonomy (67 rows) with two singletons that
--   were missing from the original authoring scope, then backfill the Tibialis
--   Raise (exercise #73) which was inserted with muscles: '[]' in PR #16
--   because these muscle_ids did not yet exist.
--
--   New muscles:
--     tibialis_anterior  — prime mover of ankle dorsiflexion; anterior
--                          compartment of the lower leg. Critical for shin
--                          splint prevention, ankle stability under dynamic
--                          loading, and knee health via the kinetic chain.
--                          Often underdeveloped in athletes — the calf/tibialis
--                          imbalance is a primary cause of lower-leg injuries
--                          and contributes to anterior knee pain patterns.
--
--     peroneals          — covers peroneus longus + peroneus brevis (fibularis
--                          group); primary function is ankle eversion and
--                          lateral ankle stabilization. A singleton rather than
--                          a parent/child split: the two heads are almost never
--                          trained in isolation; combined as a single
--                          programming unit is the right granularity for v1.
--
--   Both are singletons (parent_muscle_id = NULL). The muscles_with_kind view
--   classifies any row with no parent AND no children as 'singleton' — no
--   schema change is needed beyond the INSERT.
--
--   ⚠️  Backfill note: after this migration, the tibialis_anterior taxonomy
--   gap documented in PR #16 is fully resolved. Exercise #73 will have 2
--   muscle entries and will contribute to volume tracking.
--
-- IMPORTANT: Run in Supabase SQL Editor as a single block.
--   All INSERTs use ON CONFLICT DO NOTHING — safe to re-run.
--   The UPDATE is idempotent (deterministic SET; re-running overwrites with
--   identical values).
--   Additive-only migration; nothing is truncated or deleted.
--   PR #16 (migration_add_specialty_joint_health_exercises.sql) must be
--   applied BEFORE this migration — #73 must exist as a row for the UPDATE
--   to find it.
-- =============================================================================

BEGIN;


-- =============================================================================
-- PART 1: Add anterior-compartment muscle singletons to taxonomy
-- =============================================================================

-- tibialis_anterior:
--   Sole concentric mover during ankle dorsiflexion. The muscle is located
--   in the anterior (front) compartment of the lower leg, running from the
--   lateral tibia to the medial cuneiform and first metatarsal. It is the
--   primary agonist in exercises like the Tibialis Raise and Walking on Heels.
--   Singleton (no anatomical sub-heads that warrant separate volume tracking
--   at this granularity).

-- peroneals:
--   Covers peroneus longus and peroneus brevis (also called fibularis longus
--   and fibularis brevis). They run along the lateral lower leg from the
--   fibula to the foot. Primary function: evert and plantarflex the ankle;
--   critical for lateral ankle stability. Trained as stabilizers in most
--   exercises (0.25) and as primary movers only in dedicated eversion drills
--   (rare in hypertrophy programming). Authored as a singleton group for
--   programming purposes — the longus/brevis distinction rarely matters for
--   set/rep selection.

INSERT INTO public.muscles (muscle_id, display_name) VALUES
  ('tibialis_anterior', 'Tibialis Anterior'),
  ('peroneals',         'Peroneals')
ON CONFLICT (muscle_id) DO NOTHING;


-- =============================================================================
-- PART 2: Backfill Tibialis Raise (#73) — populate muscles JSONB
-- =============================================================================
-- PR #16 inserted #73 with muscles: '[]' because tibialis_anterior did not
-- yet exist in the taxonomy. Now that both muscle_ids exist we can populate
-- the column.
--
-- Weight rationale:
--
--   tibialis_anterior 1.0 — the sole concentric mover during dorsiflexion.
--     The tibialis raise is a pure isolation exercise for this muscle in the
--     same way that the leg extension (#25) is pure isolation for the quads.
--     There is no other muscle performing the dorsiflexion action, so 1.0 is
--     unambiguously correct.
--
--   peroneals 0.25 — the fibularis group stabilizes the ankle throughout the
--     dorsiflexion ROM. They do not drive the movement (they are ankle
--     everters, not dorsiflexors) but they co-activate to prevent excessive
--     inversion during the lift. Minor contributor in the comprehensive
--     tracking tier (§2 0.25 rule: "goes through real ROM under load OR
--     contributes a non-trivial stabilization role with meaningful load").
--
-- head_emphasis_notes remains NULL: with only one 1.0 muscle (tibialis
--   anterior is a singleton — no sub-heads) there are no rival heads to
--   distinguish via cue text.

UPDATE public.exercises
SET
  muscles = '[
    {"muscle_id": "tibialis_anterior", "weight": 1.0},
    {"muscle_id": "peroneals",         "weight": 0.25}
  ]'::jsonb,
  updated_at = NOW()
WHERE exercise_id = 'aaaaaaaa-0073-0000-0000-000000000001';


COMMIT;


-- =============================================================================
-- PART 3: Verification queries (run after migration, not part of transaction)
-- =============================================================================

-- Expected: 69 rows (67 from v2 + 2 new singletons)
-- SELECT COUNT(*) FROM public.muscles;

-- Expected: group=15, head=44, singleton=10 (was 8; now +2)
-- SELECT muscle_kind, COUNT(*) FROM public.muscles_with_kind GROUP BY muscle_kind;

-- Expected: both rows present
-- SELECT muscle_id, display_name FROM public.muscles
-- WHERE muscle_id IN ('tibialis_anterior', 'peroneals');

-- Expected: 2 rows — tibialis_anterior 1.0, peroneals 0.25
-- SELECT muscles FROM public.exercises
-- WHERE exercise_id = 'aaaaaaaa-0073-0000-0000-000000000001';

-- Expected: 0 rows (no exercise references a muscle_id that doesn't exist)
-- SELECT e.exercise_id, e.name, elem->>'muscle_id' AS missing_muscle
-- FROM public.exercises e,
--      jsonb_array_elements(e.muscles) AS elem
-- WHERE elem->>'muscle_id' NOT IN (SELECT muscle_id FROM public.muscles);
