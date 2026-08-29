import requests

url = "http://127.0.0.1:5000/explain"

data = {
    "topic": "Pointers"
}

response = requests.post(url, json=data)

print("\n==============================")
print("       AI TUTOR")
print("==============================")

print("\nTopic:", data["topic"])

print("\nAI Explanation:")
print(response.json()["explanation"])