"""
config.py — Carga de configuración desde .env
Todos los notebooks hacen: from config import PG_ENGINE, CH
"""
import os
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine
from clickhouse_driver import Client

# Buscar el .env desde cualquier subdirectorio
BASE_DIR = Path(__file__).resolve().parent
load_dotenv(BASE_DIR / '.env')

# ── PostgreSQL ─────────────────────────────────────────────────
PG_HOST     = os.getenv('PG_HOST')
PG_PORT     = int(os.getenv('PG_PORT', 5432))
PG_DATABASE = os.getenv('PG_DATABASE')
PG_USER     = os.getenv('PG_USER')
PG_PASSWORD = os.getenv('PG_PASSWORD')

PG_ENGINE = create_engine(
    f"mysql+pymysql://{PG_USER}:{PG_PASSWORD}"
    f"@{PG_HOST}:{PG_PORT}/{PG_DATABASE}",
    pool_pre_ping=True
)

# ── ClickHouse ─────────────────────────────────────────────────
CH_HOST     = os.getenv('CH_HOST', 'localhost')
CH_PORT     = int(os.getenv('CH_PORT', 9000))
CH_USER     = os.getenv('CH_USER', 'default')
CH_PASSWORD = os.getenv('CH_PASSWORD', '')

CH = Client(
    host=CH_HOST,
    port=CH_PORT,
    user=CH_USER,
    password=CH_PASSWORD,
)

# ── Nombres de bases de datos por capa ────────────────────────
BRONZE_DB = os.getenv('BRONZE_DB', 'bronze')
SILVER_DB = os.getenv('SILVER_DB', 'silver')
GOLD_DB   = os.getenv('GOLD_DB',   'gold')

# ── Pipeline ──────────────────────────────────────────────────
LOG_LEVEL  = os.getenv('LOG_LEVEL', 'INFO')
BATCH_SIZE = int(os.getenv('BATCH_SIZE', 50000))

# ── Verificación rápida al importar ───────────────────────────
if __name__ == '__main__':
    print("PostgreSQL:", PG_ENGINE.execute("SELECT version()").scalar())
    print("ClickHouse:", CH.execute("SELECT version()")[0][0])
    print(f"Capas: {BRONZE_DB} | {SILVER_DB} | {GOLD_DB}")
    print("✓ Config OK")