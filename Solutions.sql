-- netflix project

drop table if exists netflix;

CREATE TABLE netflix
(
show_id	VARCHAR(6),
type VARCHAR(10),	
title VARCHAR(150),
director VARCHAR(350),
casts VARCHAR(1000),
country	VARCHAR(150),
date_added VARCHAR(50),
release_year INT,
rating	VARCHAR(10),
duration VARCHAR(15),
listed_in VARCHAR(100),
description VARCHAR(250)
);


SELECT * FROM netflix

SELECT count(*) as total_data 
FROM netflix;

SELECT DISTINCT(type) as distinct_type
from netflix;

-- count of dircetor which has done tvshow
SELECT director,type,COUNT(*) AS d
FROM netflix
WHERE type = 'TV Show'
GROUP BY director
ORDER BY d DESC;

-- count of dircetor which has done Movies
SELECT director,type,COUNT(*) AS d
FROM netflix
WHERE type = 'Movie'
GROUP BY director
ORDER BY d DESC;

-- 15 Business Problems & Solutions

-- 1. Count the number of Movies vs TV Shows

SELECT type , count(*) as total_count
from netflix
group by type;


--2. Find the most common rating for movies and TV shows

select type,rating
FROM(
SELECT type , rating ,count(*),
RANK() OVER(PARTITION BY type ORDER BY COUNT(*) desc) as ranking
from netflix
group by 1,2) as t1
where ranking = 1


--3. List all movies released in a specific year (e.g., 2020)

SELECT type,release_year,title , director
from netflix
where type = 'Movie' and release_year = 2020;


--4. Find the top 5 countries with the most content on Netflix

SELECT TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS new_country,
COUNT(*) AS total_content
FROM netflix
GROUP BY 1
ORDER BY total_content DESC
LIMIT 5;


-- 5. Identify the longest movie

SELECT type, title, duration,
       CAST(TRIM(REPLACE(duration, 'min', '')) AS INT) AS duration_min
FROM netflix
WHERE type = 'Movie' and duration is not null
ORDER BY duration_min DESC
LIMIT 1;


--6. Find content added in the last 5 years

SELECT *
FROM NETFLIX
where TO_DATE(date_added,'MONTH DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'


--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT type ,title,director from netflix
where director ILIKE '%Rajiv Chilaka%'


--8. List all TV shows with more than 5 seasons

SELECT type,title, CAST(SUBSTRING(duration FROM '\d+') as INT) as show_seasons
from netflix
where type = 'TV Show' 
AND
CAST(SUBSTRING(duration FROM '\d+') as INT) > 5

-- another way
SELECT * 
from netflix 
where type = 'TV Show' and SPLIT_PART(duration,' ',1)::numeric > 5

--, SPLIT_PART(duration,' ',1) -- (column_name,delimiter,WHICH value)

--9. Count the number of content items in each genre

SELECT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) AS new_listed,
COUNT(*) AS total_content
FROM netflix
GROUP BY 1
ORDER BY total_content DESC;


/*10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!*/

SELECT EXTRACT(YEAR FROM TO_DATE(date_added , 'Month DD, YYYY')) as date,COUNT(*),
ROUND((COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country = 'India')::numeric * 100),2) as avg_content_per_year
from netflix
WHERE country = 'India'
GROUP BY 1 



--11. List all movies that are documentaries
SELECT * FROM netflix
WHERE listed_in ILIKE '%documentaries%'

--12. Find all content without a director

SELECT * FROM NETFLIX
WHERE director is NULl 


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT * from netflix
WHERE casts ILIKE '%salman Khan%' 
AND
release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10


--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) actors , COUNT(*)
FROM netflix
WHERE type = 'Movie' and country ILIKE '%india%'
GROUP BY 1
ORDER BY 2 desc
limit 10;


/*15.
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.*/

WITH new_table
AS(
SELECT * , 
	CASE
	WHEN 
		description ILIKE '%kill%' OR
		description ILIKE '%violence%' THEN 'Bad Content'
		ELSE 'Good Content'
	END category
FROM netflix
)

SELECT 	
	category,
	COUNT(*) AS total_content
FROM new_table
GROUP BY 1


/* 16.
Identify and classify Netflix content based on specific keywords ('kill', 'violence', 'bad', 'good') found in the 
description. Count how many times each keyword category appears for each content type.*/

SELECT type,
CASE
    WHEN description ILIKE '%kill%' THEN 'Kill'
    WHEN description ILIKE '%violence%'  THEN 'Violence'
    WHEN description ILIKE '%Bad%' THEN 'Bad'
	 WHEN description ILIKE '%good%' THEN 'Good'
    ELSE 'No key word'
END AS grade , COUNT(*) as appearance_of_word
from NETFLIX
WHERE description ILIKE '%kill%' 
or 
description ILIKE '%violence%' 
or 
description ILIKE '%Bad%' 
or 
description ILIKE '%good%'
GROUP BY type,grade
ORDER BY 


-- 17.Find the top 3 longest movies in each country.

WITH cte AS (
    SELECT 
        TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) AS country,
        title,
        SPLIT_PART(duration, ' ', 1)::INT AS duration
    FROM netflix
    WHERE type = 'Movie'
)

SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY country ORDER BY duration DESC) AS rn
    FROM cte
) ranked
WHERE rn <= 3;


-- 18. Find the country that has the highest percentage of movies produced

SELECT TRIM(UNNEST(STRING_TO_ARRAY(country,','))) as seprated_country,
ROUND((COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE type = 'Movie')::numeric * 100),2)
FROM netflix
where type = 'Movie'
GROUP BY 1
order by 2 desc

-- 19 Find the top 7 oldest content (based on release_year) available on Netflix.

SELECT type,title,release_year
from netflix
order by 3
LIMIT 7;


-- 20. Find all the movies whose duration is greater than the longest TV Show season count available in the dataset.

SELECT title, duration
FROM netflix
WHERE type = 'Movie'
AND SPLIT_PART(duration, ' ', 1)::INT > 
(
    SELECT MAX(SPLIT_PART(duration, ' ', 1)::INT)
    FROM netflix
    WHERE type = 'TV Show'
)
