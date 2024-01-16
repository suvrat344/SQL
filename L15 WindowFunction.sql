-- Window Function

USE insurance;
SELECT * FROM insuranceData;

-- 1. What are the top 5 patients who claimed the highest insurance amounts?
SELECT *,DENSE_RANK() OVER(ORDER BY claim DESC) AS Ranking FROM insuranceData LIMIT 5;

-- 2. What is the average insurance claimed by patients based on the number of children they have?
SELECT children,AverageClaim FROM (SELECT *,AVG(claim) OVER(PARTITION BY children) AS AverageClaim,ROW_NUMBER() OVER(PARTITION BY children) AS row_num FROM insuranceDATA) AS t
WHERE t.row_num = 1;

-- 3. What is the highest and lowest claimed amount by patients in each region?
SELECT t.region,t.min_claim,t.max_claim FROM (SELECT *,MIN(claim) OVER(PARTITION BY region) AS min_claim,MAX(claim) OVER(PARTITION BY region) AS max_claim,ROW_NUMBER() OVER(
PARTITION BY region) AS row_num FROM insuranceData) AS t WHERE t.row_num = 1;

-- 4. What is the difference between the claimed amount of each patient and the first claimed amount of first patient?
SELECT *,claim - FIRST_VALUE(claim) OVER() AS diff FROM insuranceData;

-- 5. For each patient, calculate the difference between their claimed amount and the average claimed amount of patients with the same number of children.
SELECT * ,claim - AVG(claim) OVER(PARTITION BY children) AS diff FROM insuranceData;

-- 6. Show the patient with the highest BMI in each region and their respective rank.
SELECT * FROM (SELECT *,RANK() OVER(PARTITION BY region ORDER BY bmi DESC) AS group_rank,RANK() OVER(ORDER BY bmi DESC) AS overall_rank FROM insuranceData) AS t WHERE t.group_rank
= 1;

-- 7. Calculate the difference between the claimed amount of each patient and the claimed amount of the patient who has the highest BMI in their region.
SELECT *, claim - FIRST_VALUE(claim) OVER(PARTITION BY region ORDER BY bmi DESC) AS diff FROM insuranceData;

-- 8. For each patient, calculate the difference in claim amount between the patient and the patient with the highest claim amount and smoker status, within the same region. Return
-- the result in descending order difference.
SELECT *,MAX(claim) OVER(PARTITION BY region,smoker) -claim AS  claim_diff FROM insuranceData ORDER BY claim_diff DESC;

-- 9. For each patient, find the maximum BMI value among their next three records (ordered by age).
SELECT *,MAX(bmi) OVER(ORDER BY age ROWS BETWEEN 1 FOLLOWING AND 3 FOLLOWING) FROM insuranceData;

-- 10. For each patient, find the rolling average of the last 2 claims.
SELECT *,AVG(claim) OVER(ROWS BETWEEN 2 PRECEDING AND 1 PRECEDING) FROM insuranceData;  

-- 11. Find the first claimed insurance value for male and female patients, within each region order the data by patient age in ascending order, and only include patients who are 
-- non-diabetic and have a bmi value between 25 and 30.
WITH filtered_data AS (SELECT * FROM insuranceData WHERE diabetic="No" AND bmi BETWEEN 25 AND 30)
SELECT t.region,t.gender,t.first_claim FROM (SELECT *,FIRST_VALUE(claim) OVER(PARTITION BY region,gender ORDER BY age ASC) AS first_claim,ROW_NUMBER() OVER(PARTITION BY region,
gender ORDER BY age ASC) AS row_num FROM filtered_data) AS t WHERE t.row_num=1;

USE nw;
SELECT * FROM nw_employees;
SELECT * FROM nw_order_details;
SELECT * FROM nw_orders;
SELECT * FROM nw_products;
SELECT * FROM nw_suppliers;

-- 12. Rank Employee in terms of revenue generation. Show employee id, first name, revenue, and rank
SELECT e.EmployeeID,e.FirstName,SUM(od.UnitPrice * od.Quantity) AS Revenue,RANK() OVER(ORDER BY SUM(od.UnitPrice * od.Quantity) DESC) AS EmpRank FROM nw_orders o INNER JOIN 
nw_order_details od USING(OrderID) INNER JOIN nw_employees e USING(EmployeeID) GROUP BY e.EmployeeID,e.firstName ORDER BY EmpRank;

-- 13. Show All products cumulative sum of units sold each month.
SELECT p.ProductID,MONTHNAME(o.OrderDate) AS "Month",SUM(od.Quantity) AS "QuantitySum",SUM(SUM(od.Quantity)) OVER(PARTITION BY p.ProductID ORDER BY MONTHNAME(o.OrderDate)) AS 
"QuantityCumulativeSum" FROM nw_orders o INNER JOIN nw_order_details od USING(OrderID) INNER JOIN nw_products p USING(ProductID) GROUP BY p.ProductID,MONTHNAME(o.OrderDate);

-- 14. Show Percentage of total revenue by each suppliers
SELECT s.SupplierID,ROUND(SUM(od.UnitPrice * od.Quantity),2) AS Revenue,ROUND(SUM(od.UnitPrice * od.Quantity) / SUM(SUM(od.UnitPrice * od.Quantity)) OVER() * 100,2)  AS 
"PercentTotalRevenue" FROM nw_suppliers s INNER JOIN nw_products p USING(SupplierID) INNER JOIN nw_order_details od USING(productID) GROUP BY s.SupplierID;

-- 15. Show Percentage of total orders by each suppliers
SELECT s.SupplierID,COUNT(DISTINCT OrderID) AS TotalOrder,ROUND(COUNT(DISTINCT OrderID)/SUM(COUNT(DISTINCT OrderID)) OVER() * 100,2) AS PercentOfTotalOrder FROM nw_suppliers s
INNER JOIN nw_products p INNER JOIN nw_order_details od USING(ProductID) GROUP BY s.SupplierID ORDER BY TotalOrder DESC;

-- 16. Show All Products Year Wise report of totalQuantity sold, percentage change from last year.
SELECT *,ROUND(100*(t.TotalQuantity - LAG(t.TotalQuantity) OVER (PARTITION BY t.ProductID ORDER BY t.ProductID))/ LAG(t.TotalQuantity) OVER (PARTITION BY t.ProductID ORDER BY 
t.ProductID),2) AS PercentChange FROM (SELECT p.ProductID,YEAR(OrderDate),SUM(od.Quantity) AS TotalQuantity FROM nw_orders AS o INNER JOIN nw_order_details AS od USING(OrderID) 
INNER JOIN nw_products AS p USING(ProductID) GROUP BY p.ProductID,YEAR(OrderDate) ORDER BY p.ProductID,YEAR(OrderDate)) AS t;

USE drug;
SELECT * FROM drug;

-- 17. For each condition, what is the average satisfaction level of drugs that are "On Label" vs "Off Label"?
WITH temp AS (SELECT drug.Condition,drug.Indication,drug.Satisfaction,ROUND(AVG(drug.Satisfaction) OVER(PARTITION BY drug.Condition,drug.Indication ORDER BY drug.Satisfaction ROWS BETWEEN 
UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),2) AS AverageSatisfaction,DENSE_RANK() OVER(PARTITION BY drug.Condition,drug.indication ORDER BY drug.Satisfaction) AS rank_num
FROM drug) 
SELECT temp.Condition,temp.Indication,temp.Satisfaction FROM temp WHERE rank_num=1;

-- 18.  For each drug type (RX, OTC, RX/OTC), what is the average ease of use and satisfaction level of drugs with a price above the median for their type?

-- 19. What is the cumulative distribution of EaseOfUse ratings for each drug type (RX, OTC, RX/OTC)? Show the results in descending order by drug type and cumulative 
-- distribution. (Use the built-in method and the manual method by calculating on your own. For the manual method, use the "ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW" and 
-- see if you get the same results as the built-in method.)
SELECT type,EaseOfUse,COUNT(*) OVER(PARTITION BY type ORDER BY EaseOfUse ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) * 1 / COUNT(*) OVER(PARTITION BY type) AS 
"Cumulative_dist",CUME_DIST() OVER(PARTITION BY type ORDER BY EaseOfUse) AS "Percentile_Score" FROM drug WHERE type IN ("RX","OTC","RX/OTC") ORDER BY type,Cumulative_dist;

-- 20. What is the median satisfaction level for each medical condition? Show the results in descending order by median satisfaction level. (Don't repeat the same rows of your 
-- result.)

-- 21. What is the running average of the price of drugs for each medical condition? Show the results in ascending order by medical condition and drug name.
SELECT drug.Condition,drug.drug,ROUND(drug.Price,2),ROUND(AVG(drug.Price) OVER(PARTITION BY drug.Condition ORDER BY drug.drug ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2)
AS running_avg_price FROM drug ORDER BY drug.Condition ASC,drug.drug ASC;

-- 22. What is the percentage change in the number of reviews for each drug between the previous row and the current row? Show the results in descending order by percentage change.
SELECT drug.Condition,drug.drug,ROUND(drug.Reviews,2),ROUND(drug.Reviews - LAG(drug.Reviews) OVER(PARTITION BY drug.Condition,drug.drug ORDER BY drug.Reviews DESC) * 100 / 
LAG(drug.Reviews) OVER(PARTITION BY drug.Condition,drug.drug ORDER BY drug.Reviews DESC),2) AS "pctChange" FROM drug ORDER BY pctChange DESC;

-- 23. What is the percentage of total satisfaction level for each drug type (RX, OTC, RX/OTC)? Show the results in descending order by drug type and percentage of total 
-- satisfaction.  
WITH temp AS (SELECT type,ROUND(Satisfaction,2) AS "Satisfaction",ROUND(SUM(Satisfaction) OVER(PARTITION BY type) / SUM(Satisfaction) OVER(),2) AS "pct_total_satisfaction" FROM 
drug WHERE type IN ("RX","OTC","RX/OTC") ORDER BY type ASC,pct_total_satisfaction DESC)
SELECT type,pct_total_satisfaction FROM temp GROUP BY type,pct_total_satisfaction;

-- 24. What is the cumulative sum of effective ratings for each medical condition and drug form combination? Show the results in ascending order by medical condition, drug form 
-- and the name of the drug.
SELECT drug.Condition,drug.Form,drug.drug,ROUND(drug.Effective,2),ROUND(SUM(drug.Effective) OVER(PARTITION BY drug.Condition,drug.Form ORDER BY drug.drug ROWS BETWEEN UNBOUNDED
PRECEDING AND CURRENT ROW),2) AS cumulative_sum_effective FROM drug ORDER BY drug.Condition ASC,drug.Form ASC,drug.drug ASC;

-- 25. What is the rank of the average ease of use for each drug type (RX, OTC, RX/OTC)? Show the results in descending order by rank and drug type.
SELECT type,AVG(EaseOfUse),RANK() OVER(ORDER BY AVG(EaseOfUse) DESC) AS 'rank' FROM drug WHERE type IN ('RX','OTC','RX/OTC') GROUP BY type;

-- 26. For each condition, what is the average effectiveness of the top 3 most reviewed drugs?

