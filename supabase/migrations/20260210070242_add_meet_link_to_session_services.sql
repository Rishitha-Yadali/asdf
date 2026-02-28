/*
  # Add Meet Link to Session Services

  1. Modified Tables
    - `session_services`
      - Added `meet_link` (text, nullable) - Google Meet or other video call link set by admin

  2. Notes
    - Admin sets one meet link per service
    - All users who book this service receive the same link
    - Link is shown on booking confirmation and sent via email
*/

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'session_services' AND column_name = 'meet_link'
  ) THEN
    ALTER TABLE session_services ADD COLUMN meet_link text DEFAULT '';
  END IF;
END $$;
