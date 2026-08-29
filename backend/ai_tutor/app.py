from flask import Flask, request, jsonify
from flask_cors import CORS

from dotenv import load_dotenv
from google import genai

import os
import json


# ---------------------------------------
# Load environment variables
# ---------------------------------------

load_dotenv()

api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    raise ValueError("GEMINI_API_KEY not found in .env file")


# ---------------------------------------
# Flask application
# ---------------------------------------

app = Flask(__name__)

CORS(app)


# ---------------------------------------
# Gemini client
# ---------------------------------------

client = genai.Client(api_key=api_key)

MODEL = "gemini-3.6-flash"


# ---------------------------------------
# 1. Concept Explanation
# ---------------------------------------

def explain_topic(topic):

    prompt = f"""
    Explain the topic "{topic}" to a Computer Engineering student.

    Use simple and clear language.

    Include:
    1. Definition
    2. Main concept
    3. Simple example
    4. Why the topic is important
    5. Connection with prerequisite concepts

    Keep the explanation student-friendly.
    """

    response = client.models.generate_content(
        model=MODEL,
        contents=prompt
    )

    return response.text


# ---------------------------------------
# 2. One-Shot Revision
# ---------------------------------------

def one_shot_revision(topic):

    prompt = f"""
    Create a short one-shot revision for "{topic}".

    Include:
    1. Key definition
    2. Important points
    3. Important syntax or formulas if applicable
    4. One simple example
    5. Common mistakes

    Keep it concise and useful for exam revision.
    """

    response = client.models.generate_content(
        model=MODEL,
        contents=prompt
    )

    return response.text


# ---------------------------------------
# 3. What If I Skip?
# ---------------------------------------

def what_if_i_skip(topic):

    prompt = f"""
    The student is thinking about skipping "{topic}".

    Explain:

    1. Why this topic is important
    2. Which later concepts may become difficult
    3. How skipping it can create learning gaps
    4. Whether the student should study it first
    5. Give one simple academic example

    Keep the answer simple and helpful.
    """

    response = client.models.generate_content(
        model=MODEL,
        contents=prompt
    )

    return response.text


# ---------------------------------------
# 4. Visual Explanation
# ---------------------------------------

def visual_explanation(topic):

    prompt = f"""
    Create a simple visual explanation of "{topic}"
    for a Computer Engineering student.

    Break the concept into 4 to 6 logical steps.

    Return ONLY valid JSON in this format:

    {{
        "topic": "Topic name",
        "central_idea": "One short sentence",
        "steps": [
            {{
                "title": "Step title",
                "description": "Short explanation"
            }}
        ]
    }}

    Rules:
    - Do not use Markdown.
    - Do not use code blocks.
    - Keep titles short.
    - Keep descriptions short.
    """

    response = client.models.generate_content(
        model=MODEL,
        contents=prompt
    )

    result = response.text.strip()

    if result.startswith("```"):
        result = result.replace("```json", "")
        result = result.replace("```", "")
        result = result.strip()

    try:
        return json.loads(result)

    except json.JSONDecodeError:

        return {
            "topic": topic,
            "central_idea": "Unable to create visual explanation.",
            "steps": []
        }


# ---------------------------------------
# 5. AI Doubt Solver
# ---------------------------------------

def solve_doubt(topic, question):

    prompt = f"""
    You are an AI tutor for Computer Engineering students.

    Current topic:
    {topic}

    Student question:
    {question}

    Answer in simple and clear language.

    Rules:
    - Stay related to the given topic.
    - Explain step-by-step when necessary.
    - Give a simple example if useful.
    - Avoid unnecessarily complicated terminology.
    """

    response = client.models.generate_content(
        model=MODEL,
        contents=prompt
    )

    return response.text


# =======================================
# API ROUTES
# =======================================


# ---------------------------------------
# Home / Test
# ---------------------------------------

@app.route("/", methods=["GET"])
def home():

    return jsonify({
        "message": "LearnRoot AI Tutor API is running!"
    })


# ---------------------------------------
# Explanation API
# ---------------------------------------

@app.route("/explain", methods=["POST"])
def explain():

    data = request.get_json()

    topic = data.get("topic")

    if not topic:
        return jsonify({
            "error": "Topic is required"
        }), 400

    answer = explain_topic(topic)

    return jsonify({
        "topic": topic,
        "explanation": answer
    })


# ---------------------------------------
# One-Shot Revision API
# ---------------------------------------

@app.route("/revision", methods=["POST"])
def revision():

    data = request.get_json()

    topic = data.get("topic")

    if not topic:
        return jsonify({
            "error": "Topic is required"
        }), 400

    answer = one_shot_revision(topic)

    return jsonify({
        "topic": topic,
        "revision": answer
    })


# ---------------------------------------
# What If I Skip API
# ---------------------------------------

@app.route("/skip", methods=["POST"])
def skip():

    data = request.get_json()

    topic = data.get("topic")

    if not topic:
        return jsonify({
            "error": "Topic is required"
        }), 400

    answer = what_if_i_skip(topic)

    return jsonify({
        "topic": topic,
        "what_if_i_skip": answer
    })


# ---------------------------------------
# Visual Explanation API
# ---------------------------------------

@app.route("/visual", methods=["POST"])
def visual():

    data = request.get_json()

    topic = data.get("topic")

    if not topic:
        return jsonify({
            "error": "Topic is required"
        }), 400

    result = visual_explanation(topic)

    return jsonify(result)


# ---------------------------------------
# AI Doubt Solver API
# ---------------------------------------

@app.route("/doubt", methods=["POST"])
def doubt():

    data = request.get_json()

    topic = data.get("topic")
    question = data.get("question")

    if not topic or not question:

        return jsonify({
            "error": "Topic and question are required"
        }), 400

    answer = solve_doubt(topic, question)

    return jsonify({
        "topic": topic,
        "question": question,
        "answer": answer
    })


# =======================================
# Start Flask server
# =======================================

if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )