from flask import Flask, jsonify, request
from flask_cors import CORS
from dotenv import load_dotenv

from db import get_connection
from ai_quiz import generate_quiz
from ai_recommendation import generate_recommendation

import os


# ============================================================
# LOAD ENVIRONMENT VARIABLES
# ============================================================

# Find LearnRoot root folder
BASE_DIR = os.path.dirname(
    os.path.dirname(
        os.path.abspath(__file__)
    )
)

# .env is inside LearnRoot
ENV_FILE = os.path.join(
    BASE_DIR,
    ".env"
)

load_dotenv(ENV_FILE)


# ============================================================
# CREATE FLASK APP
# ============================================================

app = Flask(__name__)

CORS(app)


# ============================================================
# HOME
# ============================================================

@app.route("/")
def home():

    return "LearnRoot Backend is Running!"


# ============================================================
# GET ALL TOPICS
#
# All topics are available.
# There is NO LOCK / UNLOCK system.
# ============================================================

@app.route("/topics")
def get_topics():

    connection = None
    cursor = None

    try:

        connection = get_connection()

        cursor = connection.cursor(
            dictionary=True
        )

        cursor.execute("""
            SELECT
                topic_id,
                subject,
                topic_name,
                topic_order,
                completed
            FROM topics
            ORDER BY
                subject,
                topic_order
        """)

        topics = cursor.fetchall()

        return jsonify(topics)

    except Exception as e:

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# TEST DATABASE
# ============================================================

@app.route("/test-db")
def test_db():

    connection = None

    try:

        connection = get_connection()

        if connection.is_connected():

            return jsonify({
                "status": "success",
                "message": "LearnRoot is connected to MySQL!"
            })

        return jsonify({
            "status": "error",
            "message": "Database connection failed."
        }), 500

    except Exception as e:

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

    finally:

        if connection:
            connection.close()


# ============================================================
# GET QUIZ BY TOPIC
#
# If questions already exist:
#     Return existing questions.
#
# If questions do not exist:
#     Generate 5 questions using Gemini.
#
# Gemini:
#     2 Easy
#     2 Moderate
#     1 Hard
# ============================================================

@app.route("/quiz/<int:topic_id>")
def get_quiz(topic_id):

    connection = None
    cursor = None

    try:

        connection = get_connection()

        cursor = connection.cursor(
            dictionary=True
        )

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
        # RETURN EXISTING QUESTIONS
        # ----------------------------------------------------

        if questions:

            return jsonify({
                "status": "success",
                "topic_id": topic_id,
                "topic_name": topic["topic_name"],
                "questions": questions
            })

        # ----------------------------------------------------
        # GENERATE QUIZ USING GEMINI
        # ----------------------------------------------------

        generated_questions = generate_quiz(
            topic["topic_name"]
        )

        if not generated_questions:

            return jsonify({
                "status": "error",
                "message": "Unable to generate quiz questions."
            }), 500

        # ----------------------------------------------------
        # CHECK QUESTION COUNT
        # ----------------------------------------------------

        if len(generated_questions) < 5:

            return jsonify({
                "status": "error",
                "message": "Gemini generated fewer than 5 questions."
            }), 500

        # ----------------------------------------------------
        # SAVE QUESTIONS
        # ----------------------------------------------------

        for question in generated_questions[:5]:

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
                (
                    %s,
                    %s,
                    %s,
                    %s,
                    %s,
                    %s,
                    %s,
                    %s
                )
            """, (
                topic_id,
                question["question"],
                question["option_a"],
                question["option_b"],
                question["option_c"],
                question["option_d"],
                question["correct_answer"],
                question.get("solution", "")
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

        if connection:
            connection.rollback()

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# SUBMIT QUIZ
#
# Correct answer:
#     is_correct = True
#
# Incorrect answer:
#     is_correct = False
#
# Frontend can display:
#     Correct   -> GREEN
#     Incorrect -> RED
#
# Resources are available even if score < 50%.
# ============================================================

@app.route(
    "/submit-quiz",
    methods=["POST"]
)
def submit_quiz():

    connection = None
    cursor = None

    try:

        data = request.get_json()

        if not data:

            return jsonify({
                "status": "error",
                "message": "No data received."
            }), 400

        topic_id = data.get(
            "topic_id"
        )

        answers = data.get(
            "answers",
            {}
        )

        if topic_id is None:

            return jsonify({
                "status": "error",
                "message": "topic_id is required."
            }), 400

        connection = get_connection()

        cursor = connection.cursor(
            dictionary=True
        )

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
                "message": "No quiz questions found for this topic."
            }), 404

        # ----------------------------------------------------
        # EVALUATE ANSWERS
        # ----------------------------------------------------

        score = 0

        solutions = []

        for question in questions:

            quiz_id = str(
                question["quiz_id"]
            )

            correct_answer = str(
                question["correct_answer"]
            ).upper()

            student_answer = answers.get(
                quiz_id
            )

            if student_answer is not None:

                student_answer = str(
                    student_answer
                ).upper()

            # ------------------------------------------------
            # CHECK ANSWER
            # ------------------------------------------------

            is_correct = (
                student_answer ==
                correct_answer
            )

            if is_correct:

                score += 1

            # ------------------------------------------------
            # STORE RESULT
            # ------------------------------------------------

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
                    question["solution"]

            })

        # ----------------------------------------------------
        # CALCULATE SCORE
        # ----------------------------------------------------

        total_questions = len(
            questions
        )

        percentage = (
            score /
            total_questions
        ) * 100

        completed = (
            percentage >= 50
        )

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
            (
                %s,
                %s,
                %s,
                %s
            )
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
        # UPDATE EXISTING PROGRESS
        # ----------------------------------------------------

        if progress:

            cursor.execute("""
                UPDATE progress
                SET
                    completed = %s,
                    best_score =
                        GREATEST(
                            best_score,
                            %s
                        ),
                    attempts =
                        attempts + 1,
                    last_attempt =
                        CURRENT_TIMESTAMP
                WHERE topic_id = %s
            """, (
                completed,
                percentage,
                topic_id
            ))

        # ----------------------------------------------------
        # INSERT NEW PROGRESS
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
        # UPDATE TOPIC COMPLETED STATUS
        # ----------------------------------------------------

        cursor.execute("""
            UPDATE topics
            SET completed = %s
            WHERE topic_id = %s
        """, (
            completed,
            topic_id
        ))

        # ----------------------------------------------------
        # SAVE DATABASE CHANGES
        # ----------------------------------------------------

        connection.commit()

        # ----------------------------------------------------
        # RETURN RESULT
        # ----------------------------------------------------

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
                round(
                    percentage,
                    2
                ),

            "completed":
                completed,

            "solutions":
                solutions,

            "message":
                "Quiz evaluated successfully!"

        })

    except Exception as e:

        if connection:
            connection.rollback()

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# GET STUDENT PROGRESS
#
# All topics are available.
# ============================================================

@app.route("/progress")
def get_progress():

    connection = None
    cursor = None

    try:

        connection = get_connection()

        cursor = connection.cursor(
            dictionary=True
        )

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
                ON t.topic_id =
                   p.topic_id

            ORDER BY
                t.subject,
                t.topic_order
        """)

        progress = cursor.fetchall()

        return jsonify(progress)

    except Exception as e:

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# GET WEAK TOPICS
#
# Weak topic:
# BEST SCORE < 50%
# ============================================================

@app.route("/weak-topics")
def get_weak_topics():

    connection = None
    cursor = None

    try:

        connection = get_connection()

        cursor = connection.cursor(
            dictionary=True
        )

        cursor.execute("""
            SELECT
                t.topic_id,
                t.subject,
                t.topic_name,
                MAX(
                    qr.percentage
                ) AS percentage

            FROM quiz_results qr

            JOIN topics t
                ON qr.topic_id =
                   t.topic_id

            GROUP BY
                t.topic_id,
                t.subject,
                t.topic_name,
                t.topic_order

            HAVING
                MAX(
                    qr.percentage
                ) < 50

            ORDER BY
                percentage ASC,
                t.topic_order ASC
        """)

        weak_topics = cursor.fetchall()

        return jsonify(
            weak_topics
        )

    except Exception as e:

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# LEARNING RESOURCES
#
# IMPORTANT:
#
# Resources are ALWAYS visible.
#
# < 50%:
#     Notes + resources visible
#
# 50 - 79%:
#     Notes + resources visible
#
# 80%+:
#     Notes + resources visible
#
# SCORE NEVER HIDES NOTES.
# ============================================================

@app.route(
    "/recommendations/<int:topic_id>"
)
def get_recommendations(topic_id):

    connection = None
    cursor = None

    try:

        connection = get_connection()

        cursor = connection.cursor(
            dictionary=True
        )

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
            score_data["best_score"]
            or 0
        )

        # ----------------------------------------------------
        # DETERMINE LEARNING LEVEL
        # ----------------------------------------------------

        if best_score < 50:

            recommendation_level = (
                "Needs Improvement"
            )

        elif best_score < 80:

            recommendation_level = (
                "Practice"
            )

        else:

            recommendation_level = (
                "Advanced Learning"
            )

        # ----------------------------------------------------
        # GET ALL RESOURCES
        #
        # NO SCORE FILTER
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

        # ----------------------------------------------------
        # RETURN RESOURCES
        # ----------------------------------------------------

        return jsonify({

            "status":
                "success",

            "topic_id":
                topic_id,

            "topic_name":
                topic["topic_name"],

            "best_score":
                round(
                    best_score,
                    2
                ),

            "recommendation_level":
                recommendation_level,

            "notes_visible":
                True,

            "resources":
                resources,

            "message":
                "Learning resources are always available."

        })

    except Exception as e:

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# AI SMART LEARNING RECOMMENDATION
#
# Gemini generates personalized guidance.
#
# Resources remain visible even below 50%.
# ============================================================

@app.route(
    "/smart-recommendation/<int:topic_id>"
)
def smart_recommendation(topic_id):

    connection = None
    cursor = None

    try:

        connection = get_connection()

        cursor = connection.cursor(
            dictionary=True
        )

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
            result["best_score"]
            or 0
        )

        # ----------------------------------------------------
        # GENERATE GEMINI RECOMMENDATION
        # ----------------------------------------------------

        recommendation = (
            generate_recommendation(
                topic["topic_name"],
                score
            )
        )

        # ----------------------------------------------------
        # RETURN AI RECOMMENDATION
        # ----------------------------------------------------

        return jsonify({

            "status":
                "success",

            "topic_id":
                topic_id,

            "topic_name":
                topic["topic_name"],

            "score":
                round(
                    score,
                    2
                ),

            "recommendation":
                recommendation,

            "notes_visible":
                True,

            "message":
                "AI learning recommendation generated successfully."

        })

    except Exception as e:

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# LEARNING ANALYTICS
# ============================================================

@app.route("/analytics")
def get_analytics():

    connection = None
    cursor = None

    try:

        connection = get_connection()

        cursor = connection.cursor(
            dictionary=True
        )

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
            attempts_data["total_attempts"]
            or 0
        )

        # ----------------------------------------------------
        # AVERAGE SCORE
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                AVG(percentage)
                AS average_score
            FROM quiz_results
        """)

        average_data = cursor.fetchone()

        average_score = float(
            average_data["average_score"]
            or 0
        )

        # ----------------------------------------------------
        # BEST SCORE
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                MAX(percentage)
                AS best_score
            FROM quiz_results
        """)

        best_data = cursor.fetchone()

        best_score = float(
            best_data["best_score"]
            or 0
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
            completed_data["completed_topics"]
            or 0
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
            total_data["total_topics"]
            or 0
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

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

    finally:

        if cursor:
            cursor.close()

        if connection:
            connection.close()


# ============================================================
# TEST GEMINI AI CONNECTION
# ============================================================

@app.route("/test-ai")
def test_ai():

    try:

        from google import genai

        gemini_key = os.getenv(
            "GEMINI_API_KEY"
        )

        if not gemini_key:

            return jsonify({
                "status": "error",
                "message": "GEMINI_API_KEY is not set in LearnRoot/.env"
            }), 500

        client = genai.Client(
            api_key=gemini_key
        )

        response = client.models.generate_content(
            model="gemini-3.6-flash",
            contents=(
                "Say hello to LearnRoot "
                "in one short sentence."
            )
        )

        return jsonify({

            "status":
                "success",

            "message":
                response.text

        })

    except Exception as e:

        return jsonify({

            "status":
                "error",

            "message":
                str(e)

        }), 500


# ============================================================
# RUN APPLICATION
# ============================================================

if __name__ == "__main__":

    app.run(
        debug=True,
        host="127.0.0.1",
        port=5000
    )