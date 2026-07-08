# Executive Findings

## Project Overview

This project analyzes the 2021–22 Civil Rights Data Collection (CRDC) Harassment and Bullying dataset published by the U.S. Department of Education.

The objective is to identify patterns in reported bullying allegations, understand demographic and geographic differences, evaluate disciplinary responses, and provide data-driven recommendations for educational stakeholders.

---

# Dataset Summary

| Metric                   |  Value |
| ------------------------ | -----: |
| School Records           | 98,010 |
| Variables                |    159 |
| Jurisdictions            |     52 |
| School Districts         | 17,704 |
| Juvenile Justice Schools |    882 |

---

# Data Quality Assessment

The cleaned analytical dataset was successfully produced through the ETL pipeline.

Key validation results:

- No duplicate records detected.
- Metadata fields are complete.
- CRDC reserve codes were converted into NULL values.
- Missing values remain below 7% for every variable.
- Dataset is suitable for analytical reporting.

---

# Key Findings

## 1. Bullying allegations are concentrated

Approximately 24% of schools reported at least one bullying allegation, while nearly 76% reported none during the reporting period.

This indicates that reported bullying is concentrated among a relatively small subset of schools.

---

## 2. Sex-based allegations are most common

Among all reported allegation categories:

1. Sex
2. Race
3. Sexual Orientation
4. Disability
5. Religion

Sex-based allegations account for the largest share of reported incidents.

---

## 3. Geographic variation exists

Reported allegation counts differ substantially across jurisdictions.

Even after normalizing by reporting schools, several states continue to report consistently higher allegation rates, suggesting regional variation in reporting patterns.

---

## 4. Student demographics differ

Female students appear more frequently among reported affected students.

Male students appear substantially more often among disciplinary records.

These observations describe aggregate reporting patterns and should not be interpreted as individual-level outcomes.

---

## 5. Allegations and disciplinary actions differ

The relationship between allegations and disciplinary actions varies across jurisdictions.

This suggests that disciplinary responses may differ between school systems and should be interpreted alongside local reporting practices.

---

# Key Analytical Questions

The exploratory and SQL analyses highlight several questions that merit further investigation:

- Why do some jurisdictions report substantially higher allegation rates than others?
- Which factors contribute to exceptionally high allegation counts in certain school districts?
- Why do reported disciplinary outcomes vary across jurisdictions?
- Are certain categories of harassment reported more consistently across specific regions?
- How do patterns differ for allegations based on sex, race, disability, religion, and sexual orientation?

---

# Recommendations

Based on the exploratory and SQL analyses, several recommendations emerge.

### Policy

- Review reporting practices across jurisdictions.
- Encourage standardized bullying documentation.

### Prevention

- Prioritize schools with consistently high allegation rates.
- Expand prevention initiatives for the most common allegation categories.

### Monitoring

- Develop dashboards for ongoing monitoring.
- Track allegation trends over time.
- Identify districts requiring additional support.

---

# Next Phase

The analytical findings from this report provide the foundation for the interactive Tableau dashboards.

The dashboards will transform these statistical findings into visual tools that support exploration, comparison, and evidence-based decision making.
