# TODO.md — Personal OS Roadmap

## Phase 1: Polish & Ship (Now)
_Goal: Make the current app feel complete enough to show people._

- [ ] **Rest timers between sets**
  - Auto-start countdown after checking a set as done
  - Default durations: 90s (accessories), 120s (compounds), 180s (heavy compounds)
  - Manual override: tap to pick a different time or restart
  - Visual countdown with vibration/sound alert at 0
  - Floating/sticky timer so user can scroll while it counts

- [ ] **Content/layout refinements**
  - Review all 12 Systems sections for completeness and actionability
  - Make checklist items in Today tab match the daily schedule content
  - Add subtle animations/transitions for tab switches
  - Improve History tab chart readability on small screens

- [ ] **Quality of life fixes**
  - Add "finish workout" button that saves session summary
  - Show total session volume (sets × reps × weight) at bottom of workout
  - Add date picker to view past workout logs
  - Swipe between tabs on mobile

---

## Phase 2: AI Coaching Layer
_Goal: The app starts talking back — personalized, context-aware guidance._

- [ ] **AI workout coaching**
  - Post-workout summary: "You hit 3 PRs today, volume up 12% vs last week"
  - Pre-workout suggestions: "Last time you stalled at 225 on bench — try 230 for 3 today"
  - Deload intelligence: "You've been grinding 3 weeks, form notes show fatigue — deload recommended"
  - Plateau detection: flag exercises with no progress over 2+ weeks

- [ ] **AI daily briefing**
  - Morning summary: "Day 18 streak. Leg day. You're in week 3 of 4. Priorities: close the deal from yesterday, hit squat PR."
  - Pull from checklist, workout schedule, and any logged goals

- [ ] **Systems coaching**
  - Based on which Systems sections the user engages with most/least
  - Nudges: "You haven't reviewed your money block in 5 days"
  - Content recommendations: suggest specific YouTube/books/podcasts based on stated goals

---

## Phase 3: Nutrition Intelligence
_Goal: Food tracking that doesn't suck._

- [ ] **Manual food logging (v1)**
  - Search database for common foods
  - Quick-add frequent meals (save custom meals)
  - Daily macro progress bars (protein/carbs/fat/calories)
  - Targets based on user profile (weight, goal, activity level)

- [ ] **Phone camera food recognition (v2)**
  - Photograph plate → AI identifies foods → estimates portions → calculates macros
  - User confirms/adjusts before logging
  - Builds personal food library over time

- [ ] **Smart scale integration (v3)**
  - Bluetooth food scale pairs with app
  - Place food on scale → select food type → exact macro calculation
  - Research: partner with existing scale manufacturers or build custom
  - This is a potential hardware product opportunity

- [ ] **Smart fridge concept (future)**
  - Log fridge/pantry contents
  - Track expiration dates
  - Suggest meals from available ingredients
  - Auto-generate grocery lists based on meal plan + what's missing

---

## Phase 4: Identity & Growth Engine
_Goal: The app knows where you're going, not just where you've been._

- [ ] **Goal visualization**
  - User defines future self across each system (health, money, social, etc.)
  - Quarterly milestone setting with progress tracking
  - Visual "gap analysis" — where you are vs where you want to be

- [ ] **Curated content engine**
  - AI recommends YouTube channels, books, podcasts, courses based on goals
  - Tracks what user has consumed
  - "Reading list" / "Watch list" integrated into daily checklist

- [ ] **Identity journal**
  - Daily reflection prompts tied to Systems
  - AI analyzes patterns over time (what topics come up, mood trends)
  - Weekly/monthly summary reports

---

## Phase 5: Social & Competitive
_Goal: Make improvement a team sport._

- [ ] **User accounts & authentication**
  - This is the moment we need a backend (Firebase, Supabase, or custom)
  - Migrate localStorage data to cloud storage
  - User profiles with stats, PRs, streaks

- [ ] **Leaderboards**
  - Rank friends by: total volume, PR count, streak length, consistency %
  - Weekly and all-time views
  - Opt-in: users choose what metrics to share

- [ ] **Accountability groups**
  - Small crews (3-6 people)
  - Daily check-in: did you complete your checklist?
  - Group streak tracking
  - Simple chat or reaction system

- [ ] **Head-to-head challenges**
  - 1v1 weekly competitions
  - Challenge types: most volume, longest streak, biggest single PR improvement
  - History of past challenges and win/loss record

---

## Phase 6: Expert Network & Credibility
_Goal: Get respected people involved to improve content and reach._

- [ ] **Identify target experts**
  - Fitness: coaches with proven results and good audiences
  - Nutrition: registered dietitians or evidence-based creators
  - Martial arts: active competitors or respected coaches
  - PT/rehab: sports physical therapists
  - Business/mindset: entrepreneurs with real track records

- [ ] **Partnership model**
  - Expert-curated content within their system (e.g., a PT designs the rehab protocols)
  - Affiliate/ambassador deals: they promote, they earn
  - Leverage their audience trust for distribution
  - Premium tier: direct coaching or Q&A with experts

- [ ] **Content quality audit**
  - Have experts review and improve each of the 12 Systems
  - Replace generic advice with expert-backed protocols
  - Add citations and evidence where possible

---

## Phase 7: Computer Vision Coaching
_Goal: AI watches you train and gives real-time feedback._

- [ ] **Research phase**
  - Evaluate existing pose estimation models (MediaPipe, OpenPose, MoveNet)
  - Determine: phone camera sufficient vs multi-camera setup needed
  - Define MVP: which exercises to support first (squat, deadlift, bench)

- [ ] **Phone camera MVP**
  - Single camera angle for basic lifts
  - Rep counting
  - Depth detection (did you hit parallel on squat?)
  - Bar path tracking (bench press, OHP)

- [ ] **Multi-camera system (future)**
  - Multiple angles for full 3D body tracking
  - Covers: weightlifting, calisthenics, martial arts, PT rehab
  - Real-time feedback overlay
  - Injury risk detection: flag compensatory movements

---

## Phase 8: Hormone & Biometrics Dashboard
_Goal: Track what's happening inside, not just outside._

- [ ] **Bloodwork input**
  - Manual entry of lab results (testosterone, cortisol, thyroid panel, lipids, etc.)
  - Reference ranges with color-coded status (optimal/normal/low/high)
  - Track levels over time with trend charts

- [ ] **AI protocol recommendations**
  - Based on bloodwork: suggest supplement adjustments, lifestyle changes, when to retest
  - Flag concerning trends: "Cortisol has been elevated 3 tests in a row"
  - Integrate into daily checklist: "Take vitamin D — your last test showed 22 ng/mL"

- [ ] **Wearable integrations (future)**
  - Whoop: recovery score, strain, sleep
  - Oura Ring: sleep stages, readiness, temperature
  - Apple Watch / Garmin: heart rate, HRV, activity
  - Pull data automatically, surface insights in daily briefing

---

## Technical Milestones

| Milestone | Trigger | What Changes |
|-----------|---------|-------------|
| Backend needed | Phase 5 (social features) | Add Firebase/Supabase, user auth, cloud storage |
| Multi-file split | When index.html exceeds ~5000 lines | Split into modules, add simple build step |
| Mobile app | When PWA limitations become blocking | React Native or Flutter wrapper |
| Hardware R&D | Phase 3v3 (smart scale) | Research manufacturing, partnerships, or licensing |
| Monetization | Phase 4-5 | Freemium model: free core, paid AI coaching + social + expert content |

---

## Seed Data Process

- [ ] **Substitute backfill pass after each new exercise batch**
  - Each batch's own substitute INSERTs only cover edges from new exercises outward to existing ones. After a batch lands, do a separate backfill pass to add reverse edges and fill gaps in older rows that didn't have enough substitutes at original insert time (e.g., chest-supported row currently has only 1 outgoing edge).
  - Examples: when batch 3 adds lat pulldown, the chest-supported row from batch 2 should pick up an edge to it; when more lateral work lands, the lateral raise from batch 1 should get substitutes added.
  - Aim: every exercise has ≥ 2 outgoing substitutes before its batch is marked "done."

---

## North Star
One app. Everything a self-reliant person needs to optimize their body, mind, money, and relationships — without hiring 5 different coaches. Clear steps. Built-in accountability. Gets smarter the more you use it.
