-- =============================================
-- Layoffs Data Cleaning Script
-- Steps:
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Handle Null/Blank Values
-- 4. Remove Unnecessary Columns
-- =============================================

-- Initial view of raw data
SELECT *
FROM layoffs;

-- 1. REMOVE DUPLICATES
-- Create a staging table to work safely
CREATE TABLE layoffs_staging LIKE layoffs;

SELECT *
FROM layoffs_staging;

-- Copy all data into staging table
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- Quick check for potential duplicates (initial simpler partition)
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`
       ) AS row_num
FROM layoffs_staging;

-- Better duplicate identification using all relevant columns
WITH duplicate_CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off,
                            percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_CTE
WHERE row_num > 1;

-- Example check for a specific company
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

-- Create a new staging table with row_num column for safe deletion
CREATE TABLE `layoffs_staging2` (
    `company` text,
    `location` text,
    `industry` text,
    `total_laid_off` bigint DEFAULT NULL,
    `percentage_laid_off` text,
    `date` text,
    `stage` text,
    `country` text,
    `funds_raised_millions` int DEFAULT NULL,
    `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Populate with row numbers
INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off,
                        percentage_laid_off, `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM layoffs_staging;

-- Verify duplicates
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Remove duplicates (keep row_num = 1)
DELETE FROM layoffs_staging2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging2;


-- 2. STANDARDIZING DATA
-- Trim whitespace from company names
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize industry values (e.g., Crypto, Crypto Currency → Crypto)
SELECT DISTINCT industry
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Fix trailing period in country (United States.)
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert date from text (m/d/yyyy) to proper DATE type
SELECT `date`
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT *
FROM layoffs_staging2;


-- 3. NULL AND BLANK VALUES
-- Rows with no layoff data
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Find blank or null industries
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';

-- Example: Check specific company
SELECT *
FROM layoffs_staging2
WHERE company LIKE 'Bally%';

-- Populate missing industries using other rows from same company
SELECT t1.industry, t2.industry
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE (t1.industry IS NULL OR t1.industry = '')
  AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_staging2;


-- 4. REMOVE UNNECESSARY COLUMNS AND ROWS
-- Remove rows where both layoff metrics are missing
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

-- Drop the helper column used for deduplication
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;






