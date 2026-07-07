/*
04_Demographic_Disciplinary_Analysis.sql

Purpose:
Compare reported student groups and disciplined student groups.
This supports action items around affected groups and response patterns.
*/


-- 1. Reported students by broad group
SELECT 'Sex - Female' AS student_group, SUM(COALESCE(total_reported_sex_female, 0)) AS total_reported_students
FROM s_yoldaserdem.crdc_bullying_clean
UNION ALL
SELECT 'Sex - Male', SUM(COALESCE(total_reported_sex_male, 0))
FROM s_yoldaserdem.crdc_bullying_clean
UNION ALL
SELECT 'Race - Female', SUM(COALESCE(total_reported_race_female, 0))
FROM s_yoldaserdem.crdc_bullying_clean
UNION ALL
SELECT 'Race - Male', SUM(COALESCE(total_reported_race_male, 0))
FROM s_yoldaserdem.crdc_bullying_clean
UNION ALL
SELECT 'Disability - Female', SUM(COALESCE(total_reported_disability_female, 0))
FROM s_yoldaserdem.crdc_bullying_clean
UNION ALL
SELECT 'Disability - Male', SUM(COALESCE(total_reported_disability_male, 0))
FROM s_yoldaserdem.crdc_bullying_clean
ORDER BY total_reported_students DESC;


-- 2. Disciplined students by broad group
SELECT 'Sex - Female' AS student_group, SUM(COALESCE(total_disciplined_sex_female, 0)) AS total_disciplined_students
FROM s_yoldaserdem.crdc_bullying_clean
UNION ALL
SELECT 'Sex - Male', SUM(COALESCE(total_disciplined_sex_male, 0))
FROM s_yoldaserdem.crdc_bullying_clean
UNION ALL
SELECT 'Race - Female', SUM(COALESCE(total_disciplined_race_female, 0))
FROM s_yoldaserdem.crdc_bullying_clean
UNION ALL
SELECT 'Race - Male', SUM(COALESCE(total_disciplined_race_male, 0))
FROM s_yoldaserdem.crdc_bullying_clean
UNION ALL
SELECT 'Disability - Female', SUM(COALESCE(total_disciplined_disability_female, 0))
FROM s_yoldaserdem.crdc_bullying_clean
UNION ALL
SELECT 'Disability - Male', SUM(COALESCE(total_disciplined_disability_male, 0))
FROM s_yoldaserdem.crdc_bullying_clean
ORDER BY total_disciplined_students DESC;


-- 3. Reported vs disciplined comparison
WITH reported AS (
    SELECT 'Sex - Female' AS student_group, SUM(COALESCE(total_reported_sex_female, 0)) AS reported_students FROM s_yoldaserdem.crdc_bullying_clean
    UNION ALL SELECT 'Sex - Male', SUM(COALESCE(total_reported_sex_male, 0)) FROM s_yoldaserdem.crdc_bullying_clean
    UNION ALL SELECT 'Race - Female', SUM(COALESCE(total_reported_race_female, 0)) FROM s_yoldaserdem.crdc_bullying_clean
    UNION ALL SELECT 'Race - Male', SUM(COALESCE(total_reported_race_male, 0)) FROM s_yoldaserdem.crdc_bullying_clean
    UNION ALL SELECT 'Disability - Female', SUM(COALESCE(total_reported_disability_female, 0)) FROM s_yoldaserdem.crdc_bullying_clean
    UNION ALL SELECT 'Disability - Male', SUM(COALESCE(total_reported_disability_male, 0)) FROM s_yoldaserdem.crdc_bullying_clean
),
disciplined AS (
    SELECT 'Sex - Female' AS student_group, SUM(COALESCE(total_disciplined_sex_female, 0)) AS disciplined_students FROM s_yoldaserdem.crdc_bullying_clean
    UNION ALL SELECT 'Sex - Male', SUM(COALESCE(total_disciplined_sex_male, 0)) FROM s_yoldaserdem.crdc_bullying_clean
    UNION ALL SELECT 'Race - Female', SUM(COALESCE(total_disciplined_race_female, 0)) FROM s_yoldaserdem.crdc_bullying_clean
    UNION ALL SELECT 'Race - Male', SUM(COALESCE(total_disciplined_race_male, 0)) FROM s_yoldaserdem.crdc_bullying_clean
    UNION ALL SELECT 'Disability - Female', SUM(COALESCE(total_disciplined_disability_female, 0)) FROM s_yoldaserdem.crdc_bullying_clean
    UNION ALL SELECT 'Disability - Male', SUM(COALESCE(total_disciplined_disability_male, 0)) FROM s_yoldaserdem.crdc_bullying_clean
)
SELECT
    r.student_group,
    r.reported_students,
    d.disciplined_students,
    d.disciplined_students - r.reported_students AS difference_disciplined_minus_reported,
    ROUND(d.disciplined_students * 1.0 / NULLIF(r.reported_students, 0), 2) AS disciplined_to_reported_ratio
FROM reported r
JOIN disciplined d
    ON r.student_group = d.student_group
ORDER BY disciplined_to_reported_ratio DESC;


-- 4. State-level discipline-to-allegation ratio
-- Filtered to states with at least 100 main allegations

WITH state_summary AS (
    SELECT
        state,
        COUNT(*) AS school_records,
        SUM(
            COALESCE(allegation_sex, 0)
            + COALESCE(allegation_race, 0)
            + COALESCE(allegation_orientation, 0)
            + COALESCE(allegation_disability, 0)
            + COALESCE(allegation_religion, 0)
        ) AS total_main_allegations,
        SUM(
            COALESCE(total_disciplined_sex_male, 0)
            + COALESCE(total_disciplined_sex_female, 0)
            + COALESCE(total_disciplined_race_male, 0)
            + COALESCE(total_disciplined_race_female, 0)
            + COALESCE(total_disciplined_disability_male, 0)
            + COALESCE(total_disciplined_disability_female, 0)
        ) AS total_disciplined_students
    FROM s_yoldaserdem.crdc_bullying_clean
    GROUP BY state
)
SELECT
    state,
    school_records,
    total_main_allegations,
    total_disciplined_students,
    ROUND(total_disciplined_students * 1.0 / NULLIF(total_main_allegations, 0), 2) AS discipline_to_allegation_ratio
FROM state_summary
WHERE total_main_allegations >= 100
ORDER BY discipline_to_allegation_ratio DESC
LIMIT 20;


-- 5. States with low discipline-to-allegation ratio
WITH state_summary AS (
    SELECT
        state,
        COUNT(*) AS school_records,
        SUM(
            COALESCE(allegation_sex, 0)
            + COALESCE(allegation_race, 0)
            + COALESCE(allegation_orientation, 0)
            + COALESCE(allegation_disability, 0)
            + COALESCE(allegation_religion, 0)
        ) AS total_main_allegations,
        SUM(
            COALESCE(total_disciplined_sex_male, 0)
            + COALESCE(total_disciplined_sex_female, 0)
            + COALESCE(total_disciplined_race_male, 0)
            + COALESCE(total_disciplined_race_female, 0)
            + COALESCE(total_disciplined_disability_male, 0)
            + COALESCE(total_disciplined_disability_female, 0)
        ) AS total_disciplined_students
    FROM s_yoldaserdem.crdc_bullying_clean
    GROUP BY state
)
SELECT
    state,
    school_records,
    total_main_allegations,
    total_disciplined_students,
    ROUND(total_disciplined_students * 1.0 / NULLIF(total_main_allegations, 0), 2) AS discipline_to_allegation_ratio
FROM state_summary
WHERE total_main_allegations >= 100
ORDER BY discipline_to_allegation_ratio ASC
LIMIT 20;


-- 6. Juvenile justice vs non-juvenile justice comparison
WITH school_summary AS (
    SELECT
        juvenile_justice_school,
        COALESCE(allegation_sex, 0)
        + COALESCE(allegation_race, 0)
        + COALESCE(allegation_orientation, 0)
        + COALESCE(allegation_disability, 0)
        + COALESCE(allegation_religion, 0) AS total_main_allegations,
        COALESCE(total_disciplined_sex_male, 0)
        + COALESCE(total_disciplined_sex_female, 0)
        + COALESCE(total_disciplined_race_male, 0)
        + COALESCE(total_disciplined_race_female, 0)
        + COALESCE(total_disciplined_disability_male, 0)
        + COALESCE(total_disciplined_disability_female, 0) AS total_disciplined_students
    FROM s_yoldaserdem.crdc_bullying_clean
)
SELECT
    juvenile_justice_school,
    COUNT(*) AS school_records,
    SUM(total_main_allegations) AS total_main_allegations,
    ROUND(AVG(total_main_allegations), 2) AS avg_allegations_per_school,
    SUM(total_disciplined_students) AS total_disciplined_students,
    ROUND(AVG(total_disciplined_students), 2) AS avg_disciplined_students_per_school
FROM school_summary
GROUP BY juvenile_justice_school
ORDER BY avg_allegations_per_school DESC;