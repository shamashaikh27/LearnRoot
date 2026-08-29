import requests
import os
import subprocess

# ============================================================
# LEARNROOT - AI VISUAL TUTOR
# Complete Module 3 Testing
# ============================================================

BASE_URL = "http://127.0.0.1:5000"

# Fixed topic for demonstration
topic = "Pointers"

print("\n")
print("=" * 60)
print("                 LEARNROOT")
print("              AI VISUAL TUTOR")
print("=" * 60)

print("\nSelected Topic:", topic)


# ============================================================
# 1. AI EXPLANATION
# ============================================================

print("\n\n")
print("=" * 60)
print("1. AI EXPLANATION")
print("=" * 60)

response = requests.post(
    f"{BASE_URL}/explain",
    json={
        "topic": topic
    }
)

if response.status_code == 200:

    result = response.json()

    print("\nTopic:", topic)
    print("\nAI Tutor Response:\n")
    print(result["explanation"])

else:

    print("Error:", response.status_code)
    print(response.text)


# ============================================================
# 2. VISUAL EXPLANATION
# ============================================================

print("\n\n")
print("=" * 60)
print("2. VISUAL EXPLANATION")
print("=" * 60)

response = requests.post(
    f"{BASE_URL}/visual",
    json={
        "topic": topic
    }
)

if response.status_code == 200:

    result = response.json()

    print("\nTopic:", result["topic"])

    print("\nCentral Idea:")
    print(result["central_idea"])

    print("\nVisual Steps:")

    for i, step in enumerate(result["steps"], 1):

        print(f"\n{i}. {step['title']}")
        print(f"   {step['description']}")

else:

    print("Error:", response.status_code)
    print(response.text)


# ============================================================
# 3. ONE-SHOT REVISION
# ============================================================

print("\n\n")
print("=" * 60)
print("3. ONE-SHOT REVISION")
print("=" * 60)

response = requests.post(
    f"{BASE_URL}/revision",
    json={
        "topic": topic
    }
)

if response.status_code == 200:

    result = response.json()

    print("\nTopic:", topic)

    print("\nOne-Shot Revision:\n")
    print(result["revision"])

else:

    print("Error:", response.status_code)
    print(response.text)


# ============================================================
# 4. WHAT IF I SKIP?
# ============================================================

print("\n\n")
print("=" * 60)
print("4. WHAT IF I SKIP?")
print("=" * 60)

response = requests.post(
    f"{BASE_URL}/skip",
    json={
        "topic": topic
    }
)

if response.status_code == 200:

    result = response.json()

    print("\nTopic:", topic)

    print("\nIf the student skips this topic:\n")
    print(result["what_if_i_skip"])

else:

    print("Error:", response.status_code)
    print(response.text)


# ============================================================
# 5. AI DOUBT SOLVER
# ============================================================

print("\n\n")
print("=" * 60)
print("5. AI DOUBT SOLVER")
print("=" * 60)

question = "Why do we use the * operator with a pointer?"

print("\nTopic:", topic)
print("Student Question:", question)

response = requests.post(
    f"{BASE_URL}/doubt",
    json={
        "topic": topic,
        "question": question
    }
)

if response.status_code == 200:

    result = response.json()

    print("\nAI Tutor Answer:\n")
    print(result["answer"])

else:

    print("Error:", response.status_code)
    print(response.text)


# ============================================================
# 6. VOICE EXPLANATION
# ============================================================

print("\n\n")
print("=" * 60)
print("6. VOICE EXPLANATION")
print("=" * 60)

response = requests.post(
    f"{BASE_URL}/voice",
    json={
        "topic": topic
    }
)

if response.status_code == 200:

    # Save returned audio file
    audio_file = "pointer_explanation.mp3"

    with open(audio_file, "wb") as file:
        file.write(response.content)

    print("\nVoice explanation generated successfully!")
    print("Audio file:", audio_file)

    # Open the audio file automatically on Windows
    try:
        os.startfile(audio_file)
        print("Playing voice explanation...")
    except Exception:
        print("Open the MP3 file manually to hear the explanation.")

else:

    print("Error:", response.status_code)
    print(response.text)


# ============================================================
# COMPLETE
# ============================================================

print("\n\n")
print("=" * 60)
print("       AI VISUAL TUTOR DEMONSTRATION COMPLETE")
print("=" * 60)

print("""
Features Tested:

[✓] AI Explanation
[✓] Visual Explanation
[✓] One-Shot Revision
[✓] What If I Skip?
[✓] AI Doubt Solver
[✓] Voice Explanation

Topic Used: Pointers
""")

print("=" * 60)