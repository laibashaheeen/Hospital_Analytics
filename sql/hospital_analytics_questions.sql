-- Connect to database
USE hospital_db;

-- OBJECTIVE 1: ENCOUNTERS OVERVIEW

-- a. How many total encounters occurred each year?
SELECT * FROM encounters;

SELECT COUNT(ID) AS total_encounters, year(START) AS year 
FROM encounters
GROUP BY year
ORDER BY year;

-- b. For each year, what percentage of all encounters belonged to each encounter class
-- (ambulatory, outpatient, wellness, urgentcare, emergency, and inpatient)?
SELECT * FROM encounters;

SELECT year(START) AS year, 
ROUND(SUM(CASE WHEN ENCOUNTERCLASS = 'ambulatory' THEN 1 ELSE 0 END) /COUNT(*) * 100, 1) AS ambulatory,
ROUND(SUM(CASE WHEN ENCOUNTERCLASS = 'ambulatory' THEN 1 ELSE 0 END) /COUNT(*) * 100, 1)  AS outpatient,
ROUND(SUM(CASE WHEN ENCOUNTERCLASS = 'ambulatory' THEN 1 ELSE 0 END) /COUNT(*) * 100, 1)  AS wellness,
ROUND(SUM(CASE WHEN ENCOUNTERCLASS = 'ambulatory' THEN 1 ELSE 0 END) /COUNT(*) * 100, 1)  AS urgentcare,
ROUND(SUM(CASE WHEN ENCOUNTERCLASS = 'ambulatory' THEN 1 ELSE 0 END) /COUNT(*) * 100, 1)  AS emergency,
ROUND(SUM(CASE WHEN ENCOUNTERCLASS = 'ambulatory' THEN 1 ELSE 0 END) /COUNT(*) * 100, 1)  AS inpatient
FROM encounters
GROUP BY year;

-- c. What percentage of encounters were over 24 hours versus under 24 hours?
SELECT * FROM encounters;

SELECT 
ROUND(SUM(CASE WHEN TIMESTAMPDIFF(HOUR, START, STOP) < 24 THEN 1 ELSE 0 END) /COUNT(*) * 100, 1) AS under_24_hour,
ROUND(SUM(CASE WHEN TIMESTAMPDIFF(HOUR, START, STOP) >= 24 THEN 1 ELSE 0 END) /COUNT(*) * 100, 1) AS over_24_hour
FROM encounters;

-- OBJECTIVE 2: COST & COVERAGE INSIGHTS

-- a. How many encounters had zero payer coverage, and what percentage of total encounters does this represent?
SELECT * FROM encounters;

SELECT SUM(CASE WHEN PAYER_COVERAGE = "0" THEN 1 ELSE 0 END) AS zero_payer_coverage,
	COUNT(PAYER_COVERAGE) AS total_encounters,
    ROUND(SUM(CASE WHEN PAYER_COVERAGE = "0" THEN 1 ELSE 0 END) / COUNT(PAYER_COVERAGE) * 100, 1) AS pct_zero_payer_coverage
FROM encounters;

-- b. What are the top 10 most frequent procedures performed and the average base cost for each?
SELECT * FROM procedures;

SELECT CODE, DESCRIPTION, count(*) AS NUM_PROCEDURES, AVG(BASE_COST) AS AVG_BASE_COST
FROM procedures
GROUP BY CODE, DESCRIPTION
ORDER BY NUM_PROCEDURES desc
LIMIT 10;

-- c. What are the top 10 procedures with the highest average base cost and the number of times they were performed?
SELECT * FROM procedures;

SELECT CODE, DESCRIPTION, AVG(BASE_COST) AS AVG_BASE_COST, count(*) AS NUM_PROCEDURES
FROM procedures
GROUP BY CODE, DESCRIPTION
ORDER BY AVG_BASE_COST DESC
LIMIT 10;

-- d. What is the average total claim cost for encounters, broken down by payer?
SELECT * FROM encounters;

SELECT p.NAME, AVG(e.TOTAL_CLAIM_COST) AS AVG_TOTAL_CLAIM_COST
FROM payers p LEFT JOIN encounters e ON p.id = e.PAYER
GROUP BY P.NAME
ORDER BY AVG_TOTAL_CLAIM_COST DESC;

-- OBJECTIVE 3: PATIENT BEHAVIOR ANALYSIS

-- a. How many unique patients were admitted each quarter over time?
SELECT * FROM encounters;

SELECT YEAR(START) AS year, QUARTER(START) AS quarter, COUNT(DISTINCT PATIENT) AS unique_patients
FROM encounters
GROUP BY year, quarter
ORDER BY year asc;

-- b. How many patients were readmitted within 30 days of a previous encounter?
-- SELECT PATIENT, START, STOP,
--     LEAD(START) OVER(PARTITION BY PATIENT ORDER BY START) AS NEXT_START
-- FROM encounters
-- ORDER BY PATIENT;
WITH cte AS (SELECT PATIENT, START, STOP,
                LEAD(START) OVER(PARTITION BY PATIENT ORDER BY START) AS NEXT_START
		    FROM encounters)
SELECT COUNT(DISTINCT PATIENT) AS PATIENT 
FROM cte
WHERE DATEDIFF(NEXT_START, STOP) < 30;

-- c. Which patients had the most readmissions?
WITH cte AS (SELECT PATIENT, START, STOP,
                LEAD(START) OVER(PARTITION BY PATIENT ORDER BY START) AS NEXT_START
		    FROM encounters)
SELECT PATIENT, COUNT(PATIENT) AS num_readmissions 
FROM cte
WHERE DATEDIFF(NEXT_START, STOP) < 30
group by PATIENT
ORDER BY num_readmissions DESC;