USE hospital_patients_db;


--PHASE 1
-- create the database
CREATE DATABASE hospital_patients_db;
--CREATE THE PATIENTS DEMOGRAPHICS TABLE

CREATE TABLE patients_demographics(
    id VARCHAR(150) PRIMARY KEY,
    birth_date DATE,
    death_date DATE,
    prefix VARCHAR(10),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    suffix VARCHAR(10),
    maiden_name VARCHAR(50),
    marital_status CHAR(10),
    race VARCHAR(50),
    ethnicity VARCHAR(100),
    gender CHAR(10),
    birth_place VARCHAR(100),
    address VARCHAR(200),
    city VARCHAR(50),
    state VARCHAR(50),
    county VARCHAR(50),
    zip VARCHAR(10),
    lat FLOAT,
    long FLOAT
);

--CREATE THE HOSPITAL TABLE HERE
CREATE TABLE organizations (
    hostpital_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(150),
    address VARCHAR(200),
    city VARCHAR(50),
    state CHAR(2),
    zip VARCHAR(10),
    lat FLOAT,
    long FLOAT
);

--CREATE THE PAYERS TABLE 
CREATE TABLE payers (
    payer_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(150),
    address VARCHAR(200),
    city VARCHAR(50),
    state_headquartered CHAR(10),
    zip VARCHAR(10),
    phone VARCHAR(50)
);


--CREATE TABLE FOR Admission and discharge details WITH BILLS DETAILS
CREATE TABLE admissions (
    ad_id VARCHAR(50) PRIMARY KEY,
    start_time DATETIME,
    stop_time DATETIME,
    patient_id VARCHAR(150),
    hospital_id VARCHAR(50),
    payer_id VARCHAR(50),
    encounter_class VARCHAR(50),
    code VARCHAR(50),
    description VARCHAR(255),
    base_encounter_cost FLOAT,
    total_claim_cost FLOAT,
    payer_coverage FLOAT,
    reason_code VARCHAR(50),
    reason_description VARCHAR(255),
	--specify contraints
    FOREIGN KEY (patient_id) REFERENCES patients_demographics(id),
    FOREIGN KEY (hospital_id) REFERENCES organizations(hostpital_id),
    FOREIGN KEY (payer_id) REFERENCES payers(payer_id)
);

CREATE TABLE procedures (
    start_time DATETIME,
    stop_time DATETIME,
    patient_id VARCHAR(150),
    ad_id VARCHAR(50),
    code VARCHAR(50),
    description VARCHAR(255),
    base_cost FLOAT,
    reason_code VARCHAR(50),
    reason_description VARCHAR(255),
	-- specify contraints
    FOREIGN KEY (patient_id) REFERENCES patients_demographics(id),
    FOREIGN KEY (ad_id) REFERENCES admissions(ad_id)
);

---DATA DICTIONARY
SELECT* FROM INFORMATION_SCHEMA.TABLES

-----------------------------------------------------------------------------

--PHASE 2

--1. import PAYER table AND COUNT ROWS
SELECT *,  
	COUNT(*) OVER()	count_sponsors
FROM payers;

--2. import PAYER table AND COUNT ROWS
SELECT  COUNT(*) OVER() count_admission, *
FROM admissions;

--3. import admission table AND COUNT ROWS
SELECT  COUNT(*) OVER() count_patients, *
FROM patients_demographics;

--4. import hospitals/oragizations table AND COUNT ROWS
SELECT  COUNT(*) OVER() count_org, *
FROM organizations;


--5. import procedures table AND COUNT ROWS
SELECT  COUNT(*) OVER() count_procedures, *
FROM procedures;


--NULL values counts : Return only the data quality gaps that are NOT zero
 /*
1. Calculate everything (including the zeros).
2. Rotate the table from horizontal to vertical.
3. Filter out any row where the count is zero.
4. Display only the remaining rows
 */
--PATIENTS DEMOGRAPHICS
SELECT 
    Null_Category,
    Missing_Count
FROM (
    -- null data summary for each all fields
    SELECT 
        COUNT(*) AS Total_Records,
        SUM(CASE WHEN id IS NULL THEN 1 ELSE 0 END) AS Missing_IDs,
        SUM(CASE WHEN first_name IS NULL OR last_name IS NULL THEN 1 ELSE 0 END) AS Missing_Names,
        SUM(CASE WHEN birth_date IS NULL THEN 1 ELSE 0 END) AS Missing_BirthDates,
        SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS Missing_Gender,
        SUM(CASE WHEN race IS NULL OR ethnicity IS NULL THEN 1 ELSE 0 END) AS Missing_Race_Ethnicity,
        SUM(CASE WHEN marital_status IS NULL THEN 1 ELSE 0 END) AS Missing_Marital_Status,
        SUM(CASE WHEN address IS NULL OR city IS NULL OR state IS NULL THEN 1 ELSE 0 END) AS Missing_Address_Info,
        SUM(CASE WHEN zip IS NULL THEN 1 ELSE 0 END) AS Missing_Zip_Codes,
        SUM(CASE WHEN lat IS NULL OR long IS NULL THEN 1 ELSE 0 END) AS Missing_Coordinates,
        SUM(CASE WHEN death_date IS NOT NULL THEN 1 ELSE 0 END) AS Death_Patients
    FROM patients_demographics
) AS sub
-- Unpivot the columns into rows so we can filter them
CROSS APPLY (
    VALUES 
		('Total_Records', Total_Records),
        ('Missing IDs', Missing_IDs),
        ('Missing Names', Missing_Names),
        ('Missing BirthDates', Missing_BirthDates),
        ('Missing Gender', Missing_Gender),
        ('Missing Race/Ethnicity', Missing_Race_Ethnicity),
        ('Missing Marital Status', Missing_Marital_Status),
        ('Missing Address Info', Missing_Address_Info),
        ('Missing Zip Codes', Missing_Zip_Codes),
        ('Missing Coordinates', Missing_Coordinates),
        ('Death_Patients', Death_Patients)
) AS vTable(Null_Category, Missing_Count)
WHERE vTable.Missing_Count > 0; 
--PROCEDURES
SELECT 
    Null_Category,
    Missing_Count
FROM (
    SELECT 
        COUNT(*) AS Total_Records,
        SUM(CASE WHEN start_time IS NULL THEN 1 ELSE 0 END) AS null_start,
        SUM(CASE WHEN stop_time IS NULL THEN 1 ELSE 0 END) AS null_stop,
        SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END) AS null_patient,
        SUM(CASE WHEN ad_id IS NULL THEN 1 ELSE 0 END) AS null_ad_link,
        SUM(CASE WHEN code IS NULL THEN 1 ELSE 0 END) AS null_code,
        SUM(CASE WHEN description IS NULL THEN 1 ELSE 0 END) AS null_desc,
        SUM(CASE WHEN base_cost IS NULL THEN 1 ELSE 0 END) AS null_cost,
        SUM(CASE WHEN reason_code IS NULL THEN 1 ELSE 0 END) AS null_reason_code,
        SUM(CASE WHEN reason_description IS NULL THEN 1 ELSE 0 END) AS null_reason_desc
    FROM procedures
) AS sub
CROSS APPLY (
    VALUES 
        ('Total', Total_Records),
        ('start_time', null_start), ('stop_time', null_stop), ('patient_id', null_patient),
        ('ad_id', null_ad_link), ('code', null_code), ('description', null_desc),
        ('base_cost', null_cost), ('reason_code', null_reason_code), ('reason_description', null_reason_desc)
) AS vTable(Null_Category, Missing_Count)
WHERE vTable.Null_Category = 'TOTAL_RECORDS_IN_TABLE' OR vTable.Missing_Count > 0;
--ADMISSION
SELECT 
    Null_Category,
    Missing_Count
FROM (
    SELECT 
        -- Benchmark: Total volume of records in the table
        COUNT(*) AS Total_Records,
        
        -- Primary & Foreign Keys
        SUM(CASE WHEN ad_id IS NULL THEN 1 ELSE 0 END) AS null_ad_id,
        SUM(CASE WHEN patient_id IS NULL THEN 1 ELSE 0 END) AS null_patient_id,
        SUM(CASE WHEN hospital_id IS NULL THEN 1 ELSE 0 END) AS null_hospital_id,
        SUM(CASE WHEN payer_id IS NULL THEN 1 ELSE 0 END) AS null_payer_id,
        
        -- Operational Timestamps
        SUM(CASE WHEN start_time IS NULL THEN 1 ELSE 0 END) AS null_start_time,
        SUM(CASE WHEN stop_time IS NULL THEN 1 ELSE 0 END) AS null_stop_time,
        
        -- Clinical Classification
        SUM(CASE WHEN encounter_class IS NULL THEN 1 ELSE 0 END) AS null_encounter_class,
        SUM(CASE WHEN code IS NULL THEN 1 ELSE 0 END) AS null_medical_code,
        SUM(CASE WHEN description IS NULL THEN 1 ELSE 0 END) AS null_description,
        
        -- Financial Metrics
        SUM(CASE WHEN base_encounter_cost IS NULL THEN 1 ELSE 0 END) AS null_base_cost,
        SUM(CASE WHEN total_claim_cost IS NULL THEN 1 ELSE 0 END) AS null_claim_cost,
        SUM(CASE WHEN payer_coverage IS NULL THEN 1 ELSE 0 END) AS null_coverage,
        
        -- Justification (Medical Necessity)
        SUM(CASE WHEN reason_code IS NULL THEN 1 ELSE 0 END) AS null_reason_code,
        SUM(CASE WHEN reason_description IS NULL THEN 1 ELSE 0 END) AS null_reason_desc
    FROM admissions
) AS sub
CROSS APPLY (
    VALUES 
        ('Total', Total_Records), -- Always included for context
        ('ad_id', null_ad_id), ('patient_id', null_patient_id), ('hospital_id', null_hospital_id),
        ('payer_id', null_payer_id), ('start_time', null_start_time), ('stop_time', null_stop_time),
        ('encounter_class', null_encounter_class), ('code', null_medical_code), 
        ('description', null_description), ('base_encounter_cost', null_base_cost),
        ('total_claim_cost', null_claim_cost), ('payer_coverage', null_coverage),
        ('reason_code', null_reason_code), ('reason_description', null_reason_desc)
) AS vTable(Null_Category, Missing_Count)
-- We keep Total_Records and filter out other categories that have 0 errors
WHERE vTable.Null_Category = 'TOTAL_RECORDS_IN_TABLE' OR vTable.Missing_Count > 0;



--DATA CLEANING
UPDATE patients_demographics
SET zip = '0' + zip
WHERE LEN(zip) = 4;

UPDATE patients_demographics
SET zip = '00000'
WHERE zip IS NULL;

UPDATE patients_demographics
SET marital_status = 'X'
WHERE marital_status IS NULL;

UPDATE procedures
SET reason_code = 'Unknown'
WHERE reason_code IS NULL;

UPDATE procedures
SET reason_description = 'Not Specified'
WHERE reason_description IS NULL;

UPDATE admissions
SET reason_code = 'Not Specified'
WHERE reason_code IS NULL;

-- Patients with visits but NO procedures
SELECT COUNT(*) [Visit No Procedure]
FROM admissions a
LEFT JOIN procedures pr ON a.ad_id = pr.ad_id
WHERE pr.ad_id IS NULL

-- Procedures recorded without a linked Admission ID
SELECT pr.patient_id, pr.ad_id, 'Procedure No Visit' as Type
FROM procedures pr
LEFT JOIN admissions a ON pr.ad_id = a.ad_id
WHERE a.ad_id IS NULL;
-----------------------------------------------------------------
--PHASE 3

--TOTAL PATIENTS VISITS PER CLASS %
SELECT
    a.encounter_class,
    COUNT(*) AS department_visits,
    -- Total visits across all departments (benchmark)
    SUM(COUNT(*)) OVER () AS total_visits,
    -- Percentage contribution of each department
    CAST(
		ROUND(
			100.0 * COUNT(*) / CAST(
				SUM(COUNT(*)) OVER () AS FLOAT),2
		) AS varchar
	) + '%' AS dept_volume_percent
FROM admissions a
GROUP BY a.encounter_class
ORDER BY department_visits DESC;

--PATIENT AGE GROUP SEGMENTATION
/*
  1. SCAN ADMISSIONS: Search the entire admissions table for every recorded hospital visit.
  2. FIND ENTRY DATES: Identify the earliest start time for each unique patient ID.
  3. Save  first visit dates into a temporary TABLE called FirstAdmission.
  4. Link this list to the patients_demographics table using the patient IDs.
  5. Subtract the birth_date from the first_admission_date to find their age at entry.
  6. Use CASE logic to label patients as Pediatric, Adult, or Geriatric.
  7. FINAL AGGREGATE: Count unique IDs and group them by Gender and your new Age Groups.
*/
WITH FirstAdmission AS (
    SELECT 
        patient_id,
        MIN(start_time) AS first_admission_date
    FROM admissions
    GROUP BY patient_id
)
SELECT
    p.Gender,
    -- Age group based on age at first admission
    CASE 
        WHEN DATEDIFF(YEAR, p.birth_date, fa.first_admission_date) < 18 THEN 'Pediatric (0-17)'
        WHEN DATEDIFF(YEAR, p.birth_date, fa.first_admission_date) BETWEEN 18 AND 60 THEN 'Adult'
        ELSE 'Geriatric'
    END AS [Age Group],
    COUNT(DISTINCT p.id) AS [Total Patients]
FROM patients_demographics p
JOIN FirstAdmission fa 
    ON p.id = fa.patient_id
GROUP BY
	--count by gender
    p.Gender,
    CASE 
        WHEN DATEDIFF(YEAR, p.birth_date, fa.first_admission_date) < 18 THEN 'Pediatric (0-17)'
        WHEN DATEDIFF(YEAR, p.birth_date, fa.first_admission_date) BETWEEN 18 AND 60 THEN 'Adult'
        ELSE 'Geriatric'
    END
ORDER BY 
    [Age Group], 
    p.Gender;

--ADMISSION TRENDS: ANNUAL SEASONALITY ANALYSIS (TOP 3 MONTHS)
/*
  1. Group all admissions by year and month name to get total counts.
  2. Concatenate the month name and year for a readable "Month Year" label.
  3. Store these monthly totals in a temporary TABLE (MonthlyAdmissions).
  4. Use ROW_NUMBER() to rank months within each individual year.
  5. Reset the ranking every time the year changes (PARTITION BY year).
  6. Extract only the records where the rank is 3 or less.
  7. Arrange the final list chronologically by year and then by highest volume.
*/
WITH MonthlyAdmissions AS (
    SELECT
        DATENAME(MONTH, start_time) + ' ' + CAST(YEAR(start_time) AS VARCHAR(4)) AS [month year],
        YEAR(start_time) AS year,
        -- Count total admissions for each month
        COUNT(*) AS total_admissions
    FROM admissions
    GROUP BY
        YEAR(start_time),         
        DATENAME(MONTH, start_time) 
)
--Rank monthly admissions within each year
SELECT
    year,                  
    [month year],          
    total_admissions        
FROM (
    SELECT
        year,
        [month year],
        total_admissions,
        -- ROW_NUMBER Rank
        ROW_NUMBER() OVER (
            PARTITION BY year          
            ORDER BY total_admissions DESC  
        ) AS rank
    FROM MonthlyAdmissions
) t
--top 3 months per year
WHERE rank <= 3

--Order the output for clarity
ORDER BY 
    year,                  
    total_admissions DESC; 

-------------------------------------------------------------

--PHASE 4

--PATIENTS READMISSION
SELECT  
	patient_id, 
	COUNT(*)-1 [Patient ReAdmission Count]
FROM admissions
GROUP BY patient_id
ORDER BY COUNT(*) DESC

--CHECK IF PATIENTS COUNT > 974 & COUNT No of Encounter Class
SELECT 
	COUNT(DISTINCT encounter_class) count_class,
	COUNT(DISTINCT patient_id) patients_count
FROM admissions

--WHICH DEPT ADMIT THE MOST PATIENTS
SELECT COUNT(*) FROM admissions
SELECT 
	encounter_class,
	COUNT(DISTINCT patient_id) [Count Pastient],
	ROUND(COUNT(DISTINCT patient_id)/CAST(974 AS FLOAT) * 100, 2)  [PERCENTAGE%]
FROM admissions
GROUP BY
	encounter_class
ORDER BY 
	COUNT(DISTINCT patient_id) DESC;

--average length of stay per encounter class
SELECT
    encounter_class AS department,
    AVG(DATEDIFF(HOUR, start_time, stop_time)) AS avg_los_hours,
    COUNT(*) AS encounter_count
FROM admissions
WHERE stop_time IS NOT NULL
GROUP BY encounter_class
ORDER BY AVG(DATEDIFF(HOUR, start_time, stop_time)) DESC;

--LOS outliers detection per encounter class
WITH los_calc AS (
    SELECT
        ad_id,
        encounter_class,
        start_time,
        stop_time,
        DATEDIFF(HOUR, start_time, stop_time) AS los_hours,
        AVG(DATEDIFF(HOUR, start_time, stop_time))
            OVER (PARTITION BY encounter_class) AS avg_los_hours,
		ROW_NUMBER() OVER (PARTITION BY encounter_class ORDER BY DATEDIFF(HOUR, start_time, stop_time) desc) RANK
    FROM admissions
    WHERE stop_time IS NOT NULL AND start_time IS NOT NULL
)
--select the CTE to return the results(outliers)
SELECT *
FROM los_calc
WHERE los_hours > avg_los_hours and RANK < 4
ORDER BY avg_los_hours DESC, los_hours DESC;


--FITERING BY DIAGNOSIS
---	CHECK THE NO OF APPLICATION PER DESCRIPTION TYPE
SELECT
    description AS diagnosis,
    COUNT(*) AS diagnosis_counT,
	SUM(COUNT(*)) OVER() TOTAL
FROM admissions
WHERE description IS NOT NULL
GROUP BY description
ORDER BY diagnosis_count DESC;

---Check most common procedures taken on patients
SELECT
    description AS procCedure,
    COUNT(*) AS count,
	SUM(COUNT(*)) OVER() TOTAL
FROM procedures
WHERE description IS NOT NULL
GROUP BY description
ORDER BY count DESC;

--- check if the procedures matches the diagnosis
SELECT
	a.patient_id,
	p.patient_id,
    a.description AS admission_description,
    p.description AS procedure_description
FROM admissions a
JOIN procedures p
    ON a.patient_id = p.patient_id;

--------------------------------------------------


--PHASE 5
--patients with recorded hospital visits.	
SELECT 
    p.id AS patient_id,
	COUNT(*) OVER(PARTITION BY TRIM(patient_id) ORDER BY encounter_class) [Number of Encounter],
    p.first_name,
    p.last_name,
    p.gender,
    a.encounter_class,
    a.start_time
FROM patients_demographics p --to obtain info  about the patient name and what brought the patient to the hospital
JOIN admissions a 
	ON p.id = a.patient_id
ORDER BY COUNT(*) OVER(PARTITION BY TRIM(patient_id) ORDER BY encounter_class) DESC;

--mortality rateby each age group
SELECT 
    CASE 
        WHEN DATEDIFF(YEAR, p.birth_date, a.start_time) < 18 THEN 'Pediatric'
        WHEN DATEDIFF(YEAR, p.birth_date, a.start_time) BETWEEN 18 AND 60 THEN 'Adult'
        ELSE 'Geriatric'
    END AS age_group,
    COUNT(a.ad_id) AS total_admissions,
    SUM(
		CASE WHEN p.death_date IS NOT NULL THEN 1 ELSE 0 END
		) AS total_deaths,
    CONCAT(
		ROUND(
			CAST(
				SUM(
					CASE WHEN p.death_date IS NOT NULL THEN 1 ELSE 0 END
					) AS FLOAT) / COUNT(a.ad_id) * 100, 2),'%')
	AS mortality_rate_pct
FROM dbo.patients_demographics p
JOIN dbo.admissions a ON p.id = a.patient_id
GROUP BY 
    CASE 
        WHEN DATEDIFF(YEAR, p.birth_date, a.start_time) < 18 THEN 'Pediatric'
        WHEN DATEDIFF(YEAR, p.birth_date, a.start_time) BETWEEN 18 AND 60 THEN 'Adult'
        ELSE 'Geriatric'
    END;


--Which patients are "super-utilizers"
WITH PatientUtilization AS (
    SELECT 
        patient_id,
        COUNT(ad_id) AS visit_count,
		MIN(start_time) as first_visit,
		MAX(start_time) as last_visit
    FROM dbo.admissions
    GROUP BY patient_id
    HAVING COUNT(ad_id) > 5
)
SELECT 
    p.first_name + ' ' + p.last_name name, 
    p.city, 
    p.marital_status,
    u.visit_count,
	u.first_visit,
	u.last_visit
FROM dbo.patients_demographics p
JOIN PatientUtilization u ON p.id = u.patient_id
ORDER BY u.visit_count DESC;

--which race was admitted the most
SELECT 
    p.race, 
    COUNT(a.ad_id) AS total_admissions
FROM patients_demographics p
JOIN admissions a ON p.id = a.patient_id
GROUP BY p.race
ORDER BY total_admissions DESC;

--Which region (City/State) visits more often and to what department?
SELECT 
    p.city, 
    p.state, 
    a.encounter_class, 
    COUNT(*) AS visit_count
FROM patients_demographics p
JOIN admissions a ON p.id = a.patient_id
GROUP BY p.city, p.state, a.encounter_class
ORDER BY visit_count DESC;

--PHASE 6
--rank total claim cost per department
SELECT 
	encounter_class, 
	round(sum(total_claim_cost), 2) [Sum of Cost],
	DENSE_RANK() OVER (ORDER BY sum(total_claim_cost) DESC) rank
FROM admissions
GROUP BY encounter_class 
ORDER BY rank


--Joins admissions with organizations and payers (insurance).
--How much have each insurance paid so far for medcare
SELECT 
    o.name AS hospital_name,
    pay.name AS [payer_name/ Insurance],
    COUNT(a.ad_id) AS total_encounters,
    ROUND(SUM(a.total_claim_cost),2 ) AS total_billed, --- evaluate total cost per insurance company
	DENSE_RANK () OVER(ORDER BY SUM(a.total_claim_cost) DESC) [Top to bottom rank]
FROM admissions a -- admission to which organization.hospital and who paid the bills
INNER JOIN organizations o --join by hospital id to the organizarion
	ON a.hospital_id = o.hostpital_id
INNER JOIN payers pay 
	ON a.payer_id = pay.payer_id  
GROUP BY o.name, pay.name
ORDER BY SUM(a.total_claim_cost) DESC;

-- Procedures per Patient >>>> connect patient traits/race to specific medical actions.
SELECT 
    p.race,--select the race e.g white black
    pr.description AS procedure_performed, -- the procedure
    COUNT(pr.code) AS total_count
FROM patients_demographics p -- what kind of medical actions are taken on certain race and how often
JOIN admissions a ON p.id = a.patient_id-- why is the admission when we can just connect to procedure from the patient id
JOIN procedures pr ON a.ad_id = pr.ad_id
GROUP BY p.race, pr.description
ORDER BY COUNT(pr.code) desc;


--Which gender has higher total claim costs
SELECT p.gender, round(SUM(a.total_claim_cost),2) as total_insurance_bill
FROM patients_demographics p
JOIN admissions a ON p.id = a.patient_id
GROUP BY p.gender;

SELECT 
    p.race, 
    pay.name AS insurance_provider, 
    COUNT(a.ad_id) AS total_usage
    -- Provides the percentage of that race using this specific insurance
    --CAST(ROUND(100.0 * COUNT(a.ad_id) / cast(SUM(COUNT(a.ad_id)) OVER(PARTITION BY p.race) as float), 2) AS VARCHAR) + '%' AS coverage_share
FROM patients_demographics p
JOIN admissions a ON p.id = a.patient_id
JOIN payers pay ON a.payer_id = pay.payer_id
GROUP BY p.race, pay.name
ORDER BY total_usage DESC;

--Regional Insurance Utilization
-- query focuses on Geographic Analysis, showing which insurers dominate specific cities. This helps identify where certain insurance companies have the strongest market presence.


--How is insurance usage distributed across different cities?
SELECT 
    p.city, 
    p.state,
    pay.name AS insurance_provider, 
    COUNT(a.ad_id) AS regional_visit_count
FROM patients_demographics p
JOIN admissions a ON p.id = a.patient_id
JOIN payers pay ON a.payer_id = pay.payer_id
GROUP BY p.city, p.state, pay.name
ORDER BY regional_visit_count DESC;


--which patient had more than one insurance count
SELECT 
    p.first_name, 
    p.last_name, 
    COUNT(DISTINCT a.payer_id) AS insurance_count
FROM patients_demographics p
JOIN admissions a ON p.id = a.patient_id
GROUP BY p.id, p.first_name, p.last_name
HAVING COUNT(DISTINCT a.payer_id) > 1
ORDER BY insurance_count DESC;

---------------------------------------------------------------
-- PHASE 7:

--Length of Stay (LOS) >>>> Comparing individual stays against the department average to find outliers.
SELECT 
    p.first_name  + ' ' +  p.last_name [Patient Name],
	p.race,
	DATEDIFF(YEAR, p.birth_date, a.start_time) age, a.description
    encounter_class,
    DATEDIFF(HOUR, start_time, stop_time) AS patient_los, --lenght of stay in hour
	CASE --caategorize the stay
        WHEN stop_time IS NULL THEN 'STILL ADMITTED'
        WHEN DATEDIFF(HOUR, a.start_time, a.stop_time) < 24 THEN 'Short Stay'
        WHEN DATEDIFF(HOUR, a.start_time, a.stop_time) BETWEEN 24 AND 72 THEN 'Medium Stay'
        ELSE 'Long Stay'
    END AS stay_category,
    cast(DATEDIFF(DAY, start_time, stop_time) as nvarchar) + ' days' AS patient_los, --length of stay in days
    AVG(DATEDIFF(hour, start_time, stop_time)) OVER(PARTITION BY encounter_class) AS dept_avg_los,
    DATEDIFF(hour, start_time, stop_time) - 
        AVG(DATEDIFF(hour, start_time, stop_time)) OVER(PARTITION BY encounter_class) AS variance
FROM admissions a
JOIN patients_demographics p ON a.patient_id = p.id
WHERE stop_time IS NOT NULL
ORDER BY DATEDIFF(HOUR, start_time, stop_time) DESC

--which gender has more proceddure
SELECT 
    p.gender, 
    COUNT(pr.code) AS procedure_count
FROM patients_demographics p
JOIN procedures pr ON p.id = pr.patient_id
GROUP BY p.gender
ORDER BY procedure_count DESC;


-- PHASE 8: 
-- Top 20 High-Resource Patients (Longest Stays)
SELECT top 20
    p.prefix + ' ' + first_name + ' ' + p.last_name AS patient_name,
	DATEDIFF(HOUR, a.start_time, a.stop_time) total_day,
    cast(DATEDIFF(DAY, a.start_time, a.stop_time) as varchar) + ' days' AS total_days
FROM patients_demographics p
JOIN admissions a ON p.id = a.patient_id
ORDER BY total_day DESC;

