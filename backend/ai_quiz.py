import os
import json
from dotenv import load_dotenv
from google import genai

# ============================================================
# LOAD .ENV FROM LEARNROOT ROOT FOLDER
# ============================================================

BASE_DIR = os.path.dirname(
    os.path.dirname(os.path.abspath(__file__))
)

ENV_FILE = os.path.join(BASE_DIR, ".env")

load_dotenv(ENV_FILE)

# ============================================================
# GET GEMINI API KEY
# ============================================================

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")

if not GEMINI_API_KEY:
    raise ValueError(
        "GEMINI_API_KEY is not set in LearnRoot/.env"
    )

# ============================================================
# CREATE GEMINI CLIENT
# ============================================================

client = genai.Client(
    api_key=GEMINI_API_KEY
)

# ============================================================
# GENERATE QUIZ
# ============================================================

def generate_quiz(topic_name):
    """
    Generate exactly 5 multiple-choice questions using Gemini AI.

    Difficulty:
        2 Easy
        2 Moderate
        1 Hard

    Returns:
        List of 5 quiz questions.
    """

    # ========================================================
    # GEMINI PROMPT
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

1. All questions must be directly related to {topic_name}.
2. Questions must test actual understanding.
3. Do not create generic learning questions.
4. Do not ask questions like "What is a fundamental idea?"
5. Include concepts, definitions, applications, complexity, examples,
   problem solving, or other topic-specific knowledge where appropriate.
6. Each question must have exactly 4 options.
7. Only ONE option must be correct.
8. The correct answer must be one of A, B, C, or D.
9. Include a short explanation of the correct answer.
10. Include the difficulty level.
11. Do not use Markdown.
12. Return ONLY valid JSON.
13. Do not put JSON inside ```json or ``` code fences.

Return exactly this structure:

[
  {
    "question": "Question text",
    "option_a": "Option A",
    "option_b": "Option B",
    "option_c": "Option C",
    "option_d": "Option D",
    "correct_answer": "A",
    "solution": "Short explanation",
    "difficulty": "Easy"
  }
]

Make the questions different from each other and suitable for a
college-level computer science student.
"""


    # ========================================================
    # CALL GEMINI
    # ========================================================

    try:

        response = client.models.generate_content(
            model="gemini-3.6-flash",
            contents=prompt
        )


        # ====================================================
        # GET RESPONSE TEXT
        # ====================================================

        if not response or not response.text:

            raise ValueError(
                "Gemini returned an empty response."
            )


        text = response.text.strip()


        # ====================================================
        # REMOVE MARKDOWN CODE FENCES
        # ====================================================

        if text.startswith("```json"):

            text = text[7:]

        elif text.startswith("```"):

            text = text[3:]


        if text.endswith("```"):

            text = text[:-3]


        text = text.strip()


        # ====================================================
        # CONVERT JSON STRING TO PYTHON OBJECT
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
        # CHECK QUESTION COUNT
        # ====================================================

        if len(questions) < 5:

            raise ValueError(
                f"Gemini returned only {len(questions)} questions."
            )


        # Keep exactly 5 questions

        questions = questions[:5]


        # ====================================================
        # REQUIRED FIELDS
        # ====================================================

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


        # ====================================================
        # VALIDATE QUESTIONS
        # ====================================================

        for index, question in enumerate(questions):

            if not isinstance(question, dict):

                raise ValueError(
                    f"Question {index + 1} is not an object."
                )


            for field in required_fields:

                if field not in question:

                    raise ValueError(
                        f"Question {index + 1} is missing field: {field}"
                    )


            # -----------------------------------------------
            # CHECK CORRECT ANSWER
            # -----------------------------------------------

            question["correct_answer"] = (
                str(question["correct_answer"])
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
                    f"Question {index + 1} has invalid correct answer."
                )


            # -----------------------------------------------
            # CHECK DIFFICULTY
            # -----------------------------------------------

            allowed_difficulties = [
                "Easy",
                "Moderate",
                "Hard"
            ]

            if question["difficulty"] not in allowed_difficulties:

                raise ValueError(
                    f"Question {index + 1} has invalid difficulty."
                )


            # -----------------------------------------------
            # CHECK OPTIONS ARE NOT EMPTY
            # -----------------------------------------------

            option_fields = [
                "option_a",
                "option_b",
                "option_c",
                "option_d"
            ]

            for option in option_fields:

                if not str(question[option]).strip():

                    raise ValueError(
                        f"Question {index + 1} has an empty option."
                    )


        # ====================================================
        # CHECK DIFFICULTY DISTRIBUTION
        # ====================================================

        difficulties = [
            question["difficulty"]
            for question in questions
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

        print(
            f"Gemini quiz generated successfully for: {topic_name}"
        )


        return questions


    # ========================================================
    # GEMINI ERROR
    # ========================================================

    except Exception as error:

        print(
            "Gemini quiz generation error:",
            error
        )


        # ====================================================
        # FALLBACK QUIZ
        # ====================================================

        print(
            f"Using fallback quiz for: {topic_name}"
        )


        return [

            # =================================================
            # QUESTION 1 - EASY
            # =================================================

            {
                "question": (
                    f"Which statement correctly describes "
                    f"a Binary Search Tree?"
                    if topic_name.lower() == "binary search tree"
                    else f"Which statement best describes {topic_name}?"
                ),

                "option_a": (
                    "Every left subtree contains smaller keys "
                    "and every right subtree contains larger keys."
                    if topic_name.lower() == "binary search tree"
                    else f"It follows the fundamental rules of {topic_name}."
                ),

                "option_b": "Every node must have exactly two children.",

                "option_c": "All nodes must be stored at the same level.",

                "option_d": "The root node must always contain the smallest value.",

                "correct_answer": "A",

                "solution": (
                    "A Binary Search Tree follows the ordering rule "
                    "where smaller keys are placed in the left subtree "
                    "and larger keys are placed in the right subtree."
                    if topic_name.lower() == "binary search tree"
                    else f"The fundamental rules are essential for understanding {topic_name}."
                ),

                "difficulty": "Easy"
            },


            # =================================================
            # QUESTION 2 - EASY
            # =================================================

            {
                "question": (
                    "Which traversal of a Binary Search Tree "
                    "produces the keys in sorted order?"
                    if topic_name.lower() == "binary search tree"
                    else f"Which approach is commonly used to understand {topic_name}?"
                ),

                "option_a": "Pre-order traversal",

                "option_b": "Post-order traversal",

                "option_c": (
                    "In-order traversal"
                    if topic_name.lower() == "binary search tree"
                    else "Systematic application of its concepts"
                ),

                "option_d": "Level-order traversal",

                "correct_answer": "C",

                "solution": (
                    "In-order traversal visits the left subtree, "
                    "the node, and then the right subtree, producing "
                    "sorted keys in a Binary Search Tree."
                    if topic_name.lower() == "binary search tree"
                    else f"Systematic application helps demonstrate understanding of {topic_name}."
                ),

                "difficulty": "Easy"
            },


            # =================================================
            # QUESTION 3 - MODERATE
            # =================================================

            {
                "question": (
                    "What is the worst-case time complexity of searching "
                    "for a value in an unbalanced Binary Search Tree "
                    "containing N nodes?"
                    if topic_name.lower() == "binary search tree"
                    else f"Why is practical application important when studying {topic_name}?"
                ),

                "option_a": (
                    "O(1)"
                    if topic_name.lower() == "binary search tree"
                    else "It connects theoretical concepts with problems."
                ),

                "option_b": (
                    "O(log N)"
                    if topic_name.lower() == "binary search tree"
                    else "It removes the need to understand the topic."
                ),

                "option_c": (
                    "O(N)"
                    if topic_name.lower() == "binary search tree"
                    else "It eliminates all possible errors."
                ),

                "option_d": (
                    "O(N log N)"
                    if topic_name.lower() == "binary search tree"
                    else "It makes every problem automatically simple."
                ),

                "correct_answer": "C",

                "solution": (
                    "An unbalanced Binary Search Tree can become skewed "
                    "like a linked list, so searching may require checking "
                    "up to N nodes, giving O(N)."
                    if topic_name.lower() == "binary search tree"
                    else f"Practical application helps connect the concepts of {topic_name} with actual problems."
                ),

                "difficulty": "Moderate"
            },


            # =================================================
            # QUESTION 4 - MODERATE
            # =================================================

            {
                "question": (
                    "When deleting a node with two children from a "
                    "Binary Search Tree, which value can replace it "
                    "while maintaining the BST ordering property?"
                    if topic_name.lower() == "binary search tree"
                    else f"Which method best demonstrates understanding of {topic_name}?"
                ),

                "option_a": (
                    "Its in-order predecessor or in-order successor"
                    if topic_name.lower() == "binary search tree"
                    else "Applying the concept to a relevant problem"
                ),

                "option_b": (
                    "Always the root of the tree"
                    if topic_name.lower() == "binary search tree"
                    else "Ignoring the underlying rules"
                ),

                "option_c": (
                    "Always the smallest leaf in the tree"
                    if topic_name.lower() == "binary search tree"
                    else "Avoiding examples and practice"
                ),

                "option_d": (
                    "Always the immediate parent"
                    if topic_name.lower() == "binary search tree"
                    else "Memorizing unrelated information"
                ),

                "correct_answer": "A",

                "solution": (
                    "For a node with two children, its in-order predecessor "
                    "or in-order successor can replace its value while "
                    "preserving the Binary Search Tree ordering."
                    if topic_name.lower() == "binary search tree"
                    else f"Applying {topic_name} to a relevant problem demonstrates whether its concepts are understood."
                ),

                "difficulty": "Moderate"
            },


            # =================================================
            # QUESTION 5 - HARD
            # =================================================

            {
                "question": (
                    "Given the pre-order traversal [45, 25, 15, 35, "
                    "75, 55, 65, 85] of a Binary Search Tree, what is "
                    "the corresponding post-order traversal?"
                    if topic_name.lower() == "binary search tree"
                    else f"What is generally required to solve advanced problems involving {topic_name}?"
                ),

                "option_a": (
                    "[15, 35, 25, 65, 55, 85, 75, 45]"
                    if topic_name.lower() == "binary search tree"
                    else "Combining multiple related concepts and applying them correctly"
                ),

                "option_b": (
                    "[15, 25, 35, 55, 65, 75, 85, 45]"
                    if topic_name.lower() == "binary search tree"
                    else "Ignoring the underlying principles"
                ),

                "option_c": (
                    "[35, 15, 25, 65, 85, 55, 75, 45]"
                    if topic_name.lower() == "binary search tree"
                    else "Avoiding analysis and problem solving"
                ),

                "option_d": (
                    "[45, 25, 15, 35, 55, 65, 75, 85]"
                    if topic_name.lower() == "binary search tree"
                    else "Using unrelated information"
                ),

                "correct_answer": "A",

                "solution": (
                    "The BST has root 45. Its left subtree produces "
                    "[15, 35, 25], while its right subtree produces "
                    "[65, 55, 85, 75]. Finally, the root 45 is visited, "
                    "giving [15, 35, 25, 65, 55, 85, 75, 45]."
                    if topic_name.lower() == "binary search tree"
                    else f"Advanced problems involving {topic_name} require combining and correctly applying related concepts."
                ),

                "difficulty": "Hard"
            }

        ]