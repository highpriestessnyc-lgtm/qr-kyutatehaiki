-- Supabase SQL Editor で実行してください
-- 既存テーブルを削除して作り直し
DROP TABLE IF EXISTS attendance CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS locations CASCADE;

-- 現場テーブル
CREATE TABLE locations (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  address TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- スタッフテーブル
CREATE TABLE staff (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  dept TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 打刻テーブル
CREATE TABLE attendance (
  id BIGSERIAL PRIMARY KEY,
  staff_id TEXT NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
  staff_name TEXT NOT NULL,
  dept TEXT DEFAULT '',
  location_id TEXT REFERENCES locations(id) ON DELETE SET NULL,
  location_name TEXT DEFAULT '',
  type TEXT NOT NULL CHECK (type IN ('in','out')),
  time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- インデックス
CREATE INDEX idx_attendance_time ON attendance(time DESC);
CREATE INDEX idx_attendance_staff_id ON attendance(staff_id);
CREATE INDEX idx_attendance_location_id ON attendance(location_id);

-- RLS有効化
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;

-- ポリシー
CREATE POLICY "allow_all_staff" ON staff FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_locations" ON locations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all_attendance" ON attendance FOR ALL USING (true) WITH CHECK (true);

-- リアルタイム有効化
ALTER PUBLICATION supabase_realtime ADD TABLE attendance;
ALTER PUBLICATION supabase_realtime ADD TABLE staff;
ALTER PUBLICATION supabase_realtime ADD TABLE locations;
