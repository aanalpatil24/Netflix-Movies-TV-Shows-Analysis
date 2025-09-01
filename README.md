# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/aanalpatil24/Netflix_Sql_Analysis/blob/dcae74132dd5bb9e58464137e0ab2742c5b60ec6/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (Movies or TV Shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
-- Netflix Movies & TV Shows Analysis Project

-- Create and use the database
CREATE DATABASE IF NOT EXISTS netflix_db;
USE netflix_db;

-- DROP DATABaSE IF EXISTS netflix_db;

-- SCHEMAS of Netflix
-- Drop table if it exists
DROP TABLE IF EXISTS netflix;

-- Create table
CREATE TABLE netflix (
    show_id  VARCHAR(10),
    show_type  VARCHAR(20),
    title  VARCHAR(255),
    director TEXT,
    casts  TEXT,
    country TEXT,
    date_added  VARCHAR(100),
    release_year INT,
    rating  VARCHAR(20),
    duration  VARCHAR(20),
    listed_in TEXT,
    show_description  TEXT
);

-- Check table
SELECT * FROM netflix;

```

## Solutions of 15 Business Problems


### 1. Count the number of Movies and TV Shows

```sql
SELECT 
    show_type,
    COUNT(*) AS total
FROM netflix
GROUP BY show_type
ORDER BY total;
```

**Objective:** Determine the distribution of content types on Netflix.


### 2. Find the most common rating for movies and TV shows

```sql
SELECT 
    show_type, 
    rating_count,
    rating AS most_frequent_rating
FROM (
    SELECT 
        show_type,
        rating,
        COUNT(*) AS rating_count,
        RANK() OVER (PARTITION BY show_type ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix
    GROUP BY show_type, rating
) AS ranked
WHERE rnk = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.


### 3. List all movies released in a specific year (e.g., 2020)

```sql
SELECT * 
FROM netflix
WHERE 
show_type='Movie' AND 
release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.


### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT 
    TRIM(SUBSTRING_INDEX(country, ',', 1)) AS country,
    COUNT(*) AS total_content
FROM netflix
WHERE country IS NOT NULL AND country <> ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.


### 5. Identify the 5 longest movies

```sql
SELECT *
FROM netflix
WHERE show_type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 5;
```

**Objective:** Find the movie with the longest duration.


### 6. Content added in the last 5 years

```sql
SELECT *
FROM netflix
WHERE date_added IS NOT NULL AND
STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;
```

**Objective:** Retrieve content added to Netflix in the last 5 years.


### 7. Find All Movies/TV Shows by Director 'Steven Spielberg'

```sql
SELECT *
FROM netflix
WHERE director LIKE '%Steven Spielberg%';
```


**Objective:** List all content directed by 'Steven Spielberg'.


### 8. List All TV Shows with More Than 5 Seasons
```sql
SELECT *
FROM netflix
WHERE 
    show_type = 'TV Show'
    AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;
```


**Objective:** Identify TV shows with more than 5 seasons.


### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
  genre,
  COUNT(*) AS total_titles
FROM (
    SELECT DISTINCT show_id, TRIM(SUBSTRING_INDEX(listed_in, ',', 1)) AS genre FROM netflix
    WHERE listed_in IS NOT NULL
    UNION
    SELECT DISTINCT show_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', 2), ',', -1)) FROM netflix
    WHERE listed_in IS NOT NULL
    UNION
    SELECT DISTINCT show_id, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', 3), ',', -1)) FROM netflix
    WHERE listed_in IS NOT NULL
) AS all_genres
WHERE genre IS NOT NULL AND genre <> ''
GROUP BY genre
ORDER BY total_titles DESC;
```


**Objective:** Count the number of content items in each genre.


### 10.Find each year and the average numbers of content release in India on netflix. Return top 5 year with highest avg content release!


```sql
SELECT 
    release_year,
    COUNT(*) AS total_release,
    ROUND(COUNT(*) / total.total_count * 100, 2) AS avg_release
FROM netflix,
     (SELECT COUNT(*) AS total_count FROM netflix WHERE country LIKE '%India%') AS total
WHERE country LIKE '%India%'
GROUP BY release_year, total.total_count
ORDER BY avg_release DESC
LIMIT 5;
```

**Objective:** Calculate and rank years by the average number of content releases by India.


### 11. List All Movies that are Documentaries


```sql
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%';
```

**Objective:** Retrieve all movies classified as documentaries.


### 12. Find All Content Without a Director

```sql
SELECT * FROM netflix
WHERE director IS NULL OR director = '';
```

**Objective:** List content that does not have a director.


### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * FROM netflix
WHERE 
    casts LIKE '%Salman Khan%'
    AND release_year > YEAR(CURDATE()) - 10;
```


**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.


### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
    actor,
    COUNT(*) AS appearances
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(casts, ',', n.n), ',', -1)) AS actor
    FROM netflix
    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    ) AS n
    ON CHAR_LENGTH(casts) - CHAR_LENGTH(REPLACE(casts, ',', '')) >= n.n - 1
    WHERE country LIKE '%India%' AND casts IS NOT NULL
) AS actor_list
GROUP BY actor
ORDER BY appearances DESC
LIMIT 10;
```


**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.


### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
```sql
SELECT 
    category,
    show_type,
    COUNT(*) AS content_count
FROM (
    SELECT *,
           CASE 
               WHEN LOWER(show_description) LIKE '%kill%' OR LOWER(show_description) LIKE '%violence%' THEN 'Bad'
               ELSE 'Good'
           END AS category
    FROM netflix
) AS labeled
GROUP BY category, show_type
ORDER BY show_type;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

-- End of the Project






## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Anal Patil

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

