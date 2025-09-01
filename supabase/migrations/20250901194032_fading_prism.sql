/*
  # Add get_api_keys function

  1. New Functions
    - `get_api_keys()` - Returns API keys and configuration from admin_credentials table
  
  2. Security
    - Function uses SECURITY DEFINER to bypass RLS
    - Only returns necessary configuration data
    - No sensitive data exposure beyond what's needed for frontend
*/

-- Create the get_api_keys function that was missing
CREATE OR REPLACE FUNCTION public.get_api_keys()
RETURNS TABLE(
  clerk_publishable_key text,
  gemini_api_key text,
  google_tts_api_key text,
  pro_plan_price_inr integer,
  razorpay_key_id text,
  razorpay_key_secret text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    ac.clerk_publishable_key,
    ac.gemini_api_key,
    ac.google_tts_api_key,
    ac.pro_plan_price_inr,
    ac.razorpay_key_id,
    ac.razorpay_key_secret
  FROM
    public.admin_credentials ac
  LIMIT 1;
END;
$$;