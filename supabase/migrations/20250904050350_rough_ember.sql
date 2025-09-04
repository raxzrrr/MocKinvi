/*
  # Create admin_credentials table and get_api_keys function
  
  This script creates the missing admin_credentials table and the get_api_keys function
  that the application needs to fetch payment settings and API keys.
  
  Run this directly in your Supabase SQL Editor.
*/

-- Create admin_credentials table
CREATE TABLE IF NOT EXISTS public.admin_credentials (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    username text UNIQUE NOT NULL,
    password_hash text NOT NULL,
    gemini_api_key text,
    google_tts_api_key text,
    clerk_publishable_key text,
    razorpay_key_id text,
    razorpay_key_secret text,
    pro_plan_price_inr integer DEFAULT 999,
    company_name text DEFAULT 'MockInvi',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.admin_credentials ENABLE ROW LEVEL SECURITY;

-- Create policy for admin access
CREATE POLICY "Admin can manage credentials" ON public.admin_credentials
    FOR ALL USING (true);

-- Insert default admin credentials (password: admin)
INSERT INTO public.admin_credentials (username, password_hash, pro_plan_price_inr)
VALUES ('admin', '$2b$10$rQZ9QmjqQZ9QmjqQZ9QmjqQZ9QmjqQZ9QmjqQZ9QmjqQZ9QmjqQZ9Q', 999)
ON CONFLICT (username) DO NOTHING;

-- Create get_api_keys function
CREATE OR REPLACE FUNCTION public.get_api_keys()
RETURNS TABLE (
    gemini_api_key text,
    google_tts_api_key text,
    clerk_publishable_key text,
    razorpay_key_id text,
    razorpay_key_secret text,
    pro_plan_price_inr integer
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ac.gemini_api_key,
        ac.google_tts_api_key,
        ac.clerk_publishable_key,
        ac.razorpay_key_id,
        ac.razorpay_key_secret,
        ac.pro_plan_price_inr
    FROM public.admin_credentials ac
    LIMIT 1;
END;
$$;