-- MTBox Campaign Tracker — Supabase schema
-- Run this in the Supabase SQL editor: https://supabase.com/dashboard/project/euxbkoxtetsqhiiitpvv/sql

-- ── campaigns table ──────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.campaigns (
  id                  TEXT        PRIMARY KEY,
  user_id             UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name                TEXT        NOT NULL,
  goal                TEXT        NOT NULL DEFAULT '',
  total_days          INTEGER     NOT NULL DEFAULT 30,
  current_day         INTEGER     NOT NULL DEFAULT 0,
  is_active           BOOLEAN     NOT NULL DEFAULT true,
  -- Comma-separated 0s and 1s, e.g. "1,0,1,1" (false=0, true=1)
  day_history         TEXT        NOT NULL DEFAULT '',
  last_check_in_date  TEXT,
  reminder_enabled    BOOLEAN     NOT NULL DEFAULT false,
  reminder_time       TEXT,                          -- "HH:mm" 24h, e.g. "09:00"
  color_hex           TEXT        NOT NULL DEFAULT '4C6EAD',
  icon_name           TEXT        NOT NULL DEFAULT 'fitness_center',
  -- GoalType enum index: 0=days, 1=hours, 2=sessions, 3=custom
  goal_type           INTEGER     NOT NULL DEFAULT 0,
  metric_name         TEXT        NOT NULL DEFAULT '',
  created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ── Row Level Security ────────────────────────────────────────────────────────

ALTER TABLE public.campaigns ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own campaigns"
  ON public.campaigns
  FOR ALL
  USING  (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ── Realtime ──────────────────────────────────────────────────────────────────

-- Enable Realtime for the campaigns table in the Supabase dashboard:
-- Database → Replication → supabase_realtime publication → add campaigns table.
-- Or run:
ALTER PUBLICATION supabase_realtime ADD TABLE public.campaigns;
