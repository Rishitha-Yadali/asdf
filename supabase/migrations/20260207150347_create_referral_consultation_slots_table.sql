/*
  # Create Referral Consultation Slots Table

  1. New Table
    - `referral_consultation_slots` - Consultation time slot bookings
      - `id` (uuid, primary key)
      - `referral_listing_id` (uuid, FK to referral_listings)
      - `slot_date` (date)
      - `time_slot` (text) - e.g. '10:00-10:15'
      - `status` (text) - 'available', 'booked', 'blocked'
      - `booked_by` (uuid, nullable, FK to user_profiles)
      - `booking_payment_id` (text, nullable)
      - `user_name`, `user_email`, `user_phone` (text, nullable)

  2. Security
    - RLS enabled
    - Authenticated users can view all slots
    - Users can insert/update slots they book
    - Admins can manage all slots
*/

CREATE TABLE IF NOT EXISTS referral_consultation_slots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  referral_listing_id uuid NOT NULL REFERENCES referral_listings(id),
  slot_date date NOT NULL,
  time_slot text NOT NULL,
  status text NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'booked', 'blocked')),
  booked_by uuid REFERENCES user_profiles(id),
  booking_payment_id text,
  user_name text,
  user_email text,
  user_phone text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE referral_consultation_slots ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view consultation slots"
  ON referral_consultation_slots FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Users can book consultation slots"
  ON referral_consultation_slots FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = booked_by);

CREATE POLICY "Users can update own slot bookings"
  ON referral_consultation_slots FOR UPDATE
  TO authenticated
  USING (auth.uid() = booked_by)
  WITH CHECK (auth.uid() = booked_by);

CREATE POLICY "Admins can insert consultation slots"
  ON referral_consultation_slots FOR INSERT
  TO authenticated
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

CREATE POLICY "Admins can update consultation slots"
  ON referral_consultation_slots FOR UPDATE
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

CREATE POLICY "Admins can delete consultation slots"
  ON referral_consultation_slots FOR DELETE
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
  );

CREATE INDEX IF NOT EXISTS idx_referral_consultation_slots_listing ON referral_consultation_slots(referral_listing_id);
CREATE INDEX IF NOT EXISTS idx_referral_consultation_slots_date ON referral_consultation_slots(slot_date);
