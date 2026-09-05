from flask import Flask, request, jsonify, send_file
from flask_cors import CORS

from dotenv import load_dotenv
from google import genai

import os
import json
import subprocess
import pyttsx3
import time


# =======================================
# Load Environment Variables
# =======================================

load_dotenv()

api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    raise ValueError("GEMINI_API_KEY not found in .env file")


# =======================================
# Flask Application
# =======================================

app = Flask(__name__)

CORS(app)


# =======================================
# Gemini Client
# =======================================

client = genai.Client(api_key=api_key)

# Lightweight model suitable for LearnRoot
MODEL = "gemini-3.5-flash-lite"


# =======================================
# Gemini Retry Function
# =======================================

def generate_with_retry(prompt, max_retries=3):

    for attempt in range(max_retries):

        try:

            response = client.models.generate_content(
                model=MODEL,
                contents=prompt
            )

            return response.text

        except Exception as e:

            error_message = str(e)

            # Do not retry quota/rate-limit errors
            if "429" in error_message or "RESOURCE_EXHAUSTED" in error_message:
                raise e

            # Retry temporary Gemini server errors
            if "503" in error_message or "UNAVAILABLE" in error_message:

                if attempt < max_retries - 1:

                    wait_time = 5 * (attempt + 1)

                    print(
                        f"Gemini temporarily unavailable. "
                        f"Retrying in {wait_time} seconds..."
                    )

                    time.sleep(wait_time)

                    continue

            raise e


# =======================================
# AI Error Response Helper
# =======================================

def ai_error_response(error):

    error_message = str(error)

    # Gemini quota/rate limit
    if "429" in error_message or "RESOURCE_EXHAUSTED" in error_message:

        return jsonify({
            "error": "AI request limit reached. Please try again later."
        }), 429

    # Gemini temporary server error
    if "503" in error_message or "UNAVAILABLE" in error_message:

        return jsonify({
            "error": "AI service is temporarily unavailable. Please try again."
        }), 503

    # Other AI errors
    return jsonify({
        "error": "AI service failed. Please try again."
    }), 500


# =======================================
# 1. Concept Explanation
# =======================================

def explain_topic(topic):

    prompt = f"""
You are a college AI tutor for LearnRoot.

Explain this Computer Engineering topic:
{topic}

Use simple but technically correct language.

Include only:
1. Definition
2. Main idea
3. Simple example
4. Why it is important
5. Prerequisite connection

Keep the answer concise and student-friendly.
"""

    return generate_with_retry(prompt)


# =======================================
# 2. AI Summary
# =======================================

def summarize_topic(topic):

    prompt = f"""
You are a college AI tutor for LearnRoot.

Create short exam-oriented revision notes for:
{topic}

Include:
- Short definition
- 4 to 6 key points
- Important terms, formulas, or syntax
- Small example if useful
- Remember section

Use simple language.
Keep it concise.
Return Markdown.
"""

    return generate_with_retry(prompt)


# =======================================
# 3. What If I Skip?
# =======================================

def what_if_i_skip(topic):

    prompt = f"""
You are an AI tutor for LearnRoot.

The student is considering skipping:
{topic}

Explain briefly:
1. Why it is important
2. What later concepts may become difficult
3. What learning gap may occur
4. Whether it should be studied first
5. One simple academic example

Keep the answer concise and easy to understand.
"""

    return generate_with_retry(prompt)


# =======================================
# 4. Visual Explanation
# =======================================

def visual_explanation(topic):

    prompt = f"""
You are an AI tutor for LearnRoot.

Create a simple step-by-step visual explanation of:
{topic}

Return ONLY valid JSON.

Use exactly this structure:

{{
    "topic": "{topic}",
    "central_idea": "one short sentence",
    "steps": [
        {{
            "title": "short title",
            "description": "short explanation"
        }}
    ]
}}

Rules:
- Create 4 to 5 steps.
- Keep titles short.
- Keep descriptions short.
- No Markdown.
- No code block.
- Return JSON only.
"""

    result = generate_with_retry(prompt).strip()

    # Remove Markdown code fences if Gemini adds them
    if result.startswith("```"):

        result = result.replace("```json", "")
        result = result.replace("```", "")
        result = result.strip()

    try:

        return json.loads(result)

    except json.JSONDecodeError:

        print("Gemini returned invalid JSON:")
        print(result)

        return {
            "topic": topic,
            "central_idea": "Unable to create visual explanation.",
            "steps": []
        }


# =======================================
# 5. AI Doubt Solver
# =======================================

def solve_doubt(topic, question):

    prompt = f"""
You are a contextual academic tutor inside LearnRoot.

Current topic:
{topic}

Student question:
{question}

Answer ONLY if the question is academically related
to the current topic.

Rules:
- Use simple language.
- Explain clearly.
- Give a small example when useful.
- Keep the answer concise.
- Do not act as a general chatbot.

If unrelated, say:
"This question is outside the current topic. Please select the appropriate topic."
"""

    return generate_with_retry(prompt)


# =======================================
# 6. Voice Explanation
# =======================================

def generate_voice(topic):

    # Generate AI explanation
    explanation = explain_topic(topic)

    # Create Text-to-Speech engine
    engine = pyttsx3.init()

    # Speaking speed
    engine.setProperty("rate", 150)

    # Safe filename
    safe_topic = "".join(
        character if character.isalnum() else "_"
        for character in topic.lower()
    )

    # Temporary WAV file
    wav_file = f"{safe_topic}_temp.wav"

    # Final MP3 file
    mp3_file = f"{safe_topic}_explanation.mp3"

    # Generate WAV
    engine.save_to_file(
        explanation,
        wav_file
    )

    engine.runAndWait()

    # FFmpeg executable path
    ffmpeg_path = (
        r"C:\Users\Shama\AppData\Local\Microsoft\WinGet\Packages"
        r"\Gyan.FFmpeg.Shared_Microsoft.Winget.Source_8wekyb3d8bbwe"
        r"\ffmpeg-9.0.1-full_build-shared"
        r"\bin\ffmpeg.exe"
    )

    # Convert WAV to MP3
    subprocess.run(
        [
            ffmpeg_path,
            "-y",
            "-i",
            wav_file,
            "-codec:a",
            "libmp3lame",
            "-b:a",
            "64k",
            mp3_file
        ],
        check=True
    )

    # Delete temporary WAV
    if os.path.exists(wav_file):
        os.remove(wav_file)

    return mp3_file


# =======================================
# API ROUTES
# =======================================


# =======================================
# Home / Test API
# =======================================

@app.route("/", methods=["GET"])
def home():

    return jsonify({
        "message": "LearnRoot AI Visual Tutor API is running.",
        "module": "Module 3 - AI Visual Tutor",
        "model": MODEL,
        "endpoints": [
            "/explain",
            "/summary",
            "/visual",
            "/doubt",
            "/skip",
            "/voice"
        ]
    })


# =======================================
# Explanation API
# =======================================

@app.route("/explain", methods=["POST"])
def explain():

    data = request.get_json()

    if not data:

        return jsonify({
            "error": "Request body is required."
        }), 400

    topic = data.get("topic")

    if not topic:

        return jsonify({
            "error": "Topic is required."
        }), 400

    try:

        answer = explain_topic(topic)

        return jsonify({
            "topic": topic,
            "explanation": answer
        })

    except Exception as e:

        print(f"Explanation error: {e}")

        return ai_error_response(e)


# =======================================
# AI Summary API
# =======================================

@app.route("/summary", methods=["POST"])
def summary():

    data = request.get_json()

    if not data:

        return jsonify({
            "error": "Request body is required."
        }), 400

    topic = data.get("topic")

    if not topic:

        return jsonify({
            "error": "Topic is required."
        }), 400

    try:

        answer = summarize_topic(topic)

        return jsonify({
            "topic": topic,
            "summary": answer
        })

    except Exception as e:

        print(f"Summary error: {e}")

        return ai_error_response(e)


# =======================================
# What If I Skip API
# =======================================

@app.route("/skip", methods=["POST"])
def skip():

    data = request.get_json()

    if not data:

        return jsonify({
            "error": "Request body is required."
        }), 400

    topic = data.get("topic")

    if not topic:

        return jsonify({
            "error": "Topic is required."
        }), 400

    try:

        answer = what_if_i_skip(topic)

        return jsonify({
            "topic": topic,
            "what_if_i_skip": answer
        })

    except Exception as e:

        print(f"Skip error: {e}")

        return ai_error_response(e)


# =======================================
# Visual Explanation API
# =======================================

@app.route("/visual", methods=["POST"])
def visual():

    data = request.get_json()

    if not data:

        return jsonify({
            "error": "Request body is required."
        }), 400

    topic = data.get("topic")

    if not topic:

        return jsonify({
            "error": "Topic is required."
        }), 400

    try:

        result = visual_explanation(topic)

        return jsonify(result)

    except Exception as e:

        print(f"Visual explanation error: {e}")

        return ai_error_response(e)


# =======================================
# AI Doubt Solver API
# =======================================

@app.route("/doubt", methods=["POST"])
def doubt():

    data = request.get_json()

    if not data:

        return jsonify({
            "error": "Request body is required."
        }), 400

    topic = data.get("topic")
    question = data.get("question")

    if not topic or not question:

        return jsonify({
            "error": "Topic and question are required."
        }), 400

    try:

        answer = solve_doubt(
            topic,
            question
        )

        return jsonify({
            "topic": topic,
            "question": question,
            "answer": answer
        })

    except Exception as e:

        print(f"Doubt solver error: {e}")

        return ai_error_response(e)


# =======================================
# Voice Explanation API
# =======================================

@app.route("/voice", methods=["POST"])
def voice():

    data = request.get_json()

    if not data:

        return jsonify({
            "error": "Request body is required."
        }), 400

    topic = data.get("topic")

    if not topic:

        return jsonify({
            "error": "Topic is required."
        }), 400

    try:

        audio_file = generate_voice(topic)

        return send_file(
            audio_file,
            mimetype="audio/mpeg",
            as_attachment=False
        )

    except Exception as e:

        print(f"Voice generation error: {e}")

        return jsonify({
            "error": "Voice generation failed.",
            "details": str(e)
        }), 500


# =======================================
# Start Flask Server
# =======================================

if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )