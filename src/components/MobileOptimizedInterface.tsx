import React, { useState } from 'react';
import { FileText, ArrowLeft, Loader2, CheckCircle, AlertCircle, Send, BarChart3, Pencil, Eye, Download } from 'lucide-react';
import { exportToPDF, exportToWord } from '../utils/exportUtils';
import { ResumeData, UserType } from '../types/resume';
import { ExportOptions, defaultExportOptions } from '../types/export';
import type { OptimizationSessionResult } from '../services/optimizationLoopController';
import ScoreDeltaDisplay from './ScoreDeltaDisplay';
import { Parameter16ScoreDisplay } from './Parameter16ScoreDisplay';

interface Section {
  id: string;
  title: string;
  icon: React.ReactNode;
  component: React.ReactNode;
  resumeData?: ResumeData;
  userType?: UserType;
}

interface MobileOptimizedInterfaceProps {
  sections: Section[];
  onStartNewResume: () => void;
  exportOptions?: ExportOptions;
  jobContext?: {
    jobId?: string;
    roleTitle?: string;
    companyName?: string;
    fromJobApplication?: boolean;
  } | null;
  onApplyNow?: () => void;
  jdOptimizationResult?: OptimizationSessionResult | null;
  parameter16Scores?: {
    beforeScores: any[];
    afterScores: any[];
    overallBefore: number;
    overallAfter: number;
    improvement: number;
  } | null;
  onEditResume?: () => void;
}

export const MobileOptimizedInterface: React.FC<MobileOptimizedInterfaceProps> = ({
  sections,
  onStartNewResume,
  exportOptions = defaultExportOptions,
  jobContext,
  onApplyNow,
  jdOptimizationResult,
  parameter16Scores,
  onEditResume
}) => {
  const hasScores = !!(jdOptimizationResult || parameter16Scores);
  const [activeTab, setActiveTab] = useState<'preview' | 'scores' | 'export'>('preview');
  const [isExportingPDF, setIsExportingPDF] = useState(false);
  const [isExportingWord, setIsExportingWord] = useState(false);
  const [exportStatus, setExportStatus] = useState<{
    type: 'pdf' | 'word' | null;
    status: 'success' | 'error' | null;
    message: string;
  }>({ type: null, status: null, message: '' });

  const resumeSection = sections.find(s => s.id === 'resume');
  const resumeData = resumeSection?.resumeData;
  const userType = resumeSection?.userType || 'experienced';

  const handleExportPDF = async () => {
    if (!resumeData || isExportingPDF || isExportingWord) return;
    
    setIsExportingPDF(true);
    setExportStatus({ type: null, status: null, message: '' });
    
    try {
      await exportToPDF(resumeData, userType, exportOptions);
      setExportStatus({
        type: 'pdf',
        status: 'success',
        message: 'PDF downloaded successfully!'
      });
      setTimeout(() => setExportStatus({ type: null, status: null, message: '' }), 3000);
    } catch (error) {
      setExportStatus({
        type: 'pdf',
        status: 'error',
        message: 'PDF export failed. Please try again.'
      });
      setTimeout(() => setExportStatus({ type: null, status: null, message: '' }), 5000);
    } finally {
      setIsExportingPDF(false);
    }
  };

  const handleExportWord = async () => {
    if (!resumeData || isExportingWord || isExportingPDF) return;
    
    setIsExportingWord(true);
    setExportStatus({ type: null, status: null, message: '' });
    
    try {
      exportToWord(resumeData, userType);
      setExportStatus({
        type: 'word',
        status: 'success',
        message: 'Word document downloaded successfully!'
      });
      setTimeout(() => setExportStatus({ type: null, status: null, message: '' }), 3000);
    } catch (error) {
      setExportStatus({
        type: 'word',
        status: 'error',
        message: 'Word export failed. Please try again.'
      });
      setTimeout(() => setExportStatus({ type: null, status: null, message: '' }), 5000);
    } finally {
      setIsExportingWord(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-slate-900 via-slate-950 to-[#020617] pb-24">
      {/* Header */}
      <div className="bg-slate-900/95 backdrop-blur-xl border-b border-slate-700/50 sticky top-0 z-40">
        <div className="px-4 py-4">
          <button
            onClick={() => {
              if (confirm('Start a new resume? Current progress will be cleared.')) {
                onStartNewResume();
              }
            }}
            className="flex items-center space-x-2 text-slate-300 hover:text-white transition-colors"
            style={{ minHeight: '44px' }}
          >
            <ArrowLeft className="w-5 h-5" />
            <span className="text-base font-medium">Create New Resume</span>
          </button>
        </div>

        {/* Tab Navigation */}
        <div className="flex border-t border-slate-700/50">
          <button
            onClick={() => setActiveTab('preview')}
            className={`flex-1 py-4 text-base font-medium transition-colors ${
              activeTab === 'preview'
                ? 'text-emerald-400 border-b-2 border-emerald-400'
                : 'text-slate-400 hover:text-slate-200'
            }`}
            style={{ minHeight: '44px' }}
          >
            Preview
          </button>
          {hasScores && (
            <button
              onClick={() => setActiveTab('scores')}
              className={`flex-1 py-4 text-base font-medium transition-colors ${
                activeTab === 'scores'
                  ? 'text-emerald-400 border-b-2 border-emerald-400'
                  : 'text-slate-400 hover:text-slate-200'
              }`}
              style={{ minHeight: '44px' }}
            >
              Scores
            </button>
          )}
          <button
            onClick={() => setActiveTab('export')}
            className={`flex-1 py-4 text-base font-medium transition-colors ${
              activeTab === 'export'
                ? 'text-emerald-400 border-b-2 border-emerald-400'
                : 'text-slate-400 hover:text-slate-200'
            }`}
            style={{ minHeight: '44px' }}
          >
            Download
          </button>
        </div>
      </div>

      {/* Content */}
      <div className="px-4 py-6">
        {activeTab === 'scores' && hasScores ? (
          <div className="space-y-4">
            <div className="bg-slate-900/80 backdrop-blur-xl rounded-2xl shadow-lg border border-slate-700/50 p-4">
              <h2 className="text-lg font-bold text-white mb-4 flex items-center">
                <BarChart3 className="w-5 h-5 mr-2 text-emerald-400" />
                Score Improvements
              </h2>
              {jdOptimizationResult ? (
                <ScoreDeltaDisplay
                  result={jdOptimizationResult}
                  userActionCards={jdOptimizationResult.gapClassification.userActionCards}
                />
              ) : parameter16Scores ? (
                <Parameter16ScoreDisplay
                  beforeScores={parameter16Scores.beforeScores}
                  afterScores={parameter16Scores.afterScores}
                  overallBefore={parameter16Scores.overallBefore}
                  overallAfter={parameter16Scores.overallAfter}
                  improvement={parameter16Scores.improvement}
                  compact={true}
                />
              ) : null}
            </div>
          </div>
        ) : activeTab === 'preview' ? (
          <div className="bg-slate-900/80 backdrop-blur-xl rounded-2xl shadow-lg border border-slate-700/50 p-3 sm:p-4">
            <h2 className="text-lg sm:text-xl font-bold text-white mb-3 sm:mb-4 flex items-center">
              <FileText className="w-5 h-5 sm:w-6 sm:h-6 mr-2 text-emerald-400" />
              Your Optimized Resume
            </h2>
            {/* Mobile-optimized resume preview - matches desktop view exactly */}
            <div 
              className="relative w-full bg-slate-800/50 rounded-xl overflow-hidden border border-slate-600/50"
              style={{ 
                height: 'calc(100vh - 260px)',
                minHeight: '500px'
              }}
            >
              {/* Scrollable container with pinch-zoom support */}
              <div 
                className="w-full h-full overflow-auto flex items-start justify-center p-4"
                style={{
                  WebkitOverflowScrolling: 'touch'
                }}
              >
                {/* Resume container - scaled to fit mobile like desktop */}
                <div 
                  className="transform-gpu"
                  style={{
                    transform: 'scale(0.45)',
                    transformOrigin: 'top center',
                    minWidth: '210mm' // A4 width to match desktop
                  }}
                >
                  {resumeSection?.component}
                </div>
              </div>
            </div>
            <p className="text-xs text-slate-400 text-center mt-2 sm:mt-3">
              Scroll to view full resume
            </p>
          </div>
        ) : (
          <div className="space-y-6">
            {/* Success Message */}
            <div className="bg-gradient-to-r from-emerald-900/30 to-green-900/30 rounded-2xl p-6 border border-emerald-500/30">
              <div className="flex items-start space-x-4">
                <div className="flex-shrink-0 w-12 h-12 bg-gradient-to-r from-emerald-500 to-green-500 rounded-full flex items-center justify-center shadow-lg shadow-emerald-500/20">
                  <CheckCircle className="w-6 h-6 text-white" />
                </div>
                <div className="flex-1">
                  <h3 className="text-lg font-bold text-white mb-1">
                    Resume Ready!
                  </h3>
                  <p className="text-base text-slate-300">
                    {jobContext?.fromJobApplication && jobContext?.roleTitle
                      ? `Optimized for ${jobContext.roleTitle}${jobContext.companyName ? ` at ${jobContext.companyName}` : ''}`
                      : 'Your resume has been optimized and is ready to download.'}
                  </p>
                </div>
              </div>

              {jobContext?.fromJobApplication && onApplyNow && (
                <button
                  onClick={onApplyNow}
                  className="w-full mt-4 bg-gradient-to-r from-emerald-600 to-cyan-600 hover:from-emerald-500 hover:to-cyan-500 text-white font-bold py-4 px-6 rounded-xl transition-all duration-300 flex items-center justify-center space-x-3 shadow-lg shadow-emerald-500/20"
                  style={{ minHeight: '56px', fontSize: '18px' }}
                >
                  <Send className="w-6 h-6" />
                  <span>Apply Now</span>
                </button>
              )}
            </div>

            {/* Action Buttons - Edit & Export */}
            {onEditResume && (
              <button
                onClick={onEditResume}
                className="w-full flex items-center justify-center gap-3 px-6 py-4 bg-slate-800/80 hover:bg-slate-700/80 border border-slate-600/50 hover:border-emerald-500/30 text-white font-semibold rounded-xl transition-all duration-300"
                style={{ minHeight: '52px', fontSize: '16px' }}
              >
                <Pencil className="w-5 h-5 text-emerald-400" />
                <span>Edit Resume</span>
              </button>
            )}

            {/* Download Buttons */}
            <div className="space-y-4">
              <div className="bg-slate-900/80 backdrop-blur-xl rounded-2xl p-6 shadow-lg border border-slate-700/50">
                <h3 className="text-lg font-semibold text-white mb-4 flex items-center gap-2">
                  <Download className="w-5 h-5 text-emerald-400" />
                  Export Resume
                </h3>

                <button
                  onClick={handleExportPDF}
                  disabled={isExportingPDF || isExportingWord}
                  className="w-full bg-gradient-to-r from-red-600 to-rose-600 hover:from-red-500 hover:to-rose-500 disabled:from-slate-600 disabled:to-slate-600 text-white font-semibold py-4 px-6 rounded-xl transition-all duration-300 flex items-center justify-center space-x-3 shadow-lg shadow-red-500/20 mb-4"
                  style={{ minHeight: '56px', fontSize: '18px' }}
                >
                  {isExportingPDF ? (
                    <>
                      <Loader2 className="w-6 h-6 animate-spin" />
                      <span>Generating PDF...</span>
                    </>
                  ) : (
                    <>
                      <FileText className="w-6 h-6" />
                      <span>Download PDF</span>
                    </>
                  )}
                </button>

                <button
                  onClick={handleExportWord}
                  disabled={isExportingWord || isExportingPDF}
                  className="w-full bg-gradient-to-r from-blue-600 to-cyan-600 hover:from-blue-500 hover:to-cyan-500 disabled:from-slate-600 disabled:to-slate-600 text-white font-semibold py-4 px-6 rounded-xl transition-all duration-300 flex items-center justify-center space-x-3 shadow-lg shadow-blue-500/20"
                  style={{ minHeight: '56px', fontSize: '18px' }}
                >
                  {isExportingWord ? (
                    <>
                      <Loader2 className="w-6 h-6 animate-spin" />
                      <span>Generating Word...</span>
                    </>
                  ) : (
                    <>
                      <FileText className="w-6 h-6" />
                      <span>Download Word</span>
                    </>
                  )}
                </button>
              </div>

              {exportStatus.status && (
                <div className={`p-4 rounded-xl border ${
                  exportStatus.status === 'success'
                    ? 'bg-emerald-900/30 border-emerald-500/30'
                    : 'bg-red-900/30 border-red-500/30'
                }`}>
                  <div className="flex items-center space-x-3">
                    {exportStatus.status === 'success' ? (
                      <CheckCircle className="w-6 h-6 text-emerald-400 flex-shrink-0" />
                    ) : (
                      <AlertCircle className="w-6 h-6 text-red-400 flex-shrink-0" />
                    )}
                    <span className={`text-base font-medium ${
                      exportStatus.status === 'success'
                        ? 'text-emerald-300'
                        : 'text-red-300'
                    }`}>
                      {exportStatus.message}
                    </span>
                  </div>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};
