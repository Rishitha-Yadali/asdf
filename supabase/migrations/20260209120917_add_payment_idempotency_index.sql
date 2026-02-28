/*
  # Add payment idempotency constraint

  1. Changes
    - Add unique index on `payment_transactions` for `payment_id` where payment_id 
      is a real Razorpay payment ID (starts with 'pay_'), preventing duplicate verification

  2. Security
    - Prevents replay attacks where the same Razorpay payment is verified multiple times
*/

CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_payment_id
  ON payment_transactions (payment_id)
  WHERE payment_id IS NOT NULL 
    AND payment_id LIKE 'pay_%';
