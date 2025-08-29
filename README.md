# MockInvi – AI-Powered Interview Preparation

## Project Overview

MockInvi is an AI-powered platform designed to help you master interviews. Upload your resume, practice with personalized questions, and receive real-time feedback with a modern macOS/iOS-inspired glassmorphic UI. It includes an AI Resume Maker, Learning Hub with assessments, certificates, and an admin area.

## Getting Started

### Prerequisites

- Node.js & npm installed – [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating)
- Supabase CLI – [install guide](https://supabase.com/docs/guides/cli)
- GitHub CLI (optional) – `https://cli.github.com/`

### Installation

Follow these steps to set up the project locally:

```sh
# Step 1: Clone the repository
git clone <YOUR_GIT_URL>

# Step 2: Navigate to the project directory
cd <YOUR_PROJECT_NAME>

# Step 3: Install the necessary dependencies
npm i

# Step 4: Start the development server with auto-reloading and an instant preview
npm run dev
```

### Database Setup

To set up a fresh database:

```sh
# Step 1: Initialize Supabase (if not already done)
npx supabase init

# Step 2: Start local Supabase
npx supabase start

# Step 3: Apply the fresh database migration
npx supabase db reset

# Step 4: (Optional) Link to remote Supabase project
npx supabase link --project-ref your-project-ref

# Step 5: Push migrations to remote (if linked)
npx supabase db push
```

## Technologies Used

This project is built with:

- Vite
- TypeScript
- React
- shadcn-ui
- Tailwind CSS
- Supabase (Backend)
- Clerk (Authentication)

## Features

- AI-powered interview question generation (role-based and resume-based)
- Resume analysis and AI Resume Maker (PDF + DOCX export, live preview, templates)
- Real-time voice-to-text interview practice (Web Speech API)
- Face presence guard (non-blocking) during interviews
- Comprehensive performance reports and trend analytics
- Learning modules with assessments and certificates
- Certificate preview/download with branded template
- Admin dashboard for content management
- Light/Dark mode with system preference support
- Smooth 120Hz-friendly animations and glassmorphic UI

## Environment Variables

Create a `.env.local` file in the root directory and add your environment variables:

# Supabase Configuration
VITE_SUPABASE_URL=your-supabase-url
VITE_SUPABASE_ANON_KEY=your-supabase-anon-key

# Clerk Authentication
VITE_CLERK_PUBLISHABLE_KEY=your-clerk-publishable-key

# API Keys (configure in admin panel)
VITE_GEMINI_API_KEY=your-gemini-api-key
VITE_GOOGLE_TTS_API_KEY=your-google-tts-api-key

# Payment Configuration
VITE_RAZORPAY_KEY_ID=your-razorpay-key-id
```

### Admin Configuration

After setting up the database:

1. **Access Admin Panel**: Go to `/login` and click "Admin Access"
2. **Default Credentials**: 
   - Username: `admin`
   - Password: `admin`
3. **Configure API Keys**: Go to Admin Settings to add your API keys
4. **Create Content**: Add courses, videos, and questions through the admin panel

### Fresh Database Benefits

This fresh database setup provides:

- **Clean Schema**: No legacy migration conflicts
- **Optimized Performance**: Proper indexes and constraints
- **Complete Feature Set**: All tables and functions included
- **Security**: Proper RLS policies and admin controls
- **Scalability**: Designed for production use

### Database Features

- **User Management**: Clerk integration with local fallback
- **Learning System**: Courses, videos, assessments, certificates
- **Interview Practice**: AI-powered mock interviews with evaluation
- **Payment Processing**: Razorpay integration with subscription management
- **Content Management**: Admin tools for courses and resources
- **Analytics**: User progress tracking and performance metrics