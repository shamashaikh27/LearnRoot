import { useEffect, useState } from "react";
import "./App.css";

const API = "http://127.0.0.1:5000";

function App() {
  const [topics, setTopics] = useState([]);
  const [selectedTopic, setSelectedTopic] = useState(null);
  const [questions, setQuestions] = useState([]);
  const [answers, setAnswers] = useState({});
  const [result, setResult] = useState(null);
  const [resources, setResources] = useState([]);
  const [weakTopics, setWeakTopics] = useState([]);
  const [analytics, setAnalytics] = useState(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState("");

  // ============================================================
  // LOAD TOPICS
  // ============================================================

  const loadTopics = async () => {
    try {
      const response = await fetch(`${API}/topics`);
      const data = await response.json();

      if (Array.isArray(data)) {
        setTopics(data);
      } else {
        setMessage("Unable to load topics.");
      }
    } catch (error) {
      console.log(error);
      setMessage("Unable to connect to LearnRoot backend.");
    }
  };

  // ============================================================
  // LOAD WEAK TOPICS
  // ============================================================

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
      console.log("Unable to load weak topics.");
      setWeakTopics([]);
    }
  };

  // ============================================================
  // LOAD ANALYTICS
  // ============================================================

  const loadAnalytics = async () => {
    try {
      const response = await fetch(`${API}/analytics`);
      const data = await response.json();

      if (data.status === "success") {
        setAnalytics(data);
      }
    } catch (error) {
      console.log("Unable to load analytics.");
    }
  };

  // ============================================================
  // INITIAL LOAD
  // ============================================================

  useEffect(() => {
    loadTopics();
    loadWeakTopics();
    loadAnalytics();
  }, []);

  // ============================================================
  // START QUIZ
  // ALL TOPICS ARE OPEN
  // ============================================================

  const startQuiz = async (topic) => {
    try {
      setLoading(true);
      setMessage("");

      setSelectedTopic(topic);
      setQuestions([]);
      setAnswers({});
      setResult(null);
      setResources([]);

      const response = await fetch(
        `${API}/quiz/${topic.topic_id}`
      );

      const data = await response.json();

      if (Array.isArray(data)) {
        setQuestions(data);
      } else {
        setMessage(
          data.message || "Unable to load quiz questions."
        );
      }
    } catch (error) {
      console.log(error);
      setMessage("Unable to load quiz.");
    } finally {
      setLoading(false);
    }
  };

  // ============================================================
  // SELECT ANSWER
  // ============================================================

  const selectAnswer = (quizId, answer) => {
    // Do not allow changing answers after quiz is submitted
    if (result) {
      return;
    }

    setAnswers((previous) => ({
      ...previous,
      [quizId]: answer,
    }));
  };

  // ============================================================
  // LOAD RESOURCES
  // RESOURCES ARE ALWAYS AVAILABLE
  // ============================================================

  const loadResources = async (topicId) => {
    try {
      const response = await fetch(
        `${API}/recommendations/${topicId}`
      );

      const data = await response.json();

      if (data.status === "success") {
        setResources(data.resources || []);
      } else {
        setResources([]);
      }
    } catch (error) {
      console.log("Unable to load resources.");
      setResources([]);
    }
  };

  // ============================================================
  // SUBMIT QUIZ
  // ============================================================

  const submitQuiz = async () => {
    if (!selectedTopic) {
      return;
    }

    if (Object.keys(answers).length < questions.length) {
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

        // ======================================================
        // LOAD RESOURCES REGARDLESS OF SCORE
        // ======================================================

        await loadResources(selectedTopic.topic_id);

        // ======================================================
        // REFRESH DASHBOARD
        // ======================================================

        await loadTopics();
        await loadWeakTopics();
        await loadAnalytics();
      } else {
        setMessage(
          data.message || "Quiz submission failed."
        );
      }
    } catch (error) {
      console.log(error);
      setMessage("Unable to submit quiz.");
    } finally {
      setLoading(false);
    }
  };

  // ============================================================
  // GET OPTION TEXT
  // ============================================================

  const getOptionText = (question, option) => {
    if (option === "A") return question.option_a;
    if (option === "B") return question.option_b;
    if (option === "C") return question.option_c;
    if (option === "D") return question.option_d;

    return "";
  };

  // ============================================================
  // GET ANSWER CLASS
  // GREEN = CORRECT
  // RED = INCORRECT
  // ============================================================

  const getAnswerClass = (question, option) => {
    // Before submission
    if (!result) {
      return "";
    }

    const studentAnswer = answers[question.quiz_id];
    const correctAnswer = question.correct_answer;

    // Correct selected answer
    if (
      studentAnswer === option &&
      studentAnswer === correctAnswer
    ) {
      return "answer-correct";
    }

    // Incorrect selected answer
    if (
      studentAnswer === option &&
      studentAnswer !== correctAnswer
    ) {
      return "answer-incorrect";
    }

    // Also show the correct answer in green
    if (option === correctAnswer) {
      return "answer-correct";
    }

    return "";
  };

  // ============================================================
  // BACK TO DASHBOARD
  // ============================================================

  const goHome = () => {
    setSelectedTopic(null);
    setQuestions([]);
    setAnswers({});
    setResult(null);
    setResources([]);
    setMessage("");

    loadTopics();
    loadWeakTopics();
    loadAnalytics();
  };

  // ============================================================
  // GROUP TOPICS BY SUBJECT
  // ============================================================

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

  // ============================================================
  // DASHBOARD
  // ============================================================

  if (!selectedTopic) {
    return (
      <div className="app">

        {/* HEADER */}

        <header className="header">
          <div>
            <h1>🌱 LearnRoot</h1>

            <p>
              Learn Smart. Learn at Your Own Pace.
            </p>
          </div>
        </header>

        <main className="container">

          {/* MESSAGE */}

          {message && (
            <div className="message">
              {message}
            </div>
          )}

          {/* WELCOME */}

          <section className="welcome">

            <h2>
              📚 Your Learning Path
            </h2>

            <p>
              Select any topic and start learning.
              All topics are available.
            </p>

          </section>

          {/* =====================================================
              LEARNING ANALYTICS
          ====================================================== */}

          {analytics && (
            <section className="analytics-section">

              <h2>
                📊 Learning Analytics
              </h2>

              <p className="section-description">
                Track your overall learning performance.
              </p>

              <div className="analytics-grid">

                {/* TOTAL ATTEMPTS */}

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

                {/* AVERAGE SCORE */}

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

                {/* BEST SCORE */}

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

                {/* COMPLETED TOPICS */}

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

              {/* OVERALL PROGRESS */}

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
                  >
                  </div>

                </div>

                <p>
                  Keep completing quizzes to improve
                  your learning progress.
                </p>

              </div>

            </section>
          )}

          {/* =====================================================
              TOPICS TO IMPROVE
          ====================================================== */}

          {weakTopics.length > 0 && (

            <section className="weak-section">

              <div className="weak-header">

                <div className="weak-header-content">

                  <span className="weak-label">
                    LEARNING FOCUS
                  </span>

                  <h2>
                    Topics That Need Your Attention
                  </h2>

                  <p>
                    Strengthen these concepts and improve
                    your quiz performance.
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

                  const selected = topics.find(
                    (item) =>
                      item.topic_id === topic.topic_id
                  );

                  const score = Math.max(
                    0,
                    Math.min(
                      Number(topic.percentage || 0),
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
                            Keep practicing to improve
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

          {/* =====================================================
              NO WEAK TOPICS
          ====================================================== */}

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
                  No topics currently need improvement.
                  Keep completing quizzes to track your progress.
                </p>

              </div>

            </section>
          )}

          {/* =====================================================
              SUBJECTS / LEARNING PATH
          ====================================================== */}

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
                          Topic {topic.topic_order}
                        </div>

                        <h3>
                          📖 {topic.topic_name}
                        </h3>

                        <div className="topic-status">
                          {topic.completed
                            ? "✅ Completed"
                            : "📚 Available"}
                        </div>

                        {/* EVERY TOPIC IS OPEN */}

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

        {/* FOOTER */}

        <footer>

          <p>
            🌱 LearnRoot — Your Personalized Learning Platform
          </p>

        </footer>

      </div>
    );
  }

  // ============================================================
  // QUIZ PAGE
  // ============================================================

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
                Answer all questions and submit your quiz.
              </p>

              <div className="quiz-info">
                📝 {questions.length} Questions
                {" • "}
                🎯 Easy + Moderate + Hard
              </div>

            </div>

            {loading && (

              <div className="message">
                Generating your AI quiz...
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

                    {/* DIFFICULTY */}

                    {question.difficulty && (

                      <span
                        className={`difficulty-badge ${String(
                          question.difficulty
                        ).toLowerCase()}`}
                      >
                        {question.difficulty}
                      </span>

                    )}

                    {/* OPTION A */}

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
                        disabled={!!result}
                      />

                      <span>
                        A. {question.option_a}
                      </span>

                    </label>

                    {/* OPTION B */}

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
                        disabled={!!result}
                      />

                      <span>
                        B. {question.option_b}
                      </span>

                    </label>

                    {/* OPTION C */}

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
                        disabled={!!result}
                      />

                      <span>
                        C. {question.option_c}
                      </span>

                    </label>

                    {/* OPTION D */}

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
                        disabled={!!result}
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

  // ============================================================
  // RESULT PAGE
  // ============================================================

  return (

    <div className="app">

      <header className="header">

        <h1>
          🌱 LearnRoot
        </h1>

      </header>

      <main className="container">

        <section className="result-section">

          {/* ====================================================
              RESULT
          ===================================================== */}

          <div className="result-card">

            <h2>
              🎉 Quiz Completed!
            </h2>

            <div className="score">
              {result.percentage}%
            </div>

            <p>

              Score:

              {" "}

              <strong>
                {result.score} /{" "}
                {result.total_questions}
              </strong>

            </p>

            {result.percentage < 50 && (

              <p>
                📖 Keep practicing! Your learning
                resources are available below.
              </p>

            )}

            {result.percentage >= 50 &&
              result.percentage < 80 && (

                <p>
                  👍 Good job! Keep improving
                  your understanding.
                </p>

              )}

            {result.percentage >= 80 && (

              <p>
                🌟 Excellent performance!
              </p>

            )}

          </div>

          {/* ====================================================
              SOLUTIONS
          ===================================================== */}

          {result.solutions &&
            result.solutions.length > 0 && (

              <section className="solutions-section">

                <h2>
                  📝 Quiz Review
                </h2>

                <p className="section-description">
                  Review your answers and correct solutions.
                </p>

                {result.solutions.map(
                  (solution, index) => (

                    <div
                      className={`solution-card ${
                        solution.student_answer ===
                        solution.correct_answer
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
                        </strong>

                        {" "}

                        {solution.student_answer
                          ? getOptionText(
                              questions[index],
                              solution.student_answer
                            )
                          : "Not answered"}

                      </p>

                      <p>

                        <strong>
                          Correct Answer:
                        </strong>

                        {" "}

                        {getOptionText(
                          questions[index],
                          solution.correct_answer
                        )}

                      </p>

                      {solution.solution && (

                        <p>

                          <strong>
                            Explanation:
                          </strong>

                          {" "}

                          {solution.solution}

                        </p>

                      )}

                    </div>

                  )
                )}

              </section>
            )}

          {/* ====================================================
              LEARNING RESOURCES
              ALWAYS VISIBLE
          ===================================================== */}

          <section className="resources-section">

            <h2>
              📚 AI Learning Resources & Notes
            </h2>

            <p className="section-description">
              These resources are available regardless
              of your quiz score. Use them to strengthen
              your understanding of the topic.
            </p>

            {resources.length === 0 ? (

              <div className="message">
                No resources found for this topic.
              </div>

            ) : (

              <div className="resource-grid">

                {resources.map(
                  (resource) => (

                    <div
                      className="resource-card"
                      key={
                        resource.resource_id
                      }
                    >

                      <div className="resource-icon">

                        {resource.resource_type ===
                        "Video"
                          ? "🎥"
                          : "📖"}

                      </div>

                      <div>

                        <span className="resource-type">

                          {resource.resource_type}

                        </span>

                        <h3>
                          {resource.title}
                        </h3>

                        <a
                          href={
                            resource.resource_link
                          }
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          Open Resource →
                        </a>

                      </div>

                    </div>
                  )
                )}

              </div>
            )}

          </section>

          {/* ====================================================
              CONTINUE
          ===================================================== */}

          <button
            className="continue-button"
            onClick={goHome}
          >
            Continue Learning →
          </button>

        </section>

      </main>

    </div>
  );
}

export default App;