/*
  # Filter AI Recommendations to Last 7 Days

  1. Changes
    - Updates `get_user_recommended_jobs` function to only return jobs
      where the job's `created_at` is within the last 7 days
    - This ensures AI match results only show recently uploaded jobs

  2. Important Notes
    - Jobs older than 7 days will no longer appear in AI recommendations
    - Existing recommendations for older jobs will be hidden automatically
*/

CREATE OR REPLACE FUNCTION get_user_recommended_jobs(p_user_id uuid, p_min_score integer DEFAULT 40)
RETURNS TABLE (
  job_id uuid,
  match_score integer,
  match_reason text,
  skills_matched text[],
  location_match boolean,
  year_match boolean,
  job_data jsonb
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.job_id,
    r.match_score,
    r.match_reason,
    r.skills_matched,
    r.location_match,
    r.year_match,
    to_jsonb(j.*) as job_data
  FROM ai_job_recommendations r
  JOIN job_listings j ON r.job_id = j.id
  WHERE r.user_id = p_user_id
    AND r.match_score >= p_min_score
    AND r.is_dismissed = false
    AND j.is_active = true
    AND j.created_at >= now() - interval '7 days'
  ORDER BY r.match_score DESC, r.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;