def generate_recommendation(topic_name, score):
    """
    Generate a simple intelligent learning recommendation
    based on the student's quiz score.
    """

    if score < 40:
        return {
            "level": "Needs Improvement",
            "message": f"You need to revise {topic_name} carefully before moving ahead.",
            "recommendation": "Study the notes and watch the recommended learning videos."
        }

    elif score < 60:
        return {
            "level": "Basic Understanding",
            "message": f"You have a basic understanding of {topic_name}.",
            "recommendation": "Review the important concepts and attempt the quiz again."
        }

    elif score < 80:
        return {
            "level": "Good",
            "message": f"You have a good understanding of {topic_name}.",
            "recommendation": "Practice more questions to improve your understanding."
        }

    else:
        return {
            "level": "Excellent",
            "message": f"You have a strong understanding of {topic_name}.",
            "recommendation": "You are ready to continue to the next topic."
        }