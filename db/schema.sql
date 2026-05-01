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
