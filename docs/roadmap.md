# Personal OS Workout Module — Roadmap

## Shipped

- **PR #22** — Exercise catalog browser with filter chips
- **PR #23** — Grouped accordion layout by muscle group
- **PR #25** — Substitute picker (catalog + workout SWAP)
- **PR #26** — Hotfix for PR #25 column naming
- **PR #27** — Session Builder (weekly planner with 2x-frequency framework)

## Queued

### PR #28 — Session spacing + smart set distribution
- Detect when same-muscle sessions are scheduled back-to-back without
  recovery; warn and suggest spacing.
- Smart distribution: when a head needs N weekly sets across 2 sessions,
  recommend an even split (e.g. 6+6, not 10+2) to minimize per-session
  fatigue.
- Surface "your chest sessions are 1 day apart — needs 48hr recovery"
  guidance.

### PR #29 — Auto-plan algorithm
- Given sessions/week and goal, auto-fill session cards with sensible
  exercises hitting MAV for each head.
- User can edit afterward.

### PR #30 — Anchor / accessory rotation
- Anchor exercises (main compounds) rotate every 8-12 weeks.
- Accessory exercises rotate every 4-6 weeks.
- Prevents stagnation and joint overuse.

### PR #31 — Experience-level scaling
- `profile.experience_level` is collected at onboarding but currently
  unused.
- Scale MUSCLE_HEAD_TARGETS by level:
  - Beginner: lower MEV/MAV/MRV (less volume tolerance)
  - Intermediate: current defaults
  - Advanced: higher MEV/MAV/MRV (needs more volume to progress)
- Deload frequency also scales (beginners less often, advanced more).

### PR #32 — Sticking point detection
- Analyze workout_logs over time per exercise.
- Detect plateaus (no PR for N weeks on a given lift).
- Recommend: variation swap, tempo work, deload, or volume adjustment.
- Requires sufficient log history per user before useful.

## Deferred / Backlog

- Persistence of built weeks to a `workout_templates` Supabase table.
- Equipment availability filtering (needs equipment prefs on profile).
- Per-head frequency tuning (calves/forearms tolerate higher
  frequency, low back lower).
- Day-of-week scheduling (currently sessions are abstract).
- Rest day insertion and distribution.
- Mobility/conditioning integration into the week structure.

## Principles

- Small, focused PRs. Each does one thing well.
- Verify column names against the live DB before coding — don't trust
  schema docs (Phase 2 lesson).
- Verify deploys in incognito, not hard refresh — PWA cache is
  aggressive.
- "Claude Code says done" ≠ "merged to main." Always read main commit
  history directly.
