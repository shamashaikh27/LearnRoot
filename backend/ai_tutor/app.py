from flask import Flask, request, jsonify, send_file
from flask_cors import CORS

from dotenv import load_dotenv
from google import genai

import os
import json
import re
import subprocess
import pyttsx3
import time
import tempfile
import uuid


# ============================================================
# ENVIRONMENT
# ============================================================

load_dotenv()

api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    raise ValueError("GEMINI_API_KEY not found in .env file")


# ============================================================
# FLASK APPLICATION
# ============================================================

app = Flask(__name__)
CORS(app)


# ============================================================
# GEMINI CLIENT
# ============================================================

client = genai.Client(api_key=api_key)

# Lightweight model suitable for the free Gemini tier.
MODEL = "gemini-3.5-flash-lite"


# ============================================================
# COMMON AI TEXT CLEANING
# ============================================================

def clean_ai_text(text):
    """
    Clean common Markdown artifacts from Gemini output.

    LearnRoot uses its own Flutter card styling, so the AI should
    return clean learner-facing text instead of Markdown such as
    **bold**, ## headings, or raw bullet characters.
    """

    if text is None:
        return ""

    text = str(text)

    # Remove Markdown code fences.
    text = re.sub(r"```(?:text|markdown|md)?", "", text, flags=re.IGNORECASE)
    text = text.replace("```", "")

    # Remove bold / italic markers while keeping the words.
    text = text.replace("**", "")
    text = text.replace("__", "")
    text = text.replace("~~", "")

    # Remove heading markers at the beginning of a line.
    text = re.sub(r"(?m)^\s{0,3}#{1,6}\s*", "", text)

    # Convert Markdown bullets to simple readable lines.
    text = re.sub(r"(?m)^\s*[-*•]\s+", "• ", text)

    # Remove unnecessary Markdown link formatting:
    # [text](url) -> text
    text = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", text)

    # Remove excessive blank lines.
    text = re.sub(r"\n{3,}", "\n\n", text)

    return text.strip()


def clean_visual_field(value):
    """Clean a single visual-explanation field."""
    return clean_ai_text(value)


# ============================================================
# GEMINI RETRY
# ============================================================

def generate_with_retry(prompt, max_retries=3):
    """
    Generate Gemini content with retries for temporary 503 errors.

    Rate-limit/quota errors are not retried because repeated requests
    would make the free-tier limit worse.
    """

    for attempt in range(max_retries):

        try:
            response = client.models.generate_content(
                model=MODEL,
                contents=prompt
            )

            return response.text

        except Exception as e:

            error_message = str(e)

            # Do not retry quota/rate-limit errors.
            if "429" in error_message or "RESOURCE_EXHAUSTED" in error_message:
                raise e

            # Retry temporary Gemini service errors.
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


# ============================================================
# AI ERROR RESPONSE
# ============================================================

def ai_error_response(error):

    error_message = str(error)

    if "429" in error_message or "RESOURCE_EXHAUSTED" in error_message:

        return jsonify({
            "error": "AI request limit reached. Please wait a little and try again."
        }), 429

    if "503" in error_message or "UNAVAILABLE" in error_message:

        return jsonify({
            "error": "AI service is temporarily unavailable. Please try again."
        }), 503

    print(f"AI error: {error_message}")

    return jsonify({
        "error": "AI service failed. Please try again."
    }), 500


# ============================================================
# 1. TEACHER-STYLE EXPLANATION
# ============================================================

def explain_topic(topic):

    prompt = f"""
You are the main classroom teacher inside LearnRoot, an AI learning
platform for Computer Engineering students.

Teach the student this topic:

{topic}

IMPORTANT TEACHING STYLE:
- Teach the topic as if you are standing in front of a beginner college
  class and explaining it step by step.
- Do not sound like a dictionary, textbook, Wikipedia article, or exam
  answer.
- Start with an intuitive idea before introducing technical terminology.
- Explain WHY the concept exists, not only WHAT it is.
- Use a relatable real-world analogy when it genuinely helps.
- Move from simple idea -> working -> example -> important point.
- When the topic is programming/data structures, include a small,
  correct code example when useful.
- Explicitly explain confusing terms in simple language.
- Connect the topic to prerequisite knowledge or the next concept when
  useful.
- Use natural teacher transitions such as "Let's imagine...", "Now notice...",
  "The important part is...", and "So what does this mean?"
- Do not make the explanation artificially short. Give enough detail that
  a beginner can actually understand the concept.

FORMATTING:
- Use clean plain text.
- Use emojis as visual section markers.
- Good section markers include 🧠, 👀, 💡, 💻, 🔍, 🎯, and 🔗.
- Do NOT use Markdown bold markers such as **text**.
- Do NOT use Markdown headings such as ##.
- Do NOT use Markdown tables.
- Do NOT wrap the response in a code block.
- Do NOT use decorative stars.
- Keep paragraphs short.
- Use numbered steps such as 1️⃣, 2️⃣, 3️⃣ when teaching a process.
- Include a final "🎯 Quick Check" with one simple question when
  appropriate.

Use this general structure, but adapt it naturally to the topic:

🧠 BIG IDEA
Explain the concept in simple words.

👀 LET'S IMAGINE
Give a useful analogy or mental picture.

🔍 HOW IT WORKS
Teach the important steps.

💻 SIMPLE EXAMPLE
Give a small example if useful.

💡 IMPORTANT POINT
State the key thing the student should remember.

🔗 CONNECTION
Explain how this topic connects to prerequisites or later concepts.

🎯 QUICK CHECK
Ask one simple question to make the student think.

Return only the learner-facing explanation.
"""

    result = generate_with_retry(prompt)

    return clean_ai_text(result)


# ============================================================
# 2. AI SUMMARY
# ============================================================

def summarize_topic(topic):

    prompt = f"""
You are the revision teacher inside LearnRoot.

Create useful exam-oriented revision notes for:

{topic}

The student has already learned the topic and now wants a clear,
quick revision.

CONTENT:
- Start with a short intuitive definition.
- Give 5 to 7 genuinely useful key points.
- Include important terms, syntax, rules, formulas, or properties when
  they apply.
- Give one small example when useful.
- Include common mistakes or a common confusion when relevant.
- Finish with a "💡 Remember" section containing the most important
  takeaway.

FORMATTING:
- Use clean plain text, NOT Markdown.
- Use emojis such as 🧠, 📌, 💻, ⚠️, and 💡.
- Do NOT use **bold** markers.
- Do NOT use ## headings.
- Do NOT use Markdown tables.
- Do NOT use decorative stars.
- Keep each point short but meaningful.
- Do not write a generic definition followed by empty filler points.
- Make the notes useful for a Computer Engineering student preparing
  for an exam.

Return only the revision notes.
"""

    result = generate_with_retry(prompt)

    return clean_ai_text(result)


# ============================================================
# 3. WHAT IF I SKIP?
# ============================================================

def what_if_i_skip(topic):

    prompt = f"""
You are the academic mentor inside LearnRoot.

The student is considering skipping this topic:

{topic}

Explain the academic impact honestly and specifically.

The student needs to understand:
1. Why this topic matters.
2. What knowledge they would miss by skipping it.
3. Which later concepts may become harder.
4. What prerequisite or foundation is involved.
5. Whether they should study it now or can safely postpone it.
6. Give one simple real academic example.

IMPORTANT:
- Do not scare the student.
- Do not give a generic answer that could apply to every topic.
- Base the explanation on the actual Computer Engineering topic.
- Mention likely downstream concepts only when they are genuinely related.
- Explain the dependency in simple language.

FORMATTING:
- Use clean plain text.
- Use emojis such as ⚠️, 🔗, 🧠, and 💡.
- Do NOT use **bold**.
- Do NOT use ## headings.
- Do NOT use Markdown tables.
- Keep it clear and student-friendly.

Use a structure similar to:

⚠️ WHAT YOU MAY MISS
...

🔗 WHAT COMES AFTER IT
...

🧠 WHY IT MATTERS
...

💡 SHOULD YOU SKIP IT?
...

🎯 SIMPLE EXAMPLE
...

Return only the learner-facing explanation.
"""

    result = generate_with_retry(prompt)

    return clean_ai_text(result)


# ============================================================
# 4. AI VISUAL EXPLANATION
# ============================================================

def visual_explanation(topic):
    prompt = f"""
You are the visual-teaching engine inside LearnRoot.

Create a beginner-friendly animated visual lesson for this Computer Engineering topic:

{topic}

The student should understand the topic by LOOKING at the diagram while a teacher explains it.
Do not create a generic flowchart that could describe any topic.

IMPORTANT:
The diagram must be SPECIFIC to the actual topic.
Think like a teacher drawing on a classroom board:
- Pointers: variable, memory address, pointer, arrow to the address/value.
- Arrays: indexed memory cells with values and index labels.
- Linked lists: nodes connected by arrows, ending in NULL.
- Stack: stacked items with TOP and push/pop direction.
- Queue: people/items in a line with FRONT and REAR.
- Binary tree: parent and child nodes.
- Operators and expressions: operands -> operator -> expression -> evaluated result.
- Sorting: unsorted values -> comparisons/swaps -> sorted values.
- Searching: data -> search target -> comparisons -> found/not found.
- Functions: input -> function block -> parameters/work -> return value.
- Loops: initialization -> condition -> repeated body -> update -> exit.
- OOP: class -> object -> attributes/methods.
- DBMS: table/rows/columns -> query -> result.
- OS: application -> OS services -> hardware.
- Networking: sender -> packets -> network -> receiver.
For any other topic, invent a meaningful domain-specific diagram based on the actual concept.

Return ONLY valid JSON. No Markdown. No code fences.

Use exactly this structure:

{{
  "topic": "{topic}",
  "central_idea": "One or two clear sentences.",
  "analogy": "A simple real-world mental picture.",
  "diagram": {{
    "title": "Short topic-specific diagram title",
    "subtitle": "What the student should follow in the diagram",
    "nodes": [
      {{
        "id": "n1",
        "label": "Short label",
        "value": "Optional value or notation",
        "caption": "Very short explanation",
        "kind": "generic",
        "stage": 0
      }}
    ],
    "connections": [
      {{
        "from": "n1",
        "to": "n2",
        "label": "Short relationship",
        "stage": 0
      }}
    ]
  }},
  "steps": [
    {{
      "title": "Short teaching step title",
      "description": "Explain what the student should notice in the diagram and why."
    }}
  ],
  "example": "A small concrete example or code example when appropriate.",
  "remember": "The most important point to remember.",
  "teacher_script": "A natural classroom-style explanation that follows the diagram from beginning to end."
}}

DIAGRAM RULES:
- Create 3 to 6 nodes.
- Every node must be directly related to the selected topic.
- Do NOT use generic labels such as INPUT, RESULT, PROCESS, or the topic name as a substitute for real concepts.
- Use short labels that fit inside visual boxes.
- Use value for code symbols, sample values, addresses, formulas, or other useful visual details.
- Use caption for one short clarification.
- kind should describe the visual object: memory, data, code, process, input, output, person, tree, table, generic.
- stage is a zero-based teaching stage. Start with 0 and increase as the teacher reveals the diagram.
- Connections must use node IDs that exist.
- Use arrows/connections to show the actual relationship between concepts.
- The diagram must work as a visual explanation, not as a decorative flowchart.

TEACHING RULES:
- Create 4 to 6 logical steps.
- Each step should explain something visible in the diagram.
- Explain WHY, not just WHAT.
- Use simple but technically correct language.
- Use a concrete example.
- Make teacher_script sound like a professor explaining while pointing at the diagram.
- teacher_script should follow the same order as the diagram and steps.
- Make teacher_script about 45 to 90 seconds.
- No Markdown, no **, no ##, no decorative stars.
- Emojis may be used in learner-facing text, but do NOT use emojis in teacher_script.
- Keep JSON valid.
"""

    result = generate_with_retry(prompt).strip()

    result = re.sub(
        r"^```(?:json)?\s*",
        "",
        result,
        flags=re.IGNORECASE
    )
    result = re.sub(r"\s*```$", "", result)

    try:
        data = json.loads(result)

        for key in [
            "topic",
            "central_idea",
            "analogy",
            "example",
            "remember",
            "teacher_script"
        ]:
            if key in data:
                data[key] = clean_visual_field(data[key])

        # Clean and validate the AI-generated diagram.
        diagram = data.get("diagram")
        if isinstance(diagram, dict):
            diagram["title"] = clean_visual_field(
                diagram.get("title", "See how the concept works")
            )
            diagram["subtitle"] = clean_visual_field(
                diagram.get(
                    "subtitle",
                    "Follow the important parts of the concept"
                )
            )

            raw_nodes = diagram.get("nodes", [])
            cleaned_nodes = []

            if isinstance(raw_nodes, list):
                for index, node in enumerate(raw_nodes[:6]):
                    if not isinstance(node, dict):
                        continue

                    cleaned_nodes.append({
                        "id": str(
                            node.get("id", f"n{index + 1}")
                        ).strip(),
                        "label": clean_visual_field(
                            node.get("label", "Concept")
                        ),
                        "value": clean_visual_field(
                            node.get("value", "")
                        ),
                        "caption": clean_visual_field(
                            node.get("caption", "")
                        ),
                        "kind": clean_visual_field(
                            node.get("kind", "generic")
                        ).lower(),
                        "stage": max(
                            0,
                            min(
                                5,
                                int(node.get("stage", 0))
                                if str(node.get("stage", "0")).isdigit()
                                else 0
                            )
                        )
                    })

            valid_ids = {node["id"] for node in cleaned_nodes}

            raw_connections = diagram.get("connections", [])
            cleaned_connections = []

            if isinstance(raw_connections, list):
                for connection in raw_connections:
                    if not isinstance(connection, dict):
                        continue

                    source = str(
                        connection.get("from", "")
                    ).strip()
                    target = str(
                        connection.get("to", "")
                    ).strip()

                    if source not in valid_ids or target not in valid_ids:
                        continue

                    stage_value = connection.get("stage", 0)
                    stage = (
                        int(stage_value)
                        if str(stage_value).isdigit()
                        else 0
                    )

                    cleaned_connections.append({
                        "from": source,
                        "to": target,
                        "label": clean_visual_field(
                            connection.get("label", "")
                        ),
                        "stage": max(0, min(5, stage))
                    })

            diagram["nodes"] = cleaned_nodes
            diagram["connections"] = cleaned_connections

            if not cleaned_nodes:
                data["diagram"] = {
                    "title": f"How {topic} works",
                    "subtitle": "Follow the key parts and their relationship",
                    "nodes": [
                        {
                            "id": "n1",
                            "label": topic,
                            "value": "",
                            "caption": "Core concept",
                            "kind": "generic",
                            "stage": 0
                        },
                        {
                            "id": "n2",
                            "label": "Example",
                            "value": "",
                            "caption": "Concrete case",
                            "kind": "data",
                            "stage": 1
                        }
                    ],
                    "connections": [
                        {
                            "from": "n1",
                            "to": "n2",
                            "label": "applied as",
                            "stage": 1
                        }
                    ]
                }
        else:
            # This fallback is still topic-specific, unlike the old
            # INPUT -> TOPIC -> RESULT block.
            data["diagram"] = {
                "title": f"How {topic} works",
                "subtitle": "Key ideas connected together",
                "nodes": [
                    {
                        "id": "n1",
                        "label": topic,
                        "value": "",
                        "caption": "Core idea",
                        "kind": "generic",
                        "stage": 0
                    },
                    {
                        "id": "n2",
                        "label": "Example",
                        "value": "",
                        "caption": "Concrete case",
                        "kind": "data",
                        "stage": 1
                    },
                    {
                        "id": "n3",
                        "label": "Result",
                        "value": "",
                        "caption": "What we get",
                        "kind": "output",
                        "stage": 2
                    }
                ],
                "connections": [
                    {
                        "from": "n1",
                        "to": "n2",
                        "label": "used in",
                        "stage": 1
                    },
                    {
                        "from": "n2",
                        "to": "n3",
                        "label": "leads to",
                        "stage": 2
                    }
                ]
            }

        return data

    except json.JSONDecodeError:
        print("Gemini returned invalid visual JSON:")
        print(result)

        return {
            "topic": topic,
            "central_idea": (
                f"Let's understand {topic} using a topic-specific example."
            ),
            "analogy": "",
            "diagram": {
                "title": f"Understanding {topic}",
                "subtitle": "Key idea and example",
                "nodes": [
                    {
                        "id": "n1",
                        "label": topic,
                        "value": "",
                        "caption": "Core concept",
                        "kind": "generic",
                        "stage": 0
                    },
                    {
                        "id": "n2",
                        "label": "Example",
                        "value": "",
                        "caption": "See it in practice",
                        "kind": "data",
                        "stage": 1
                    }
                ],
                "connections": [
                    {
                        "from": "n1",
                        "to": "n2",
                        "label": "example",
                        "stage": 1
                    }
                ]
            },
            "steps": [],
            "example": "",
            "remember": "",
            "teacher_script": ""
        }


# ============================================================
# 5. AI DOUBT SOLVER
# ============================================================

def solve_doubt(topic, question):

    prompt = f"""
You are a contextual academic tutor inside LearnRoot.

Current selected topic:
{topic}

Student's question:
{question}

Your job is to answer the student's question as a patient college
teacher.

SCOPE:
- First determine whether the question is academically related to the
  selected topic.
- If it is unrelated, do not answer it as a general chatbot.
- Instead say exactly:
  "This question is outside the current topic. Please select the appropriate topic."

FOR A RELATED QUESTION:
- Answer the actual question directly.
- Explain the reason behind the answer.
- Use a small analogy or example when it helps.
- If code is relevant, show a tiny correct example.
- Explain confusing symbols or terminology.
- Assume the student may be a beginner.
- Do not make the answer artificially short.
- Do not repeat the question unnecessarily.
- Do not drift into unrelated topics.

FORMATTING:
- Use clean plain text.
- Use emojis such as 🧠, 🔍, 💡, and 💻 where useful.
- Do NOT use **bold** markers.
- Do NOT use ## headings.
- Do NOT use Markdown tables.
- Do NOT use decorative stars.
- Keep paragraphs short.

Return only the learner-facing answer.
"""

    result = generate_with_retry(prompt)

    return clean_ai_text(result)


# ============================================================
# 6. TEACHER-STYLE VOICE
# ============================================================

def generate_voice_script(topic):

    """
    Generate a dedicated classroom-style script for TTS.

    We intentionally use a separate prompt from the visual JSON because
    a voice lesson should sound natural when spoken aloud.
    """

    prompt = f"""
You are a friendly Computer Engineering professor teaching a beginner
student in a classroom.

Prepare a spoken explanation of this topic:

{topic}

This will be converted directly into speech using text-to-speech.

TEACHING STYLE:
- Speak naturally, as if a teacher is explaining the concept to a student.
- Begin with a simple hook or relatable idea.
- Explain the basic idea before technical terminology.
- Use a classroom analogy when useful.
- Walk through the concept step by step.
- Explain WHY things work, not just WHAT they are.
- Give a small practical or code example when appropriate.
- Point out the most common confusion.
- End with a short recap.
- Use natural transitions such as:
  "Okay, let's start with the basic idea."
  "Now look at this part carefully."
  "The important thing to notice is..."
  "Let's take a simple example."
  "So, what should you remember?"
- Sound encouraging and patient.
- Do not sound like a textbook being read aloud.
- Do not say "I am an AI".
- Do not mention this prompt, Gemini, or LearnRoot's internal system.

VOICE FORMATTING:
- Return plain spoken text only.
- Do NOT use Markdown.
- Do NOT use **bold**.
- Do NOT use ## headings.
- Do NOT use bullet symbols.
- Do NOT use emojis because text-to-speech may pronounce them strangely.
- Use short natural paragraphs.
- Use punctuation to create natural pauses.
- Aim for approximately 60 to 100 seconds of speech.
- Do not make unsupported claims.

Return only the spoken classroom explanation.
"""

    result = generate_with_retry(prompt)

    return clean_ai_text(result)


# ============================================================
# 7. VOICE FILE GENERATION
# ============================================================

def generate_voice(topic, explanation=None):
    """
    Generate teacher voice for the visual lesson.

    The visual lesson sends its teacher_script to this function so the
    audio explains the exact same lesson shown on screen.

    We generate WAV directly with pyttsx3 and return the WAV file. This is
    more reliable for the local Flutter Web setup than depending on an
    additional FFmpeg conversion step. Browser audio players can play WAV.
    """

    if explanation is None or not str(explanation).strip():
        explanation = generate_voice_script(topic)

    explanation = clean_ai_text(explanation)

    if not explanation:
        raise RuntimeError("The teacher script is empty.")

    # Use a unique temporary directory so two requests cannot overwrite
    # each other's audio files.
    temp_dir = tempfile.gettempdir()
    unique_id = uuid.uuid4().hex
    wav_file = os.path.join(
        temp_dir,
        f"learnroot_voice_{unique_id}.wav"
    )

    engine = None

    try:
        print("Starting text-to-speech...")
        print(f"Voice script length: {len(explanation)} characters")

        # pyttsx3 uses the installed Windows speech engine on Windows.
        engine = pyttsx3.init()

        engine.setProperty("rate", 145)
        engine.setProperty("volume", 1.0)

        engine.save_to_file(explanation, wav_file)
        engine.runAndWait()

        # Release the speech engine before Flask sends the file.
        try:
            engine.stop()
        except Exception:
            pass

        # pyttsx3 may return from runAndWait before the file is fully visible
        # on some Windows speech-engine configurations, so verify it.
        if not os.path.exists(wav_file):
            raise RuntimeError(
                "Text-to-speech completed but the WAV file was not created. "
                "Please check that Windows text-to-speech is available."
            )

        file_size = os.path.getsize(wav_file)

        if file_size == 0:
            raise RuntimeError("The generated WAV file is empty.")

        print(f"Voice generated successfully: {wav_file} ({file_size} bytes)")

        return wav_file

    except Exception as e:
        if os.path.exists(wav_file):
            try:
                os.remove(wav_file)
            except Exception:
                pass

        print(f"Text-to-speech generation error: {e}")
        raise

    finally:
        if engine is not None:
            try:
                engine.stop()
            except Exception:
                pass


# ============================================================
# HOME / TEST
# ============================================================

@app.route("/", methods=["GET"])
def home():

    return jsonify({
        "message": "LearnRoot AI Visual Tutor API is running.",
        "module": "Module 3 - AI Visual Tutor",
        "model": MODEL,
        "features": [
            "Teacher-style visual explanation",
            "AI summary",
            "Contextual AI doubt solver",
            "What If I Skip?",
            "Teacher-style voice explanation"
        ],
        "endpoints": [
            "/explain",
            "/summary",
            "/visual",
            "/doubt",
            "/skip",
            "/voice"
        ]
    })


# ============================================================
# EXPLANATION API
# ============================================================

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


# ============================================================
# SUMMARY API
# ============================================================

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


# ============================================================
# WHAT IF I SKIP API
# ============================================================

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


# ============================================================
# VISUAL EXPLANATION API
# ============================================================

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


# ============================================================
# DOUBT SOLVER API
# ============================================================

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


# ============================================================
# VOICE API
# ============================================================

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

        script = data.get("script")

        audio_file = generate_voice(
            topic,
            explanation=script
        )

        response = send_file(
            audio_file,
            mimetype="audio/wav",
            as_attachment=False,
            download_name="learnroot_teacher_voice.wav"
        )

        # Delete the temporary WAV after Flask has finished sending it.
        @response.call_on_close
        def cleanup_audio_file():
            try:
                if os.path.exists(audio_file):
                    os.remove(audio_file)
                    print(f"Temporary voice file removed: {audio_file}")
            except Exception as cleanup_error:
                print(f"Voice cleanup warning: {cleanup_error}")

        return response

    except Exception as e:

        print(f"Voice generation error: {e}")

        return jsonify({
            "error": "Voice generation failed.",
            "details": str(e)
        }), 500


# ============================================================
# START SERVER
# ============================================================

if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )
