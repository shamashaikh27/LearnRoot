import React from "react";
import ReactMarkdown from "react-markdown";
import remarkMath from "remark-math";
import rehypeKatex from "rehype-katex";
import "katex/dist/katex.min.css";

function AINotes({ notes, topicName, onBack }) {
  // ============================================================
  // NO NOTES AVAILABLE
  // ============================================================

  if (!notes || !notes.trim()) {
    return (
      <div className="container">

        <div className="no-weak-section">

          <div className="no-weak-icon">
            📘
          </div>

          <div>
            <h3>Study Notes Not Available</h3>

            <p>
              Study notes could not be loaded for this topic.
              Please try again.
            </p>
          </div>

        </div>

        <button
          className="back-button"
          onClick={onBack}
        >
          ← Back
        </button>

      </div>
    );
  }

  return (
    <div className="container">

      {/* ========================================================
          BACK BUTTON
      ======================================================== */}

      <button
        className="back-button"
        onClick={onBack}
      >
        ← Back to Topic
      </button>


      {/* ========================================================
          NOTES HEADER
      ======================================================== */}

      <div className="quiz-header">

        <span>
          AI-POWERED STUDY NOTES
        </span>

        <h2>
          📘 {topicName}
        </h2>

        <p>
          Clear and exam-focused study notes for understanding,
          revision, and preparation.
        </p>

      </div>


      {/* ========================================================
          STUDY NOTES
      ======================================================== */}

      <section className="solutions-section">

        <h2>
          📚 Study Notes
        </h2>

        <div className="ai-notes-content">

          <ReactMarkdown
            remarkPlugins={[remarkMath]}
            rehypePlugins={[rehypeKatex]}
          >
            {notes}
          </ReactMarkdown>

        </div>

      </section>


      {/* ========================================================
          QUICK REVISION
      ======================================================== */}

      <div className="weak-section">

        <div className="section-heading">

          <div>

            <h2>
              ⚡ Quick Revision
            </h2>

            <p>
              Revise the important concepts before attempting
              the quiz again.
            </p>

          </div>

        </div>


        <div className="weak-card">

          <h3>
            📌 Remember for {topicName}
          </h3>

          <p>
            Focus on the definitions, important concepts,
            examples, formulas, applications, and exam tips
            provided in the notes above.
          </p>

        </div>

      </div>


      {/* ========================================================
          CONTINUE LEARNING
      ======================================================== */}

      <button
        className="continue-button"
        onClick={onBack}
      >
        Continue Learning →
      </button>

    </div>
  );
}

export default AINotes;