-- ============================================================
-- Project: School Bullying Capstone
-- File: 01_SQL_Data_Validation.sql
-- Author: Yoldas Erdem
-- Description:
-- Initial validation of the cleaned CRDC 2021–22 analytical dataset.
-- This script verifies data quality, dataset completeness,
-- uniqueness, and overall structure before further SQL analysis.
-- ============================================================


----------------------------------------------------
-- 1. Dataset Overview
----------------------------------------------------

SELECT
    COUNT(*) AS total_school_records
FROM s_yoldaserdem.crdc_bullying_clean;


----------------------------------------------------
-- 2. Number of Jurisdictions
----------------------------------------------------

SELECT
    COUNT(DISTINCT state) AS jurisdictions
FROM s_yoldaserdem.crdc_bullying_clean;


----------------------------------------------------
-- 3. Number of School Districts
----------------------------------------------------

SELECT
    COUNT(DISTINCT district_id) AS school_districts
FROM s_yoldaserdem.crdc_bullying_clean;


----------------------------------------------------
-- 4. Juvenile Justice Schools
----------------------------------------------------

SELECT
    juvenile_justice_school,
    COUNT(*) AS schools
FROM s_yoldaserdem.crdc_bullying_clean
GROUP BY juvenile_justice_school
ORDER BY schools DESC;


----------------------------------------------------
-- 5. Duplicate School Records
----------------------------------------------------

SELECT
    school_key,
    COUNT(*) AS duplicate_records
FROM s_yoldaserdem.crdc_bullying_clean
GROUP BY school_key
HAVING COUNT(*) > 1;


----------------------------------------------------
-- 6. Missing School Names
----------------------------------------------------

SELECT
    COUNT(*) AS missing_school_names
FROM s_yoldaserdem.crdc_bullying_clean
WHERE school IS NULL;


----------------------------------------------------
-- 7. Missing District Names
----------------------------------------------------

SELECT
    COUNT(*) AS missing_district_names
FROM s_yoldaserdem.crdc_bullying_clean
WHERE district IS NULL;


----------------------------------------------------
-- 8. Missing State Values
----------------------------------------------------

SELECT
    COUNT(*) AS missing_states
FROM s_yoldaserdem.crdc_bullying_clean
WHERE state IS NULL;


----------------------------------------------------
-- 9. Total Main Allegations
----------------------------------------------------

SELECT

SUM(allegation_sex)          AS sex_allegations,
SUM(allegation_orientation)  AS orientation_allegations,
SUM(allegation_race)         AS race_allegations,
SUM(allegation_disability)   AS disability_allegations,
SUM(allegation_religion)     AS religion_allegations,

SUM(
COALESCE(allegation_sex,0)+
COALESCE(allegation_orientation,0)+
COALESCE(allegation_race,0)+
COALESCE(allegation_disability,0)+
COALESCE(allegation_religion,0)
) AS total_main_allegations

FROM s_yoldaserdem.crdc_bullying_clean;


----------------------------------------------------
-- 10. Schools Reporting Any Allegation
----------------------------------------------------

SELECT

COUNT(*) FILTER (
WHERE
COALESCE(allegation_sex,0)+
COALESCE(allegation_orientation,0)+
COALESCE(allegation_race,0)+
COALESCE(allegation_disability,0)+
COALESCE(allegation_religion,0) > 0
) AS schools_reporting_allegations,

COUNT(*) FILTER (
WHERE
COALESCE(allegation_sex,0)+
COALESCE(allegation_orientation,0)+
COALESCE(allegation_race,0)+
COALESCE(allegation_disability,0)+
COALESCE(allegation_religion,0) = 0
) AS schools_without_allegations

FROM s_yoldaserdem.crdc_bullying_clean;


----------------------------------------------------
-- 11. Dataset Validation Summary
----------------------------------------------------

SELECT

COUNT(*)                                   AS total_records,
COUNT(DISTINCT state)                      AS jurisdictions,
COUNT(DISTINCT district_id)                AS districts,
COUNT(DISTINCT school_key)                 AS unique_schools,

SUM(
CASE
WHEN juvenile_justice_school = 'Yes'
THEN 1
ELSE 0
END
) AS juvenile_justice_schools

FROM s_yoldaserdem.crdc_bullying_clean;