import os
import re
import sys
import argparse
from collections import Counter, defaultdict

# ============================================================
# LEARNROOT - COMPLETE SYLLABUS IMPORTER
# ============================================================

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))

SYLLABUS_FILE = os.path.join(
    os.path.expanduser("~"),
    "Downloads",
    "syllabus_data_multi_prerequisites (2).dart"
)

BACKEND_DIR = os.path.join(ROOT_DIR, "backend")

if BACKEND_DIR not in sys.path:
    sys.path.insert(0, BACKEND_DIR)


# ============================================================
# DATABASE CONNECTION
# ============================================================

try:
    from db import get_connection
except Exception as e:
    print()
    print("ERROR: Could not import backend/db.py")
    print()
    print("Make sure this file exists:")
    print(os.path.join(BACKEND_DIR, "db.py"))
    print()
    print("Original error:", e)
    sys.exit(1)


# ============================================================
# EXISTING 18 LEARNROOT TOPIC MAPPING
# ============================================================

LEGACY_MAPPING = {}


# ============================================================
# PARSE PREREQUISITES
# ============================================================

def parse_prerequisites(text):
    """
    Converts:

        ['ds_arrays', 'ds_recursion']

    into:

        ['ds_arrays', 'ds_recursion']
    """

    if not text:
        return []

    return re.findall(
        r"""['"]([^'"]+)['"]""",
        text
    )


# ============================================================
# PARSE SYLLABUS
# ============================================================



def parse_syllabus(file_path):
    """Parse topic helper calls from the Dart syllabus file."""

    if not os.path.exists(file_path):
        raise FileNotFoundError(
            f"Syllabus file not found: {file_path}"
        )

    with open(file_path, "r", encoding="utf-8-sig") as file:
        content = file.read()

    helper_details = {
        "_dsTopic": ("ds", "Data Structures"),
        "_cTopic": ("c", "C Programming"),
        "_osTopic": ("os", "Operating Systems"),
        "_cnTopic": ("cn", "Computer Networks"),
        "_javaTopic": ("java", "OOPs - Java"),
        "_dbmsTopic": ("dbms", "DBMS"),
    }

    pattern = re.compile(
        r"""
        (?P<helper>_dsTopic|_cTopic|_osTopic|_cnTopic|_javaTopic|_dbmsTopic)
        \s*\(
        \s*(?P<id>\d+)
        \s*,\s*
        (?P<quote>['"])
        (?P<name>.*?)
        (?P=quote)
        \s*,\s*
        \[
        (?P<prerequisites>[^\]]*)
        \]
        \s*\)
        """,
        re.VERBOSE | re.DOTALL
    )

    topics = []

    for match in pattern.finditer(content):
        helper = match.group("helper")
        prefix, subject = helper_details[helper]

        topic_id = int(match.group("id"))

        prerequisite_numbers = re.findall(
            r"\d+",
            match.group("prerequisites")
        )

        topics.append({
            "topic_code": f"{prefix}_{topic_id}",
            "topic_name": match.group("name").strip(),
            "subject": subject,
            "prerequisites": [
                f"{prefix}_{number}"
                for number in prerequisite_numbers
            ]
        })

    return topics



# ============================================================
# ASSIGN TOPIC ORDER
# ============================================================

def assign_topic_orders(topics):

    counters = defaultdict(int)

    for topic in topics:

        subject = topic["subject"]

        counters[subject] += 1

        topic["topic_order"] = counters[
            subject
        ]

    return topics


# ============================================================
# VALIDATE TOPICS
# ============================================================

def validate_topics(topics):

    print()
    print("=" * 70)
    print("VALIDATING UPLOADED SYLLABUS")
    print("=" * 70)

    errors = []

    # --------------------------------------------------------
    # Check topic count
    # --------------------------------------------------------

    if not topics:

        errors.append(
            "No Topic(...) definitions were found."
        )

    # --------------------------------------------------------
    # Check duplicate topic codes
    # --------------------------------------------------------

    code_counts = Counter(
        topic["topic_code"]
        for topic in topics
    )

    duplicate_codes = [
        code
        for code, count in code_counts.items()
        if count > 1
    ]

    if duplicate_codes:

        errors.append(
            "Duplicate topic codes found: "
            + ", ".join(duplicate_codes)
        )

    # --------------------------------------------------------
    # Check topic name length
    # --------------------------------------------------------

    long_names = [
        topic
        for topic in topics
        if len(topic["topic_name"]) > 100
    ]

    if long_names:

        errors.append(
            f"{len(long_names)} topic names "
            "exceed VARCHAR(100)."
        )

    # --------------------------------------------------------
    # Check subject length
    # --------------------------------------------------------

    long_subjects = [
        topic
        for topic in topics
        if len(topic["subject"]) > 50
    ]

    if long_subjects:

        errors.append(
            f"{len(long_subjects)} subjects "
            "exceed VARCHAR(50)."
        )

    # --------------------------------------------------------
    # Check prerequisite references
    # --------------------------------------------------------

    all_codes = {
        topic["topic_code"]
        for topic in topics
    }

    missing_prerequisites = []

    for topic in topics:

        for prerequisite in topic[
            "prerequisites"
        ]:

            if prerequisite not in all_codes:

                missing_prerequisites.append(
                    (
                        topic["topic_code"],
                        prerequisite
                    )
                )

    if missing_prerequisites:

        errors.append(
            "Some prerequisites refer to "
            "non-existent topic codes."
        )

        for topic_code, prerequisite in (
            missing_prerequisites
        ):

            print(
                f"  Missing prerequisite: "
                f"{topic_code} -> {prerequisite}"
            )


    # --------------------------------------------------------
    # Summary
    # --------------------------------------------------------

    print()

    print(
        f"Topics found: {len(topics)}"
    )

    subject_counts = Counter(
        topic["subject"]
        for topic in topics
    )

    print()

    print("Topics by subject:")

    for subject, count in subject_counts.items():

        print(
            f"  {subject}: {count}"
        )

    print()

    if errors:

        print("VALIDATION FAILED")
        print()

        for error in errors:

            print(
                "ERROR:",
                error
            )

        print()

        return False

    print("VALIDATION PASSED")
    print()

    return True


# ============================================================
# CREATE PREREQUISITE TABLE
# ============================================================

def create_prerequisite_table(cursor):

    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS topic_prerequisites (

            prerequisite_id INT AUTO_INCREMENT PRIMARY KEY,

            topic_id INT NOT NULL,

            prerequisite_code VARCHAR(100) NOT NULL,

            UNIQUE KEY unique_topic_prerequisite
            (
                topic_id,
                prerequisite_code
            ),

            FOREIGN KEY (topic_id)
            REFERENCES topics(topic_id)

            ON DELETE CASCADE

        )
        """
    )


# ============================================================
# GET EXISTING TOPICS
# ============================================================

def get_existing_topics(cursor):

    cursor.execute(
        """
        SELECT
            topic_id,
            topic_code,
            subject,
            topic_name,
            topic_order,
            completed,
            unlocked

        FROM topics

        ORDER BY topic_id
        """
    )

    return cursor.fetchall()


# ============================================================
# PRINT EXISTING TOPICS
# ============================================================

def print_existing_topics(existing_topics):

    print()
    print("=" * 70)
    print("CURRENT DATABASE TOPICS")
    print("=" * 70)

    if not existing_topics:

        print("No existing topics.")
        return

    for row in existing_topics:

        print(
            f"ID {row[0]:<4} | "
            f"{str(row[1]):<35} | "
            f"{row[2]} | "
            f"{row[3]}"
        )


# ============================================================
# BUILD SOURCE LOOKUP
# ============================================================

def build_source_lookup(topics):

    return {
        topic["topic_code"]: topic
        for topic in topics
    }


# ============================================================
# PREVIEW CHANGES
# ============================================================

def preview_changes(
    topics,
    existing_topics
):

    source_lookup = build_source_lookup(
        topics
    )

    existing_by_id = {
        row[0]: row
        for row in existing_topics
    }

    existing_codes = {
        row[1]
        for row in existing_topics
        if row[1]
    }

    mapped_codes = set(
        LEGACY_MAPPING.values()
    )

    updates = []
    inserts = []

    # --------------------------------------------------------
    # Existing 18 topics
    # --------------------------------------------------------

    for topic_id, new_code in LEGACY_MAPPING.items():

        if topic_id not in existing_by_id:

            print(
                f"WARNING: topic_id {topic_id} "
                "does not exist."
            )

            continue

        source_topic = source_lookup[
            new_code
        ]

        old_row = existing_by_id[
            topic_id
        ]

        updates.append(
            {
                "topic_id": topic_id,
                "old_code": old_row[1],
                "new_code": new_code,
                "old_subject": old_row[2],
                "new_subject": source_topic["subject"],
                "old_name": old_row[3],
                "new_name": source_topic["topic_name"]
            }
        )

    # --------------------------------------------------------
    # Remaining topics
    # --------------------------------------------------------

    for topic in topics:

        code = topic["topic_code"]

        if code in mapped_codes:
            continue

        if code in existing_codes:
            continue

        inserts.append(topic)

    # --------------------------------------------------------
    # Display updates
    # --------------------------------------------------------

    print()
    print("=" * 70)
    print("EXISTING TOPIC UPDATES")
    print("=" * 70)

    for update in updates:

        print(
            f"ID {update['topic_id']}: "
            f"{update['old_name']} "
            f"-> "
            f"{update['new_name']}"
        )

        print(
            f"    Code: "
            f"{update['old_code']} "
            f"-> "
            f"{update['new_code']}"
        )

    # --------------------------------------------------------
    # Display new topics
    # --------------------------------------------------------

    print()
    print("=" * 70)
    print("NEW TOPICS TO INSERT")
    print("=" * 70)

    print(
        f"New source topics: {len(inserts)}"
    )

    insert_counts = Counter(
        topic["subject"]
        for topic in inserts
    )

    for subject, count in insert_counts.items():

        print(
            f"  {subject}: {count}"
        )

    return updates, inserts


# ============================================================
# ENSURE UNIQUE TOPIC CODE
# ============================================================

def ensure_topic_code_index(cursor):

    cursor.execute(
        """
        SHOW INDEX
        FROM topics
        WHERE Key_name = 'uq_topics_topic_code'
        """
    )

    result = cursor.fetchall()

    if result:
        return

    cursor.execute(
        """
        ALTER TABLE topics

        ADD UNIQUE KEY
        uq_topics_topic_code (topic_code)
        """
    )


# ============================================================
# IMPORT TOPICS
# ============================================================

def import_topics(
    connection,
    topics
):

    cursor = connection.cursor()

    try:

        # ====================================================
        # FIX:
        # Close any transaction that was already active.
        # ====================================================

        try:
            connection.rollback()
        except Exception:
            pass

        # ====================================================
        # START FRESH TRANSACTION
        # ====================================================

        connection.start_transaction()

        # ====================================================
        # CREATE PREREQUISITE TABLE
        # ====================================================

        create_prerequisite_table(
            cursor
        )

        # ====================================================
        # GET EXISTING TOPICS
        # ====================================================

        existing_topics = get_existing_topics(
            cursor
        )

        existing_by_id = {
            row[0]: row
            for row in existing_topics
        }

        source_lookup = build_source_lookup(
            topics
        )

        # ====================================================
        # UPDATE EXISTING TOPICS
        # ====================================================

        updated_count = 0

        for topic_id, source_code in (
            LEGACY_MAPPING.items()
        ):

            if topic_id not in existing_by_id:
                continue

            source_topic = source_lookup[
                source_code
            ]

            cursor.execute(
                """
                UPDATE topics

                SET
                    topic_code = %s,
                    subject = %s,
                    topic_name = %s,
                    topic_order = %s

                WHERE topic_id = %s
                """,
                (
                    source_topic["topic_code"],
                    source_topic["subject"],
                    source_topic["topic_name"],
                    source_topic["topic_order"],
                    topic_id
                )
            )

            updated_count += cursor.rowcount

        # ====================================================
        # GET CURRENT TOPIC CODES
        # ====================================================

        cursor.execute(
            """
            SELECT topic_code
            FROM topics
            WHERE topic_code IS NOT NULL
            """
        )

        current_codes = {
            row[0]
            for row in cursor.fetchall()
        }

        # ====================================================
        # INSERT NEW TOPICS
        # ====================================================

        inserted_count = 0

        for topic in topics:

            topic_code = topic[
                "topic_code"
            ]

            if topic_code in current_codes:
                continue

            cursor.execute(
                """
                INSERT INTO topics
                (
                    topic_code,
                    subject,
                    topic_name,
                    topic_order,
                    completed,
                    unlocked
                )

                VALUES
                (
                    %s,
                    %s,
                    %s,
                    %s,
                    0,
                    0
                )
                """,
                (
                    topic["topic_code"],
                    topic["subject"],
                    topic["topic_name"],
                    topic["topic_order"]
                )
            )

            inserted_count += 1

            current_codes.add(
                topic_code
            )

        # ====================================================
        # UNIQUE INDEX
        # ====================================================

        ensure_topic_code_index(
            cursor
        )

        # ====================================================
        # MAKE topic_code NOT NULL
        # ====================================================

        cursor.execute(
            """
            ALTER TABLE topics

            MODIFY topic_code
            VARCHAR(100) NOT NULL
            """
        )

        # ====================================================
        # GET TOPIC IDs
        # ====================================================

        cursor.execute(
            """
            SELECT topic_id, topic_code
            FROM topics
            """
        )

        topic_id_lookup = {
            row[1]: row[0]
            for row in cursor.fetchall()
        }

        # ====================================================
        # CLEAR OLD PREREQUISITE RELATIONSHIPS
        # ====================================================

        cursor.execute(
            """
            DELETE FROM topic_prerequisites
            """
        )

        # ====================================================
        # INSERT PREREQUISITE RELATIONSHIPS
        # ====================================================

        prerequisite_count = 0

        for topic in topics:

            topic_code = topic[
                "topic_code"
            ]

            topic_id = topic_id_lookup.get(
                topic_code
            )

            if topic_id is None:

                raise Exception(
                    f"Topic ID not found for "
                    f"{topic_code}"
                )

            for prerequisite_code in topic[
                "prerequisites"
            ]:

                if (
                    prerequisite_code
                    not in topic_id_lookup
                ):

                    raise Exception(
                        f"Prerequisite "
                        f"{prerequisite_code} "
                        f"for {topic_code} "
                        f"does not exist."
                    )

                cursor.execute(
                    """
                    INSERT INTO topic_prerequisites
                    (
                        topic_id,
                        prerequisite_code
                    )

                    VALUES
                    (
                        %s,
                        %s
                    )
                    """,
                    (
                        topic_id,
                        prerequisite_code
                    )
                )

                prerequisite_count += 1

        # ====================================================
        # COMMIT EVERYTHING
        # ====================================================

        connection.commit()

        print()
        print("=" * 70)
        print("IMPORT SUCCESSFUL")
        print("=" * 70)

        print()
        print(
            f"Existing topics updated : "
            f"{updated_count}"
        )

        print(
            f"New topics inserted     : "
            f"{inserted_count}"
        )

        print(
            f"Prerequisites stored    : "
            f"{prerequisite_count}"
        )

        print()

        return True

    except Exception as e:

        # ====================================================
        # ROLLBACK ON ERROR
        # ====================================================

        try:
            connection.rollback()
        except Exception:
            pass

        print()
        print("=" * 70)
        print("IMPORT FAILED")
        print("=" * 70)

        print()
        print(
            "ERROR:",
            e
        )

        print()
        print(
            "Database transaction rolled back."
        )

        print(
            "No partial import was committed."
        )

        print()

        return False

    finally:

        cursor.close()


# ============================================================
# FINAL DATABASE SUMMARY
# ============================================================

def print_final_summary(connection):

    cursor = connection.cursor()

    try:

        # ----------------------------------------------------
        # Total topics
        # ----------------------------------------------------

        cursor.execute(
            """
            SELECT COUNT(*)
            FROM topics
            """
        )

        total_topics = cursor.fetchone()[0]

        # ----------------------------------------------------
        # Topics by subject
        # ----------------------------------------------------

        cursor.execute(
            """
            SELECT
                subject,
                COUNT(*)

            FROM topics

            GROUP BY subject

            ORDER BY subject
            """
        )

        subject_counts = cursor.fetchall()

        # ----------------------------------------------------
        # Prerequisites
        # ----------------------------------------------------

        cursor.execute(
            """
            SELECT COUNT(*)
            FROM topic_prerequisites
            """
        )

        prerequisite_count = (
            cursor.fetchone()[0]
        )

        # ----------------------------------------------------
        # Display
        # ----------------------------------------------------

        print()
        print("=" * 70)
        print("FINAL DATABASE SUMMARY")
        print("=" * 70)

        print()
        print(
            f"Total topics: {total_topics}"
        )

        print()
        print("Topics by subject:")

        for subject, count in subject_counts:

            print(
                f"  {subject}: {count}"
            )

        print()
        print(
            f"Prerequisite relationships: "
            f"{prerequisite_count}"
        )

        print()

    finally:

        cursor.close()


# ============================================================
# MAIN
# ============================================================

def main():

    parser = argparse.ArgumentParser(
        description=(
            "Import LearnRoot syllabus topics"
        )
    )

    parser.add_argument(
        "--apply",
        action="store_true",
        help="Actually modify the database."
    )

    args = parser.parse_args()

    # ========================================================
    # HEADER
    # ========================================================

    print()
    print("=" * 70)
    print("LEARNROOT SYLLABUS IMPORTER")
    print("=" * 70)

    print()
    print("Project root:")
    print(ROOT_DIR)

    print()
    print("Syllabus:")
    print(SYLLABUS_FILE)

    # ========================================================
    # READ SYLLABUS
    # ========================================================

    print()
    print(
        "Reading uploaded syllabus..."
    )

    topics = parse_syllabus(
        SYLLABUS_FILE
    )

    # ========================================================
    # ASSIGN ORDER
    # ========================================================

    topics = assign_topic_orders(
        topics
    )

    # ========================================================
    # VALIDATE
    # ========================================================

    if not validate_topics(topics):

        sys.exit(1)

    # ========================================================
    # DATABASE CONNECTION
    # ========================================================

    print(
        "Connecting to LearnRoot MySQL database..."
    )

    connection = None

    try:

        connection = get_connection()

        if not connection:

            print()
            print(
                "ERROR: Database connection failed."
            )

            sys.exit(1)

        # ====================================================
        # CURRENT TOPICS
        # ====================================================

        cursor = connection.cursor()

        existing_topics = get_existing_topics(
            cursor
        )

        cursor.close()

        print_existing_topics(
            existing_topics
        )

        # ====================================================
        # PREVIEW
        # ====================================================

        preview_changes(
            topics,
            existing_topics
        )

        # ====================================================
        # SAFE MODE
        # ====================================================

        if not args.apply:

            print()
            print("=" * 70)
            print("SAFE PREVIEW ONLY")
            print("=" * 70)

            print()
            print(
                "No database changes were made."
            )

            print()
            print(
                "If everything looks correct, run:"
            )

            print()
            print(
                "python seed_topics.py --apply"
            )

            print()

            return

        # ====================================================
        # APPLY
        # ====================================================

        print()
        print("=" * 70)
        print("APPLYING SYLLABUS IMPORT")
        print("=" * 70)

        success = import_topics(
            connection,
            topics
        )

        if not success:

            sys.exit(1)

        # ====================================================
        # FINAL SUMMARY
        # ====================================================

        print_final_summary(
            connection
        )

        print()
        print("=" * 70)
        print("DONE")
        print("=" * 70)

        print()
        print(
            "The syllabus has been imported "
            "into LearnRoot."
        )

        print()

    except Exception as e:

        print()
        print("=" * 70)
        print("DATABASE ERROR")
        print("=" * 70)

        print()
        print(
            e
        )

        print()

        sys.exit(1)

    finally:

        if connection:

            connection.close()


# ============================================================
# START PROGRAM
# ============================================================

if __name__ == "__main__":
    main()