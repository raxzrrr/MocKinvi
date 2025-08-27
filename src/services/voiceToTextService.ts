import { supabase } from '@/integrations/supabase/client';

export class VoiceRecorder {
  private mediaRecorder: MediaRecorder | null = null;
  private audioChunks: Blob[] = [];
  private stream: MediaStream | null = null;
  private isRecording = false;

  async startRecording(): Promise<void> {
    try {
      console.log('Starting voice recording...');
      
      // Request microphone access
      this.stream = await navigator.mediaDevices.getUserMedia({ 
        audio: {
          sampleRate: 16000,
          channelCount: 1,
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true
        }
      });

      // Create MediaRecorder
      this.mediaRecorder = new MediaRecorder(this.stream, {
        mimeType: 'audio/webm;codecs=opus'
      });

      this.audioChunks = [];
      this.isRecording = true;

      this.mediaRecorder.ondataavailable = (event) => {
        if (event.data.size > 0) {
          this.audioChunks.push(event.data);
        }
      };

      this.mediaRecorder.start(100); // Collect data every 100ms
      console.log('Voice recording started successfully');
      
    } catch (error) {
      console.error('Error starting recording:', error);
      throw new Error('Failed to start recording. Please check microphone permissions.');
    }
  }

  async stopRecording(): Promise<string> {
    return new Promise((resolve, reject) => {
      if (!this.mediaRecorder || !this.isRecording) {
        reject(new Error('No recording in progress'));
        return;
      }

      this.mediaRecorder.onstop = async () => {
        try {
          console.log('Processing recorded audio...');
          
          // Create blob from chunks
          const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' });
          console.log('Audio blob created, size:', audioBlob.size, 'bytes');

          // Convert to base64
          const base64Audio = await this.blobToBase64(audioBlob);
          
          // Clean up
          this.cleanup();
          
          resolve(base64Audio);
        } catch (error) {
          console.error('Error processing recording:', error);
          reject(error);
        }
      };

      this.mediaRecorder.stop();
      this.isRecording = false;
    });
  }

  private async blobToBase64(blob: Blob): Promise<string> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => {
        const result = reader.result as string;
        // Remove the data URL prefix (data:audio/webm;base64,)
        const base64 = result.split(',')[1];
        resolve(base64);
      };
      reader.onerror = reject;
      reader.readAsDataURL(blob);
    });
  }

  private cleanup(): void {
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop());
      this.stream = null;
    }
    this.mediaRecorder = null;
    this.audioChunks = [];
    this.isRecording = false;
  }

  getRecordingState(): boolean {
    return this.isRecording;
  }
}

export class WebSpeechRecognition {
  private recognition: any = null;
  private isListening = false;
  private inactivityTimer: any = null;
  private lastActivity = 0;
  private maxSilenceMs = 3000; // allow up to 5s pauses by default

  constructor() {
    // Check for Web Speech API support
    if ('webkitSpeechRecognition' in window) {
      this.recognition = new (window as any).webkitSpeechRecognition();
    } else if ('SpeechRecognition' in window) {
      this.recognition = new (window as any).SpeechRecognition();
    } else {
      throw new Error('Web Speech API not supported in this browser');
    }

    this.setupRecognition();
  }

  private setupRecognition(): void {
    if (!this.recognition) return;

    // Enable continuous mode with interim results so pauses don't end immediately
    this.recognition.continuous = true;
    this.recognition.interimResults = true;
    this.recognition.lang = 'en-US';
    this.recognition.maxAlternatives = 1;
  }

  startListening(maxSilenceMs?: number): Promise<string> {
    return new Promise((resolve, reject) => {
      if (!this.recognition) {
        reject(new Error('Speech recognition not available'));
        return;
      }

      this.isListening = true;
      let finalTranscript = '';
      if (typeof maxSilenceMs === 'number' && maxSilenceMs > 0) {
        this.maxSilenceMs = maxSilenceMs;
      }
      this.lastActivity = Date.now();

      this.recognition.onstart = () => {
        console.log('Speech recognition started');
      };

      this.recognition.onresult = (event: any) => {
        this.lastActivity = Date.now();
        // Accumulate all final segments
        for (let i = event.resultIndex; i < event.results.length; i++) {
          const res = event.results[i];
          if (res.isFinal) {
            finalTranscript += (finalTranscript ? ' ' : '') + res[0].transcript;
          }
        }
      };

      this.recognition.onend = () => {
        this.isListening = false;
        if (this.inactivityTimer) {
          clearInterval(this.inactivityTimer);
          this.inactivityTimer = null;
        }
        if (finalTranscript.trim()) {
          resolve(finalTranscript);
        } else {
          reject(new Error('No speech detected'));
        }
      };

      this.recognition.onerror = (event: any) => {
        this.isListening = false;
        if (this.inactivityTimer) {
          clearInterval(this.inactivityTimer);
          this.inactivityTimer = null;
        }
        console.error('Speech recognition error:', event.error);
        reject(new Error(`Speech recognition error: ${event.error}`));
      };

      this.recognition.start();

      // Poll for inactivity to stop after long pauses
      this.inactivityTimer = setInterval(() => {
        if (!this.isListening) return;
        const idle = Date.now() - this.lastActivity;
        if (idle > this.maxSilenceMs) {
          try { this.recognition.stop(); } catch {}
        }
      }, 300);
    });
  }

  stopListening(): void {
    if (this.recognition && this.isListening) {
      this.recognition.stop();
      this.isListening = false;
    }
    if (this.inactivityTimer) {
      clearInterval(this.inactivityTimer);
      this.inactivityTimer = null;
    }
  }

  isSupported(): boolean {
    return 'webkitSpeechRecognition' in window || 'SpeechRecognition' in window;
  }
}

export class VoiceToTextService {
  private webSpeechRecognition: WebSpeechRecognition | null = null;

  constructor() {
    try {
      this.webSpeechRecognition = new WebSpeechRecognition();
    } catch (error) {
      console.warn('Web Speech API not available:', error);
      this.webSpeechRecognition = null;
    }
  }

  // Try Web Speech API first, then fallback to Supabase function
  async transcribeAudio(audioBase64: string, language = 'en'): Promise<string> {
    try {
      console.log('Sending audio for transcription...');
      
      const { data, error } = await supabase.functions.invoke('voice-to-text', {
        body: {
          audio: audioBase64,
          language: language
        }
      });

      if (error) {
        console.error('Transcription error:', error);
        // Extract meaningful error message from Supabase error
        const errorMessage = error.message || 'Edge Function returned a non-2xx status code';
        throw new Error(errorMessage);
      }

      if (!data || !data.text) {
        throw new Error('No transcription received');
      }

      console.log('Transcription successful:', data.text);
      return data.text;
      
    } catch (error: any) {
      console.error('Error in transcription service:', error);
      // Provide more specific error messages
      const errorMessage = error.message || 'Unknown error occurred';
      if (errorMessage.includes('status code')) {
        throw new Error('Voice-to-text service temporarily unavailable. Please try again.');
      }
      throw new Error(`Transcription failed: ${errorMessage}`);
    }
  }

  // Use Web Speech API for real-time transcription
  async startRealTimeTranscription(): Promise<string> {
    if (!this.webSpeechRecognition) {
      throw new Error('Web Speech API not supported in this browser');
    }

    try {
      return await this.webSpeechRecognition.startListening();
    } catch (error: any) {
      console.error('Real-time transcription error:', error);
      throw error;
    }
  }

  // Overload allowing custom silence timeout in ms
  async startRealTimeTranscriptionWithSilence(maxSilenceMs: number): Promise<string> {
    if (!this.webSpeechRecognition) {
      throw new Error('Web Speech API not supported in this browser');
    }
    return this.webSpeechRecognition.startListening(maxSilenceMs);
  }

  stopRealTimeTranscription(): void {
    if (this.webSpeechRecognition) {
      this.webSpeechRecognition.stopListening();
    }
  }

  // Check if Web Speech API is available
  isWebSpeechSupported(): boolean {
    return this.webSpeechRecognition !== null;
  }

  // Simplified method - component will handle the recording lifecycle
  async transcribeAudioBlob(audioBlob: Blob, language = 'en'): Promise<string> {
    const base64Audio = await this.blobToBase64(audioBlob);
    return this.transcribeAudio(base64Audio, language);
  }

  private async blobToBase64(blob: Blob): Promise<string> {
    return new Promise((resolve, reject) => {
      const reader = new FileReader();
      reader.onload = () => {
        const result = reader.result as string;
        // Remove the data URL prefix
        const base64 = result.split(',')[1];
        resolve(base64);
      };
      reader.onerror = reject;
      reader.readAsDataURL(blob);
    });
  }
}

export const voiceToTextService = new VoiceToTextService();
export default voiceToTextService;