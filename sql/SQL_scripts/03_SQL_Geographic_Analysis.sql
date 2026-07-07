/*
03_Geographic_Analysis.sql

Purpose:
Analyze geographic reporting patterns across states and districts.
This script compares raw totals with normalized rates to avoid misleading
conclusions caused by different numbers of schools per state or district.
*/


-- 1. Top jurisdictions by raw allegation totals
WITH school_totals AS (
    SELECT
        state,
        COALESCE(allegation_sex, 0)
        + COALESCE(allegation_race, 0)
        + COALESCE(allegation_orientation, 0)
        + COALESCE(allegation_disability, 0)
        + COALESCE(allegation_religion, 0) AS total_main_allegations
    FROM s_yoldaserdem.crdc_bullying_clean
)
SELECT
    state,
    COUNT(*) AS school_records,
    SUM(total_main_allegations) AS total_main_allegations
FROM school_totals
GROUP BY state
ORDER BY total_main_allegations DESC
LIMIT 15;


-- 2. Top jurisdictions by allegations per school
WITH school_totals AS (
    SELECT
        state,
        COALESCE(allegation_sex, 0)
        + COALESCE(allegation_race, 0)
        + COALESCE(allegation_orientation, 0)
        + COALESCE(allegation_disability, 0)
        + COALESCE(allegation_religion, 0) AS total_main_allegations
    FROM s_yoldaserdem.crdc_bullying_clean
)
SELECT
    state,
    COUNT(*) AS school_records,
    SUM(total_main_allegations) AS total_main_allegations,
    ROUND(SUM(total_main_allegations) * 1.0 / COUNT(*), 2) AS allegations_per_school
FROM school_totals
GROUP BY state
HAVING COUNT(*) >= 50
ORDER BY allegations_per_school DESC
LIMIT 15;


-- 3. Jurisdictions with highest share of schools reporting allegations
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
    COUNT(*) AS school_records,
    SUM(CASE WHEN total_main_allegations > 0 THEN 1 ELSE 0 END) AS schools_with_allegations,
    ROUND(SUM(CASE WHEN total_main_allegations > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS schools_with_allegations_pct
FROM school_totals
GROUP BY state
HAVING COUNT(*) >= 50
ORDER BY schools_with_allegations_pct DESC
LIMIT 15;


-- 4. Top districts by raw allegation totals
WITH school_totals AS (
    SELECT
        state,
        district,
        COALESCE(allegation_sex, 0)
        + COALESCE(allegation_race, 0)
        + COALESCE(allegation_orientation, 0)
        + COALESCE(allegation_disability, 0)
        + COALESCE(allegation_religion, 0) AS total_main_allegations
    FROM s_yoldaserdem.crdc_bullying_clean
)
SELECT
    state,
    district,
    COUNT(*) AS school_records,
    SUM(total_main_allegations) AS total_main_allegations
FROM school_totals
GROUP BY state, district
ORDER BY total_main_allegations DESC
LIMIT 20;


-- 5. Top districts by allegations per school
WITH school_totals AS (
    SELECT
        state,
        district,
        COALESCE(allegation_sex, 0)
        + COALESCE(allegation_race, 0)
        + COALESCE(allegation_orientation, 0)
        + COALESCE(allegation_disability, 0)
        + COALESCE(allegation_religion, 0) AS total_main_allegations
    FROM s_yoldaserdem.crdc_bullying_clean
)
SELECT
    state,
    district,
    COUNT(*) AS school_records,
    SUM(total_main_allegations) AS total_main_allegations,
    ROUND(SUM(total_main_allegations) * 1.0 / COUNT(*), 2) AS allegations_per_school
FROM school_totals
GROUP BY state, district
HAVING COUNT(*) >= 25
ORDER BY allegations_per_school DESC
LIMIT 20;


-- 6. State-level category mix
WITH category_totals AS (
    SELECT
        state,
        COUNT(*) AS school_records,
        SUM(COALESCE(allegation_sex, 0)) AS sex_allegations,
        SUM(COALESCE(allegation_race, 0)) AS race_allegations,
        SUM(COALESCE(allegation_orientation, 0)) AS orientation_allegations,
        SUM(COALESCE(allegation_disability, 0)) AS disability_allegations,
        SUM(COALESCE(allegation_religion, 0)) AS religion_allegations
    FROM s_yoldaserdem.crdc_bullying_clean
    GROUP BY state
)
SELECT
    state,
    school_records,
    sex_allegations,
    race_allegations,
    orientation_allegations,
    disability_allegations,
    religion_allegations,
    sex_allegations + race_allegations + orientation_allegations + disability_allegations + religion_allegations AS total_main_allegations,
    ROUND(sex_allegations * 100.0 / NULLIF(sex_allegations + race_allegations + orientation_allegations + disability_allegations + religion_allegations, 0), 2) AS sex_share_pct,
    ROUND(race_allegations * 100.0 / NULLIF(sex_allegations + race_allegations + orientation_allegations + disability_allegations + religion_allegations, 0), 2) AS race_share_pct,
    ROUND(orientation_allegations * 100.0 / NULLIF(sex_allegations + race_allegations + orientation_allegations + disability_allegations + religion_allegations, 0), 2) AS orientation_share_pct,
    ROUND(disability_allegations * 100.0 / NULLIF(sex_allegations + race_allegations + orientation_allegations + disability_allegations + religion_allegations, 0), 2) AS disability_share_pct,
    ROUND(religion_allegations * 100.0 / NULLIF(sex_allegations + race_allegations + orientation_allegations + disability_allegations + religion_allegations, 0), 2) AS religion_share_pct
FROM category_totals
WHERE sex_allegations + race_allegations + orientation_allegations + disability_allegations + religion_allegations > 0
ORDER BY total_main_allegations DESC
LIMIT 20;


-- 7. Compact state summary for Tableau
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
    COUNT(*) AS school_records,
    SUM(CASE WHEN total_main_allegations > 0 THEN 1 ELSE 0 END) AS schools_with_allegations,
    ROUND(SUM(CASE WHEN total_main_allegations > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS schools_with_allegations_pct,
    SUM(total_main_allegations) AS total_main_allegations,
    ROUND(SUM(total_main_allegations) * 1.0 / COUNT(*), 2) AS allegations_per_school
FROM school_totals
GROUP BY state
ORDER BY total_main_allegations DESC;