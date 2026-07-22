/*
====================================================
SQL SCRIPT 05
Advanced Insights & Actionable Findings

School Bullying Analysis
CRDC 2021-2022

Author: Yoldas Erdem
====================================================

Purpose:
Identify patterns, bottlenecks, high-risk areas,
and opportunities for intervention that will
support the Tableau dashboards and final report.
====================================================
*/


----------------------------------------------------
1. States with the highest bullying allegations
per school
----------------------------------------------------

SELECT
    state,
    COUNT(*) AS schools,
    SUM(total_main_allegations) AS total_allegations,
    ROUND(
        SUM(total_main_allegations)::numeric / COUNT(*),
        2
    ) AS allegations_per_school
FROM bullying_summary
GROUP BY state
ORDER BY allegations_per_school DESC;



----------------------------------------------------
2. States with the lowest disciplinary response
----------------------------------------------------

SELECT
    state,
    SUM(total_main_allegations) AS allegations,
    SUM(total_disciplined_students) AS disciplined_students,
    ROUND(
        SUM(total_disciplined_students)::numeric
        /
        NULLIF(SUM(total_main_allegations),0),
        2
    ) AS discipline_ratio
FROM bullying_summary
GROUP BY state
HAVING SUM(total_main_allegations) > 100
ORDER BY discipline_ratio ASC;



----------------------------------------------------
3. Highest reporting schools
----------------------------------------------------

SELECT
    state,
    district,
    school,
    total_main_allegations,
    total_disciplined_students
FROM bullying_summary
ORDER BY total_main_allegations DESC
LIMIT 25;



----------------------------------------------------
4. Schools with the biggest discipline gap
----------------------------------------------------

SELECT
    state,
    district,
    school,
    total_main_allegations,
    total_disciplined_students,
    total_main_allegations
        -
    total_disciplined_students
        AS discipline_gap
FROM bullying_summary
ORDER BY discipline_gap DESC
LIMIT 25;



----------------------------------------------------
5. Schools reporting zero allegations
----------------------------------------------------

SELECT
COUNT(*) AS total_schools,
SUM(
CASE
WHEN total_main_allegations = 0
THEN 1
ELSE 0
END
) AS zero_reporting_schools,
ROUND(
SUM(
CASE
WHEN total_main_allegations = 0
THEN 1
ELSE 0
END
)::numeric
/
COUNT(*)
*100,
2
) AS percent_zero_reporting
FROM bullying_summary;



----------------------------------------------------
6. Top allegation category by state
----------------------------------------------------

SELECT
state,
SUM(allegation_sex) AS sex,
SUM(allegation_race) AS race,
SUM(allegation_orientation) AS orientation,
SUM(allegation_disability) AS disability,
SUM(allegation_religion) AS religion
FROM crdc_bullying_clean
GROUP BY state
ORDER BY state;



----------------------------------------------------
7. Priority Matrix
High allegations + Low discipline
----------------------------------------------------

SELECT
state,
COUNT(*) AS schools,
SUM(total_main_allegations) AS allegations,
SUM(total_disciplined_students) AS disciplined,
ROUND(
SUM(total_main_allegations)::numeric
/
COUNT(*),
2
) AS allegations_per_school,
ROUND(
SUM(total_disciplined_students)::numeric
/
NULLIF(
SUM(total_main_allegations),
0
),
2
) AS discipline_ratio
FROM bullying_summary
GROUP BY state
ORDER BY
allegations_per_school DESC,
discipline_ratio ASC;



----------------------------------------------------
8. Districts with the highest allegations
per school
----------------------------------------------------

SELECT
state,
district,
COUNT(*) AS schools,
SUM(total_main_allegations) AS allegations,
ROUND(
SUM(total_main_allegations)::numeric
/
COUNT(*),
2
) AS allegations_per_school
FROM bullying_summary
GROUP BY state,district
HAVING COUNT(*) >= 5
ORDER BY allegations_per_school DESC
LIMIT 25;



----------------------------------------------------
9. Which allegation category dominates?
----------------------------------------------------

SELECT
'Sex' AS category,
SUM(allegation_sex) AS total
FROM crdc_bullying_clean
UNION ALL
SELECT
'Race',
SUM(allegation_race)
FROM crdc_bullying_clean
UNION ALL
SELECT
'Orientation',
SUM(allegation_orientation)
FROM crdc_bullying_clean
UNION ALL
SELECT
'Disability',
SUM(allegation_disability)
FROM crdc_bullying_clean
UNION ALL
SELECT
'Religion',
SUM(allegation_religion)
FROM crdc_bullying_clean
ORDER BY total DESC;



----------------------------------------------------
10. Male vs Female students reported
----------------------------------------------------

SELECT
    SUM(total_reported_sex_male) AS males_reported,
    SUM(total_reported_sex_female) AS females_reported,
    SUM(total_disciplined_sex_male) AS males_disciplined,
    SUM(total_disciplined_sex_female) AS females_disciplined
FROM s_yoldaserdem.crdc_bullying_clean;



----------------------------------------------------
11. Top 20 schools requiring intervention
Ranking Score
----------------------------------------------------

SELECT
state,
district,
school,
total_main_allegations,
total_disciplined_students,
ROUND(
(
total_main_allegations
-
total_disciplined_students
)::numeric,
0
) AS intervention_score
FROM bullying_summary
ORDER BY
intervention_score DESC,
total_main_allegations DESC
LIMIT 20;



----------------------------------------------------
12. Overall Executive Summary
----------------------------------------------------

SELECT
COUNT(*) AS schools,
SUM(total_main_allegations) AS allegations,
SUM(total_reported_students) AS students_reported,
SUM(total_disciplined_students) AS students_disciplined,
ROUND(
AVG(total_main_allegations),
2
) AS average_allegations_per_school,
MAX(total_main_allegations) AS highest_school_total
FROM bullying_summary;

----------------------------------------------------
-- 13. Top 10 states by average allegations per reporting school
-- Excludes schools with zero allegations
----------------------------------------------------

WITH school_totals AS (
    SELECT
        state,
        school_key,
        COALESCE(allegation_sex, 0)
        + COALESCE(allegation_race, 0)
        + COALESCE(allegation_orientation, 0)
        + COALESCE(allegation_disability, 0)
        + COALESCE(allegation_religion, 0) AS total_main_allegations
    FROM s_yoldaserdem.crdc_bullying_clean
)
SELECT
    state,
    COUNT(*) AS reporting_schools,
    SUM(total_main_allegations) AS total_allegations,
    ROUND(SUM(total_main_allegations)::numeric / COUNT(*), 2) AS avg_allegations_per_reporting_school
FROM school_totals
WHERE total_main_allegations > 0
GROUP BY state
HAVING COUNT(*) >= 10
ORDER BY avg_allegations_per_reporting_school DESC
LIMIT 10;