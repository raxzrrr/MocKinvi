
import React from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { useAuth } from '@/contexts/ClerkAuthContext';
import { useToast } from '@/components/ui/use-toast';
import { useTheme } from 'next-themes';

const Header: React.FC = () => {
  const { user, profile, isAdmin, isStudent, logout } = useAuth();
  const navigate = useNavigate();
  const { toast } = useToast();
  const { theme, setTheme } = useTheme();
  
  const handleLogout = async () => {
    try {
      console.log("Logout button clicked");
      await logout();
      navigate('/login');
    } catch (error) {
      console.error("Logout error:", error);
      toast({
        title: "Logout failed",
        description: "There was a problem logging you out. Please try again.",
        variant: "destructive",
      });
    }
  };

  return (
    <header className="sticky top-0 z-50 bg-white border-b border-gray-200 shadow-sm">
      <div className="container flex items-center justify-between h-20 px-4 mx-auto">
        <Link to="/" className="flex items-center space-x-3 group">
          <div className="flex items-center space-x-3">
            <div className="w-12 h-12 bg-gradient-to-br from-blue-600 to-purple-600 rounded-xl flex items-center justify-center shadow-lg group-hover:shadow-xl transition-all duration-300">
              <span className="text-white text-xl font-bold">M</span>
            </div>
            <div className="flex flex-col">
              <span className="text-3xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent group-hover:from-blue-700 group-hover:to-purple-700 transition-all duration-300">
                MocKinvi
              </span>
              <span className="text-xs text-gray-500 font-medium -mt-1">
                Interview Practice Platform
              </span>
            </div>
          </div>
        </Link>

        <nav className="hidden md:flex items-center space-x-6">
          <Link to="/" className="text-gray-600 hover:text-blue-600 transition-colors font-medium">
            Home
          </Link>
          
          {!user && (
            <>
              <Link to="/about" className="text-gray-600 hover:text-blue-600 transition-colors font-medium">
                About
              </Link>
              <Link to="/pricing" className="text-gray-600 hover:text-blue-600 transition-colors font-medium">
                Pricing
              </Link>
              <Link to="/contact" className="text-gray-600 hover:text-blue-600 transition-colors font-medium">
                Contact
              </Link>
            </>
          )}
          
          {user && isStudent() && (
            <>
              <Link to="/dashboard" className="text-gray-600 hover:text-blue-600 transition-colors font-medium">
                Dashboard
              </Link>
              <Link to="/learning" className="text-gray-600 hover:text-blue-600 transition-colors font-medium">
                Learning Hub
              </Link>
              <Link to="/interviews" className="text-gray-600 hover:text-blue-600 transition-colors font-medium">
                My Interviews
              </Link>
              <Link to="/jobs" className="text-gray-600 hover:text-blue-600 transition-colors font-medium">
                Jobs
              </Link>
              <Link to="/interview-resources" className="text-gray-600 hover:text-blue-600 transition-colors font-medium">
                Interview Guides
              </Link>
            </>
          )}
          
          {user && isAdmin() && (
            <>
              <Link to="/admin" className="text-gray-600 hover:text-blue-600 transition-colors font-medium">
                Admin Panel
              </Link>
              <Link to="/admin/user-management" className="text-gray-600 hover:text-blue-600 transition-colors font-medium">
                Manage Users
              </Link>
              <Link to="/admin/courses" className="text-gray-600 hover:text-blue-600 transition-colors font-medium">
                Manage Content
              </Link>
            </>
          )}
        </nav>

        <div className="flex items-center space-x-4">
          <Button
            variant="outline"
            size="sm"
            onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
            className="hidden sm:inline"
          >
            {theme === 'dark' ? 'Light' : 'Dark'} Mode
          </Button>
          {user ? (
            <div className="flex items-center space-x-4">
              <span className="hidden md:inline text-sm font-medium text-gray-700">
                Hello, {profile?.full_name || 'User'}
              </span>
              <Button 
                variant="outline" 
                onClick={handleLogout}
                className="border-gray-300 hover:border-gray-400 hover:bg-gray-50"
              >
                Logout
              </Button>
            </div>
          ) : (
            <div className="flex items-center space-x-3">
              <Link to="/login">
                <Button variant="outline" className="border-gray-300 hover:border-gray-400 hover:bg-gray-50">
                  Sign In
                </Button>
              </Link>
              <Link to="/register">
                <Button className="bg-blue-600 hover:bg-blue-700">
                  Get Started
                </Button>
              </Link>
            </div>
          )}
        </div>
      </div>
    </header>
  );
};

export default Header;
