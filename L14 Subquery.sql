-- Subquery Questions 

USE Olympics;
SELECT * FROM Olympics;

-- 1. Display the names of athletes who won a gold medal in the 2008 Olympics and whose height is greater than the average height of all athletes 
-- in the 2008 Olympics.
SELECT Name FROM Olympics WHERE Medal="Gold" AND Year = 2008 AND  Height > (SELECT AVG(Height) FROM Olympics WHERE Year = 2008);

-- 2. Display the names of athletes who won a medal in the sport of basketball in the 2016 Olympics and whose weight is less than the average 
-- weight of all athletes who won a medal in the 2016 Olympics.
SELECT Name FROM Olympics WHERE Sport="BasketBall" AND Year=2016 AND Medal <> '' AND Weight < (SELECT AVG(Weight) FROM Olympics WHERE Year = 2016 AND Medal <> '');

-- 3. Display the names of all athletes who have won a medal in the sport of swimming in both the 2008 and 2016 Olympics.
SELECT DISTINCT(t1.Name) FROM (SELECT * FROM Olympics WHERE Year = 2008 AND Medal<>'' AND Sport = 'Swimming') AS t1 INNER JOIN (SELECT * FROM Olympics WHERE Year = 2016 AND 
Medal <> '' AND Sport = 'Swimming') AS t2 ON t1.Name = t2.Name AND t1.country = t2.country;

-- 4. Display the names of all countries that have won more than 50 medals in a single year.
SELECT country,year,count(*) FROM Olympics WHERE medal <> '' GROUP BY country,year HAVING  COUNT(*)>50 ORDER BY year,country;

-- 5. Display the names of all athletes who have won more than one medals in same sport in the same year.
SELECT DISTINCT(name) FROM olympics WHERE id IN (SELECT id FROM Olympics WHERE medal <> '' GROUP BY id,year,sport HAVING COUNT(*)>1);

USE insurance;
SELECT * FROM insuranceData;

-- 6. How many patients have claimed more than the average claim amount for patients who are smokers and have at least one child, and belong to the 
-- southeast region?
SELECT COUNT(*) FROM insuranceData WHERE claim > (SELECT AVG(claim) FROM insuranceData WHERE smoker="Yes" AND children>=1 AND region = "southeast");

-- 7. How many patients have claimed more than the average claim amount for patients who are not smokers and have a BMI greater than the average BMI 
-- for patients who have at least one child?
SELECT COUNT(*) FROM insuranceData WHERE claim > (SELECT AVG(claim) FROM insuranceData WHERE smoker = "No" AND bmi > (SELECT AVG(bmi) FROM insuranceData WHERE children >= 1));

-- 8. How many patients have claimed more than the average claim amount for patients who have a BMI greater than the average BMI for patients who 
-- are diabetic, have at least one child, and are from the southwest region?
SELECT COUNT(*) FROM insuranceData WHERE claim > (SELECT AVG(claim) FROM insuranceData WHERE bmi > (SELECT AVG(bmi) FROM insuranceData WHERE diabetic="Yes" AND children >= 1 AND 
region = "southwest"));

-- 9. What is the difference in the average claim amount between patients who are smokers and patients who are non-smokers, and have the same BMI 
-- and number of children?

WITH Smoker AS (SELECT * FROM insuranceData WHERE smoker='Yes'),NoSmoker AS (SELECT * FROM insuranceData WHERE smoker='No')
SELECT ROUND(AVG(A.claim) - AVG(B.claim),2) FROM smoker A INNER JOIN NoSmoker B ON A.bmi = B.bmi AND A.children = B.children;
