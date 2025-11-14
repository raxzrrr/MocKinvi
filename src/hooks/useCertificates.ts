
import { useState, useEffect } from 'react';
import { useAuth } from '@/contexts/ClerkAuthContext';
import { supabase } from '@/integrations/supabase/client';

interface Certificate {
  id: string;
  title: string;
  description: string | null;
  certificate_type: string;
  template_data: any;
  requirements: any;
  is_active: boolean;
  auto_issue: boolean;
  created_at: string;
  updated_at: string;
}

interface UserCertificate {
  id: string;
  user_id: string;
  certificate_id: string;
  course_id: string | null;
  issued_date: string;
  completion_data: any;
  certificate_url: string | null;
  verification_code: string;
  score: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
  certificate_title: string;
  certificate_description: string | null;
  certificate_type: string;
  certificate_is_active: boolean;
}

// NEW: Interface for certificate management
interface CertificateManagement {
  id: string;
  clerk_user_id: string;
  course_id: string;
  course_name: string;
  course_complete: boolean;
  assessment_pass: boolean;
  assessment_score: number;
  completion_date: string;
  created_at: string;
  updated_at: string;
}

export const useCertificates = () => {
  const [userCertificates, setUserCertificates] = useState<UserCertificate[]>([]);
  const [availableCertificates, setAvailableCertificates] = useState<Certificate[]>([]);
  const [loading, setLoading] = useState(true);
  const { getSupabaseUserId, isAuthenticated, ensureSupabaseSession, user } = useAuth();

  useEffect(() => {
    const fetchCertificates = async () => {
      if (!isAuthenticated) {
        setUserCertificates([]);
        setAvailableCertificates([]);
        setLoading(false);
        return;
      }

      try {
        // Ensure Supabase session is established before querying RLS-protected tables
        await ensureSupabaseSession();
        
        const supabaseUserId = getSupabaseUserId();
        const clerkUserId = user?.id;
        
        if (!supabaseUserId || !clerkUserId) {
          console.log('useCertificates - No user ID available');
          setUserCertificates([]);
          setAvailableCertificates([]);
          setLoading(false);
          return;
        }

        console.log('useCertificates - Fetching certificates for user:', supabaseUserId);
        
        // Fetch user's certificates using the new unified view
        const { data: userCerts, error: userError } = await supabase
          .from('v_unified_certificates')
          .select('*')
          .eq('clerk_user_id', clerkUserId)
          .eq('is_active', true)
          .order('created_at', { ascending: false });

        let processedCerts = [];

        if (userError) {
          console.error('Error fetching unified certificates:', userError);
          processedCerts = [];
        } else {
          console.log('useCertificates - Found unified certificates:', userCerts);
          
          // Process certificates to ensure they have required fields
          processedCerts = (userCerts || []).map((cert) => ({
            ...cert,
            // Provide fallback values if certificate data is missing
            certificate_title: cert.certificate_title || 'Course Completion Certificate',
            certificate_description: cert.certificate_description || 'Certificate of successful course completion',
            // Ensure issued_date is available for all certificates
            issued_date: cert.issued_date || cert.created_at || cert.completion_data?.completion_date || cert.created_at
          }));
        }

        // Also fetch frontend-generated certificates from localStorage
        try {
          const localCerts = JSON.parse(localStorage.getItem('user_certificates') || '[]');
          const frontendCerts = localCerts.map((cert: any) => ({
            id: cert.id,
            certificate_title: cert.title,
            certificate_description: `Certificate of successful completion for ${cert.courseName}`,
            certificate_type: 'completion',
            score: cert.score,
            verification_code: cert.verificationCode,
            completion_data: {
              course_name: cert.courseName,
              completion_date: cert.completionDate,
              score: cert.score,
              user_name: cert.userName
            },
            issued_date: cert.issuedDate,
            created_at: cert.issuedDate,
            source: 'frontend-generated'
          }));

          // Combine database and localStorage certificates
          const allCerts = [...processedCerts, ...frontendCerts];
          
          // Sort by creation date (newest first)
          allCerts.sort((a, b) => new Date(b.created_at || b.issued_date).getTime() - new Date(a.created_at || a.issued_date).getTime());
          
          setUserCertificates(allCerts);
        } catch (localError) {
          console.error('Error reading localStorage certificates:', localError);
          setUserCertificates(processedCerts);
        }

        // Fetch available certificates
        const { data: availableCerts, error: availableError } = await supabase
          .from('certificates')
          .select('*')
          .eq('is_active', true)
          .order('created_at', { ascending: false });

        if (availableError) {
          console.error('Error fetching available certificates:', availableError);
          setAvailableCertificates([]);
        } else {
          setAvailableCertificates(availableCerts || []);
        }
      } catch (error) {
        console.error('Error in fetchCertificates:', error);
        setUserCertificates([]);
        setAvailableCertificates([]);
      } finally {
        setLoading(false);
      }
    };

    fetchCertificates();

    // Listen for auth state changes to refetch when session is ready
    const { data: { subscription } } = supabase.auth.onAuthStateChange((event, session) => {
      if (event === 'SIGNED_IN' || (event === 'TOKEN_REFRESHED' && session)) {
        console.log('useCertificates - Auth state changed, refetching certificates');
        fetchCertificates();
      }
    });

    return () => {
      subscription.unsubscribe();
    };
  }, [isAuthenticated, getSupabaseUserId, ensureSupabaseSession, user]);

  const refetch = () => {
    setLoading(true);
    fetchCertificates();
  };

  return {
    userCertificates,
    availableCertificates,
    loading,
    refetch
  };
};
