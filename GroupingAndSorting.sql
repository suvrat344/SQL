-- Grouping and Sorting

USE assignment;
SELECT * FROM sleep_efficiency;

-- 1. Find out the average sleep duration of top 15 male candidates who's sleep duration are equal to 7.5 or greater than 7.5.
 SELECT 
    AVG(SleepDuration)
FROM
    sleep_efficiency
WHERE
    gender = 'Male' AND SleepDuration >= 7.5
ORDER BY SleepDuration DESC
LIMIT 15;
 
-- 2. Show avg deep sleep time for both gender. Round result at 2 decimal places.
-- Note: sleep time and deep sleep percentage will give you, deep sleep time.
SELECT 
    gender, AVG(DeepSleepPercentage * SleepDuration / 100)
FROM
    sleep_efficiency
GROUP BY gender;

-- 3. Find out the lowest 10th to 30th light sleep percentage records where deep sleep percentage values are between 25 to 45. Display age, light 
-- sleep percentage and deep sleep percentage columns only.
SELECT 
    age, LightSleepPercentage, DeepSleepPercentage
FROM
    sleep_efficiency
WHERE
    DeepSleepPercentage BETWEEN 25 AND 45
ORDER BY LightSleepPercentage
LIMIT 10 , 20;

-- 4. Group by on exercise frequency and smoking status and show average deep sleep time, average light sleep time and avg rem sleep time.
-- Note the differences in deep sleep time for smoking and non smoking status
SELECT 
    ExerciseFrequency,
    SmokingStatus,
    AVG(DeepSleepPercentage * SleepDuration / 100) AS DeepSleep,
    AVG(LightSleepPercentage * SleepDuration / 100),
    AVG(RemSleepPercentage * SleepDuration / 100)
FROM
    sleep_efficiency
GROUP BY ExerciseFrequency , SmokingStatus
ORDER BY DeepSleep;

-- 5. Group By on Awakening and show AVG Caffeine consumption, AVG Deep sleep time and AVG Alcohol consumption only for people who do exercise 
-- atleast 3 days a week. Show result in descending order awekenings
SELECT 
    AVG(CaffeineConsumption),
    AVG(DeepSleepPercentage * SleepDuration / 100),
    AVG(AlcoholConsumption)
FROM
    sleep_efficiency
WHERE
    ExerciseFrequency >= 3
GROUP BY awakenings
ORDER BY awakenings DESC;


SELECT * From powergeneration;

-- 6. Display those power stations which have average 'Monitored Cap.(MW)' (display the values) between 1000 and 2000 and the number of 
-- occurance of the power stations (also display these values) are greater than 200. Also sort the result in ascending order. 
SELECT 
    `Power Station`,
    AVG(`Monitored Cap.(MW)`) AS 'AverageMonitoredCap',
    COUNT(*) AS occurence
FROM
    powergeneration
GROUP BY `Power Station`
HAVING AverageMonitoredCap BETWEEN 1000 AND 2000
    AND occurence > 200
ORDER BY AverageMonitoredCap ASC;


SELECT * FROM nces;

-- 7. Display top 10 lowest "value" State names of which the Year either belong to 2013 or 2017 or 2021 and type is 'Public In-State'. Also the number 
-- of occurance should be between 6 to 10. Display the average value upto 2 decimal places, state names and the occurance of the states.
SELECT 
    state,
    ROUND(AVG(value), 2) AS AvgValue,
    COUNT(*) AS frequency
FROM
    nces
WHERE
    type = 'Public In-State'
        AND year IN (2013 , 2017, 2021)
GROUP BY state
HAVING frequency BETWEEN 6 AND 10
ORDER BY AvgValue ASC
LIMIT 10;

-- 8. Best state in terms of low education cost (Tution Fees) in 'Public' type university.
SELECT 
    state, AVG(value) AS AverageValue
FROM
    nces
WHERE
    type LIKE '%Public%'
        AND expense LIKE '%Tuition%'
GROUP BY state
ORDER BY AverageValue ASC
LIMIT 1;

-- 9. 2nd Costliest state for Private education in year 2021. Consider, Tution and Room fee both.
SELECT 
    state, AVG(value) AS AverageValue
FROM
    nces
WHERE
    type LIKE 'Private' AND year = 2021
GROUP BY state
ORDER BY AverageValue DESC
LIMIT 1 , 1;


SELECT * FROM ECommerceShipping;

-- 10. Display total and average values of Discount_offered for all the combinations of 'Mode_of_Shipment' (display this feature) and 'Warehouse_block' 
-- (display this feature also) for all male ('M') and 'High' Product_importance. Also sort the values in descending order of Mode_of_Shipment and 
-- ascending order of Warehouse_block.
SELECT 
    Mode_of_Shipment,
    Warehouse_block,
    SUM(Discount_offered),
    AVG(Discount_offered)
FROM
    ECommerceShipping
WHERE
    gender = 'M'
        AND Product_importance = 'High'
GROUP BY mode_of_shipment , Warehouse_block
ORDER BY Mode_of_Shipment DESC , Warehouse_block ASC;