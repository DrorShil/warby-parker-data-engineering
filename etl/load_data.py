import os
import pandas as pd
from sqlalchemy import create_engine
from dotenv import load_dotenv

# 1. Load environment variables from .env (see .env.example for the template)
load_dotenv()

PG_USER = os.environ["POSTGRES_USER"]
PG_PASSWORD = os.environ["POSTGRES_PASSWORD"]
PG_DB = os.environ["POSTGRES_DB"]
PG_HOST = os.environ.get("POSTGRES_HOST", "localhost")
PG_PORT = os.environ.get("POSTGRES_PORT", "5432")

# 2. Establish PostgreSQL connection engine
pg_engine = create_engine(
    f"postgresql://{PG_USER}:{PG_PASSWORD}@{PG_HOST}:{PG_PORT}/{PG_DB}"
)

# 3. List target tables
tables = ['quiz', 'home_try_on', 'purchase', 'survey']

# 4. Extract from CSVs and load to PostgreSQL
for table in tables:
    csv_path = os.path.join('csvs', f'{table}.csv')

    print(f"Reading {csv_path}...")
    df = pd.read_csv(csv_path)

    print(f"Loading into PostgreSQL table '{table}'...")
    df.to_sql(table, pg_engine, if_exists='replace', index=False)

print("All tables loaded successfully into PostgreSQL!")
