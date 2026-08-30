def generate_quiz(topic_name):
    return [
        {
            "question": f"What is an important concept in {topic_name}?",
            "option_a": "Understanding the basic concepts",
            "option_b": "Ignoring the topic",
            "option_c": "Skipping all practice",
            "option_d": "Avoiding examples",
            "correct_answer": "A",
            "solution": f"Understanding the basic concepts is important when learning {topic_name}."
        },
        {
            "question": f"Why should students study {topic_name}?",
            "option_a": "To understand the subject better",
            "option_b": "To avoid learning",
            "option_c": "To skip prerequisites",
            "option_d": "To avoid practice",
            "correct_answer": "A",
            "solution": f"Studying {topic_name} helps build knowledge and understanding."
        }
    ]