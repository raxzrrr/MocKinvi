
import React from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '@/contexts/ClerkAuthContext';
import { 
  LayoutDashboard, 
  BookOpen, 
  Video, 
  FileText, 
  Award, 
  Settings, 
  LogOut,
  FileVideo,
  Tag,
  CreditCard,
  Sparkles,
  GraduationCap,
  UserCog,
  Briefcase
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { useToast } from '@/components/ui/use-toast';
import { useTheme } from 'next-themes';

interface DashboardLayoutProps {
  children: React.ReactNode;
}

type NavItem = {
  icon: any;
  label: string;
  href: string;
  color: string; // tailwind color class for icon
};

const DashboardLayout: React.FC<DashboardLayoutProps> = ({ children }) => {
  const { user, profile, isAdmin, isStudent, logout } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const { toast } = useToast();
  const { theme, setTheme } = useTheme();

  const studentNavItems: NavItem[] = [
    { icon: LayoutDashboard, label: 'Dashboard', href: '/dashboard', color: 'text-blue-500' },
    { icon: Video, label: 'Interview Practice', href: '/interviews', color: 'text-green-500' },
    { icon: Sparkles, label: 'Custom Interviews', href: '/custom-interviews', color: 'text-purple-500' },
    { icon: FileText, label: 'AI Resume Maker', href: '/resume-maker', color: 'text-sky-500' },
    { icon: BookOpen, label: 'Learning Hub', href: '/learning', color: 'text-emerald-500' },
    { icon: Briefcase, label: 'Jobs', href: '/jobs', color: 'text-amber-500' },
    { icon: FileText, label: 'Interview Resources', href: '/interview-resources', color: 'text-indigo-500' },
    { icon: Award, label: 'Certificates', href: '/certificates', color: 'text-pink-500' },
    { icon: Settings, label: 'Settings', href: '/settings', color: 'text-gray-500' },
  ];

  const adminNavItems: NavItem[] = [
    { icon: LayoutDashboard, label: 'Dashboard', href: '/admin', color: 'text-blue-500' },
    { icon: UserCog, label: 'User Management', href: '/admin/user-management', color: 'text-rose-500' },
    { icon: GraduationCap, label: 'Course Management', href: '/admin/courses', color: 'text-emerald-500' },
    { icon: FileText, label: 'Interview Resources', href: '/admin/interview-resources', color: 'text-indigo-500' },
    { icon: CreditCard, label: 'Payments', href: '/admin/payments', color: 'text-amber-500' },
    { icon: Award, label: 'Certificates', href: '/admin/certificates', color: 'text-pink-500' },
    { icon: Settings, label: 'Settings', href: '/admin/settings', color: 'text-gray-500' },
  ];

  const navItems = (isAdmin() ? adminNavItems : studentNavItems);

  return (
    <div className="flex h-screen overflow-hidden bg-background">
      {/* Sidebar */}
      <div className="hidden md:flex md:flex-col md:w-64 md:fixed md:inset-y-0 z-10 sidebar-glass">
        <div className="flex items-center justify-between h-16 px-4 border-b border-gray-200 dark:border-white/10">
          <Link to="/" className="flex items-center gap-2 hover:opacity-90 transition">
            <img src="/src/assets/mockinvi-logo.png" alt="MockInvi" className="w-8 h-8 rounded-lg shadow" />
            <span className="text-xl font-bold text-gray-800 dark:text-gray-100">MockInvi</span>
          </Link>
          <Button
            variant="outline"
            size="sm"
            onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
            className="btn-glass"
          >
            {theme === 'dark' ? 'Light' : 'Dark'}
          </Button>
        </div>
        
        <div className="flex flex-col flex-grow p-4 overflow-y-auto">
          <div className="mb-8">
            <div className="px-4 py-2 text-xs font-semibold text-gray-500 dark:text-gray-400 uppercase tracking-wide">
              Main
            </div>
            <nav className="space-y-1">
              {navItems.map((item, index) => (
                <Link
                  key={index}
                  to={item.href}
                  className={cn(
                    'flex items-center px-4 py-3 text-sm rounded-xl transition-all duration-200',
                    location.pathname === item.href
                      ? 'bg-blue-50 dark:bg-blue-500/10 text-blue-700 dark:text-blue-300 shadow-sm border border-blue-200 dark:border-blue-500/30'
                      : 'text-gray-600 dark:text-gray-300 hover:bg-gray-50 dark:hover:bg-white/5 hover:text-gray-800 dark:hover:text-gray-100'
                  )}
                >
                  <item.icon className={cn('w-5 h-5 mr-3 flex-shrink-0', item.color)} />
                  <span className="truncate">{item.label}</span>
                </Link>
              ))}
            </nav>
          </div>
          
          <div className="mt-auto border-t border-gray-200 dark:border-white/10 pt-4">
            <div className="px-4 py-3 mb-2">
              <div className="flex items-center">
                <div className="flex-shrink-0">
                  <div className="w-10 h-10 rounded-full bg-gradient-to-br from-blue-600 to-purple-600 flex items-center justify-center text-white font-medium shadow-lg">
                    {(profile?.full_name ? profile.full_name.charAt(0).toUpperCase() : 'U')}
                  </div>
                </div>
                <div className="ml-3 min-w-0 flex-1">
                  <p className="text-sm font-medium text-gray-800 dark:text-gray-100 truncate">
                    {profile?.full_name || 'User'}
                  </p>
                  <p className="text-xs text-gray-500 dark:text-gray-400 truncate">
                    {user?.primaryEmailAddress?.emailAddress || 'guest@mockinvi.ai'}
                  </p>
                </div>
              </div>
            </div>
            {user && (
              <Button
                variant="ghost"
                className="flex items-center w-full px-4 py-3 text-sm text-gray-600 dark:text-gray-300 rounded-xl hover:bg-gray-50 dark:hover:bg-white/5 hover:text-gray-800 dark:hover:text-gray-100 transition-all duration-200"
                onClick={async () => {
                  try {
                    await logout();
                    navigate('/login');
                  } catch (e) {}
                }}
              >
                <LogOut className="w-5 h-5 mr-3 flex-shrink-0" />
                <span>Logout</span>
              </Button>
            )}
          </div>
        </div>
      </div>
      
      {/* Main content */}
      <div className="flex flex-col flex-1 md:ml-64 overflow-y-auto bg-background">
        <header className="sticky top-0 z-10 flex items-center justify-between h-16 px-6 nav-glass md:hidden">
          <Link to="/" className="flex items-center gap-2">
            <img src="/src/assets/mockinvi-logo.png" alt="MockInvi" className="w-6 h-6 rounded" />
            <span className="text-xl font-bold text-gray-800 dark:text-gray-100">MockInvi</span>
          </Link>
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
              className="btn-glass"
            >
              {theme === 'dark' ? 'Light' : 'Dark'}
            </Button>
          </div>
        </header>
        
        <main className="flex-1">
          <div className="max-w-7xl mx-auto p-6">
            {children}
          </div>
        </main>
      </div>
    </div>
  );
};

export default DashboardLayout;
