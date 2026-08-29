from dotenv import load_dotenv
from google import genai
import os


# ---------------------------------------
# Load API key
# ---------------------------------------

load_dotenv()

api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    print("Error: GEMINI_API_KEY not found.")
    exit()


# ---------------------------------------
# Create Gemini client
# ---------------------------------------

client = genai.Client(api_key=api_key)

MODEL = "gemini-3.6-flash"


# ---------------------------------------
# AI Doubt Solver
# ---------------------------------------

def solve_doubt(topic, question):

    prompt = f"""
    You are an AI tutor for Computer Engineering students.

    The student is currently learning:
    {topic}

    The student's question is:
    {question}

    Answer the question in simple and clear language.

    Rules:
    - Stay related to the given topic.
    - Explain step-by-step when necessary.
    - Give a simple example if useful.
    - Avoid unnecessarily complicated terminology.
    - If the question is unrelated to the topic, politely
      tell the student that it is outside the current topic.
    """

    response = client.models.generate_content(
        model=MODEL,
        contents=prompt
    )

    return response.text


# ---------------------------------------
# Main
# ---------------------------------------

topic = input("Enter the topic you are studying: ")

print("\nAI Doubt Solver")
print("Type 'exit' to stop.\n")


while True:

    question = input("You: ")

    if question.lower() == "exit":
        print("\nAI Tutor: Goodbye! Keep learning.")
        break

    answer = solve_doubt(topic, question)

    print("\nAI Tutor:")
    print(answer)
    print()