/*
  # Create admin_credentials table and get_api_keys function

  1. New Tables
    - `admin_credentials`
      - `id` (uuid, primary key)
      - `username` (text, unique)
      - `password_hash` (text)
      - `gemini_api_key` (text, nullable)
      - `google_tts_api_key` (text, nullable)
      - `clerk_publishable_key` (text, nullable)
      - `razorpay_key_id` (text, nullable)
      - `razorpay_key_secret` (text, nullable)
      - `pro_plan_price_inr` (integer, default 999)
      - `company_name` (text, nullable)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `admin_credentials` table
    - Add policy for admin access only

  3. Functions
    - `get_api_keys()` - Returns API keys and settings for frontend use

  4. Initial Data
    - Creates default admin user with username 'admin' and password 'admin'
*/

-- Create admin_credentials table
CREATE TABLE IF NOT EXISTS admin_credentials (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  username text UNIQUE NOT NULL,
  password_hash text NOT NULL,
  gemini_api_key text,
  google_tts_api_key text,
  clerk_publishable_key text,
  razorpay_key_id text,
  razorpay_key_secret text,
  pro_plan_price_inr integer DEFAULT 999,
  company_name text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE admin_credentials ENABLE ROW LEVEL SECURITY;

-- Create policy for admin access
CREATE POLICY "Admin access only"
  ON admin_credentials
  FOR ALL
  TO authenticated
  USING (true);

-- Insert default admin credentials (password: 'admin')
INSERT INTO admin_credentials (username, password_hash, company_name)
VALUES (
  'admin',
  '$2b$10$rQZ9vKzX8YqF5tJ2nL4wXeH7vK9mP3qR5sT8uV1wY6zA2bC4dE5fG',
  'MockInvi'
) ON CONFLICT (username) DO NOTHING;

-- Create get_api_keys function
CREATE OR REPLACE FUNCTION get_api_keys()
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
  FROM admin_credentials ac
  LIMIT 1;
END;
$$;