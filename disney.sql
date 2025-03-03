DROP TABLE IF EXISTS netflix;

CREATE TABLE disny
(
  show_id  VARCHAR(6),
  type  VARCHAR(10),
  title  VARCHAR(150),
  director  VARCHAR(208),
  casts   VARCHAR(1000),
  country  VARCHAR(150), 
  date_added  VARCHAR(50),
  release_year  INT,
  rating  VARCHAR(10),
  duration  VARCHAR(15),
  listed_in  VARCHAR(150), 
  description  VARCHAR(250)
);

SELECT * FROM disny;

SELECT COUNT(*) as total_content FROM disny;

SELECT DISTINCT type FROM disny;

--Count the number of movies & tv shows--

SELECT type,COUNT(*) as total_content FROM disny
GROUP BY type

--Find the most common rating from movies & tv shows--

SELECT
 type,
 rating
FROM 
(
   SELECT 
         type,
         rating,
         COUNT(*),
         RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) as ranking
   FROM disny
   GROUP BY 1,2 
) as t1
WHERE 
    ranking =1

--List all movie released in 2018--

SELECT * FROM disny
WHERE type = 'Movie'
AND
release_year = 2018

--Finding top 5 countries with the most content--

SELECT
   UNNEST (STRING_TO_ARRAY(country,',')) as new_country,
  COUNT (show_id) as total_content
FROM disny
GROUP BY 1  
ORDER BY 2 DESC
LIMIT 5

--Identify the longest movie--

SELECT * FROM disny
WHERE
   type = 'Movie'
   AND
   duration = (SELECT MAX(duration)FROM disny) 

--Find content added in the last 5 years--

SELECT 
       *
FROM disny
WHERE
    TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'

--Find all the movies/TV shows by directed by 'Robert Vince'--

SELECT * FROM disny
WHERE director ILIKE '%Robert Vince%'

--Select all TV shows with more than TEN seasosns--

SELECT 
      *
FROM disny
WHERE
    type = 'TV Show'
	AND
    SPLIT_PART(duration, ' ', 1)::numeric > 10

--Count the number of content items in each genre--

SELECT 
  UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre,
  COUNT(show_id) as total_content
FROM disny
GROUP BY 1
ORDER BY 2 DESC

--Total avarage content per year by 'United States'--
SELECT 
      EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	  COUNT(*) as yearly_content,
	  ROUND(
	  COUNT(*)::numeric/(SELECT COUNT(*) FROM disny WHERE country = 'United States')::numeric * 100
	  ,2)as avg_content_per_year
FROM disny
WHERE country = 'United States'
GROUP BY 1

--List all ADVENTURE genre--

SELECT * FROM disny
WHERE 
    listed_in ILIKE '%Adventure%'

--Find all content without a director--

SELECT * FROM disny
WHERE
    director IS NULL

--Find all 'Chris Hemsworth' movie in last 10 year--
SELECT * FROM disny
WHERE 
      casts ILIKE '%Chris Hemsworth%'
      AND 
      release_year > EXTRACT(YEAR FROM CURRENT_DATE)-10

--Finding top 10 actors casts in highest number of movies--

SELECT 
--show_id,
--casts,
UNNEST(STRING_TO_ARRAY(casts,',')) as actors,
COUNT(*) as total_content
FROM disny
WHERE country ILIKE '%United States'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10

--Categorize the content based on the keywords "Superhero" and "City" in the description field.
Label content this keyword as "Specal_Content" and all other content as "Human".
Count how many fall into each catagory.--

WITH new_table
AS
(
SELECT 
*,
  CASE 
  WHEN
      description ILIKE '%Superhero%' OR
      description ILIKE '%City%' THEN 'Specal_Content'
	  ELSE 'Normal_Content'
  END catagory  
  FROM disny
)
SELECT 
      catagory,
	  COUNT(*) as total_content
FROM new_table
GROUP BY 1
