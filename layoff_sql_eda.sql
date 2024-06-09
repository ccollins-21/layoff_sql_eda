-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;


SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2; 
-- Max total laid off in a single day was 12,000 people.
-- Max percentage was 1 or (100% of the company) 


SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY  company
ORDER BY 2 DESC;
-- I notice Google's sum of layoffs = 12000, so I'm assuming that Google was the company for the MAX query I ran earlier


SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
-- The Date range for this data is 2020-03-11 to 2023-03-06 (Almost three years)
-- March of 2020 was right about when the COVID pandemic hit the United States


SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY  industry
ORDER BY 2 DESC;
-- Top three industries affected by layoffs were Consumer, Retail, and Other


SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY  country
ORDER BY 2 DESC;
-- The United States had by far the most layoffs during this three year span. Over 250,000!


SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY  YEAR(`date`)
ORDER BY 1 DESC;

-- Creating a rolling total of layoffs by month
SELECT  SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_Total AS	-- creating a CTE (Common Table Expression) which is a named temporary results dataset that can be referenced later within the query
(
SELECT  SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Rolling_Total;   -- CTE we created

-- Ranking the years based on the total number of layoffs by each company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY  company
ORDER BY 2 DESC;

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY  company, YEAR(`date`)
ORDER BY 3 DESC;


WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY  company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;	-- Shows Top 5 companies with the most layoffs each year



WITH Company_Year (company, years, avg_percentage_laid_off) AS
(
SELECT company, YEAR(`date`), AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY  company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY avg_percentage_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;	-- Shows Top 5 companies with the highest avg % of layoffs each year. (1 = 100%)


-- I want to see the years compare with companies who had a 100% layoff.
SELECT YEAR(`date`), COUNT(percentage_laid_off) AS total_layoff
FROM layoffs_staging2
WHERE percentage_laid_off = 1
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;
-- 2022 had the most companies who has a 100% total lay off with 58 companies. 
-- 2021 had the least with only 8
