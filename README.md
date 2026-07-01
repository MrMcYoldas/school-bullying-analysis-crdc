# School Bullying Analysis using the CRDC 2021–22 Dataset

## Project Overview

This project analyzes school harassment and bullying incidents across U.S. schools using the **Civil Rights Data Collection (CRDC) 2021–22** published by the **U.S. Department of Education, Office for Civil Rights (OCR)**.

The goal is to identify patterns in reported bullying incidents, compare affected student groups, and examine how schools respond to these incidents using publicly available national education data.

---

## Business Problem

School bullying negatively impacts students' well-being, academic performance, and school climate. Although schools report incidents to the CRDC, it is often difficult to understand national patterns, identify vulnerable student groups, and compare institutional responses across schools.

This project aims to transform raw CRDC data into meaningful insights that support data-driven decision making.

---

## Project Objectives

- Analyze reported harassment and bullying incidents
- Compare incident rates across schools and states
- Identify demographic groups most frequently affected
- Explore differences in school disciplinary responses
- Build interactive Tableau dashboards to communicate findings

---

## Dataset

**Source:** U.S. Department of Education – Office for Civil Rights (OCR)

**Dataset:** Civil Rights Data Collection (CRDC) 2021–22

**Coverage**

- 98,010 school-year observations
- 159 variables
- All 50 U.S. states + District of Columbia

Each row represents one school for one school year.

The dataset contains:

- School metadata
- Geographic information
- Harassment and bullying allegations
- Reported victim counts
- School disciplinary actions

---

## ETL Pipeline

The raw dataset was processed using Python.

Pipeline steps include:

1. Load the original CRDC dataset
2. Rename technical column names
3. Replace CRDC reserve codes with NULL values
4. Validate the cleaned dataset
5. Export a clean CSV for PostgreSQL and Tableau

---

## Technology Stack

- Python
- Pandas
- PostgreSQL
- DBeaver
- SQL
- Tableau
- Git & GitHub

---

## Project Structure

```
School_Bullying_Capstone/

├── data/
│   ├── raw/
│   └── processed/
│
├── notebooks/
│   ├── 01_Data_Exploration.ipynb
│   └── 02_ETL_Pipeline.ipynb
│
├── sql/
├── tableau/
├── documentation/
├── exports/
└── presentation/
```

---

## Documentation

This repository includes additional project documentation to improve reproducibility and understanding of the dataset.

Available documentation includes:

- **Data Dictionary** – Original CRDC variables, simplified column names, and descriptions.
- **CRDC User Manual** – Official documentation published by the U.S. Department of Education.
- **CRDC Appendix Workbook** – Variable definitions and metadata.
- **ETL Pipeline Notebook** – Complete data cleaning and transformation process.

---

## Current Status

- ✅ Data exploration completed
- ✅ ETL pipeline completed
- ✅ Dataset cleaned and validated
- ⏳ PostgreSQL data warehouse
- ⏳ SQL analysis
- ⏳ Tableau dashboard
- ⏳ Final presentation

---

## Author

**Yoldas Erdem**

Data Analytics & AI Bootcamp Capstone Project

2026
