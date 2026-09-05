import { useEffect, useState } from "react";
import "./App.css";

const API = "http://127.0.0.1:5000";

function App() {
  const [topics, setTopics] = useState([]);
  const [selectedTopic, setSelectedTopic] = useState(null);
  const [questions, setQuestions] = useState([]);
  const [answers, setAnswers] = useState({});
  const [result, setResult] = useState(null);
  const [aiNotes, setAiNotes] = useState("");
  const [resources, setResources] = useState([]);
  const [weakTopics, setWeakTopics] = useState([]);
  const [analytics, setAnalytics] = useState(null);

  const [loading, setLoading] = useState(false);
  const [notesLoading, setNotesLoading] = useState(false);
  const [resourcesLoading, setResourcesLoading] = useState(false);
  const [message, setMessage] = useState("");

  // =========================
  // LOAD TOPICS
  // =========================
  const loadTopics = async () => {
    try {
      const response = await fetch(`${API}/topics`);
      const data = await response.json();

      if (Array.isArray(data)) {
        setTopics(data);
      } else {
        setMessage(data.message || "Unable to load topics.");
      }
    } catch (error) {
      console.error("Topics Error:", error);
      setMessage("Unable to connect to LearnRoot backend.");
    }
  };

  // =========================
  // LOAD WEAK TOPICS
  // =========================
  const loadWeakTopics = async () => {
    try {
      const response = await fetch(`${API}/weak-topics`);
      const data = await response.json();

      if (Array.isArray(data)) {
        const uniqueTopics = {};

        data.forEach((topic) => {
          const topicId = topic.topic_id;
          const score = Number(topic.percentage || 0);

          if (
            !uniqueTopics[topicId] ||
            score < Number(uniqueTopics[topicId].percentage)
          ) {
            uniqueTopics[topicId] = {
              ...topic,
              percentage: score,
            };
          }
        });

        const cleanedTopics = Object.values(uniqueTopics);

        cleanedTopics.sort(
          (a, b) =>
            Number(a.percentage) - Number(b.percentage)
        );

        setWeakTopics(cleanedTopics);
      } else {
        setWeakTopics([]);
      }
    } catch (error) {
      console.error("Weak Topics Error:", error);
      setWeakTopics([]);
    }
  };

  // =========================
  // LOAD ANALYTICS
  // =========================
  const loadAnalytics = async () => {
    try {
      const response = await fetch(`${API}/analytics`);
      const data = await response.json();

      if (data.status === "success") {
        setAnalytics(data);
      }
    } catch (error) {
      console.error("Analytics Error:", error);
    }
  };

  useEffect(() => {
    loadTopics();
    loadWeakTopics();
    loadAnalytics();
  }, []);

  // =========================
  // LOAD RESOURCES
  // =========================
  const loadResources = async (topicId) => {
    try {
      setResourcesLoading(true);

      const response = await fetch(
        `${API}/recommendations/${topicId}`
      );

      const data = await response.json();

      console.log("Database Resources:", data);

      if (
        response.ok &&
        data.status === "success" &&
        Array.isArray(data.resources)
      ) {
        setResources(data.resources);
      } else {
        setResources([]);
      }
    } catch (error) {
      console.error("Resources Error:", error);
      setResources([]);
    } finally {
      setResourcesLoading(false);
    }
  };

  // =========================
  // START QUIZ
  // =========================
  const startQuiz = async (topic) => {
    try {
      setLoading(true);
      setMessage("");

      setSelectedTopic(topic);
      setQuestions([]);
      setAnswers({});
      setResult(null);
      setAiNotes("");
      setResources([]);

      await loadResources(topic.topic_id);

      const response = await fetch(
        `${API}/quiz/${topic.topic_id}`
      );

      const data = await response.json();

      if (
        data.status === "success" &&
        Array.isArray(data.questions)
      ) {
        setQuestions(data.questions);
      } else {
        setMessage(
          data.message ||
            "Unable to load quiz questions."
        );
      }
    } catch (error) {
      console.error("Quiz Error:", error);
      setMessage("Unable to load quiz.");
    } finally {
      setLoading(false);
    }
  };

  // =========================
  // SELECT ANSWER
  // =========================
  const selectAnswer = (quizId, answer) => {
    if (result) {
      return;
    }

    setAnswers((previous) => ({
      ...previous,
      [quizId]: answer,
    }));
  };

  // =========================
  // GENERATE SMART NOTES
  // =========================
  const generateAINotes = async (topicId) => {
    try {
      setNotesLoading(true);
      setMessage("");
      setAiNotes("");

      console.log(
        "Requesting Smart Notes for topic:",
        topicId
      );

      const response = await fetch(
        `${API}/ai-notes/${topicId}`
      );

      const data = await response.json();

      console.log("Smart Notes Response:", data);

      if (
        response.ok &&
        data.status === "success" &&
        data.notes
      ) {
        setAiNotes(data.notes);
      } else {
        setMessage(
          data.message ||
            "Unable to load Smart Notes."
        );
      }
    } catch (error) {
      console.error("Smart Notes Error:", error);

      setMessage(
        "Unable to load Smart Notes. Please check the backend and Gemini API."
      );
    } finally {
      setNotesLoading(false);
    }
  };

  // =========================
  // SUBMIT QUIZ
  // =========================
  const submitQuiz = async () => {
    if (!selectedTopic) {
      return;
    }

    if (
      Object.keys(answers).length <
      questions.length
    ) {
      setMessage("Please answer all questions.");
      return;
    }

    try {
      setLoading(true);
      setMessage("");

      const response = await fetch(
        `${API}/submit-quiz`,
        {
          method: "POST",

          headers: {
            "Content-Type": "application/json",
          },

          body: JSON.stringify({
            topic_id: selectedTopic.topic_id,
            answers: answers,
          }),
        }
      );

      const data = await response.json();

      if (data.status === "success") {
        setResult(data);

        await loadResources(
          selectedTopic.topic_id
        );

        await loadTopics();
        await loadWeakTopics();
        await loadAnalytics();
      } else {
        setMessage(
          data.message ||
            "Quiz submission failed."
        );
      }
    } catch (error) {
      console.error("Submit Quiz Error:", error);

      setMessage("Unable to submit quiz.");
    } finally {
      setLoading(false);
    }
  };

  // =========================
  // GET OPTION TEXT
  // =========================
  const getOptionText = (question, option) => {
    if (!question) {
      return "";
    }

    if (option === "A") {
      return question.option_a;
    }

    if (option === "B") {
      return question.option_b;
    }

    if (option === "C") {
      return question.option_c;
    }

    if (option === "D") {
      return question.option_d;
    }

    return "";
  };

  // =========================
  // ANSWER COLOR
  // =========================
  const getAnswerClass = (question, option) => {
    if (!result) {
      return "";
    }

    const studentAnswer =
      answers[question.quiz_id];

    const correctAnswer =
      question.correct_answer;

    if (
      studentAnswer === option &&
      studentAnswer === correctAnswer
    ) {
      return "answer-correct";
    }

    if (
      studentAnswer === option &&
      studentAnswer !== correctAnswer
    ) {
      return "answer-incorrect";
    }

    if (option === correctAnswer) {
      return "answer-correct";
    }

    return "";
  };

  // =========================
  // RENDER SMART NOTES
  // =========================
  const renderAINotes = (notes) => {
    if (!notes) {
      return null;
    }

    const lines = notes.split("\n");

    return lines.map((line, index) => {
      const trimmedLine = line.trim();

      if (!trimmedLine) {
        return (
          <div
            key={index}
            style={{ height: "8px" }}
          />
        );
      }

      if (
        trimmedLine === "---" ||
        trimmedLine === "***" ||
        trimmedLine === "___"
      ) {
        return <hr key={index} />;
      }

      if (trimmedLine.startsWith("# ")) {
        return (
          <h2 key={index}>
            {trimmedLine.substring(2)}
          </h2>
        );
      }

      if (trimmedLine.startsWith("## ")) {
        return (
          <h3 key={index}>
            {trimmedLine.substring(3)}
          </h3>
        );
      }

      if (trimmedLine.startsWith("### ")) {
        return (
          <h4 key={index}>
            {trimmedLine.substring(4)}
          </h4>
        );
      }

      if (/^\d+\.\s/.test(trimmedLine)) {
        return (
          <h3 key={index}>
            {trimmedLine}
          </h3>
        );
      }

      if (
        trimmedLine.startsWith("- ") ||
        trimmedLine.startsWith("* ") ||
        trimmedLine.startsWith("• ")
      ) {
        const bulletText =
          trimmedLine.replace(
            /^[-*•]\s/,
            ""
          );

        return (
          <div
            className="ai-note-bullet"
            key={index}
          >
            <span>•</span>
            <span>{bulletText}</span>
          </div>
        );
      }

      if (/^\d+\)\s/.test(trimmedLine)) {
        return (
          <p key={index}>
            {trimmedLine}
          </p>
        );
      }

      const formattedText =
        trimmedLine.replace(
          /\*\*(.*?)\*\*/g,
          "$1"
        );

      const cleanText =
        formattedText.replace(
          /`([^`]+)`/g,
          "$1"
        );

      return (
        <p key={index}>
          {cleanText}
        </p>
      );
    });
  };

  // =========================
  // RESOURCE ICON
  // =========================
  const getResourceIcon = (type) => {
    if (!type) {
      return "📚";
    }

    const resourceType =
      String(type).toLowerCase();

    if (
      resourceType.includes("video")
    ) {
      return "🎥";
    }

    if (
      resourceType.includes("note")
    ) {
      return "📖";
    }

    if (
      resourceType.includes("pdf")
    ) {
      return "📄";
    }

    if (
      resourceType.includes("link")
    ) {
      return "🔗";
    }

    if (
      resourceType.includes("book")
    ) {
      return "📚";
    }

    return "📘";
  };

  // =========================
  // GO HOME
  // =========================
  const goHome = () => {
    setSelectedTopic(null);
    setQuestions([]);
    setAnswers({});
    setResult(null);
    setResources([]);
    setAiNotes("");
    setMessage("");
    setNotesLoading(false);
    setResourcesLoading(false);

    loadTopics();
    loadWeakTopics();
    loadAnalytics();
  };

  // =========================
  // GROUP TOPICS
  // =========================
  const groupedTopics = topics.reduce(
    (groups, topic) => {
      if (!groups[topic.subject]) {
        groups[topic.subject] = [];
      }

      groups[topic.subject].push(topic);

      return groups;
    },
    {}
  );

  // =========================
  // FILTER VIDEO RESOURCES
  // =========================
  const videoResources = resources.filter(
    (resource) => {
      const type = String(
        resource.resource_type ||
          resource.type ||
          ""
      ).toLowerCase();

      return type === "video";
    }
  );

  // =========================================================
  // HOME PAGE
  // =========================================================

  if (!selectedTopic) {
    return (
      <div className="app">

        <header className="header">
          <div>
            <h1>🌱 LearnRoot</h1>

            <p>
              Learn Smart. Learn at
              Your Own Pace.
            </p>
          </div>
        </header>

        <main className="container">

          {message && (
            <div className="message">
              {message}
            </div>
          )}

          <section className="welcome">

            <h2>
              📚 Your Learning Path
            </h2>

            <p>
              Select any topic and start
              learning. All topics are
              available.
            </p>

          </section>

          {/* ANALYTICS */}

          {analytics && (
            <section className="analytics-section">

              <h2>
                📊 Learning Analytics
              </h2>

              <p className="section-description">
                Track your overall learning
                performance.
              </p>

              <div className="analytics-grid">

                <div className="analytics-card">

                  <div className="analytics-icon">
                    📝
                  </div>

                  <h3>
                    Total Attempts
                  </h3>

                  <div className="analytics-value">
                    {analytics.total_attempts}
                  </div>

                  <p>
                    Quiz attempts completed
                  </p>

                </div>

                <div className="analytics-card">

                  <div className="analytics-icon">
                    📈
                  </div>

                  <h3>
                    Average Score
                  </h3>

                  <div className="analytics-value">
                    {analytics.average_score}%
                  </div>

                  <p>
                    Overall quiz average
                  </p>

                </div>

                <div className="analytics-card">

                  <div className="analytics-icon">
                    🏆
                  </div>

                  <h3>
                    Best Score
                  </h3>

                  <div className="analytics-value">
                    {analytics.best_score}%
                  </div>

                  <p>
                    Highest quiz score
                  </p>

                </div>

                <div className="analytics-card">

                  <div className="analytics-icon">
                    ✅
                  </div>

                  <h3>
                    Completed Topics
                  </h3>

                  <div className="analytics-value">
                    {analytics.completed_topics}
                    {" / "}
                    {analytics.total_topics}
                  </div>

                  <p>
                    Topics completed
                  </p>

                </div>

              </div>

              <div className="overall-progress-card">

                <div className="overall-progress-header">

                  <h3>
                    Overall Learning Progress
                  </h3>

                  <strong>
                    {analytics.overall_progress}%
                  </strong>

                </div>

                <div className="progress-bar-background">

                  <div
                    className="progress-bar-fill"
                    style={{
                      width: `${analytics.overall_progress}%`,
                    }}
                  />

                </div>

                <p>
                  Keep completing quizzes
                  to improve your learning
                  progress.
                </p>

              </div>

            </section>
          )}

          {/* WEAK TOPICS */}

          {weakTopics.length > 0 && (
            <section className="weak-section">

              <div className="weak-header">

                <div className="weak-header-content">

                  <span className="weak-label">
                    LEARNING FOCUS
                  </span>

                  <h2>
                    Topics That Need
                    Your Attention
                  </h2>

                  <p>
                    Strengthen these concepts
                    and improve your quiz
                    performance.
                  </p>

                </div>

                <div className="weak-count">

                  <strong>
                    {weakTopics.length}
                  </strong>

                  <span>
                    {weakTopics.length === 1
                      ? "Topic"
                      : "Topics"}
                  </span>

                </div>

              </div>

              <div className="weak-grid">

                {weakTopics.map((topic) => {

                  const selected =
                    topics.find(
                      (item) =>
                        item.topic_id ===
                        topic.topic_id
                    );

                  const score =
                    Math.max(
                      0,
                      Math.min(
                        Number(
                          topic.percentage || 0
                        ),
                        100
                      )
                    );

                  return (
                    <div
                      className="weak-card"
                      key={topic.topic_id}
                    >

                      <div className="weak-card-top">

                        <span className="weak-subject">
                          {topic.subject}
                        </span>

                        <span className="needs-practice">
                          Needs Practice
                        </span>

                      </div>

                      <h3>
                        {topic.topic_name}
                      </h3>

                      <div className="weak-score-area">

                        <div
                          className="score-circle"
                          style={{
                            "--score": score,
                          }}
                        >

                          <div className="score-circle-inner">
                            {score.toFixed(0)}%
                          </div>

                        </div>

                        <div className="score-info">

                          <span>
                            Latest Performance
                          </span>

                          <strong>
                            {score.toFixed(2)}%
                          </strong>

                          <small>
                            Keep practicing
                            to improve
                          </small>

                        </div>

                      </div>

                      <button
                        className="review-button"
                        onClick={() => {
                          if (selected) {
                            startQuiz(selected);
                          } else {
                            setMessage(
                              "Topic information not found."
                            );
                          }
                        }}
                      >

                        <span>
                          Review Topic
                        </span>

                        <span className="review-arrow">
                          →
                        </span>

                      </button>

                    </div>
                  );
                })}

              </div>

            </section>
          )}

          {weakTopics.length === 0 && (
            <section className="no-weak-section">

              <div className="no-weak-icon">
                🎯
              </div>

              <div>

                <h3>
                  You're Doing Great!
                </h3>

                <p>
                  No topics currently need
                  improvement. Keep completing
                  quizzes to track your progress.
                </p>

              </div>

            </section>
          )}

          {/* SUBJECTS AND TOPICS */}

          {Object.keys(groupedTopics).map(
            (subject) => (
              <section
                className="subject-section"
                key={subject}
              >

                <div className="subject-title">

                  <h2>
                    {subject}
                  </h2>

                </div>

                <div className="topic-grid">

                  {groupedTopics[subject].map(
                    (topic) => (

                      <div
                        className="topic-card unlocked"
                        key={topic.topic_id}
                      >

                        <div className="topic-number">
                          Topic{" "}
                          {topic.topic_order}
                        </div>

                        <h3>
                          📖{" "}
                          {topic.topic_name}
                        </h3>

                        <div className="topic-status">
                          {topic.completed
                            ? "✅ Completed"
                            : "📚 Available"}
                        </div>

                        <button
                          onClick={() =>
                            startQuiz(topic)
                          }
                        >
                          Start Quiz →
                        </button>

                      </div>

                    )
                  )}

                </div>

              </section>
            )
          )}

        </main>

        <footer>

          <p>
            🌱 LearnRoot — Your Personalized
            Learning Platform
          </p>

        </footer>

      </div>
    );
  }

  // =========================================================
  // QUIZ PAGE
  // =========================================================

  if (!result) {
    return (
      <div className="app">

        <header className="header">

          <h1>
            🌱 LearnRoot
          </h1>

        </header>

        <main className="container">

          <button
            className="back-button"
            onClick={goHome}
          >
            ← Back to Topics
          </button>

          <section className="quiz-section">

            <div className="quiz-header">

              <span>
                {selectedTopic.subject}
              </span>

              <h2>
                {selectedTopic.topic_name}
              </h2>

              <p>
                Answer all questions and
                submit your quiz.
              </p>

              <div className="quiz-info">
                📝 {questions.length} Questions
                {" • "}
                🎯 Easy + Moderate + Hard
              </div>

            </div>

            {message && (
              <div className="message">
                {message}
              </div>
            )}

            {loading && (
              <div className="message">
                🤖 Generating your AI quiz...
              </div>
            )}

            {!loading &&
              questions.length === 0 && (
                <div className="message">
                  No questions found.
                  Please check your backend
                  and Gemini API.
                </div>
              )}

            {!loading &&
              questions.map(
                (question, index) => (
                  <div
                    className="question-card"
                    key={question.quiz_id}
                  >

                    <h3>
                      Q{index + 1}.{" "}
                      {question.question}
                    </h3>

                    {question.difficulty && (
                      <span
                        className={`difficulty-badge ${String(
                          question.difficulty
                        ).toLowerCase()}`}
                      >
                        {question.difficulty}
                      </span>
                    )}

                    <label
                      className={getAnswerClass(
                        question,
                        "A"
                      )}
                    >

                      <input
                        type="radio"
                        name={`question-${question.quiz_id}`}
                        checked={
                          answers[
                            question.quiz_id
                          ] === "A"
                        }
                        onChange={() =>
                          selectAnswer(
                            question.quiz_id,
                            "A"
                          )
                        }
                      />

                      <span>
                        A. {question.option_a}
                      </span>

                    </label>

                    <label
                      className={getAnswerClass(
                        question,
                        "B"
                      )}
                    >

                      <input
                        type="radio"
                        name={`question-${question.quiz_id}`}
                        checked={
                          answers[
                            question.quiz_id
                          ] === "B"
                        }
                        onChange={() =>
                          selectAnswer(
                            question.quiz_id,
                            "B"
                          )
                        }
                      />

                      <span>
                        B. {question.option_b}
                      </span>

                    </label>

                    <label
                      className={getAnswerClass(
                        question,
                        "C"
                      )}
                    >

                      <input
                        type="radio"
                        name={`question-${question.quiz_id}`}
                        checked={
                          answers[
                            question.quiz_id
                          ] === "C"
                        }
                        onChange={() =>
                          selectAnswer(
                            question.quiz_id,
                            "C"
                          )
                        }
                      />

                      <span>
                        C. {question.option_c}
                      </span>

                    </label>

                    <label
                      className={getAnswerClass(
                        question,
                        "D"
                      )}
                    >

                      <input
                        type="radio"
                        name={`question-${question.quiz_id}`}
                        checked={
                          answers[
                            question.quiz_id
                          ] === "D"
                        }
                        onChange={() =>
                          selectAnswer(
                            question.quiz_id,
                            "D"
                          )
                        }
                      />

                      <span>
                        D. {question.option_d}
                      </span>

                    </label>

                  </div>
                )
              )}

            {!loading &&
              questions.length > 0 && (
                <button
                  className="submit-button"
                  onClick={submitQuiz}
                  disabled={loading}
                >
                  {loading
                    ? "Submitting..."
                    : "Submit Quiz"}
                </button>
              )}

          </section>

        </main>

      </div>
    );
  }

  // =========================================================
  // RESULT PAGE
  // =========================================================

  return (
    <div className="app">

      <header className="header">

        <h1>
          🌱 LearnRoot
        </h1>

      </header>

      <main className="container">

        <section className="result-section">

          {/* SCORE */}

          <div className="result-card">

            <h2>
              🎉 Quiz Completed!
            </h2>

            <div className="score">
              {result.percentage}%
            </div>

            <p>
              Score:{" "}
              <strong>
                {result.score} /{" "}
                {result.total_questions}
              </strong>
            </p>

            {result.percentage < 50 && (
              <p>
                📖 Keep practicing!
                Use the Smart Notes
                below to strengthen your
                understanding.
              </p>
            )}

            {result.percentage >= 50 &&
              result.percentage < 80 && (
                <p>
                  👍 Good job!
                  Use the Smart Notes below
                  for improvement.
                </p>
              )}

            {result.percentage >= 80 && (
              <p>
                🌟 Excellent performance!
                Use the Smart Notes for
                quick revision.
              </p>
            )}

          </div>

          {/* QUIZ REVIEW */}

          {result.solutions &&
            result.solutions.length > 0 && (

              <section className="solutions-section">

                <h2>
                  📝 Quiz Review
                </h2>

                <p className="section-description">
                  Review your answers and
                  correct solutions.
                </p>

                {result.solutions.map(
                  (solution, index) => {

                    const currentQuestion =
                      questions.find(
                        (q) =>
                          Number(q.quiz_id) ===
                          Number(solution.quiz_id)
                      );

                    return (
                      <div
                        className={`solution-card ${
                          solution.is_correct
                            ? "solution-correct"
                            : "solution-incorrect"
                        }`}
                        key={
                          solution.quiz_id ||
                          index
                        }
                      >

                        <h3>
                          Q{index + 1}.{" "}
                          {solution.question}
                        </h3>

                        <p>
                          <strong>
                            Your Answer:
                          </strong>{" "}

                          {solution.student_answer
                            ? getOptionText(
                                currentQuestion,
                                solution.student_answer
                              )
                            : "Not answered"}
                        </p>

                        <p>
                          <strong>
                            Correct Answer:
                          </strong>{" "}

                          {getOptionText(
                            currentQuestion,
                            solution.correct_answer
                          )}
                        </p>

                        {solution.solution && (
                          <p>
                            <strong>
                              Explanation:
                            </strong>{" "}

                            {solution.solution}
                          </p>
                        )}

                      </div>
                    );
                  }
                )}

              </section>
            )}

          {/* =================================================
              SMART NOTES + VIDEO RESOURCES
          ================================================= */}

          <div className="learning-area">

            {/* SMART NOTES */}

            <div className="learning-column">

              <div className="learning-heading">

                <h2>
                  🤖 Smart Notes
                </h2>

                <p>
                  AI-powered study notes for
                  your selected topic.
                </p>

              </div>

              <div className="ai-learning-card">

                {!aiNotes ? (

                  <div className="ai-empty-state">

                    <div className="ai-icon">
                      ✨
                    </div>

                    <h2>
                      Smart Notes
                    </h2>

                    <p>
                      Get clear and useful
                      study notes for this
                      topic using Gemini AI.
                    </p>

                    <button
                      className="primary-btn"
                      onClick={() =>
                        generateAINotes(
                          selectedTopic.topic_id
                        )
                      }
                      disabled={notesLoading}
                    >
                      🤖{" "}
                      {notesLoading
                        ? "Loading..."
                        : "View Smart Notes"}
                    </button>

                  </div>

                ) : (

                  <div className="ai-notes-content">

                    {renderAINotes(aiNotes)}

                  </div>

                )}

              </div>

            </div>

            {/* VIDEO RESOURCES */}

            <div className="learning-column">

              <div className="learning-heading">

                <h2>
                  🎥 Video Resources
                </h2>

                <p>
                  Watch videos to better understand
                  this topic.
                </p>

              </div>

              <div className="video-learning-card">

                <div className="video-visual">

                  <div className="video-circle">
                    🎬
                  </div>

                  <h3>
                    Learn Through Video
                  </h3>

                  <p>
                    Visual explanations can make
                    difficult concepts easier to understand.
                  </p>

                </div>

                <div className="video-list">

                  {resourcesLoading && (
                    <div className="video-empty-state">

                      <span>🎥</span>

                      <p>
                        Loading video resources...
                      </p>

                    </div>
                  )}

                  {!resourcesLoading &&
                    videoResources.length === 0 && (

                      <div className="video-empty-state">

                        <div className="video-empty-icon">
                          🎥
                        </div>

                        <h3>
                          No Videos Available
                        </h3>

                        <p>
                          Video resources for this
                          topic are not available yet.
                        </p>

                      </div>

                    )}

                  {!resourcesLoading &&
                    videoResources.map(
                      (resource, index) => {

                        const videoLink =
                          resource.resource_link ||
                          resource.url ||
                          resource.link ||
                          "";

                        return (
                          <div
                            className="video-resource-item"
                            key={
                              resource.resource_id ||
                              resource.id ||
                              index
                            }
                          >

                            <div className="video-resource-icon">
                              {getResourceIcon(
                                resource.resource_type ||
                                  resource.type
                              )}
                            </div>

                            <div className="video-resource-info">

                              <span>
                                VIDEO
                              </span>

                              <h3>
                                {resource.title}
                              </h3>

                              {videoLink && (
                                <a
                                  href={videoLink}
                                  target="_blank"
                                  rel="noreferrer"
                                >
                                  Open Video →
                                </a>
                              )}

                            </div>

                          </div>
                        );
                      }
                    )}

                </div>

                {videoResources.length > 0 && (
                  <button
                    className="video-view-btn"
                    onClick={() => {

                      const video =
                        videoResources[0];

                      const videoLink =
                        video?.resource_link ||
                        video?.url ||
                        video?.link ||
                        "";

                      if (videoLink) {
                        window.open(
                          videoLink,
                          "_blank"
                        );
                      }

                    }}
                  >
                    🎥 View Videos
                  </button>
                )}

              </div>

            </div>

          </div>

          {/* CONTINUE */}

          <div className="continue-learning">

            <button
              className="back-button"
              onClick={goHome}
            >
              ← Continue Learning
            </button>

          </div>

        </section>

      </main>

    </div>
  );
}

export default App;