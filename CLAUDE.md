# CLAUDE.md — Personal OS

## What This Is
Personal OS is a personal optimization platform disguised (for now) as a fitness app. The long-term vision is a comprehensive life operating system that integrates training, nutrition, identity/growth coaching, social accountability, hormone tracking, and eventually AI-powered computer vision for form correction — all in one product.

**Live URL:** https://ecommerceamazon51-cloud.github.io/personal-os/
**Deployment:** GitHub Pages (static, no build step)
**Repo:** https://github.com/ecommerceamazon51-cloud/personal-os

---

## Tech Stack
- **Single `index.html` file** — everything lives in one file
- **Vanilla JavaScript** — no JSX, no build tools, no Babel
- Uses `React.createElement` directly (aliased as `h()`)
- **React + ReactDOM via CDN** (loaded from unpkg)
- **localStorage** for all data persistence (day-specific keys to prevent bleed)
- **No backend** — fully client-side
- Mobile-first design, dark theme, monospace typography (`Courier New`)
- Designed to be added to phone home screen as a PWA-like experience

---

## Current App Architecture (4 Tabs)

### Tab 1: Today
- Daily checklist with toggleable tasks
- Tasks organized by life category (money, health, social, etc.)
- Completion percentage tracked for streak system
- Day-specific storage so tasks don't carry across days

### Tab 2: Workout
- 7-day rotating split: Chest+Back Heavy → Legs → Recovery → Arms+Shoulders → Plyo+Power → Chest+Back Volume → Rest
- Per-exercise set logging: weight (lbs) + reps + done checkbox
- **Ghost Racer:** shows last session's numbers per exercise (purple banner) so user knows what to beat
- **PR Badges:** inline display of personal records next to each exercise
- **Smart Cycle Tracker:** "Week X of 4" with warning before deload week
- **Auto Deload:** week 4 automatically calculates weights at 60% of best
- **Input Fix:** uses `onBlur` instead of `onChange` so typing full numbers works on mobile
- Number inputs use `inputMode="numeric"` for mobile keyboard

### Tab 3: History
- **PRs:** all-time personal records sorted by weight, per exercise
- **Streaks:** tracks daily checklist completion (75%+ = streak day), shows current/longest/total
- **Volume Charts:** bar charts showing weekly total volume (lbs) and training days over last 8 weeks

### Tab 4: Systems
- All 12 life sections from the Personal Operating System document
- Expandable/collapsible accordion UI
- Sections: Overview, Money, Health/Nutrition, Training, Posture/Height, Combat, Brotherhood, Social/Sexual, Grooming/Style, Supplements/Peptides, Preparedness, Daily Schedule

---

## The 12 Systems (Content Reference)

These are the core life systems built into the app. They currently display as reference content but will evolve into actionable, trackable modules.

1. **Identity/Overview** — "Consolidate → Stabilize → Scale" framework. Priority stack: Money > Health > Brotherhood > Social > Preparedness.
2. **Money** — Daily money blocks (revenue generation, AI/systems work, skill improvement). Sales optimization, pipeline management, income volatility fixes.
3. **Health/Nutrition** — Target: 175g protein, 2800-3000 cal/day. Meal timing around training. Hydration protocol. Micronutrient focus (Mg, D3+K2, Zinc, Omega-3, Creatine).
4. **Training** — 6-day split with progressive overload. Double progression system. Deload every 4th week. Back rehab + knee strengthening protocols.
5. **Posture/Height** — APT correction, forward head posture fix, thoracic kyphosis correction. AM/PM protocol. Spinal decompression (dead hangs, inversion).
6. **Combat** — Heavy bag work (10 rounds), shadowboxing, Muay Thai focus. Conditioning: rope, sprints, neck curls, farmer carries. Future: MMA gym when budget allows.
7. **Brotherhood** — Be reliable, useful, discreet. Help without asking. Network expansion.
8. **Social/Sexual** — Higher standards, more intentional relationships, discipline over impulse.
9. **Grooming/Style** — Skincare routine, haircut cadence, wardrobe fundamentals (fit > brand). Chelsea boots for height.
10. **Supplements/Peptides** — Daily stack: creatine, fish oil, D3+K2, magnesium, zinc, ashwagandha. BPC-157 breakdown (promising but limited human data).
11. **Preparedness** — Insurance layer, low time investment, high seriousness. Emergency fund, situational awareness, basic medical/legal readiness.
12. **Daily Schedule** — Time-blocked from 5:30 AM wake to 10 PM sleep. Morning ritual → money blocks → training → brotherhood → flex → decompress → evening wind-down.

---

## Target Market
**Primary:** Anyone serious about self-improvement
**Marketing segments (separate ad campaigns for each):**
- Young men 20-30 grinding solo without a coach
- Entrepreneurs/busy professionals optimizing everything
- Athletic, ambitious people building something

**Core user persona:** Self-reliant, busy, willing to do the work but needs clear steps and accountability — not hand-holding. Doesn't have time to hire 5 different coaches.

---

## Product Vision (6 Layers)

### Layer 1 — Training Tracker ✅ (Current)
Smart workout logging with ghost racer, PR tracking, auto-deload, cycle management, daily checklist, streaks, volume analytics.

### Layer 2 — Nutrition Intelligence (Next)
- Phone camera AI: photograph food → auto-identify → calculate macros → log
- Smart scale integration: weigh food → select type → auto-log calories/macros
- Daily macro targets with progress bars
- Smart fridge concept: log contents, track expiration, suggest meals from what's available
- Eventually: partner with hardware companies or build proprietary scale

### Layer 3 — Identity & Growth Engine
- Goal visualization: user defines their future self
- AI-curated content: recommends specific YouTube channels, books, podcasts based on goals
- Personalized daily actions derived from identity goals
- Progress tracking against self-defined milestones

### Layer 4 — Expert Network & Credibility
- Partner with respected figures in fitness, nutrition, martial arts, PT, business
- Use their expertise to improve app content quality
- Affiliate/ambassador relationships for distribution (leverage their trust + audience)
- Premium content or coaching tiers

### Layer 5 — Computer Vision Coaching
- Multi-camera setup for real-time form analysis
- Covers: weightlifting, calisthenics, martial arts, PT rehab exercises
- AI feedback on body positioning, range of motion, injury risk
- Injury detection: flag compensatory movement patterns

### Layer 6 — Hormone & Biometrics Dashboard
- Input bloodwork results (testosterone, cortisol, thyroid, etc.)
- AI analysis with actionable protocol recommendations
- Track hormone levels over time with trend visualization
- Integration into daily checklist and supplement recommendations
- Eventually: wearable integrations (Whoop, Oura, Apple Watch)

---

## Social & Competitive Features
- **Leaderboards:** rank against friends on PRs, streaks, total volume, consistency
- **Accountability groups:** small crews (3-6 people) with daily check-ins
- **Head-to-head challenges:** 1v1 weekly competitions (most volume, longest streak, biggest PR improvement)
- All three modes — users choose their competitive style

---

## Brand
- **Name:** Personal OS (working name, may evolve)
- **Tagline direction:** "Consolidate → Stabilize → Scale"
- **Aesthetic:** Dark, monospace, utilitarian — feels like a command center, not a lifestyle app
- **Tone:** Direct, no-BS, actionable. Respects the user's intelligence.

---

## Key Technical Decisions
- **Single file architecture** — keeps deployment dead simple (just upload to GitHub Pages)
- **No build step** — avoids npm/webpack complexity, anyone can fork and modify
- **localStorage over backend** — zero cost, instant, works offline. Will need migration strategy when social features require a backend.
- **React via CDN** — gets component model without build tooling
- **`onBlur` for inputs** — solved the mobile keyboard issue where `onChange` was kicking users out of number fields mid-type
- **Day-specific storage keys** — format: `wlog-YYYY-MM-DD` prevents workout data from bleeding across days

---

## Development Workflow
1. Edit `index.html` locally
2. Test in browser (just open the file or use `npx serve`)
3. Commit and push to `main` branch
4. GitHub Pages auto-deploys within ~60 seconds
5. Hard refresh on phone to see changes (may need to clear cache)

Note: Keep `index.html` under ~5000 lines. Beyond that, split into modules with a simple build step (see Technical Milestones in TODO.md).

---

## Important Notes for Claude Code
- This is a SINGLE FILE app. Do not split into multiple files.
- All React code uses `React.createElement` aliased as `var h = React.createElement`. Do NOT use JSX.
- All styling is inline JavaScript objects, no external CSS files.
- Test that number inputs work properly on mobile after any changes.
- localStorage keys are prefixed and day-specific — be careful not to break existing data formats.
- The app must work on both desktop and mobile, but mobile is the primary use case.
- When adding features, maintain the existing tab structure. New major features may warrant new tabs.
- Keep the dark monospace aesthetic consistent. Colors: bg #08080a, cards #111, accent green #22c55e, orange for warnings, purple for ghost racer.
