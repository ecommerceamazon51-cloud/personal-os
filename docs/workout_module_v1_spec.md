# Workout Module — v1 Spec

Consolidated design decisions for the goal-driven, data-driven workout module. This document is the canonical reference for v1 implementation. Iterate as real user data comes in; lock structural decisions, default everything else.

---

## 1. Core Philosophy

Goal-driven app where users complete an onboarding questionnaire that determines a training profile. AI suggests exercises and structure; user always has final pick. Reactive progression — user logs what they did, app suggests what to do next session. The system is designed to **discover** each user's optimal volume, frequency, and recovery needs rather than prescribe them.

---

## 2. Goal System

Users select **primary, secondary, and tertiary** goals from:

- Build muscle (hypertrophy)
- Get stronger (powerlifting-style)
- Lose weight / get leaner
- Get more athletic
- Train martial arts
- General fitness / stay healthy

**Volume weighting when goals stack:**

- Primary = 100% of recommended volume
- Secondary = 60–70%
- Tertiary = 30–40% or maintenance/skill work

App flags conflicting goal combinations honestly (e.g., strength + weight loss compete for recovery) and lets the user keep, swap, or drop goals.

---

## 3. Experience Tiers

**Hybrid gating system** — uses years training, self-assessment, and strength benchmarks. If signals conflict, lower tier wins. Tiers are reassessed periodically.

| Tier | Years | Working sets per exercise | Weekly sets per muscle | Progression style |
|---|---|---|---|---|
| Beginner | 0–6 months | 2–3 | 10–12 | Linear, 1x/week frequency fine |
| Intermediate | 6 months–2 years | 3–4 | 14–18 | Double progression, 2x/week preferred |
| Advanced | 2+ years | 3–5 | 18–22+ | Autoregulated/RIR-based, 2–3x/week required |

**Volume targets are ceilings, not goals.** The system discovers each user's MRV (maximum recoverable volume) through stall and fatigue feedback.

**Frequency note:** Splitting weekly volume across 2 sessions per muscle outperforms cramming into one, especially as volume rises. Beginners can do 1x. Intermediates and advanced lifters should hit 2x+.

---

## 4. Rep Ranges by Goal

- **Hypertrophy:** 6–12 compounds, 8–15 isolation
- **Strength:** 3–6 main lifts, 6–10 accessories
- **Athletic:** 3–6 power/main, 6–12 accessories, plus 3–5 explosive
- **Weight loss:** same as hypertrophy
- **General fitness:** 6–12 across the board

When goals stack, primary goal's rep ranges dominate; secondary goal adds dedicated exercises in its own range.

---

## 5. Weight Increments

Smart defaults with user override per exercise:

- Lower body compounds: 10 lb
- Upper body compounds: 5 lb
- Isolation/accessory: 5 lb (2.5 lb if microloading enabled)
- Dumbbells: next available pair
- Machines: stack-dependent

Users can set "available increments" per exercise for gym-specific equipment.

---

## 6. Logging Modes

- **Simple mode:** weight × reps only. No effort flag — reps tell the story.
- **Advanced mode:** unlocks RIR (Reps in Reserve) 0–4 per set, enables autoregulated progression.

Default to simple for beginners, advanced for intermediates+ (user can override).

---

## 7. Progression Detection

Any of the following counts as progression:

- More weight, same reps/sets
- More reps, same weight/sets
- More sets, same weight/reps with good RIR
- Same load with lower RIR (easier = stronger)
- Beating an old rep PR at sub-maximal weight

---

## 8. Rep PR Tracking

Every set updates a rep PR table per exercise: best reps ever achieved at every weight. When stalled, app surfaces 2–3 lower-weight PR targets to chase ("your 215 PR is 6 reps — try 215×7"). PR history stays attached to the exercise across rotations.

---

## 9. Top Sets + Back-Off Sets

Structure for intermediate+ lifters. One heavy top set (chase strength) + 2–3 back-off sets at 85–90% of top weight (accumulate hypertrophy volume). Track both progressions in parallel — top set on strength rules, back-offs on hypertrophy rules.

---

## 10. Exercise Rotation

- **Main compound lifts** (squat, bench, deadlift, OHP, row): stable for 3–6 months
- **Accessories:** rotate every 4–8 weeks
- App surfaces "you haven't done X in 9 weeks, last PR was Y — want to retest?" when user returns to a rotated-out exercise
- Rep PR history persists per exercise across rotations

---

## 11. Stall Detection & Cascade

A stall = no weight, rep, OR set increase across recent sessions. Window adjusts by aggressiveness:

- Aggressive: 2 sessions
- Standard: 3 sessions
- Patient: 4 sessions

Default tied to tier (beginner → aggressive, intermediate → standard, advanced → patient). User can override.

**Cascade order (one at a time, user accepts or rejects each):**

1. Double progression nudge ("hit all reps before adding weight")
2. Microloading suggestion (2.5 lb jumps)
3. Rep PR at lower weight (offer 2–3 targets from history)
4. Back-off sets
5. Tempo/pause variation
6. Volume adjustment (add or strip a set)
7. Deload week
8. Exercise rotation

Cascade ordering will be refined from aggregate data (which interventions actually break stalls).

---

## 12. Deload Structure by Tier

- **Beginner:** Rare. Trigger: stalled 4+ weeks or fatigue reported. 70% weight, same reps, same sets, 1 week.
- **Intermediate:** Scheduled every 6–8 weeks OR cascade-triggered. 60% weight, 1 fewer set per exercise, 1 week.
- **Advanced:** Scheduled every 4–6 weeks. 50–60% weight on main lifts, reps cut 30–40%, sets cut 30–50%, drop or halve accessories, 1 week.

App educates users that deload = productive, encourages sleep/mobility/walking. Skips deload if user just took 7+ days off. More frequent deloads when user is in calorie deficit.

---

## 13. When User Ignores Suggestions

- 1st ignore: silent
- 2nd ignore: gentle ask ("was that intentional?")
- 3rd ignore: adapt — switch to stall-break interventions even if not technically stalled

---

## 14. Athletic Programming

**Principles:**

- CNS-intensive; doesn't stack with heavy lifting like hypertrophy work does
- Quality over quantity — low volume, high quality (3–5 sets, 3–5 reps, 2–3 min rest)
- Always early in the session
- Stop set when speed/quality drops, not at a fixed rep count

**Scheduling by goal weighting:**

- **Athletic primary:** 10–20 min plyo/power opens every session, then lifting. Athletic work 3–4x/week with rotating focus (vertical plyo, horizontal/lateral, upper body, sprint/agility).
- **Athletic secondary:** 5–10 min plyo/power in 2–3 sessions/week.
- **Athletic tertiary:** 5 min explosive primer in 1–2 sessions/week.

**Categories:**

- Lower body plyo (jumps, bounds, hops) — progress by box height, distance, drop height
- Upper body plyo (med ball throws, plyo push-ups) — progress by ball weight, distance, complexity
- Power lifts (cleans, push press, KB swings) — progress by weight at acceptable bar speed
- Sprint/agility/footwork — progress by time, distance, drill complexity, reduced rest

**Athletic-specific stall logic:** Stall = no progression on relevant metric (height, distance, bar speed, time). Cascade: deload first, technique check, variation swap, volume reduction.

**Same-category spacing:** At least 48 hours between same-category plyo sessions.

---

## 15. Martial Arts Approach

**Now:** Fundamentals library (stance, basic strikes, shadowboxing, bag combos, footwork) structured as progressive sessions. Heavy disclaimer that real progress needs a coach.

**Logging:** rounds × duration with optional RPE. Logged-only — does not enter rep PR table or stall cascade.

**Recovery accounting:** User inputs hours of martial arts training; lifting volume scales accordingly.

**Future:** Camera-based form feedback (pose estimation) unlocks objective progression tracking.

---

## 16. Session Flow

- Suggestions delivered at end-of-session summary AND pre-loaded when user opens next workout
- Session ordering: primary-goal work first when user is freshest
- Plyo/power → main compounds → accessories → conditioning/mobility (when goals require)

---

## 17. Edge Cases

- **First session ever:** Ask user to estimate or guide warm-up
- **Long break (10+ days):** Start at 80–85% of last working weight, rebuild over 1–2 weeks
- **Inconsistent set performance:** Ask "did something happen?" rather than punish next prescription
- **Bodyweight changes:** Track relative-strength exercises against bodyweight
- **Conflicting RIR vs reps:** Trust reps (objective) over RIR (subjective)
- **User-set "available increments":** Per exercise (gym equipment varies)
- **Warm-up sets:** Logged separately, don't count toward working volume

---

## 18. Exercise Database Schema

### Identity
- `exercise_id`, `name`, `aliases`, `domain` (lifting | martial_arts | conditioning | mobility)

### Movement classification
- `movement_pattern_primary` — full canonical list (22 values, post PR #4):
  - **Multi-joint compounds**: squat | hinge | horizontal_push | vertical_push | horizontal_pull | vertical_pull | lunge_split | carry
  - **Isolation (single-joint)**: knee_flexion | knee_extension | elbow_flexion | elbow_extension | ankle_plantarflexion | shoulder_abduction
  - **Anti-pattern / core stabilization**: rotation | anti_rotation | anti_extension | anti_lateral_flexion
  - **Other**: plyometric | locomotion | skill | mobility
- `movement_pattern_secondary` (nullable)
- `loading_type` (bilateral | unilateral | alternating)

### Muscle targeting (v2: per-head parent/child taxonomy)

**Structure.** The `muscles` lookup table uses a parent/child hierarchy via the `parent_muscle_id` column:

- **Group** (e.g. `triceps`): parent row with children. No exercise references a group directly.
- **Head** (e.g. `triceps_lateral`): child row with `parent_muscle_id` set. This is what exercises reference.
- **Singleton** (e.g. `brachialis`, `rhomboids`): no parent, no children. Referenced directly by exercises.

Use the `muscles_with_kind` view to derive the classification:

```sql
SELECT muscle_id, display_name, parent_muscle_id, muscle_kind
FROM public.muscles_with_kind;
-- muscle_kind ∈ { 'group', 'head', 'singleton' }
```

The `muscle_kind` column is **derived, not stored**, to avoid two sources of truth (a row's parent + a stored kind that could disagree).

**Display names are user-friendly.** `muscle_id` is for the schema and code; `display_name` is what users see in the app. Example: `muscle_id = 'pectorals'`, `display_name = 'Chest'`. Authoring references muscle_id, not display_name.

**Exercise muscle entries.** The `exercises.muscles` JSONB column is an array of `{muscle_id, weight}` objects:

```json
[
  {"muscle_id": "triceps_long",    "weight": 0.7},
  {"muscle_id": "triceps_lateral", "weight": 1.0},
  {"muscle_id": "triceps_medial",  "weight": 0.5}
]
```

Weights are decimal 0.0–1.0. Tier guidance (1.0 = target, 0.5 = synergist, 0.25 = minor contributor through ROM under load) is in `docs/exercise_authoring_conventions.md` §2. Intermediate values (0.3, 0.4, 0.6, 0.7, 0.85) are encouraged when contribution falls between tiers.

**Comprehensive 0.25 authoring (changed from v1).** Any muscle head that goes through ROM under load is listed, even if it doesn't count toward the current volume rule. Stored for advanced user profiles and future configurable volume math. See conventions §2.

**Head emphasis cues.** `exercises.head_emphasis_notes` is a nullable JSONB object mapping muscle_id → form cue text:

```json
{
  "triceps_lateral": "Keep elbows tucked to maximize lateral head; flaring shifts work toward long head.",
  "triceps_long":    "Overhead variants emphasize long head via shoulder flexion."
}
```

Populated only for heads where form distinguishes head emphasis. NULL when no per-head cues apply.

**Cross-listed muscles.** Rectus femoris is anatomically a quad (knee extensor) AND a hip flexor. In the taxonomy it lives under `quads` only; exercises that train it via hip flexion (hanging leg raise, etc.) list it under quads with a `head_emphasis_notes` entry explaining the function. This avoids duplicate rows. See conventions §13.

**Volume aggregation rules:**

1. **Per-head volume** is the source of truth. `weight × sets` per head, summed across the week.

2. **Volume eligibility threshold:** only entries weighted ≥ 0.5 count toward current weekly volume targets. (0.25 entries stored but ignored by current volume math; reserved for future user profile rules.)

3. **Group-level volume** = arithmetic mean of all head weights in the group, with untrained heads counted as zero. Example: a leg curl weighting 3 of 4 hamstring heads at 1.0 / 0 / 1.0 / 0.8 has a group score of (1.0 + 0 + 1.0 + 0.8) / 4 = 0.7. The untrained head pulls the group average down — this is correct, because the exercise genuinely doesn't train that head and the group score should reflect reality.

4. **Singletons** contribute directly (no aggregation needed).

**Muscle taxonomy (67 rows total, post-PR A):**
- 15 groups: quads, hamstrings, glutes, calves, adductors, hip_flexors, pectorals, lats, biceps, triceps, forearms, neck, deltoids, traps, rotator_cuff
- 44 heads (parent → child examples):
  - quads → rectus_femoris, vastus_lateralis, vastus_medialis, vastus_intermedius
  - hamstrings → bf_long, bf_short, semitendinosus, semimembranosus
  - glutes → max, medius, minimus
  - calves → gastrocnemius, soleus
  - adductors → magnus, short
  - hip_flexors → iliopsoas, tfl, sartorius
  - pectorals → clavicular, sternal, abdominal
  - lats → upper, lower *(functional regions, not anatomical heads; see conventions §13)*
  - biceps → long, short
  - triceps → long, lateral, medial
  - forearms → wrist_flexors, wrist_extensors, brachioradialis, grip *(grouped functional categories of ~20 forearm muscles; see conventions §13)*
  - neck → flexors, extensors
  - deltoids → anterior, lateral, posterior
  - traps → upper, middle, lower
  - rotator_cuff → supraspinatus, infraspinatus, teres_minor, subscapularis
- 8 singletons: rhomboids, spinal_erectors, rectus_abdominis, obliques, teres_major, serratus_anterior, brachialis, transverse_abdominis

Full authoring rules and per-head weighting patterns: see `docs/exercise_authoring_conventions.md` §13 + §14.

### Equipment
- `equipment_primary` (barbell | dumbbell | machine | cable | bodyweight | kettlebell | band | specialty_bar | plyo_box | sled | med_ball | bag | pads | none)
- `equipment_specific` (nullable; e.g., "leg_press")
- `load_increment_default`, `load_increment_micro`, `load_increment_user` (nullable override)

### Programming role
- `training_modality`: array (strength | hypertrophy | power | plyometric | stability | conditioning | skill | mobility)
- `default_role` (main_compound | secondary_compound | accessory | isolation) — programs can override
- `session_position` (early | anywhere | late)

### Performance metric
- `performance_metric` (weight_x_reps | bodyweight_x_reps | weighted_bodyweight | time | distance | rounds_x_duration | reps_only | height | rpe_only)
- `progression_eligible` (boolean; false for skill drills)
- `relative_to_bodyweight` (boolean)

### Demands & prerequisites
- `demands`: array of demand tags (overhead_rom, deep_knee_flexion, lumbar_loading, shoulder_external_rotation, ankle_dorsiflexion, etc.)
- `prerequisites`: array of `{type, reference, threshold}` where type is exercise_competency | mobility_check | strength_minimum

### Variations
- `exercise_family_id` (groups variations of same lift)
- `variation_attributes` (nullable map: grip, bar position, etc.)

### Substitution graph
- `substitutes`: array of `{exercise_id, similarity_score, reason}` where reason is same_pattern_different_equipment | same_muscles_different_pattern | regression | progression | injury_friendly_variant
- Auto-generated from other tags initially; hand-curated for high-traffic exercises

### Loaded position
- `loaded_position` (stretched | mid | shortened | none) — for stretch-bias programming variety

### Metadata
- `created_at`, `updated_at`, `authored_by` (system | curator | user), `verified` (boolean)

### Schema decisions worth noting
- Muscle weighting tiers (1.0 / 0.5 / 0.25) with intermediate values encouraged — easier to author than continuous weighting, but more honest than strict tiering when contribution falls between tiers.
- Per-head muscle taxonomy with parent/child structure (v2; previously flat 22-row taxonomy in v1). Group/head/singleton classification derived via `muscles_with_kind` view, not stored. Volume aggregation: per-head is source of truth; group-level is mean across all heads with untrained heads as zero.
- No static "skill" or "fatigue cost" tags — handled by prerequisites and runtime derivation
- Default role on exercise; program can override at usage time
- Substitutes computed initially, cached if performance demands
- `head_emphasis_notes` JSONB column carries form cues per head; populated only where form distinguishes head emphasis (grip width, foot position, elbow path, etc.).

---

## 19. Onboarding Questionnaire

**Block A — Goals**
1. Primary goal (single select; required)
2. Secondary/tertiary goals (multi-select up to 2; optional)
3. Conflict callout if competing goals selected

**Block B — Experience**
1. Years training consistently (single select)
2. Self-assessment as a lifter (single select)
3. Currently on a program? (single select)

**Block C — Strength benchmarks** (skippable)
1. Want to share numbers? (yes/skip)
2. Lifts done regularly (multi-select)
3. Best weight × reps OR estimated 1RM per lift
4. How recent? (single select)

**Block D — Body & basics**
1. Bodyweight (required if weight/composition goals)
2. Height (optional)
3. Age (range buckets preferred)
4. Sex assigned at birth (with prefer-not-to-say)

**Block E — Equipment & access**
1. Where you train (single select)
2. Equipment available (multi-select; conditional on E1)
3. Sessions per week (single select)
4. Time per session (single select)

**Block F — Constraints**
1. Current injuries (multi-select with free text)
2. Other training outside gym (multi-select with hours)

**Block G — Preferences**
1. Logging mode (simple/detailed; default by tier)
2. Aggressiveness (push/balanced/patient; default by tier)
3. Microloading interest (default by tier)

**End:** Summary screen showing inferred tier, goal weighting, weekly volume targets, session plan. User can accept or tweak. App explains reasoning when challenged.

**Required questions:** A1, B1, E1. Everything else skippable with defaults.

**Reassessment:** App checks in every couple months to update tier and goals.

---

## 20. Data Logging Schema

### Layer 1: Raw events (append-only)

**Set events:** `event_id`, `user_id`, `session_id`, `exercise_id`, `timestamp`, `set_number`, `weight`, `reps`, `RIR`, `was_warmup`, `was_suggested`, `suggested_weight`, `suggested_reps`, `felt_easier`, `felt_harder`

**Session events:** `session_started`, `session_completed`, `session_abandoned` (with reason), `planned_exercises`, `completed_exercises`, `duration`, `location`

**Suggestion events:** `suggestion_id`, `user_id`, `timestamp`, `context`, `suggestion_type`, `suggestion_payload`, `user_response` (accepted/rejected/modified), cascade context if applicable

**Cascade events:** `cascade_triggered`, `intervention_offered`, `intervention_outcome` (over next 1–3 sessions)

**User state events:** `goal_changed`, `tier_assessed`, `bodyweight_logged`, `external_training_logged`, `subjective_check_in` (sleep/soreness/stress 1–5), `injury_flag_added/removed`, `preference_changed`

**App engagement:** `session_opened/closed`, `notification_sent/tapped`, `feature_viewed`

### Layer 2: Derived state

**Per user:** current_tier, current_goals, weekly_volume by muscle (rolling 7d), frequency by muscle (rolling 7d), active_injuries

**Per user × exercise:** rep_pr_table, last_performed_date, last_working_weight/reps, current_stall_count, progression_history, estimated_1rm

**Per user × muscle group:** weekly_volume_history, frequency_history, discovered_MRV_estimate

### Layer 3: Aggregate analytics

- Suggestion efficacy (offer/acceptance/success by type, tier, goal)
- Cascade efficacy (stall-break rate per intervention, drives cascade reordering)
- Frequency analysis (1x vs 2x vs 3x at matched volume → progression rate)
- Volume / MRV distribution by tier and goal
- Tier accuracy (does promotion correlate with predicted progression change?)
- Drop-off analysis (where users churn, correlated factors)
- Goal-specific progression curves (basis for honest expectations to new users)

### User-facing data
- Personal stats and history always available
- Aggregate stats shown contextually only when n is meaningful — never fake industry averages
- Examples: "microloading breaks stalls for 64% of users in your tier" or "users at your volume training this muscle 2x/week progress 40% faster than 1x"

### Schema decisions worth noting
- Event sourcing for sets, sessions, cascades — append-only, derived state rebuildable
- Store rejected suggestions (not just accepted)
- Subjective fields kept cheap (3 questions max, 1–5 scales, optional)
- Privacy: anonymize/aggregate before storage where possible; be transparent with users

---

## 21. Cascade UI/UX

**Timing:** End-of-session as primary surface, start-of-next-session as confirmation. Never in-the-moment during sets.

**Surfacing pattern:**
1. Acknowledge stall, frame as productive ("plateaus are normal — let's try a tweak")
2. Offer one intervention with brief explanation; two buttons (accept / show other options)
3. Track outcome silently; celebrate small wins; offer next cascade step if it didn't work

**Ignored suggestions:**
- 1st: silent
- 2nd: small prompt at session start ("noticed you went your own way — anything we should know?")
- 3rd: switch recommendation engine to stall-break mode

**Visibility:** Power-user view of full cascade with explanations available; not surfaced to beginners by default.

**Aggregate data:** Show when meaningful and real ("works for X% of users like you"); omit until n is high enough.

**Components to build:** stall notification card, cascade options screen, intervention preview, outcome tracking (silent), cascade history view.

---

## 22. Iteration Plan

**Lock for v1:**
- Exercise database schema (fields and relationships)
- Logging schema (event types, derived state structure)
- Performance metric flexibility (weight×reps, time, distance, rounds, height, etc.)
- Rep PR table structure
- Demands/prerequisites split (exercise side vs user side)
- Domain field on exercises

**Reasonable defaults, refine from data:**
- Exact volume/set targets per tier
- Rep range boundaries
- Stall window defaults
- Main-vs-accessory classification per exercise
- Fatigue cost modeling
- Default rest times
- Cascade ordering
- Strength benchmarks for tier gating

**Open questions for post-launch:**
- Does 2x/week beat 1x at matched volume? (frequency analysis)
- What's the real MRV distribution? (volume analysis)
- Which cascade interventions actually work? (cascade efficacy)
- Are tier thresholds correctly placed? (tier accuracy)
- What causes churn? (drop-off analysis)

---

## 23. Out of Scope for v1

- Camera-based form feedback for martial arts (future)
- Detailed nutrition tracking (recovery accounting only)
- Social/community features
- Wearable integration for HRV-driven readiness
- Stimulus-to-fatigue-ratio (SFR) tagging per exercise
- Estimated time per set (for session duration prediction)
- Aggregate stats UI (defer until n is meaningful)

---

*This spec is the v1 baseline. Update as data and use reveal what works.*
