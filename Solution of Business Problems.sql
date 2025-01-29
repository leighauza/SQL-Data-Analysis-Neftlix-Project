-- Exploration of Business Problems

-- 1. Distribution of Movies vs. TV Shows with trend over time

-- 1.a. Count of Movies vs. TV Shows

SELECT 
  type,
  COUNT(show_id)
FROM netflix
GROUP BY
  type;

-- 1.b. Count Movies vs. TV Shows over the last 5 years

SELECT 
  EXTRACT(YEAR FROM date_added) AS year_added,
  type,
  COUNT(show_id)
FROM netflix
WHERE
  EXTRACT(YEAR FROM date_added) IS NOT NULL
  AND EXTRACT(YEAR FROM date_added) > 2016
GROUP BY
  type,
  year_added
ORDER BY
  year_added DESC,
  type;

-- Alternative

SELECT 
  EXTRACT(YEAR FROM date_added) AS year_added,
  COUNT(show_id) AS show_count
FROM netflix
WHERE
  EXTRACT(YEAR FROM date_added) >= 2017
  AND EXTRACT(YEAR FROM date_added) IS NOT NULL
  AND type = 'Movie'
GROUP BY
  year_added
ORDER BY
  show_count DESC;

SELECT 
  EXTRACT(YEAR FROM date_added) AS year_added,
  COUNT(show_id) AS show_count
FROM netflix
WHERE
  EXTRACT(YEAR FROM date_added) >= 2017
  AND EXTRACT(YEAR FROM date_added) IS NOT NULL
  AND type = 'TV Show'
GROUP BY
  year_added
ORDER BY
  show_count DESC;


-- 2. Seeing the distribution of ratings across Movies and TV Shows

-- 2.a. Total number of shows per rating

WITH ranked_ratings AS (
  SELECT
    type,
    rating,
    count(rating) AS count,
    RANK () OVER (PARTITION BY type ORDER BY count(rating) DESC) as rank
  FROM netflix
  WHERE
    rating NOT LIKE '%min%'
    AND rating IS NOT NULL
  GROUP BY type, rating
)

SELECT
  type,
  rank,
  rating,
  count
FROM ranked_ratings
WHERE
  rank <= 5
GROUP BY type, rating, rank, count
ORDER BY rank;



-- 2.b. Top 5 for movies, top 5 for tv shows

-- Movie
SELECT
  type,
  rating,
  count(show_id) AS count
FROM netflix
WHERE
    rating NOT LIKE '%min%'
    AND rating IS NOT NULL
    AND type = 'Movie'
GROUP BY type, rating
ORDER BY count DESC
LIMIT 5;

-- TV Show
SELECT
  type,
  rating,
  count(show_id) AS count
FROM netflix
WHERE
    rating NOT LIKE '%min%'
    AND rating IS NOT NULL
    AND type = 'TV Show'
GROUP BY type, rating
ORDER BY count DESC
LIMIT 5;


-- Seeing top 10 countries contributing in Movies and TV Shows.

WITH countries_unnested AS (
  SELECT
    UNNEST(STRING_TO_ARRAY(country, ',')) AS country_group,
    show_id
  FROM netflix
)

SELECT
  TRIM(country_group) AS top_10_countries,
  COUNT(show_id) AS count_of_titles
FROM countries_unnested
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


-- Contribution of top 10 counties per year

WITH countries_unnested AS (
  SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_group,
    show_id,
    EXTRACT(YEAR FROM date_added) AS year_added
  FROM netflix
)

SELECT
  country_group,
  COUNT(*) FILTER(WHERE year_added = '2017') AS year_2017,
  COUNT(*) FILTER(WHERE year_added = '2018') AS year_2018,
  COUNT(*) FILTER(WHERE year_added = '2019') AS year_2019,
  COUNT(*) FILTER(WHERE year_added = '2020') AS year_2020,
  COUNT(*) FILTER(WHERE year_added = '2021') AS year_2021,
  COUNT(*)/5 AS average,
  COUNT(*) AS total
FROM countries_unnested
GROUP BY country_group
ORDER BY COUNT(*) DESC
LIMIT 10;

-- #4 Duration of Movies vs. TV Shows

-- Average, Min, Max for Movies

WITH new_duration AS (
  SELECT
    show_id,
    type,
    CASE
      WHEN duration LIKE '%min%' THEN CAST(TRIM(REPLACE(duration, 'min', '')) AS INT)
      WHEN duration LIKE '%Season%' THEN 
        CAST(TRIM(SUBSTRING(duration FROM 1 FOR POSITION('Season' IN duration) - 1)) AS INT)
      ELSE NULL -- Handle any other cases where duration doesn't match these patterns
    END AS clean_duration
  FROM netflix
)

SELECT
  ROUND(AVG(clean_duration) / 60.0, 2) AS avg_hours,
  ROUND(MAX(clean_duration) / 60.0, 2) AS max_hours,
  ROUND(MIN(clean_duration) / 60.0, 2) AS min_hours
FROM new_duration
WHERE
  type = 'Movie';

-- Average, Min, Max for Movies

WITH new_duration AS (
  SELECT
    show_id,
    type,
    CASE
      WHEN duration LIKE '%min%' THEN CAST(TRIM(REPLACE(duration, 'min', '')) AS INT)
      WHEN duration LIKE '%Season%' THEN 
        CAST(TRIM(SUBSTRING(duration FROM 1 FOR POSITION('Season' IN duration) - 1)) AS INT)
      ELSE NULL -- Handle any other cases where duration doesn't match these patterns
    END AS clean_duration
  FROM netflix
)

SELECT
  ROUND(AVG(clean_duration), 1) AS avg_seasons,
  MAX(clean_duration) AS max_seasons,
  MIN(clean_duration) AS min_seasons
FROM new_duration
WHERE
  type = 'TV Show';

-- Count per Duration Group (TV Shows)


WITH new_duration AS (
  SELECT
    show_id,
    type,
    CASE
      WHEN duration LIKE '%min%' THEN CAST(TRIM(REPLACE(duration, 'min', '')) AS INT)
      WHEN duration LIKE '%Season%' THEN 
        CAST(TRIM(SUBSTRING(duration FROM 1 FOR POSITION('Season' IN duration) - 1)) AS INT)
      ELSE NULL -- Handle any other cases where duration doesn't match these patterns
    END AS clean_duration
  FROM netflix
)

/*

SELECT
  CASE
    WHEN clean_duration <= 1 THEN '1'
    WHEN clean_duration <= 3 THEN '2-3'
    WHEN clean_duration <= 6 THEN '4-6'
    WHEN clean_duration <= 10 THEN '7-10'
    WHEN clean_duration <= 17 THEN '11+'
    ELSE NULL
  END AS duration_group,
  COUNT(show_id) AS show_count
FROM new_duration
WHERE type = 'TV Show'
GROUP BY duration_group
ORDER BY show_count DESC;
*/

/*
SELECT*
FROM new_duration
WHERE type = 'TV Show' AND
  clean_duration >= 11;
*/

-- Count per Duration Group (Movies)

SELECT
  CASE
    WHEN clean_duration <= 60 THEN '-1 hr'
    WHEN clean_duration <= 90 THEN '1-1.5 hrs'
    WHEN clean_duration <= 120 THEN '1.5-2 hrs'
    WHEN clean_duration <= 150 THEN '2-2.5 hrs'
    WHEN clean_duration <= 180 THEN '2.5-3 hrs'
    ELSE '3+ hrs'
  END AS duration_group,
  COUNT(show_id) AS show_count
FROM new_duration
WHERE type = 'Movie'
GROUP BY duration_group
ORDER BY duration_group ASC;


SELECT*
FROM new_duration
WHERE type = 'Movie' AND
  clean_duration >= 180;

-- Categories

WITH unnested_categories AS (
  SELECT
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS category,
    COUNT(show_id) AS show_count
  FROM netflix
  GROUP BY category
)

SELECT
  TRIM(category) AS top_category,
  SUM(show_count) AS total_count
FROM unnested_categories
GROUP BY top_category
ORDER BY total_count DESC
LIMIT 20;

-- #6 Top 30 Directors

-- All time

SELECT
  UNNEST(STRING_TO_ARRAY(director, ',')) AS top_directors,
  COUNT(show_id) AS show_count
FROM netflix
GROUP BY top_directors
ORDER BY show_count DESC
LIMIT 30;

-- For 2021


SELECT
  UNNEST(STRING_TO_ARRAY(director, ',')) AS top_directors,
  COUNT(show_id) AS show_count
FROM netflix
WHERE
  EXTRACT(YEAR FROM date_added) = '2021'
GROUP BY top_directors
ORDER BY show_count DESC
LIMIT 30;

-- # 9 Adding Global Averages


WITH countries_unnested AS (
  SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country_group,
    show_id,
    EXTRACT(YEAR FROM date_added) AS year_added
  FROM netflix
),

trend_top_30_countries AS(
  SELECT
    country_group,
    COUNT(*) FILTER(WHERE year_added = 2017) AS year_2017,
    COUNT(*) FILTER(WHERE year_added = 2018) AS year_2018,
    COUNT(*) FILTER(WHERE year_added = 2019) AS year_2019,
    COUNT(*) FILTER(WHERE year_added = 2020) AS year_2020,
    COUNT(*) FILTER(WHERE year_added = 2021) AS year_2021,
    ROUND(COUNT(*)/5.0) AS average,
    COUNT(*) AS total
  FROM countries_unnested
  GROUP BY country_group
  ORDER BY COUNT(*) DESC
  LIMIT 30
)

SELECT --- Global Averages (from Top 30 countries)
  'Global Average' AS country_group,
  ROUND(AVG(year_2017)) AS avg_2017,
  ROUND(AVG(year_2018)) AS avg_2018,
  ROUND(AVG(year_2019)) AS avg_2019,
  ROUND(AVG(year_2020)) AS avg_2020,
  ROUND(AVG(year_2021)) AS avg_2021,
  ROUND(AVG(average)) AS avg_per_year,
  ROUND(SUM(total) / 30.0) AS avg_total
FROM trend_top_30_countries

UNION ALL

SELECT *
FROM trend_top_30_countries
LIMIT 10;

-- #10 Count of Missing Data

SELECT
  COUNT(*) FILTER(WHERE director IS NULL OR TRIM(director) = '') AS missing_director,
  COUNT(*) FILTER(WHERE casting IS NULL OR TRIM(casting) = '') AS missing_cast,
  COUNT(*) FILTER(WHERE country IS NULL OR TRIM(country) = '') AS missing_country,
  COUNT(*) FILTER(WHERE listed_in IS NULL OR TRIM(listed_in) = '') AS missing_category,
  COUNT(*) FILTER(WHERE rating IS NULL OR TRIM(rating) = '') AS missing_rating
FROM netflix;

-- #11 Actors Contributions all-time and increasing contributions

-- Top 100 Contibutors of All-Time
SELECT
  TRIM(UNNEST(STRING_TO_ARRAY(casting, ', '))) AS actors,
  COUNT(show_id) AS show_count
FROM netflix
GROUP BY TRIM(UNNEST(STRING_TO_ARRAY(casting, ', ')))
ORDER BY show_count DESC
LIMIT 100;

-- Top 100 Increasing Contributors (Long Version)

WITH top_contributors AS (
  SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(casting, ', '))) AS actors,
    show_id,
    EXTRACT(YEAR FROM date_added) AS year_added
  FROM netflix
)

SELECT
  actors,
  COUNT(*) FILTER(WHERE year_added = 2019) AS count_2019,
  COUNT(*) FILTER(WHERE year_added = 2020) AS count_2020,
  COUNT(*) FILTER(WHERE year_added = 2021) AS count_2021,
  COUNT(show_id) AS total_count
FROM top_contributors
GROUP BY actors
HAVING
  COUNT(*) FILTER(WHERE year_added = 2019) <
  COUNT(*) FILTER(WHERE year_added = 2020) AND
  COUNT(*) FILTER(WHERE year_added = 2020) <
  COUNT(*) FILTER(WHERE year_added = 2021)
ORDER BY total_count DESC
LIMIT 100;

-- Top 100 Increasing Contributors (Shorthand Version)

WITH top_contributors AS (
  SELECT
    TRIM(UNNEST(STRING_TO_ARRAY(casting, ', '))) AS actors,
    show_id,
    EXTRACT(YEAR FROM date_added) AS year_added
  FROM netflix
)

SELECT
  actors,
  COUNT(show_id) AS total_count
FROM top_contributors
GROUP BY actors
HAVING
  COUNT(*) FILTER(WHERE year_added = 2019) <
  COUNT(*) FILTER(WHERE year_added = 2020) AND
  COUNT(*) FILTER(WHERE year_added = 2020) <
  COUNT(*) FILTER(WHERE year_added = 2021)
ORDER BY total_count DESC
LIMIT 100;