# Database Setup Guide

## Overview

This guide will help you set up a fresh Supabase database for the MockInvi project from scratch.

## Prerequisites

- Supabase CLI installed
- Node.js and npm installed
- A Supabase account (free tier is sufficient)

## Step 1: Create New Supabase Project

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Click "New Project"
3. Choose your organization
4. Enter project details:
   - **Name**: MockInvi
   - **Database Password**: Choose a strong password
   - **Region**: Select closest to your users
5. Click "Create new project"
6. Wait for the project to be ready (2-3 minutes)

## Step 2: Get Project Credentials

1. In your Supabase project dashboard, go to **Settings** > **API**
2. Copy the following values:
   - **Project URL** (e.g., `https://your-project-ref.supabase.co`)
   - **Project Reference ID** (e.g., `your-project-ref`)
   - **Anon/Public Key** (starts with `eyJ...`)
   - **Service Role Key** (starts with `eyJ...`) - Keep this secret!

## Step 3: Configure Local Environment

Create a `.env.local` file in your project root:

```env
# Supabase Configuration
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key

# Clerk Authentication (get from Clerk dashboard)
VITE_CLERK_PUBLISHABLE_KEY=pk_test_your-clerk-key

# Optional: API Keys (can be configured later in admin panel)
VITE_GEMINI_API_KEY=your-gemini-api-key
VITE_GOOGLE_TTS_API_KEY=your-google-tts-api-key
VITE_RAZORPAY_KEY_ID=your-razorpay-key-id
```

## Step 4: Apply Database Schema

### Option A: Using Supabase CLI (Recommended)

```bash
# Initialize Supabase in your project
npx supabase init

# Link to your remote project
npx supabase link --project-ref your-project-ref

# Apply the fresh database migration
npx supabase db push
```

### Option B: Manual SQL Execution

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Copy the contents of `supabase/migrations/20250127000000_create_fresh_database.sql`
4. Paste and run the SQL

## Step 5: Configure Edge Functions

Deploy the edge functions to your Supabase project:

```bash
# Deploy all edge functions
npx supabase functions deploy gemini-interview
npx supabase functions deploy learning-service
npx supabase functions deploy razorpay-payment
npx supabase functions deploy voice-to-text
npx supabase functions deploy text-to-speech
npx supabase functions deploy real-job-search
npx supabase functions deploy admin-upload
```

## Step 6: Update Application Configuration

Update `src/integrations/supabase/client.ts` with your new project details:

```typescript
const SUPABASE_URL = "https://your-project-ref.supabase.co";
const SUPABASE_PUBLISHABLE_KEY = "your-anon-key";
```

## Step 7: Test the Setup

1. Start your development server:
   ```bash
   npm run dev
   ```

2. Test admin access:
   - Go to `/login`
   - Click "Admin Access"
   - Use credentials: `admin` / `admin`

3. Test user registration:
   - Go to `/register`
   - Create a test account
   - Verify login works

## Step 8: Configure API Keys (Admin Panel)

1. Login as admin
2. Go to **Admin Settings**
3. Configure your API keys:
   - **Gemini API Key**: For AI interview questions
   - **Google TTS API Key**: For text-to-speech
   - **Razorpay Keys**: For payment processing

## Database Schema Overview

### Core Tables

- **profiles**: User accounts and authentication
- **admin_credentials**: Admin authentication and API keys
- **courses**: Learning courses
- **course_videos**: Video content
- **course_questions**: Assessment questions
- **user_learning**: Progress tracking
- **user_subscriptions**: Subscription management
- **payments**: Payment records
- **certificates**: Certificate templates
- **user_certificates**: Issued certificates

### Features Included

✅ **User Management**: Registration, authentication, profiles  
✅ **Learning System**: Courses, videos, assessments  
✅ **Certificate System**: Automated certificate generation  
✅ **Interview Practice**: AI-powered mock interviews  
✅ **Payment Processing**: Razorpay integration  
✅ **Admin Panel**: Content and user management  
✅ **Analytics**: Progress tracking and reporting  

## Troubleshooting

### Common Issues

1. **Migration Fails**: Ensure you have the latest Supabase CLI
2. **RLS Errors**: Check that your user has proper permissions
3. **Edge Function Errors**: Verify API keys are configured
4. **Authentication Issues**: Confirm Clerk configuration

### Getting Help

- Check the Supabase logs in your dashboard
- Review the browser console for client-side errors
- Verify environment variables are set correctly

## Security Notes

- The fresh database includes proper RLS policies
- Admin credentials are hashed using bcrypt
- API keys are stored securely in the admin_credentials table
- User data is protected by row-level security

## Next Steps

After setup:

1. **Add Content**: Use the admin panel to create courses and videos
2. **Configure Payments**: Set up Razorpay for subscription processing
3. **Customize**: Modify certificate templates and branding
4. **Deploy**: Deploy to production when ready

Your MockInvi platform is now ready to use with a fresh, optimized database!