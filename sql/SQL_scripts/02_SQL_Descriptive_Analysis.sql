/*
02_Descriptive_Analysis.sql

Purpose:
Identify the main national-level bullying patterns before moving into
state, district, and Tableau-ready views.
*/


-- 1. Allegation category ranking
SELECT 'Sex' AS allegation_category, SUM(COALESCE(allegation_sex, 0)) AS total_allegations
FROM s_yoldaserdem.crdc_bullying_clean
UNION ALL
SELECT 'Race', SUM(COALESCE(allegation_race, 0))
FROM s_yoldaserdem.crdc_bullying_clean
UNION ALL
SELECT 'Sexual Orientation', SUM(COALESCE(allegation_orientation, 0))
FROM s_yoldaserdem.crdc_bullying_clean
UNION ALL
SELECT 'Disability', SUM(COALESCE(allegation_disability, 0))
FROM s_yoldaserdem.crdc_bullying_clean
UNION ALL
SELECT 'Religion', SUM(COALESCE(allegation_religion, 0))
FROM s_yoldaserdem.crdc_bullying_clean
ORDER BY total_allegations DESC;


-- 2. Schools with vs. without allegations
WITH school_totals AS (
    SELECT
        school_key,
        COALESCE(allegation_sex, 0)
        + COALESCE(allegation_race, 0)
        + COALESCE(allegation_orientation, 0)
        + COALESCE(allegation_disability, 0)
        + COALESCE(allegation_religion, 0) AS total_main_allegations
    FROM s_yoldaserdem.crdc_bullying_clean
)
SELECT
    CASE
        WHEN total_main_allegations > 0 THEN 'At least one allegation'
        ELSE 'Zero allegations'
    END AS allegation_status,
    COUNT(*) AS school_records,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS percentage
FROM school_totals
GROUP BY allegation_status
ORDER BY school_records DESC;


-- 3. National overview summary
WITH school_totals AS (
    SELECT
        school_key,
        COALESCE(allegation_sex, 0)
        + COALESCE(allegation_race, 0)
        + COALESCE(allegation_orientation, 0)
        + COALESCE(allegation_disability, 0)
        + COALESCE(allegation_religion, 0) AS total_main_allegations,
        COALESCE(total_reported_sex_male, 0)
        + COALESCE(total_reported_sex_female, 0)
        + COALESCE(total_reported_race_male, 0)
        + COALESCE(total_reported_race_female, 0)
        + COALESCE(total_reported_disability_male, 0)
        + COALESCE(total_reported_disability_female, 0) AS total_reported_students,
        COALESCE(total_disciplined_sex_male, 0)
        + COALESCE(total_disciplined_sex_female, 0)
        + COALESCE(total_disciplined_race_male, 0)
        + COALESCE(total_disciplined_race_female, 0)
        + COALESCE(total_disciplined_disability_male, 0)
        + COALESCE(total_disciplined_disability_female, 0) AS total_disciplined_students
    FROM s_yoldaserdem.crdc_bullying_clean
)
SELECT
    COUNT(*) AS school_records,
    SUM(CASE WHEN total_main_allegations > 0 THEN 1 ELSE 0 END) AS schools_with_allegations,
    ROUND(SUM(CASE WHEN total_main_allegations > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS schools_with_allegations_pct,
    SUM(total_main_allegations) AS total_main_allegations,
    SUM(total_reported_students) AS total_reported_students,
    SUM(total_disciplined_students) AS total_disciplined_students,
    ROUND(SUM(total_main_allegations) * 1.0 / COUNT(*), 2) AS allegations_per_school
FROM school_totals;