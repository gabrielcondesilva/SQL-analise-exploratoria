-- EDA (Análise Exploratória de Dados)

-- Visualizar todos os dados da tabela.
SELECT * FROM layoffs_copia2;

-- Verificar o intervalo de tempo da análise.
SELECT 
    MIN(`date`) AS start_date,
    MAX(`date`) AS end_date
FROM layoffs_copia2;

-- Empresas que demitiram 100% dos funcionários em um dia, ordenadas pela quantidade total de demitidos.
SELECT *
FROM layoffs_copia2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Empresas que demitiram 100% dos funcionários, ordenadas pelos fundos levantados (em milhões).
SELECT *
FROM layoffs_copia2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Empresas que mais demitiram funcionários.
SELECT 
    company, 
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_copia2
GROUP BY company
ORDER BY total_laid_off DESC;

-- Indústrias que mais demitiram funcionários.
SELECT 
    industry, 
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_copia2
GROUP BY industry
ORDER BY total_laid_off DESC;

-- Países que mais demitiram funcionários.
SELECT 
    country, 
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_copia2
GROUP BY country
ORDER BY total_laid_off DESC;

-- Anos com mais demissões.
SELECT 
    YEAR(`date`) AS year, 
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_copia2
GROUP BY YEAR(`date`)
ORDER BY total_laid_off DESC;

-- Níveis de hierarquia (stages) que mais demitiram funcionários.
-- Níveis variam de grandes empresas (Post-IPO) a pequenas (Seed).
SELECT 
    stage, 
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_copia2
GROUP BY stage
ORDER BY total_laid_off DESC;

-- Total de demissões por mês e ano.
SELECT 
    DATE_FORMAT(`date`, '%Y-%m') AS month,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_copia2
GROUP BY month
ORDER BY month ASC;

-- Progresso de demissões acumuladas ao longo do tempo.
WITH monthly_layoffs AS (
    SELECT 
        DATE_FORMAT(`date`, '%Y-%m') AS month,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_copia2
    GROUP BY month
    ORDER BY month ASC
)
SELECT
    month,
    total_laid_off,
    SUM(total_laid_off) OVER(ORDER BY month) AS cumulative_layoffs
FROM monthly_layoffs;

-- Demissões de cada empresa por ano.
SELECT 
    company, 
    YEAR(`date`) AS year,
    SUM(total_laid_off) AS total_laid_off
FROM layoffs_copia2
GROUP BY company, year
ORDER BY total_laid_off DESC;

-- Ranking de empresas com mais demissões por ano.
WITH company_year AS 
(
    SELECT
        company, 
        YEAR(`date`) AS year,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_copia2
    GROUP BY company, year
), ranked_companies AS 
(
    SELECT *,
        DENSE_RANK() OVER(PARTITION BY year ORDER BY total_laid_off DESC) AS ranking
    FROM company_year
)
SELECT *
FROM ranked_companies
WHERE year IS NOT NULL
ORDER BY ranking ASC;

-- Top 5 empresas com mais demissões por ano.
WITH company_year AS 
(
    SELECT
        company, 
        YEAR(`date`) AS year,
        SUM(total_laid_off) AS total_laid_off
    FROM layoffs_copia2
    GROUP BY company, year
), ranked_companies AS 
(
    SELECT *,
        DENSE_RANK() OVER(PARTITION BY year ORDER BY total_laid_off DESC) AS ranking
    FROM company_year
)
SELECT *
FROM ranked_companies
WHERE ranking <= 5;
