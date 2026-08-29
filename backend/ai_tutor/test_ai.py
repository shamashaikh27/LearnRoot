from dotenv import load_dotenv
from google import genai
import os

# Load variables from .env
load_dotenv()

# Get Gemini API key
api_key = os.getenv("GEMINI_API_KEY")

# Check if API key exists
if not api_key:
    print("Error: GEMINI_API_KEY not found.")
    exit()

# Connect to Gemini
client = genai.Client(api_key=api_key)

# Ask Gemini to explain a topic
response = client.models.generate_content(
    model="gemini-3.6-flash",
    contents="Explain pointers in C in simple words for a computer engineering student."
)

# Display AI response
print("\nAI Tutor Response:\n")
print(response.text)