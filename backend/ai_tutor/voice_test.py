from dotenv import load_dotenv
from google import genai
import pyttsx3
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
# Generate explanation
# ---------------------------------------

def explain_topic(topic):

    prompt = f"""
    Explain the topic "{topic}" to a Computer Engineering student.

    Use simple language.

    Explain:
    1. What it is
    2. How it works
    3. One simple example
    4. Why it is important

    Make the explanation suitable for listening.
    Do not use tables, Markdown or complicated formatting.
    Keep it around 150 to 200 words.
    """

    response = client.models.generate_content(
        model=MODEL,
        contents=prompt
    )

    return response.text


# ---------------------------------------
# Convert explanation to speech
# ---------------------------------------

def speak(text):

    engine = pyttsx3.init()

    # Speech speed
    engine.setProperty("rate", 150)

    # Volume
    engine.setProperty("volume", 1.0)

    print("\n🔊 Speaking explanation...\n")

    engine.say(text)

    engine.runAndWait()


# ---------------------------------------
# Main
# ---------------------------------------

topic = input("Enter a topic: ")

print("\nGenerating AI explanation...\n")

explanation = explain_topic(topic)

print("====================================")
print("          AI EXPLANATION")
print("====================================")

print(explanation)

print("\n====================================")
print("          VOICE EXPLANATION")
print("====================================")

speak(explanation)

print("\nFinished.")