# Personal OS

A single-file vanilla JS web app for tracking workouts, nutrition, and daily habits, with cloud sync via Supabase.

## Stack

See [CLAUDE.md](CLAUDE.md) for full details. `index.html` contains the entire frontend (React 18 via CDN, no build step). Backend is Supabase (auth, Postgres, RLS). Deployed via GitHub Pages.

## Documentation

- [docs/workout_module_v1_spec.md](docs/workout_module_v1_spec.md) — Full spec for the workout module: exercise database, progression logic, volume tracking, stall detection, and the migration plan away from the legacy index-based data model.
- [docs/exercise_authoring_conventions.md](docs/exercise_authoring_conventions.md) — Conventions for authoring exercise rows: muscle weighting rules, demands tag vocabulary, variation_attributes shape, and the seed data workflow.

## Database

`db/schema.sql` is the source of truth for the Supabase schema. There is no migration tool — changes are applied manually via the Supabase SQL Editor and must be reflected in `db/schema.sql` in the same commit.

## Deploy

Push to `main` → GitHub Pages builds and deploys automatically in ~60 seconds.
Live: https://ecommerceamazon51-cloud.github.io/personal-os/
