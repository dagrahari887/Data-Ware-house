# 🚀 Data Warehouse & Analytics Project

Welcome to the **Data Warehouse and Analytics Project** repository! This project demonstrates a comprehensive, end-to-end data warehousing and business intelligence solution—from raw data ingestion to advanced analytical reporting. Designed as a professional portfolio project, it highlights industry best practices in data engineering, data modeling, and SQL analytics.

---

## 🏗️ Data Architecture

This project follows the **Medallion Architecture**, organizing data into three distinct layers (**Bronze**, **Silver**, and **Gold**) to ensure data quality, lineage, and query performance:

![Data Architecture]"E:\SQL Warehouse\Docs\data_architecture.png"

1. **Bronze Layer (Raw Data):** Ingests raw CSV source data from operational systems (**ERP** and **CRM**) directly into SQL Server without transformations.
2. **Silver Layer (Cleansed Data):** Performs data cleansing, standardization, structural normalization, and domain validation to prepare data for modeling.
3. **Gold Layer (Curated Data):** Houses business-ready data modeled into a high-performance **Star Schema** (Fact and Dimension tables) required for reporting and analytics.

---

## 📋 Project Overview

This repository covers the complete lifecycle of modern data warehousing:

* **Data Architecture:** Designing a scalable warehouse using the Medallion Architecture pattern.
* **ETL Pipelines:** Extracting, transforming, and loading structured data across layers using optimized T-SQL scripts.
* **Data Modeling:** Developing Fact and Dimension tables in a Star Schema optimized for analytical queries.
* **Analytics & Reporting:** Creating SQL-driven analytical reports to generate actionable business insights.

### 🎯 Skills Demonstrated
This repository serves as a practical showcase for roles including:
* SQL Developer / Database Administrator
* Data Architect
* Data Engineer / ETL Pipeline Developer
* Data Analyst & BI Specialist

---

## 🎯 Project Scope & Requirements

### 1. Data Engineering (Warehouse & Pipelines)
* **Data Sources:** Import operational data from two distinct source systems (**ERP** and **CRM**) provided as raw CSV files.
* **Data Quality:** Identify and resolve missing values, duplicates, and structural inconsistencies prior to modeling.
* **Integration:** Combine ERP and CRM sources into a unified, user-friendly data model.
* **Scope:** Focus on current state analysis (historization of historical states is not required).
* **Documentation:** Maintain complete documentation including data models, catalog, and architectural diagrams.

### 2. Business Intelligence & Analytics
Deliver SQL-based analytics providing actionable insights into:
* **Customer Behavior:** Segment customer profiles, track purchasing frequency, and evaluate lifetime value.
* **Product Performance:** Analyze metrics across product categories, items, and distribution channels.
* **Sales Trends:** Measure performance over time (Total Revenue, Order Volumes, and Growth Trends).

---

## 📁 Repository Structure

```text
data-warehouse-project/
│
├── datasets/                 # Raw datasets used for the project (ERP and CRM CSV files)
│
├── docs/                     # Project documentation and architectural diagrams
│   ├── data_architecture.png # Architecture visual diagram
│   ├── data_architecture.drawio # Diagram source for data architecture
│   ├── etl.drawio            # Visual map of ETL techniques and transformation workflows
│   ├── data_flow.drawio      # End-to-end data flow diagram
│   ├── data_models.drawio    # Star Schema entity-relationship models
│   ├── data_catalog.md       # Detailed metadata catalog and column definitions
│   └── naming-conventions.md # Standardized naming rules for database objects
│
├── scripts/                  # T-SQL scripts for ETL execution
│   ├── bronze/               # Ingestion scripts for loading raw source files
│   ├── silver/               # Cleansing, transformation, and normalization scripts
│   └── gold/                 # Star Schema view & table creation scripts
│
├── tests/                    # Data quality checks and pipeline validation scripts
│
├── README.md                 # Primary project documentation
├── LICENSE                   # Open-source repository license
├── .gitignore                # Files excluded from version control
└── requirements.txt          # Python/environment dependencies (if applicable)
