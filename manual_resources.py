import sys
from urllib.parse import quote_plus

from backend.db import get_connection

VIDEOS_PER_TOPIC = 5

VIDEO_TYPES = [
    ("Tutorial", "tutorial"),
    ("Lecture", "lecture"),
    ("Concept Explanation", "explained"),
    ("Examples", "examples"),
    ("Quick Revision", "quick revision"),
]


def create_youtube_search_link(topic_name, subject, search_term):
    query = f"{topic_name} {subject} {search_term}"
    return (
        "https://www.youtube.com/results?search_query="
        + quote_plus(query)
    )


def get_existing_videos(cursor, topic_id):
    cursor.execute(
        """
        SELECT resource_id, title, resource_link
        FROM resources
        WHERE topic_id = %s
          AND LOWER(resource_type) = 'video'
        ORDER BY resource_id
        """,
        (topic_id,)
    )
    return cursor.fetchall()


def delete_manual_search_resources(cursor, topic_id):
    cursor.execute(
        """
        DELETE FROM resources
        WHERE topic_id = %s
          AND LOWER(resource_type) = 'video'
          AND resource_link LIKE
              'https://www.youtube.com/results?search_query=%%'
        """,
        (topic_id,)
    )


def insert_video_resource(cursor, topic_id, title, link):
    cursor.execute(
        """
        INSERT INTO resources
            (topic_id, resource_type, title, resource_link)
        VALUES
            (%s, 'Video', %s, %s)
        """,
        (topic_id, title, link)
    )


def get_topics(cursor, offset=0, limit=None):
    query = """
        SELECT topic_id, topic_code, subject, topic_name
        FROM topics
        ORDER BY topic_id
    """

    if limit is None:
        cursor.execute(query)
    else:
        cursor.execute(
            query + " LIMIT %s OFFSET %s",
            (limit, offset)
        )

    return cursor.fetchall()


def create_resources_for_topic(
    cursor, topic_id, topic_code, subject, topic_name
):
    existing = get_existing_videos(cursor, topic_id)

    real_videos = [
        row for row in existing
        if "youtube.com/watch?v=" in (row[2] or "")
    ]

    print()
    print("=" * 70)
    print(f"Topic ID   : {topic_id}")
    print(f"Topic Code : {topic_code}")
    print(f"Subject    : {subject}")
    print(f"Topic      : {topic_name}")
    print(f"Existing real videos : {len(real_videos)}/{VIDEOS_PER_TOPIC}")
    print("=" * 70)

    if len(real_videos) >= VIDEOS_PER_TOPIC:
        print("5 real video links already exist - skipping.")
        return 0

    # Remove only search-result links created by this script.
    # Existing real watch?v= links are never deleted.
    delete_manual_search_resources(cursor, topic_id)

    remaining = VIDEOS_PER_TOPIC - len(real_videos)
    inserted = 0

    for title_suffix, search_term in VIDEO_TYPES:
        if inserted >= remaining:
            break

        link = create_youtube_search_link(
            topic_name, subject, search_term
        )

        title = f"{topic_name} - {title_suffix}"

        insert_video_resource(
            cursor, topic_id, title, link
        )

        inserted += 1
        print(f"[ADDED] {title}")

    print(
        f"Recommended video resources now available: "
        f"{len(real_videos) + inserted}/{VIDEOS_PER_TOPIC}"
    )

    return inserted


def import_resources(offset=0, limit=None):
    connection = None
    cursor = None

    try:
        connection = get_connection()

        if not connection or not connection.is_connected():
            print("Database connection failed.")
            return

        cursor = connection.cursor()

        topics = get_topics(cursor, offset, limit)

        if not topics:
            print("No topics found.")
            return

        print()
        print("=" * 70)
        print("LEARNROOT RECOMMENDED VIDEO RESOURCE IMPORT")
        print("=" * 70)
        print(f"Topics found     : {len(topics)}")
        print(f"Videos per topic : {VIDEOS_PER_TOPIC}")
        print("YouTube API      : NOT USED")
        print("=" * 70)

        total_inserted = 0

        for topic_id, topic_code, subject, topic_name in topics:
            total_inserted += create_resources_for_topic(
                cursor,
                topic_id,
                topic_code,
                subject,
                topic_name
            )
            connection.commit()

        print()
        print("=" * 70)
        print("IMPORT COMPLETED")
        print("=" * 70)
        print(f"Topics processed   : {len(topics)}")
        print(f"Resources inserted : {total_inserted}")
        print("YouTube API calls  : 0")
        print("=" * 70)

    except Exception as error:
        if connection:
            connection.rollback()
        print()
        print("IMPORT ERROR:")
        print(error)

    finally:
        if cursor:
            cursor.close()
        if connection:
            connection.close()


if __name__ == "__main__":
    offset = 0
    limit = None

    if len(sys.argv) >= 2:
        try:
            offset = int(sys.argv[1])
        except ValueError:
            print("Offset must be a number.")
            sys.exit(1)

    if len(sys.argv) >= 3:
        try:
            limit = int(sys.argv[2])
        except ValueError:
            print("Limit must be a number.")
            sys.exit(1)

    import_resources(offset=offset, limit=limit)
