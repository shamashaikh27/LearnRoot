# LearnRoot - AI Visual Tutor API Documentation

## Module 3 - AI Visual Tutor

LearnRoot is a prerequisite-aware learning platform designed to help Computer Engineering students understand topics, revise concepts, solve doubts, and understand the consequences of skipping prerequisite topics.

This document describes the APIs developed for **Module 3 - AI Visual Tutor**.

---

# 1. Module Overview

Module 3 provides AI-powered learning assistance using the Google Gemini API.

The module contains four main AI features:

1. AI Visual Explanation with Text-to-Speech
2. AI Summary of the Concept
3. AI Doubt Solver
4. AI "What If I Skip?"

The backend is developed using:

- Python
- Flask
- Google Gemini API
- `google-genai`
- `python-dotenv`
- Flask-CORS
- `pyttsx3`
- FFmpeg
- JSON

---

# 2. Module 3 Architecture

```text
                    MODULE 2
                 Prerequisite DAG
                       │
                Student selects topic
                       ↓
              ┌─────────────────┐
              │   MODULE 3      │
              │   AI VISUAL     │
              │     TUTOR       │
              └────────┬────────┘
                       │
       ┌───────────────┼────────────────┐
       ↓               ↓                ↓
   Explanation      Summary        What If I Skip?
       │               │                │
       └───────────────┼────────────────┘
                       ↓
                  Gemini API
                       ↓
                 AI response
                       ↓
              Flutter UI / TTS

                 AI DOUBT SOLVER
                       ↑
                 Student question
                       ↓
                    Gemini
                       ↓
                  AI answer