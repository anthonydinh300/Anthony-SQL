-- Data cleaning 

-- skills:
-- 1 remove duplicates
-- 2 standarize the data
-- 3  null values
-- 4 remove any columns 


-- Step 1: remove duplicates
-- first step is to create a copy of the raw data to ensure orginal copy is not altered
SELECT *
FROM layoffs;
CREATE TABLE layoffs_staging
LIKE layoffs;
SELECT *
FROM layoffs_staging;
INSERT layoffs_staging
SELECT *
FROM layoffs;


-- Check for Duplicates
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, 'date') as row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date` , stage
, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)	
SELECT *
FROM duplicate_cte
WHERE row_num > 1;




-- Create another new table with the CTE data as new data. Using row_num as new column.
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;


-- Insert into another table
INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date` , stage
, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;
DELETE
FROM layoffs_staging2
WHERE row_num > 1;
select *
from layoffs_staging2
where row_num > 1;

-- 2: standardizing data

SELECT company, trim(company)
FROM LAYOFFS_STAGING2;

UPDATE LAYOFFS_STAGING2
SET COMPANY= TRIM(COMPANY);

SELECT distinct industry
FROM LAYOFFS_STAGING2
;

UPDATE LAYOFFS_STAGING2
SET industry = 'crypto'
WHERE industry LIKE 'crypto%';

SELECT DISTINCT country, trim(TRAILING 	'.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

-- Updates table to get of any trailing period from United states
UPDATE layoffs_staging2
SET country= trim(TRAILING 	'.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`
FROM LAYOFFS_STAGING2;
UPDATE LAYOFFS_STAGING2
SET DATE = str_to_date(`date`, '%m/%d/%Y' 	);

-- Altering the table to change data type from text type into a date data type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` Date;

-- 3. Analyzing Null or blank values.
SELECT *
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company= t2.company
    AND t1.location= t2.location
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

-- Takes industry value from the company's other entities to make t1's industry match up with t2's industry.
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Deletes eneties with no laid off data
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

-- Romeves extra column, no longer in use
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Table is cleaned












