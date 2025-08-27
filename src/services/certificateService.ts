
import jsPDF from 'jspdf';

export interface CertificateData {
  userName: string;
  certificateTitle: string;
  completionDate: string;
  score?: number;
  verificationCode: string;
}

interface InterviewReportData {
  userName: string;
  interviewType: string;
  completionDate: string;
  overallScore: number;
  grade: string;
  totalQuestions: number;
  questions: string[];
  answers: string[];
  evaluations: any[];
  idealAnswers?: string[];
}

const loadImage = (src: string): Promise<HTMLImageElement> => {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.crossOrigin = 'anonymous';
    img.onload = () => resolve(img);
    img.onerror = reject;
    img.src = src;
  });
};

export const generateCertificatePDF = async (data: CertificateData): Promise<jsPDF> => {
  const pdf = new jsPDF({ orientation: 'landscape', unit: 'mm', format: 'a4' });

  // Dimensions
  const width = 297; const height = 210; const cx = width / 2;

  // Soft background
  pdf.setFillColor(245, 248, 255);
  pdf.rect(0, 0, width, height, 'F');

  // Outer subtle border
  pdf.setDrawColor(180, 198, 252);
  pdf.setLineWidth(0.8);
  pdf.roundedRect(8, 8, width - 16, height - 16, 4, 4);

  // Header logo + brand
  try {
    const logo = await loadImage('/src/assets/mockinvi-logo.png');
    pdf.addImage(logo, 'PNG', 18, 14, 18, 18);
  } catch {}
  pdf.setFont('helvetica', 'bold');
  pdf.setTextColor(59, 130, 246);
  pdf.setFontSize(20);
  pdf.text('MockInvi', 40, 26);

  // Title
  pdf.setTextColor(23, 37, 84);
  pdf.setFontSize(34);
  pdf.setFont('helvetica', 'bold');
  pdf.text('Certificate of Completion', cx, 60, { align: 'center' });
  pdf.setDrawColor(59,130,246); pdf.setLineWidth(1.5); pdf.line(cx - 40, 66, cx + 40, 66);

  // Body
  pdf.setFont('helvetica', 'normal');
  pdf.setTextColor(71, 85, 105);
  pdf.setFontSize(14);
  pdf.text('This certifies that', cx, 84, { align: 'center' });

  // Name
  pdf.setTextColor(37, 99, 235);
  pdf.setFont('helvetica', 'bold');
  pdf.setFontSize(32);
  pdf.text(data.userName, cx, 100, { align: 'center' });

  // Subtitle
  pdf.setFont('helvetica', 'normal');
  pdf.setTextColor(71, 85, 105);
  pdf.setFontSize(14);
  pdf.text('has successfully completed', cx, 114, { align: 'center' });

  // Course title
  pdf.setFont('helvetica', 'bold');
  pdf.setTextColor(23, 37, 84);
  pdf.setFontSize(22);
  pdf.text(data.certificateTitle, cx, 130, { align: 'center' });

  // Details row
  pdf.setFont('helvetica', 'normal');
  pdf.setTextColor(100, 116, 139);
  pdf.setFontSize(11);
  pdf.text('Completion Date', cx - 45, 148, { align: 'center' });
  pdf.text('Final Score', cx + 45, 148, { align: 'center' });

  pdf.setFont('helvetica', 'bold');
  pdf.setTextColor(15, 23, 42);
  pdf.setFontSize(13);
  pdf.text(data.completionDate, cx - 45, 156, { align: 'center' });
  pdf.text(`${data.score ?? 0}%`, cx + 45, 156, { align: 'center' });

  // Certified seal
  pdf.setDrawColor(59,130,246); pdf.setFillColor(59,130,246);
  pdf.circle(cx, 178, 15, 'FD');
  pdf.setTextColor(255,255,255); pdf.setFontSize(18); pdf.text('✓', cx, 181, { align: 'center' });
  pdf.setFontSize(8); pdf.text('CERTIFIED', cx, 186, { align: 'center' });

  // Footer validity and ID
  pdf.setTextColor(100,116,139);
  pdf.setFont('helvetica', 'normal');
  pdf.setFontSize(9);
  pdf.text(`Certificate ID: ${data.verificationCode}`, 18, height - 12);
  pdf.text('Digitally authorized by MockInvi. No physical signature required. Verify using the ID above.', width - 18, height - 12, { align: 'right' });

  return pdf;
};

export const generateInterviewReportPDF = (data: InterviewReportData): jsPDF => {
  const pdf = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' });

  const pageWidth = 210;
  const pageHeight = 297;
  const margin = 15;
  let yPosition = 20;

  // Helper function to add new page if needed
  const checkPageBreak = (requiredSpace: number) => {
    if (yPosition + requiredSpace > pageHeight - margin) {
      pdf.addPage();
      yPosition = 20;
    }
  };

  // Header
  pdf.setFillColor(59, 130, 246);
  pdf.rect(0, 0, pageWidth, 40, 'F');
  
  pdf.setFontSize(24);
  pdf.setTextColor(255, 255, 255);
  pdf.setFont('helvetica', 'bold');
  pdf.text('Interview Report', pageWidth / 2, 25, { align: 'center' });

  yPosition = 55;

  // User Info
  pdf.setFontSize(16);
  pdf.setTextColor(30, 64, 175);
  pdf.setFont('helvetica', 'bold');
  pdf.text('Candidate Information', margin, yPosition);
  yPosition += 10;

  pdf.setFontSize(12);
  pdf.setTextColor(75, 85, 99);
  pdf.setFont('helvetica', 'normal');
  pdf.text(`Name: ${data.userName}`, margin, yPosition);
  yPosition += 6;
  pdf.text(`Interview Type: ${data.interviewType}`, margin, yPosition);
  yPosition += 6;
  pdf.text(`Date: ${data.completionDate}`, margin, yPosition);
  yPosition += 15;

  // Performance Summary
  pdf.setFontSize(16);
  pdf.setTextColor(30, 64, 175);
  pdf.setFont('helvetica', 'bold');
  pdf.text('Performance Summary', margin, yPosition);
  yPosition += 10;

  // Score box
  pdf.setFillColor(240, 248, 255);
  pdf.rect(margin, yPosition, pageWidth - 2 * margin, 25, 'F');
  pdf.setDrawColor(59, 130, 246);
  pdf.rect(margin, yPosition, pageWidth - 2 * margin, 25);

  pdf.setFontSize(14);
  pdf.setTextColor(30, 64, 175);
  pdf.setFont('helvetica', 'bold');
  pdf.text(`Overall Score: ${data.overallScore.toFixed(1)}/10`, margin + 5, yPosition + 8);
  pdf.text(`Grade: ${data.grade}`, margin + 5, yPosition + 16);
  pdf.text(`Questions Answered: ${data.totalQuestions}`, margin + 80, yPosition + 8);

  yPosition += 35;

  // Detailed Analysis
  pdf.setFontSize(16);
  pdf.setTextColor(30, 64, 175);
  pdf.setFont('helvetica', 'bold');
  pdf.text('Detailed Analysis', margin, yPosition);
  yPosition += 15;

  // Questions and Answers
  data.questions.forEach((question, index) => {
    const evaluation = data.evaluations[index];
    const answer = data.answers[index] || 'No answer provided';
    const idealAnswer = data.idealAnswers?.[index];

    checkPageBreak(40);

    // Question number and text
    pdf.setFontSize(12);
    pdf.setTextColor(30, 64, 175);
    pdf.setFont('helvetica', 'bold');
    pdf.text(`Question ${index + 1}:`, margin, yPosition);
    yPosition += 6;

    pdf.setFontSize(10);
    pdf.setTextColor(75, 85, 99);
    pdf.setFont('helvetica', 'normal');
    const questionLines = pdf.splitTextToSize(question, pageWidth - 2 * margin);
    pdf.text(questionLines, margin, yPosition);
    yPosition += questionLines.length * 4 + 5;

    // User Answer
    pdf.setFontSize(10);
    pdf.setTextColor(30, 64, 175);
    pdf.setFont('helvetica', 'bold');
    pdf.text('Your Answer:', margin, yPosition);
    yPosition += 4;

    pdf.setFontSize(9);
    pdf.setTextColor(75, 85, 99);
    pdf.setFont('helvetica', 'normal');
    const answerLines = pdf.splitTextToSize(answer, pageWidth - 2 * margin);
    pdf.text(answerLines, margin, yPosition);
    yPosition += answerLines.length * 3 + 3;

    // Score
    if (evaluation) {
      pdf.setFontSize(10);
      pdf.setTextColor(30, 64, 175);
      pdf.setFont('helvetica', 'bold');
      pdf.text(`Score: ${evaluation.score || 0}/10`, margin, yPosition);
      yPosition += 6;

      // Score breakdown
      if (evaluation.score_breakdown) {
        const breakdown = evaluation.score_breakdown;
        pdf.setFontSize(8);
        pdf.setTextColor(75, 85, 99);
        pdf.setFont('helvetica', 'normal');
        pdf.text(`Correctness: ${breakdown.correctness || 0}/10  Completeness: ${breakdown.completeness || 0}/10  Depth: ${breakdown.depth || 0}/10  Clarity: ${breakdown.clarity || 0}/10`, margin, yPosition);
        yPosition += 5;
      }

      // Remarks
      if (evaluation.remarks) {
        pdf.setFontSize(9);
        pdf.setTextColor(184, 146, 31);
        pdf.setFont('helvetica', 'italic');
        const remarksLines = pdf.splitTextToSize(`Feedback: ${evaluation.remarks}`, pageWidth - 2 * margin);
        pdf.text(remarksLines, margin, yPosition);
        yPosition += remarksLines.length * 3 + 5;
      }
    }

    // Ideal Answer (if available)
    if (idealAnswer) {
      checkPageBreak(15);
      pdf.setFontSize(10);
      pdf.setTextColor(34, 197, 94);
      pdf.setFont('helvetica', 'bold');
      pdf.text('Ideal Answer:', margin, yPosition);
      yPosition += 4;

      pdf.setFontSize(9);
      pdf.setTextColor(75, 85, 99);
      pdf.setFont('helvetica', 'normal');
      const idealLines = pdf.splitTextToSize(idealAnswer, pageWidth - 2 * margin);
      pdf.text(idealLines, margin, yPosition);
      yPosition += idealLines.length * 3 + 8;
    }

    yPosition += 5;
  });

  // Footer
  const totalPages = pdf.getNumberOfPages();
  for (let i = 1; i <= totalPages; i++) {
    pdf.setPage(i);
    pdf.setFontSize(8);
    pdf.setTextColor(107, 114, 128);
    pdf.setFont('helvetica', 'normal');
    pdf.text(`Page ${i} of ${totalPages}`, pageWidth - margin, pageHeight - 10, { align: 'right' });
    pdf.text('Generated by Interview AI Platform', margin, pageHeight - 10);
  }

  return pdf;
};

export const downloadInterviewReport = (data: InterviewReportData) => {
  const pdf = generateInterviewReportPDF(data);
  const fileName = `Interview_Report_${data.interviewType.replace(/\s+/g, '_')}_${Date.now()}.pdf`;
  pdf.save(fileName);
};

export const downloadCertificate = async (data: CertificateData) => {
  const pdf = await generateCertificatePDF(data);
  const fileName = `${data.certificateTitle.replace(/\s+/g, '_')}_${data.verificationCode}.pdf`;
  pdf.save(fileName);
};
