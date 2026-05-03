# Personal OS — Dev Context

This file is context for Claude Code. Keep it accurate. If you change the stack, schema, or structural conventions, update this file in the same commit.

---

## What this app is

A personal operating system: one app for the things a self-reliant person uses to run their life — body, mind, money, relationships. Built primarily for the owner's own use, designed so it could open up to others later.

Current tabs: **Today** (daily checklist + streak), **Workout** (6-day rotating split, set logging, Ghost Racer, PRs, deload cycle), **History** (workout/PR/streak/volume/muscle/weight subtabs), **Nutrition** (macro tracking, AI label scan, eyeball estimation, manual entry), **Systems** (12 life-area reference sections).

The long roadmap (`TODO.md`) covers AI coaching, social/competitive features, computer-vision form feedback, hormone dashboards, and more. Treat that as the direction, not the next sprint.

---

## Stack

- **Frontend:** Single `index.html`, ~1500 lines. Vanilla JS, no build step.
- **React 18.2** + **ReactDOM 18.2** via cdnjs. `React.createElement` aliased as `h()`. **No JSX.**
- **Supabase JS v2** via jsdelivr.
- **Backend:** Supabase (remote only — no local `supabase start`). Project URL and anon key are hardcoded in `index.html`. Anon key in source is fine; if a key ever gets broader permissions than read-own-data, move it.
- **Auth:** email + password, email confirmation off. State machine: `loading → unauthed → onboarding → authed`. Wired via `onAuthStateChange`.
- **Edge functions:** none. All logic client-side.
- **Deploy:** push to `main` → GitHub Pages → live in ~60s. URL: https://ecommerceamazon51-cloud.github.io/personal-os/
- **PWA:** `manifest.json` present. Adding to home screen caches aggressively — updates may require remove + re-add to force fresh code.

---

## Database

Schema was applied manually in the Supabase SQL Editor. There is no migration tool. To prevent drift between the live DB and the repo, **every schema change must be reflected in `db/schema.sql`** in the repo, in the same commit that introduces it. That file is the source of truth even though it isn't auto-applied.

**Current tables (all with RLS, select/insert/update/delete on `user_id = auth.uid()`):**

- `profiles` — one row per user. Display name, goals, experience, gym access, macro targets, anthropic API key, cycle start, onboarding flag. Auto-created on signup via trigger.
- `checklist_completions` — `(user_id, date, task_id, is_done)`. Unique on `(user_id, date, task_id)`.
- `workout_logs` — `(user_id, date, exercise_idx, set_idx, weight, reps, is_done, day_override)`. **Legacy structure** — see "Workout migration" below. `exercise_idx` is an index into a hardcoded JS array, which is the structural problem the migration fixes.
- `nutrition_logs` — date, name, macros, portion multiplier, source, claude reasoning, logged_at.

**Pending tables (referenced in UI or spec but not yet created):**

- `body_weight_logs` — History → Weight subtab points at this. Either create it or hide the subtab; don't leave the dangling pointer.
- `exercises` + `workout_events` + derived-state tables — see workout migration.

**RLS rule:** every new user-data table gets RLS enabled and policies written before any client code touches it. No exceptions.

---

## Code conventions

- **Single file.** Until `index.html` exceeds ~5000 lines, don't split. When the time comes, that's a real change with its own design discussion.
- **`h()` not JSX.** Match the existing style — `h('div', {className: '...'}, child1, child2)`.
- **Optimistic updates → background upsert → revert on error.** This pattern is used throughout. New write paths follow it.
- **Toast on error, silent on success** unless the action benefits from confirmation.
- **Inline queries are fine.** Don't introduce a data layer abstraction without a reason. The app is small enough that locality beats indirection.
- **Tailwind utility classes** as used in current code. No CSS modules or styled-components.

---

## Workout migration (active project)

This is the focused work right now. Source of truth: `workout_module_v1_spec.md` (23 sections, in repo or attached to design chats).

**The structural problem:** `workout_logs.exercise_idx` references position in a hardcoded JS array. That makes the spec's recommendation engine — exercise database, muscle volume tracking, rep PRs across rotations, substitutions, stall cascade — impossible to build cleanly. The migration replaces this with proper IDs and an event log.

**Staged plan (each step independently shippable, live app never breaks):**

1. **Update CLAUDE.md** — done when this file is current.
2. **Create `exercises` table** per spec Section 18. Seed with 30–50 exercises covering the main movement patterns. Old workout tab keeps using its hardcoded array. **Have human review the first ~10 seeded exercises before batching the rest.** All authoring decisions (muscle weightings, demands tags, variation_attributes shape, workflow) are governed by `docs/exercise_authoring_conventions.md` — read it before touching seed data.
3. **Create `body_weight_logs`.** Spec needs it (relative-strength exercises) and the History tab already points at it.
4. **Create event log + derived state tables** per spec Section 20. Empty for now. Tables: `workout_events` (Layer 1 append-only), `rep_prs`, `weekly_volume`, `stall_state` (Layer 2 derived).
5. **Dual-write phase.** Every set logged to `workout_logs` also writes to `workout_events`. Old behavior unchanged. New data starts flowing.
6. **Build derived-state computation** from events. Verify outputs match what users actually did.
7. **Simplest suggestion path** — linear progression for hypertrophy goal — surfaced at end-of-session next to Ghost Racer. Spec Section 7 (progression detection) and Section 11 (stall detection).
8. **Migrate historical `workout_logs`** → events, retire old table, switch reads over.
9. **Layer in the rest of the spec:** cascade, top sets/back-offs, athletic, martial arts, onboarding questionnaire.

**Gotchas pinned from the spec:**

- **Stall definition (Section 11).** Reads as "no weight, rep, OR set increase." Intent is "*none* of weight/reps/sets went up" (logical AND across negations). Section 7 confirms: any one of those increasing counts as progression, so a stall is the absence of all three.
- **Volume targets are ceilings, not goals** (Section 3). The system discovers MRV from stalls and fatigue. Don't prescribe.
- **`progression_eligible` boolean** on exercises. Skill drills (martial arts, mobility) get logged but don't enter the rep PR / cascade system.
- **Frequency.** 2x/week per muscle beats 1x at intermediate+ volumes. Beginners 1x is fine.

---

## Exercise authoring conventions

**Source of truth: `docs/exercise_authoring_conventions.md`**

Read this file before drafting, reviewing, or inserting any rows into `exercises` or `exercise_substitutes`. It covers:

- **Muscle weighting rules** — when to use 1.0 vs 0.5 vs 0.25, and which stabilizers qualify for 0.25 at all
- **Demands tag vocabulary** — the closed set of valid `demands` strings and what each means
- **`variation_attributes` shape** — the key/value schema for the JSONB column
- **Authoring workflow** — how to add exercises to the seed file, the human-review gate before batch inserts, and how to write `exercise_substitutes` rows

This applies to: seeding exercises, writing substitution pairs, building any UI that reads or filters the exercise database, and any query logic that interprets muscle weights or demands tags.

---

## Roadmap context

`TODO.md` has the full 8-phase roadmap. In rough order: Phase 1 polish, Phase 2 AI coaching, Phase 3 nutrition intelligence, Phase 4 identity/growth engine, Phase 5 social, Phase 6 expert network, Phase 7 computer vision, Phase 8 hormones/biometrics. Workout-spec migration sits inside Phase 1–2 territory.

When working on non-workout features, keep two things in mind: the workout migration's data patterns (event log, derived state, RLS) are the templates for how other "intelligent" features should be built later. Nutrition AI, daily briefings, plateau detection across systems — all of those want the same shape.

---

## Open / known issues

- `body_weight_logs` table missing (see migration step 3).
- History → Muscles subtab content unclear; verify it works on real data once `exercises` table lands.
- `TAB_ORDER` array is dead code (swipe-to-switch was removed). Harmless, can be deleted any time.
- PWA cache aggressiveness — note above.
- No way to view/edit DB schema from the repo besides reading SQL files. If `db/schema.sql` doesn't exist yet when you read this, create it the next time a schema change happens, and backfill with the current schema in that same commit.

---

## How to work in this repo

- Read this file first.
- For workout-related work, also read `workout_module_v1_spec.md`.
- For anything touching the exercise database — seeding, querying, substitution pairs, UI filters, volume calculations — also read `docs/exercise_authoring_conventions.md`.
- For any task involving Supabase tables, confirm RLS is enabled and policies exist before writing client code that reads/writes those tables.
- Schema changes: write the SQL, paste it into Supabase SQL Editor, *and* update `db/schema.sql` in the same commit.
- Don't introduce new dependencies or build steps without flagging the change.
- If something in the spec or this file looks wrong or ambiguous, say so before guessing.
