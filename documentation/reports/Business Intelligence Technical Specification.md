# 📊 CRDC School Bullying Analysis

# Business Intelligence Framework, KPI Documentation & Technical Specification

> **Version:** 2.0

> **Dataset:** Civil Rights Data Collection (CRDC) 2021–2022

> **Author:** Yoldas Erdem

> **Project:** Data Analytics & AI Bootcamp – Executive Business Intelligence Dashboard

---

# 📑 Table of Contents

- [1. Project Overview](#1-project-overview)

- [2. Business Intelligence Architecture](#2-business-intelligence-architecture)

- [3. Dataset Overview](#3-dataset-overview)

- [4. KPI Framework](#4-kpi-framework)

- [5. Raw Business KPIs](#5-raw-business-kpis)

- [6. Normalized KPIs](#6-normalized-kpis)

- [7. Business Classifications](#7-business-classifications)

- [8. National Ranking Framework](#8-national-ranking-framework)

- [9. Recommendation Engine](#9-recommendation-engine)

- [10. SQL Business Views](#10-sql-business-views)

- [11. SQL Calculated Fields](#11-sql-calculated-fields)

- [12. Tableau Parameters](#12-tableau-parameters)

- [13. Tableau Calculated Fields](#13-tableau-calculated-fields)

- [14. Dashboard Sorting Logic](#14-dashboard-sorting-logic)

- [15. Dashboard Overview](#15-dashboard-overview)

- [16. Business Rules & Thresholds](#16-business-rules--thresholds)

- [17. Interpretation Guidelines](#17-interpretation-guidelines)

- [18. Data Limitations](#18-data-limitations)

- [19. Data Flow](#19-data-flow)

- [20. Formula Reference](#20-formula-reference)

---

# 1. Project Overview

## Purpose

This project transforms the **CRDC 2021–2022 School Bullying dataset** into an interactive Business Intelligence solution designed for executive decision-making.

Rather than presenting descriptive statistics alone, the project introduces a complete analytical framework consisting of:

- Business KPIs

- Normalized performance metrics

- Executive priority classifications

- National ranking methodology

- Rule-based recommendation engine

- Interactive Tableau dashboards

The overall objective is to enable policymakers, education departments and decision-makers to identify reporting patterns, prioritize intervention efforts and compare jurisdictions fairly regardless of their size.

---

# 2. Business Intelligence Architecture

The project follows a layered Business Intelligence architecture.

```text

CRDC Dataset

      │

      ▼

SQL Data Cleaning

      │

      ▼

Business Views

(vw_state_summary

vw_demographic_summary

vw_category_summary

vw_state_action_matrix)

      │

      ▼

Tableau

      │

      ▼

Parameters

Calculated Fields

Interactive Dashboards

      │

      ▼

Executive Decision Support

```

Each layer has a clearly defined responsibility:

| Layer | Purpose |

|--------|----------|

| Raw Dataset | Original CRDC school records |

| SQL Cleaning | Standardizes and prepares data |

| SQL Business Views | Generates reusable business metrics |

| Tableau | Visualization and interaction |

| Recommendation Engine | Converts metrics into executive guidance |

---

# 3. Dataset Overview

The analysis is based on the **Civil Rights Data Collection (CRDC) 2021–2022** dataset.

The project focuses on five federally protected bullying categories:

- Sex

- Race

- Sexual Orientation

- Disability

- Religion

The CRDC contains **administrative school-level reporting** rather than individual incident records.

---

# 4. KPI Framework

The analytical framework follows a layered approach.

```

Raw Measures

      │

      ▼

Normalized KPIs

      │

      ▼

Business Rules

      │

      ▼

Priority Classification

      │

      ▼

Recommendation Engine

      │

      ▼

Interactive Dashboards

```

This progression transforms administrative reporting data into executive decision-support information.

---

# 5. Raw Business KPIs

Raw KPIs represent direct administrative counts reported by schools.

| KPI | Formula | Business Meaning | Used In |

|------|----------|-----------------|----------|

| 📄 Total Main Allegations | Sex + Race + Sexual Orientation + Disability + Religion | Total reported bullying allegations | Executive Dashboard |

| 👥 Students Reported as Affected | Sum of reported demographic counts | Students reported as affected | Demographic Dashboard |

| ⚖ Students Disciplined | Sum of disciplined students | Reported disciplinary actions | Executive Dashboard |

| 🏫 Schools With Allegations | Schools reporting at least one allegation | Geographic reporting coverage | State Dashboard |

---

# 6. Normalized KPIs

Raw totals naturally favor larger jurisdictions.

To improve comparability, several normalized metrics were created.

| KPI | Formula | Business Purpose |

|------|----------|-----------------|

| 📊 Normalized Reporting Rate | Total Main Allegations ÷ Schools With Allegations | Primary state comparison metric |

| 🏫 Reporting Coverage (%) | Schools With Allegations ÷ Total Schools ×100 | Measures reporting penetration |

| 📈 Allegation Share (%) | Category Allegations ÷ Total Allegations ×100 | Category contribution |

| ⚖ Discipline-to-Allegation Ratio | Students Disciplined ÷ Total Main Allegations | Operational comparison metric |

---

# 7. Business Classifications

To simplify executive interpretation, states are grouped into three priority levels.

| Priority Level | Description |

|----------------|-------------|

| 🔴 High Priority | Highest reporting intensity requiring executive attention |

| 🟠 Medium Priority | Moderate reporting intensity requiring targeted monitoring |

| 🔵 Routine Monitoring | Lower reporting intensity requiring standard oversight |

These classifications are generated automatically in SQL and reused throughout Tableau.

---

# 8. National Ranking Framework

Each state receives a national rank based on its **Normalized Reporting Rate**.

An alternative dashboard ranking based on **Total Main Allegations** is also available through a Tableau parameter.

National reporting tiers are assigned using the following business rules:

| National Rank | Executive Tier |

|---------------|----------------|

| 🥇 Top 5 | National Hotspot |

| 🥈 Top 10 | High National Concern |

| 🥉 Top 20 | Elevated Reporting |

| ✅ Remaining States | Maintain Monitoring |

These tiers provide additional executive context beyond the Priority Level classification.

---

# 9. Recommendation Engine

One of the project's key features is the SQL-based Recommendation Engine.

Instead of displaying generic comments, recommendations are generated dynamically using multiple business rules.

The engine combines:

- Priority Level

- National Rank

- Protected Category

- Discipline-to-Allegation Ratio

- Reporting Intensity

- Schools Reporting Allegations

Example rule hierarchy:

| Business Rule | Recommendation |

|---------------|---------------|

| Top 5 nationally | National Hotspot |

| Top 10 nationally | High National Concern |

| Top 20 nationally | Elevated Reporting |

| Discipline Ratio < 0.60 | Review investigation consistency |

| Sex category | Improve reporting channels |

| Race category | Expand anti-bias initiatives |

| Sexual Orientation | Strengthen LGBTQ+ support |

| Disability | Review IDEA & Section 504 safeguards |

| Religion | Validate reporting consistency |

These recommendations populate the **Overall Assessment**, **Category Action Item**, **Category Summary**, and **Action Matrix** fields displayed in Tableau.

---

# 10. SQL Business Views

The analytical model is built using several SQL business views.

| SQL View | Purpose |

|----------|----------|

| vw_state_summary | Generates state-level KPIs |

| vw_category_summary | Aggregates protected category statistics |

| vw_demographic_summary | Creates demographic analysis tables |

| vw_state_action_matrix | Generates executive recommendation engine |

These views provide reusable business logic and ensure consistency across dashboards.

---

# 11. SQL Calculated Fields

Several calculated fields were created within SQL to support executive analysis.

| Field | Purpose |

|--------|----------|

| normalized_reporting_rate | Primary comparison metric |

| priority_level | Executive classification |

| priority_score | Internal ranking value |

| state_rank | National state ranking |

| national_reporting_tier | Top 5 / Top 10 / Top 20 classification |

| state_sort_score | Dynamic dashboard sorting |

| overall_assessment | Executive narrative |

| category_action_item | Recommendation engine output |

| category_action_summary | Short recommendation |

| action_matrix_text | Final text displayed in Tableau |

---

# 12. Tableau Parameters

Interactive dashboard behavior is controlled using Tableau parameters.

| Parameter | Options | Purpose |

|-----------|----------|----------|

| 📊 State Ranking | Highest Reporting Rate / Highest Total Impact | Changes ranking methodology |

| 🏫 State Filter | Individual States | Filters dashboard |

| 🎯 Priority Level | High / Medium / Routine | Executive filtering |

| 📚 Harassment Category | Five protected categories | Heatmap comparison |

---

# 13. Tableau Calculated Fields

Tableau calculations extend SQL functionality by enabling dynamic interaction.

| Calculated Field | Purpose |

|------------------|----------|

| State Sort | Dynamic ranking based on parameter selection |

| Tooltip Labels | Dynamic executive descriptions |

| Display Labels | Improves dashboard readability |

---

# 14. Dashboard Sorting Logic

Each dashboard uses a predefined business sorting methodology.

| Dashboard | Sorted By |

|------------|-----------|

| State Ranking | Normalized Reporting Rate |

| High Priority States | Normalized Reporting Rate |

| State Priority Matrix | Dynamic Parameter |

| Schools Reporting | Schools With Allegations |

| Students Affected | Students Reported as Affected |

| Category Breakdown | Total Allegations |

| Demographic Heatmap | Students Reported as Affected |

---

# 15. Dashboard Overview

| Dashboard | Purpose |

|------------|----------|

| Executive Overview | National comparison |

| Geographic Map | Geographic reporting patterns |

| Category Breakdown | Protected category comparison |

| Students Affected | Demographic analysis |

| Schools Reporting | Reporting coverage |

| High Priority States | Executive prioritization |

| State Priority Matrix | Recommendation engine |

| Demographic Heatmap | Detailed subgroup comparison |

---

# 16. Business Rules & Thresholds

The project incorporates several rule-based thresholds.

| Rule | Threshold | Purpose |

|------|-----------|----------|

| National Hotspot | Top 5 | Immediate attention |

| High National Concern | Top 10 | Increased monitoring |

| Elevated Reporting | Top 20 | Targeted intervention |

| Investigation Review | Discipline Ratio < 0.60 | Review investigation consistency |

| Executive Priority | SQL Classification | Dashboard filtering |

These thresholds provide consistent interpretation across all dashboards.

---

# 17. Interpretation Guidelines

Several important considerations apply when interpreting the dashboards.

> **Higher reporting does not necessarily indicate poorer school climate.**

Higher reporting may reflect:

- Better reporting systems

- Stronger documentation

- Greater awareness

- Improved compliance

Similarly:

- Correlation does not imply causation.

- Rankings are comparative rather than evaluative.

- Administrative reporting should not be interpreted as incident prevalence.

The Discipline-to-Allegation Ratio compares two independent administrative measures and should not be interpreted as a success rate or investigation outcome.

---

# 18. Data Limitations

The CRDC dataset does **not** contain:

- Individual incident records

- Individual student histories

- Verified victim-offender relationships

- Investigation outcomes

- School climate surveys

- Causal evidence

Accordingly, all findings should be interpreted as descriptive administrative reporting rather than causal analysis.

---

# 19. Data Flow

```text

CRDC Dataset

      │

      ▼

SQL Cleaning

      │

      ▼

Business Views

      │

      ▼

Calculated KPIs

      │

      ▼

Priority Classification

      │

      ▼

Recommendation Engine

      │

      ▼

Tableau Parameters

      │

      ▼

Interactive Dashboards

      │

      ▼

Executive Decision Support

```

---

# 20. Formula Reference

| Metric | Formula |

|---------|----------|

| Total Main Allegations | Sex + Race + Sexual Orientation + Disability + Religion |

| Normalized Reporting Rate | Total Main Allegations ÷ Schools With Allegations |

| Reporting Coverage (%) | Schools With Allegations ÷ Total Schools ×100 |

| Allegation Share (%) | Category Allegations ÷ Total Main Allegations ×100 |

| Discipline-to-Allegation Ratio | Students Disciplined ÷ Total Main Allegations |

| State Rank | DENSE_RANK() OVER (ORDER BY Normalized Reporting Rate DESC) |

| National Reporting Tier | Top 5 / Top 10 / Top 20 |

| Priority Score | High = 3, Medium = 2, Routine = 1 |

| State Sort Score | (Priority Score × 1,000,000) + Normalized Reporting Rate |

---

# 📌 Executive Summary

This project extends beyond descriptive reporting by combining **SQL business logic**, **normalized KPIs**, **national ranking**, **priority classifications**, **dynamic recommendations**, **Tableau parameters**, and **interactive dashboards** into a unified Business Intelligence solution.

The Recommendation Engine integrates reporting intensity, national ranking, discipline ratio, reporting coverage, and protected-category patterns to generate contextual, evidence-informed recommendations. Together, these components transform administrative CRDC reporting into an executive decision-support framework suitable for interactive business intelligence, comparative analysis, and policy planning.
