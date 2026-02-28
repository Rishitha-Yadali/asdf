/*
  # Create Referral Purchases Table

  1. New Table
    - `referral_purchases` - Tracks user purchases of referral access
      - `id` (uuid, primary key)
      - `user_id` (uuid, FK to user_profiles)
      - `referral_listing_id` (uuid, FK to referral_listings)
      - `purchase_type` (text) - 'query' or 'profile'
      - `amount_paid` (integer, paise)
      - `payment_id` (text, nullable)
      - `order_id` (text, nullable)
      - `status` (text) - 'pending', 'success', 'failed'

  2. Security
    - RLS enabled
    - Users can view/insert/update their own purchases
    - Admins can view all purchases
*/

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

CREATE INDEX IF NOT EXISTS idx_referral_purchases_user ON referral_purchases(user_id);
CREATE INDEX IF NOT EXISTS idx_referral_purchases_listing ON referral_purchases(referral_listing_id);
