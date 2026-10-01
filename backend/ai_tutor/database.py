import mysql.connector
from mysql.connector import Error


# ============================================================
# LEARNROOT MYSQL DATABASE CONFIGURATION
# ============================================================

DB_HOST = "localhost"
DB_USER = "root"
DB_PASSWORD = "$hama09Ali"
DB_NAME = "learnroot_db"


# ============================================================
# DATABASE CONNECTION
# ============================================================

def get_connection():
    """
    Create and return a connection to the LearnRoot MySQL database.
    """

    try:
        connection = mysql.connector.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASSWORD,
            database=DB_NAME
        )

        if connection.is_connected():
            return connection

    except Error as e:
        print(f"MySQL connection error: {e}")

    return None


# ============================================================
# GET CACHED AI CONTENT
# ============================================================

def get_cached_content(subject, topic, feature_type):
    """
    Check MySQL for an existing AI response.

    Returns:
        The stored content if found.
        None if no cached response exists.
    """

    connection = get_connection()

    if connection is None:
        return None

    cursor = None

    try:
        cursor = connection.cursor()

        query = """
            SELECT content
            FROM ai_content
            WHERE subject = %s
              AND topic = %s
              AND feature_type = %s
            LIMIT 1
        """

        cursor.execute(
            query,
            (subject, topic, feature_type)
        )

        result = cursor.fetchone()

        if result:
            print(
                f"MySQL cache HIT: "
                f"{subject} | {topic} | {feature_type}"
            )
            return result[0]

        print(
            f"MySQL cache MISS: "
            f"{subject} | {topic} | {feature_type}"
        )

        return None

    except Error as e:
        print(f"MySQL read error: {e}")
        return None

    finally:
        if cursor:
            cursor.close()

        connection.close()


# ============================================================
# SAVE AI CONTENT
# ============================================================

def save_ai_content(subject, topic, feature_type, content):
    """
    Save an AI-generated response in MySQL.

    If the same subject, topic and feature already exists,
    update the existing response instead of creating a duplicate.
    """

    connection = get_connection()

    if connection is None:
        return False

    cursor = None

    try:
        cursor = connection.cursor()

        query = """
            INSERT INTO ai_content
                (subject, topic, feature_type, content)
            VALUES
                (%s, %s, %s, %s)
            ON DUPLICATE KEY UPDATE
                content = VALUES(content),
                updated_at = CURRENT_TIMESTAMP
        """

        cursor.execute(
            query,
            (
                subject,
                topic,
                feature_type,
                content
            )
        )

        connection.commit()

        print(
            f"MySQL cache SAVED: "
            f"{subject} | {topic} | {feature_type}"
        )

        return True

    except Error as e:
        print(f"MySQL save error: {e}")
        return False

    finally:
        if cursor:
            cursor.close()

        connection.close()


# ============================================================
# TEST DATABASE
# ============================================================

if __name__ == "__main__":

    connection = get_connection()

    if connection:
        print("MySQL connection successful.")
        connection.close()
        print("MySQL connection closed.")

    else:
        print("Could not connect to LearnRoot database.")