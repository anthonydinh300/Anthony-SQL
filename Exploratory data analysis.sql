-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

--Exploring the data
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Searching for companies with the highest percentage laid off (with 100% being the company went under)
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;
-- finding which countries and industries had the most layoffs
SELECT country, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

Select *
FROM layoffs_staging2;

--figuring out which year had the most layoffs from 2020-2023
SELECT YEAR(`date`), sum(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;
-- finding which stage had the most layoffs
SELECT STAGE, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY STAGE
ORDER BY 2 DESC;

SELECT company, sum(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Rolling Total of Layoffs Per Month
SELECT *
FROM layoffs_staging2;

SELECT substring(`date`,1,7) as `MONTH`, sum(total_laid_off)
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
;

-- Rolling Total of Layoffs Per Month
WITH ROLLING_TOTAL AS
(
SELECT substring(`date`,1,7) as `MONTH`, sum(total_laid_off) as total_off	
FROM layoffs_staging2
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
 SUM(total_off) OVER(ORDER BY `MONTH`) AS ROLLING_TOTAL
FROM ROLLING_TOTAL;


SELECT company, sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT company, year(`date`), sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company, year(`date`)
ORDER BY 3 desc;

---- Building a CTE to see which company had the most layoffs each year.
WITH COMPANY_YEAR (COMPANY, YEARS, TOTAL_LAID_OFFS) AS
(
SELECT company, year(`date`), sum(total_laid_off)
FROM layoffs_staging2
GROUP BY company, year(`date`)
), COMPANY_YEAR_RANK AS
(SELECT *, dense_rank() OVER(PARTITION BY YEARS ORDER BY total_laid_offs desc) AS RANKING
FROM COMPANY_YEAR
where years is not null
)
SELECT *
FROM COMPANY_YEAR_RANK
WHERE RANKING <=5;
