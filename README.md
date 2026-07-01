# 🏫 School Bullying Analysis using the CRDC 2021–22 Dataset

> A data analytics project exploring patterns of school bullying and harassment across nearly 100,000 U.S. schools using the Civil Rights Data Collection (CRDC) 2021–22.

---

# 📖 Project Vision

School bullying remains one of the most significant challenges affecting students' well-being, academic performance, and school climate.

While many discussions around bullying rely on individual stories or small-scale studies, the U.S. Department of Education collects nationwide administrative data through the Civil Rights Data Collection (CRDC).

This project aims to transform that large and complex dataset into meaningful insights by answering questions such as:

- Which types of bullying are reported most frequently?
- Which student groups appear most affected?
- How do schools differ in reported incidents?
- How often are disciplinary actions reported following bullying allegations?
- Are there geographical patterns across states and school districts?

Rather than focusing on individual schools, the goal is to identify broader patterns that may help support evidence-based discussions around school safety and student well-being.

---

# 🎯 Objectives

This project follows a complete analytics workflow:

- Data exploration
- Data cleaning and transformation (ETL)
- SQL-based analysis
- Interactive Tableau dashboards
- Executive presentation of findings

---

# 📊 Dataset

**Source**

U.S. Department of Education – Office for Civil Rights

**Dataset**

Civil Rights Data Collection (CRDC) 2021–22

The dataset contains information reported by public schools across the United States, including:

- School metadata
- Student demographics
- Harassment and bullying allegations
- Students reported as affected
- Students receiving disciplinary actions

---

# 📈 Project Workflow

```
Raw CRDC Dataset
        │
        ▼
Data Exploration
        │
        ▼
ETL Pipeline
        │
        ▼
Clean Dataset
        │
        ▼
PostgreSQL Database
        │
        ▼
SQL Analysis
        │
        ▼
Tableau Dashboard
        │
        ▼
Presentation & Insights
```

---

# 🛠️ Technologies

- Python
- Pandas
- Jupyter Notebook
- PostgreSQL
- DBeaver
- SQL
- Tableau
- Git
- GitHub

---

# 📂 Project Structure

```
School_Bullying_Capstone
│
├── data
│   ├── raw
│   └── processed
│
├── notebooks
│   ├── 01_Data_Exploration.ipynb
│   └── 02_ETL_Pipeline.ipynb
│
├── documentation
│   ├── appendix
│   └── reference
│
├── sql
│
├── tableau
│
├── presentation
│
└── README.md
```

---

# 🔄 ETL Pipeline

The ETL process includes:

- Loading the CRDC dataset
- Renaming technical variable names
- Preserving identifier fields
- Converting CRDC reserve codes (-3, -4, -5, -6, -9, -12, -13) to NULL values
- Exporting a clean analytical dataset

---

# 📚 Documentation

The project includes a complete data dictionary documenting:

- Original CRDC variable names
- Renamed variables
- Variable descriptions
- ETL transformations

Additional documentation includes the official CRDC manuals and reference materials.

---

# 📌 Current Status

✅ Project structure

✅ Data exploration

✅ ETL pipeline

✅ Data cleaning

✅ Documentation

✅ GitHub repository

⬜ PostgreSQL database

⬜ SQL analysis

⬜ Tableau dashboard

⬜ Final presentation

---

# ⚠️ Dataset Notice

The original CRDC dataset is **not included** in this repository.

To reproduce this project:

1. Download the CRDC 2021–22 dataset from the U.S. Department of Education.
2. Place the ZIP archive in:

```
data/raw/
```

3. Run the ETL notebook to generate the cleaned dataset.

---

# 👤 Author

**Yoldas Erdem**

Data Analytics & AI Bootcamp Capstone Project

2026
