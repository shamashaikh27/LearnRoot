import tkinter as tk
import json
import os

from dotenv import load_dotenv
from google import genai


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
# Generate visual explanation using AI
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
    - Do not use code blocks.
    - Keep titles short.
    - Keep descriptions short.
    - Arrange the steps in a logical learning sequence.
    """

    response = client.models.generate_content(
        model=MODEL,
        contents=prompt
    )

    result = response.text.strip()

    # Remove ```json if Gemini adds it
    if result.startswith("```"):
        result = result.replace("```json", "")
        result = result.replace("```", "")
        result = result.strip()

    try:
        return json.loads(result)

    except json.JSONDecodeError:
        print("AI returned invalid JSON.")
        print(result)
        return None


# ---------------------------------------
# Draw visual explanation
# ---------------------------------------

def show_diagram(data):

    window = tk.Tk()

    window.title("LearnRoot - AI Visual Tutor")

    window.geometry("900x700")


    # Heading
    heading = tk.Label(
        window,
        text=data["topic"],
        font=("Arial", 24, "bold")
    )

    heading.pack(pady=10)


    # Central idea
    idea = tk.Label(
        window,
        text=data["central_idea"],
        font=("Arial", 13),
        wraplength=700
    )

    idea.pack(pady=5)


    # Canvas
    canvas = tk.Canvas(
        window,
        width=800,
        height=550
    )

    canvas.pack(pady=10)


    # Get steps
    steps = data["steps"]

    start_y = 30
    box_width = 500
    box_height = 70


    # Draw each step
    for i, step in enumerate(steps):

        x1 = 150
        y1 = start_y + i * 100

        x2 = x1 + box_width
        y2 = y1 + box_height


        # Box
        canvas.create_rectangle(
            x1,
            y1,
            x2,
            y2,
            width=2
        )


        # Title
        canvas.create_text(
            400,
            y1 + 20,
            text=step["title"],
            font=("Arial", 14, "bold")
        )


        # Description
        canvas.create_text(
            400,
            y1 + 48,
            text=step["description"],
            font=("Arial", 11),
            width=450
        )


        # Arrow
        if i < len(steps) - 1:

            canvas.create_line(
                400,
                y2,
                400,
                y2 + 30,
                arrow=tk.LAST,
                width=2
            )


    window.mainloop()


# ---------------------------------------
# Main
# ---------------------------------------

topic = input("Enter a topic: ")

print("\nGenerating visual explanation...\n")

data = visual_explanation(topic)

if data:

    print("Visual explanation generated successfully!")

    print("\nAI Generated Data:")
    print(json.dumps(data, indent=4))

    show_diagram(data)

else:

    print("Could not create visual explanation.")