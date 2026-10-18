import os
import json
from dotenv import load_dotenv
from google import genai

# ============================================================
# LOAD ENVIRONMENT VARIABLES
# ============================================================

load_dotenv()

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

# ============================================================
# CREATE GEMINI CLIENT
# ============================================================

client = genai.Client(
    api_key=GEMINI_API_KEY
)


# ============================================================
# GENERATE AI LEARNING RESOURCES
# ============================================================

def generate_recommendation(topic_name, score):
    """
    Generate learning notes and resources using Gemini.

    Resources are ALWAYS generated, regardless of score.

    Score levels:
        Below 50%  -> Needs Improvement
        50-79%     -> Practice
        80%+       -> Advanced Learning
    """

    # --------------------------------------------------------
    # DETERMINE LEARNING LEVEL
    # --------------------------------------------------------

    if score < 50:
        level = "Needs Improvement"

    elif score < 80:
        level = "Practice"

    else:
        level = "Advanced Learning"


    # --------------------------------------------------------
    # GEMINI PROMPT
    # --------------------------------------------------------

    prompt = f"""
Create high-quality educational learning resources for this topic:

Topic: "{topic_name}"

Student quiz score: {score}%

Learning level: {level}

The resources MUST be useful for a college engineering student.

IMPORTANT:
- Always provide learning resources.
- Never hide or remove notes because the score is low.
- If the score is below 50%, provide simple and clear notes to help the student improve.
- If the score is between 50% and 79%, provide notes plus practice guidance.
- If the score is 80% or above, provide advanced learning and revision material.
- Content must be directly related to the topic.
- Do not give generic advice.
- Use simple and easy-to-understand language.
- Include important concepts and examples.
- Do not use markdown.
- Return ONLY valid JSON.

Generate the following:

1. A short summary of the topic.
2. Important concepts.
3. Detailed notes.
4. Key points for revision.
5. One simple example.
6. Common mistakes students make.
7. What the student should study next.
8. Practice suggestions.

Use EXACTLY this JSON structure:

{{
    "topic": "{topic_name}",
    "score": {score},
    "level": "{level}",
    "summary": "Short summary",
    "important_concepts": [
        "Concept 1",
        "Concept 2",
        "Concept 3"
    ],
    "notes": [
        {{
            "heading": "Heading",
            "content": "Detailed explanation"
        }}
    ],
    "key_points": [
        "Key point 1",
        "Key point 2",
        "Key point 3"
    ],
    "example": "Simple example",
    "common_mistakes": [
        "Mistake 1",
        "Mistake 2"
    ],
    "study_next": [
        "What to study next 1",
        "What to study next 2"
    ],
    "practice_suggestions": [
        "Practice suggestion 1",
        "Practice suggestion 2"
    ]
}}
"""


    # --------------------------------------------------------
    # CALL GEMINI
    # --------------------------------------------------------

    try:

        response = client.models.generate_content(
            model="gemini-3.6-flash",
            contents=prompt
        )

        text = response.text.strip()


        # ----------------------------------------------------
        # REMOVE MARKDOWN CODE FENCES
        # ----------------------------------------------------

        if text.startswith("```"):

            text = text.replace(
                "```json",
                ""
            )

            text = text.replace(
                "```",
                ""
            )

            text = text.strip()


        # ----------------------------------------------------
        # CONVERT GEMINI RESPONSE TO JSON
        # ----------------------------------------------------

        recommendation = json.loads(text)


        # ----------------------------------------------------
        # RETURN GEMINI DATA
        # ----------------------------------------------------

        return recommendation


    except Exception as error:

        print(
            "Gemini recommendation generation error:",
            error
        )


        # ----------------------------------------------------
        # FALLBACK
        # ----------------------------------------------------

        return {

            "topic": topic_name,

            "score": score,

            "level": level,

            "summary":
                f"Basic learning notes for {topic_name}.",

            "important_concepts": [
                f"Understand the basic concepts of {topic_name}.",
                f"Learn the important terms used in {topic_name}.",
                f"Practice problems related to {topic_name}."
            ],

            "notes": [
                {
                    "heading":
                        f"Introduction to {topic_name}",

                    "content":
                        f"Study the fundamental concepts of {topic_name} and understand how they are applied."
                },
                {
                    "heading":
                        "Important Concepts",

                    "content":
                        f"Focus on the main concepts, definitions, operations and examples related to {topic_name}."
                }
            ],

            "key_points": [
                f"Understand the basics of {topic_name}.",
                "Practice important concepts.",
                "Review mistakes after solving questions."
            ],

            "example":
                f"Take a simple example related to {topic_name} and solve it step by step.",

            "common_mistakes": [
                "Memorizing concepts without understanding them.",
                "Not practicing enough questions."
            ],

            "study_next": [
                f"Revise the important concepts of {topic_name}.",
                "Solve additional practice questions."
            ],

            "practice_suggestions": [
                "Solve at least 5 practice questions.",
                "Review incorrect answers and understand the solution."
            ]
        }