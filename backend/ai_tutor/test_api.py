import requests

url = "http://127.0.0.1:5000/skip"

data = {
    "topic": "Pointers"
}

response = requests.post(url, json=data)

print("Status Code:", response.status_code)

print("\nWhat If I Skip?")
print(response.json())