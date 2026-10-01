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

from database import get_cached_content, save_ai_content


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

# Versioned cache key for the improved, topic-specific visual lesson.
# Changing this forces old generic visual lessons to be regenerated once.
VISUAL_FEATURE = "visual_v5"


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
# MYSQL AI CONTENT CACHE
# ============================================================

def get_cached_or_generate(subject, topic, feature_type, generator):
    """Return cached AI content or generate and save it."""
    cached_content = get_cached_content(subject, topic, feature_type)

    if cached_content is not None:
        print(f"MySQL cache HIT: {subject} | {topic} | {feature_type}")
        if feature_type.startswith("visual"):
            try:
                return json.loads(cached_content)
            except (json.JSONDecodeError, TypeError):
                print("Cached visual content is invalid JSON. Regenerating.")
        else:
            return cached_content

    print(f"MySQL cache MISS: {subject} | {topic} | {feature_type}")
    generated_content = generator()

    if isinstance(generated_content, (dict, list)):
        content_to_save = json.dumps(generated_content, ensure_ascii=False)
    else:
        content_to_save = str(generated_content)

    save_ai_content(subject, topic, feature_type, content_to_save)
    return generated_content


def get_request_subject(data):
    """Read the selected subject, keeping old topic-only requests working."""
    subject = data.get("subject", "General")
    return str(subject).strip() or "General"


# ============================================================
# 1. TEACHER-STYLE EXPLANATION
# ============================================================

def explain_topic(subject, topic):

    prompt = f"""
You are the main classroom teacher inside LearnRoot, an AI learning
platform for Computer Engineering students.

Teach the student this topic from the selected subject:

Subject: {subject}
Topic: {topic}

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

def summarize_topic(subject, topic):

    prompt = f"""
You are the revision teacher inside LearnRoot.

Create useful exam-oriented revision notes for this selected subject/topic:

Subject: {subject}
Topic: {topic}

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

def what_if_i_skip(subject, topic):

    prompt = f"""
You are the academic mentor inside LearnRoot.

The student is considering skipping this topic:

Subject: {subject}
Topic: {topic}

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

def visual_explanation(subject, topic):
    """Generate a strongly topic-specific visual lesson."""

    prompt = f"""
You are the visual-teaching engine inside LearnRoot, a Computer Engineering
learning platform.

SELECTED SUBJECT: {subject}
SELECTED TOPIC: {topic}

Teach ONLY the selected topic inside the selected subject.
The lesson must feel as if it was designed specifically for this one topic.
Do not silently switch to a broader chapter or a nearby concept.

CORE GOAL:
Create a memorable visual lesson that a beginner can understand by looking
at the diagram while a teacher explains it aloud. The visual should make the
concept easier to remember, not merely decorate the screen.

STRICT ANTI-MONOTONY RULES:
1. Never use a generic INPUT -> TOPIC -> PROCESS -> RESULT flowchart.
2. Never use "Structure of C Program", "Preprocessor Directives", "Input",
   "Process", or "Result" unless the selected topic is actually about that
   concept.
3. Never make unrelated topics share the same diagram vocabulary.
4. Choose the visual metaphor from the actual concept. For example, arrays
   should look like indexed memory cells, a stack should look like a stack,
   normalization should look like tables being decomposed, and TCP should
   look like connection/segments/acknowledgement behaviour.
5. Every node must represent a real object, state, operation, symbol, or
   relationship from the selected topic.
6. At least 4 of the nodes must be topic-specific. Do not fill nodes with
   generic words such as Example, Result, Process, Input, or Output.
7. The diagram title must name or clearly describe the selected topic.
8. Use different relationships and arrangements depending on the topic.
9. Choose ONE visual_type that naturally represents the topic. The visual_type
   controls how LearnRoot draws the lesson, so choose the actual mechanism, not
   a generic flowchart.
10. Include one memorable real-world analogy and one memory hook.
11. The teacher script must explain the same exact visual lesson. Do not
    create a separate unrelated voice lesson.

VISUAL TYPE RULES:
- array: indexed memory cells and value access
- pointer/memory: address/reference relationship
- linked_list: linked data nodes and next references
- stack: vertical LIFO structure with TOP, PUSH and POP
- queue: horizontal FIFO structure with FRONT, REAR, ENQUEUE and DEQUEUE
- tree/hierarchy: branching parent-child structure
- table: rows/fields/keys/relationships
- network: connected devices or packet movement
- process/flow: ordered operations where sequence itself is the concept
- concept: radial concept map for topics that are better explained through related ideas
- If the selected topic is an ER-model/database-design topic, use visual_type "concept"
  and use shape-aware node kinds: entity, relationship, and attribute. Do not use
  generic process nodes for an ER diagram.

VISUAL DESIGN EXAMPLES (adapt, do not copy blindly):
- Pointers: variable value -> memory address -> pointer stores address -> dereference.
- Arrays: index labels -> contiguous cells -> selected index -> value access.
- Linked lists: data nodes -> next references -> traversal -> NULL.
- Stack: TOP -> push -> new top -> pop -> previous top.
- Queue: FRONT -> items -> REAR -> enqueue/dequeue movement.
- Binary tree: root -> child branches -> levels -> traversal/search.
- Sorting: actual values -> comparison -> swap -> ordered sequence.
- Searching: collection -> target -> comparisons -> found/not found.
- Functions: call -> parameters -> local work -> return.
- Recursion: call stack -> repeated smaller call -> base case -> unwind.
- Loops: initialization -> condition -> body -> update -> repeat/exit.
- OOP: class blueprint -> object -> attributes -> methods.
- DBMS: table -> fields/records -> query -> filtered result.
- SQL joins: table A key -> matching table B key -> combined rows.
- Normalization: repeated data -> dependency problem -> decomposed tables -> linked keys.
- OS: process -> scheduler/resources -> CPU/memory -> execution state.
- Networking: sender -> packet/segment -> protocol/network -> receiver.
- IP addressing: network part -> host part -> destination -> packet delivery.
- TCP: connection setup -> sequence numbers -> acknowledgement -> reliable delivery.
- Any other topic: invent a topic-native visual from its actual mechanism.

MEMORY RULE:
The analogy and memory_hook should give the student a strong mental image,
not a vague motivational sentence.

Return ONLY valid JSON. No Markdown. No code fences.

Use exactly this structure:
{{
  "subject": "{subject}",
  "topic": "{topic}",
  "central_idea": "One or two clear sentences about this exact topic.",
  "analogy": "A memorable real-world mental picture specific to this topic.",
  "memory_hook": "A short memorable phrase or mental image for this topic.",
  "visual_type": "array|pointer|linked_list|stack|queue|tree|table|network|hierarchy|process|flow|memory|concept",
  "diagram": {{
    "title": "A topic-specific visual title",
    "subtitle": "What the student should follow visually",
    "nodes": [
      {{
        "id": "n1",
        "label": "Real topic-specific object or action",
        "value": "Useful value, symbol, example, or notation",
        "caption": "Very short explanation",
        "emoji": "One suitable emoji",
        "kind": "entity|relationship|attribute|memory|data|code|process|input|output|person|tree|table|generic",
        "stage": 0
      }}
    ],
    "connections": [
      {{
        "from": "n1",
        "to": "n2",
        "label": "Real relationship",
        "stage": 0
      }}
    ]
  }},
  "steps": [
    {{
      "title": "Short topic-specific teaching step",
      "description": "Explain what the student should notice and why it matters."
    }}
  ],
  "example": "A small correct example or code example when appropriate.",
  "remember": "The most important point to remember.",
  "teacher_script": "A natural classroom-style explanation that follows the visual from beginning to end."
}}

QUALITY CHECK BEFORE RETURNING:
- Confirm the returned topic is exactly: {topic}
- Confirm the returned subject is exactly: {subject}
- Confirm the diagram cannot be reused unchanged for a different topic.
- Confirm at least 4 nodes are genuinely specific to {topic}.
- Confirm the teacher script discusses {topic}, not a broader subject.
- Create 4 to 6 teaching steps.
- Make teacher_script approximately 60 to 100 seconds.
- Use simple but technically correct language.
- Do not use emojis inside teacher_script.
"""

    raw_result = generate_with_retry(prompt).strip()

    def parse_and_validate(result_text):
        cleaned = re.sub(r"^```(?:json)?\s*", "", result_text, flags=re.IGNORECASE)
        cleaned = re.sub(r"\s*```$", "", cleaned).strip()
        data = json.loads(cleaned)

        if str(data.get("topic", "")).strip().casefold() != topic.casefold():
            raise ValueError("Gemini returned a different topic.")

        data["subject"] = subject
        data["topic"] = topic

        for key in [
            "subject", "topic", "central_idea", "analogy", "memory_hook",
            "visual_type", "example", "remember", "teacher_script"
        ]:
            data[key] = clean_visual_field(data.get(key, ""))

        visual_type = clean_visual_field(data.get("visual_type", "concept")).lower()
        allowed_visual_types = {
            "array", "pointer", "linked_list", "stack", "queue", "tree",
            "table", "network", "hierarchy", "process", "flow", "memory",
            "concept"
        }
        if visual_type not in allowed_visual_types:
            visual_type = "concept"
        data["visual_type"] = visual_type

        diagram = data.get("diagram")
        if not isinstance(diagram, dict):
            raise ValueError("Missing diagram object.")
        diagram["visual_type"] = visual_type

        diagram["title"] = clean_visual_field(diagram.get("title", ""))
        diagram["subtitle"] = clean_visual_field(diagram.get("subtitle", ""))

        raw_nodes = diagram.get("nodes", [])
        if not isinstance(raw_nodes, list) or len(raw_nodes) < 4:
            raise ValueError("Diagram needs at least 4 nodes.")

        cleaned_nodes = []
        for index, node in enumerate(raw_nodes[:6]):
            if not isinstance(node, dict):
                continue
            stage_value = node.get("stage", 0)
            try:
                stage = int(stage_value)
            except (TypeError, ValueError):
                stage = 0
            cleaned_nodes.append({
                "id": str(node.get("id", f"n{index + 1}")).strip(),
                "label": clean_visual_field(node.get("label", "")),
                "value": clean_visual_field(node.get("value", "")),
                "caption": clean_visual_field(node.get("caption", "")),
                "emoji": clean_visual_field(node.get("emoji", "💡"))[:4],
                "kind": clean_visual_field(node.get("kind", "generic")).lower(),
                "stage": max(0, min(5, stage)),
            })

        if len(cleaned_nodes) < 4:
            raise ValueError("Too few valid diagram nodes.")

        node_ids = [node["id"] for node in cleaned_nodes]
        if len(set(node_ids)) != len(node_ids):
            raise ValueError("Diagram contains duplicate node IDs.")

        for node in cleaned_nodes:
            if not node["label"]:
                raise ValueError("Every visual node needs a label.")

        allowed_kinds = {
            "entity", "relationship", "attribute", "memory", "data", "code",
            "process", "input", "output", "person", "tree", "table", "generic"
        }

        for node in cleaned_nodes:
            kind = node["kind"].replace("-", "_").strip().lower()
            node["kind"] = kind if kind in allowed_kinds else "generic"

        generic_labels = {
            "input", "result", "process", "example", "output", "topic",
            "structure of c program", "preprocessor directives"
        }
        labels = [node["label"].casefold() for node in cleaned_nodes]
        generic_count = sum(label in generic_labels for label in labels)
        if generic_count >= 2 or len(set(labels)) < 4:
            raise ValueError("Diagram is too generic or repetitive.")

        valid_ids = {node["id"] for node in cleaned_nodes}
        raw_connections = diagram.get("connections", [])
        cleaned_connections = []
        if isinstance(raw_connections, list):
            for connection in raw_connections:
                if not isinstance(connection, dict):
                    continue
                source = str(connection.get("from", "")).strip()
                target = str(connection.get("to", "")).strip()
                if source not in valid_ids or target not in valid_ids:
                    continue
                try:
                    stage = int(connection.get("stage", 0))
                except (TypeError, ValueError):
                    stage = 0
                cleaned_connections.append({
                    "from": source,
                    "to": target,
                    "label": clean_visual_field(connection.get("label", "")),
                    "stage": max(0, min(5, stage)),
                })

        if len(cleaned_connections) < 2:
            raise ValueError("Diagram needs meaningful connections.")

        diagram["nodes"] = cleaned_nodes
        diagram["connections"] = cleaned_connections
        data["diagram"] = diagram

        return data

    try:
        return parse_and_validate(raw_result)
    except (json.JSONDecodeError, ValueError, TypeError) as first_error:
        print(f"Visual lesson validation failed: {first_error}")
        print("Requesting a stricter topic-specific regeneration...")

        repair_prompt = f"""
Create a completely new visual lesson for EXACTLY this Computer Engineering topic.
Subject: {subject}
Topic: {topic}

The previous attempt was rejected because it was too generic or not reliably
specific to the selected topic.

This time, make the diagram unmistakably about {topic}. Do not use INPUT,
PROCESS, RESULT, EXAMPLE, Structure of C Program, or Preprocessor Directives
unless they are genuinely part of {topic}. Use 4 to 6 real topic-specific nodes,
2 or more meaningful relationships, a topic-specific analogy, and a memorable
memory_hook. The teacher_script must follow the same visual and be 60 to 100
seconds long.

Return only JSON with these keys:
subject, topic, central_idea, analogy, memory_hook, visual_type, diagram, steps, example,
remember, teacher_script.
visual_type must be one of: array, pointer, linked_list, stack, queue, tree, table,
network, hierarchy, process, flow, memory, concept. Choose the one that best matches
the actual teaching mechanism of the topic.
The diagram must contain nodes with id, label, value, caption, emoji, kind,
and stage, plus connections with from, to, label, and stage.
"""

        try:
            repaired = generate_with_retry(repair_prompt).strip()
            return parse_and_validate(repaired)
        except Exception as second_error:
            print(f"Strict visual regeneration failed: {second_error}")
            raise RuntimeError(
                f"Could not create a valid topic-specific visual lesson for {subject} - {topic}."
            )


# ============================================================
# 5. AI DOUBT SOLVER
# ============================================================

def solve_doubt(subject, topic, question):

    prompt = f"""
You are a contextual academic tutor inside LearnRoot.

Current selected subject:
{subject}

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

def generate_voice_script(subject, topic):

    """
    Generate a dedicated classroom-style script for TTS.

    We intentionally use a separate prompt from the visual JSON because
    a voice lesson should sound natural when spoken aloud.
    """

    prompt = f"""
You are a friendly Computer Engineering professor teaching a beginner
student in a classroom.

Prepare a spoken explanation of this exact subject/topic:

Subject: {subject}
Topic: {topic}

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

def generate_voice(subject, topic, explanation=None):
    """
    Generate teacher voice for the visual lesson.

    The visual lesson sends its teacher_script to this function so the
    audio explains the exact same lesson shown on screen.

    We generate WAV directly with pyttsx3 and return the WAV file. This is
    more reliable for the local Flutter Web setup than depending on an
    additional FFmpeg conversion step. Browser audio players can play WAV.
    """

    if explanation is None or not str(explanation).strip():
        explanation = generate_voice_script(subject, topic)

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
        return jsonify({"error": "Request body is required."}), 400

    subject = get_request_subject(data)
    topic = data.get("topic")

    if not topic:
        return jsonify({"error": "Topic is required."}), 400

    topic = str(topic).strip()

    try:
        cached_before = get_cached_content(subject, topic, "explain")
        answer = get_cached_or_generate(
            subject, topic, "explain", lambda: explain_topic(subject, topic)
        )

        return jsonify({
            "subject": subject,
            "topic": topic,
            "explanation": answer,
            "source": "mysql" if cached_before is not None else "gemini"
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
        return jsonify({"error": "Request body is required."}), 400

    subject = get_request_subject(data)
    topic = data.get("topic")

    if not topic:
        return jsonify({"error": "Topic is required."}), 400

    topic = str(topic).strip()

    try:
        cached_before = get_cached_content(subject, topic, "summary")
        answer = get_cached_or_generate(
            subject, topic, "summary", lambda: summarize_topic(subject, topic)
        )

        return jsonify({
            "subject": subject,
            "topic": topic,
            "summary": answer,
            "source": "mysql" if cached_before is not None else "gemini"
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
        return jsonify({"error": "Request body is required."}), 400

    subject = get_request_subject(data)
    topic = data.get("topic")

    if not topic:
        return jsonify({"error": "Topic is required."}), 400

    topic = str(topic).strip()

    try:
        cached_before = get_cached_content(subject, topic, "skip")
        answer = get_cached_or_generate(
            subject, topic, "skip", lambda: what_if_i_skip(subject, topic)
        )

        return jsonify({
            "subject": subject,
            "topic": topic,
            "what_if_i_skip": answer,
            "source": "mysql" if cached_before is not None else "gemini"
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
        return jsonify({"error": "Request body is required."}), 400

    subject = get_request_subject(data)
    topic = data.get("topic")

    if not topic:
        return jsonify({"error": "Topic is required."}), 400

    topic = str(topic).strip()

    try:
        cached = get_cached_content(subject, topic, VISUAL_FEATURE)

        if cached is not None:
            print(f"MySQL cache HIT: {subject} | {topic} | {VISUAL_FEATURE}")
            try:
                result = json.loads(cached)
                result["source"] = "mysql"
                return jsonify(result)
            except json.JSONDecodeError:
                print("Cached visual JSON is invalid. Generating again.")

        print(f"MySQL cache MISS: {subject} | {topic} | {VISUAL_FEATURE}")
        result = visual_explanation(subject, topic)

        save_ai_content(
            subject, topic, VISUAL_FEATURE, json.dumps(result, ensure_ascii=False)
        )

        result["source"] = "gemini"
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

    subject = get_request_subject(data)
    topic = data.get("topic")
    question = data.get("question")

    if not topic or not question:
        return jsonify({
            "error": "Topic and question are required."
        }), 400

    try:

        answer = solve_doubt(
            subject,
            topic,
            question
        )

        return jsonify({
            "subject": subject,
            "topic": topic,
            "question": question,
            "answer": answer,
            "source": "gemini"
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

    subject = get_request_subject(data)
    topic = data.get("topic")

    if not topic:
        return jsonify({
            "error": "Topic is required."
        }), 400

    try:

        script = data.get("script")

        audio_file = generate_voice(
            subject,
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
