-- Case Study on Data Science Job

CREATE DATABASE CaseStudy;
USE CaseStudy;
SELECT * FROM salaries;

-- 1. You're a Compensation analyst employed by a multinational corporation. Your Assignment is to Pinpoint Countries who give work 
-- fully remotely, for the title 'managers’ Paying salaries Exceeding $90,000 USD
SELECT 
	DISTINCT company_location 
FROM 
	salaries
WHERE 
	remote_ratio = 100 
		AND 
	salary > 90000 
		and 
	job_title REGEXP "\\b[mM]anager\\b";


-- 2. AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms. you're 
-- tasked WITH Identifying top 5 Country Having greatest count of large (company size) number of companies.
SELECT 
	company_location,
    count(company_location) AS "Total" 
FROM 
	salaries 
WHERE 
	company_size = 'L'
		AND 
	experience_level="EN" 
GROUP BY 
	company_location 
ORDER BY 
	total DESC LIMIT 5;


-- 3. Picture yourself AS a data scientist working for a workforce management platform. Your objective is to calculate the percentage of 
-- employees who enjoy fully remote roles with salaries exceeding $100,000 USD, shedding light on the attractiveness of high-paying remote
--  positions iN today's job market.
set @total = (SELECT COUNT(*) FROM salaries WHERE salary > 100000);
set @count = (SELECT COUNT(*) FROM salaries WHERE remote_ratio=100 AND salary > 100000);
SELECT 
	ROUND(((SELECT @count)/(SELECT @total))* 100,2) AS "Percentage";
--                                    OR
SELECT 
	ROUND(COUNT(*)/(SELECT COUNT(*) FROM salaries WHERE salary > 100000) * 100,2) "Percentage" 
FROM 
	salaries 
WHERE 
	remote_ratio = 100 
		AND 
	salary > 100000;


-- 4. Imagine you're a data analyst working for a global recruitment agency. Your Task is to identify the locations where average salaries 
-- exceed the average salary for that job title in market for entry level, helping your agency guide candidates towards  lucrative 
-- opportunities.
SELECT 
	job_title,
    company_location,
    average_salary,average_per_country_salary 
FROM
(
	SELECT  
		job_title,
        AVG(salary) AS "average_salary" 
	FROM
		salaries 
	GROUP BY 
		job_title
) AS t
INNER JOIN 
(
	SELECT 
		job_title,
		company_location,
        AVG(salary) AS "average_per_country_salary" 
	FROM 
		salaries 
	GROUP BY 
		job_title,
        company_location
) AS m USING(job_title) 
WHERE 
	average_per_country_salary > average_salary ;


-- 5. You've been hired by a big HR Consultancy to look at how much people get paid in different countries. Your job is to find out for 
-- each job title which country pays the maximum average salary. This helps you to place your candidates in those countries.
SELECT 
	job_title,
    company_location 
FROM
(
	SELECT 
		job_title,
        company_location,
        DENSE_RANK() OVER(PARTITION BY job_title ORDER BY AverageSalaryCountry DESC) AS "Ranking" 
	FROM 
	(
		SELECT 
			job_title,
            company_location,
            AVG(salary) AS "AverageSalaryCountry" 
		FROM 
			salaries 
		GROUP BY 
			job_title,
            company_location
	) AS t1
) AS t2 
WHERE 
	Ranking=1;


-- 6. As a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different 
-- company locations. Your goal is to pinpoint locations where the average salary has consistently increased over the past few years 
-- (countries where data is available for 3 years only(present year and past two years) providing insights into locations experiencing 
-- sustained salary growth.
WITH temp AS 
(
	SELECT 
		* 
	FROM 
		salaries 
	WHERE company_location in
		(
			SELECT 
				company_location 
			FROM
			(
				SELECT 
					company_location,
                    AVG(salary),
                    COUNT(DISTINCT work_year) as "cnt" 
				FROM 
					salaries 
				WHERE 
					work_year >= (year(CURRENT_DATE) -2) 
			GROUP BY 
				company_location 
			HAVING 
				cnt=3
		) AS t
	)
)
SELECT 
	company_location,
	MAX(CASE WHEN work_year = 2022 THEN average END) AS "Avg_Salary_2022",
    MAX(CASE WHEN work_year = 2023 THEN average END) AS "Avg_Salary_2023",
    MAX(CASE WHEN work_year = 2024 THEN average END) AS "Avg_Salary_2024"
FROM 
(
	SELECT 
		company_location,
        work_year,
        AVG(salary) AS "Average" 
	FROM 
		temp 
	GROUP BY 
		company_location,
        work_year
) AS q 
GROUP BY 
	company_location 
HAVING 
	Avg_Salary_2024 > Avg_Salary_2023 
		AND 
	Avg_Salary_2023 > Avg_Salary_2022
;


-- 7. Picture yourself AS a workforce strategist employed by a global HR tech startup. Your mission is to determine the percentage of 
-- fully remote work for each experience level IN 2021 and compare it with the corresponding figures for 2024, highlighting any 
-- significant increases or decreases in remote work adoption over the years.
SELECT * FROM
(
	SELECT 
		experience_level,
        (cnt2021/total2021)*100 as "Remote2021"
	FROM
	(
		SELECT 
			experience_level,
            COUNT(*) AS "Total2021" 
		FROM 
			salaries 
		WHERE 
			work_year=2021 
		GROUP BY 
			experience_level
	) AS t1
	INNER JOIN
	(
		SELECT 
			experience_level,
            COUNT(*) AS "CNT2021" 
		FROM 
			salaries
		WHERE 
			work_year=2021 
				AND 
			remote_ratio=100 
		GROUP BY 
			experience_level
	) AS t2 USING(experience_level)
) AS temp1
INNER JOIN
(
	SELECT 
		experience_level,
        (cnt2024/total2024)*100 as "Remote2024"
	FROM
		(
			SELECT 
				experience_level,
                COUNT(*) AS "Total2024" 
			FROM 
				salaries 
            WHERE 
				work_year=2024 
			GROUP BY 
				experience_level
		) AS t1
	INNER JOIN
	(
		SELECT 
			experience_level,
            COUNT(*) AS "CNT2024" 
		FROM 
			salaries 
		WHERE 
			work_year=2024 
				AND 
			remote_ratio=100 
		GROUP BY 
			experience_level
	) AS t2 USING(experience_level)
) AS temp2 USING(experience_level);


-- 8. As a Compensation specialist at a Fortune 500 company, you're tasked with analyzing salary trends over time. Your objective is to 
-- calculate the average salary increase percentage for each experience level and job title between the years 2023 and 2024, helping the
-- company stay competitive in the talent market.
WITH temp AS 
(
	SELECT 
		experience_level,
        job_title,
        work_year,
        AVG(salary) AS "Average" 
	FROM 
		salaries 
	WHERE 
		work_year IN (2023,2024) 
	GROUP BY 
		experience_level,
        job_title,
        work_year
)
SELECT 
	*,
    ROUND(((AvgSalary2024 - AvgSalary2023) / AvgSalary2023) * 100,2) AS "Percent Change" 
FROM
(
	SELECT 
		experience_level,
        job_title,
		MAX(case WHEN work_year=2023 THEN average END) AS AvgSalary2023,
		MAX(case WHEN work_year=2024 THEN average END) AS AvgSalary2024
	FROM 
		temp 
	GROUP BY 
		experience_level,
        job_title
) AS a 
WHERE 
	((AvgSalary2024 - AvgSalary2023) / AvgSalary2023) * 100 IS NOT NULL
;


-- 9. You're a database administrator tasked with role-based access control for a company's employee database. Your goal is to implement
-- a security measure where employees in different experience level (e.g. Entry Level, Senior level etc.) can only access details relevant
-- to their respective experience level, ensuring data confidentiality and minimizing the risk of unauthorized access.
CREATE USER 'Entry_level'@'%' IDENTIFIED BY 'EN';
CREATE USER 'Junior_Mid_level'@'%' IDENTIFIED BY 'MI';
CREATE USER 'Intermediate_Senior_level'@'%' IDENTIFIED BY 'SE';
CREATE USER 'Expert Executive_level'@'%' IDENTIFIED BY 'EX';

CREATE VIEW entry_level AS
(
	SELECT 
		* 
	FROM 
		salaries 
	WHERE 
		experience_level="EN"
);
GRANT SELECT ON CaseStudy.Entry_Level TO 'Entry_level'@'%';


-- 10. You are working with a consultancy firm, your client comes to you with certain data and preferences such as (their year of 
-- experience , their employment type, company location and company size )  and want to make an transaction into different domain in data
-- industry (like  a person is working as a data analyst and want to move to some other domain such as data science or data engineering 
-- etc.) your work is to  guide them to which domain they should switch to base on  the input they provided, so that they can now update 
-- their knowledge as  per the suggestion/.. The Suggestion should be based on average salary.
DELIMITER //
CREATE PROCEDURE `GetAverageSalary`(IN exp_lev VARCHAR(2),IN emp_type VARCHAR(3),IN comp_loc VARCHAR(2),
IN comp_size VARCHAR(2))
BEGIN
	SELECT 
		job_title,
        experience_level,
        company_location,
        company_size,
        employment_type,
        ROUND(AVG(salary),2) AS avg_salary
    FROM 
		salaries 
	WHERE 
		experience_level = exp_lev 
			AND 
		company_location = comp_loc 
			AND 
		company_size = comp_size 
			AND
		employment_type = emp_type 
	GROUP BY 
		experience_level,
        employment_type,
        company_location,
        company_size,
        job_title 
    ORDER BY 
		avg_salary DESC;
END //
call GetAverageSalary('EN','FT','AU','M');


-- 11. As a market researcher, your job is to investigate the job market for a company that analyzes workforce data. Your task is to know
-- how many people were employed in different types of companies as per their size in 2021.
SELECT 
    company_size,
    COUNT(*)
FROM
    salaries
WHERE
    work_year = 2021
GROUP BY 
	company_size;


-- 12. Imagine you are a talent acquisition specialist working for an International recruitment agency. Your task is to identify the top 3
-- job titles that command the highest average salary among part-time positions in the year 2023.
SELECT 
    job_title, 
    AVG(salary) AS 'Avearge'
FROM
    salaries
WHERE
    work_year = 2023
        AND 
	employment_type = 'PT'
GROUP BY 
	job_title
ORDER BY 
	avearge DESC
LIMIT 3;


-- 13. As a database analyst you have been assigned the task to select countries where average mid-level salary is higher than overall 
-- mid-level salary for the year 2023.
set @average = (SELECT AVG(salary) FROM salaries WHERE experience_level = "MI" AND work_year=2023);
SELECT 
	DISTINCT company_location
FROM 
	salaries 
WHERE 
	experience_level = "MI" 
		AND 
	salary > @average;


-- 14. As a database analyst you have been assigned the task to identify the company locations with the highest and lowest average salary
-- for senior-level (SE) employees in 2023.

CREATE PROCEDURE `GetSeniorSalaryStats`()
BEGIN
    
	SELECT 
		company_location,
        AVG(salary)
	FROM 
		salaries 
	WHERE 
		work_year=2023
			AND
		experience_level = "SE"
	GROUP BY
		company_location 
	ORDER BY
		AVG(salary) DESC
	LIMIT 1;
    
	SELECT 
		company_location,
        AVG(salary)
	FROM 
		salaries 
	WHERE 
		work_year=2023
			AND
		experience_level = "SE"
	GROUP BY
		company_location 
	ORDER BY
		AVG(salary) ASC
	LIMIT 1;
END //
CALL GetSeniorSalaryStats();

-- 15. You're a Financial analyst working for a leading HR Consultancy, and your task is to assess the annual salary growth rate for 
-- various job titles.By calculating the percentage increase in salary from previous year to this year, you aim to provide valuable 
-- insights into salary trends within different job roles.
SELECT 
	t1.job_title, 
    ROUND(((avg2024-avg2023)/avg2023)*100,2) AS "Annual Salary Growth" 
FROM
(
	SELECT 
		job_title, 
        AVG(salary_IN_usd) AS avg2023
	FROM 
		salaries 
	WHERE 
		work_year = 2023 
	GROUP BY 
		job_title
) t1
INNER JOIN
(
	SELECT 
		job_title,
        AVG(salary_IN_usd) AS avg2024
	FROM 
		salaries 
	WHERE 
		work_year = 2024 
	GROUP BY 
		job_title
) t2 ON t1.job_title = t2.job_title


-- 16. You've been hired by a global HR Consultancy to identify countries experiencing significant salary growth for entry-level roles. 
-- Your task is to list the top three countries with the highest salary growth rate FROM 2021 to 2023, helping multinational corporations 
-- identify emerging talent markets.
WITH t AS
(
    SELECT 
        company_location, 
        work_year, 
        AVG(salary_in_usd) as average 
    FROM 
        salaries 
    WHERE 
        experience_level = 'EN' 
        AND (work_year = 2021 OR work_year = 2023)
    GROUP BY  
        company_location, 
        work_year
)
SELECT 
    *, 
    (((AVG_salary_2023 - AVG_salary_2021) / AVG_salary_2021) * 100) AS changes
FROM
(
    SELECT 
        company_location,
        MAX(CASE WHEN work_year = 2021 THEN average END) AS AVG_salary_2021,
        MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023
    FROM 
        t 
    GROUP BY 
        company_location
) a 
WHERE 
    (((AVG_salary_2023 - AVG_salary_2021) / AVG_salary_2021) * 100) IS NOT NULL  
ORDER BY 
    (((AVG_salary_2023 - AVG_salary_2021) / AVG_salary_2021) * 100) DESC 
    limit 3 ;
    
    
-- 17. Picture yourself as a data architect responsible for database management. Companies in US and AU(Australia) decided to create a 
-- hybrid model for employees they decided that employees earning salaries exceeding $90000 USD, will be given work from home. You now 
-- need to update the remote work ratio for eligible employees, ensuring efficient remote work management while implementing appropriate
-- error handling mechanisms for invalid input parameters.
CREATE TABLE temp AS (SELECT * FROM salaries);
SET SQL_SAFE_UPDATES = 0;
UPDATE temp
SET remote_ratio = 100 
WHERE 
	company_location IN ("US","AU")
		AND
	salary > 90000;


-- 18. In year 2024, due to increase demand in data industry , there was  increase in salaries of data field employees.
-- Entry Level-35%  of the salary.
-- Mid junior – 30% of the salary.
-- Immediate senior level- 22% of the salary.
-- Expert level- 20% of the salary.
-- Director – 15% of the salary.
-- you have to update the salaries accordingly and update it back in the original database.
UPDATE temp
SET salary = 
	CASE
		WHEN experience_level = "EN" THEN salary * 1.35
        WHEN experience_level = "MI" THEN salary * 1.30
        WHEN experience_level = "SE" THEN salary * 1.22
        WHEN experience_level = "EX" THEN salary * 1.20
        WHEN experience_level = "DX" THEN salary * 1.15
        ELSE salary
	END
WHERE
	work_year=2024
	
    
-- 19. You are a researcher and you have been assigned the task to find the year with the highest average salary for each job title.
WITH AverageSalary AS
(
	SELECT 
		job_title,
        work_year,
        AVG(salary) AS "Average"
    FROM 
		salaries 
	GROUP BY 
		job_title,
        work_year
)
SELECT 
	job_title,
    work_year,
    Average 
FROM 
(
		SELECT 
			*,
            DENSE_RANK() OVER(PARTITION BY job_title ORDER BY Average DESC) AS "Ranking" 
        FROM 
			AverageSalary
) AS t 
WHERE 
	Ranking=1;


-- 20.  You have been hired by a market research agency where you been assigned the task to show the percentage of different employment 
-- type (full time, part time) in Different job roles, in the format where each row will be job title, each column will be type of 
-- employment type and  cell value  for that row and column will show the % value
SELECT 
    job_title,
    ROUND((SUM(CASE WHEN employment_type = 'FT' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2) AS 'FT Percentage',
    ROUND((SUM(CASE WHEN employment_type = 'CT' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2) AS 'CT Percentage',
    ROUND((SUM(CASE WHEN employment_type = 'PT' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2) AS 'PT Percentage',
    ROUND((SUM(CASE WHEN employment_type = 'FL' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2) AS 'FL Percentage'
FROM
    salaries
GROUP BY 
	job_title