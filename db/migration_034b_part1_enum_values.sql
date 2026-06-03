-- =============================================================================
-- Migration 034b Part 1 — Extend movement_pattern enum (6 new values)
-- =============================================================================
-- RUN THIS FIRST, as its own statement/commit, BEFORE part 2.
-- Postgres error 55P04: new enum values must be committed before they can be
-- used in any INSERT. Do NOT paste parts 1 and 2 as a single query — it will
-- fail with "unsafe use of new value of enum type".
--
-- Exercises that require these new values:
--   neck_flexion      → #85 Weighted Neck Flexion
--   neck_extension    → #86 Weighted Neck Extension
--   wrist_flexion     → #87 Wrist Curl
--   wrist_extension   → #88 Reverse Wrist Curl
--   ankle_eversion    → #89 Ankle Eversion
--   hip_abduction     → #90 Hip Abduction Machine, #92 Lateral Band Walk
--
-- Exercises #91 (Serratus Punch, horizontal_push) and #93 (Weighted Hanging
-- Knee Raise, anti_extension) use existing patterns — no new values needed for
-- them. All 9 gap-fill INSERTs are in part 2.
--
-- Rollback note: Postgres does not support removing enum values without
-- recreating the type. If rollback is needed, just leave these values unused —
-- do NOT try to DROP TYPE.
-- =============================================================================

ALTER TYPE movement_pattern ADD VALUE IF NOT EXISTS 'neck_flexion';
ALTER TYPE movement_pattern ADD VALUE IF NOT EXISTS 'neck_extension';
ALTER TYPE movement_pattern ADD VALUE IF NOT EXISTS 'wrist_flexion';
ALTER TYPE movement_pattern ADD VALUE IF NOT EXISTS 'wrist_extension';
ALTER TYPE movement_pattern ADD VALUE IF NOT EXISTS 'hip_abduction';
ALTER TYPE movement_pattern ADD VALUE IF NOT EXISTS 'ankle_eversion';
