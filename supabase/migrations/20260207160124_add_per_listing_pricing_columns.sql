/*
  # Add per-listing pricing columns to referral_listings

  1. Modified Tables
    - `referral_listings`
      - `query_price` (integer, nullable) - Per-listing referral query price in paise, overrides global pricing
      - `profile_price` (integer, nullable) - Per-listing profile monetization price in paise, overrides global pricing
      - `slot_price` (integer, nullable) - Per-listing consultation slot price in paise, overrides global pricing

  2. Notes
    - All price columns are nullable; when null, the global pricing from referral_pricing table is used
    - Prices are stored in paise (1 INR = 100 paise) for consistency with referral_pricing table
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'referral_listings' AND column_name = 'query_price'
  ) THEN
    ALTER TABLE referral_listings ADD COLUMN query_price integer;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'referral_listings' AND column_name = 'profile_price'
  ) THEN
    ALTER TABLE referral_listings ADD COLUMN profile_price integer;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'referral_listings' AND column_name = 'slot_price'
  ) THEN
    ALTER TABLE referral_listings ADD COLUMN slot_price integer;
  END IF;
END $$;