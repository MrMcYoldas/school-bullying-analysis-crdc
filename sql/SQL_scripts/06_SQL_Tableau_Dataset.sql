/*
============================================================
06_SQL_Tableau_Dataset.sql
School Bullying Analysis using the CRDC 2021–22 Dataset

Purpose:
Create Tableau-ready SQL views from the cleaned PostgreSQL table.

Source table:
s_yoldaserdem.crdc_bullying_clean
============================================================
*/


-- ============================================================
-- 1. Executive Dashboard Summary View
-- ============================================================
-- Purpose:
-- One-row summary for KPI cards in Tableau.

DROP VIEW IF EXISTS s_yoldaserdem.vw_dashboard_summary;

CREATE VIEW s_yoldaserdem.vw_dashboard_summary AS
SELECT
    COUNT(*) AS school_records,
    COUNT(DISTINCT state) AS jurisdictions,
    COUNT(DISTINCT district_id) AS school_districts,
    SUM(CASE WHEN juvenile_justice_school = 'Yes' THEN 1 ELSE 0 END) AS juvenile_justice_schools,
    SUM(
        COALESCE(allegation_sex, 0)
        + COALESCE(allegation_race, 0)
        + COALESCE(allegation_orientation, 0)
        + COALESCE(allegation_disability, 0)
        + COALESCE(allegation_religion, 0)
    ) AS total_main_allegations,
    SUM(
        COALESCE(total_reported_sex_male, 0)
        + COALESCE(total_reported_sex_female, 0)
        + COALESCE(total_reported_race_male, 0)
        + COALESCE(total_reported_race_female, 0)
        + COALESCE(total_reported_disability_male, 0)
        + COALESCE(total_reported_disability_female, 0)
    ) AS students_reported_as_affected,
    SUM(
        COALESCE(total_disciplined_sex_male, 0)
        + COALESCE(total_disciplined_sex_female, 0)
        + COALESCE(total_disciplined_race_male, 0)
        + COALESCE(total_disciplined_race_female, 0)
        + COALESCE(total_disciplined_disability_male, 0)
        + COALESCE(total_disciplined_disability_female, 0)
    ) AS students_disciplined,
    SUM(
        CASE
            WHEN COALESCE(allegation_sex, 0)
               + COALESCE(allegation_race, 0)
               + COALESCE(allegation_orientation, 0)
               + COALESCE(allegation_disability, 0)
               + COALESCE(allegation_religion, 0) > 0
            THEN 1
            ELSE 0
        END
    ) AS schools_with_allegations,
    SUM(
        CASE
            WHEN COALESCE(allegation_sex, 0)
               + COALESCE(allegation_race, 0)
               + COALESCE(allegation_orientation, 0)
               + COALESCE(allegation_disability, 0)
               + COALESCE(allegation_religion, 0) = 0
            THEN 1
            ELSE 0
        END
    ) AS schools_without_allegations,
    ROUND(
        SUM(
            CASE
                WHEN COALESCE(allegation_sex, 0)
                   + COALESCE(allegation_race, 0)
                   + COALESCE(allegation_orientation, 0)
                   + COALESCE(allegation_disability, 0)
                   + COALESCE(allegation_religion, 0) > 0
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS schools_with_allegations_pct
FROM s_yoldaserdem.crdc_bullying_clean;


-- Validation
SELECT *
FROM s_yoldaserdem.vw_dashboard_summary;

-- ============================================================
-- 2. State Summary View
-- ============================================================
-- Purpose:
-- One row per state/jurisdiction for Tableau maps, rankings,
-- state filters, priority levels, and executive tooltips.

DROP VIEW IF EXISTS s_yoldaserdem.vw_state_summary;

CREATE VIEW s_yoldaserdem.vw_state_summary AS
WITH state_base AS (
    SELECT
        state,
        district_id,
        school_key,
        juvenile_justice_school,

        COALESCE(allegation_sex, 0) AS allegation_sex,
        COALESCE(allegation_race, 0) AS allegation_race,
        COALESCE(allegation_orientation, 0) AS allegation_orientation,
        COALESCE(allegation_disability, 0) AS allegation_disability,
        COALESCE(allegation_religion, 0) AS allegation_religion,

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
        + COALESCE(total_reported_disability_female, 0) AS students_reported_as_affected,

        COALESCE(total_disciplined_sex_male, 0)
        + COALESCE(total_disciplined_sex_female, 0)
        + COALESCE(total_disciplined_race_male, 0)
        + COALESCE(total_disciplined_race_female, 0)
        + COALESCE(total_disciplined_disability_male, 0)
        + COALESCE(total_disciplined_disability_female, 0) AS students_disciplined
    FROM s_yoldaserdem.crdc_bullying_clean
),
state_summary AS (
    SELECT
        state,
        COUNT(*) AS school_records,
        COUNT(DISTINCT district_id) AS school_districts,
        SUM(CASE WHEN juvenile_justice_school = 'Yes' THEN 1 ELSE 0 END) AS juvenile_justice_schools,

        SUM(total_main_allegations) AS total_main_allegations,
        ROUND(SUM(total_main_allegations) * 1.0 / COUNT(*), 2) AS allegations_per_school,

        SUM(CASE WHEN total_main_allegations > 0 THEN 1 ELSE 0 END) AS schools_with_allegations,
        SUM(CASE WHEN total_main_allegations = 0 THEN 1 ELSE 0 END) AS schools_without_allegations,
        ROUND(
            SUM(CASE WHEN total_main_allegations > 0 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
            2
        ) AS schools_with_allegations_pct,

        SUM(students_reported_as_affected) AS students_reported_as_affected,
        SUM(students_disciplined) AS students_disciplined,
        ROUND(
            SUM(students_disciplined) * 1.0 / NULLIF(SUM(total_main_allegations), 0),
            2
        ) AS discipline_to_allegation_ratio,

        SUM(allegation_sex) AS sex_allegations,
        SUM(allegation_race) AS race_allegations,
        SUM(allegation_orientation) AS orientation_allegations,
        SUM(allegation_disability) AS disability_allegations,
        SUM(allegation_religion) AS religion_allegations
    FROM state_base
    GROUP BY state
)
SELECT
    state,
    school_records,
    school_districts,
    juvenile_justice_schools,
    total_main_allegations,
    allegations_per_school,
    schools_with_allegations,
    schools_without_allegations,
    schools_with_allegations_pct,
    students_reported_as_affected,
    students_disciplined,
    discipline_to_allegation_ratio,
    sex_allegations,
    race_allegations,
    orientation_allegations,
    disability_allegations,
    religion_allegations,

    CASE
        WHEN total_main_allegations = 0 THEN 'No reported allegations'
        WHEN allegations_per_school >= 2.00 THEN 'High priority'
        WHEN allegations_per_school >= 1.00 THEN 'Medium priority'
        ELSE 'Routine monitoring'
    END AS priority_level,

    CASE
        WHEN total_main_allegations = 0
            THEN 'Review reporting completeness and continue routine monitoring.'
        WHEN allegations_per_school >= 2.00
             AND discipline_to_allegation_ratio < 0.75
            THEN 'Prioritize prevention support and review response consistency.'
        WHEN allegations_per_school >= 2.00
            THEN 'Prioritize targeted prevention and monitoring resources.'
        WHEN discipline_to_allegation_ratio < 0.75
            THEN 'Review whether disciplinary responses are consistently documented.'
        WHEN allegations_per_school >= 1.00
            THEN 'Monitor trends and compare patterns across districts.'
        ELSE 'Continue routine monitoring.'
    END AS suggested_action
FROM state_summary;


-- Validation
SELECT *
FROM s_yoldaserdem.vw_state_summary
ORDER BY total_main_allegations DESC
LIMIT 10;

-- ============================================================
-- 3. Category Summary View
-- ============================================================
-- Purpose:
-- One row per main allegation category for Tableau category charts,
-- ranking views, tooltips, and executive interpretation.

DROP VIEW IF EXISTS s_yoldaserdem.vw_category_summary;

CREATE VIEW s_yoldaserdem.vw_category_summary AS
WITH category_totals AS (
    SELECT
        'Sex' AS allegation_category,
        SUM(COALESCE(allegation_sex, 0)) AS total_allegations
    FROM s_yoldaserdem.crdc_bullying_clean

    UNION ALL

    SELECT
        'Race',
        SUM(COALESCE(allegation_race, 0))
    FROM s_yoldaserdem.crdc_bullying_clean

    UNION ALL

    SELECT
        'Sexual Orientation',
        SUM(COALESCE(allegation_orientation, 0))
    FROM s_yoldaserdem.crdc_bullying_clean

    UNION ALL

    SELECT
        'Disability',
        SUM(COALESCE(allegation_disability, 0))
    FROM s_yoldaserdem.crdc_bullying_clean

    UNION ALL

    SELECT
        'Religion',
        SUM(COALESCE(allegation_religion, 0))
    FROM s_yoldaserdem.crdc_bullying_clean
),
ranked_categories AS (
    SELECT
        allegation_category,
        total_allegations,
        ROUND(
            total_allegations * 100.0 / SUM(total_allegations) OVER (),
            2
        ) AS allegation_share_pct,
        RANK() OVER (ORDER BY total_allegations DESC) AS category_rank
    FROM category_totals
)
SELECT
    allegation_category,
    total_allegations,
    allegation_share_pct,
    category_rank,
    CASE
        WHEN category_rank IN (1, 2) THEN 'High priority'
        WHEN category_rank IN (3, 4) THEN 'Medium priority'
        ELSE 'Monitor'
    END AS priority_tier,
    CASE
        WHEN allegation_category = 'Sex'
            THEN 'Prioritize prevention and response programs addressing sex-based harassment.'
        WHEN allegation_category = 'Race'
            THEN 'Review racial harassment patterns and strengthen equity-focused prevention efforts.'
        WHEN allegation_category = 'Sexual Orientation'
            THEN 'Monitor harassment allegations based on sexual orientation and support inclusive school climate initiatives.'
        WHEN allegation_category = 'Disability'
            THEN 'Strengthen monitoring of disability-based harassment and related student support practices.'
        WHEN allegation_category = 'Religion'
            THEN 'Continue monitoring religion-based harassment and review targeted cases where needed.'
        ELSE 'Continue monitoring.'
    END AS suggested_policy_focus
FROM ranked_categories
ORDER BY category_rank;


-- Validation
SELECT *
FROM s_yoldaserdem.vw_category_summary
ORDER BY category_rank;

-- ============================================================
-- 4. Demographic Summary View
-- ============================================================
-- Purpose:
-- Compare reported students and disciplined students across
-- the major demographic groups.

DROP VIEW IF EXISTS s_yoldaserdem.vw_demographic_summary;

CREATE VIEW s_yoldaserdem.vw_demographic_summary AS

WITH demographic_summary AS (

SELECT
'Sex - Male' AS student_group,
SUM(COALESCE(total_reported_sex_male,0)) AS students_reported_as_affected,
SUM(COALESCE(total_disciplined_sex_male,0)) AS students_disciplined

FROM s_yoldaserdem.crdc_bullying_clean

UNION ALL

SELECT
'Sex - Female',
SUM(COALESCE(total_reported_sex_female,0)),
SUM(COALESCE(total_disciplined_sex_female,0))

FROM s_yoldaserdem.crdc_bullying_clean

UNION ALL

SELECT
'Race - Male',
SUM(COALESCE(total_reported_race_male,0)),
SUM(COALESCE(total_disciplined_race_male,0))

FROM s_yoldaserdem.crdc_bullying_clean

UNION ALL

SELECT
'Race - Female',
SUM(COALESCE(total_reported_race_female,0)),
SUM(COALESCE(total_disciplined_race_female,0))

FROM s_yoldaserdem.crdc_bullying_clean

UNION ALL

SELECT
'Disability - Male',
SUM(COALESCE(total_reported_disability_male,0)),
SUM(COALESCE(total_disciplined_disability_male,0))

FROM s_yoldaserdem.crdc_bullying_clean

UNION ALL

SELECT
'Disability - Female',
SUM(COALESCE(total_reported_disability_female,0)),
SUM(COALESCE(total_disciplined_disability_female,0))

FROM s_yoldaserdem.crdc_bullying_clean

)

SELECT

student_group,

students_reported_as_affected,

students_disciplined,

students_disciplined
-
students_reported_as_affected
AS difference,

ROUND(
students_disciplined * 100.0 /
NULLIF(students_reported_as_affected,0),
2
) AS discipline_rate_pct,

RANK() OVER(
ORDER BY students_reported_as_affected DESC
) AS reporting_rank,

CASE

WHEN students_reported_as_affected >= 20000
THEN 'High Priority'

WHEN students_reported_as_affected >= 10000
THEN 'Medium Priority'

ELSE 'Monitor'

END
AS priority_level,

CASE

WHEN students_reported_as_affected >= 20000
THEN 'Prioritize prevention resources and targeted interventions.'

WHEN students_reported_as_affected >= 10000
THEN 'Continue monitoring and compare across jurisdictions.'

ELSE 'Routine monitoring.'

END
AS suggested_action

FROM demographic_summary

ORDER BY reporting_rank;


-- ============================================================
-- Validation
-- ============================================================

SELECT *
FROM s_yoldaserdem.vw_demographic_summary;

-- ============================================================
-- 5. School Hotspots View
-- ============================================================
-- Purpose:
-- One row per school for identifying high-reporting schools,
-- school-level outliers, and allegation-discipline gaps.

DROP VIEW IF EXISTS s_yoldaserdem.vw_school_hotspots;

CREATE VIEW s_yoldaserdem.vw_school_hotspots AS

WITH school_summary AS (
    SELECT
        state,
        district,
        school,
        school_key,
        juvenile_justice_school,

        COALESCE(allegation_sex, 0) AS sex_allegations,
        COALESCE(allegation_race, 0) AS race_allegations,
        COALESCE(allegation_orientation, 0) AS orientation_allegations,
        COALESCE(allegation_disability, 0) AS disability_allegations,
        COALESCE(allegation_religion, 0) AS religion_allegations,

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
        + COALESCE(total_reported_disability_female, 0) AS students_reported_as_affected,

        COALESCE(total_disciplined_sex_male, 0)
        + COALESCE(total_disciplined_sex_female, 0)
        + COALESCE(total_disciplined_race_male, 0)
        + COALESCE(total_disciplined_race_female, 0)
        + COALESCE(total_disciplined_disability_male, 0)
        + COALESCE(total_disciplined_disability_female, 0) AS students_disciplined
    FROM s_yoldaserdem.crdc_bullying_clean
)

SELECT
    state,
    district,
    school,
    school_key,
    juvenile_justice_school,

    sex_allegations,
    race_allegations,
    orientation_allegations,
    disability_allegations,
    religion_allegations,

    total_main_allegations,
    students_reported_as_affected,
    students_disciplined,

    total_main_allegations - students_disciplined AS allegation_discipline_gap,

    ROUND(
        students_disciplined * 1.0 / NULLIF(total_main_allegations, 0),
        2
    ) AS discipline_to_allegation_ratio,

    CASE
        WHEN total_main_allegations >= 100 THEN 'Extreme hotspot'
        WHEN total_main_allegations >= 50 THEN 'High hotspot'
        WHEN total_main_allegations >= 25 THEN 'Moderate hotspot'
        WHEN total_main_allegations > 0 THEN 'Reported allegations'
        ELSE 'No reported allegations'
    END AS hotspot_level,

    CASE
        WHEN total_main_allegations >= 100
            THEN 'Prioritize immediate review and targeted prevention support.'
        WHEN total_main_allegations >= 50
            THEN 'Review school-level reporting patterns and consider additional support.'
        WHEN total_main_allegations >= 25
            THEN 'Monitor closely and compare with district-level patterns.'
        WHEN total_main_allegations > 0
            THEN 'Continue monitoring through routine reporting.'
        ELSE 'No reported allegations in this reporting period.'
    END AS suggested_action

FROM school_summary;


-- Validation
SELECT *
FROM s_yoldaserdem.vw_school_hotspots
ORDER BY total_main_allegations DESC
LIMIT 20;

----
-- ============================================================
-- 6. Priority Matrix View
-- ============================================================
-- Purpose:
-- State-level action matrix for Tableau.
-- This view combines reporting intensity, disciplinary response,
-- and school reporting coverage into one executive prioritization layer.

DROP VIEW IF EXISTS s_yoldaserdem.vw_priority_matrix;

CREATE VIEW s_yoldaserdem.vw_priority_matrix AS

WITH state_summary AS (
    SELECT
        state,
        COUNT(*) AS school_records,
        COUNT(DISTINCT district_id) AS school_districts,

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
        ) AS students_disciplined,

        SUM(
            CASE
                WHEN COALESCE(allegation_sex, 0)
                   + COALESCE(allegation_race, 0)
                   + COALESCE(allegation_orientation, 0)
                   + COALESCE(allegation_disability, 0)
                   + COALESCE(allegation_religion, 0) > 0
                THEN 1
                ELSE 0
            END
        ) AS schools_with_allegations

    FROM s_yoldaserdem.crdc_bullying_clean
    GROUP BY state
),

metrics AS (
    SELECT
        state,
        school_records,
        school_districts,
        total_main_allegations,
        students_disciplined,
        schools_with_allegations,

        ROUND(
            total_main_allegations * 1.0 / school_records,
            2
        ) AS allegations_per_school,

        ROUND(
            students_disciplined * 1.0 / NULLIF(total_main_allegations, 0),
            2
        ) AS discipline_to_allegation_ratio,

        ROUND(
            schools_with_allegations * 100.0 / school_records,
            2
        ) AS schools_with_allegations_pct

    FROM state_summary
    WHERE total_main_allegations >= 100
)

SELECT
    state,
    school_records,
    school_districts,
    total_main_allegations,
    students_disciplined,
    schools_with_allegations,
    schools_with_allegations_pct,
    allegations_per_school,
    discipline_to_allegation_ratio,

    CASE
        WHEN allegations_per_school >= 2
             AND discipline_to_allegation_ratio < 0.75
            THEN 'Highest Priority'
        WHEN allegations_per_school >= 2
            THEN 'High Priority'
        WHEN discipline_to_allegation_ratio < 0.75
            THEN 'Response Review'
        WHEN schools_with_allegations_pct >= 40
            THEN 'High Reporting Coverage'
        ELSE 'Monitor'
    END AS priority_level,

    CASE
        WHEN allegations_per_school >= 2
             AND discipline_to_allegation_ratio < 0.75
            THEN 'High allegation intensity combined with comparatively low disciplinary response. Prioritize prevention support and review response consistency.'
        WHEN allegations_per_school >= 2
            THEN 'High allegation intensity. Investigate drivers of elevated reporting and consider targeted prevention resources.'
        WHEN discipline_to_allegation_ratio < 0.75
            THEN 'Disciplinary response ratio is comparatively low. Review whether response practices are consistently documented.'
        WHEN schools_with_allegations_pct >= 40
            THEN 'Large share of schools report allegations. Monitor reporting patterns and compare district-level variation.'
        ELSE 'Continue routine monitoring.'
    END AS suggested_action

FROM metrics

ORDER BY
    CASE
        WHEN allegations_per_school >= 2
             AND discipline_to_allegation_ratio < 0.75 THEN 1
        WHEN allegations_per_school >= 2 THEN 2
        WHEN discipline_to_allegation_ratio < 0.75 THEN 3
        WHEN schools_with_allegations_pct >= 40 THEN 4
        ELSE 5
    END,
    allegations_per_school DESC,
    discipline_to_allegation_ratio ASC;


-- Validation
SELECT *
FROM s_yoldaserdem.vw_priority_matrix
ORDER BY
    CASE
        WHEN priority_level = 'Highest Priority' THEN 1
        WHEN priority_level = 'High Priority' THEN 2
        WHEN priority_level = 'Response Review' THEN 3
        WHEN priority_level = 'High Reporting Coverage' THEN 4
        ELSE 5
    END,
    allegations_per_school DESC;