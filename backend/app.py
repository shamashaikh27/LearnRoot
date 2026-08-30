from flask import Flask, jsonify, request
from flask_cors import CORS
from dotenv import load_dotenv
from openai import OpenAI
from db import get_connection
from ai_quiz import generate_quiz
from ai_recommendation import generate_recommendation
import os


# ============================================================
# LOAD ENVIRONMENT VARIABLES
# ============================================================

load_dotenv()

client = OpenAI(
    api_key=os.getenv("OPENAI_API_KEY")
)


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
# ============================================================

@app.route("/topics")
def get_topics():

    connection = None
    cursor = None

    try:

        connection = get_connection()
        cursor = connection.cursor(dictionary=True)

        cursor.execute("""
            SELECT
                topic_id,
                subject,
                topic_name,
                topic_order,
                completed,
                unlocked
            FROM topics
            ORDER BY subject, topic_order
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
# ============================================================

@app.route("/quiz/<int:topic_id>")
def get_quiz(topic_id):

    connection = None
    cursor = None

    try:

        connection = get_connection()
        cursor = connection.cursor(dictionary=True)

        # ----------------------------------------------------
        # GET TOPIC INFORMATION
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
        # GET EXISTING QUESTIONS
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
        # IF QUESTIONS EXIST, RETURN THEM
        # ----------------------------------------------------

        if questions:

            return jsonify(questions)

        # ----------------------------------------------------
        # NO QUESTIONS
        # GENERATE USING AI
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
        # SAVE GENERATED QUESTIONS
        # ----------------------------------------------------

        for question in generated_questions:

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
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
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
        # GET NEW QUESTIONS
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

        return jsonify(questions)

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
# ============================================================

@app.route("/submit-quiz", methods=["POST"])
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

        topic_id = data.get("topic_id")
        answers = data.get("answers", {})

        if topic_id is None:

            return jsonify({
                "status": "error",
                "message": "topic_id is required."
            }), 400

        connection = get_connection()
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
                "message": "No quiz questions found for this topic."
            }), 404

        # ----------------------------------------------------
        # EVALUATE ANSWERS
        # ----------------------------------------------------

        score = 0
        solutions = []

        for question in questions:

            quiz_id = str(question["quiz_id"])

            correct_answer = question["correct_answer"]

            student_answer = answers.get(quiz_id)

            if student_answer == correct_answer:

                score += 1

            solutions.append({
                "quiz_id": question["quiz_id"],
                "question": question["question"],
                "student_answer": student_answer,
                "correct_answer": correct_answer,
                "solution": question["solution"]
            })

        # ----------------------------------------------------
        # CALCULATE SCORE
        # ----------------------------------------------------

        total_questions = len(questions)

        percentage = (score / total_questions) * 100

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
            VALUES (%s, %s, %s, %s)
        """, (
            topic_id,
            score,
            total_questions,
            percentage
        ))

        # ----------------------------------------------------
        # CHECK EXISTING PROGRESS
        # ----------------------------------------------------

        cursor.execute("""
            SELECT *
            FROM progress
            WHERE topic_id = %s
        """, (topic_id,))

        progress = cursor.fetchone()

        # ----------------------------------------------------
        # UPDATE OR INSERT PROGRESS
        # ----------------------------------------------------

        if progress:

            cursor.execute("""
                UPDATE progress
                SET
                    completed = %s,
                    best_score = GREATEST(best_score, %s),
                    attempts = attempts + 1,
                    last_attempt = CURRENT_TIMESTAMP
                WHERE topic_id = %s
            """, (
                completed,
                percentage,
                topic_id
            ))

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
                VALUES (%s, %s, %s, 1, CURRENT_TIMESTAMP)
            """, (
                topic_id,
                completed,
                percentage
            ))

        # ----------------------------------------------------
        # UNLOCK NEXT TOPIC
        # ----------------------------------------------------

        if percentage >= 50:

            cursor.execute("""
                SELECT topic_id
                FROM topics
                WHERE subject = (
                    SELECT subject
                    FROM topics
                    WHERE topic_id = %s
                )
                AND topic_order > (
                    SELECT topic_order
                    FROM topics
                    WHERE topic_id = %s
                )
                ORDER BY topic_order
                LIMIT 1
            """, (topic_id, topic_id))

            next_topic = cursor.fetchone()

            if next_topic:

                cursor.execute("""
                    UPDATE topics
                    SET unlocked = TRUE
                    WHERE topic_id = %s
                """, (next_topic["topic_id"],))

        # ----------------------------------------------------
        # SAVE
        # ----------------------------------------------------

        connection.commit()

        # ----------------------------------------------------
        # RETURN RESULT
        # ----------------------------------------------------

        return jsonify({
            "status": "success",
            "topic_id": topic_id,
            "score": score,
            "total_questions": total_questions,
            "percentage": round(percentage, 2),
            "completed": completed,
            "solutions": solutions,
            "message": "Quiz evaluated successfully!"
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
# ============================================================

@app.route("/progress")
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
                t.unlocked,
                COALESCE(p.completed, 0) AS completed,
                COALESCE(p.best_score, 0) AS best_score,
                COALESCE(p.attempts, 0) AS attempts
            FROM topics t
            LEFT JOIN progress p
                ON t.topic_id = p.topic_id
            ORDER BY t.subject, t.topic_order
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
# ============================================================

@app.route("/weak-topics")
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
                t.topic_name
            HAVING MAX(qr.percentage) < 50
            ORDER BY percentage ASC, t.topic_order ASC
        """)

        weak_topics = cursor.fetchall()

        return jsonify(weak_topics)

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
# SMART RECOMMENDATIONS
# ============================================================

@app.route("/recommendations/<int:topic_id>")
def get_recommendations(topic_id):

    connection = None
    cursor = None

    try:

        connection = get_connection()
        cursor = connection.cursor(dictionary=True)

        # ----------------------------------------------------
        # GET BEST SCORE
        # ----------------------------------------------------

        cursor.execute("""
            SELECT
                COALESCE(MAX(percentage), 0) AS best_score
            FROM quiz_results
            WHERE topic_id = %s
        """, (topic_id,))

        score_data = cursor.fetchone()

        best_score = float(
            score_data["best_score"] or 0
        )

        # ----------------------------------------------------
        # CHOOSE RECOMMENDATION LEVEL
        # ----------------------------------------------------

        if best_score < 50:

            recommendation_level = "Needs Improvement"

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

        elif best_score < 80:

            recommendation_level = "Practice"

            cursor.execute("""
                SELECT
                    resource_id,
                    topic_id,
                    resource_type,
                    title,
                    resource_link
                FROM resources
                WHERE topic_id = %s
                ORDER BY
                    CASE
                        WHEN resource_type = 'Video' THEN 1
                        ELSE 2
                    END,
                    resource_id
            """, (topic_id,))

        else:

            recommendation_level = "Advanced Learning"

            cursor.execute("""
                SELECT
                    resource_id,
                    topic_id,
                    resource_type,
                    title,
                    resource_link
                FROM resources
                WHERE topic_id = %s
                ORDER BY
                    CASE
                        WHEN resource_type = 'Video' THEN 1
                        ELSE 2
                    END,
                    resource_id
            """, (topic_id,))

        resources = cursor.fetchall()

        return jsonify({
            "status": "success",
            "topic_id": topic_id,
            "best_score": best_score,
            "recommendation_level": recommendation_level,
            "resources": resources,
            "message": "Smart learning resources recommended successfully."
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
        cursor = connection.cursor(dictionary=True)

        # ----------------------------------------------------
        # TOTAL ATTEMPTS
        # ----------------------------------------------------

        cursor.execute("""
            SELECT COUNT(*) AS total_attempts
            FROM quiz_results
        """)

        attempts_data = cursor.fetchone()

        total_attempts = attempts_data["total_attempts"] or 0

        # ----------------------------------------------------
        # AVERAGE SCORE
        # ----------------------------------------------------

        cursor.execute("""
            SELECT AVG(percentage) AS average_score
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
            SELECT MAX(percentage) AS best_score
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
            SELECT COUNT(*) AS completed_topics
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
            SELECT COUNT(*) AS total_topics
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
                completed_topics / total_topics
            ) * 100

        else:

            overall_progress = 0

        # ----------------------------------------------------
        # RETURN ANALYTICS
        # ----------------------------------------------------

        return jsonify({
            "status": "success",
            "total_attempts": total_attempts,
            "average_score": round(average_score, 2),
            "best_score": round(best_score, 2),
            "completed_topics": completed_topics,
            "total_topics": total_topics,
            "overall_progress": round(
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
# AI SMART LEARNING RECOMMENDATION
# ============================================================

@app.route("/smart-recommendation/<int:topic_id>")
def smart_recommendation(topic_id):

    connection = None
    cursor = None

    try:

        connection = get_connection()
        cursor = connection.cursor(dictionary=True)

        # ----------------------------------------------------
        # GET TOPIC NAME
        # ----------------------------------------------------

        cursor.execute("""
            SELECT topic_name
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
            SELECT MAX(percentage) AS best_score
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

        recommendation = generate_recommendation(
            topic["topic_name"],
            score
        )

        return jsonify({
            "status": "success",
            "topic_id": topic_id,
            "topic_name": topic["topic_name"],
            "score": round(score, 2),
            "recommendation": recommendation
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
# TEST OPENAI AI CONNECTION
# ============================================================

@app.route("/test-ai")
def test_ai():

    try:

        response = client.responses.create(
            model="gpt-5.6",
            input="Say hello to LearnRoot in one short sentence."
        )

        return jsonify({
            "status": "success",
            "message": response.output_text
        })

    except Exception as e:

        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500


# ============================================================
# RUN APPLICATION
# ============================================================

if __name__ == "__main__":

    app.run(debug=True)