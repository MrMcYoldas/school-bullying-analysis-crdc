# School Bullying Analysis

# KPI Definitions & Business Rules

Version: 2.0  
Dataset: CRDC 2021–2022 (U.S. Department of Education)  
Author: Yoldas Erdem

---

# Purpose

This document defines every KPI, calculated field, threshold, business rule, and recommendation used throughout the School Bullying Analysis project.

It serves as the technical reference for:

- SQL Views
- Tableau Dashboards
- Business Logic
- Recommendation Engine
- Executive Reporting

All calculations are based on the cleaned CRDC 2021–2022 dataset unless otherwise specified.

---

# Analytical Framework

The project follows a layered analytical approach.

Raw Data

↓

Aggregated Metrics

↓

Normalized KPIs

↓

Priority Classification

↓

Recommendation Engine

↓

Executive Dashboard

This approach transforms descriptive educational data into decision-support metrics suitable for interactive business intelligence dashboards.

---

# Core KPIs

## 1. Total Main Allegations

### Formula

Sex

- Race
- Sexual Orientation
- Disability
- Religion

### Business Meaning

Represents the total number of reported bullying and harassment allegations across all federally protected categories.

### Interpretation

Higher values indicate more reported incidents but should **not** automatically be interpreted as poorer school climate.

Reporting practices differ between jurisdictions.

---

## 2. Students Reported as Affected

### Formula

Sum of all reported student counts across available demographic groups.

### Business Meaning

Represents students reported by schools as affected by bullying or harassment.

### Important Note

Students may appear in multiple reporting categories.

The dataset does not represent unique victim records.

---

## 3. Students Disciplined

### Formula

Sum of all reported disciplinary actions.

### Business Meaning

Measures disciplinary responses associated with bullying incidents.

### Interpretation

The dataset does not link disciplinary actions to specific incidents or individual perpetrators.

---

## 4. Schools With Allegations

### Formula

Count of schools reporting at least one allegation.

### Business Meaning

Measures how widespread bullying reporting is across schools.

### Interpretation

Schools reporting zero allegations are **not necessarily bullying-free**.

Differences in reporting practices should always be considered.

---

# Normalized KPIs

Normalization allows fair comparison between jurisdictions of different sizes.

---

## 5. Normalized Reporting Rate (Primary KPI)

### Formula

Total Main Allegations

÷

Number of School Records

### SQL

```
allegations_per_school
```

### Tableau Name

Normalized Reporting Rate

### Purpose

Primary ranking metric throughout the dashboard.

Used instead of raw totals when comparing states.

### Interpretation

Higher values indicate greater reporting intensity per school.

---

## 6. Schools Reporting Allegations (%)

### Formula

Schools With Allegations

÷

Total School Records

×

100

### Purpose

Measures reporting coverage across schools.

### Interpretation

Higher percentages indicate more schools submitted at least one allegation.

---

## 7. Allegation Share (%)

### Formula

Category Allegations

÷

Total Main Allegations

×

100

### Purpose

Measures the contribution of each protected category to overall reported bullying.

Used primarily in category comparisons.

---

## 8. Discipline-to-Allegation Ratio

### Formula

Students Disciplined

÷

Total Main Allegations

### Purpose

Compares disciplinary responses to reported allegations.

### Important

This **is not** a success rate.

It simply compares two administrative reporting metrics.

---

# Executive Classifications

Several business classifications were created specifically for executive dashboards.

---

## Priority Level

Determined from the SQL summary view.

Possible values:

- High Priority
- Medium Priority
- Routine Monitoring

Purpose:

Allows dashboard filtering and executive prioritization.

---

## State Rank

### Formula

Dense Rank

ordered by

Normalized Reporting Rate DESC

### SQL

```
DENSE_RANK() OVER (
ORDER BY allegations_per_school DESC
)
```

Purpose:

Ranks every U.S. state by reporting intensity.

---

## National Reporting Tier

Derived from State Rank.

| Rank      | Classification        |
| --------- | --------------------- |
| Top 5     | National Hotspot      |
| Top 10    | High National Concern |
| Top 20    | Elevated Reporting    |
| Remaining | Maintain Monitoring   |

Purpose

Provides an executive-level interpretation of reporting intensity.

---

# Recommendation Engine

The recommendation engine combines multiple KPIs to generate dynamic business recommendations.

Unlike static recommendations, recommendations vary depending on both statewide reporting patterns and protected category.

---

## Rule 1

IF

State Rank ≤ 5

THEN

National Hotspot

Recommendation:

Immediate statewide attention.

Review prevention strategy.

Identify highest contributing districts.

---

## Rule 2

IF

State Rank ≤ 10

THEN

High National Concern

Recommendation

Continue targeted prevention and annual monitoring.

---

## Rule 3

IF

State Rank ≤ 20

THEN

Elevated Reporting

Recommendation

Focus resources on recurring districts.

---

## Rule 4

IF

Discipline-to-Allegation Ratio

<

0.60

Recommendation

Review:

- Investigation consistency
- Disciplinary practices
- Reporting accessibility

Purpose

May indicate comparatively fewer disciplinary responses relative to reported allegations.

---

## Rule 5

IF

Schools With Allegations

>

3,000

Recommendation

Statewide prevention campaign

District-level monitoring

Reason

Incidents are distributed across a large number of schools.

---

# Category-Specific Recommendations

## Sex

Strengthen reporting channels.

Review response consistency.

Expand prevention education.

---

## Race

Prioritize anti-bias initiatives.

Review district equity patterns.

Identify recurring schools.

---

## Sexual Orientation

Expand LGBTQ+ student support.

Strengthen inclusive school climate.

Improve reporting accessibility.

---

## Disability

Review IDEA implementation.

Review Section 504 safeguards.

Improve accessibility.

---

## Religion

Strengthen inclusion initiatives.

Validate reporting completeness.

Review cultural awareness programs.

---

# Tableau Calculated Fields

The following calculated fields were introduced during dashboard development.

## State Rank

Dense Rank from SQL.

---

## National Reporting Tier

Top 5

Top 10

Top 20

Remaining

---

## Overall Assessment

Executive narrative generated from:

- Priority Level
- State Rank
- Discipline Ratio
- Reporting Intensity

---

## Category Action Item

Dynamic recommendation combining:

- State classification
- Protected category

---

## Category Action Summary

Short executive summary displayed inside the Action Matrix.

---

## Action Matrix Text

Formatted display field combining

- Medal icon
- Category
- Allegation count
- Executive recommendation

Example

🥇 Sex

7,253 reports

National Hotspot

Strengthen prevention and reporting consistency.

---

## State Priority Summary

Example

California

High Priority

Rank #8

2.94 reports per school

---

## State Focus Label

Example

California

High Priority

---

# Dashboard Sorting Logic

Most dashboards use the

Normalized Reporting Rate

as the primary ranking metric.

However, the State Priority Action Matrix includes a parameter allowing two ranking methods.

---

## Tableau Parameter

State Ranking

Values

Highest Reporting Rate

Highest Total Impact

---

## Sorting Logic

Highest Reporting Rate

↓

Normalized Reporting Rate

Highest Total Impact

↓

Total Main Allegations

This allows users to compare either:

Reporting intensity

or

Overall incident volume.

---

# Dashboard Filters

Common dashboard filters include:

Priority Level

Protected Category

State

State Ranking Parameter

National Reporting Tier

Issue Rank

---

# Interpretation Guidelines

The CRDC dataset contains administrative reporting data.

It does **not** contain:

- Individual incidents
- Victim histories
- Offender histories
- Investigation outcomes
- Cause-and-effect relationships

Therefore:

✔ Correlation does not imply causation.

✔ Higher reporting does not necessarily indicate poorer school climate.

✔ Higher disciplinary counts do not identify perpetrators.

✔ Larger states naturally report more incidents.

✔ Normalized KPIs should always be interpreted alongside raw totals.

---

# Current SQL Views

Current project SQL views include:

- vw_state_summary
- vw_state_action_matrix
- vw_category_summary
- vw_demographic_summary

Additional school-level recommendation views may be introduced in future iterations.

---

# Future Enhancements

Planned improvements include:

- School-level Recommendation Engine
- District-level Executive Dashboard
- School Priority Ranking
- District Risk Scoring
- State → School Drill-down Navigation
- Automated Recommendation Rules
- Predictive Reporting Models

---

# Version History

| Version | Description                                                                                                                                                                              |
| ------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1.0     | Initial KPI Definitions                                                                                                                                                                  |
| 2.0     | Added normalized KPIs, recommendation engine, national reporting tiers, executive classifications, SQL documentation, Tableau calculations, sorting logic, and dashboard business rules. |
