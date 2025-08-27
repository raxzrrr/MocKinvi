import React from 'react';
import MainLayout from '@/components/Layout/MainLayout';
import { Mail, Phone, MapPin } from 'lucide-react';

const ContactPage = () => {
  return (
    <MainLayout>
      <div className="container mx-auto px-4 py-16">
        {/* Header */}
        <div className="text-center mb-16">
          <h1 className="text-4xl md:text-5xl font-bold text-foreground mb-6">
            Get in <span className="text-primary">Touch</span>
          </h1>
          <p className="text-xl text-muted-foreground max-w-3xl mx-auto">
            Have questions about MockInvi? We're here to help you succeed in your interview preparation journey.
          </p>
        </div>

        <div className="max-w-2xl mx-auto">
          {/* Contact Information */}
          <div className="space-y-8">
            <div>
              <h2 className="text-2xl font-bold text-foreground mb-6">
                Contact Information
              </h2>
              <div className="space-y-6">
                <div className="flex items-start gap-4">
                  <Mail className="w-6 h-6 text-primary mt-1" />
                  <div>
                    <h3 className="font-semibold text-foreground mb-1">Email</h3>
                    <p className="text-muted-foreground">support@mockinvi.com</p>
                    <p className="text-muted-foreground">partnerships@mockinvi.com</p>
                  </div>
                </div>
                
                <div className="flex items-start gap-4">
                  <Phone className="w-6 h-6 text-primary mt-1" />
                  <div>
                    <h3 className="font-semibold text-foreground mb-1">Phone</h3>
                    <p className="text-muted-foreground">+1 (555) 123-4567</p>
                    <p className="text-sm text-muted-foreground">Mon-Fri, 9AM-6PM EST</p>
                  </div>
                </div>
                
                <div className="flex items-start gap-4">
                  <MapPin className="w-6 h-6 text-primary mt-1" />
                  <div>
                    <h3 className="font-semibold text-foreground mb-1">Address</h3>
                    <p className="text-muted-foreground">
                      123 Innovation Drive<br />
                      Tech Park, CA 94107<br />
                      United States
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* FAQ Section */}
        <div className="mt-20">
          <h2 className="text-3xl font-bold text-center text-foreground mb-12">
            Frequently Asked Questions
          </h2>
          <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
            <div>
              <h3 className="text-xl font-semibold text-foreground mb-3">
                How quickly do you respond to inquiries?
              </h3>
              <p className="text-muted-foreground">
                We typically respond to all inquiries within 24 hours during business days. 
                For urgent technical issues, we aim to respond within 4 hours.
              </p>
            </div>
            
            <div>
              <h3 className="text-xl font-semibold text-foreground mb-3">
                Can I schedule a demo call?
              </h3>
              <p className="text-muted-foreground">
                Absolutely! Contact us to schedule a personalized demo of MockInvi's features 
                and see how we can help with your interview preparation.
              </p>
            </div>
            
            <div>
              <h3 className="text-xl font-semibold text-foreground mb-3">
                Do you offer enterprise solutions?
              </h3>
              <p className="text-muted-foreground">
                Yes, we offer customized enterprise solutions for organizations. 
                Contact our partnerships team to discuss your specific needs.
              </p>
            </div>
            
            <div>
              <h3 className="text-xl font-semibold text-foreground mb-3">
                How can I provide feedback?
              </h3>
              <p className="text-muted-foreground">
                We love hearing from our users! Email us directly with your suggestions and feedback.
              </p>
            </div>
          </div>
        </div>
      </div>
    </MainLayout>
  );
};

export default ContactPage;