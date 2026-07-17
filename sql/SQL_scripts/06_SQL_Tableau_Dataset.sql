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
--
-- Key thresholds:
-- High priority: allegations per school >= 2.00
-- Medium priority: allegations per school >= 1.00
-- Response review: discipline-to-allegation ratio < 0.60
-- ============================================================

CREATE OR REPLACE VIEW s_yoldaserdem.vw_state_summary AS

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
        + COALESCE(allegation_religion, 0)
            AS total_main_allegations,

        COALESCE(total_reported_sex_male, 0)
        + COALESCE(total_reported_sex_female, 0)
        + COALESCE(total_reported_race_male, 0)
        + COALESCE(total_reported_race_female, 0)
        + COALESCE(total_reported_disability_male, 0)
        + COALESCE(total_reported_disability_female, 0)
            AS students_reported_as_affected,

        COALESCE(total_disciplined_sex_male, 0)
        + COALESCE(total_disciplined_sex_female, 0)
        + COALESCE(total_disciplined_race_male, 0)
        + COALESCE(total_disciplined_race_female, 0)
        + COALESCE(total_disciplined_disability_male, 0)
        + COALESCE(total_disciplined_disability_female, 0)
            AS students_disciplined

    FROM s_yoldaserdem.crdc_bullying_clean
),

state_summary AS (
    SELECT
        state,

        COUNT(*) AS school_records,
        COUNT(DISTINCT district_id) AS school_districts,

        SUM(
            CASE
                WHEN juvenile_justice_school = 'Yes' THEN 1
                ELSE 0
            END
        ) AS juvenile_justice_schools,

        SUM(total_main_allegations) AS total_main_allegations,

        -- Average reported allegations across all school records.
        -- Stored with six decimal places to preserve very small values.
        ROUND(
            SUM(total_main_allegations)::NUMERIC
            / NULLIF(COUNT(*), 0),
            6
        ) AS allegations_per_school,

        SUM(
            CASE
                WHEN total_main_allegations > 0 THEN 1
                ELSE 0
            END
        ) AS schools_with_allegations,

        SUM(
            CASE
                WHEN total_main_allegations = 0 THEN 1
                ELSE 0
            END
        ) AS schools_without_allegations,

        ROUND(
            SUM(
                CASE
                    WHEN total_main_allegations > 0 THEN 1
                    ELSE 0
                END
            )::NUMERIC
            * 100
            / NULLIF(COUNT(*), 0),
            2
        ) AS schools_with_allegations_pct,

        SUM(students_reported_as_affected)
            AS students_reported_as_affected,

        SUM(students_disciplined)
            AS students_disciplined,

        ROUND(
            SUM(students_disciplined)::NUMERIC
            / NULLIF(SUM(total_main_allegations), 0),
            3
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
        WHEN total_main_allegations = 0
            THEN 'No reported allegations'

        WHEN allegations_per_school >= 2.00
            THEN 'High priority'

        WHEN allegations_per_school >= 1.00
            THEN 'Medium priority'

        ELSE 'Routine monitoring'
    END AS priority_level,

    CASE
        WHEN total_main_allegations = 0
            THEN
                'Review reporting completeness and continue routine monitoring.'

        WHEN allegations_per_school >= 2.00
             AND discipline_to_allegation_ratio < 0.60
            THEN
                'Prioritize prevention support and review response consistency.'

        WHEN allegations_per_school >= 2.00
            THEN
                'Prioritize targeted prevention and monitoring resources.'

        WHEN discipline_to_allegation_ratio < 0.60
            THEN
                'Review whether disciplinary responses are consistently documented.'

        WHEN allegations_per_school >= 1.00
            THEN
                'Monitor trends and compare patterns across districts.'

        ELSE
            'Continue routine monitoring.'
    END AS suggested_action

FROM state_summary;


-- ============================================================
-- Validation 1: General output
-- ============================================================

SELECT *
FROM s_yoldaserdem.vw_state_summary
ORDER BY total_main_allegations DESC
LIMIT 10;


-- ============================================================
-- Validation 2: North Carolina precision check
-- Expected allegations_per_school:
-- 2 / 2,722 = approximately 0.000735
-- ============================================================

SELECT
    state,
    school_records,
    total_main_allegations,
    schools_with_allegations,
    allegations_per_school,
    discipline_to_allegation_ratio,
    priority_level,
    suggested_action
FROM s_yoldaserdem.vw_state_summary
WHERE state = 'NORTH CAROLINA';

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
             AND discipline_to_allegation_ratio < 0.60
            THEN 'Highest Priority'
        WHEN allegations_per_school >= 2
            THEN 'High Priority'
        WHEN discipline_to_allegation_ratio < 0.60
            THEN 'Response Review'
        WHEN schools_with_allegations_pct >= 40
            THEN 'High Reporting Coverage'
        ELSE 'Monitor'
    END AS priority_level,

    CASE
        WHEN allegations_per_school >= 2
             AND discipline_to_allegation_ratio < 0.60
            THEN 'High allegation intensity combined with comparatively low disciplinary response. Prioritize prevention support and review response consistency.'
        WHEN allegations_per_school >= 2
            THEN 'High allegation intensity. Investigate drivers of elevated reporting and consider targeted prevention resources.'
        WHEN discipline_to_allegation_ratio < 0.60
            THEN 'Disciplinary response ratio is comparatively low. Review whether response practices are consistently documented.'
        WHEN schools_with_allegations_pct >= 40
            THEN 'Large share of schools report allegations. Monitor reporting patterns and compare district-level variation.'
        ELSE 'Continue routine monitoring.'
    END AS suggested_action

FROM metrics

ORDER BY
    CASE
        WHEN allegations_per_school >= 2
             AND discipline_to_allegation_ratio < 0.60 THEN 1
        WHEN allegations_per_school >= 2 THEN 2
        WHEN discipline_to_allegation_ratio < 0.60 THEN 3
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

------------------------------------------------------
-- CRDC BULLYING DASHBOARD
-- View: vw_state_demographic_heatmap
-- Purpose: Demographic analysis of reported bullying
-- by state, protected harassment category,
-- student group, gender, reported students,
-- and disciplinary actions.
------------------------------------------------------
-- Visualization:
-- Demographic Bullying Hotspots by State (Heatmap)
------------------------------------------------------

DROP VIEW IF EXISTS s_yoldaserdem.vw_state_demographic_heatmap;


CREATE VIEW s_yoldaserdem.vw_state_demographic_heatmap AS

-- SEX-BASED HARASSMENT
SELECT state, 'Sex' AS protected_category, 'Hispanic' AS student_group, 'Male' AS gender, 1 AS display_order,
       SUM(COALESCE(reported_sex_hispanic_male,0)) AS students_reported_as_affected,
       SUM(COALESCE(disciplined_sex_hispanic_male,0)) AS students_disciplined
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'Hispanic', 'Female', 1,
       SUM(COALESCE(reported_sex_hispanic_female,0)),
       SUM(COALESCE(disciplined_sex_hispanic_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'American Indian / Alaska Native', 'Male', 2,
       SUM(COALESCE(reported_sex_american_indian_male,0)),
       SUM(COALESCE(disciplined_sex_american_indian_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'American Indian / Alaska Native', 'Female', 2,
       SUM(COALESCE(reported_sex_american_indian_female,0)),
       SUM(COALESCE(disciplined_sex_american_indian_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'Asian', 'Male', 3,
       SUM(COALESCE(reported_sex_asian_male,0)),
       SUM(COALESCE(disciplined_sex_asian_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'Asian', 'Female', 3,
       SUM(COALESCE(reported_sex_asian_female,0)),
       SUM(COALESCE(disciplined_sex_asian_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'Pacific Islander', 'Male', 4,
       SUM(COALESCE(reported_sex_pacific_islander_male,0)),
       SUM(COALESCE(disciplined_sex_pacific_islander_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'Pacific Islander', 'Female', 4,
       SUM(COALESCE(reported_sex_pacific_islander_female,0)),
       SUM(COALESCE(disciplined_sex_pacific_islander_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'Black', 'Male', 5,
       SUM(COALESCE(reported_sex_black_male,0)),
       SUM(COALESCE(disciplined_sex_black_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'Black', 'Female', 5,
       SUM(COALESCE(reported_sex_black_female,0)),
       SUM(COALESCE(disciplined_sex_black_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'White', 'Male', 6,
       SUM(COALESCE(reported_sex_white_male,0)),
       SUM(COALESCE(disciplined_sex_white_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'White', 'Female', 6,
       SUM(COALESCE(reported_sex_white_female,0)),
       SUM(COALESCE(disciplined_sex_white_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'Multi-Race', 'Male', 7,
       SUM(COALESCE(reported_sex_multi_race_male,0)),
       SUM(COALESCE(disciplined_sex_multi_race_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'Multi-Race', 'Female', 7,
       SUM(COALESCE(reported_sex_multi_race_female,0)),
       SUM(COALESCE(disciplined_sex_multi_race_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'English Learner', 'Male', 8,
       SUM(COALESCE(reported_sex_english_learner_male,0)),
       SUM(COALESCE(disciplined_sex_english_learner_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'English Learner', 'Female', 8,
       SUM(COALESCE(reported_sex_english_learner_female,0)),
       SUM(COALESCE(disciplined_sex_english_learner_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'IDEA', 'Male', 9,
       SUM(COALESCE(reported_sex_idea_male,0)),
       SUM(COALESCE(disciplined_sex_idea_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'IDEA', 'Female', 9,
       SUM(COALESCE(reported_sex_idea_female,0)),
       SUM(COALESCE(disciplined_sex_idea_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'Section 504', 'Male', 10,
       SUM(COALESCE(reported_sex_section_504_male,0)),
       SUM(COALESCE(disciplined_sex_section_504_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Sex', 'Section 504', 'Female', 10,
       SUM(COALESCE(reported_sex_section_504_female,0)),
       SUM(COALESCE(disciplined_sex_section_504_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state

-- RACE-BASED HARASSMENT
UNION ALL
SELECT state, 'Race', 'Hispanic', 'Male', 1,
       SUM(COALESCE(reported_race_hispanic_male,0)),
       SUM(COALESCE(disciplined_race_hispanic_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Race', 'Hispanic', 'Female', 1,
       SUM(COALESCE(reported_race_hispanic_female,0)),
       SUM(COALESCE(disciplined_race_hispanic_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Race', 'Black', 'Male', 2,
       SUM(COALESCE(reported_race_black_male,0)),
       SUM(COALESCE(disciplined_race_black_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Race', 'Black', 'Female', 2,
       SUM(COALESCE(reported_race_black_female,0)),
       SUM(COALESCE(disciplined_race_black_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Race', 'White', 'Male', 3,
       SUM(COALESCE(reported_race_white_male,0)),
       SUM(COALESCE(disciplined_race_white_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Race', 'White', 'Female', 3,
       SUM(COALESCE(reported_race_white_female,0)),
       SUM(COALESCE(disciplined_race_white_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Race', 'Asian', 'Male', 4,
       SUM(COALESCE(reported_race_asian_male,0)),
       SUM(COALESCE(disciplined_race_asian_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Race', 'Asian', 'Female', 4,
       SUM(COALESCE(reported_race_asian_female,0)),
       SUM(COALESCE(disciplined_race_asian_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Race', 'American Indian / Alaska Native', 'Male', 5,
       SUM(COALESCE(reported_race_american_indian_male,0)),
       SUM(COALESCE(disciplined_race_american_indian_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Race', 'American Indian / Alaska Native', 'Female', 5,
       SUM(COALESCE(reported_race_american_indian_female,0)),
       SUM(COALESCE(disciplined_race_american_indian_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Race', 'Pacific Islander', 'Male', 6,
       SUM(COALESCE(reported_race_pacific_islander_male,0)),
       SUM(COALESCE(disciplined_race_pacific_islander_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Race', 'Pacific Islander', 'Female', 6,
       SUM(COALESCE(reported_race_pacific_islander_female,0)),
       SUM(COALESCE(disciplined_race_pacific_islander_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Race', 'Multi-Race', 'Male', 7,
       SUM(COALESCE(reported_race_multi_race_male,0)),
       SUM(COALESCE(disciplined_race_multi_race_male,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state
UNION ALL
SELECT state, 'Race', 'Multi-Race', 'Female', 7,
       SUM(COALESCE(reported_race_multi_race_female,0)),
       SUM(COALESCE(disciplined_race_multi_race_female,0))
FROM s_yoldaserdem.crdc_bullying_clean GROUP BY state;

------------------------------------------------------
------------------------------------------------------
-- CRDC BULLYING DASHBOARD
-- View: vw_state_action_matrix
-- Purpose: State-level executive action matrix showing
-- each state's top three protected harassment categories,
-- national reporting rank, priority tier, and dynamic
-- recommended actions.
------------------------------------------------------
-- Visualization:
-- State Priority Action Matrix
------------------------------------------------------
-- STATUS: FINAL
-- Used by: State Priority Action Matrix
-- Last Updated: 2026-07-09
------------------------------------------------------

DROP VIEW IF EXISTS s_yoldaserdem.vw_state_action_matrix;
CREATE VIEW s_yoldaserdem.vw_state_action_matrix AS
WITH category_long AS (
    SELECT state, 'Sex' AS protected_category, SUM(COALESCE(allegation_sex, 0)) AS category_allegations
    FROM s_yoldaserdem.crdc_bullying_clean
    GROUP BY state
    UNION ALL
    SELECT state, 'Race', SUM(COALESCE(allegation_race, 0))
    FROM s_yoldaserdem.crdc_bullying_clean
    GROUP BY state
    UNION ALL
    SELECT state, 'Sexual Orientation', SUM(COALESCE(allegation_orientation, 0))
    FROM s_yoldaserdem.crdc_bullying_clean
    GROUP BY state
    UNION ALL
    SELECT state, 'Disability', SUM(COALESCE(allegation_disability, 0))
    FROM s_yoldaserdem.crdc_bullying_clean
    GROUP BY state
    UNION ALL
    SELECT state, 'Religion', SUM(COALESCE(allegation_religion, 0))
    FROM s_yoldaserdem.crdc_bullying_clean
    GROUP BY state
),
ranked AS (
    SELECT
        state,
        protected_category,
        category_allegations,
        ROW_NUMBER() OVER (
            PARTITION BY state
            ORDER BY category_allegations DESC
        ) AS category_rank
    FROM category_long
),
state_metrics AS (
    SELECT
        state,
        total_main_allegations,
        allegations_per_school AS normalized_reporting_rate,
        schools_with_allegations,
        students_reported_as_affected,
        students_disciplined,
        discipline_to_allegation_ratio,
        priority_level,
        suggested_action,
        DENSE_RANK() OVER (
            ORDER BY allegations_per_school DESC
        ) AS state_rank,
        CASE
            WHEN priority_level = 'High priority' THEN 3
            WHEN priority_level = 'Medium priority' THEN 2
            WHEN priority_level = 'Routine monitoring' THEN 1
            ELSE 0
        END AS priority_score
    FROM s_yoldaserdem.vw_state_summary
)
SELECT
    r.state,
    r.state AS state_filter_value,
    CONCAT(r.state, ' | ', sm.priority_level) AS state_focus_label,
    CONCAT(
        r.state,
        ' | National Rank #',
        sm.state_rank,
        ' | ',
        sm.priority_level,
        ' | ',
        TO_CHAR(sm.normalized_reporting_rate, 'FM999,999,990.000'),
        ' allegations per school'
    ) AS state_priority_summary,
    sm.state_rank,
    CASE
        WHEN sm.state_rank <= 5 THEN '🚨 National Hotspot (Top 5)'
        WHEN sm.state_rank <= 10 THEN '⚠️ High National Concern (Top 10)'
        WHEN sm.state_rank <= 20 THEN '📊 Elevated Reporting (Top 20)'
        ELSE '✅ Maintain Monitoring'
    END AS national_reporting_tier,
    CASE
        WHEN rc.total_main_allegations = 0 THEN 'No reported allegations'
        WHEN rc.category_rank = 1 THEN '🥇 Primary Issue'
        WHEN rc.category_rank = 2 THEN '🥈 Secondary Issue'
        WHEN rc.category_rank = 3 THEN '🥉 Third Issue'
        WHEN rc.category_rank = 4 THEN '4th Issue'
        ELSE '5th Issue'
    END AS issue_rank_label,
    r.category_rank,
    r.protected_category,
    r.category_allegations,
    sm.total_main_allegations,
    sm.normalized_reporting_rate,
    sm.schools_with_allegations,
    sm.students_reported_as_affected,
    sm.students_disciplined,
    sm.discipline_to_allegation_ratio,
    sm.priority_level,
    sm.priority_score,
    sm.suggested_action,
    (sm.priority_score * 1000000) + COALESCE(sm.normalized_reporting_rate, 0) AS state_sort_score,
    CASE
        WHEN sm.state_rank <= 5 THEN
            CONCAT(
                '🚨 National Hotspot (Ranked #',
                sm.state_rank,
                ' of 52 jurisdictions). This state ranks among the highest reporting jurisdictions nationwide and warrants immediate statewide attention.'
            )
        WHEN sm.state_rank <= 10 THEN
            CONCAT(
                '⚠️ High National Concern (Ranked #',
                sm.state_rank,
                ' of 52 jurisdictions). Reporting intensity is among the highest nationwide and should remain a priority for prevention and monitoring.'
            )
        WHEN sm.state_rank <= 20 THEN
            CONCAT(
                '📊 Elevated Reporting (Ranked #',
                sm.state_rank,
                ' of 52 jurisdictions). Reporting activity remains elevated and should be monitored through targeted prevention and district-level review.'
            )
        WHEN sm.priority_level = 'High priority'
             AND sm.discipline_to_allegation_ratio < 0.60 THEN
            'Critical statewide attention recommended. High reporting combined with comparatively lower disciplinary response suggests reviewing investigation consistency.'
        WHEN sm.priority_level = 'High priority' THEN
            'High statewide reporting intensity indicates sustained bullying patterns requiring continued prevention and monitoring.'
        WHEN sm.priority_level = 'Medium priority' THEN
            'Moderate reporting activity observed. Continue monitoring districts with recurring incidents while supporting preventative programs.'
        ELSE
            'Routine monitoring is currently appropriate while continuing annual prevention and reporting initiatives.'
    END AS overall_assessment,
    CASE
        WHEN sm.state_rank <= 5 THEN
            'Prioritize statewide prevention initiatives, identify districts contributing most to reporting volume, and review investigation consistency.'
        WHEN sm.state_rank <= 10 THEN
            'Maintain statewide prevention focus, compare district-level patterns, and monitor response consistency.'
        WHEN sm.state_rank <= 20 THEN
            'Continue district-level monitoring and target prevention resources toward recurring reporting patterns.'
        WHEN sm.discipline_to_allegation_ratio < 0.60 THEN
            'Review disciplinary consistency and investigation practices across districts with elevated reporting.'
        WHEN sm.priority_level = 'Medium priority' THEN
            'Target prevention resources toward districts with sustained reporting while monitoring annual trends.'
        ELSE
            'Maintain routine monitoring and continue supporting accurate reporting practices.'
    END
    ||
    ' '
    ||
    CASE
        WHEN r.protected_category = 'Sex'
            THEN 'Strengthen sex-based harassment prevention, reporting channels, and response consistency.'
        WHEN r.protected_category = 'Race'
            THEN 'Prioritize anti-bias initiatives and review districts with repeated race-based harassment.'
        WHEN r.protected_category = 'Sexual Orientation'
            THEN 'Expand LGBTQ+ student support and strengthen inclusive school climate practices.'
        WHEN r.protected_category = 'Disability'
            THEN 'Review IDEA and Section 504 safeguards while ensuring reporting accessibility.'
        WHEN r.protected_category = 'Religion'
            THEN 'Review religion-based incidents, validate reporting completeness, and strengthen inclusion initiatives.'
        ELSE
            'Continue monitoring reporting trends.'
    END AS category_action_item,
    CASE
        WHEN sm.state_rank <= 5 THEN '🚨 National hotspot. '
        WHEN sm.state_rank <= 10 THEN '⚠️ High national concern. '
        WHEN sm.state_rank <= 20 THEN '📊 Elevated reporting. '
        ELSE '✅ Routine monitoring. '
    END
    ||
    CASE
        WHEN r.protected_category = 'Sex'
            THEN 'Focus: Sex-based harassment.'
        WHEN r.protected_category = 'Race'
            THEN 'Focus: Race-based harassment.'
        WHEN r.protected_category = 'Sexual Orientation'
            THEN 'Focus: Sexual orientation harassment.'
        WHEN r.protected_category = 'Disability'
            THEN 'Focus: Disability-related harassment.'
        WHEN r.protected_category = 'Religion'
            THEN 'Focus: Religion-based harassment.'
        ELSE
            'Continue monitoring.'
    END AS category_action_summary,
    CONCAT(
        CASE
            WHEN r.category_rank = 1 THEN '🥇 '
            WHEN r.category_rank = 2 THEN '🥈 '
            WHEN r.category_rank = 3 THEN '🥉 '
        END,
        r.protected_category,
        ' | ',
        TO_CHAR(r.category_allegations, 'FM999,999,999'),
        ' reports | ',
        CASE
            WHEN sm.state_rank <= 5 THEN '🚨 National hotspot: '
            WHEN sm.state_rank <= 10 THEN '⚠️ High national concern: '
            WHEN sm.state_rank <= 20 THEN '📊 Elevated reporting: '
            ELSE ''
        END,
        CASE
            WHEN r.protected_category = 'Sex'
                THEN 'Strengthen prevention, reporting channels, and response consistency.'
            WHEN r.protected_category = 'Race'
                THEN 'Prioritize anti-bias prevention and district equity review.'
            WHEN r.protected_category = 'Sexual Orientation'
                THEN 'Strengthen inclusive climate practices and LGBTQ+ student support.'
            WHEN r.protected_category = 'Disability'
                THEN 'Review IDEA and Section 504 safeguards and reporting accessibility.'
            WHEN r.protected_category = 'Religion'
                THEN 'Validate reporting completeness and review inclusion initiatives.'
            ELSE
                'Continue monitoring.'
        END
    ) AS category_summary
FROM ranked r
LEFT JOIN state_metrics sm
    ON r.state = sm.state
WHERE r.category_rank <= 3
ORDER BY
    state_sort_score DESC,
    r.state,
    r.category_rank;


---- Validation ----
SELECT *
FROM s_yoldaserdem.vw_state_action_matrix
ORDER BY state_sort_score DESC, state, category_rank
LIMIT 30;

-- ============================================================
-- CRDC BULLYING DASHBOARD
-- View: vw_school_hotspot_matrix
-- ============================================================
-- Purpose:
-- Creates a school-level protected-category matrix for Tableau.
--
-- Grain:
-- One row per school and protected harassment category.
--
-- Intended visualization:
-- School Reporting Hotspots Heatmap
--
-- Tableau structure:
-- Rows:
--   State
--   District ID
--   School Label
--
-- Columns:
--   Protected Category
--
-- Color / Text:
--   Category Allegations
--
-- Recommended filters:
--   State
--   District ID
--   School Label
--   Protected Category
--   State Priority Level
--
-- Important methodology note:
-- At state level, Normalized Reporting Rate is calculated as:
-- Total Main Allegations / School Records.
--
-- At school level, each row already represents one school.
-- Therefore:
-- School Allegations / 1 = School Total Allegations.
--
-- No new school normalization KPI is introduced.
-- ============================================================

CREATE OR REPLACE VIEW s_yoldaserdem.vw_school_hotspot_matrix AS
WITH school_base AS (
    SELECT
        state,
        district_id,
        school_key,
        juvenile_justice_school,

        -- Creates a readable identifier when no school-name field
        -- is available in the cleaned dataset.
        CONCAT(
            state,
            ' | District ',
            district_id,
            ' | School ',
            school_key
        ) AS school_label,
        COALESCE(allegation_sex, 0) AS allegation_sex,
        COALESCE(allegation_race, 0) AS allegation_race,
        COALESCE(allegation_orientation, 0) AS allegation_orientation,
        COALESCE(allegation_disability, 0) AS allegation_disability,
        COALESCE(allegation_religion, 0) AS allegation_religion,
        COALESCE(allegation_sex, 0)
        + COALESCE(allegation_race, 0)
        + COALESCE(allegation_orientation, 0)
        + COALESCE(allegation_disability, 0)
        + COALESCE(allegation_religion, 0)
            AS total_main_allegations,
        COALESCE(total_reported_sex_male, 0)
        + COALESCE(total_reported_sex_female, 0)
        + COALESCE(total_reported_race_male, 0)
        + COALESCE(total_reported_race_female, 0)
        + COALESCE(total_reported_disability_male, 0)
        + COALESCE(total_reported_disability_female, 0)
            AS students_reported_as_affected,
        COALESCE(total_disciplined_sex_male, 0)
        + COALESCE(total_disciplined_sex_female, 0)
        + COALESCE(total_disciplined_race_male, 0)
        + COALESCE(total_disciplined_race_female, 0)
        + COALESCE(total_disciplined_disability_male, 0)
        + COALESCE(total_disciplined_disability_female, 0)
            AS students_disciplined
    FROM s_yoldaserdem.crdc_bullying_clean
),
school_metrics AS (
    SELECT
        state,
        district_id,
        school_key,
        school_label,
        juvenile_justice_school,
        total_main_allegations,
        -- At school grain this is mathematically identical
        -- to Total Main Allegations because the denominator is one school.
        total_main_allegations::NUMERIC
            AS school_reporting_rate,
        students_reported_as_affected,
        students_disciplined,
        ROUND(
            students_disciplined::NUMERIC
            / NULLIF(total_main_allegations, 0),
            3
        ) AS discipline_to_allegation_ratio,
        allegation_sex,
        allegation_race,
        allegation_orientation,
        allegation_disability,
        allegation_religion
    FROM school_base
),
category_long AS (
    SELECT
        sm.state,
        sm.district_id,
        sm.school_key,
        sm.school_label,
        sm.juvenile_justice_school,
        sm.total_main_allegations,
        sm.school_reporting_rate,
        sm.students_reported_as_affected,
        sm.students_disciplined,
        sm.discipline_to_allegation_ratio,
        category_values.protected_category,
        category_values.category_allegations
    FROM school_metrics sm
    CROSS JOIN LATERAL (
        VALUES
            ('Sex', sm.allegation_sex),
            ('Race', sm.allegation_race),
            ('Sexual Orientation', sm.allegation_orientation),
            ('Disability', sm.allegation_disability),
            ('Religion', sm.allegation_religion)
    ) AS category_values (
        protected_category,
        category_allegations
    )
),
ranked_categories AS (
    SELECT
        cl.*,
        ROW_NUMBER() OVER (
            PARTITION BY
                cl.state,
                cl.district_id,
                cl.school_key
            ORDER BY
                cl.category_allegations DESC,
                cl.protected_category
        ) AS category_rank,

        SUM(cl.category_allegations) OVER (
            PARTITION BY
                cl.state,
                cl.district_id,
                cl.school_key
        ) AS school_category_total
    FROM category_long cl
),
state_context AS (
    SELECT
        state,
        allegations_per_school
            AS state_normalized_reporting_rate,
        priority_level
            AS state_priority_level,
        suggested_action
            AS state_suggested_action
    FROM s_yoldaserdem.vw_state_summary
)
SELECT
    rc.state,
    rc.district_id,
    rc.school_key,
    rc.school_label,
    rc.juvenile_justice_school,
    -- Useful filters
    rc.state AS state_filter_value,
    rc.district_id AS district_filter_value,
    rc.school_label AS school_filter_value,
    rc.protected_category,
    rc.category_allegations,
    rc.category_rank,
CASE
    WHEN rc.total_main_allegations = 0
        THEN 'No reported allegations'
    WHEN rc.category_rank = 1
        THEN '🥇 Primary issue'
    WHEN rc.category_rank = 2
        THEN '🥈 Secondary issue'
    WHEN rc.category_rank = 3
        THEN '🥉 Third issue'
    WHEN rc.category_rank = 4
        THEN 'Fourth issue'
    ELSE
        'Fifth issue'
END AS issue_rank_label,
    rc.total_main_allegations,
    rc.school_reporting_rate,
    rc.students_reported_as_affected,
    rc.students_disciplined,
    rc.discipline_to_allegation_ratio,
    sc.state_normalized_reporting_rate,
    sc.state_priority_level,
    sc.state_suggested_action,
    ROUND(
     	  rc.category_allegations::NUMERIC
        * 100
        / NULLIF(rc.school_category_total, 0),
        2
    ) AS category_share_pct,
    CASE
        WHEN rc.protected_category = 'Sex'
            THEN 'Review sex-based harassment prevention, reporting channels, and response consistency.'
        WHEN rc.protected_category = 'Race'
            THEN 'Review race-based harassment patterns and strengthen targeted anti-bias prevention.'
        WHEN rc.protected_category = 'Sexual Orientation'
            THEN 'Review inclusive climate practices, safe reporting channels, and LGBTQ+ student support.'
        WHEN rc.protected_category = 'Disability'
            THEN 'Review IDEA and Section 504 safeguards and ensure reporting processes are accessible.'
        WHEN rc.protected_category = 'Religion'
            THEN 'Review religion-based incidents, reporting completeness, and inclusion initiatives.'
        ELSE 'Continue monitoring reporting patterns.'
    END AS category_action_item,
    CONCAT(
        CASE
        WHEN rc.total_main_allegations = 0
            THEN ''
        WHEN rc.category_rank = 1 THEN '🥇 '
        WHEN rc.category_rank = 2 THEN '🥈 '
        WHEN rc.category_rank = 3 THEN '🥉 '
        WHEN rc.category_rank = 4 THEN '4. '
        WHEN rc.category_rank = 5 THEN '5. '
    ELSE ''
        END,
        rc.protected_category,
        ' | ',
        TO_CHAR(
            rc.category_allegations,
            'FM999,999,999'
        ),
        ' reports'
    ) AS school_matrix_text
FROM ranked_categories rc
LEFT JOIN state_context sc
    ON rc.state = sc.state;


    ------
    -- General output check
SELECT *
FROM s_yoldaserdem.vw_school_hotspot_matrix
LIMIT 50;

----

-- Check row grain:
-- each school should normally have five category rows
SELECT
    state,
    district_id,
    school_key,
    COUNT(*) AS category_rows
FROM s_yoldaserdem.vw_school_hotspot_matrix
GROUP BY
    state,
    district_id,
    school_key
HAVING COUNT(*) <> 5;

------ Inspect schools with the highest total allegation count
SELECT DISTINCT
    state,
    district_id,
    school_key,
    school_label,
    total_main_allegations,
    students_reported_as_affected,
    students_disciplined,
    discipline_to_allegation_ratio,
    state_priority_level
FROM s_yoldaserdem.vw_school_hotspot_matrix
ORDER BY total_main_allegations DESC
LIMIT 30;