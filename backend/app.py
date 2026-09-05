from flask import Flask, jsonify, request
from flask_cors import CORS
from dotenv import load_dotenv

from db import get_connection
from ai_quiz import generate_quiz
from ai_recommendation import generate_recommendation
from ai_notes import generate_notes

import os


# ============================================================
# FIND LEARNROOT FOLDERS
# ============================================================

BACKEND_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(BACKEND_DIR)


# ============================================================
# LOAD ENVIRONMENT VARIABLES
# ============================================================

ROOT_ENV = os.path.join(ROOT_DIR, ".env")
BACKEND_ENV = os.path.join(BACKEND_DIR, ".env")

if os.path.exists(ROOT_ENV):
    load_dotenv(ROOT_ENV)

if os.path.exists(BACKEND_ENV):
    load_dotenv(BACKEND_ENV, override=True)


# ============================================================
# CREATE FLASK APP
# ============================================================

app = Flask(__name__)

CORS(app)


# ============================================================
# HOME
# ============================================================

@app.route("/", methods=["GET"])
def home():

    return jsonify({
        "status": "success",
        "message": "LearnRoot Backend is Running!"
    })


# ============================================================
# GET ALL TOPICS
# ============================================================

@app.route("/topics", methods=["GET"])
def get_topics():

    connection = None
    cursor = None

    try:

        connection = get_connection()

        if not connection or not connection.is_connected():

            return jsonify({
                "status": "error",
                "message": "Database connection failed."
            }), 500

        cursor = connection.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                topic_id,
                subject,
                topic_name,
                topic_order,
                completed
            FROM topics
            ORDER BY subject, topic_order
        """)

        topics = cursor.fetchall()

        return jsonify(topics)

    except Exception as e:

        print("Topics Error:", str(e))

        return jsonify({
            "status": "error",
            "message": "Unable to load topics."
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# TEST DATABASE
# ============================================================

@app.route("/test-db", methods=["GET"])
def test_db():

    connection = None

    try:

        connection = get_connection()

        if connection and connection.is_connected():

            return jsonify({
                "status": "success",
                "message": "LearnRoot is connected to MySQL!"
            })

        return jsonify({
            "status": "error",
            "message": "Database connection failed."
        }), 500

    except Exception as e:

        print("Database Error:", str(e))

        return jsonify({
            "status": "error",
            "message": "Database connection failed."
        }), 500

    finally:

        if connection:
            connection.close()


# ============================================================
# GET QUIZ BY TOPIC
# ============================================================

@app.route("/quiz/<int:topic_id>", methods=["GET"])
def get_quiz(topic_id):

    connection = None
    cursor = None

    try:

        connection = get_connection()

        if not connection or not connection.is_connected():

            return jsonify({
                "status": "error",
                "message": "Database connection failed."
            }), 500

        cursor = connection.cursor(dictionary=True)

        # ----------------------------------------------------
        # GET TOPIC
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                topic_id,
                subject,
                topic_name
            FROM topics
            WHERE topic_id = %s
        """, (topic_id,))

        topic = cursor.fetchone()

        if not topic:

            return jsonify({
                "status": "error",
                "message": "Topic not found."
            }), 404

        # ----------------------------------------------------
        # CHECK EXISTING QUESTIONS
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                quiz_id,
                topic_id,
                question,
                option_a,
                option_b,
                option_c,
                option_d
            FROM quizzes
            WHERE topic_id = %s
            ORDER BY quiz_id
        """, (topic_id,))

        questions = cursor.fetchall()

        # ----------------------------------------------------
        # RETURN EXISTING QUIZ
        # ----------------------------------------------------

        if questions:

            return jsonify({
                "status": "success",
                "topic_id": topic_id,
                "topic_name": topic["topic_name"],
                "questions": questions
            })

        # ----------------------------------------------------
        # GENERATE NEW QUIZ
        # ----------------------------------------------------

        print("------------------------------------------")
        print("Generating Gemini Quiz")
        print(f"Topic: {topic['topic_name']}")
        print("------------------------------------------")

        try:

            generated_questions = generate_quiz(
                topic["topic_name"]
            )

        except Exception as ai_error:

            print("Gemini Quiz Error:", str(ai_error))

            return jsonify({
                "status": "error",
                "message": "Gemini could not generate the quiz.",
                "details": str(ai_error)
            }), 500

        # ----------------------------------------------------
        # CHECK GENERATED QUESTIONS
        # ----------------------------------------------------

        if not generated_questions:

            return jsonify({
                "status": "error",
                "message": "Gemini returned no quiz questions."
            }), 500

        if not isinstance(generated_questions, list):

            return jsonify({
                "status": "error",
                "message": "Invalid quiz format received from Gemini."
            }), 500

        if len(generated_questions) < 5:

            return jsonify({
                "status": "error",
                "message": (
                    f"Gemini generated only "
                    f"{len(generated_questions)} questions. "
                    f"At least 5 are required."
                )
            }), 500

        # ----------------------------------------------------
        # VALIDATE QUESTIONS
        # ----------------------------------------------------

        required_fields = [
            "question",
            "option_a",
            "option_b",
            "option_c",
            "option_d",
            "correct_answer"
        ]

        valid_questions = []

        for question in generated_questions[:5]:

            if not isinstance(question, dict):
                continue

            missing_fields = [
                field
                for field in required_fields
                if not question.get(field)
            ]

            if missing_fields:

                print(
                    "Skipping invalid question. "
                    f"Missing: {missing_fields}"
                )

                continue

            correct_answer = str(
                question["correct_answer"]
            ).upper().strip()

            if correct_answer not in ["A", "B", "C", "D"]:

                print(
                    "Skipping question with invalid "
                    "correct answer:",
                    correct_answer
                )

                continue

            valid_questions.append({

                "question":
                    str(question["question"]),

                "option_a":
                    str(question["option_a"]),

                "option_b":
                    str(question["option_b"]),

                "option_c":
                    str(question["option_c"]),

                "option_d":
                    str(question["option_d"]),

                "correct_answer":
                    correct_answer,

                "solution":
                    str(question.get("solution", ""))
            })

        # ----------------------------------------------------
        # CHECK VALID QUESTIONS
        # ----------------------------------------------------

        if len(valid_questions) < 5:

            return jsonify({
                "status": "error",
                "message": (
                    "Gemini returned invalid quiz data. "
                    "Please try again."
                )
            }), 500

        # ----------------------------------------------------
        # SAVE QUESTIONS
        # ----------------------------------------------------

        for question in valid_questions:

            cursor.execute("""
                INSERT INTO quizzes
                (
                    topic_id,
                    question,
                    option_a,
                    option_b,
                    option_c,
                    option_d,
                    correct_answer,
                    solution
                )
                VALUES
                (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                topic_id,
                question["question"],
                question["option_a"],
                question["option_b"],
                question["option_c"],
                question["option_d"],
                question["correct_answer"],
                question["solution"]
            ))

        connection.commit()

        # ----------------------------------------------------
        # GET SAVED QUESTIONS
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                quiz_id,
                topic_id,
                question,
                option_a,
                option_b,
                option_c,
                option_d
            FROM quizzes
            WHERE topic_id = %s
            ORDER BY quiz_id
        """, (topic_id,))

        questions = cursor.fetchall()

        return jsonify({
            "status": "success",
            "topic_id": topic_id,
            "topic_name": topic["topic_name"],
            "questions": questions
        })

    except Exception as e:

        print("------------------------------------------")
        print("Quiz Error:")
        print(str(e))
        print("------------------------------------------")

        if connection:
            connection.rollback()

        return jsonify({
            "status": "error",
            "message": "Unable to load quiz.",
            "details": str(e)
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# SUBMIT QUIZ
# ============================================================

@app.route("/submit-quiz", methods=["POST"])
def submit_quiz():

    connection = None
    cursor = None

    try:

        data = request.get_json(silent=True)

        if not data:

            return jsonify({
                "status": "error",
                "message": "No quiz data received."
            }), 400

        topic_id = data.get("topic_id")
        answers = data.get("answers", {})

        if topic_id is None:

            return jsonify({
                "status": "error",
                "message": "topic_id is required."
            }), 400

        if not isinstance(answers, dict):

            return jsonify({
                "status": "error",
                "message": "Answers must be an object."
            }), 400

        connection = get_connection()

        if not connection or not connection.is_connected():

            return jsonify({
                "status": "error",
                "message": "Database connection failed."
            }), 500

        cursor = connection.cursor(dictionary=True)

        # ----------------------------------------------------
        # GET QUESTIONS
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                quiz_id,
                question,
                option_a,
                option_b,
                option_c,
                option_d,
                correct_answer,
                solution
            FROM quizzes
            WHERE topic_id = %s
            ORDER BY quiz_id
        """, (topic_id,))

        questions = cursor.fetchall()

        if not questions:

            return jsonify({
                "status": "error",
                "message": "No quiz questions found."
            }), 404

        # ----------------------------------------------------
        # EVALUATE
        # ----------------------------------------------------

        score = 0
        solutions = []

        for question in questions:

            quiz_id = str(
                question["quiz_id"]
            )

            correct_answer = str(
                question["correct_answer"]
            ).upper().strip()

            student_answer = answers.get(
                quiz_id
            )

            if student_answer is not None:

                student_answer = str(
                    student_answer
                ).upper().strip()

            is_correct = (
                student_answer == correct_answer
            )

            if is_correct:
                score += 1

            solutions.append({

                "quiz_id":
                    question["quiz_id"],

                "question":
                    question["question"],

                "student_answer":
                    student_answer,

                "correct_answer":
                    correct_answer,

                "is_correct":
                    is_correct,

                "solution":
                    question["solution"] or ""
            })

        # ----------------------------------------------------
        # CALCULATE SCORE
        # ----------------------------------------------------

        total_questions = len(questions)

        if total_questions == 0:

            return jsonify({
                "status": "error",
                "message": "Quiz contains no questions."
            }), 400

        percentage = (
            score / total_questions
        ) * 100

        completed = percentage >= 50

        # ----------------------------------------------------
        # STORE QUIZ RESULT
        # ----------------------------------------------------

        cursor.execute("""
            INSERT INTO quiz_results
            (
                topic_id,
                score,
                total_questions,
                percentage
            )
            VALUES
            (%s, %s, %s, %s)
        """, (
            topic_id,
            score,
            total_questions,
            percentage
        ))

        # ----------------------------------------------------
        # CHECK PROGRESS
        # ----------------------------------------------------

        cursor.execute("""
            SELECT *
            FROM progress
            WHERE topic_id = %s
        """, (topic_id,))

        progress = cursor.fetchone()

        # ----------------------------------------------------
        # UPDATE PROGRESS
        # ----------------------------------------------------

        if progress:

            cursor.execute("""
                UPDATE progress
                SET
                    completed = %s,
                    best_score = GREATEST(
                        COALESCE(best_score, 0),
                        %s
                    ),
                    attempts = COALESCE(
                        attempts,
                        0
                    ) + 1,
                    last_attempt = CURRENT_TIMESTAMP
                WHERE topic_id = %s
            """, (
                completed,
                percentage,
                topic_id
            ))

        # ----------------------------------------------------
        # INSERT PROGRESS
        # ----------------------------------------------------

        else:

            cursor.execute("""
                INSERT INTO progress
                (
                    topic_id,
                    completed,
                    best_score,
                    attempts,
                    last_attempt
                )
                VALUES
                (
                    %s,
                    %s,
                    %s,
                    1,
                    CURRENT_TIMESTAMP
                )
            """, (
                topic_id,
                completed,
                percentage
            ))

        # ----------------------------------------------------
        # COMMIT
        # ----------------------------------------------------

        connection.commit()

        return jsonify({

            "status":
                "success",

            "topic_id":
                topic_id,

            "score":
                score,

            "total_questions":
                total_questions,

            "percentage":
                round(percentage, 2),

            "completed":
                completed,

            "solutions":
                solutions,

            "message":
                "Quiz evaluated successfully!"
        })

    except Exception as e:

        print("------------------------------------------")
        print("Submit Quiz Error:")
        print(str(e))
        print("------------------------------------------")

        if connection:
            connection.rollback()

        return jsonify({
            "status": "error",
            "message": "Unable to submit quiz.",
            "details": str(e)
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# GET PROGRESS
# ============================================================

@app.route("/progress", methods=["GET"])
def get_progress():

    connection = None
    cursor = None

    try:

        connection = get_connection()

        cursor = connection.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                t.topic_id,
                t.subject,
                t.topic_name,
                COALESCE(
                    p.completed,
                    0
                ) AS completed,
                COALESCE(
                    p.best_score,
                    0
                ) AS best_score,
                COALESCE(
                    p.attempts,
                    0
                ) AS attempts
            FROM topics t
            LEFT JOIN progress p
                ON t.topic_id = p.topic_id
            ORDER BY
                t.subject,
                t.topic_order
        """)

        progress = cursor.fetchall()

        return jsonify(progress)

    except Exception as e:

        print("Progress Error:", str(e))

        return jsonify({
            "status": "error",
            "message": "Unable to load progress."
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# GET WEAK TOPICS
# ============================================================

@app.route("/weak-topics", methods=["GET"])
def get_weak_topics():

    connection = None
    cursor = None

    try:

        connection = get_connection()

        cursor = connection.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                t.topic_id,
                t.subject,
                t.topic_name,
                MAX(qr.percentage) AS percentage
            FROM quiz_results qr
            JOIN topics t
                ON qr.topic_id = t.topic_id
            GROUP BY
                t.topic_id,
                t.subject,
                t.topic_name,
                t.topic_order
            HAVING
                MAX(qr.percentage) < 50
            ORDER BY
                percentage ASC,
                t.topic_order ASC
        """)

        weak_topics = cursor.fetchall()

        return jsonify(weak_topics)

    except Exception as e:

        print("Weak Topics Error:", str(e))

        return jsonify({
            "status": "error",
            "message": "Unable to load weak topics."
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# DATABASE RESOURCES
# ============================================================

@app.route(
    "/recommendations/<int:topic_id>",
    methods=["GET"]
)
def get_recommendations(topic_id):

    connection = None
    cursor = None

    try:

        connection = get_connection()

        cursor = connection.cursor(dictionary=True)

        # ----------------------------------------------------
        # GET TOPIC
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                topic_id,
                topic_name
            FROM topics
            WHERE topic_id = %s
        """, (topic_id,))

        topic = cursor.fetchone()

        if not topic:

            return jsonify({
                "status": "error",
                "message": "Topic not found."
            }), 404

        # ----------------------------------------------------
        # GET BEST SCORE
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                COALESCE(
                    MAX(percentage),
                    0
                ) AS best_score
            FROM quiz_results
            WHERE topic_id = %s
        """, (topic_id,))

        score_data = cursor.fetchone()

        best_score = float(
            score_data["best_score"] or 0
        )

        # ----------------------------------------------------
        # RECOMMENDATION LEVEL
        # ----------------------------------------------------

        if best_score < 50:

            recommendation_level = "Needs Improvement"

        elif best_score < 80:

            recommendation_level = "Practice"

        else:

            recommendation_level = "Advanced Learning"

        # ----------------------------------------------------
        # GET RESOURCES
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                resource_id,
                topic_id,
                resource_type,
                title,
                resource_link
            FROM resources
            WHERE topic_id = %s
            ORDER BY resource_id
        """, (topic_id,))

        resources = cursor.fetchall()

        return jsonify({

            "status":
                "success",

            "topic_id":
                topic_id,

            "topic_name":
                topic["topic_name"],

            "best_score":
                round(best_score, 2),

            "recommendation_level":
                recommendation_level,

            "resources":
                resources
        })

    except Exception as e:

        print("Resources Error:", str(e))

        return jsonify({
            "status": "error",
            "message": "Unable to load resources."
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# AI SMART RECOMMENDATION
# ============================================================

@app.route(
    "/smart-recommendation/<int:topic_id>",
    methods=["GET"]
)
def smart_recommendation(topic_id):

    connection = None
    cursor = None

    try:

        connection = get_connection()

        cursor = connection.cursor(dictionary=True)

        # ----------------------------------------------------
        # GET TOPIC
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                topic_id,
                topic_name
            FROM topics
            WHERE topic_id = %s
        """, (topic_id,))

        topic = cursor.fetchone()

        if not topic:

            return jsonify({
                "status": "error",
                "message": "Topic not found."
            }), 404

        # ----------------------------------------------------
        # GET BEST SCORE
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                COALESCE(
                    MAX(percentage),
                    0
                ) AS best_score
            FROM quiz_results
            WHERE topic_id = %s
        """, (topic_id,))

        result = cursor.fetchone()

        score = float(
            result["best_score"] or 0
        )

        # ----------------------------------------------------
        # GENERATE AI RECOMMENDATION
        # ----------------------------------------------------

        try:

            recommendation = generate_recommendation(
                topic["topic_name"],
                score
            )

        except Exception as ai_error:

            print(
                "AI Recommendation Error:",
                str(ai_error)
            )

            return jsonify({
                "status": "error",
                "message": "Unable to generate AI recommendation.",
                "details": str(ai_error)
            }), 500

        if not recommendation:

            return jsonify({
                "status": "error",
                "message": "AI returned no recommendation."
            }), 500

        return jsonify({

            "status":
                "success",

            "topic_id":
                topic_id,

            "topic_name":
                topic["topic_name"],

            "score":
                round(score, 2),

            "recommendation":
                recommendation
        })

    except Exception as e:

        print(
            "Smart Recommendation Error:",
            str(e)
        )

        return jsonify({
            "status": "error",
            "message": "Unable to generate recommendation."
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# AI GENERATED NOTES
# ============================================================
#
# COMMON NOTES FOR ALL STUDENTS
#
# Flow:
#
# React requests /ai-notes/<topic_id>
#             ↓
# Flask checks ai_notes table
#             ↓
#       Notes already exist?
#          /          \
#        YES          NO
#         ↓            ↓
#   Return notes     Gemini
#                      ↓
#                 Generate notes
#                      ↓
#                 Save MySQL
#                      ↓
#                 Return notes
#
# ============================================================

@app.route(
    "/ai-notes/<int:topic_id>",
    methods=["GET"]
)
def ai_notes(topic_id):

    connection = None
    cursor = None

    try:

        connection = get_connection()

        if not connection or not connection.is_connected():

            return jsonify({
                "status": "error",
                "message": "Database connection failed."
            }), 500

        cursor = connection.cursor(dictionary=True)

        # ====================================================
        # 1. GET TOPIC
        # ====================================================

        cursor.execute("""
            SELECT
                topic_id,
                subject,
                topic_name
            FROM topics
            WHERE topic_id = %s
        """, (topic_id,))

        topic = cursor.fetchone()

        if not topic:

            return jsonify({
                "status": "error",
                "message": "Topic not found."
            }), 404

        topic_name = topic["topic_name"]

        print("------------------------------------------")
        print("AI NOTES REQUEST")
        print(f"Topic ID: {topic_id}")
        print(f"Topic: {topic_name}")
        print("------------------------------------------")

        # ====================================================
        # 2. CHECK DATABASE FOR EXISTING NOTES
        # ====================================================

        cursor.execute("""
            SELECT
                note_id,
                topic_id,
                notes,
                generated_by,
                created_at,
                updated_at
            FROM ai_notes
            WHERE topic_id = %s
            LIMIT 1
        """, (topic_id,))

        existing_notes = cursor.fetchone()

        # ====================================================
        # 3. NOTES ALREADY EXIST
        # ====================================================

        if existing_notes:

            print("AI notes found in database.")
            print("Returning stored notes.")
            print("------------------------------------------")

            return jsonify({

                "status":
                    "success",

                "topic_id":
                    topic_id,

                "subject":
                    topic["subject"],

                "topic_name":
                    topic_name,

                "notes":
                    existing_notes["notes"],

                "generated_by":
                    existing_notes["generated_by"],

                "source":
                    "database",

                "created_at":
                    existing_notes["created_at"],

                "updated_at":
                    existing_notes["updated_at"]
            })

        # ====================================================
        # 4. NOTES DON'T EXIST
        # ====================================================

        print("No notes found in database.")
        print("Generating notes using Gemini...")

        # IMPORTANT:
        # We do NOT send student score.
        # These notes are COMMON for every student.

        try:

            notes = generate_notes(
                topic_name
            )

        except Exception as ai_error:

            print("------------------------------------------")
            print("Gemini AI Notes Error:")
            print(str(ai_error))
            print("------------------------------------------")

            return jsonify({

                "status":
                    "error",

                "message":
                    "Gemini could not generate AI notes.",

                "details":
                    str(ai_error)
            }), 500

        # ====================================================
        # 5. CHECK GENERATED NOTES
        # ====================================================

        if not notes:

            return jsonify({

                "status":
                    "error",

                "message":
                    "Gemini returned empty notes."
            }), 500

        # ====================================================
        # 6. SAVE NOTES INTO DATABASE
        # ====================================================

        print("Saving AI notes into MySQL...")

        cursor.execute("""
            INSERT INTO ai_notes
            (
                topic_id,
                notes,
                generated_by
            )
            VALUES
            (
                %s,
                %s,
                %s
            )
        """, (
            topic_id,
            notes,
            "Gemini AI"
        ))

        connection.commit()

        print("AI notes successfully saved to database.")

        # ====================================================
        # 7. RETURN NEWLY GENERATED NOTES
        # ====================================================

        return jsonify({

            "status":
                "success",

            "topic_id":
                topic_id,

            "subject":
                topic["subject"],

            "topic_name":
                topic_name,

            "notes":
                notes,

            "generated_by":
                "Gemini AI",

            "source":
                "gemini"
        })

    except Exception as e:

        print("------------------------------------------")
        print("AI Notes Endpoint Error:")
        print(str(e))
        print("------------------------------------------")

        if connection:
            connection.rollback()

        return jsonify({

            "status":
                "error",

            "message":
                "Unable to load AI notes.",

            "details":
                str(e)
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# LEARNING ANALYTICS
# ============================================================

@app.route("/analytics", methods=["GET"])
def get_analytics():

    connection = None
    cursor = None

    try:

        connection = get_connection()

        cursor = connection.cursor(dictionary=True)

        # ----------------------------------------------------
        # TOTAL ATTEMPTS
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                COUNT(*) AS total_attempts
            FROM quiz_results
        """)

        attempts_data = cursor.fetchone()

        total_attempts = (
            attempts_data["total_attempts"] or 0
        )

        # ----------------------------------------------------
        # AVERAGE SCORE
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                AVG(percentage) AS average_score
            FROM quiz_results
        """)

        average_data = cursor.fetchone()

        average_score = float(
            average_data["average_score"] or 0
        )

        # ----------------------------------------------------
        # BEST SCORE
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                MAX(percentage) AS best_score
            FROM quiz_results
        """)

        best_data = cursor.fetchone()

        best_score = float(
            best_data["best_score"] or 0
        )

        # ----------------------------------------------------
        # COMPLETED TOPICS
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                COUNT(*) AS completed_topics
            FROM progress
            WHERE completed = TRUE
        """)

        completed_data = cursor.fetchone()

        completed_topics = (
            completed_data["completed_topics"] or 0
        )

        # ----------------------------------------------------
        # TOTAL TOPICS
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                COUNT(*) AS total_topics
            FROM topics
        """)

        total_data = cursor.fetchone()

        total_topics = (
            total_data["total_topics"] or 0
        )

        # ----------------------------------------------------
        # OVERALL PROGRESS
        # ----------------------------------------------------

        if total_topics > 0:

            overall_progress = (
                completed_topics /
                total_topics
            ) * 100

        else:

            overall_progress = 0

        # ----------------------------------------------------
        # RETURN ANALYTICS
        # ----------------------------------------------------

        return jsonify({

            "status":
                "success",

            "total_attempts":
                total_attempts,

            "average_score":
                round(
                    average_score,
                    2
                ),

            "best_score":
                round(
                    best_score,
                    2
                ),

            "completed_topics":
                completed_topics,

            "total_topics":
                total_topics,

            "overall_progress":
                round(
                    overall_progress,
                    2
                )
        })

    except Exception as e:

        print(
            "Analytics Error:",
            str(e)
        )

        return jsonify({
            "status": "error",
            "message": "Unable to load analytics."
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# ERROR HANDLERS
# ============================================================

@app.errorhandler(404)
def page_not_found(error):

    return jsonify({
        "status": "error",
        "message": "API endpoint not found."
    }), 404


@app.errorhandler(405)
def method_not_allowed(error):

    return jsonify({
        "status": "error",
        "message": "HTTP method not allowed."
    }), 405


@app.errorhandler(500)
def internal_server_error(error):

    return jsonify({
        "status": "error",
        "message": "Internal server error."
    }), 500


# ============================================================
# RUN APPLICATION
# ============================================================

if __name__ == "__main__":

    print("==========================================")
    print("LearnRoot Backend Starting...")
    print("Backend URL: http://127.0.0.1:5000")
    print("AI Notes: /ai-notes/<topic_id>")
    print("Quiz: /quiz/<topic_id>")
    print("==========================================")

    app.run(
        debug=True,
        host="127.0.0.1",
        port=5000
    )