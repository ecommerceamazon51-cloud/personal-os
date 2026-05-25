-- PR #30: user_exercise_notes
-- Run manually in Supabase Dashboard → SQL Editor BEFORE merging the frontend code.

CREATE TABLE user_exercise_notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  exercise_id uuid NOT NULL REFERENCES exercises(exercise_id) ON DELETE CASCADE,
  muscle_id text NOT NULL,
  cue_text text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id, exercise_id, muscle_id)
);

CREATE INDEX idx_user_exercise_notes_user_ex ON user_exercise_notes(user_id, exercise_id);

ALTER TABLE user_exercise_notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_select_own_notes" ON user_exercise_notes
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "users_insert_own_notes" ON user_exercise_notes
  FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "users_update_own_notes" ON user_exercise_notes
  FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "users_delete_own_notes" ON user_exercise_notes
  FOR DELETE USING (auth.uid() = user_id);
