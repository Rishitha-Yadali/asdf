/*
  # Fix referral listing cascade delete

  1. Changes
    - Drop and recreate foreign key on `referral_purchases.referral_listing_id` with ON DELETE CASCADE
    - Drop and recreate foreign key on `referral_consultation_slots.referral_listing_id` with ON DELETE CASCADE

  2. Notes
    - This allows deleting a referral listing to automatically remove all related purchases and slot bookings
    - Prevents the 409 foreign key constraint violation when admin deletes a listing
*/

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'referral_purchases_referral_listing_id_fkey'
    AND table_name = 'referral_purchases'
  ) THEN
    ALTER TABLE referral_purchases DROP CONSTRAINT referral_purchases_referral_listing_id_fkey;
  END IF;

  ALTER TABLE referral_purchases
    ADD CONSTRAINT referral_purchases_referral_listing_id_fkey
    FOREIGN KEY (referral_listing_id) REFERENCES referral_listings(id) ON DELETE CASCADE;

  IF EXISTS (
    SELECT 1 FROM information_schema.table_constraints
    WHERE constraint_name = 'referral_consultation_slots_referral_listing_id_fkey'
    AND table_name = 'referral_consultation_slots'
  ) THEN
    ALTER TABLE referral_consultation_slots DROP CONSTRAINT referral_consultation_slots_referral_listing_id_fkey;
  END IF;

  ALTER TABLE referral_consultation_slots
    ADD CONSTRAINT referral_consultation_slots_referral_listing_id_fkey
    FOREIGN KEY (referral_listing_id) REFERENCES referral_listings(id) ON DELETE CASCADE;
END $$;