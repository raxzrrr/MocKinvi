
import React from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { X, Download } from 'lucide-react';

interface Certificate {
  id: string;
  title: string;
  completedDate: string;
  score: number;
  certificateUrl?: string;
}

interface CertificateViewerProps {
  certificate: Certificate;
  userName: string;
  onClose: () => void;
  onDownload: () => void;
}

const CertificateViewer: React.FC<CertificateViewerProps> = ({ 
  certificate, 
  userName, 
  onClose, 
  onDownload 
}) => {
  return (
    <div className="fixed inset-0 bg-black/60 flex items-center justify-center p-4 z-50">
      <Card className="w-full max-w-5xl max-h-[92vh] overflow-auto">
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
          <CardTitle>Certificate Preview</CardTitle>
          <div className="flex gap-2">
            <Button onClick={onDownload} size="sm">
              <Download className="h-4 w-4 mr-2" />
              Download
            </Button>
            <Button onClick={onClose} variant="ghost" size="sm">
              <X className="h-4 w-4" />
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          {/* Branded certificate */}
          <div className="relative overflow-hidden rounded-2xl border shadow-lg bg-gradient-to-br from-white to-blue-50 dark:from-gray-900 dark:to-blue-950 p-10">
            {/* Decorative gradient rings */}
            <div className="pointer-events-none absolute -top-24 -left-24 w-[32rem] h-[32rem] rounded-full bg-gradient-to-br from-blue-500/10 to-purple-500/10 blur-3xl"></div>
            <div className="pointer-events-none absolute -bottom-24 -right-24 w-[28rem] h-[28rem] rounded-full bg-gradient-to-br from-purple-500/10 to-blue-500/10 blur-3xl"></div>

            {/* Header with logo */}
            <div className="flex items-center justify-center gap-3 mb-6">
              <img src="/src/assets/mockinvi-logo.png" alt="MockInvi" className="w-10 h-10 rounded-lg shadow" />
              <span className="text-2xl font-extrabold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">MockInvi</span>
            </div>

            <div className="text-center space-y-6">
              <div className="space-y-3">
                <h1 className="text-4xl font-extrabold text-gray-900 dark:text-gray-100">Certificate of Completion</h1>
                <div className="w-28 h-1.5 bg-gradient-to-r from-blue-600 to-purple-600 mx-auto rounded-full"></div>
              </div>

              <div className="space-y-4">
                <p className="text-lg text-gray-600 dark:text-gray-300">This certifies that</p>
                <p className="text-5xl font-extrabold tracking-tight bg-gradient-to-r from-blue-600 to-indigo-600 bg-clip-text text-transparent">{userName}</p>
                <p className="text-lg text-gray-600 dark:text-gray-300">has successfully completed</p>
                <p className="text-2xl font-bold text-gray-900 dark:text-gray-100">{certificate.title}</p>
              </div>

              <div className="flex flex-wrap justify-center items-center gap-12 pt-6">
                <div className="text-center">
                  <p className="text-sm text-gray-500 dark:text-gray-400">Completion Date</p>
                  <p className="font-semibold text-gray-900 dark:text-gray-100">{certificate.completedDate}</p>
                </div>
                <div className="text-center">
                  <p className="text-sm text-gray-500 dark:text-gray-400">Final Score</p>
                  <p className="font-semibold text-gray-900 dark:text-gray-100">{certificate.score}%</p>
                </div>
                <div className="text-center">
                  <p className="text-sm text-gray-500 dark:text-gray-400">Certificate ID</p>
                  <p className="font-mono text-gray-900 dark:text-gray-100">{certificate.id}</p>
                </div>
              </div>

              <div className="pt-8">
                <div className="inline-block">
                  <div className="w-36 h-36 rounded-full bg-gradient-to-br from-blue-600 to-indigo-600 flex items-center justify-center shadow-xl">
                    <div className="text-white text-center">
                      <div className="text-3xl font-bold">✓</div>
                      <div className="text-xs tracking-wide">CERTIFIED</div>
                    </div>
                  </div>
                </div>
              </div>

              <div className="pt-6 text-xs text-gray-600 dark:text-gray-300 max-w-2xl mx-auto leading-relaxed">
                This certificate is issued by <span className="font-semibold">MockInvi</span> and is valid for verification using the Certificate ID above. No physical signature is required; the document is digitally authorized by MockInvi.
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
};

export default CertificateViewer;
