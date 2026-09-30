-- =====================================================
-- Codecademy: Usage Funnels with Warby Parker
-- (PostgreSQL version)
-- =====================================================

-- Task 1: Preview the survey table
SELECT *
FROM survey
LIMIT 10;

-- Task 2: Count how many distinct users answered each quiz question
SELECT question,
       COUNT(DISTINCT user_id) AS total_responses
FROM survey
GROUP BY question;

-- Task 3: Calculate each question's response count as a percentage
--         of the previous question's responses (quiz drop-off rate)
WITH quiz_funnel AS (
  SELECT question,
         COUNT(DISTINCT user_id) AS total_responses
  FROM survey
  GROUP BY question
)
SELECT question,
       total_responses,
       ROUND(
         CAST(total_responses AS NUMERIC)
         / LAG(total_responses, 1, total_responses) OVER () * 100,
       2) AS pct_of_previous_question
FROM quiz_funnel;

-- Task 4: Preview the quiz, home_try_on, and purchase tables
SELECT * FROM quiz LIMIT 5;
SELECT * FROM home_try_on LIMIT 5;
SELECT * FROM purchase LIMIT 5;

-- Task 5: Build a unified funnel by combining quiz, home_try_on,
--         and purchase with LEFT JOINs, flagging each user's
--         progression and their A/B test pair count
SELECT q.user_id,
       hto.user_id IS NOT NULL AS is_home_try_on,
       hto.number_of_pairs,
       prch.user_id IS NOT NULL AS is_purchase
FROM quiz AS q
LEFT JOIN home_try_on AS hto
  ON q.user_id = hto.user_id
LEFT JOIN purchase AS prch
  ON q.user_id = prch.user_id
LIMIT 10;

-- Task 6a: Overall conversion rate from quiz completion to purchase
-- NOTE: Postgres booleans can't be SUM()'d directly like SQLite allows,
-- so is_purchase/is_home_try_on are cast with CASE WHEN before summing.
WITH funnel AS (
  SELECT q.user_id,
         hto.user_id IS NOT NULL AS is_home_try_on,
         hto.number_of_pairs,
         prch.user_id IS NOT NULL AS is_purchase
  FROM quiz AS q
  LEFT JOIN home_try_on AS hto
    ON q.user_id = hto.user_id
  LEFT JOIN purchase AS prch
    ON q.user_id = prch.user_id
)
SELECT ROUND(
         100.0 * SUM(CASE WHEN is_purchase THEN 1 ELSE 0 END)
         / COUNT(DISTINCT user_id),
       2) AS overall_purchase_rate_pct
FROM funnel;

-- Task 6b: Conversion rate from quiz to home try-on, and from
--          home try-on to purchase
WITH funnel AS (
  SELECT q.user_id,
         hto.user_id IS NOT NULL AS is_home_try_on,
         hto.number_of_pairs,
         prch.user_id IS NOT NULL AS is_purchase
  FROM quiz AS q
  LEFT JOIN home_try_on AS hto
    ON q.user_id = hto.user_id
  LEFT JOIN purchase AS prch
    ON q.user_id = prch.user_id
)
SELECT ROUND(
         100.0 * SUM(CASE WHEN is_home_try_on THEN 1 ELSE 0 END)
         / COUNT(DISTINCT user_id),
       2) AS home_try_on_rate_pct,
       ROUND(
         100.0 * SUM(CASE WHEN is_purchase THEN 1 ELSE 0 END)
         / NULLIF(SUM(CASE WHEN is_home_try_on THEN 1 ELSE 0 END), 0),
       2) AS purchase_after_try_on_rate_pct
FROM funnel;

-- Task 6c: Purchase rate broken down by number of pairs tried on,
--          to see if trying more pairs correlates with buying
WITH funnel AS (
  SELECT q.user_id,
         hto.number_of_pairs,
         prch.user_id IS NOT NULL AS is_purchase
  FROM quiz AS q
  LEFT JOIN home_try_on AS hto
    ON q.user_id = hto.user_id
  LEFT JOIN purchase AS prch
    ON q.user_id = prch.user_id
)
SELECT number_of_pairs,
       COUNT(*) AS total_users,
       SUM(CASE WHEN is_purchase THEN 1 ELSE 0 END) AS total_purchases,
       ROUND(
         100.0 * SUM(CASE WHEN is_purchase THEN 1 ELSE 0 END) / COUNT(*),
       2) AS purchase_rate_pct
FROM funnel
WHERE number_of_pairs IS NOT NULL
GROUP BY number_of_pairs
ORDER BY CAST(SPLIT_PART(number_of_pairs, ' ', 1) AS INTEGER);
