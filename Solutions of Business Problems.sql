-- Netflix Movies & TV Shows Analysis Project

-- Solutions of 15 Business Problems

-- 1. Count the number of Movies and TV Shows
SELECT 
    show_type,
    COUNT(*) AS total
FROM netflix
GROUP BY show_type
ORDER BY total;

-- 2. Find the most common rating for movies and TV shows
SELECT 
    show_type, 
    rating AS most_frequent_rating,
     rating_count
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

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * 
FROM netflix
WHERE 
show_type='Movie' AND 
release_year = 2020;

-- 4. Top 5 countries with the most content

SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n), ',', -1)) AS country,
    COUNT(DISTINCT show_id) AS total_content
FROM netflix
JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
    UNION ALL SELECT 9 UNION ALL SELECT 10
) AS numbers
  ON numbers.n <= 1 + CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', ''))
WHERE country IS NOT NULL AND country <> ''
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify the 5 longest movie
SELECT *
FROM netflix
WHERE show_type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 5;

-- 6. Content added in the last 5 years
SELECT *
FROM netflix
WHERE date_added IS NOT NULL AND
STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

-- 7. Movies/TV shows by director 'Steven Spielberg'
SELECT *
FROM netflix
WHERE director LIKE '%Steven Spielberg%';

-- 8. TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE 
    show_type = 'TV Show'
    AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

-- 9. Number of content items in each genre

SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n), ',', -1)) AS genre,
    COUNT(DISTINCT show_id) AS total_titles
FROM netflix
JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
    UNION ALL SELECT 9 UNION ALL SELECT 10
) AS numbers
  ON numbers.n <= 1 + CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', ''))
WHERE listed_in IS NOT NULL
GROUP BY genre
ORDER BY total_titles DESC;

-- 10.Top 5 years with the highest number of content items released by India (as percentage of total Indian content)

SET @total_india := (SELECT COUNT(*) FROM netflix WHERE country LIKE '%India%');

SELECT 
    release_year,
    COUNT(*) AS total_release,
    ROUND(COUNT(*) / @total_india * 100, 2) AS release_percentage
FROM netflix
WHERE country LIKE '%India%'
GROUP BY release_year
ORDER BY release_percentage DESC
LIMIT 5;


-- 11. List all movies that are documentaries
SELECT * FROM netflix
WHERE show_type = 'Movie' AND listed_in LIKE '%Documentaries%';


-- 12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL OR director = '';

-- 13. How many movies actor 'Salman Khan' appeared in last 10 years
SELECT COUNT(*) FROM netflix
WHERE 
    casts LIKE '%Salman Khan%'
    AND release_year >= YEAR(CURDATE()) - 10;

-- 14. Top 10 actors with most appearances in Indian content

SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(casts, ',', n), ',', -1)) AS actor,
    COUNT(*) AS appearances
FROM netflix
JOIN (
    SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
    UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 
    UNION ALL SELECT 13  UNION ALL SELECT 14  UNION ALL SELECT 15
) AS numbers
  ON numbers.n <= 1 + CHAR_LENGTH(casts) - CHAR_LENGTH(REPLACE(casts, ',', ''))
WHERE country LIKE '%India%' AND casts IS NOT NULL
GROUP BY actor
ORDER BY appearances DESC
LIMIT 10;

-- 15. Categorize content as 'Good' or 'Bad' based on description

SELECT 
    content_category AS category,
    show_type,
    COUNT(*) AS content_count
FROM (
    SELECT *,
           CASE 
               WHEN LOWER(show_description) LIKE '%kill%' 
               OR LOWER(show_description) LIKE '%violence%' THEN 'Bad'
               ELSE 'Good'
           END AS content_category
    FROM netflix
) AS labeled
GROUP BY content_category, show_type
ORDER BY show_type;

-- End of the Project
