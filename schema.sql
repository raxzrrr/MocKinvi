-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.admin_credentials (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  username text NOT NULL UNIQUE,
  password_hash text NOT NULL,
  gemini_api_key text,
  google_tts_api_key text,
  clerk_publishable_key text,
  razorpay_key_id text,
  razorpay_key_secret text,
  pro_plan_price_inr integer,
  company_name text DEFAULT 'cyrobox solutions'::text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT admin_credentials_pkey PRIMARY KEY (id)
);
CREATE TABLE public.certificate_templates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text,
  html_template text NOT NULL,
  placeholders jsonb DEFAULT '[]'::jsonb,
  is_active boolean DEFAULT true,
  is_default boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT certificate_templates_pkey PRIMARY KEY (id)
);
CREATE TABLE public.certificates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  certificate_type text DEFAULT 'completion'::text,
  template_data jsonb DEFAULT '{}'::jsonb,
  requirements jsonb DEFAULT '{}'::jsonb,
  is_active boolean DEFAULT true,
  auto_issue boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT certificates_pkey PRIMARY KEY (id)
);
CREATE TABLE public.course_questions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL,
  question_text text NOT NULL,
  difficulty_level text NOT NULL CHECK (difficulty_level = ANY (ARRAY['easy'::text, 'intermediate'::text, 'hard'::text])),
  option_1 text NOT NULL,
  option_2 text NOT NULL,
  option_3 text NOT NULL,
  option_4 text NOT NULL,
  correct_answer integer NOT NULL CHECK (correct_answer >= 1 AND correct_answer <= 4),
  explanation text,
  order_index integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT course_questions_pkey PRIMARY KEY (id)
);
CREATE TABLE public.course_videos (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  course_id uuid NOT NULL,
  title text NOT NULL,
  description text,
  video_url text NOT NULL,
  duration text,
  order_index integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  content_type character varying DEFAULT 'url'::character varying,
  file_path text,
  file_size bigint,
  thumbnail_url text,
  CONSTRAINT course_videos_pkey PRIMARY KEY (id),
  CONSTRAINT course_videos_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id)
);
CREATE TABLE public.courses (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  description text,
  thumbnail_url text,
  order_index integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT courses_pkey PRIMARY KEY (id)
);
CREATE TABLE public.interview_reports (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  overall_score integer DEFAULT 0,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT interview_reports_pkey PRIMARY KEY (id)
);
CREATE TABLE public.interview_resources (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  file_name text NOT NULL,
  file_path text NOT NULL,
  file_size bigint,
  uploaded_by uuid,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  is_active boolean NOT NULL DEFAULT true,
  CONSTRAINT interview_resources_pkey PRIMARY KEY (id),
  CONSTRAINT interview_resources_uploaded_by_fkey FOREIGN KEY (uploaded_by) REFERENCES auth.users(id)
);
CREATE TABLE public.interview_sessions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  interview_type text NOT NULL CHECK (interview_type = ANY (ARRAY['basic_hr_technical'::text, 'role_based'::text, 'resume_based'::text])),
  question_count integer NOT NULL CHECK (question_count >= 5 AND question_count <= 10),
  job_role text,
  questions jsonb NOT NULL DEFAULT '[]'::jsonb,
  ideal_answers jsonb NOT NULL DEFAULT '[]'::jsonb,
  user_answers jsonb DEFAULT '[]'::jsonb,
  evaluations jsonb DEFAULT '[]'::jsonb,
  overall_score integer DEFAULT 0,
  session_status text NOT NULL DEFAULT 'created'::text CHECK (session_status = ANY (ARRAY['created'::text, 'in_progress'::text, 'completed'::text])),
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  completed_at timestamp with time zone,
  CONSTRAINT interview_sessions_pkey PRIMARY KEY (id)
);
CREATE TABLE public.payments (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  razorpay_order_id text NOT NULL,
  razorpay_payment_id text NOT NULL,
  razorpay_signature text NOT NULL,
  amount integer NOT NULL,
  currency text NOT NULL DEFAULT 'INR'::text,
  plan_type text NOT NULL,
  status text NOT NULL DEFAULT 'completed'::text,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT payments_pkey PRIMARY KEY (id),
  CONSTRAINT fk_payments_profiles FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.profiles (
  id uuid NOT NULL,
  full_name text NOT NULL,
  avatar_url text,
  role USER-DEFINED NOT NULL DEFAULT 'student'::user_role,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  status text DEFAULT 'active'::text CHECK (status = ANY (ARRAY['active'::text, 'inactive'::text, 'pending'::text])),
  email text,
  last_active timestamp with time zone DEFAULT now(),
  password_hash text,
  email_verified boolean DEFAULT false,
  auth_provider text DEFAULT 'clerk'::text,
  CONSTRAINT profiles_pkey PRIMARY KEY (id)
);
CREATE TABLE public.question_banks (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  technology text NOT NULL,
  category text NOT NULL,
  questions jsonb NOT NULL DEFAULT '[]'::jsonb,
  difficulty_level text DEFAULT 'mixed'::text,
  total_questions integer DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT question_banks_pkey PRIMARY KEY (id)
);
CREATE TABLE public.user_certificates (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  certificate_id uuid NOT NULL,
  issued_date timestamp with time zone DEFAULT now(),
  completion_data jsonb DEFAULT '{}'::jsonb,
  certificate_url text,
  verification_code text DEFAULT concat('CERT-', upper(SUBSTRING((gen_random_uuid())::text FROM 1 FOR 8))) UNIQUE,
  status text DEFAULT 'issued'::text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  template_id uuid,
  populated_html text,
  certificate_hash text UNIQUE,
  course_id uuid,
  score integer DEFAULT 0,
  is_active boolean DEFAULT true,
  CONSTRAINT user_certificates_pkey PRIMARY KEY (id),
  CONSTRAINT user_certificates_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT user_certificates_certificate_id_fkey FOREIGN KEY (certificate_id) REFERENCES public.certificates(id),
  CONSTRAINT user_certificates_template_id_fkey FOREIGN KEY (template_id) REFERENCES public.certificate_templates(id)
);
CREATE TABLE public.user_interview_usage (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  free_interview_used boolean DEFAULT false,
  usage_count integer DEFAULT 0,
  last_interview_date timestamp with time zone,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT user_interview_usage_pkey PRIMARY KEY (id),
  CONSTRAINT user_interview_usage_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.user_learning (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  course_progress jsonb DEFAULT '{}'::jsonb,
  completed_modules integer DEFAULT 0,
  total_modules integer DEFAULT 0,
  course_score integer,
  course_completed_at timestamp with time zone,
  assessment_attempted boolean DEFAULT false,
  assessment_score integer,
  assessment_completed_at timestamp with time zone,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  category_progress jsonb DEFAULT '{}'::jsonb,
  course_progress_new jsonb DEFAULT '{}'::jsonb,
  course_id uuid NOT NULL,
  CONSTRAINT user_learning_pkey PRIMARY KEY (id),
  CONSTRAINT user_learning_course_id_fkey FOREIGN KEY (course_id) REFERENCES public.courses(id)
);
CREATE TABLE public.user_reports (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  report_type text NOT NULL DEFAULT 'interview'::text,
  title text NOT NULL,
  pdf_url text,
  pdf_data bytea,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  CONSTRAINT user_reports_pkey PRIMARY KEY (id),
  CONSTRAINT user_reports_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);
CREATE TABLE public.user_subscriptions (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  plan_type text NOT NULL,
  status text NOT NULL DEFAULT 'active'::text,
  current_period_start timestamp with time zone NOT NULL,
  current_period_end timestamp with time zone NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),
  was_granted boolean DEFAULT false,
  CONSTRAINT user_subscriptions_pkey PRIMARY KEY (id),
  CONSTRAINT fk_subscriptions_profiles FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);