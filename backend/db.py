
import os
import mysql.connector
from dotenv import load_dotenv

PROJECT_ROOT = os.path.dirname(
    os.path.dirname(os.path.abspath(__file__))
)

load_dotenv(os.path.join(PROJECT_ROOT, ".env"))

load_dotenv(
    os.path.join(PROJECT_ROOT, "backend", ".env"),
    override=True
)


def get_connection():
    return mysql.connector.connect(
        host=os.getenv("MODULE4_DB_HOST", "localhost"),
        user=os.getenv("MODULE4_DB_USER", "root"),
        password=os.getenv("MODULE4_DB_PASSWORD"),
        database=os.getenv("MODULE4_DB_NAME", "learnroot_module4")
    )
