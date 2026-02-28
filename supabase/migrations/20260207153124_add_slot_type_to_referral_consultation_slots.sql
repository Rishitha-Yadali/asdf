/*
  # Add slot_type to referral consultation slots

  1. Modified Tables
    - `referral_consultation_slots`
      - Added `slot_type` column (text) to distinguish between query, profile, and consultation slots
      - Default value is 'consultation' to preserve existing data
  
  2. Changes
    - Allows booking different types of sessions:
      - 'query' = Referral Query (15-min slots)
      - 'profile' = Profile Monetization (60-min slots)
      - 'consultation' = Consultation Slot (15-min slots)
    - All existing rows default to 'consultation'
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'referral_consultation_slots' AND column_name = 'slot_type'
  ) THEN
    ALTER TABLE referral_consultation_slots ADD COLUMN slot_type text NOT NULL DEFAULT 'consultation';
  END IF;
END $$;
