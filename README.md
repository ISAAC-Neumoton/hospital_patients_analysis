# Hospital Analytics SQL Project

![Project Banner](images/banner.jpg)

A comprehensive **end-to-end hospital data analytics project** built using **Microsoft SQL Server (T-SQL)**.  
This project analyzes patient utilization, outcomes, operational efficiency, and financial performance across multiple analytical phases.

---

## 📑 Table of Contents

* [1. Project Overview](#1-project-overview)
* [2. Business Objectives](#2-business-objectives)
* [3. Dataset Description](#3-dataset-description)
* [4. Entity Relationship Diagram (ERD)](#4-entity-relationship-diagram-erd)
* [5. Phase 1: Database & Schema Design](#5-phase-1-database--schema-design)
* [6. Phase 2: Data Quality & Profiling (The Unpivot Method)](#6-phase-2-data-quality--profiling-the-unpivot-method)
    * [6.1 Missing Data Audit](#61-missing-data-audit)
    * [6.2 Orphan Record Detection (Admissions vs. Procedures)](#62-orphan-record-detection)
* [7. Phase 3: Data Cleaning & ETL](#7-phase-3-data-cleaning--etl)
* [8. Phase 4: Descriptive Analytics & Patient Segmentation](#8-phase-4-descriptive-analytics--patient-segmentation)
    * [8.1 Departmental Visit Volume %](#81-departmental-visit-volume)
    * [8.2 Age Group Segmentation (Pediatric, Adult, Geriatric)](#82-age-group-segmentation)
* [9. Phase 5: Utilization & Mortality Analysis](#9-phase-5-utilization--mortality-analysis)
    * [9.1 Mortality Rates by Age Group](#91-mortality-rates-by-age-group)
    * [9.2 Super-Utilizer Identification (>5 Visits)](#92-super-utilizer-identification)
    * [9.3 Demographic Utilization (Race & Gender Admission Trends)](#93-demographic-utilization)
* [10. Phase 6: Financial & Insurance Analytics](#10-phase-6-financial--insurance-analytics)
    * [10.1 Payer Market Share by Race](#101-payer-market-share-by-race)
    * [10.2 Regional Insurance Utilization (City Ranking)](#102-regional-insurance-utilization)
    * [10.3 Insurance Pay-outs by Gender](#103-insurance-pay-outs-by-gender)
    * [10.4 Multi-Insurance Coverage Patients](#104-multi-insurance-coverage-patients)
* [11. Phase 7: Clinical Efficiency & LOS Variance](#11-phase-7-clinical-efficiency--los-variance)
    * [11.1 Average Length of Stay (LOS) per Department](#111-average-length-of-stay-per-department)
    * [11.2 LOS Outlier Detection using Window Functions](#112-los-outlier-detection)
* [12. Phase 8: High-Resource & Seasonality Analysis](#12-phase-8-high-resource--seasonality-analysis)
    * [12.1 High-Resource Patient Ranking (Longest Stays)](#121-high-resource-patient-ranking)
    * [12.2 Monthly Admission Trends & Annual Seasonality](#122-monthly-admission-trends)
* [13. Key Insights](#13-key-insights)
* [14. Tools & Technologies](#14-tools--technologies)
* [15. How to Run the Project](#15-how-to-run-the-project)

---

## 1. Project Overview

This project uses SQL analytics to extract actionable insights from hospital patient data including:

- Patient utilization and readmissions  
- Mortality rates by age group  
- Departmental efficiency (LOS analysis)  
- Insurance claims and financial performance  
- Seasonal admission trends  

![Project Overview](images/project_overview.png)

---

## 2. Business Objectives

- Identify high-utilization patients (super-utilizers)  
- Measure mortality rates by age group  
- Analyze length of stay (LOS) per department  
- Rank departments by utilization and claim costs  
- Evaluate insurance payer contributions  
- Detect seasonal patterns in hospital admissions  
- Understand procedure distribution across demographics  

---

## 3. Dataset Description

The hospital dataset includes:

- `patients_demographics` – Patient personal and demographic data  
- `admissions` – Hospital visits, encounter details, billing  
- `procedures` – Procedures performed per patient visit  
- `payers` – Insurance provider information  
- `organizations` – Hospital/clinic details  

![Dataset Schema](images/dataset_tables.png)

---

## 4. Entity Relationship Diagram (ERD)

Shows relationships between patients, admissions, procedures, hospitals, and payers.

![ER Diagram](images/er_diagram.png)

---

## 5. Phase 1: Database & Schema Design

- Creation of `hospital_patients_db` database  
- Tables: `patients_demographics`, `admissions`, `procedures`, `payers`, `organizations`  
- Primary keys and foreign key constraints established  

![Database Schema](images/database_schema.png)

---

## 6. Phase 2: Data Quality & Profiling (The Unpivot Method)

### 6.1 Missing Data Audit

- Count of null values in each table column  
- Identification of data quality gaps for patients, admissions, and procedures  

![Missing Data](images/missing_data.png)

### 6.2 Orphan Record Detection

- Identify admissions without matching procedures or patients  
- Ensures referential integrity  

![Orphan Records](images/orphan_records.png)

---

## 7. Phase 3: Data Cleaning & ETL

- Standardize zip codes and marital status in `patients_demographics`  
- Fill missing `reason_code` and `reason_description` in `procedures` and `admissions`  
- Prepare clean dataset for analytics  

![Data Cleaning](images/data_cleaning.png)

---

## 8. Phase 4: Descriptive Analytics & Patient Segmentation

### 8.1 Departmental Visit Volume %

- Total patient visits per `encounter_class`  
- Percentage of total visits per department  

![Department Visits](images/department_visits.png)

### 8.2 Age Group Segmentation

- Classify patients by age at first admission: Pediatric, Adult, Geriatric  
- Count unique patients by gender and age group  

![Age Group Segmentation](images/age_group_segmentation.png)

---

## 9. Phase 5: Utilization & Mortality Analysis

### 9.1 Mortality Rates by Age Group

- Calculate total admissions and deaths per age group  
- Mortality percentage  

![Mortality Rates](images/mortality_rates.png)

### 9.2 Super-Utilizer Identification

- Patients with more than 5 admissions  
- Include first and last visit dates, city, and marital status  

![Super-Utilizers](images/super_utilizers.png)

### 9.3 Demographic Utilization

- Procedures and admissions distribution by race and gender  

![Demographics Utilization](images/demographics_utilization.png)

---

## 10. Phase 6: Financial & Insurance Analytics

### 10.1 Payer Market Share by Race

### 10.2 Regional Insurance Utilization (City Ranking)

### 10.3 Insurance Pay-outs by Gender

### 10.4 Multi-Insurance Coverage Patients

![Financial Analytics](images/financial_analytics.png)

---

## 11. Phase 7: Clinical Efficiency & LOS Variance

### 11.1 Average Length of Stay (LOS) per Department

### 11.2 LOS Outlier Detection using Window Functions

- Categorize stays: Short (<24h), Medium (24–72h), Long (>72h)  
- Detect outliers compared to department averages  

![LOS Analysis](images/los_analysis.png)
![LOS Outliers](images/los_outliers.png)

---

## 12. Phase 8: High-Resource & Seasonality Analysis

### 12.1 High-Resource Patient Ranking (Longest Stays)

- Top 20 patients with the longest stays  

![High-Resource Patients](images/high_resource_patients.png)

### 12.2 Monthly Admission Trends & Annual Seasonality

- Monthly hospital admissions for seasonality trends  

![Seasonality Trends](images/seasonality_trends.png)

---

## 13. Key Insights

- Certain departments have higher visit volumes than others  
- Pediatric and Geriatric patients show different mortality trends  
- Super-utilizers significantly impact resource allocation  
- Insurance contributions vary by payer and region  
- Length of stay outliers may indicate efficiency gaps  
- Seasonal trends highlight peak admission periods  

---

## 14. Tools & Technologies

- **SQL Server (T-SQL)** – Data storage and queries  
- **SSMS** – Query execution and visualization  
- **Excel / Power BI (Optional)** – Reporting and charts  

---

## 15. How to Run the Project

1. Restore `hospital_patients_db` in SQL Server  
2. Run SQL scripts in order:  
   - `schema.sql`  
   - `data_cleaning.sql`  
   - `analytics_phases_1-8.sql`  
3. Review query results in SSMS or export to reporting tools  
4. Use images in `images/` folder to visualize results  

---

