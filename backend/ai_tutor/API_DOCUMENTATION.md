# LearnRoot AI Tutor API

## Base URL

http://127.0.0.1:5000

---

## 1. AI Concept Explanation

### Endpoint

POST /explain

### Request

{
    "topic": "Pointers"
}

### Response

{
    "topic": "Pointers",
    "explanation": "AI generated explanation..."
}

---

## 2. Visual Explanation

### Endpoint

POST /visual

### Request

{
    "topic": "Pointers"
}

### Response

{
    "topic": "Pointers",
    "central_idea": "A pointer stores a memory address.",
    "steps": [
        {
            "title": "Variable",
            "description": "A variable stores a value."
        },
        {
            "title": "Memory Address",
            "description": "Every variable has an address."
        },
        {
            "title": "Pointer",
            "description": "A pointer stores an address."
        }
    ]
}

---

## 3. One-Shot Revision

### Endpoint

POST /revision

### Request

{
    "topic": "Pointers"
}

### Response

{
    "topic": "Pointers",
    "revision": "AI generated revision..."
}

---

## 4. What If I Skip?

### Endpoint

POST /skip

### Request

{
    "topic": "Pointers"
}

### Response

{
    "topic": "Pointers",
    "what_if_i_skip": "AI generated explanation..."
}

---

## 5. AI Doubt Solver

### Endpoint

POST /doubt

### Request

{
    "topic": "Pointers",
    "question": "Why do we use the * operator?"
}

### Response

{
    "topic": "Pointers",
    "question": "Why do we use the * operator?",
    "answer": "AI generated answer..."
}