/*
  # Fresh Database Schema for MockInvi

  This migration creates a complete database schema from scratch for the MockInvi platform.

  ## Tables Created:
  1. **profiles** - User profiles with authentication support
  2. **admin_credentials** - Admin authentication and API key management
  3. **courses** - Learning courses
  4. **course_videos** - Video content for courses
  5. **course_questions** - Assessment questions for courses
  6. **user_learning** - User progress tracking
  7. **user_subscriptions** - Subscription management
  8. **payments** - Payment records
  9. **certificates** - Certificate templates
  10. **certificate_templates** - HTML certificate templates
  11. **user_certificates** - Issued certificates
  12. **course_certificate_management** - Course completion tracking
  13. **interview_sessions** - Interview practice sessions
  14. **interview_reports** - Interview performance reports
  15. **user_reports** - PDF report storage
  16. **user_interview_usage** - Interview usage tracking
  17. **interview_resources** - Admin-uploaded PDF resources

  ## Security:
  - Row Level Security (RLS) enabled on all tables
  - Proper policies for user data access
  - Admin-only access for management functions
  - Secure API key storage

  ## Features:
  - Clerk authentication integration
  - Razorpay payment processing
  - Certificate generation system
  - Learning progress tracking
  - Interview practice and evaluation
*/

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create user roles enum
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('student', 'admin');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- =====================================================
-- PROFILES TABLE - Core user management
-- =====================================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID NOT NULL PRIMARY KEY,
  full_name TEXT NOT NULL,
  email TEXT,
  avatar_url TEXT,
  role user_role NOT NULL DEFAULT 'student',
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'pending')),
  last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  password_hash TEXT,
  email_verified BOOLEAN DEFAULT false,
  auth_provider TEXT DEFAULT 'clerk',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- =====================================================
-- ADMIN CREDENTIALS - API keys and admin auth
-- =====================================================
CREATE TABLE IF NOT EXISTS public.admin_credentials (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  username TEXT NOT NULL UNIQUE,
  password_hash TEXT NOT NULL,
  gemini_api_key TEXT,
  google_tts_api_key TEXT,
  clerk_publishable_key TEXT,
  razorpay_key_id TEXT,
  razorpay_key_secret TEXT,
  pro_plan_price_inr INTEGER DEFAULT 999,
  company_name TEXT DEFAULT 'cyrobox solutions',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- =====================================================
-- COURSES AND CONTENT
-- =====================================================
CREATE TABLE IF NOT EXISTS public.courses (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  description TEXT,
  thumbnail_url TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.course_videos (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  video_url TEXT NOT NULL,
  thumbnail_url TEXT,
  duration TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  content_type TEXT DEFAULT 'url',
  file_path TEXT,
  file_size BIGINT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.course_questions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  difficulty_level TEXT NOT NULL CHECK (difficulty_level IN ('easy', 'intermediate', 'hard')),
  option_1 TEXT NOT NULL,
  option_2 TEXT NOT NULL,
  option_3 TEXT NOT NULL,
  option_4 TEXT NOT NULL,
  correct_answer INTEGER NOT NULL CHECK (correct_answer BETWEEN 1 AND 4),
  explanation TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- =====================================================
-- USER LEARNING AND PROGRESS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.user_learning (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  course_id UUID NOT NULL REFERENCES public.courses(id) ON DELETE CASCADE,
  progress JSONB DEFAULT '{}',
  completed_modules_count INTEGER DEFAULT 0,
  total_modules_count INTEGER DEFAULT 0,
  last_assessment_score INTEGER DEFAULT 0,
  is_completed BOOLEAN DEFAULT false,
  assessment_attempted BOOLEAN DEFAULT false,
  assessment_passed BOOLEAN DEFAULT false,
  assessment_score INTEGER DEFAULT NULL,
  assessment_completed_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  completed_and_passed BOOLEAN GENERATED ALWAYS AS (
    COALESCE(is_completed, false) AND COALESCE(assessment_passed, false)
  ) STORED,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, course_id)
);

-- =====================================================
-- PAYMENTS AND SUBSCRIPTIONS
-- =====================================================
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  razorpay_order_id TEXT NOT NULL,
  razorpay_payment_id TEXT NOT NULL,
  razorpay_signature TEXT NOT NULL,
  amount INTEGER NOT NULL,
  currency TEXT NOT NULL DEFAULT 'INR',
  plan_type TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'completed',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.user_subscriptions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  plan_type TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  current_period_start TIMESTAMP WITH TIME ZONE NOT NULL,
  current_period_end TIMESTAMP WITH TIME ZONE NOT NULL,
  was_granted BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- =====================================================
-- CERTIFICATES SYSTEM
-- =====================================================
CREATE TABLE IF NOT EXISTS public.certificates (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  certificate_type TEXT DEFAULT 'completion',
  template_data JSONB DEFAULT '{}',
  requirements JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE,
  auto_issue BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.certificate_templates (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  html_template TEXT NOT NULL,
  placeholders JSONB DEFAULT '[]'::jsonb,
  is_active BOOLEAN DEFAULT true,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.user_certificates (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  certificate_id UUID NOT NULL REFERENCES public.certificates(id) ON DELETE CASCADE,
  course_id UUID REFERENCES public.courses(id) ON DELETE SET NULL,
  template_id UUID REFERENCES public.certificate_templates(id),
  clerk_user_id TEXT,
  issued_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  completion_data JSONB DEFAULT '{}',
  verification_code TEXT NOT NULL,
  certificate_url TEXT,
  populated_html TEXT,
  certificate_hash TEXT UNIQUE,
  score INTEGER DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, certificate_id)
);

CREATE TABLE IF NOT EXISTS public.course_certificate_management (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clerk_user_id TEXT NOT NULL,
  course_id TEXT NOT NULL,
  course_name TEXT NOT NULL,
  course_complete BOOLEAN DEFAULT FALSE,
  assessment_pass BOOLEAN DEFAULT FALSE,
  assessment_score INTEGER DEFAULT 0,
  completion_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(clerk_user_id, course_id)
);

-- =====================================================
-- INTERVIEW SYSTEM
-- =====================================================
CREATE TABLE IF NOT EXISTS public.interview_sessions (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID DEFAULT '00000000-0000-0000-0000-000000000001',
  interview_type TEXT NOT NULL CHECK (interview_type IN ('basic_hr_technical', 'role_based', 'resume_based')),
  question_count INTEGER NOT NULL CHECK (question_count >= 5 AND question_count <= 10),
  job_role TEXT,
  questions JSONB NOT NULL DEFAULT '[]'::jsonb,
  ideal_answers JSONB NOT NULL DEFAULT '[]'::jsonb,
  user_answers JSONB DEFAULT '[]'::jsonb,
  evaluations JSONB DEFAULT '[]'::jsonb,
  overall_score INTEGER DEFAULT 0,
  session_status TEXT NOT NULL DEFAULT 'created' CHECK (session_status IN ('created', 'in_progress', 'completed')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

CREATE TABLE IF NOT EXISTS public.interview_reports (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  interview_type TEXT DEFAULT 'basic_hr_technical',
  job_role TEXT,
  questions JSONB DEFAULT '[]',
  answers JSONB DEFAULT '[]',
  evaluations JSONB DEFAULT '[]',
  overall_score INTEGER DEFAULT 0,
  overall_grade TEXT DEFAULT 'C',
  recommendation TEXT DEFAULT 'Keep practicing',
  report_data JSONB,
  pdf_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.user_reports (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  report_type TEXT NOT NULL DEFAULT 'interview',
  title TEXT NOT NULL,
  pdf_url TEXT,
  pdf_data TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.user_interview_usage (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  free_interview_used BOOLEAN DEFAULT FALSE,
  usage_count INTEGER DEFAULT 0,
  last_interview_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- INTERVIEW RESOURCES
-- =====================================================
CREATE TABLE IF NOT EXISTS public.interview_resources (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_size BIGINT,
  uploaded_by UUID,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  is_active BOOLEAN NOT NULL DEFAULT true
);

-- =====================================================
-- ENABLE ROW LEVEL SECURITY
-- =====================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_credentials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_learning ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certificate_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.course_certificate_management ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.interview_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.interview_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_interview_usage ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.interview_resources ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- HELPER FUNCTIONS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Function to check if current user is admin
CREATE OR REPLACE FUNCTION public.is_current_user_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 
    FROM public.profiles 
    WHERE id = auth.uid() 
    AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Function to get JWT email
CREATE OR REPLACE FUNCTION public.jwt_email()
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT (current_setting('request.jwt.claims', true)::json ->> 'email')::text;
$$;

-- Function to check ownership by email
CREATE OR REPLACE FUNCTION public.is_owner_by_email(target_user_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.profiles p
    WHERE p.id = target_user_id
      AND COALESCE(p.email, '') = COALESCE(public.jwt_email(), '__none__')
  );
$$;

-- =====================================================
-- AUTHENTICATION FUNCTIONS
-- =====================================================

-- Function to authenticate admin
CREATE OR REPLACE FUNCTION public.authenticate_admin(
  admin_username TEXT,
  admin_password TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  stored_hash TEXT;
BEGIN
  SELECT password_hash INTO stored_hash 
  FROM public.admin_credentials 
  WHERE username = admin_username;
  
  IF stored_hash IS NULL THEN
    RETURN FALSE;
  END IF;
  
  RETURN (stored_hash = crypt(admin_password, stored_hash));
END;
$$;

-- Function to update admin credentials
CREATE OR REPLACE FUNCTION public.update_admin_credentials(
  old_username TEXT,
  old_password TEXT,
  new_username TEXT,
  new_password TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NOT public.authenticate_admin(old_username, old_password) THEN
    RETURN FALSE;
  END IF;
  
  UPDATE public.admin_credentials 
  SET 
    username = new_username,
    password_hash = crypt(new_password, gen_salt('bf')),
    updated_at = NOW()
  WHERE username = old_username;
  
  RETURN TRUE;
END;
$$;

-- Function to authenticate user
CREATE OR REPLACE FUNCTION public.authenticate_user(
  user_email TEXT,
  user_password TEXT
)
RETURNS TABLE(
  user_id UUID,
  user_data JSON
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  user_record public.profiles;
  password_valid BOOLEAN;
BEGIN
  SELECT * INTO user_record 
  FROM public.profiles 
  WHERE email = user_email 
  AND auth_provider IN ('manual', 'clerk', 'both');
  
  IF user_record IS NULL THEN
    RAISE EXCEPTION 'User not found';
  END IF;
  
  IF user_record.auth_provider = 'clerk' THEN
    password_valid := true;
  ELSE
    password_valid := (user_record.password_hash = crypt(user_password, user_record.password_hash));
  END IF;
  
  IF NOT password_valid THEN
    RAISE EXCEPTION 'Invalid credentials';
  END IF;
  
  RETURN QUERY SELECT 
    user_record.id,
    json_build_object(
      'id', user_record.id,
      'email', user_record.email,
      'full_name', user_record.full_name,
      'role', user_record.role,
      'auth_provider', user_record.auth_provider
    );
END;
$$;

-- Function to register manual user
CREATE OR REPLACE FUNCTION public.register_manual_user(
  user_email TEXT,
  user_password TEXT,
  user_full_name TEXT,
  user_role TEXT DEFAULT 'student'
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  new_user_id UUID;
  existing_user public.profiles;
BEGIN
  SELECT * INTO existing_user 
  FROM public.profiles 
  WHERE email = user_email;
  
  IF existing_user IS NOT NULL THEN
    IF existing_user.auth_provider = 'clerk' THEN
      UPDATE public.profiles 
      SET 
        password_hash = crypt(user_password, gen_salt('bf')),
        auth_provider = 'both'
      WHERE email = user_email;
      
      RETURN existing_user.id;
    ELSE
      RAISE EXCEPTION 'User already exists';
    END IF;
  END IF;
  
  new_user_id := gen_random_uuid();
  
  INSERT INTO public.profiles (
    id,
    email,
    full_name,
    role,
    password_hash,
    auth_provider,
    email_verified
  ) VALUES (
    new_user_id,
    user_email,
    user_full_name,
    user_role::user_role,
    crypt(user_password, gen_salt('bf')),
    'manual',
    false
  );
  
  RETURN new_user_id;
END;
$$;

-- =====================================================
-- API KEY MANAGEMENT FUNCTIONS
-- =====================================================

-- Function to update API keys
CREATE OR REPLACE FUNCTION public.update_api_keys(
  p_gemini_key TEXT DEFAULT NULL,
  p_tts_key TEXT DEFAULT NULL,
  p_clerk_key TEXT DEFAULT NULL,
  p_razorpay_key_id TEXT DEFAULT NULL,
  p_razorpay_key_secret TEXT DEFAULT NULL,
  p_pro_plan_price_inr INTEGER DEFAULT NULL,
  p_company_name TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.admin_credentials 
  SET 
    gemini_api_key = COALESCE(p_gemini_key, gemini_api_key),
    google_tts_api_key = COALESCE(p_tts_key, google_tts_api_key),
    clerk_publishable_key = COALESCE(p_clerk_key, clerk_publishable_key),
    razorpay_key_id = COALESCE(p_razorpay_key_id, razorpay_key_id),
    razorpay_key_secret = COALESCE(p_razorpay_key_secret, razorpay_key_secret),
    pro_plan_price_inr = COALESCE(p_pro_plan_price_inr, pro_plan_price_inr),
    company_name = COALESCE(p_company_name, company_name),
    updated_at = NOW()
  WHERE id = (SELECT id FROM public.admin_credentials LIMIT 1);
  
  RETURN TRUE;
END;
$$;

-- Function to get API keys
CREATE OR REPLACE FUNCTION public.get_api_keys()
RETURNS TABLE(
  gemini_api_key TEXT,
  google_tts_api_key TEXT,
  clerk_publishable_key TEXT,
  razorpay_key_id TEXT,
  razorpay_key_secret TEXT,
  pro_plan_price_inr INTEGER,
  company_name TEXT
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
    ac.pro_plan_price_inr,
    ac.company_name
  FROM public.admin_credentials ac
  LIMIT 1;
END;
$$;

-- =====================================================
-- CERTIFICATE FUNCTIONS
-- =====================================================

-- Function to generate certificate hash
CREATE OR REPLACE FUNCTION public.generate_certificate_hash(
  user_id UUID,
  template_id UUID,
  completion_data JSONB,
  issued_date TIMESTAMP WITH TIME ZONE
) RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN encode(
    digest(
      user_id::text || template_id::text || completion_data::text || issued_date::text || 'certificate_salt_2024',
      'sha256'
    ),
    'hex'
  );
END;
$$;

-- Function to populate certificate template
CREATE OR REPLACE FUNCTION public.populate_certificate_template(
  template_id UUID,
  user_id UUID,
  course_name TEXT,
  completion_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  score INTEGER DEFAULT NULL
) RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  template_html TEXT;
  user_name TEXT;
  company_name TEXT;
  populated_html TEXT;
BEGIN
  SELECT html_template INTO template_html
  FROM public.certificate_templates
  WHERE id = template_id AND is_active = true;
  
  IF template_html IS NULL THEN
    RAISE EXCEPTION 'Template not found or inactive';
  END IF;
  
  SELECT full_name INTO user_name
  FROM public.profiles
  WHERE id = user_id;
  
  IF user_name IS NULL THEN
    RAISE EXCEPTION 'User not found';
  END IF;
  
  SELECT admin_credentials.company_name INTO company_name
  FROM public.admin_credentials
  LIMIT 1;
  
  IF company_name IS NULL THEN
    company_name := 'cyrobox solutions';
  END IF;
  
  populated_html := template_html;
  populated_html := REPLACE(populated_html, '{{user_name}}', user_name);
  populated_html := REPLACE(populated_html, '{{course_name}}', course_name);
  populated_html := REPLACE(populated_html, '{{completion_date}}', TO_CHAR(completion_date, 'Month DD, YYYY'));
  populated_html := REPLACE(populated_html, '{{company_name}}', company_name);
  
  IF score IS NOT NULL THEN
    populated_html := REPLACE(populated_html, '{{score}}', score::TEXT || '%');
  ELSE
    populated_html := REPLACE(populated_html, '{{score}}', 'N/A');
  END IF;
  
  RETURN populated_html;
END;
$$;

-- Function to update course certificate management
CREATE OR REPLACE FUNCTION public.update_course_certificate_management(
  p_clerk_user_id TEXT,
  p_course_id TEXT,
  p_course_name TEXT,
  p_course_complete BOOLEAN,
  p_assessment_score INTEGER
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  INSERT INTO public.course_certificate_management (
    clerk_user_id,
    course_id,
    course_name,
    course_complete,
    assessment_pass,
    assessment_score,
    completion_date
  ) VALUES (
    p_clerk_user_id,
    p_course_id,
    p_course_name,
    p_course_complete,
    p_assessment_score >= 70,
    p_assessment_score,
    CASE WHEN p_course_complete AND p_assessment_score >= 70 THEN NOW() ELSE NULL END
  )
  ON CONFLICT (clerk_user_id, course_id)
  DO UPDATE SET
    course_complete = EXCLUDED.course_complete,
    assessment_pass = EXCLUDED.assessment_pass,
    assessment_score = EXCLUDED.assessment_score,
    completion_date = EXCLUDED.completion_date,
    updated_at = NOW();
END;
$$;

-- =====================================================
-- ROW LEVEL SECURITY POLICIES
-- =====================================================

-- Profiles policies
CREATE POLICY "Users can view all profiles" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "Users can update their own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id OR public.is_owner_by_email(id));
CREATE POLICY "Users can insert their own profile" ON public.profiles FOR INSERT WITH CHECK (true);

-- Admin credentials policies
CREATE POLICY "Only admins can access credentials" ON public.admin_credentials FOR ALL TO authenticated USING (public.is_current_user_admin()) WITH CHECK (public.is_current_user_admin());
CREATE POLICY "Service role can access credentials" ON public.admin_credentials FOR ALL TO service_role USING (true) WITH CHECK (true);

-- Courses policies
CREATE POLICY "Anyone can view active courses" ON public.courses FOR SELECT USING (is_active = true);
CREATE POLICY "Admins can manage courses" ON public.courses FOR ALL USING (public.is_current_user_admin()) WITH CHECK (public.is_current_user_admin());

-- Course videos policies
CREATE POLICY "Anyone can view active course videos" ON public.course_videos FOR SELECT USING (is_active = true);
CREATE POLICY "Admins can manage course videos" ON public.course_videos FOR ALL USING (public.is_current_user_admin()) WITH CHECK (public.is_current_user_admin());

-- Course questions policies
CREATE POLICY "Anyone can view active course questions" ON public.course_questions FOR SELECT USING (is_active = true);
CREATE POLICY "Admins can manage course questions" ON public.course_questions FOR ALL USING (public.is_current_user_admin()) WITH CHECK (public.is_current_user_admin());

-- User learning policies
CREATE POLICY "Users can view their own learning data" ON public.user_learning FOR SELECT USING (auth.uid() = user_id OR public.is_owner_by_email(user_id));
CREATE POLICY "Users can insert their own learning data" ON public.user_learning FOR INSERT WITH CHECK (auth.uid() = user_id OR public.is_owner_by_email(user_id));
CREATE POLICY "Users can update their own learning data" ON public.user_learning FOR UPDATE USING (auth.uid() = user_id OR public.is_owner_by_email(user_id));

-- Payments policies
CREATE POLICY "Users can view their own payments" ON public.payments FOR SELECT USING (true);
CREATE POLICY "Users can insert their own payments" ON public.payments FOR INSERT WITH CHECK (true);

-- Subscriptions policies
CREATE POLICY "Users can view their own subscriptions" ON public.user_subscriptions FOR SELECT USING (true);
CREATE POLICY "Users can insert their own subscriptions" ON public.user_subscriptions FOR INSERT WITH CHECK (true);
CREATE POLICY "Users can update their own subscriptions" ON public.user_subscriptions FOR UPDATE USING (true);

-- Certificates policies
CREATE POLICY "Anyone can view active certificates" ON public.certificates FOR SELECT USING (is_active = true);
CREATE POLICY "Admins can manage certificates" ON public.certificates FOR ALL USING (public.is_current_user_admin());

-- Certificate templates policies
CREATE POLICY "Anyone can view active certificate templates" ON public.certificate_templates FOR SELECT USING (is_active = true);
CREATE POLICY "Admins can manage certificate templates" ON public.certificate_templates FOR ALL USING (public.is_current_user_admin());

-- User certificates policies
CREATE POLICY "Users can view their own certificates" ON public.user_certificates FOR SELECT USING (auth.uid() = user_id OR public.is_owner_by_email(user_id));
CREATE POLICY "Users can insert their own certificates" ON public.user_certificates FOR INSERT WITH CHECK (auth.uid() = user_id OR public.is_owner_by_email(user_id));
CREATE POLICY "Users can update their own certificates" ON public.user_certificates FOR UPDATE USING (auth.uid() = user_id OR public.is_owner_by_email(user_id));
CREATE POLICY "Admins can manage all user certificates" ON public.user_certificates FOR ALL USING (public.is_current_user_admin());

-- Course certificate management policies
CREATE POLICY "Users can view their own certificate management" ON public.course_certificate_management FOR SELECT USING (clerk_user_id = auth.jwt() ->> 'sub');
CREATE POLICY "System can insert certificate management" ON public.course_certificate_management FOR INSERT WITH CHECK (true);
CREATE POLICY "System can update certificate management" ON public.course_certificate_management FOR UPDATE USING (true);

-- Interview sessions policies
CREATE POLICY "Users can manage their own sessions" ON public.interview_sessions FOR ALL USING (true);

-- Interview reports policies
CREATE POLICY "Users can view their own reports" ON public.interview_reports FOR ALL USING (user_id = auth.uid() OR public.is_owner_by_email(user_id));

-- User reports policies
CREATE POLICY "Users can view their own reports" ON public.user_reports FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert their own reports" ON public.user_reports FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update their own reports" ON public.user_reports FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Admins can manage all reports" ON public.user_reports FOR ALL USING (public.is_current_user_admin());

-- Interview usage policies
CREATE POLICY "Users can manage their own interview usage" ON public.user_interview_usage FOR ALL USING (auth.uid() = user_id OR public.is_owner_by_email(user_id)) WITH CHECK (auth.uid() = user_id OR public.is_owner_by_email(user_id));

-- Interview resources policies
CREATE POLICY "Admins can manage interview resources" ON public.interview_resources FOR ALL USING (public.is_current_user_admin()) WITH CHECK (public.is_current_user_admin());
CREATE POLICY "Students can view active interview resources" ON public.interview_resources FOR SELECT USING (is_active = true);

-- =====================================================
-- TRIGGERS FOR UPDATED_AT
-- =====================================================
CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_admin_credentials_updated_at BEFORE UPDATE ON public.admin_credentials FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_courses_updated_at BEFORE UPDATE ON public.courses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_course_videos_updated_at BEFORE UPDATE ON public.course_videos FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_course_questions_updated_at BEFORE UPDATE ON public.course_questions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_learning_updated_at BEFORE UPDATE ON public.user_learning FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_subscriptions_updated_at BEFORE UPDATE ON public.user_subscriptions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_certificates_updated_at BEFORE UPDATE ON public.certificates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_certificate_templates_updated_at BEFORE UPDATE ON public.certificate_templates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_certificates_updated_at BEFORE UPDATE ON public.user_certificates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_course_certificate_management_updated_at BEFORE UPDATE ON public.course_certificate_management FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_interview_sessions_updated_at BEFORE UPDATE ON public.interview_sessions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_interview_reports_updated_at BEFORE UPDATE ON public.interview_reports FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_reports_updated_at BEFORE UPDATE ON public.user_reports FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_interview_usage_updated_at BEFORE UPDATE ON public.user_interview_usage FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_interview_resources_updated_at BEFORE UPDATE ON public.interview_resources FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_status ON public.profiles(status);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON public.profiles(role);
CREATE INDEX IF NOT EXISTS idx_courses_order ON public.courses(order_index);
CREATE INDEX IF NOT EXISTS idx_courses_active ON public.courses(is_active);
CREATE INDEX IF NOT EXISTS idx_course_videos_course_id ON public.course_videos(course_id);
CREATE INDEX IF NOT EXISTS idx_course_videos_order ON public.course_videos(order_index);
CREATE INDEX IF NOT EXISTS idx_course_questions_course_id ON public.course_questions(course_id);
CREATE INDEX IF NOT EXISTS idx_course_questions_difficulty ON public.course_questions(difficulty_level);
CREATE INDEX IF NOT EXISTS idx_user_learning_user_course ON public.user_learning(user_id, course_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(status);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON public.user_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_status ON public.user_subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_user_certificates_user_id ON public.user_certificates(user_id);
CREATE INDEX IF NOT EXISTS idx_user_certificates_clerk_user_id ON public.user_certificates(clerk_user_id);
CREATE INDEX IF NOT EXISTS idx_user_certificates_verification_code ON public.user_certificates(verification_code);
CREATE INDEX IF NOT EXISTS idx_interview_sessions_user_id ON public.interview_sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_reports_user_id ON public.user_reports(user_id);
CREATE INDEX IF NOT EXISTS idx_user_interview_usage_user_id ON public.user_interview_usage(user_id);

-- =====================================================
-- VIEWS FOR EASIER DATA ACCESS
-- =====================================================

-- Unified certificates view
CREATE OR REPLACE VIEW public.v_unified_certificates AS
SELECT 
  'user_certificate' as source,
  uc.id,
  uc.user_id,
  COALESCE(uc.clerk_user_id, 'legacy-' || uc.id) as clerk_user_id,
  uc.course_id,
  uc.certificate_id,
  uc.verification_code,
  uc.score,
  uc.completion_data,
  uc.is_active,
  uc.created_at,
  uc.updated_at,
  c.title as certificate_title,
  c.description as certificate_description,
  c.certificate_type
FROM public.user_certificates uc
JOIN public.certificates c ON uc.certificate_id = c.id
WHERE uc.is_active = true

UNION ALL

SELECT 
  'certificate_management' as source,
  ccm.id,
  NULL as user_id,
  ccm.clerk_user_id,
  ccm.course_id,
  NULL as certificate_id,
  'CERT-MGMT-' || ccm.id as verification_code,
  ccm.assessment_score as score,
  jsonb_build_object(
    'course_id', ccm.course_id,
    'course_name', ccm.course_name,
    'completion_date', ccm.completion_date,
    'score', ccm.assessment_score,
    'passing_score', 70,
    'user_name', 'Student'
  ) as completion_data,
  true as is_active,
  ccm.created_at,
  ccm.updated_at,
  ccm.course_name || ' Completion Certificate' as certificate_title,
  'Certificate of successful completion for ' || ccm.course_name as certificate_description,
  'completion' as certificate_type
FROM public.course_certificate_management ccm
WHERE ccm.course_complete = true AND ccm.assessment_pass = true;

-- User certificates view with embedded certificate data
CREATE OR REPLACE VIEW public.v_user_certificates AS
SELECT
  uc.id,
  uc.user_id,
  uc.course_id,
  uc.certificate_id,
  uc.template_id,
  uc.issued_date,
  uc.score,
  uc.is_active,
  uc.certificate_url,
  uc.populated_html,
  uc.verification_code,
  uc.completion_data,
  uc.created_at,
  uc.updated_at,
  c.title AS certificate_title,
  c.description AS certificate_description,
  c.certificate_type,
  c.is_active AS certificate_is_active
FROM public.user_certificates uc
LEFT JOIN public.certificates c ON c.id = uc.certificate_id;

-- =====================================================
-- STORAGE BUCKETS
-- =====================================================

-- Create storage buckets
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('course-videos', 'course-videos', true, 524288000, ARRAY['video/mp4', 'video/webm', 'video/quicktime', 'video/x-msvideo']),
  ('interview-resources', 'interview-resources', false, 10485760, ARRAY['application/pdf'])
ON CONFLICT (id) DO NOTHING;

-- Storage policies for course-videos
CREATE POLICY "Anyone can view course videos" ON storage.objects FOR SELECT USING (bucket_id = 'course-videos');
CREATE POLICY "Admins can upload course videos" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'course-videos' AND public.is_current_user_admin());
CREATE POLICY "Admins can update course videos" ON storage.objects FOR UPDATE USING (bucket_id = 'course-videos' AND public.is_current_user_admin());
CREATE POLICY "Admins can delete course videos" ON storage.objects FOR DELETE USING (bucket_id = 'course-videos' AND public.is_current_user_admin());

-- Storage policies for interview-resources
CREATE POLICY "Admins can manage interview resources" ON storage.objects FOR ALL USING (bucket_id = 'interview-resources' AND public.is_current_user_admin());
CREATE POLICY "Pro users can download interview resources" ON storage.objects FOR SELECT USING (
  bucket_id = 'interview-resources'
  AND EXISTS (
    SELECT 1 FROM public.user_subscriptions
    WHERE user_subscriptions.user_id = auth.uid()
    AND user_subscriptions.plan_type = 'pro'
    AND user_subscriptions.status = 'active'
    AND (
      user_subscriptions.was_granted = true
      OR user_subscriptions.current_period_end > NOW()
    )
  )
);

-- =====================================================
-- INITIAL DATA
-- =====================================================

-- Insert default admin credentials
INSERT INTO public.admin_credentials (username, password_hash) 
VALUES ('admin', crypt('admin', gen_salt('bf')))
ON CONFLICT (username) DO NOTHING;

-- Insert default certificate
INSERT INTO public.certificates (title, description, certificate_type, auto_issue, requirements) VALUES
('Course Completion Certificate', 'Certificate for completing course assessments', 'completion', true, '{"min_score": 70}')
ON CONFLICT DO NOTHING;

-- Insert default certificate template
INSERT INTO public.certificate_templates (name, description, html_template, placeholders, is_default) VALUES (
  'Professional Certificate',
  'Default professional certificate template',
  '<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Certificate of Achievement</title>
    <style>
        body {
            font-family: "Times New Roman", serif;
            margin: 0;
            padding: 40px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .certificate {
            background: white;
            width: 800px;
            padding: 60px;
            border: 10px solid #2c3e50;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
            position: relative;
        }
        .certificate::before {
            content: "";
            position: absolute;
            top: 20px;
            left: 20px;
            right: 20px;
            bottom: 20px;
            border: 3px solid #3498db;
            border-radius: 5px;
        }
        .header {
            margin-bottom: 30px;
        }
        .company-name {
            font-size: 24px;
            color: #2c3e50;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 3px;
            margin-bottom: 10px;
        }
        .certificate-title {
            font-size: 36px;
            color: #34495e;
            font-weight: bold;
            margin: 20px 0;
            text-transform: uppercase;
            letter-spacing: 2px;
        }
        .subtitle {
            font-size: 18px;
            color: #7f8c8d;
            margin-bottom: 40px;
        }
        .recipient-name {
            font-size: 42px;
            color: #2980b9;
            font-weight: bold;
            margin: 30px 0;
            text-decoration: underline;
            text-decoration-color: #3498db;
        }
        .course-info {
            font-size: 20px;
            color: #34495e;
            margin: 30px 0;
            line-height: 1.6;
        }
        .completion-details {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 50px;
            padding-top: 30px;
            border-top: 2px solid #ecf0f1;
        }
        .date {
            font-size: 16px;
            color: #7f8c8d;
        }
        .signature {
            text-align: center;
        }
        .signature-line {
            border-bottom: 2px solid #34495e;
            width: 200px;
            margin: 20px auto 10px auto;
        }
        .signature-text {
            font-size: 14px;
            color: #7f8c8d;
        }
        .score {
            font-size: 18px;
            color: #27ae60;
            font-weight: bold;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="certificate">
        <div class="header">
            <div class="company-name">{{company_name}}</div>
            <div class="certificate-title">Certificate of Achievement</div>
            <div class="subtitle">This is to certify that</div>
        </div>
        
        <div class="recipient-name">{{user_name}}</div>
        
        <div class="course-info">
            has successfully completed the course<br>
            <strong>{{course_name}}</strong>
        </div>
        
        <div class="score">Final Score: {{score}}</div>
        
        <div class="completion-details">
            <div class="date">
                Date of Completion:<br>
                <strong>{{completion_date}}</strong>
            </div>
            <div class="signature">
                <div class="signature-line"></div>
                <div class="signature-text">Authorized Signature</div>
            </div>
        </div>
    </div>
</body>
</html>',
  '["user_name", "course_name", "completion_date", "company_name", "score"]'::jsonb,
  true
) ON CONFLICT DO NOTHING;

-- Insert default courses
INSERT INTO public.courses (name, description, order_index) VALUES
('Interview Mastery', 'Master the art of technical and behavioral interviews', 1),
('System Design', 'Learn to design scalable distributed systems', 2),
('Data Structures & Algorithms', 'Master fundamental CS concepts for coding interviews', 3),
('Behavioral Interview Skills', 'Excel at behavioral and leadership questions', 4),
('Resume Optimization', 'Create compelling resumes that get noticed', 5)
ON CONFLICT (name) DO NOTHING;

-- =====================================================
-- REALTIME SUBSCRIPTIONS
-- =====================================================
ALTER TABLE public.user_certificates REPLICA IDENTITY FULL;
ALTER TABLE public.interview_reports REPLICA IDENTITY FULL;
ALTER TABLE public.user_interview_usage REPLICA IDENTITY FULL;
ALTER TABLE public.course_videos REPLICA IDENTITY FULL;
ALTER TABLE public.courses REPLICA IDENTITY FULL;

-- Add tables to realtime publication
DO $$
BEGIN
  -- Add tables to realtime publication if they exist
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.user_certificates;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.interview_reports;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.user_interview_usage;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.course_videos;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.courses;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    -- Ignore errors if publication doesn't exist or tables are already added
    NULL;
END $$;