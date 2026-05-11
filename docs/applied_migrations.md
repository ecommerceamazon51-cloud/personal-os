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
- **Notes:** Schema-only changes. Per-exercise muscle distribution re-authoring deferred to PR B.
