-- ① Supabaseのダッシュボード > SQL Editor で実行してください

-- スタッフテーブル
CREATE TABLE IF NOT EXISTS staff (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  dept TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 打刻テーブル
CREATE TABLE IF NOT EXISTS attendance (
  id BIGSERIAL PRIMARY KEY,
  staff_id TEXT NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
  staff_name TEXT NOT NULL,
  dept TEXT DEFAULT '',
  type TEXT NOT NULL CHECK (type IN ('in','out')),
  time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- インデックス（検索高速化）
CREATE INDEX IF NOT EXISTS idx_attendance_time ON attendance(time DESC);
CREATE INDEX IF NOT EXISTS idx_attendance_staff_id ON attendance(staff_id);

-- RLS（Row Level Security）を有効化
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;

-- 全員読み書き可能ポリシー（anon keyで動作）
CREATE POLICY "allow_all_staff" ON staff FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_attendance" ON attendance FOR ALL USING (true) WITH CHECK (true);

-- リアルタイム有効化
ALTER PUBLICATION supabase_realtime ADD TABLE attendance;
ALTER PUBLICATION supabase_realtime ADD TABLE staff;
