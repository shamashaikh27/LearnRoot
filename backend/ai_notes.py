import os
from dotenv import load_dotenv
from google import genai


# ============================================================
# FIND LEARNROOT FOLDERS
# ============================================================

BACKEND_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(BACKEND_DIR)

ROOT_ENV = os.path.join(ROOT_DIR, ".env")
BACKEND_ENV = os.path.join(BACKEND_DIR, ".env")


# ============================================================
# LOAD .ENV FILES
# ============================================================

if os.path.exists(ROOT_ENV):
    load_dotenv(ROOT_ENV)

if os.path.exists(BACKEND_ENV):
    load_dotenv(BACKEND_ENV, override=True)


# ============================================================
# GET GEMINI API KEY
# ============================================================

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

if not GEMINI_API_KEY:
    raise ValueError(
        "GEMINI_API_KEY is not set.\n"
        "Please add GEMINI_API_KEY=YOUR_KEY inside LearnRoot/.env "
        "or backend/.env"
    )


# ============================================================
# GET GEMINI MODEL
# ============================================================

MODEL_NAME = os.getenv(
    "GEMINI_MODEL",
    "gemini-2.5-flash"
)


# ============================================================
# CREATE GEMINI CLIENT
# ============================================================

try:

    client = genai.Client(
        api_key=GEMINI_API_KEY
    )

except Exception as error:

    print("Gemini Client Error:")
    print(type(error).__name__)
    print(str(error))

    client = None


# ============================================================
# GENERATE AI NOTES
# ============================================================

def generate_notes(topic_name):

    """
    Generate general AI study notes for a topic.

    IMPORTANT:
    These notes are NOT personalized.

    The same generated notes can be stored in MySQL
    and shown to all students studying the same topic.

    Database storage is handled by the Flask route.
    """


    # ========================================================
    # VALIDATE TOPIC NAME
    # ========================================================

    if not topic_name:

        print(
            "AI Notes Error: Topic name is empty."
        )

        return None


    topic_name = str(
        topic_name
    ).strip()


    if not topic_name:

        print(
            "AI Notes Error: Topic name is empty."
        )

        return None


    # ========================================================
    # CHECK GEMINI CLIENT
    # ========================================================

    if client is None:

        print(
            "AI Notes Error: Gemini client is not available."
        )

        return None


    # ========================================================
    # AI NOTES PROMPT
    # ========================================================

    prompt = f"""
You are an educational study-notes generator for LearnRoot.

Create complete, accurate, exam-oriented study notes for the
following academic topic:

Topic: {topic_name}

IMPORTANT:

These notes will be stored in a MySQL database and shown to
ALL students who study this topic.

Therefore, the notes MUST be general topic notes.

Do NOT:
- Personalize the notes for a particular student.
- Mention student scores.
- Mention student performance.
- Give personalized recommendations.
- Say that the student needs improvement.
- Mention Gemini.
- Mention that you are an AI.
- Create quiz questions.
- Include unrelated topics.

The notes should help a college-level engineering student
understand the topic and prepare for examinations.

Use the following structure:

# {topic_name}

## 1. Introduction

Explain:
- What the topic is.
- Why the topic is important.
- Where it is used.

## 2. Important Concepts

Explain the main concepts of the topic.

For every important concept:
- Give a clear definition.
- Explain it in simple words.
- Explain how it works where applicable.

## 3. Working / Process

If the topic has a process, algorithm, mechanism, or working procedure,
explain it step by step in the correct order.

If the topic does not have a specific process, explain its main operation
or mechanism instead.

## 4. Key Points

Give the most important points that students should remember.

Use bullet points.

## 5. Simple Example

Give at least one simple and relevant example.

Explain the example clearly.

If the topic is an algorithm or technical process, show a small
example where appropriate.

## 6. Advantages

List the important advantages of the topic where applicable.

## 7. Applications

Explain practical applications and real-world or computer-science
uses of the topic where applicable.

## 8. Important Terms

List important technical terms related to the topic.

For each term:
Term — Short and simple meaning.

## 9. Formulas

If the topic contains formulas:

- Write each important formula.
- Explain every variable.
- Explain what the formula is used for.
- Give a simple numerical example where useful.

If the topic has no important formulas, write:

No major formula.

## 10. Quick Revision

Give 5 to 8 short points for last-minute revision.

These should contain the most important facts from the topic.

## 11. Exam Tips

Give useful exam-oriented points such as:

- Important definitions to remember.
- Important differences.
- Important steps.
- Important formulas.
- Important diagrams to practice.
- Common points that can be asked in exams.

Do not give personalized study advice.

GENERAL REQUIREMENTS:

- Use simple student-friendly English.
- Explain concepts instead of only giving definitions.
- Use proper headings.
- Use bullet points where useful.
- Keep the notes reasonably detailed.
- Make the notes suitable for engineering examinations.
- Include formulas when applicable.
- Include examples when applicable.
- Include processes and steps when applicable.
- Include important terminology.
- Do not invent technical facts.
- Stay focused only on the given topic.
- Avoid unnecessary repetition.
- Do not create quiz questions.
- Do not mention AI.
- Do not mention Gemini.
- Do not mention student scores.
- Do not personalize the notes.

Return ONLY the study notes.
"""


    # ========================================================
    # CALL GEMINI
    # ========================================================

    try:

        print()
        print("==============================================")
        print("GENERATING AI NOTES")
        print("==============================================")
        print(f"Topic : {topic_name}")
        print(f"Model : {MODEL_NAME}")
        print("Calling Gemini API...")
        print("==============================================")


        response = client.models.generate_content(
            model=MODEL_NAME,
            contents=prompt
        )


        # ====================================================
        # CHECK RESPONSE
        # ====================================================

        if response is None:

            print(
                "Gemini returned None response."
            )

            return None


        print(
            "Gemini response received."
        )


        # ====================================================
        # GET RESPONSE TEXT
        # ====================================================

        notes = getattr(
            response,
            "text",
            None
        )


        # ====================================================
        # HANDLE EMPTY RESPONSE
        # ====================================================

        if notes is None:

            print(
                "Gemini response.text is None."
            )

            print(
                "Gemini response:"
            )

            print(response)

            return None


        notes = str(
            notes
        ).strip()


        if not notes:

            print(
                "Gemini returned empty notes."
            )

            print(
                "Gemini response:"
            )

            print(response)

            return None


        # ====================================================
        # REMOVE UNNECESSARY CODE FENCES
        # ====================================================

        if notes.startswith("```"):

            lines = notes.splitlines()

            if len(lines) >= 2:

                # Remove first line such as ```markdown
                lines = lines[1:]

                # Remove final ```
                if lines and lines[-1].strip() == "```":

                    lines = lines[:-1]

                notes = "\n".join(lines).strip()


        # ====================================================
        # VALIDATE MINIMUM CONTENT
        # ====================================================

        if len(notes) < 100:

            print(
                "Gemini returned notes that are too short."
            )

            print(
                f"Characters received: {len(notes)}"
            )

            return None


        # ====================================================
        # SUCCESS
        # ====================================================

        print()
        print("==============================================")
        print("AI NOTES GENERATED SUCCESSFULLY")
        print("==============================================")
        print(f"Topic      : {topic_name}")
        print(f"Characters : {len(notes)}")
        print("==============================================")
        print()


        return notes


    # ========================================================
    # HANDLE GEMINI ERRORS
    # ========================================================

    except Exception as error:

        print()
        print("==============================================")
        print("GEMINI AI NOTES ERROR")
        print("==============================================")

        print(
            "Error Type:",
            type(error).__name__
        )

        print(
            "Error:",
            str(error)
        )

        print("==============================================")
        print()

        return None