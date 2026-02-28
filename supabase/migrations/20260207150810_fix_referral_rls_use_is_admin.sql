/*
  # Fix Referral RLS Policies to use is_admin() function

  Replaces all admin checks on referral tables to use the existing
  `is_admin(uuid)` function that checks user_profiles.role instead of
  auth.users.raw_app_meta_data which doesn't contain the role field.
*/

-- Drop existing policies on referral_listings
DROP POLICY IF EXISTS "Admins can view all referral listings" ON referral_listings;
DROP POLICY IF EXISTS "Admins can insert referral listings" ON referral_listings;
DROP POLICY IF EXISTS "Admins can update referral listings" ON referral_listings;
DROP POLICY IF EXISTS "Admins can delete referral listings" ON referral_listings;

-- Recreate with is_admin()
CREATE POLICY "Admins can view all referral listings"
  ON referral_listings FOR SELECT
  TO authenticated
  USING (is_admin(auth.uid()));

CREATE POLICY "Admins can insert referral listings"
  ON referral_listings FOR INSERT
  TO authenticated
  WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can update referral listings"
  ON referral_listings FOR UPDATE
  TO authenticated
  USING (is_admin(auth.uid()))
  WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can delete referral listings"
  ON referral_listings FOR DELETE
  TO authenticated
  USING (is_admin(auth.uid()));

-- Drop existing policies on referral_pricing
DROP POLICY IF EXISTS "Admins can update referral pricing" ON referral_pricing;

CREATE POLICY "Admins can update referral pricing"
  ON referral_pricing FOR UPDATE
  TO authenticated
  USING (is_admin(auth.uid()))
  WITH CHECK (is_admin(auth.uid()));

-- Drop existing policies on referral_purchases
DROP POLICY IF EXISTS "Admins can view all referral purchases" ON referral_purchases;

CREATE POLICY "Admins can view all referral purchases"
  ON referral_purchases FOR SELECT
  TO authenticated
  USING (is_admin(auth.uid()));

-- Drop existing admin policies on referral_consultation_slots
DROP POLICY IF EXISTS "Admins can insert consultation slots" ON referral_consultation_slots;
DROP POLICY IF EXISTS "Admins can update consultation slots" ON referral_consultation_slots;
DROP POLICY IF EXISTS "Admins can delete consultation slots" ON referral_consultation_slots;

CREATE POLICY "Admins can insert consultation slots"
  ON referral_consultation_slots FOR INSERT
  TO authenticated
  WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can update consultation slots"
  ON referral_consultation_slots FOR UPDATE
  TO authenticated
  USING (is_admin(auth.uid()))
  WITH CHECK (is_admin(auth.uid()));

CREATE POLICY "Admins can delete consultation slots"
  ON referral_consultation_slots FOR DELETE
  TO authenticated
  USING (is_admin(auth.uid()));
