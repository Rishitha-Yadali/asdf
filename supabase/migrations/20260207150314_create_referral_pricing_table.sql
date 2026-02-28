/*
  # Create Referral Pricing Table

  1. New Table
    - `referral_pricing` - Admin-configurable pricing
      - `id` (text, primary key, singleton row)
      - `query_price` (integer, paise) - default 9900 = Rs.99
      - `profile_price` (integer, paise) - default 99900 = Rs.999
      - `slot_price` (integer, paise) - default 9900 = Rs.99
      - `slot_duration_minutes` (integer) - default 15
      - `slot_start_time` (text) - default '10:00'
      - `slots_per_session` (integer) - default 4

  2. Security
    - RLS enabled
    - Authenticated users can read pricing
    - Admins can update pricing

  3. Default Data
    - Inserts default pricing row
*/

CREATE TABLE IF NOT EXISTS referral_pricing (
  id text PRIMARY KEY DEFAULT '1',
  query_price integer NOT NULL DEFAULT 9900,
  profile_price integer NOT NULL DEFAULT 99900,
  slot_price integer NOT NULL DEFAULT 9900,
  slot_duration_minutes integer NOT NULL DEFAULT 15,
  slot_start_time text NOT NULL DEFAULT '10:00',
  slots_per_session integer NOT NULL DEFAULT 4,
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE referral_pricing ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can read referral pricing"
  ON referral_pricing FOR SELECT
  TO authenticated
  USING (id = '1');

CREATE POLICY "Admins can update referral pricing"
  ON referral_pricing FOR UPDATE
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE auth.users.id = auth.uid()
      AND (
        auth.users.raw_app_meta_data->>'role' = 'admin'
        OR auth.users.email = 'primoboostai@gmail.com'
      )
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM auth.users
      WHERE auth.users.id = auth.uid()
      AND (
        auth.users.raw_app_meta_data->>'role' = 'admin'
        OR auth.users.email = 'primoboostai@gmail.com'
      )
    )
  );

INSERT INTO referral_pricing (id, query_price, profile_price, slot_price, slot_duration_minutes, slot_start_time, slots_per_session)
VALUES ('1', 9900, 99900, 9900, 15, '10:00', 4)
ON CONFLICT (id) DO NOTHING;
