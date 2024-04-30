-- Data Cleaning And Date Time Function In SQL

USE assignment;
SELECT * FROM laptop;
SET SQL_SAFE_UPDATES = 0;

-- Create Backup
CREATE TABLE laptop_backup LIKE laptop;
INSERT INTO laptop_backup SELECT * FROM laptop;
SELECT * FROM laptop_backup;

-- Check memory consumption
SELECT DATA_LENGTH/1024 AS "KB"  FROM information_schema.TABLES WHERE TABLE_SCHEMA = 'laptop' AND TABLE_NAME = 'laptop';

-- Drop non-important column
ALTER TABLE laptop DROP COLUMN `Unnamed: 0`;

-- Drop Null Values
DELETE FROM laptop WHERE id IN (SELECT * FROM (SELECT id FROM laptop WHERE Company IS NULL AND TypeName IS NULL AND Inches IS NULL AND 
ScreenResolution IS NULL AND Cpu IS NULL AND Ram IS NULL AND Memory  IS NULL AND Gpu IS NULL AND OpSys IS NULL AND Weight IS NULL AND 
Price IS NULL) AS t);

-- Drop Duplicates
SELECT Company,TypeName,Inches,ScreenResolution,Cpu,Ram,Memory,Gpu,OpSys,Weight,Price,COUNT(*) FROM laptop GROUP BY Company,TypeName,
Inches,ScreenResolution,Cpu,Ram,Memory,Gpu,OpSys,Weight,Price HAVING COUNT(*) > 1;

DELETE FROM laptop WHERE id NOT IN (SELECT * FROM (SELECT MIN(id) FROM laptop GROUP BY Company,TypeName,Inches,ScreenResolution,Cpu,Ram,
Memory,Gpu,OpSys,Weight,Price) AS t);

-- Inches -> Change Column DataType
ALTER TABLE laptop MODIFY COLUMN Inches DECIMAL(10,1);

-- Clean Ram -> Change Column DataType
UPDATE laptop l1 SET Ram = REPLACE(Ram,"GB","");
ALTER TABLE laptop MODIFY COLUMN Ram INT;

-- Clean Weight -> Change Column DataType
UPDATE laptop l1 SET Weight = REPLACE(Weight,"kg","");
ALTER TABLE laptop MODIFY COLUMN Weight DECIMAL(10,2);

-- Round Price Column And Change TO Integer 
ALTER TABLE laptop MODIFY COLUMN Price INT;
UPDATE laptop SET price = ROUND(price);

-- Change The OpSys Column
UPDATE laptop SET OpSys = 
CASE
	WHEN OpSys LIKE '%mac%' THEN 'macos'
    WHEN OpSys LIKE 'windows%' THEN 'windows'
    WHEN OpSys LIKE '%linux%' THEN 'linux'
    WHEN OpSys = 'No OS' THEN 'N/A'
    ELSE 'other'
END;

-- Clean Gpu -> Split Gpu Column
ALTER TABLE laptop ADD COLUMN gpu_brand VARCHAR(255) AFTER Gpu,ADD COLUMN gpu_name VARCHAR(255) AFTER gpu_brand;
UPDATE laptop SET gpu_brand = SUBSTRING_INDEX(Gpu,' ',1);
UPDATE laptop l1 SET gpu_name = REPLACE(Gpu,gpu_brand,'');
ALTER TABLE laptop DROP COLUMN Gpu;
ALTER TABLE laptop DROP COLUMN gpu_name;

-- Clean Cpu -> Split Cpu Column
ALTER TABLE laptop ADD COLUMN cpu_brand VARCHAR(255) AFTER Cpu,ADD COLUMN cpu_name VARCHAR(255) AFTER cpu_brand,ADD COLUMN cpu_speed 
DECIMAL(10,1) AFTER cpu_name;
UPDATE laptop l1 SET cpu_brand = SUBSTRING_INDEX(Cpu,' ',1);
UPDATE laptop l1 SET cpu_speed = CAST(REPLACE(SUBSTRING_INDEX(Cpu,' ',-1),'GHz','') AS DECIMAL(10,2));
UPDATE laptop l1 SET cpu_name = REPLACE(REPLACE(Cpu,cpu_brand,''),SUBSTRING_INDEX(REPLACE(Cpu,cpu_brand,''),' ',-1),'');
UPDATE laptop SET cpu_name = SUBSTRING_INDEX(TRIM(cpu_name),' ',2);
ALTER TABLE laptop DROP COLUMN cpu;

-- Clean  ScreenResolution -> Split ScreenResolution Column

ALTER TABLE laptop ADD COLUMN resolution_width INT AFTER ScreenResolution,ADD COLUMN resolution_height INT AFTER resolution_width;
ALTER TABLE laptop ADD COLUMN touchScreen INT AFTER resolution_height;
UPDATE laptop SET resolution_width = SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',1),resolution_height = 
SUBSTRING_INDEX(SUBSTRING_INDEX(ScreenResolution,' ',-1),'x',-1);
UPDATE laptop SET touchScreen = ScreenResolution LIKE '%Touch%';
ALTER TABLE laptop DROP COLUMN ScreenResolution;

-- Clean  Memory -> Split ScreenResolution Column
ALTER TABLE laptop ADD COLUMN memory_type VARCHAR(255) AFTER memory,ADD COLUMN primary_storage INT AFTER memory_type,ADD COLUMN 
secondary_storage INT AFTER primary_storage;
UPDATE laptop SET memory_type = 
CASE
	WHEN memory LIKE "%SSD%" AND memory LIKE "%HDD%" THEN "Hybrid"
    WHEN memory LIKE "%Flash Storage%" AND memory LIKE "%HDD%" THEN "Hybrid"
    WHEN memory LIKE "%Flash Storage%" AND memory LIKE "%SSD%" THEN "Hybrid"
    WHEN memory LIKE "%Flash Storage%" THEN "FLash Storage"
    WHEN memory LIKE "%Hybrid%" THEN "Hybrid"
    WHEN memory LIKE "%SSD%" THEN "SSD"
    WHEN memory LIKE "%HDD%" THEN "HDD"
    ELSE NULL
END;
UPDATE laptop SET primary_storage = REGEXP_SUBSTR(SUBSTRING_INDEX(memory,"+",1),'[0-9]+'),secondary_storage = CASE WHEN memory LIKE 
'%+%' THEN REGEXP_SUBSTR(SUBSTRING_INDEX(memory,"+",-1),'[0-9]') ELSE 0 END;
UPDATE laptop SET primary_storage = CASE WHEN primary_storage <= 2 THEN primary_storage * 1024 ELSE primary_storage END,secondary_storage 
= CASE WHEN secondary_storage <= 2 THEN secondary_storage * 1024 ELSE secondary_storage END;
ALTER TABLE laptop DROP COLUMN memory;

-- Date And Time Function

SELECT * FROM flights;

-- Find the month with most number of flights.
SELECT MONTHNAME(date_of_journey),COUNT(*) FROM flights GROUP BY MONTHNAME(date_of_journey) ORDER BY COUNT(*) DESC LIMIT 1;

-- Which week day has most costly flights.
SELECT DAYNAME(date_of_journey),AVG(price) FROM flights GROUP BY DAYNAME(date_of_journey) ORDER BY AVG(price) DESC LIMIT 1;

-- Find the number of indigo flights every month
SELECT MONTHNAME(date_of_journey),COUNT(*) FROM flights WHERE airline = "indigo" GROUP BY MONTHNAME(date_of_journey);

-- Find list of flights that depart between 10AM and 2PM from Bangalore to Delhi.
SELECT * FROM flights WHERE Destination = "Delhi" AND Source = "Banglore" AND Dep_Time > '10:00:00' AND Dep_Time < '14:00:00';

-- Find the number of flights departing on weekends from Bangalore.
SELECT COUNT(*) FROM flights WHERE Source = 'Banglore' AND DAYNAME(date_of_journey) in ("saturday","sunday");

-- Calculate the arrival time for all flights by adding the duration to the departure time.
ALTER TABLE flights ADD COLUMN departure DATETIME;
UPDATE flights SET departure = STR_TO_DATE(CONCAT(Date_of_Journey,' ',Dep_Time),'%Y-%m-%d %H:%i');
ALTER TABLE flights ADD COLUMN arrival DATETIME;
UPDATE flights SET arrival = DATE_ADD(departure,INTERVAL duration MINUTE);
SELECT TIME(arrival) FROM flights;

-- Calculate the arrival time for all the flights.
SELECT DATE(arrival) FROM flights;

-- Find the number of flights which travel on multiple dates.
SELECT COUNT(*) FROM flights WHERE DATE(departure) <> DATE(arrival);

-- Calculate the average duration of flights between all city pairs.
SELECT source,destination,AVG(duration) FROM flights GROUP BY source,destination;
SELECT source,destination,TIME_FORMAT(SEC_TO_TIME(AVG(duration)*60),'%kh:%im') AS AverageDuration FROM flights GROUP BY source,
destination;

-- Find all flights which departed before midnight but arrived at their destination after midnight having only 1 stop.
SELECT * FROM flights WHERE Total_Stops = 'non-stop' AND DATE(departure)<DATE(arrival);

-- Find quarter wise number of flights for each airline.
SELECT airline,QUARTER(departure),COUNT(*) FROM flights GROUP BY airline,QUARTER(departure);

-- Find the longest flight distance(between cities in terms of time) in India.
SELECT source,destination,AVG(duration) FROM flights GROUP BY source,destination ORDER BY AVG(duration) DESC LIMIT 1;

-- Average time duration for flights that have 1 stop vs more than 1 stops.
WITH temp_table AS(SELECT *,
CASE
	WHEN total_stops = "non-stop" THEN "non-stop"
    ELSE "with stop"
END AS temp
FROM flights)
SELECT temp,TIME_FORMAT(SEC_TO_TIME(AVG(duration)*60),"%kh : %im") AS AvearageDuration FROM temp_table GROUP BY temp;

-- Find all Air India flights in a given date range originating from  Delhi.
SELECT * FROM flights WHERE source = "Delhi" AND DATE(departure) BETWEEN '2019-03-01' AND '2019-03-10';

-- Find the longest flight of each airline.
SELECT airline,TIME_FORMAT(SEC_TO_TIME(MAX(Duration)*60),"%kh : %im") AS MaxDuration FROM flights GROUP BY Airline ORDER BY MaxDuration 
DESC;

-- Find all the pair of cities having average time duration > 3 hours.
SELECT source,destination,TIME_FORMAT(SEC_TO_TIME(AVG(Duration)*60),"%kh : %im") AS AverageDuration FROM flights GROUP BY source,
destination HAVING AVG(duration) > 180; 

-- Make a weekday vs time grid showing frequency of flights from Banglore to Delhi.
SELECT DAYNAME(departure),
SUM(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN 1 ELSE 0 END) AS "12AM - 6AM",
SUM(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN 1 ELSE 0 END) AS "6AM - 12PM",
SUM(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN 1 ELSE 0 END) AS "12PM - 6PM",
SUM(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN 1 ELSE 0 END) AS "18PM - 12PM"
FROM flights WHERE source = "Banglore" AND destination = "Delhi" GROUP BY DAYNAME(departure);

-- Make a weekday vs time grid showing avg flight price from Banglore and Delhi.
SELECT DAYNAME(departure),
AVG(CASE WHEN HOUR(departure) BETWEEN 0 AND 5 THEN price  ELSE NULL END) AS "12AM - 6AM",
AVG(CASE WHEN HOUR(departure) BETWEEN 6 AND 11 THEN price ELSE NULL END) AS "6AM - 12PM",
AVG(CASE WHEN HOUR(departure) BETWEEN 12 AND 17 THEN price ELSE NULL END) AS "12PM - 6PM",
AVG(CASE WHEN HOUR(departure) BETWEEN 18 AND 23 THEN price ELSE NULL END) AS "18PM - 12PM"
FROM flights WHERE source = "Banglore" AND destination = "Delhi" GROUP BY DAYNAME(departure);