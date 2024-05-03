USE CaseStudy;
load data infile "D:/Programming/SQLCaseStudy/SharkTankIndia/sharktank.csv" 
INTO TABLE sharktank
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


-- 1. You Team must promote shark Tank India season 4, The senior come up with the idea to show highest funding domain wise so that new 
-- startups can be attracted, and you were assigned the task to show the same.
SELECT 
	industry,
    total
FROM
(
SELECT 
	industry,
    `total_deal_amount(in_lakhs)` AS "total",
    row_number() OVER(PARTITION BY industry ORDER BY `total_deal_amount(in_lakhs)` DESC) AS rnk
FROM 
	sharktank 
GROUP BY 
	industry, `total_deal_amount(in_lakhs)` 
) AS t 
WHERE
	rnk = 1;


-- 2. You have been assigned the role of finding the domain where female as pitchers have female to male pitcher ratio >70%
SELECT 
	*,
	(female/male) * 100 AS "Percentage"
FROM
(
	SELECT 
		industry,
		SUM(female_presenters) AS "female",
		SUM(male_presenters) AS "male" 
	FROM 
		sharktank 
	GROUP BY 
		industry 
	HAVING 
		Female > 0 
			AND 
		male > 0
) AS t 
WHERE 
	(female/male)*100 > 70;
    
    
-- 3. You are working at marketing firm of Shark Tank India, you have got the task to determine volume of per season sale pitch made, 
-- pitches who received offer and pitches that were converted. Also show the percentage of pitches converted and percentage of pitches 
-- entertained.
SELECT 
	t1.season_number,
    total,
    received_offer,
    (received_offer)/total * 100 AS "R_%",
    accepted_offer,
    (accepted_offer)/total * 100 AS "A_%"
FROM
(
	SELECT 
		season_number,
        COUNT(startup_name) AS "Total" 
	FROM 
		sharktank 
	GROUP BY 
		season_number
) AS t1
INNER JOIN
(
	SELECT 
		season_number,
        COUNT(startup_name) AS "received_offer" 
	FROM 
		sharktank 
	WHERE 
		received_offer = "Yes" 
	GROUP BY 
		season_number
) AS t2 USING(season_number)
INNER JOIN
(
	SELECT 
		season_number,
        COUNT(startup_name) AS "accepted_offer" 
	FROM 
		sharktank 
	WHERE 
		accepted_offer = "Yes" 
	GROUP BY 
		season_number
) AS t3;


-- 4. As a venture capital firm specializing in investing in startups featured on a renowned entrepreneurship TV show, you are determining 
-- the season with the highest average monthly sales and identify the top 5 industries with the highest average monthly sales during that 
-- season to optimize investment decisions?
set @season = 
	(
		SELECT 
			season_number
		FROM 
			sharktank 
		GROUP BY
			season_number
		ORDER BY 
			AVG(`monthly_sales(in_lakhs)`) DESC 
		LIMIT 1
    );
SELECT @season;
SELECT 
	industry,
    ROUND(AVG(`monthly_sales(in_lakhs)`),2) AS "average" 
FROM 
	sharktank 
WHERE 
	season_number = @season 
GROUP BY 
	industry 
ORDER BY 
	average DESC 
LIMIT 5;


-- 5. As a data scientist at our firm, your role involves solving real-world challenges like identifying industries with consistent 
-- increases in funds raised over multiple seasons. This requires focusing on industries where data is available across all three seasons. 
-- Once these industries are pinpointed, your task is to delve into the specifics, analyzing the number of pitches made, offers received, 
-- and offers converted per season within each industry.
WITH temp AS
(
	SELECT 
		industry,
		MAX(CASE WHEN season_number = 1 THEN `total_deal_amount(in_lakhs)` END) AS season1,
		MAX(CASE WHEN season_number = 2 THEN `total_deal_amount(in_lakhs)` END) AS season2,
		MAX(CASE WHEN season_number = 3 THEN `total_deal_amount(in_lakhs)` END) AS season3
	FROM
		sharktank
	GROUP BY
		industry
	HAVING 
		season3 > season2 
			AND 
		season2 > season1
			AND
		season1 != 0
)
SELECT 
	season_number,
	industry,
    COUNT(startup_name) AS "total",
	COUNT(CASE WHEN received_offer="Yes" THEN startup_name END) AS "received",
	COUNT(CASE WHEN accepted_offer="Yes" THEN startup_name END) AS "accepted"
 FROM 
	temp 
INNER JOIN 
	sharktank USING(industry)
GROUP BY
	season_number,
    industry;
 
 
-- 6. Every shark wants to know in how much year their investment will be returned, so you must create a system for them, where shark will
-- enter the name of the startup’s and the based on the total deal and equity given in how many years their principal amount will be returned
-- and make their investment decisions.
DELIMITER //
CREATE PROCEDURE tot(IN start_up VARCHAR(100))
BEGIN
	DECLARE accepted_offer VARCHAR(50);
    DECLARE yearly_revenue VARCHAR(50);
    SELECT accepted_offer,`yearly_revenue(in_lakhs)` INTO accepted_offer,yearly_revenue FROM sharktank WHERE startup_name=start_up;
    
    IF(accepted_offer = "No")
    THEN 
		SELECT "Turn over time cannot be calculated";
	ELSEIF(accepted_offer="Yes" AND yearly_revenue="Not Mentioned")
    THEN
		SELECT "Previous data is not available";
	ELSE
		SELECT
			startup_name,
            `yearly_revenue(in_lakhs)`,
            `total_deal_amount(in_lakhs)`, 
			`total_deal_equity(%)`, 
			`total_deal_amount(in_lakhs)` / ((`total_deal_equity(%)` / 100) * `total_deal_amount(in_lakhs)`) AS years
        FROM 
			sharktank 
		WHERE 
			startup_name = start_up;
		END IF;
END //
DELIMITER ;
CALL tot('BluePineFoods');


-- 7. In the world of startup investing, we're curious to know which big-name investor, often referred to as "sharks," tends to put the 
-- most money into each deal on average. This comparison helps us see who's the most generous with their investments and how they measure
-- up against their fellow investors.
SELECT 
	sharkname,
    ROUND(AVG(investment),2) AS "Average"
FROM
(
	SELECT 
		`Namita_Investment_Amount(in lakhs)` AS investment,
		'Namita' AS sharkname 
	FROM 
		sharktank 
	WHERE  
		`Namita_Investment_Amount(in lakhs)` > 0
	UNION ALL
	SELECT 
		`Vineeta_Investment_Amount(in_lakhs)` AS investment,
		'Vineeta' AS sharkname 
	FROM 
		sharktank 
	WHERE  
		`Vineeta_Investment_Amount(in_lakhs)` > 0
	UNION ALL
	SELECT 
		`Anupam_Investment_Amount(in_lakhs)` AS investment,
		'Anupam' AS sharkname 
	FROM 
		sharktank 
	WHERE  
		`Anupam_Investment_Amount(in_lakhs)` > 0
	UNION ALL
	SELECT 
		`Aman_Investment_Amount(in_lakhs)` AS investment,
		'Aman' AS sharkname 
	FROM 
		sharktank 
	WHERE  
		`Aman_Investment_Amount(in_lakhs)` > 0
	UNION ALL
	SELECT 
		`Peyush_Investment_Amount((in_lakhs)` AS investment,
		'Peyush' AS sharkname 
	FROM 
		sharktank 
	WHERE  
		`Peyush_Investment_Amount((in_lakhs)` > 0
	UNION ALL
	SELECT 
		`Amit_Investment_Amount(in_lakhs)` AS investment,
		'Amit' AS sharkname 
	FROM 
		sharktank 
	WHERE  
		`Amit_Investment_Amount(in_lakhs)` > 0
	UNION ALL
	SELECT 
		`Ashneer_Investment_Amount` AS investment,
		'Ashneer' AS sharkname 
	FROM 
		sharktank 
	WHERE  
		`Ashneer_Investment_Amount` > 0
) AS k
GROUP BY
	sharkname;
    
    
-- 8. Develop a stored procedure that accepts inputs for the season number and the name of a shark. The procedure will then provide 
-- detailed insights into the total investment made by that specific shark across different industries during the specified season. 
-- Additionally, it will calculate the percentage of their investment in each sector relative to the total investment in that year, giving
-- a comprehensive understanding of the shark's investment distribution and impact.
DELIMITER //
CREATE PROCEDURE getseason(IN season INT,IN sharkname VARCHAR(100))
BEGIN
	CASE
		WHEN sharkname = "Namita"
        THEN
			set @total = 
				(
					SELECT
						SUM(`Namita_Investment_Amount(in lakhs)`)
					FROM
						sharktank
					WHERE
						season_number = season
							AND
						`Namita_Investment_Amount(in lakhs)` > 0
				);
			SELECT 
				industry,
				SUM(`Namita_Investment_Amount(in lakhs)`),
                SUM(`Namita_Investment_Amount(in lakhs)`)/@total
			FROM 
				sharktank 
			WHERE 
				season_number = season 
					AND 
				`Namita_Investment_Amount(in lakhs)` > 0
			GROUP BY 
				industry;
                
		WHEN sharkname = "Vineeta"
        THEN
			set @total = 
				(
					SELECT
						SUM(`Vineeta_Investment_Amount(in_lakhs)`)
					FROM
						sharktank
					WHERE
						season_number = season
							AND
						`Vineeta_Investment_Amount(in_lakhs)` > 0
				);
			SELECT 
				industry,
				SUM(`Vineeta_Investment_Amount(in_lakhs)`),
                SUM(`Vineeta_Investment_Amount(in_lakhs)`)/@total
			FROM 
				sharktank 
			WHERE 
				season_number = season 
					AND 
				`Vineeta_Investment_Amount(in_lakhs)` > 0
			GROUP BY 
				industry;
                
		WHEN sharkname = "Anupam"
        THEN
			set @total = 
				(
					SELECT
						SUM(`Anupam_Investment_Amount(in_lakhs)`)
					FROM
						sharktank
					WHERE
						season_number = season
							AND
						`Anupam_Investment_Amount(in_lakhs)` > 0
				);
			SELECT 
				industry,
				SUM(`Anupam_Investment_Amount(in_lakhs)`),
                SUM(`Anupam_Investment_Amount(in_lakhs)`)/@total
			FROM 
				sharktank 
			WHERE 
				season_number = season 
					AND 
				`Anupam_Investment_Amount(in_lakhs)` > 0
			GROUP BY 
				industry;
                
		WHEN sharkname = "Aman"
        THEN
			set @total = 
				(
					SELECT
						SUM(`Aman_Investment_Amount(in_lakhs)`)
					FROM
						sharktank
					WHERE
						season_number = season
							AND
						`Aman_Investment_Amount(in_lakhs)` > 0
				);
			SELECT 
				industry,
				SUM(`Aman_Investment_Amount(in_lakhs)`),
                SUM(`Aman_Investment_Amount(in_lakhs)`)/@total
			FROM 
				sharktank 
			WHERE 
				season_number = season 
					AND 
				`Aman_Investment_Amount(in_lakhs)` > 0
			GROUP BY 
				industry;
		
        WHEN sharkname = "Peyush"
        THEN
			set @total = 
				(
					SELECT
						SUM(`Peyush_Investment_Amount((in_lakhs)`)
					FROM
						sharktank
					WHERE
						season_number = season
							AND
						`Peyush_Investment_Amount((in_lakhs)` > 0
				);
			SELECT 
				industry,
				SUM(`Peyush_Investment_Amount((in_lakhs)`),
                SUM(`Peyush_Investment_Amount((in_lakhs)`)/@total
			FROM 
				sharktank 
			WHERE 
				season_number = season 
					AND 
				`Peyush_Investment_Amount((in_lakhs)` > 0
			GROUP BY 
				industry;
                
		WHEN sharkname = "Amit"
        THEN
			set @total = 
				(
					SELECT
						SUM(`Amit_Investment_Amount(in_lakhs)`)
					FROM
						sharktank
					WHERE
						season_number = season
							AND
						`Amit_Investment_Amount(in_lakhs)` > 0
				);
			SELECT 
				industry,
				SUM(`Amit_Investment_Amount(in_lakhs)`),
                SUM(`Amit_Investment_Amount(in_lakhs)`)/@total
			FROM 
				sharktank 
			WHERE 
				season_number = season 
					AND 
				`Amit_Investment_Amount(in_lakhs)` > 0
			GROUP BY 
				industry;
                
		WHEN sharkname = "Ashneer"
        THEN
			set @total = 
				(
					SELECT
						SUM(`Ashneer_Investment_Amount`)
					FROM
						sharktank
					WHERE
						season_number = season
							AND
						`Ashneer_Investment_Amount` > 0
				);
			SELECT 
				industry,
				SUM(`Ashneer_Investment_Amount`),
                SUM(`Ashneer_Investment_Amount`)/@total
			FROM 
				sharktank 
			WHERE 
				season_number = season 
					AND 
				`Ashneer_Investment_Amount` > 0
			GROUP BY 
				industry;
		ELSE
			SELECT "Wrong Input";
	END CASE;
END //
DELIMITER ;
CALL getseason(1,"Namita");


-- 9. In the realm of venture capital, we're exploring which shark possesses the most diversified investment portfolio across various 
-- industries. By examining their investment patterns and preferences, we aim to uncover any discernible trends or strategies that may 
-- shed light on their decision-making processes and investment philosophies
SELECT 
	SharkName,
    COUNT(DISTINCT industry) AS "UniqueIndustry",
    COUNT(DISTINCT CONCAT(pitchers_city,',',pitchers_state)) AS "UniqueLocation"
FROM
(
	SELECT 
		industry,
        pitchers_city,
        pitchers_state,
        'Namita' AS "SharkName" 
	FROM 
		sharktank 
	WHERE 
		`Namita_Investment_Amount(in lakhs)`> 0 
	UNION ALL
	SELECT 
		industry,
        pitchers_city,
        pitchers_state,
        'Vineeta' AS "SharkName" 
	FROM 
		sharktank 
	WHERE 
		`Vineeta_Investment_Amount(in_lakhs)`> 0 
	UNION ALL
	SELECT 
		industry,
        pitchers_city,
        pitchers_state,
        'Anupam' AS "SharkName" 
	FROM 
		sharktank 
	WHERE 
		`Anupam_Investment_Amount(in_lakhs)`> 0
	UNION ALL
	SELECT 
		industry,
        pitchers_city,
        pitchers_state,
        'Aman' AS "SharkName" 
	FROM 
		sharktank 
	WHERE 
		`Aman_Investment_Amount(in_lakhs)`> 0
	UNION ALL
	SELECT 
		industry,
        pitchers_city,
        pitchers_state,
        'Peyush' AS "SharkName" 
	FROM 
		sharktank 
	WHERE 
		`Peyush_Investment_Amount((in_lakhs)`> 0
	UNION ALL
	SELECT 
		industry,
        pitchers_city,
        pitchers_state,'Amit' AS "SharkName" 
	FROM 
		sharktank 
	WHERE 
		`Amit_Investment_Amount(in_lakhs)`> 0
	UNION ALL
	SELECT 
		industry,
        pitchers_city,
        pitchers_state,
        'Ashneer' AS "SharkName" 
	FROM sharktank 
		WHERE `Ashneer_Investment_Amount`> 0
) AS t
GROUP BY 
	SharkName
ORDER BY 
	UniqueIndustry DESC,
    UniqueLocation DESC;