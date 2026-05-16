# Applied Migrations Log

Tracks when migrations were actually applied to the Supabase database, separate from when their PRs merged to main. Per project convention, "merged to main ≠ applied to Supabase" — this file is the source of truth for what's live.

## PR A — Muscle Taxonomy v2 Schema Migration
- **File:** `db/migration_muscle_taxonomy_v2.sql`
- **PR:** #8
- **Merged to main:** 2026-05-07
- **Applied to Supabase:** 2026-05-07
- **Verification:** All 6 PART 5 queries returned expected results
  - Total muscles: 67 (was 22 in v1)
  - Kind breakdown: group:15, head:44, singleton:8
  - Zero orphan parent references
  - Zero v1 muscle_ids remaining in exercises JSONB
  - Zero exercises referencing non-existent muscle_ids
  - Display names verified user-friendly for renames (Chest, Lower Back, Abs, etc.)
- **Notes:** Schema-only changes. Per-exercise muscle distribution re-authoring deferred to PR B. The `head_emphasis_notes JSONB` column added in this migration was missing from `db/schema.sql` until PR #13 synced the file to match the live DB (no DB change — file-only).

## PR B — Muscle Taxonomy v2 Exercise Re-Authoring
- **File:** `db/migration_reseed_exercises_v2.sql`
- **PR:** #10
- **Merged to main:** 2026-05-15
- **Applied to Supabase:** 2026-05-15
- **Verification:** All 6 verification queries passed
  - Total exercises: 65
  - Total substitution edges: ~150–165
  - Zero exercises referencing group-level muscle_ids
  - Zero exercises referencing non-existent muscle_ids
  - `head_emphasis_notes` populated on all 65 exercises (0 NULL)
  - Pilot 5 spot-check matched expected muscle counts (Squat 15, Pull-Up 18, Lateral Raise 6, BSS 20, Leg Press 11)
- **Notes:** Required a follow-up fix in PR #11 (combined TRUNCATE statements) before successful application. First apply attempt failed with FK constraint error 0A000.

## PR #11 — TRUNCATE Syntax Fix (reseed migration)
- **File:** `db/migration_reseed_exercises_v2.sql`
- **PR:** #11
- **Merged to main:** 2026-05-15
- **Notes:** Two-line fix combining sequential TRUNCATE statements into one. Resolved FK constraint blocker on PR B migration. Not separately applied to Supabase — fix was applied as part of the re-run of the corrected migration.
