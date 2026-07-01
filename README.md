# 🏫 School Bullying Analysis using the CRDC 2021–22 Dataset

> A data analytics project exploring patterns of school bullying and harassment across nearly 100,000 U.S. schools using the Civil Rights Data Collection (CRDC) 2021–22.

> 🚧 **Project Status:** This project is currently under active development as part of a Data Analytics & AI Bootcamp Capstone. The ETL pipeline has been completed, while the PostgreSQL database, SQL analysis, and Tableau dashboard are currently in progress.

---

# 📖 Project Vision

School bullying affects student well-being, academic performance, and the overall school climate. Understanding nationwide patterns through data can help educators, policymakers, and researchers identify trends, allocate resources more effectively, and support evidence-based decision-making.

While many discussions around bullying rely on individual stories or small-scale studies, the U.S. Department of Education collects nationwide administrative data through the Civil Rights Data Collection (CRDC).

This project transforms that large and complex dataset into meaningful insights by answering questions such as:

- Which types of bullying are reported most frequently?
- Which student groups appear most affected?
- How do schools differ in reported incidents?
- How often are disciplinary actions reported following bullying allegations?
- Are there geographical patterns across states and school districts?

Rather than focusing on individual schools, the goal is to identify broader nationwide patterns that support evidence-based discussions around school safety and student well-being.

---

# 📷 Dashboard Preview

Dashboard screenshots will be added after the Tableau analysis is completed.

The final dashboard will provide interactive visualizations exploring nationwide bullying patterns, student demographics, disciplinary actions, school characteristics, and geographic comparisons across the United States.

---

# 🎯 Objectives

This project follows a complete end-to-end analytics workflow:

- Data exploration and profiling
- Data cleaning and transformation (ETL)
- Database integration with PostgreSQL
- SQL-based analysis
- Interactive Tableau dashboards
- Executive presentation of findings

---

# 🔍 Expected Insights

The analysis aims to uncover:

- The most frequently reported types of bullying and harassment.
- Differences in reported incidents across states and school districts.
- Student groups with higher reported allegation counts.
- Relationships between reported allegations and disciplinary actions.
- Geographic trends and school-level variations across the United States.

The objective is not to evaluate individual schools, but to identify broader nationwide patterns that can support data-driven discussions around school safety and student well-being.

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

# ⭐ Project Highlights

- 📊 Analyzing **98,010** school-level records collected across the United States.
- 🏫 Covers nearly **100,000 public schools** participating in the CRDC.
- 🧹 Built a complete ETL pipeline using Python and Pandas.
- 🗂️ Renamed and documented **159 analytical variables**.
- 📚 Created a comprehensive data dictionary and supporting project documentation.
- 💾 Preparing the cleaned dataset for PostgreSQL and SQL analysis.
- 📈 Developing an interactive Tableau dashboard for exploratory analysis and storytelling.

---

# 🛠️ Technologies

| Technology       | Purpose                                         |
| ---------------- | ----------------------------------------------- |
| Python           | Data cleaning and preprocessing                 |
| Pandas           | ETL pipeline and data transformation            |
| Jupyter Notebook | Exploratory Data Analysis (EDA)                 |
| PostgreSQL       | Analytical database                             |
| DBeaver          | Database management                             |
| SQL              | Data querying and aggregation                   |
| Tableau          | Interactive dashboards and visualizations       |
| Git              | Version control                                 |
| GitHub           | Repository management and project documentation |

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

The ETL pipeline includes:

- Loading the original CRDC dataset.
- Renaming technical CRDC variable names into readable analytical field names.
- Preserving leading zeros for school and district identifiers.
- Converting CRDC reserve codes (`-3`, `-4`, `-5`, `-6`, `-9`, `-12`, `-13`) into standard NULL values.
- Validating the transformed dataset.
- Exporting a clean analytical dataset ready for PostgreSQL and Tableau.

---

# 📚 Documentation

The project includes comprehensive documentation to improve transparency and reproducibility.

Available documentation includes:

- Data Dictionary
- Variable Mapping
- ETL documentation
- Official CRDC Data User Manual
- Official CRDC Variable Definitions
- CRDC Appendix Workbook

Note: Some PDF and Excel documentation files may not render directly in GitHub. Use **View raw** or download the file to open it locally.

---

# 📌 Current Status

| Phase               | Status         |
| ------------------- | -------------- |
| Project Structure   | ✅ Completed   |
| Data Exploration    | ✅ Completed   |
| ETL Pipeline        | ✅ Completed   |
| Data Cleaning       | ✅ Completed   |
| Documentation       | ✅ Completed   |
| GitHub Repository   | ✅ Completed   |
| PostgreSQL Database | ⏳ In Progress |
| SQL Analysis        | ⏳ Planned     |
| Tableau Dashboard   | ⏳ Planned     |
| Final Presentation  | ⏳ Planned     |

---

# ⚠️ Dataset Notice

The original CRDC dataset is **not included** in this repository.

To reproduce this project:

1. Download the CRDC 2021–22 dataset from the U.S. Department of Education.
2. Place the ZIP archive inside:

```
data/raw/
```

3. Run the ETL notebook to generate the cleaned analytical dataset.

---

# 📊 Key Findings

This section will be updated once the SQL analysis and Tableau dashboard have been completed. It will summarize the most important findings and include dashboard screenshots together with links to the final interactive visualizations.

---

# 👤 Author

**Yoldas Erdem**

Data Analytics & AI Bootcamp Capstone Project

2026
