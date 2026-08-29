from dotenv import load_dotenv
from google import genai
import os
import json

# ---------------------------------------
# Load API key from .env
# ---------------------------------------

load_dotenv()

api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    print("Error: GEMINI_API_KEY not found.")
    exit()

# Create Gemini client
client = genai.Client(api_key=api_key)

MODEL = "gemini-3.6-flash"


# ---------------------------------------
# 1. AI Concept Explanation
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
    Create a short one-shot revision for the topic "{topic}"
    for a Computer Engineering student.

    Include:

    1. Key definition
    2. Important points
    3. Important formulas or syntax, if applicable
    4. One simple example
    5. Common mistakes students make

    Keep it concise and useful for quick exam revision.
    """

    response = client.models.generate_content(
        model=MODEL,
        contents=prompt
    )

    return response.text


# ---------------------------------------
# 3. What If I Skip This Topic?
# ---------------------------------------

def what_if_i_skip(topic):

    prompt = f"""
    The student is thinking about skipping the topic "{topic}".

    Explain what problems the student may face if they skip this topic.

    Include:

    1. Why this topic is important
    2. Which concepts may become difficult later
    3. How skipping it can create learning gaps
    4. Whether the student should study it before moving ahead
    5. Give one simple academic example

    Keep the answer simple, clear and helpful.
    Do not scare the student.
    """

    response = client.models.generate_content(
        model=MODEL,
        contents=prompt
    )

    return response.text


# ---------------------------------------
# 4. AI Visual Explanation
# ---------------------------------------

def visual_explanation(topic):

    prompt = f"""
    Create a simple visual explanation of the topic "{topic}"
    for a Computer Engineering student.

    Break the concept into 4 to 6 simple steps.

    Return ONLY valid JSON in this format:

    {{
        "topic": "Topic name",
        "central_idea": "One short sentence",
        "steps": [
            {{
                "title": "Step 1 title",
                "description": "Short explanation"
            }},
            {{
                "title": "Step 2 title",
                "description": "Short explanation"
            }}
        ]
    }}

    Rules:
    - Do not use Markdown.
    - Do not use ``` or code blocks.
    - Keep each title short.
    - Keep each description short.
    - Arrange the steps in a logical learning sequence.
    """

    response = client.models.generate_content(
        model=MODEL,
        contents=prompt
    )

    result = response.text.strip()

    # Remove markdown code fences if Gemini adds them
    if result.startswith("```"):
        result = result.replace("```json", "")
        result = result.replace("```", "")
        result = result.strip()

    try:
        return json.loads(result)
    except json.JSONDecodeError:
        return {
            "topic": topic,
            "central_idea": "Visual explanation could not be formatted.",
            "steps": []
        }


# ---------------------------------------
# Main Program
# ---------------------------------------

topic = input("Enter a topic: ")


print("\n====================================")
print("       AI CONCEPT EXPLANATION")
print("====================================\n")

print(explain_topic(topic))


print("\n====================================")
print("          ONE-SHOT REVISION")
print("====================================\n")

print(one_shot_revision(topic))


print("\n====================================")
print("       WHAT IF I SKIP THIS TOPIC?")
print("====================================\n")

print(what_if_i_skip(topic))


print("\n====================================")
print("          VISUAL EXPLANATION")
print("====================================\n")

visual = visual_explanation(topic)

print(json.dumps(visual, indent=4))