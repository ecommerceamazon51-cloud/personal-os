-- Personal OS — Supabase Schema
-- Reconstructed from applied migration (no migrations file exists in repo).
-- All statements are idempotent; safe to re-apply to an empty database.
-- Run in: Supabase Dashboard > SQL Editor > New Query

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── profiles ────────────────────────────────────────────────────────────────
-- One row per auth user. Auto-created by trigger on_auth_user_created.

CREATE TABLE IF NOT EXISTS public.profiles (
  id                  UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name        TEXT,
  cycle_start         DATE        NOT NULL DEFAULT CURRENT_DATE,
  onboarding_complete BOOLEAN     NOT NULL DEFAULT FALSE,
  goals               JSONB       NOT NULL DEFAULT '[]'::jsonb,
  experience_level    TEXT        CHECK (experience_level IN ('beginner','intermediate','advanced')),
  gym_access          TEXT        CHECK (gym_access IN ('full','home','bodyweight')),
  target_calories     INT         NOT NULL DEFAULT 2800,
  target_protein      INT         NOT NULL DEFAULT 200,
  target_carbs        INT         NOT NULL DEFAULT 300,
  target_fat          INT         NOT NULL DEFAULT 80,
  anthropic_api_key   TEXT,
  created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "profiles_select_own" ON public.profiles
  FOR SELECT USING (auth.uid() = id);
CREATE POLICY "profiles_insert_own" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

-- Auto-create profile row when a new user signs up.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ─── checklist_completions ───────────────────────────────────────────────────
-- Replaces localStorage keys: checks-YYYY-MM-DD
-- task_id matches the id fields in the CHECKLIST constant in index.html.

CREATE TABLE IF NOT EXISTS public.checklist_completions (
  id         BIGSERIAL   PRIMARY KEY,
  user_id    UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date       DATE        NOT NULL,
  task_id    TEXT        NOT NULL,
  is_done    BOOLEAN     NOT NULL DEFAULT FALSE,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, date, task_id)
);

ALTER TABLE public.checklist_completions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "checks_select_own" ON public.checklist_completions
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "checks_insert_own" ON public.checklist_completions
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "checks_update_own" ON public.checklist_completions
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "checks_delete_own" ON public.checklist_completions
  FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_checks_user_date
  ON public.checklist_completions (user_id, date DESC);

-- ─── workout_logs ─────────────────────────────────────────────────────────────
-- Replaces localStorage keys: wlog-D-YYYY-MM-DD
-- exercise_idx and set_idx match WORKOUTS[day].exercises array positions.
-- day_override stores the workout day number when user manually overrides the
-- auto-assigned day (e.g. doing yesterday's workout today).

CREATE TABLE IF NOT EXISTS public.workout_logs (
  id            BIGSERIAL    PRIMARY KEY,
  user_id       UUID         NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date          DATE         NOT NULL,
  day_override  INT,
  exercise_idx  INT          NOT NULL,
  set_idx       INT          NOT NULL,
  weight        DECIMAL(6,2),
  reps          INT,
  is_done       BOOLEAN      NOT NULL DEFAULT FALSE,
  updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, date, exercise_idx, set_idx)
);

ALTER TABLE public.workout_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "wlogs_select_own" ON public.workout_logs
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "wlogs_insert_own" ON public.workout_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "wlogs_update_own" ON public.workout_logs
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "wlogs_delete_own" ON public.workout_logs
  FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_wlogs_user_date
  ON public.workout_logs (user_id, date DESC);

-- ─── nutrition_logs ───────────────────────────────────────────────────────────
-- One row per food item logged. portion_multiplier scales all macros at read
-- time (e.g. 0.5 = half portion). source records how the entry was created.
-- claude_reasoning is populated only for source='eyeball'.

CREATE TABLE IF NOT EXISTS public.nutrition_logs (
  id                 BIGSERIAL    PRIMARY KEY,
  user_id            UUID         NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date               DATE         NOT NULL,
  logged_at          TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  name               TEXT         NOT NULL,
  calories           INT          NOT NULL DEFAULT 0,
  protein            DECIMAL(6,2) NOT NULL DEFAULT 0,
  carbs              DECIMAL(6,2) NOT NULL DEFAULT 0,
  fat                DECIMAL(6,2) NOT NULL DEFAULT 0,
  portion_multiplier DECIMAL(4,2) NOT NULL DEFAULT 1.0,
  source             TEXT         NOT NULL DEFAULT 'manual'
                                  CHECK (source IN ('scan_label','eyeball','manual')),
  claude_reasoning   TEXT,
  notes              TEXT
);

ALTER TABLE public.nutrition_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "nlogs_select_own" ON public.nutrition_logs
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "nlogs_insert_own" ON public.nutrition_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "nlogs_update_own" ON public.nutrition_logs
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "nlogs_delete_own" ON public.nutrition_logs
  FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX IF NOT EXISTS idx_nlogs_user_date
  ON public.nutrition_logs (user_id, date DESC);

-- =============================================================================
-- EXERCISE DATABASE
-- =============================================================================
-- Reference data shared across all users (not user-owned rows).
-- RLS: authenticated users can SELECT; no INSERT/UPDATE/DELETE policy means
-- only the Supabase service role (SQL editor / server) can write. Fine for v1.
-- No seed data here — seeding is a separate step after human review.
-- =============================================================================

-- ─── Enums ───────────────────────────────────────────────────────────────────
-- All idempotent via DO $$ ... EXCEPTION WHEN duplicate_object pattern.
-- Type name → column name notes where they differ:
--   exercise_equipment  → equipment_primary column
--   exercise_role       → default_role column
--   exercise_authored_by → authored_by column

DO $$ BEGIN
  CREATE TYPE exercise_domain AS ENUM (
    'lifting', 'martial_arts', 'conditioning', 'mobility'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE movement_pattern AS ENUM (
    -- Compound patterns
    'squat', 'hinge', 'horizontal_push', 'vertical_push',
    'horizontal_pull', 'vertical_pull', 'lunge_split', 'carry',
    -- Isolation patterns (single-joint)
    'knee_flexion', 'knee_extension', 'elbow_flexion', 'elbow_extension',
    'ankle_plantarflexion', 'shoulder_abduction',
    -- Core / anti-patterns
    'rotation', 'anti_rotation', 'anti_extension', 'anti_lateral_flexion',
    -- Other
    'plyometric', 'locomotion', 'skill', 'mobility'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE loading_type AS ENUM (
    'bilateral', 'unilateral', 'alternating'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE exercise_equipment AS ENUM (
    'barbell', 'dumbbell', 'machine', 'cable', 'bodyweight',
    'kettlebell', 'band', 'specialty_bar', 'plyo_box', 'sled',
    'med_ball', 'bag', 'pads', 'none'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE exercise_role AS ENUM (
    'main_compound', 'secondary_compound', 'accessory', 'isolation'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE session_position AS ENUM (
    'early', 'anywhere', 'late'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE performance_metric AS ENUM (
    'weight_x_reps', 'bodyweight_x_reps', 'weighted_bodyweight',
    'time', 'distance', 'rounds_x_duration', 'reps_only', 'height', 'rpe_only'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE loaded_position AS ENUM (
    'stretched', 'mid', 'shortened', 'none'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE exercise_authored_by AS ENUM (
    'system', 'curator', 'user'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ─── muscles ─────────────────────────────────────────────────────────────────
-- Lookup table for the 22 muscles from spec Section 18.
-- muscle_id is a stable text key (snake_case) referenced inside the exercises
-- JSONB muscles array. No FK enforcement from JSONB — see calls below.

CREATE TABLE IF NOT EXISTS public.muscles (
  muscle_id    TEXT PRIMARY KEY,
  display_name TEXT NOT NULL
);

ALTER TABLE public.muscles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "muscles_select_authed" ON public.muscles
  FOR SELECT TO authenticated USING (TRUE);

INSERT INTO public.muscles (muscle_id, display_name) VALUES
  ('quads',           'Quadriceps'),
  ('hamstrings',      'Hamstrings'),
  ('glutes',          'Glutes'),
  ('calves',          'Calves'),
  ('chest',           'Chest'),
  ('lats',            'Lats'),
  ('traps_upper',     'Upper Traps'),
  ('traps_mid_lower', 'Mid/Lower Traps'),
  ('rhomboids',       'Rhomboids'),
  ('rear_delts',      'Rear Delts'),
  ('side_delts',      'Side Delts'),
  ('front_delts',     'Front Delts'),
  ('biceps',          'Biceps'),
  ('triceps',         'Triceps'),
  ('forearms',        'Forearms'),
  ('abs',             'Abs'),
  ('obliques',        'Obliques'),
  ('lower_back',      'Lower Back'),
  ('neck',            'Neck'),
  ('hip_flexors',     'Hip Flexors'),
  ('adductors',       'Adductors'),
  ('abductors',       'Abductors')
ON CONFLICT (muscle_id) DO NOTHING;

-- ─── exercises ───────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.exercises (
  exercise_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Identity
  name          TEXT            NOT NULL UNIQUE,
  aliases       TEXT[]          NOT NULL DEFAULT '{}',
  domain        exercise_domain NOT NULL,

  -- Movement classification
  movement_pattern_primary   movement_pattern NOT NULL,
  movement_pattern_secondary movement_pattern,
  loading_type               loading_type     NOT NULL,

  -- Muscle targeting
  -- Array of {muscle_id: text, weight: 1.0|0.5|0.25}.
  -- muscle_id values should match muscles.muscle_id (no FK; see calls).
  -- Only weights >= 0.5 count toward weekly volume calculations.
  muscles       JSONB           NOT NULL DEFAULT '[]'::jsonb,

  -- Equipment
  equipment_primary  exercise_equipment NOT NULL,
  equipment_specific TEXT,
  load_increment_default DECIMAL(5,2),
  load_increment_micro   DECIMAL(5,2),
  -- Per-user override lives in user_exercise_settings (future table).

  -- Programming role
  -- training_modality is TEXT[] not an enum array; values are:
  -- strength | hypertrophy | power | plyometric | stability | conditioning | skill | mobility
  -- Kept as TEXT[] so the list can grow without a migration. See calls.
  training_modality TEXT[]        NOT NULL DEFAULT '{}',
  default_role      exercise_role NOT NULL,
  session_position  session_position NOT NULL,

  -- Performance metric
  performance_metric     performance_metric NOT NULL,
  progression_eligible   BOOLEAN            NOT NULL DEFAULT TRUE,
  relative_to_bodyweight BOOLEAN            NOT NULL DEFAULT FALSE,

  -- Demands & prerequisites
  -- demands: free-form tag strings (e.g. 'overhead_rom', 'deep_knee_flexion').
  -- Kept as TEXT[] because the tag vocabulary isn't closed. See calls.
  demands       TEXT[]   NOT NULL DEFAULT '{}',
  -- prerequisites: array of {type: text, reference: text, threshold: text|numeric}.
  -- type values: 'exercise_competency' | 'mobility_check' | 'strength_minimum'
  -- No DB-level type enforcement since it's nested inside JSONB.
  prerequisites JSONB    NOT NULL DEFAULT '[]'::jsonb,

  -- Variations
  -- Exercises sharing the same exercise_family_id are variations of the same lift.
  -- No separate families table in v1 (no family-level metadata needed yet).
  exercise_family_id   UUID,
  variation_attributes JSONB,

  -- Loaded position (for stretch-bias programming variety)
  loaded_position loaded_position NOT NULL DEFAULT 'none',

  -- Metadata
  authored_by exercise_authored_by NOT NULL DEFAULT 'system',
  verified    BOOLEAN              NOT NULL DEFAULT FALSE,
  created_at  TIMESTAMPTZ          NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ          NOT NULL DEFAULT NOW()
);

ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;

CREATE POLICY "exercises_select_authed" ON public.exercises
  FOR SELECT TO authenticated USING (TRUE);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_exercises_domain
  ON public.exercises (domain);
CREATE INDEX IF NOT EXISTS idx_exercises_movement_pattern
  ON public.exercises (movement_pattern_primary);
CREATE INDEX IF NOT EXISTS idx_exercises_equipment
  ON public.exercises (equipment_primary);
CREATE INDEX IF NOT EXISTS idx_exercises_family
  ON public.exercises (exercise_family_id)
  WHERE exercise_family_id IS NOT NULL;
-- GIN indexes for array/JSONB containment queries
CREATE INDEX IF NOT EXISTS idx_exercises_muscles_gin
  ON public.exercises USING GIN (muscles);
CREATE INDEX IF NOT EXISTS idx_exercises_modality_gin
  ON public.exercises USING GIN (training_modality);
CREATE INDEX IF NOT EXISTS idx_exercises_demands_gin
  ON public.exercises USING GIN (demands);

DO $$ BEGIN
  CREATE TYPE substitute_reason AS ENUM (
    'same_pattern_different_equipment',
    'same_muscles_different_pattern',
    'regression',
    'progression',
    'injury_friendly_variant'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ─── exercise_substitutes ─────────────────────────────────────────────────────
-- Directed substitution graph. (A → B) and (B → A) are separate rows,
-- allowing asymmetric similarity scores and reasons (e.g. B is a regression
-- of A but A is a progression of B).

CREATE TABLE IF NOT EXISTS public.exercise_substitutes (
  exercise_id   UUID              NOT NULL REFERENCES public.exercises(exercise_id) ON DELETE CASCADE,
  substitute_id UUID              NOT NULL REFERENCES public.exercises(exercise_id) ON DELETE CASCADE,
  similarity_score DECIMAL(3,2)   NOT NULL CHECK (similarity_score BETWEEN 0 AND 1),
  reason        substitute_reason NOT NULL,
  PRIMARY KEY (exercise_id, substitute_id),
  CHECK (exercise_id <> substitute_id)
);

ALTER TABLE public.exercise_substitutes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "exercise_substitutes_select_authed" ON public.exercise_substitutes
  FOR SELECT TO authenticated USING (TRUE);
