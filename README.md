# Warby Parker Usage Funnels — Data Engineering Project

An end-to-end data engineering project built on top of Codecademy's **Usage Funnels with Warby Parker** SQL capstone. Instead of just running queries in a notebook, this project stands up a full local pipeline: raw CSVs → PostgreSQL (via Docker) → automated ETL load → SQL funnel analysis → live Grafana dashboard.

Built as part of the **Data Engineer career path** on Codecademy.

## 🏗️ Architecture

```
CSV files  --->  load_data.py (ETL)  --->  PostgreSQL  --->  Grafana Dashboard
                                             (Docker)          (Docker)
```

- **PostgreSQL** and **Grafana** run as containers, orchestrated with `docker-compose`.
- A Python ETL script (`etl/load_data.py`) reads the raw CSVs and loads them into Postgres using `pandas` + `SQLAlchemy`.
- SQL queries (`sql/usage_funnels_analysis.sql`) analyze quiz drop-off, home try-on conversion, and purchase behavior.
- Grafana connects to the same Postgres instance to visualize the funnel and revenue metrics live.

## 📦 Project Structure

```
.
├── docker-compose.yml          # Spins up PostgreSQL + Grafana
├── .env.example                 # Template for required environment variables
├── .gitignore
├── etl/
│   └── load_data.py            # Loads CSVs into PostgreSQL
├── csvs/
│   ├── quiz.csv
│   ├── home_try_on.csv
│   ├── purchase.csv
│   └── survey.csv
├── sql/
│   └── usage_funnels_analysis.sql   # Funnel & conversion analysis queries
└── grafana/
    └── warby_parker_dashboard.json  # Exported Grafana dashboard
```

## 📌 Project Background

Warby Parker is a designer eyewear brand offering a **style quiz**, a **home try-on program**, and a **purchase flow**. This project analyzes the marketing funnel across those three stages using fictional data provided in collaboration with Warby Parker's Data Science team:

- **Quiz Funnel:** `survey` — tracks completion of a 5-question style quiz
- **Home Try-On Funnel:** `quiz` → `home_try_on` → `purchase` — tracks users from quiz completion through requesting sample pairs to final purchase

## 🚀 Running the Project

1. **Clone the repo**
   ```bash
   git clone https://github.com/<your-username>/<repo-name>.git
   cd <repo-name>
   ```

2. **Set up your environment variables**
   ```bash
   cp .env.example .env
   # then edit .env and set your own POSTGRES_PASSWORD / GF_SECURITY_ADMIN_PASSWORD
   ```

3. **Start PostgreSQL and Grafana**
   ```bash
   docker-compose up -d
   ```

4. **Install Python dependencies and run the ETL script**
   ```bash
   pip install pandas sqlalchemy psycopg2-binary python-dotenv
   python etl/load_data.py
   ```

5. **Run the analysis queries**
   Connect to Postgres (`localhost:5432`, db `warby_parker`, user `postgres`) with `psql` or any GUI tool and run:
   ```bash
   psql -h localhost -U postgres -d warby_parker -f sql/usage_funnels_analysis.sql
   ```

6. **View the dashboard**
   Open Grafana at [http://localhost:3000](http://localhost:3000) (default login: `admin` / `admin`, or the password set in `docker-compose.yml`). Add a PostgreSQL data source pointing at host `postgres:5432` (the Docker service name, not `localhost`), then import `grafana/warby_parker_dashboard.json`.

## 📊 Dashboard Panels

| Panel | What it shows |
|---|---|
| Style Quiz Completion by Question | Number of distinct users answering each of the 5 quiz questions |
| Overall Funnel Stages Volume | User counts at each funnel stage: quiz → home try-on → purchase |
| Conversion Rates (%) | Headline conversion rates between funnel stages |
| A/B Test: Purchase Rate by Pairs Offered | Whether trying more pairs at home correlates with purchasing |
| Top Selling Glass Models | Best-selling frame models by units and/or revenue |

## 🛠️ Tech Stack

- **PostgreSQL** — relational data store
- **Docker & Docker Compose** — containerized local environment
- **Python** (`pandas`, `SQLAlchemy`) — ETL pipeline
- **SQL** — funnel and conversion analysis (window functions, CTEs, conditional aggregation)
- **Grafana** — dashboarding and visualization

## 💡 Key Findings

- Quiz completion drops off steadily from question 1 to question 5, with the largest fall-off at the final "last eye exam" question.
- Users who try on more pairs at home tend to show a different purchase rate than single-pair users — see the dashboard for the exact breakdown.
- Revenue is concentrated in a subset of styles and colors, useful for merchandising decisions.

## About

This project is part of my portfolio for the **Codecademy Data Engineer** career path, demonstrating a full pipeline: containerized infrastructure, Python-based ETL, SQL analysis, and BI dashboarding — not just isolated queries.
