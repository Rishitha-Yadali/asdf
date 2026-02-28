/*
  # Create Referral Listings Table

  1. New Table
    - `referral_listings` - Company referral opportunities
      - `id` (uuid, primary key)
      - `company_name` (text)
      - `company_logo_url` (text, nullable)
      - `role_title` (text)
      - `experience_range` (text)
      - `package_range` (text)
      - `tech_stack` (text[])
      - `job_description` (text)
      - `location` (text, nullable)
      - `referrer_name` (text, nullable)
      - `referrer_designation` (text, nullable)
      - `is_active` (boolean)

  2. Security
    - RLS enabled
    - Authenticated users can view active listings
    - Admins can manage all listings
*/

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

CREATE INDEX IF NOT EXISTS idx_referral_listings_active ON referral_listings(is_active);
CREATE INDEX IF NOT EXISTS idx_referral_listings_company ON referral_listings(company_name);
