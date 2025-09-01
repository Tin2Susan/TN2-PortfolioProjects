------------------------------------------

SELECT 
  COUNTRY,"TOTAL MEDALS WON" 
FROM 
  medals_total
LIMIT 3;
----------------------------------------------
ALTER TABLE medals_total RENAME COLUMN total TO "TOTAL MEDALS WON";
ALTER TABLE medals_total RENAME COLUMN country TO "COUNTRY";
ALTER TABLE athletes RENAME COLUMN name_short TO "NAME";
-----------------------------------------------
SELECT country, 
       COUNT(NAME) AS athlete_count
FROM athletes
GROUP BY country
ORDER BY athlete_count DESC;
-----------------------------------------------
SELECT country,
       CASE
           WHEN age < 18 THEN 'Under 18'
           WHEN age BETWEEN 18 AND 24 THEN '18-24'
           WHEN age BETWEEN 25 AND 34 THEN '25-34'
           WHEN age BETWEEN 35 AND 44 THEN '35-44'
           WHEN age BETWEEN 45 AND 54 THEN '45-54'
           ELSE '55 and above'
       END AS age_category,
       COUNT(*) AS athlete_count
FROM (
    SELECT name,
           birth_date,
           country,
           CAST((strftime('%Y', 'now') - strftime('%Y', substr(birth_date, 7, 4) || '-' || substr(birth_date, 4, 2) || '-' || substr(birth_date, 1, 2))) AS INTEGER) 
           - (strftime('%m-%d', 'now') < strftime('%m-%d', substr(birth_date, 7, 4) || '-' || substr(birth_date, 4, 2) || '-' || substr(birth_date, 1, 2))) AS age
    FROM athletes
) AS age_calculation
GROUP BY country, age_category
ORDER BY country, age_category;
---------------------------------------------

-- Subquery to count the number of athletes per country
WITH athlete_counts AS (
    SELECT country,
           COUNT(*) AS num_athletes
    FROM athletes
    GROUP BY country
),

-- Subquery to get the total number of medals won per country
medal_counts AS (
    SELECT country,
           "TOTAL MEDALS WON" AS num_medals
    FROM medals_total
)

-- Final query to join and compare athlete counts with medal counts
SELECT a.country,
       a.num_athletes,
       m.num_medals,
       (CASE 
           WHEN m.num_medals IS NULL THEN 0
           ELSE m.num_medals
       END) AS num_medals,
       (CASE 
           WHEN a.num_athletes > 0 THEN (m.num_medals * 1.0 / a.num_athletes) 
           ELSE 0
       END) AS medals_per_athlete
FROM athlete_counts a
LEFT JOIN medal_counts m
ON a.country = m.country
ORDER BY a.num_athletes DESC;
---------------------------------------------------------------

SELECT 
       CASE
           WHEN age < 18 THEN 'Under 18'
           WHEN age BETWEEN 18 AND 24 THEN '18-24'
           WHEN age BETWEEN 25 AND 34 THEN '25-34'
           WHEN age BETWEEN 35 AND 44 THEN '35-44'
           WHEN age BETWEEN 45 AND 54 THEN '45-54'
           ELSE '55 and above'
       END AS age_category,
       COUNT(*) AS athlete_count
FROM (
    SELECT name,
           birth_date,
           CAST((strftime('%Y', 'now') - strftime('%Y', substr(birth_date, 7, 4) || '-' || substr(birth_date, 4, 2) || '-' || substr(birth_date, 1, 2))) AS INTEGER) 
           - (strftime('%m-%d', 'now') < strftime('%m-%d', substr(birth_date, 7, 4) || '-' || substr(birth_date, 4, 2) || '-' || substr(birth_date, 1, 2))) AS age
    FROM athletes
) AS age_calculation
GROUP BY age_category
ORDER BY age_category;

-------------------------------------------------------

SELECT country, 
       "Gold Medal",
	   "Silver Medal",
	   "Bronze Medal"
       --ROUND(("Gold Medal"* 100.0 / "TOTAL MEDALS WON"),2) AS gold_percentage,
       --ROUND(("Silver Medal" * 100.0 / "TOTAL MEDALS WON"),2) AS silver_percentage,
       --ROUND(("Bronze Medal" * 100.0 / "TOTAL MEDALS WON"),2) AS bronze_percentage
FROM medals_total
limit 20;

--------------------------------------------------------

WITH daily_medals AS (
    SELECT country,
           strftime('%d-%m-%Y', medal_date) AS day,
           COUNT(*) AS daily_medal_count
    FROM medals
    GROUP BY country, day
)
SELECT country,
       day,
       daily_medal_count,
       AVG(daily_medal_count) OVER (PARTITION BY country ORDER BY day ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS moving_avg
FROM daily_medals
ORDER BY country, day;

