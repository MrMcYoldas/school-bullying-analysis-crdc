# 📊 School Bullying Analysis

## Business Intelligence Technical Specification

### KPI Dictionary • Business Rules • Recommendation Engine • Dashboard Documentation

---

Version: 2.0

Dataset:
CRDC 2021–2022
(U.S. Department of Education)

Author:
Yoldas Erdem

Last Updated:
July 2026

---

# 📑 Table of Contents

1. Executive Summary
2. Project Architecture
3. Data Sources
4. Data Model
5. Analytical Workflow
6. Core KPIs
7. Normalized KPIs
8. Business Rules
9. Executive Classifications
10. Recommendation Engine
11. Tableau Dashboard Logic
12. Dashboard-by-Dashboard Documentation
13. SQL Views
14. Tableau Calculated Fields
15. Threshold Register
16. Decision Tree
17. Interpretation Guidelines
18. Known Data Limitations
19. Future Improvements
20. Version History

---

# 1 Executive Summary

## Purpose

The School Bullying Analysis dashboard was developed to transform raw administrative reporting data from the CRDC into an interactive decision-support tool for education leaders.

Instead of simply displaying reported bullying counts, the project combines:

- descriptive statistics
- normalized reporting metrics
- priority classifications
- business rules
- automated recommendation logic

to help identify jurisdictions requiring additional attention.

---

## Analytical Objectives

| Objective               | Description                                                |
| ----------------------- | ---------------------------------------------------------- |
| Compare States          | Compare reporting intensity across jurisdictions           |
| Identify Hotspots       | Detect states with elevated reporting                      |
| Explain Patterns        | Identify the most frequently reported protected categories |
| Prioritize Resources    | Support prevention planning                                |
| Support Decision Making | Generate rule-based recommendations                        |

---

# 2 Project Architecture

```text
CRDC Raw Dataset
        │
        ▼
Data Cleaning
        │
        ▼
SQL Views
        │
        ▼
Normalized KPIs
        │
        ▼
Business Rules
        │
        ▼
Recommendation Engine
        │
        ▼
Interactive Tableau Dashboard
```

---

# 3 Data Sources

| Source               | Description                                         |
| -------------------- | --------------------------------------------------- |
| CRDC 2021–2022       | School Civil Rights Data Collection                 |
| School Records       | Individual schools                                  |
| State                | U.S. State                                          |
| Enrollment           | School enrollment                                   |
| Protected Categories | Sex, Race, Disability, Religion, Sexual Orientation |

---

# 4 Analytical Workflow

```text
Raw Measures
        │
        ▼
Aggregated Metrics
        │
        ▼
Normalized Metrics
        │
        ▼
Priority Classification
        │
        ▼
Recommendation Engine
        │
        ▼
Executive Dashboard
```

Purpose:

Every visualization follows this workflow.

---

# 5 Core KPIs

| KPI                      | Formula             | Business Meaning              | Used In               |
| ------------------------ | ------------------- | ----------------------------- | --------------------- |
| Total Main Allegations   | Sum of 5 categories | Overall reporting volume      | State Summary         |
| Students Affected        | Sum                 | Reported affected students    | Demographic Dashboard |
| Students Disciplined     | Sum                 | Reported disciplinary actions | State Summary         |
| Schools With Allegations | Count               | Reporting coverage            | State Summary         |

...

---

# 6 Normalized KPIs

## Why Normalize?

Large states naturally contain more schools.

Raw counts alone therefore do not provide fair comparisons.

Normalization allows states of different sizes to be compared using reporting intensity rather than reporting volume.

---

| KPI                       | Formula                      | Why It Exists             |
| ------------------------- | ---------------------------- | ------------------------- |
| Normalized Reporting Rate | Allegations ÷ Schools        | Primary comparison metric |
| Allegation Share          | Category ÷ Total Allegations | Category contribution     |
| Reporting Coverage        | Reporting Schools ÷ Schools  | Reporting completeness    |
| Discipline Ratio          | Disciplined ÷ Allegations    | Operational context       |

---

# 7 Business Rules

## Priority Classification

| Condition                    | Priority           |
| ---------------------------- | ------------------ |
| Highest normalized reporting | High Priority      |
| Moderate reporting           | Medium Priority    |
| Remaining                    | Routine Monitoring |

Purpose

Allows dashboards to filter jurisdictions requiring additional attention.

---

# 8 Recommendation Engine

The recommendation engine combines multiple KPIs into contextual recommendations.

Unlike traditional dashboards, recommendations are generated dynamically.

---

## Overall Logic

```text
Reporting Intensity
        │
        ▼
Priority Level
        │
        ▼
National Rank
        │
        ▼
Discipline Ratio
        │
        ▼
Protected Category
        │
        ▼
Final Recommendation
```

---

## Rule Matrix

| Rule      | Threshold             | Recommendation                |
| --------- | --------------------- | ----------------------------- |
| Top 5     | National Hotspot      | Immediate statewide attention |
| Top 10    | High National Concern | Continue targeted monitoring  |
| Top 20    | Elevated Reporting    | Focus prevention resources    |
| Remaining | Monitor               | Routine monitoring            |

---

## Operational Rules

| KPI               | Threshold | Action                |
| ----------------- | --------- | --------------------- |
| Discipline Ratio  | < 0.60    | Review investigations |
| Schools Reporting | >3000     | District review       |
| High Priority     | Yes       | Immediate review      |

---

# 9 Protected Category Logic

| Category           | Recommendation         |
| ------------------ | ---------------------- |
| Sex                | Prevention + Reporting |
| Race               | Equity Review          |
| Sexual Orientation | LGBTQ+ Support         |
| Disability         | IDEA / 504 Review      |
| Religion           | Inclusion Programs     |

---

# 10 SQL Views

| SQL View               | Purpose               |
| ---------------------- | --------------------- |
| vw_state_summary       | Executive KPIs        |
| vw_state_action_matrix | Recommendation engine |
| vw_category_summary    | Protected categories  |
| vw_demographic_summary | Student groups        |

---

# 11 Tableau Dashboards

| Dashboard            | Purpose               | Primary KPI               |
| -------------------- | --------------------- | ------------------------- |
| Reporting Intensity  | State comparison      | Normalized Reporting Rate |
| High Priority States | Executive overview    | Priority Level            |
| Category Breakdown   | Category comparison   | Allegation Share          |
| Action Matrix        | Recommendation Engine | Recommendation Logic      |
| Heatmap              | Demographic analysis  | Students Affected         |

---

# 12 Tableau Parameters

## State Ranking

Purpose

Allows users to switch between two ranking methodologies.

| Option                 | Sort Field                |
| ---------------------- | ------------------------- |
| Highest Reporting Rate | Normalized Reporting Rate |
| Highest Total Impact   | Total Main Allegations    |

---

# 13 Decision Tree

```text
State
 │
 ▼
Priority Level
 │
 ▼
National Rank
 │
 ▼
Discipline Ratio
 │
 ▼
Protected Category
 │
 ▼
Recommendation
```

---

# 14 Threshold Register

| KPI               | Threshold | Why                    |
| ----------------- | --------- | ---------------------- |
| National Hotspot  | Top 5     | Highest reporting      |
| High Concern      | Top 10    | Elevated reporting     |
| Elevated          | Top 20    | Above average          |
| Discipline Ratio  | <0.60     | Operational review     |
| Reporting Schools | >3000     | Statewide distribution |

---

# 15 Dashboard Interpretation

✔ Higher reporting ≠ worse school climate

✔ Correlation ≠ causation

✔ Administrative reporting ≠ individual incidents

✔ Use normalized KPIs before raw totals

✔ Recommendations are decision-support tools

---

# 16 Known Limitations

The CRDC dataset does not contain

- individual incidents
- offender/victim links
- investigation outcomes
- severity scores
- timestamps

Therefore causal conclusions cannot be drawn.

---

# 17 Future Roadmap

Planned enhancements

- School-level Recommendation Engine
- District Dashboard
- School Ranking
- Drill-down Navigation
- Predictive Analytics
- Time Series (future CRDC releases)

---

# 18 Version History

| Version | Changes                                                                            |
| ------- | ---------------------------------------------------------------------------------- |
| 1.0     | Initial KPI documentation                                                          |
| 2.0     | Recommendation Engine, SQL Views, Tableau Logic, Threshold Register, Decision Tree |
