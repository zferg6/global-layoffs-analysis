-- =====================================================
-- Exploratory Data Analysis: Global Layoffs (2020–2023)
-- Table: layoffs_staging2 (cleaned)
-- =====================================================

-- 1. Dataset Overview
SELECT COUNT(*) AS total_events FROM layoffs_staging2;
SELECT MIN(`date`) AS start_date, MAX(`date`) AS end_date FROM layoffs_staging2;

-- 2. Top 10 Companies by Total Layoffs
SELECT company, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY company
ORDER BY total_laid_off DESC
LIMIT 10;

-- 3. Top 10 Industries
SELECT industry, SUM(total_laid_off) AS total_laid_off, COUNT(*) AS events
FROM layoffs_staging2
WHERE industry IS NOT NULL
GROUP BY industry
ORDER BY total_laid_off DESC
LIMIT 10;

-- 4. Top 10 Countries
SELECT country, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY country
ORDER BY total_laid_off DESC
LIMIT 10;

-- 5. Layoffs Trend Over Time (Yearly)
SELECT YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY year
ORDER BY year;

-- 6. Monthly Trend (2022–2023 focus)
SELECT DATE_FORMAT(`date`, '%Y-%m') AS month, SUM(total_laid_off) AS monthly_layoffs
FROM layoffs_staging2
WHERE `date` >= '2022-01-01'
GROUP BY month
ORDER BY month;

-- 7. Layoffs by Funding Stage
SELECT stage, SUM(total_laid_off) AS total_laid_off, ROUND(AVG(percentage_laid_off), 3) AS avg_percentage
FROM layoffs_staging2
GROUP BY stage
ORDER BY total_laid_off DESC;