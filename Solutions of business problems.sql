-- Netflix Data Analysis Project
-- Solutions to 15 business problems

-- 1. Count the number of Movies vs TV Shows
SELECT 
    type,
    COUNT(*) AS total
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows
SELECT 
    type,
    rating AS most_frequent_rating
FROM (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix
    GROUP BY type, rating
) AS ranked
WHERE rnk = 1;

-- 3. List all movies released in a specific year (e.g., 2020)
SELECT * 
FROM netflix
WHERE release_year = 2020;

-- 4. Top 5 countries with the most content
SELECT 
    country_name AS country,
    COUNT(*) AS total_content
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(country, ',', n.n), ',', -1)) AS country_name
    FROM netflix
    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    ) n
    ON CHAR_LENGTH(country) - CHAR_LENGTH(REPLACE(country, ',', '')) >= n.n - 1
    WHERE country IS NOT NULL
) AS t
GROUP BY country_name
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie
SELECT *
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;

-- 6. Content added in the last 5 years
SELECT *
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d, %Y') >= CURDATE() - INTERVAL 5 YEAR;

-- 7. Movies/TV shows by director 'Rajiv Chilaka'
SELECT *
FROM (
    SELECT *,
           TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(director, ',', n.n), ',', -1)) AS director_name
    FROM netflix
    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    ) n
    ON CHAR_LENGTH(director) - CHAR_LENGTH(REPLACE(director, ',', '')) >= n.n - 1
    WHERE director IS NOT NULL
) AS d
WHERE director_name = 'Rajiv Chilaka';

-- 8. TV shows with more than 5 seasons
SELECT *
FROM netflix
WHERE 
    type = 'TV Show'
    AND CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) > 5;

-- 9. Number of content items in each genre
SELECT 
    genre,
    COUNT(*) AS total_content
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', n.n), ',', -1)) AS genre
    FROM netflix
    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    ) n
    ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= n.n - 1
) AS genres
GROUP BY genre;

-- 10. Top 5 years with highest avg content released by India
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

-- 11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in LIKE '%Documentaries%';

-- 12. Find all content without a director
SELECT * FROM netflix
WHERE director IS NULL OR director = '';

-- 13. How many movies actor 'Salman Khan' appeared in last 10 years
SELECT * FROM netflix
WHERE 
    casts LIKE '%Salman Khan%'
    AND release_year > YEAR(CURDATE()) - 10;

-- 14. Top 10 actors with most appearances in Indian content
SELECT 
    actor,
    COUNT(*) AS appearances
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(casts, ',', n.n), ',', -1)) AS actor
    FROM netflix
    JOIN (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
    ) n
    ON CHAR_LENGTH(casts) - CHAR_LENGTH(REPLACE(casts, ',', '')) >= n.n - 1
    WHERE country LIKE '%India%' AND casts IS NOT NULL
) AS actor_list
GROUP BY actor
ORDER BY appearances DESC
LIMIT 10;

-- 15. Categorize content as 'Good' or 'Bad' based on description
SELECT 
    category,
    type,
    COUNT(*) AS content_count
FROM (
    SELECT *,
           CASE 
               WHEN LOWER(description) LIKE '%kill%' OR LOWER(description) LIKE '%violence%' THEN 'Bad'
               ELSE 'Good'
           END AS category
    FROM netflix
) AS labeled
GROUP BY category, type
ORDER BY type;
