-- Data Manipulation Language

CREATE DATABASE insurance;
USE insurance;
SET SQL_SAFE_UPDATES = 0;
SELECT * FROM insurance;
DROP TABLE insurance;

-- 1. Show records of 'male' patient from 'southwest' region.
SELECT * FROM insurance WHERE gender='male' AND region="southwest";

-- 2. Show all records having bmi in range 30 to 45 both inclusive.
SELECT * FROM insurance WHERE bmi BETWEEN 30 AND 45;

-- 3. Show minimum and maximum bloodpressure of diabetic patient who smokes. Make column names as MinBP and MaxBP respectively.
SELECT MIN(bloodpressure) AS MinBP,MAX(bloodpressure) AS MaxBP FROM insurance WHERE diabetic="Yes" AND smoker="Yes";

-- 4. Find no of unique patients who are not from southwest region.
SELECT COUNT(DISTINCT PatientID) FROM insurance WHERE region <> "southwest";

-- 5. Total claim amount from male smoker.
SELECT SUM(claim) AS TotalClaim FROM insurance WHERE gender="male" AND smoker="Yes";

-- 6. Select all records of south region.
SELECT * FROM insurance WHERE region IN ("southeast","southwest");

-- 7. No of patient having normal blood pressure. Normal range[90-120]
SELECT COUNT(*) FROM insurance WHERE bloodpressure between 90 AND 120;

-- 8. No of pateint below 17 years of age having normal blood pressure as per below formula -
--   a) BP normal range = 80+(age in years × 2) to 100 + (age in years × 2)
--   Note: Formula taken just for practice, don't take in real sense.
SELECT COUNT(*) FROM insurance WHERE age<17 AND bloodpressure BETWEEN 80+age*2 AND 100+age*2;

-- 9. What is the average claim amount for non-smoking female patients who are diabetic?
SELECT AVG(claim) FROM insurance WHERE gender = "female" AND smoker="No" AND diabetic="Yes";

-- 10. Write a SQL query to update the claim amount for the patient with PatientID = 1234 to 5000.
UPDATE insurance SET claim = 5000  WHERE patientid=1234;

-- 11. Write a SQL query to delete all records for patients who are smokers and have no children.
DELETE FROM insurance WHERE smoker = "Yes"  AND children = 0;