# Netflix Movies and TV Shows Data Analysis using SQL


## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql

CREATE TABLE netflix (
	show_id VARCHAR(7) PRIMARY KEY,
	type VARCHAR(10),
	title VARCHAR(200),
	director VARCHAR(300),
	casting VARCHAR(1000),
	country VARCHAR(200),
	date_added DATE,
	release_year INT,
	rating VARCHAR(10),
	duration VARCHAR(10),
	listed_in VARCHAR (100),
	description VARCHAR(600)
);

SELECT * FROM netflix;

```

## Business Problems and Solutions

### 1. Content Distribution Analysis: Movies vs. TV Shows (2017-2021)

**Content Distribution Overview** - The total count of Movies vs TV Shows in Netflix's catalog as of 2021, revealing overall content distribution.

```sql
SELECT 
  type,
  COUNT(show_id)
FROM netflix
GROUP BY
  type;
```

| Type     | Count |
|----------|-------|
| Movie    | 6131  |
| TV Show  | 2676  |


**Trend Analysis of Content Distribution** - Annual breakdown of Netflix's content additions from 2017-2021, showing the distribution between Movies and TV Shows over time.

```sql
SELECT 
  EXTRACT(YEAR FROM date_added) AS year_added,
  COUNT(show_id) AS show_count
FROM netflix
WHERE
  EXTRACT(YEAR FROM date_added) >= 2017
  AND EXTRACT(YEAR FROM date_added) IS NOT NULL
  AND type = 'Movie' -- Same format for 'TV Show'
GROUP BY
  year_added
ORDER BY
  show_count DESC;
```

**Movies** ---
| Year Added | Movie Count |
| --- | --- |
| 2019 | 1,424 |
| 2020 | 1,284 |
| 2018 | 1,237 |
| 2021 | 993 |
| 2017 | 839 |

**TV Shows** ---
| Year Added | TV Show Count |
| --- | --- |
| 2020 | 595 |
| 2019 | 592 |
| 2021 | 505 |
| 2018 | 412 |
| 2017 | 349 |

**Key Findings:**

- Movies dominate the catalog with a significant 70% share (6,131 movies vs 2,676 TV shows)
- Peak content addition was in 2019-2020, with 1,424 movies added in 2019 and 595 TV shows in 2020
- Content addition showed a slight decline in 2021, dropping to 993 movies and 505 TV shows

**Strategic Implications:**

- The decline in 2021 additions may signal a shift in content strategy or impact of production delays
- Despite maintaining a movie-heavy catalog, TV show additions have grown proportionally faster since 2017
- Future strategy should evaluate whether to maintain the current movie-dominant ratio or adjust based on viewing metrics

### 2. Top 5 Content Ratings Across Movies and TV Shows
Examination of rating distributions across Movies and TV Shows in Netflix's catalog to identify predominant content ratings and potential content gaps.

```sql
SELECT
  type,
  rating,
  count(show_id) AS count
FROM netflix
WHERE
    rating NOT LIKE '%min%'
    AND rating IS NOT NULL
    AND type = 'Movie' -- Same format for 'TV Show'
GROUP BY type, rating
ORDER BY count DESC
LIMIT 5;
```

**Top 5 Ratings for Movies**
| Type | Rating | Count |
| --- | --- | --- |
| Movie | TV-MA | 2,062 |
| Movie | TV-14 | 1,427 |
| Movie | R | 797 |
| Movie | TV-PG | 540 |
| Movie | PG-13 | 490 |


**Top 5 Ratings for TV Shows**
| Type | Rating | Count |
| --- | --- | --- |
| TV Show | TV-MA | 1,145 |
| TV Show | TV-14 | 733 |
| TV Show | TV-PG | 323 |
| TV Show | TV-Y7 | 195 |
| TV Show | TV-Y | 176 |

**Key Findings:**

- Movies are dominated by mature content ratings with TV-MA (2,062) and TV-14 (1,427) being the most common ratings
- Similarly, TV Shows follow the same pattern with TV-MA (1,145) and TV-14 (733) leading the distribution
- Family-friendly content (TV-PG, TV-Y7, TV-Y) has a stronger presence in TV Shows than Movies

**Business Insights:**

- The heavy skew toward mature content suggests potential opportunities to diversify into family-friendly programming
- Consider balancing the mature content portfolio with more TV-PG rated content to capture a broader audience demographic
- Future content acquisition strategies should evaluate whether the current rating distribution aligns with target market growth objectives
  
### 3. Geographic Content Analysis: Global Contribution (2017-2021)
An analysis that examines where shows and movies are produced globally and how different regions contribute to the platform's offerings.

**Top 10 Countries by Content Volume**

``` sql
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
```

| Top Countries | Count of Titles |
| --- | --- |
| United States | 3,690 |
| India | 1,046 |
| United Kingdom | 806 |
| Canada | 445 |
| France | 393 |
| Japan | 318 |
| Spain | 232 |
| South Korea | 231 |
| Germany | 226 |
| Mexico | 169 |

**Top 10 Countries' Annual (2017-2021) and Average Contribution**

```sql
WITH countries_unnested AS (
  SELECT
    UNNEST(STRING_TO_ARRAY(country, ',')) AS country_group,
    show_id,
    date_added
  FROM netflix
)

SELECT
  TRIM(country_group) AS top_10_countries,
  COUNT (  -- Takes the average.
	  CASE
	    WHEN EXTRACT(YEAR FROM date_added) >= '2017'
	    THEN show_id
	    ELSE NULL
    END)/5 AS avg_per_year,
  COUNT (  -- Gives the 2017 count.
    CASE
      WHEN EXTRACT(YEAR FROM date_added) = '2017'
      THEN show_id
      ELSE NULL
    END) AS year_2017,
  COUNT (  -- Gives the 2018 count. 
    CASE
      WHEN EXTRACT(YEAR FROM date_added) = '2018'
      THEN show_id
      ELSE NULL
    END) AS year_2018,
  -- The full code continues until 2021, please see for reference.
FROM countries_unnested
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
```

| Country | Avg per Year | 2021 | 2020 | 2019 | 2018 | 2017 |
| --- | --- | --- | --- | --- | --- | --- |
| United States | 674 | 627 | 828 | 856 | 600 | 462 |
| India | 206 | 105 | 199 | 218 | 349 | 162 |
| United Kingdom | 147 | 120 | 146 | 191 | 147 | 134 |
| Canada | 81 | 59 | 110 | 84 | 81 | 71 |
| France | 70 | 60 | 97 | 79 | 64 | 53 |
| Japan | 57 | 53 | 79 | 74 | 44 | 37 |
| South Korea | 44 | 29 | 56 | 59 | 33 | 43 |
| Spain | 42 | 33 | 43 | 53 | 43 | 42 |
| Germany | 42 | 40 | 58 | 45 | 34 | 33 |
| Mexico | 31 | 21 | 30 | 39 | 31 | 36 |

**Key Findings:**

- The United States dominates content production with 3,690 titles, followed by India (1,046) and the United Kingdom (806)
- US content production peaked in 2019 with 856 titles, showing a decline to 627 titles by 2021
- Asian markets show significant presence with India, Japan, and South Korea all in the top 10 content producing countries
- European content is well-represented through UK, France, Spain, and Germany, collectively contributing over 1,600 titles

**Business Insights:**

- The decline in US content production from 2019-2021 suggests an opportunity to diversify content sources and reduce dependency on a single market
- Strong presence in Asian markets indicates potential for further expansion, particularly given the success of content from South Korea and Japan
- Consider increasing investment in emerging markets like Mexico, which currently contributes the least among top 10 with only 31 titles per year on average
- European market presence could be strengthened by expanding beyond current top contributors and exploring partnerships in other European countries

### 4. Count of Top Performing Categories
An analysis of Netflix's content categories, examining the distribution of shows and movies across different genres, categories, or lists.

```sql
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
```

Top 20 Categories with Volume
| Category | Total Count |
|--------------|-------------|
| International Movies | 2752 |
| Dramas | 2427 |
| Comedies | 1674 |
| International TV Shows | 1351 |
| Documentaries | 869 |
| Action & Adventure | 859 |
| TV Dramas | 763 |
| Independent Movies | 756 |
| Children & Family Movies | 641 |
| Romantic Movies | 616 |
| TV Comedies | 581 |
| Thrillers | 577 |
| Crime TV Shows | 470 |
| Kids' TV | 451 |
| Docuseries | 395 |
| Music & Musicals | 375 |
| Romantic TV Shows | 370 |
| Horror Movies | 357 |
| Stand-Up Comedy | 343 |
| Reality TV | 255 |

**Key Findings:**

- International content dominates the platform with International Movies (2,752 titles) and International TV Shows (1,351 titles) among the top categories
- Drama and Comedy genres form a substantial portion of the catalog, with Dramas (2,427) and Comedies (1,674) ranking high in content volume
- Family-oriented content has a significant presence through Children & Family Movies (641) and Kids' TV (451)

**Business Insights:**

- The strong presence of international content suggests successful global market penetration and opportunities for further expansion in this area
- While drama and comedy genres are well-represented, there might be opportunities to increase variety in lower-volume categories like Reality TV (255) to capture different audience segments
- The platform could explore expanding specialized content categories like Docuseries (395) and Stand-Up Comedy (343), which have relatively lower representation but potentially dedicated audiences

### 5. Director Analysis: Netflix Content Contributors (All Time vs. 2021)
A comprehensive analysis of Netflix’s most prolific directors, comparing historical data with the most recent data in 2021. This highlights top contributors and high-volume content creators.

```sql
-- All time vs 2021
SELECT
  UNNEST(STRING_TO_ARRAY(director, ',')) AS top_directors,
  COUNT(show_id) AS total_count,
  COUNT(CASE
    WHEN EXTRACT(YEAR FROM date_added) = '2021' THEN 1
    ELSE NULL
  END) AS count_2021
FROM netflix
GROUP BY top_directors
ORDER BY total_count DESC
LIMIT 30;
```
**Director's Total Show Contributions vs 2021 Contributions**
| Director | Total Count | Count 2021 |
| --- | --- | --- |
| Rajiv Chilaka | 22 | 17 |
| Jan Suter | 18 | 0 |
| Raúl Campos | 18 | 0 |
| Suhas Kadav | 16 | 15 |
| Marcus Raboy | 16 | 0 |
| Jay Karas | 15 | 0 |
| Cathy Garcia-Molina | 13 | 0 |
| Jay Chapman | 12 | 0 |
| Martin Scorsese | 12 | 3 |
| Youssef Chahine | 12 | 1 |
| Steven Spielberg | 11 | 3 |
| Don Michael Paul | 10 | 3 |
| David Dhawan | 9 | 1 |
| Shannon Hartman | 9 | 0 |
| Yılmaz Erdoğan | 9 | 2 |
| Quentin Tarantino | 8 | 1 |
| Fernando Ayllón | 8 | 1 |
| Johnnie To | 8 | 0 |
| Ryan Polito | 8 | 0 |
| Troy Miller | 8 | 2 |
| Lance Bangs | 8 | 0 |
| Robert Rodriguez | 8 | 1 |
| Hanung Bramantyo | 8 | 2 |
| Kunle Afolayan | 8 | 0 |
| Hakan Algül | 8 | 2 |
| Prakash Satam | 7 | 2 |
| Omoni Oboli | 7 | 0 |
| Mae Czarina Cruz | 7 | 2 |
| Anurag Kashyap | 7 | 0 |
| Lasse Hallström | 7 | 5 |

**Key Findings:**

- Rajiv Chilaka leads both all-time (22 titles) and 2021 (17 titles) contributions, showing consistent productivity
- Notable directors like Scorsese, Spielberg, and Tarantino have significant presence in the all-time list
- 2021 saw a strong presence of Asian directors (Hidenori Inoue, Toshiya Shinohara, Suhas Kadav)
- The platform maintains a mix of acclaimed directors (Clint Eastwood, Jane Campion) and prolific content creators

**Business Insights:**

- Consider strengthening relationships with consistently productive directors like Rajiv Chilaka and Suhas Kadav
- The platform should maintain its balance of prestigious directors and high-volume content creators
- The strong presence of international directors aligns with Netflix's global content strategy
- 2021's director list suggests an increased focus on Asian content, which could be further expanded

### 6. Runtime Patterns and Content Duration Across Netflix Shows
An analysis of content duration patterns across Netflix's library, examining the statistical distribution of movie lengths in hours and TV show in seasons.

**Average, Min, Max Duration of Movies and TV Shows**

```sql
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

-- For TV Shows, same CTE(new_duration) is used as above.

SELECT
  ROUND(AVG(clean_duration), 1) AS avg_seasons,
  MAX(clean_duration) AS max_seasons,
  MIN(clean_duration) AS min_seasons
FROM new_duration
WHERE
  type = 'TV Show';
```

**Movies**
| average_hours | max_hours | min_hours |
| --- | --- | --- |
| 1.66 | 5.20 | 0.05 |

**TV Shows**
| avg_seasons | max_seasons | min_seasons |
| --- | --- | --- |
| 1.8 | 17 | 1 |


**Duration Distribution Count**

```sql
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
  CASE   -- Groups Movies
    WHEN clean_duration <= 60 THEN '-1 hr'
    WHEN clean_duration <= 90 THEN '1-1.5 hrs'
    WHEN clean_duration <= 120 THEN '1.5-2 hrs'
    WHEN clean_duration <= 150 THEN '2-2.5 hrs'
    WHEN clean_duration <= 180 THEN '2.5-3 hrs'
    ELSE '3+ hrs'
  END AS movie_duration,
  COUNT(show_id) AS show_count
FROM new_duration
WHERE type = 'Movie'
GROUP BY duration_group
ORDER BY duration_group ASC;

-- For TV Shows, same CTE(new_duration) is used as above.

SELECT
  CASE   -- Groups TV Shows
    WHEN clean_duration <= 1 THEN '1' -- Cascading groups has been chosen to naturally align with the distribution of TV show durations. 
    WHEN clean_duration <= 3 THEN '2-3'
    WHEN clean_duration <= 6 THEN '4-6'
    WHEN clean_duration <= 10 THEN '7-10'
    WHEN clean_duration <= 17 THEN '11+'
    ELSE NULL
  END AS season_duration,
  COUNT(show_id) AS show_count
FROM new_duration
WHERE type = 'TV Show'
GROUP BY duration_group
ORDER BY show_count DESC;

```

| Movie Duration | Show Count |
| --- | --- |
| -1 hr | 487 |
| 1-1.5 hrs | 1,503 |
| 1.5-2 hrs | 2,996 |
| 2-2.5 hrs | 897 |
| 2.5-3 hrs | 198 |
| 3+ hrs | 50 |

| Season Duration | Show Count |
| --- | --- |
| 1 | 1,793 |
| 2-3 | 624 |
| 4-6 | 193 |
| 7-10 | 56 |
| 11+ | 10 |

**Key Findings:**

- Movies average 1.66 hours in length, ranging from 3 minutes (0.05 hours) to 5.2 hours
- The majority of movies (2,996) fall within the 1.5-2 hours range, followed by 1-1.5 hours (1,503)
- TV Shows average 1.8 seasons, with most shows (1,793) being single-season series
- Only 10 TV shows have more than 11 seasons, indicating a strong preference for shorter series

**Business Insights:**

- The concentration of movies in the 1.5-2 hour range suggests this is the optimal duration for new movie productions
- The high number of single-season shows indicates a potential strategy of testing concepts before committing to longer runs
- Very long movies (3+ hours) and extended TV series (11+ seasons) are rare, suggesting limited market demand for such content
- Consider focusing resources on producing more content within the proven duration ranges rather than extremely long or short content

### #7 Long Running Shows by Category

This section analyzes the distribution of long-running TV shows (more than 4 seasons) across different categories on Netflix, providing insights into which genres tend to sustain viewer interest over multiple seasons.

```sql
WITH long_running_shows AS (
  SELECT
    show_id,
    title,
    TRIM(LEFT(duration, 2)) AS number_of_seasons,
    listed_in
  FROM netflix
  WHERE
    type = 'TV Show' AND
    CAST(TRIM(LEFT(duration, 2)) AS INT) > 4
)

SELECT
  TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS categories,
  COUNT(show_id) AS count
FROM long_running_shows
GROUP BY
  categories
ORDER BY
  count DESC;
```

| Category | Count |
| --- | --- |
| TV Comedies | 62 |
| TV Dramas | 60 |
| International TV Shows | 33 |
| Crime TV Shows | 29 |
| Kids' TV | 24 |
| TV Action & Adventure | 22 |
| British TV Shows | 16 |
| Classic & Cult TV | 14 |
| TV Sci-Fi & Fantasy | 14 |
| Romantic TV Shows | 10 |
| TV Mysteries | 9 |
| Docuseries | 9 |
| Teen TV Shows | 8 |
| TV Horror | 8 |
| Anime Series | 6 |
| Reality TV | 6 |
| TV Thrillers | 5 |
| Stand-Up Comedy & Talk Shows | 5 |
| Spanish-Language TV Shows | 5 |
| Science & Nature TV | 1 |
| Korean TV Shows | 1 |

**Key Findings:**

- TV Comedies and TV Dramas dominate long-running shows with 62 and 60 shows respectively
- International TV Shows rank third with 33 long-running series, showing strong global content presence
- Crime TV Shows (29) and Kids' TV (24) form a significant portion of sustained content
- Niche categories like Korean TV Shows and Science & Nature TV have minimal long-running representation (1 show each)

**Business Insights:**

- Focus development resources on comedy and drama genres, as they show the highest success rate for long-running series
- Continue investing in international content, particularly crime shows and kids' programming, which demonstrate strong sustainability
- Consider strategic expansion in underrepresented categories like Korean content, especially given the growing global popularity of K-dramas

### #8 Trend of Top 20 Genres Across 2019-2021

This analysis examines the distribution and trends of Netflix content across different genres from 2019 to 2021, providing insights into content strategy and catalog composition over time.


```sql
SELECT
  UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS category,
  SUM(CASE
    WHEN EXTRACT(YEAR FROM date_added) = '2019' THEN 1
    ELSE 0
  END) AS year_2019,
  SUM(CASE
    WHEN EXTRACT(YEAR FROM date_added) = '2020' THEN 1
    ELSE 0
  END) AS year_2020,
  SUM(CASE
    WHEN EXTRACT(YEAR FROM date_added) = '2021' THEN 1
    ELSE 0
  END) AS year_2021,
  COUNT(show_id) AS count
FROM netflix
GROUP BY category
ORDER BY count DESC
LIMIT 20;
```

| Category | 2019 | 2020 | 2021 | Total |
| --- | --- | --- | --- | --- |
| International Movies | 583 | 538 | 392 | 2624 |
| Dramas | 365 | 346 | 262 | 1600 |
| Comedies | 286 | 302 | 201 | 1210 |
| Action & Adventure | 202 | 170 | 196 | 859 |
| Documentaries | 186 | 107 | 96 | 829 |
| Dramas | 199 | 189 | 150 | 827 |
| International TV Shows | 191 | 154 | 129 | 774 |
| Independent Movies | 196 | 143 | 87 | 736 |
| TV Dramas | 155 | 147 | 124 | 696 |
| Romantic Movies | 149 | 172 | 114 | 613 |
| Children & Family Movies | 136 | 158 | 116 | 605 |
| International TV Shows | 144 | 123 | 100 | 577 |
| Thrillers | 117 | 121 | 90 | 512 |
| Comedies | 134 | 114 | 98 | 464 |
| TV Comedies | 92 | 94 | 91 | 461 |
| Crime TV Shows | 96 | 90 | 63 | 399 |
| Kids' TV | 74 | 89 | 86 | 388 |
| Music & Musicals | 77 | 68 | 56 | 357 |
| Romantic TV Shows | 90 | 60 | 49 | 338 |
| Stand-Up Comedy | 65 | 48 | 17 | 334 |

**Key Findings:**

- International Movies consistently lead content volume, though showing decline from 583 (2019) to 392 (2021)
- Dramas and Comedies maintain strong second and third positions in total content volume
- Children & Family Movies and Kids' TV show relative stability compared to other categories

**Business Insights:**

- The overall decline in content additions across genres may suggest a shift toward quality over quantity in content acquisition.
- Strong international content presence indicates successful global market penetration strategy
- Stable children's content suggests strategic importance of family viewership


## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Leigh Auza

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!
