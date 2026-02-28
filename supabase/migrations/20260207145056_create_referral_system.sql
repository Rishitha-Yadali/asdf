/*
  # Create Referral System

  1. New Tables
    - `referral_listings` - Company referral opportunities (Amazon, Google, etc.)
      - `id` (uuid, primary key)
      - `company_name` (text) - Company name
      - `company_logo_url` (text, nullable) - Company logo URL
      - `role_title` (text) - Job role title
      - `experience_range` (text) - e.g. "2-5 years"
      - `package_range` (text) - e.g. "15-25 LPA"
      - `tech_stack` (text[]) - Required technologies
      - `job_description` (text) - Full JD
      - `location` (text, nullable) - Job location
      - `referrer_name` (text, nullable) - Person offering referral
      - `referrer_designation` (text, nullable)
      - `is_active` (boolean) - Whether listing is live
      - `created_at`, `updated_at` timestamps

    - `referral_pricing` - Admin-configurable pricing for referral services
      - `id` (text, primary key, default '1')
      - `query_price` (integer) - Price in paise for basic referral query (default 9900 = Rs.99)
      - `profile_price` (integer) - Price in paise for profile monetization (default 99900 = Rs.999)
      - `slot_price` (integer) - Price in paise for consultation slot (default 9900 = Rs.99)
      - `slot_duration_minutes` (integer) - Duration per slot (default 15)
      - `slot_start_time` (text) - Day start time (default '10:00')
      - `slots_per_session` (integer) - Number of slots per session (default 4)
      - `updated_at` timestamp

    - `referral_purchases` - Tracks user purchases of referral access
      - `id` (uuid, primary key)
      - `user_id` (uuid, FK to user_profiles)
      - `referral_listing_id` (uuid, FK to referral_listings)
      - `purchase_type` (text) - 'query' or 'profile'
      - `amount_paid` (integer) - Amount in paise
      - `payment_id` (text, nullable) - Razorpay payment ID
      - `status` (text) - 'pending', 'success', 'failed'
      - `created_at` timestamp

    - `referral_consultation_slots` - Available consultation time slots
      - `id` (uuid, primary key)
      - `referral_listing_id` (uuid, FK to referral_listings)
      - `slot_date` (date) - Date of slot
      - `time_slot` (text) - e.g. '10:00-10:15'
      - `status` (text) - 'available', 'booked', 'blocked'
      - `booked_by` (uuid, nullable, FK to user_profiles)
      - `booking_payment_id` (text, nullable)
      - `created_at`, `updated_at` timestamps

  2. Security
    - RLS enabled on all tables
    - Authenticated users can read active referral listings
    - Users can only view their own purchases
    - Admin can manage all data
    - Consultation slots readable by authenticated users, bookable by owner

  3. Default Data
    - Insert default pricing row
*/

-- Referral Listings
CREATE TABLE IF NOT EXISTS referral_listings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  company_name text NOT NULL,
  company_logo_url text,
  role_title text NOT NULL,
  experience_range text NOT NULL DEFAULT '',
  package_range text NOT NULL DEFAULT '',
  tech_stack text[] NOT NULL DEFAULT '{}',
  job_description text NOT NULL DEFAULT '',
  location text,
  referrer_name text,
  referrer_designation text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE referral_listings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Authenticated users can view active referral listings"
  ON referral_listings FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "Admins can insert referral listings"
  ON referral_listings FOR INSERT
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

CREATE POLICY "Admins can update referral listings"
  ON referral_listings FOR UPDATE
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

CREATE POLICY "Admins can delete referral listings"
  ON referral_listings FOR DELETE
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

-- Admin select all (including inactive)
CREATE POLICY "Admins can view all referral listings"
  ON referral_listings FOR SELECT
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

-- Referral Pricing
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
  USING (true);

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

-- Referral Purchases
CREATE TABLE IF NOT EXISTS referral_purchases (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES user_profiles(id),
  referral_listing_id uuid NOT NULL REFERENCES referral_listings(id),
  purchase_type text NOT NULL CHECK (purchase_type IN ('query', 'profile')),
  amount_paid integer NOT NULL DEFAULT 0,
  payment_id text,
  order_id text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'success', 'failed')),
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE referral_purchases ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own referral purchases"
  ON referral_purchases FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own referral purchases"
  ON referral_purchases FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own referral purchases"
  ON referral_purchases FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Admins can view all referral purchases"
  ON referral_purchases FOR SELECT
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

-- Referral Consultation Slots
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

CREATE POLICY "Users can insert consultation slot bookings"
  ON referral_consultation_slots FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = booked_by);

CREATE POLICY "Users can update own consultation slot bookings"
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

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_referral_listings_active ON referral_listings(is_active);
CREATE INDEX IF NOT EXISTS idx_referral_listings_company ON referral_listings(company_name);
CREATE INDEX IF NOT EXISTS idx_referral_purchases_user ON referral_purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_referral_purchases_listing ON referral_purchases(referral_listing_id);
CREATE INDEX IF NOT EXISTS idx_referral_consultation_slots_listing ON referral_consultation_slots(referral_listing_id);
CREATE INDEX IF NOT EXISTS idx_referral_consultation_slots_date ON referral_consultation_slots(slot_date);
