-- ============================================
-- QR出勤管理システム v2 セットアップSQL
-- Supabase SQL Editor で全部貼り付けて実行
-- ============================================

-- 既存テーブルを全削除
DROP TABLE IF EXISTS attendance CASCADE;
DROP TABLE IF EXISTS staff CASCADE;
DROP TABLE IF EXISTS locations CASCADE;
DROP TABLE IF EXISTS work_types CASCADE;
DROP TABLE IF EXISTS departments CASCADE;

-- ① 事業部マスタ
CREATE TABLE departments (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  color TEXT DEFAULT '#a78bfa',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ② 勤務区分
CREATE TABLE work_types (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  dept_id TEXT REFERENCES departments(id) ON DELETE SET NULL,
  is_flex BOOLEAN DEFAULT FALSE,
  start_time TEXT DEFAULT '09:00',
  end_time TEXT DEFAULT '17:00',
  core_start TEXT DEFAULT NULL,
  core_end TEXT DEFAULT NULL,
  break_minutes INTEGER DEFAULT 0,
  late_tolerance INTEGER DEFAULT 15,
  overtime_buffer INTEGER DEFAULT 30,
  base_hours NUMERIC DEFAULT 8,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ③ 現場
CREATE TABLE locations (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  dept_id TEXT REFERENCES departments(id) ON DELETE SET NULL,
  address TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ④ スタッフ
CREATE TABLE staff (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  dept_id TEXT REFERENCES departments(id) ON DELETE SET NULL,
  work_type_ids TEXT[] DEFAULT '{}',
  allow_online_stamp BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ⑤ 打刻
CREATE TABLE attendance (
  id BIGSERIAL PRIMARY KEY,
  staff_id TEXT NOT NULL REFERENCES staff(id) ON DELETE CASCADE,
  staff_name TEXT NOT NULL,
  dept_id TEXT REFERENCES departments(id) ON DELETE SET NULL,
  dept_name TEXT DEFAULT '',
  location_id TEXT REFERENCES locations(id) ON DELETE SET NULL,
  location_name TEXT DEFAULT '',
  work_type_id TEXT REFERENCES work_types(id) ON DELETE SET NULL,
  work_type_name TEXT DEFAULT '',
  type TEXT NOT NULL CHECK (type IN ('in','out')),
  is_online BOOLEAN DEFAULT FALSE,
  time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- インデックス
CREATE INDEX idx_att_time ON attendance(time DESC);
CREATE INDEX idx_att_staff ON attendance(staff_id);
CREATE INDEX idx_att_location ON attendance(location_id);
CREATE INDEX idx_att_dept ON attendance(dept_id);

-- RLS
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE work_types ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;

CREATE POLICY "allow_all" ON departments FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON work_types FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON locations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON staff FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON attendance FOR ALL USING (true) WITH CHECK (true);

-- リアルタイム
ALTER PUBLICATION supabase_realtime ADD TABLE attendance;
ALTER PUBLICATION supabase_realtime ADD TABLE staff;
ALTER PUBLICATION supabase_realtime ADD TABLE locations;
ALTER PUBLICATION supabase_realtime ADD TABLE departments;
ALTER PUBLICATION supabase_realtime ADD TABLE work_types;
