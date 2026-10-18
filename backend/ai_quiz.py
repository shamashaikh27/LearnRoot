import os
import json
from dotenv import load_dotenv
from google import genai


# ============================================================
# LOAD .ENV
# ============================================================

BACKEND_DIR = os.path.dirname(os.path.abspath(__file__))
ROOT_DIR = os.path.dirname(BACKEND_DIR)

ROOT_ENV = os.path.join(ROOT_DIR, ".env")
BACKEND_ENV = os.path.join(BACKEND_DIR, ".env")

if os.path.exists(ROOT_ENV):
    load_dotenv(ROOT_ENV)

if os.path.exists(BACKEND_ENV):
    load_dotenv(BACKEND_ENV, override=True)


# ============================================================
# GEMINI API KEY
# ============================================================

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

if not GEMINI_API_KEY:
    raise ValueError(
        "GEMINI_API_KEY is not set. "
        "Please add GEMINI_API_KEY inside LearnRoot/.env "
        "or backend/.env"
    )


# ============================================================
# GEMINI MODEL
# ============================================================

MODEL_NAME = os.getenv(
    "GEMINI_MODEL",
    "gemini-2.5-flash"
)


# ============================================================
# CREATE GEMINI CLIENT
# ============================================================

client = genai.Client(
    api_key=GEMINI_API_KEY
)


# ============================================================
# CLEAN GEMINI RESPONSE
# ============================================================

def clean_json_response(text):
    """
    Removes markdown code fences and extracts JSON.
    """

    if not text:
        return ""

    text = text.strip()

    # Remove ```json
    if text.startswith("```json"):
        text = text[7:]

    # Remove ```
    elif text.startswith("```"):
        text = text[3:]

    if text.endswith("```"):
        text = text[:-3]

    text = text.strip()

    # --------------------------------------------------------
    # If Gemini added extra text around JSON, extract the
    # JSON array.
    # --------------------------------------------------------

    start = text.find("[")
    end = text.rfind("]")

    if start != -1 and end != -1 and end > start:
        text = text[start:end + 1]

    return text.strip()


# ============================================================
# VALIDATE QUESTION
# ============================================================

def validate_question(question, index):

    if not isinstance(question, dict):
        raise ValueError(
            f"Question {index} is not a JSON object."
        )

    required_fields = [
        "question",
        "option_a",
        "option_b",
        "option_c",
        "option_d",
        "correct_answer",
        "solution",
        "difficulty"
    ]

    # --------------------------------------------------------
    # CHECK REQUIRED FIELDS
    # --------------------------------------------------------

    for field in required_fields:

        if field not in question:

            raise ValueError(
                f"Question {index} is missing field: {field}"
            )

    # --------------------------------------------------------
    # CONVERT TEXT FIELDS TO STRING
    # --------------------------------------------------------

    for field in required_fields:

        if question[field] is None:
            question[field] = ""

        question[field] = str(
            question[field]
        ).strip()

    # --------------------------------------------------------
    # CHECK QUESTION
    # --------------------------------------------------------

    if not question["question"]:
        raise ValueError(
            f"Question {index} has empty question text."
        )

    # --------------------------------------------------------
    # CHECK OPTIONS
    # --------------------------------------------------------

    option_fields = [
        "option_a",
        "option_b",
        "option_c",
        "option_d"
    ]

    for option in option_fields:

        if not question[option]:

            raise ValueError(
                f"Question {index} has an empty option."
            )

    # --------------------------------------------------------
    # CHECK CORRECT ANSWER
    # --------------------------------------------------------

    question["correct_answer"] = (
        question["correct_answer"]
        .strip()
        .upper()
    )

    if question["correct_answer"] not in [
        "A",
        "B",
        "C",
        "D"
    ]:

        raise ValueError(
            f"Question {index} has invalid correct_answer: "
            f"{question['correct_answer']}"
        )

    # --------------------------------------------------------
    # CHECK DIFFICULTY
    # --------------------------------------------------------

    difficulty = question["difficulty"].strip().title()

    if difficulty not in [
        "Easy",
        "Moderate",
        "Hard"
    ]:

        raise ValueError(
            f"Question {index} has invalid difficulty: "
            f"{question['difficulty']}"
        )

    question["difficulty"] = difficulty

    return question


# ============================================================
# FALLBACK QUIZ
# ============================================================

def fallback_quiz(topic_name):

    topic_lower = topic_name.strip().lower()

    # ========================================================
    # BINARY SEARCH TREE
    # ========================================================

    if topic_lower in [
        "binary search tree",
        "binary search trees",
        "bst"
    ]:

        return [

            {
                "question":
                    "Which property defines a Binary Search Tree?",
                "option_a":
                    "Left subtree keys are smaller and right subtree keys are larger.",
                "option_b":
                    "Every node must have exactly two children.",
                "option_c":
                    "All nodes must be stored at the same level.",
                "option_d":
                    "The root must always contain the smallest key.",
                "correct_answer":
                    "A",
                "solution":
                    "In a Binary Search Tree, keys in the left subtree are smaller than the node key and keys in the right subtree are larger.",
                "difficulty":
                    "Easy"
            },

            {
                "question":
                    "Which traversal of a Binary Search Tree produces keys in sorted order?",
                "option_a":
                    "Pre-order traversal",
                "option_b":
                    "Post-order traversal",
                "option_c":
                    "In-order traversal",
                "option_d":
                    "Level-order traversal",
                "correct_answer":
                    "C",
                "solution":
                    "In-order traversal visits the left subtree, root, and right subtree, producing sorted keys in a Binary Search Tree.",
                "difficulty":
                    "Easy"
            },

            {
                "question":
                    "What is the worst-case search time in an unbalanced Binary Search Tree containing N nodes?",
                "option_a":
                    "O(1)",
                "option_b":
                    "O(log N)",
                "option_c":
                    "O(N)",
                "option_d":
                    "O(N log N)",
                "correct_answer":
                    "C",
                "solution":
                    "An unbalanced Binary Search Tree can become skewed like a linked list, making search take O(N) time in the worst case.",
                "difficulty":
                    "Moderate"
            },

            {
                "question":
                    "When deleting a node with two children from a Binary Search Tree, which replacement preserves the ordering property?",
                "option_a":
                    "Its in-order predecessor or successor",
                "option_b":
                    "Always the root node",
                "option_c":
                    "Always the smallest leaf",
                "option_d":
                    "Always its immediate parent",
                "correct_answer":
                    "A",
                "solution":
                    "The in-order predecessor or in-order successor can replace the deleted node while maintaining BST ordering.",
                "difficulty":
                    "Moderate"
            },

            {
                "question":
                    "Given the BST preorder traversal [45, 25, 15, 35, 75, 55, 65, 85], what is the postorder traversal?",
                "option_a":
                    "[15, 35, 25, 65, 55, 85, 75, 45]",
                "option_b":
                    "[15, 25, 35, 55, 65, 75, 85, 45]",
                "option_c":
                    "[35, 15, 25, 65, 85, 55, 75, 45]",
                "option_d":
                    "[45, 25, 15, 35, 55, 65, 75, 85]",
                "correct_answer":
                    "A",
                "solution":
                    "Postorder visits the left subtree, right subtree, and root. The left subtree gives [15, 35, 25], the right subtree gives [65, 55, 85, 75], and the root 45 is visited last.",
                "difficulty":
                    "Hard"
            }

        ]

    # ========================================================
    # GENERIC FALLBACK
    # ========================================================

    return [

        {
            "question":
                f"What is an important characteristic of {topic_name}?",
            "option_a":
                f"It follows the main principles associated with {topic_name}.",
            "option_b":
                "It completely removes the need for problem solving.",
            "option_c":
                "It is unrelated to computer science.",
            "option_d":
                "It requires no understanding of its concepts.",
            "correct_answer":
                "A",
            "solution":
                f"Understanding the main principles is essential when studying {topic_name}.",
            "difficulty":
                "Easy"
        },

        {
            "question":
                f"Which approach is useful when learning {topic_name}?",
            "option_a":
                "Ignoring examples",
            "option_b":
                "Applying concepts to relevant problems",
            "option_c":
                "Avoiding practice",
            "option_d":
                "Memorizing unrelated information",
            "correct_answer":
                "B",
            "solution":
                f"Applying the concepts of {topic_name} to relevant problems helps develop understanding.",
            "difficulty":
                "Easy"
        },

        {
            "question":
                f"Why are practical examples useful for {topic_name}?",
            "option_a":
                "They connect concepts with real problems.",
            "option_b":
                "They eliminate every possible error.",
            "option_c":
                "They remove the need for theory.",
            "option_d":
                "They make all problems identical.",
            "correct_answer":
                "A",
            "solution":
                f"Practical examples connect the theory of {topic_name} with real problems.",
            "difficulty":
                "Moderate"
        },

        {
            "question":
                f"What is important when solving problems involving {topic_name}?",
            "option_a":
                "Applying the correct concepts and rules",
            "option_b":
                "Ignoring the problem conditions",
            "option_c":
                "Using unrelated concepts",
            "option_d":
                "Avoiding analysis",
            "correct_answer":
                "A",
            "solution":
                f"Correctly applying the concepts and rules of {topic_name} is important for solving problems.",
            "difficulty":
                "Moderate"
        },

        {
            "question":
                f"What is generally required for advanced problems involving {topic_name}?",
            "option_a":
                "Combining related concepts and applying them correctly",
            "option_b":
                "Ignoring the underlying principles",
            "option_c":
                "Avoiding problem solving",
            "option_d":
                "Using unrelated information",
            "correct_answer":
                "A",
            "solution":
                f"Advanced problems involving {topic_name} require combining and correctly applying related concepts.",
            "difficulty":
                "Hard"
        }

    ]


# ============================================================
# GENERATE QUIZ
# ============================================================

def generate_quiz(topic_name):

    if not topic_name:
        raise ValueError(
            "Topic name is required."
        )

    topic_name = str(topic_name).strip()

    if not topic_name:
        raise ValueError(
            "Topic name cannot be empty."
        )

    # ========================================================
    # IMPORTANT:
    # DO NOT USE f-string JSON braces directly.
    #
    # We use a normal string for the JSON structure below.
    # This prevents the "Invalid format specifier" error.
    # ========================================================

    prompt = f"""
Create a high-quality educational quiz for the following topic:

Topic: {topic_name}

Generate EXACTLY 5 multiple-choice questions.

Difficulty distribution:
- Question 1: Easy
- Question 2: Easy
- Question 3: Moderate
- Question 4: Moderate
- Question 5: Hard

Requirements:

1. All questions must be directly related to the given topic.
2. Questions must test actual understanding.
3. Do not create generic questions.
4. Do not ask vague questions.
5. Include definitions, concepts, applications, examples,
   complexity, problem solving, or topic-specific knowledge.
6. Each question must have exactly 4 options.
7. Only ONE option must be correct.
8. correct_answer must be A, B, C, or D.
9. Include a short explanation in solution.
10. Include difficulty.
11. Do not use Markdown.
12. Return ONLY valid JSON.
13. Do not use ```json code fences.
14. Make all questions different.
15. Make the quiz suitable for a college-level engineering student.

The JSON must contain these fields:

question
option_a
option_b
option_c
option_d
correct_answer
solution
difficulty

Difficulty values must be exactly:
Easy
Moderate
Hard

Return exactly 5 questions as a JSON array.
"""

    # ========================================================
    # CALL GEMINI
    # ========================================================

    try:

        print()
        print("==============================================")
        print("Generating Gemini AI Quiz")
        print(f"Topic: {topic_name}")
        print(f"Model: {MODEL_NAME}")
        print("==============================================")

        response = client.models.generate_content(
            model=MODEL_NAME,
            contents=prompt
        )

        # ====================================================
        # CHECK RESPONSE
        # ====================================================

        if not response:

            raise ValueError(
                "Gemini returned no response."
            )

        if not response.text:

            raise ValueError(
                "Gemini returned an empty response."
            )

        text = response.text.strip()

        print("Gemini response received.")

        # ====================================================
        # CLEAN RESPONSE
        # ====================================================

        text = clean_json_response(text)

        if not text:

            raise ValueError(
                "Gemini returned empty JSON."
            )

        print("Parsing Gemini JSON...")

        # ====================================================
        # PARSE JSON
        # ====================================================

        questions = json.loads(text)

        # ====================================================
        # CHECK LIST
        # ====================================================

        if not isinstance(questions, list):

            raise ValueError(
                "Gemini response is not a JSON list."
            )

        # ====================================================
        # CHECK COUNT
        # ====================================================

        if len(questions) < 5:

            raise ValueError(
                f"Gemini returned only {len(questions)} questions."
            )

        # Keep exactly 5

        questions = questions[:5]

        # ====================================================
        # VALIDATE EVERY QUESTION
        # ====================================================

        validated_questions = []

        for index, question in enumerate(
            questions,
            start=1
        ):

            validated = validate_question(
                question,
                index
            )

            validated_questions.append(
                validated
            )

        # ====================================================
        # CHECK DIFFICULTY
        # ========================================================

        difficulties = [
            question["difficulty"]
            for question in validated_questions
        ]

        easy_count = difficulties.count("Easy")
        moderate_count = difficulties.count("Moderate")
        hard_count = difficulties.count("Hard")

        if (
            easy_count != 2
            or moderate_count != 2
            or hard_count != 1
        ):

            raise ValueError(
                "Gemini returned incorrect difficulty distribution."
            )

        # ====================================================
        # SUCCESS
        # ====================================================

        print("==============================================")
        print("Gemini quiz generated successfully.")
        print(f"Questions: {len(validated_questions)}")
        print("Difficulty: 2 Easy + 2 Moderate + 1 Hard")
        print("==============================================")
        print()

        return validated_questions

    # ========================================================
    # ERROR + FALLBACK
    # ========================================================

    except json.JSONDecodeError as error:

        print()
        print("==============================================")
        print("Gemini JSON Parsing Error")
        print(error)
        print("==============================================")

        print(
            f"Using fallback quiz for: {topic_name}"
        )

        return fallback_quiz(topic_name)

    except Exception as error:

        print()
        print("==============================================")
        print("Gemini Quiz Generation Error")
        print(str(error))
        print("==============================================")

        print(
            f"Using fallback quiz for: {topic_name}"
        )

        return fallback_quiz(topic_name)