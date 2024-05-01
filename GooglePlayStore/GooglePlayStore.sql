USE CaseStudy;
SELECT * FROM playstore;
load data infile "D:/Programming/SQLCaseStudy/GooglePlayStore/playstore.csv" 
INTO TABLE playstore
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- 1. You're working as a market analyst for a mobile app development company. Your task is to identify the most promising categories 
-- (TOP 5) for launching new free apps based on their average ratings.
SELECT 
	category,
    AVG(rating) AS "Average" 
FROM 
	playstore 
WHERE 
	type="Free" 
GROUP BY 
	category 
ORDER BY 
	average DESC LIMIT 5;
    
    
-- 2. As a business strategist for a mobile app company, your objective is to pinpoint the three categories that generate the most 
-- revenue from paid apps. This calculation is based on the product of the app price and its number of installations.
SELECT 
	Category,
    AVG(Revenue) AS "AverageRevenue"
FROM
(
	SELECT 
		*,
		Installs * Price AS "Revenue" 
	FROM 
		playstore 
	WHERE 
		type="Paid"
) AS t
GROUP BY
	category
ORDER BY
	AverageRevenue DESC 
LIMIT 3;


-- 3. As a data analyst for a gaming company, you're tasked with calculating the percentage of games within each category. This 
-- information will help the company understand the distribution of gaming apps across different categories.
set @total = (SELECT COUNT(*) FROM playstore WHERE category="Game");
SELECT 
	Genres,
    (COUNT(*)/@total) * 100 AS "Percentage" 
FROM 
	playstore 
WHERE 
	category="Game" 
GROUP BY 
	Genres 
ORDER BY 
	Percentage DESC;
    
    
-- 4. As a data analyst at a mobile app-focused market research firm you’ll recommend whether the company should develop paid or free 
-- apps for each category based on the ratings of that category.
WITH t1 AS
(
	SELECT 
		category,
		ROUND(AVG(rating),2) AS "AveragePaidRating"
	FROM 
		playstore 
	WHERE 
		type="Paid" 
	GROUP BY 
		category
),
t2 AS 
(
	SELECT 
		category,
		ROUND(AVG(rating),2) AS "AverageFreeRating"
	FROM 
		playstore 
	WHERE 
		type="Free" 
	GROUP BY 
		category
)
SELECT 
	*, 
    if (AveragePaidRating > AverageFreeRating,"Develop paid apps","Develop free apps") AS Decision 
FROM
(
	SELECT 
		category,
        AveragePaidRating,
        AverageFreeRating 
	FROM 
		t1 
    INNER JOIN 
		t2 USING(category)
) AS temp;


-- 5. Suppose you're a database administrator your databases have been hacked and hackers are changing price of certain apps on the
-- database, it is taking long for IT team to neutralize the hack, however you as a responsible manager don’t want your data to be 
-- changed, do some measure where the changes in price can be recorded as you can’t stop hackers from making changes.
CREATE TABLE pricelog
(
	app VARCHAR(255),
	old_price DECIMAL(10,2),
	new_price DECIMAL(10,2),
	operational_type VARCHAR(255),
	operational_date TIMESTAMP
);
SELECT * FROM pricelog;
CREATE TABLE play AS SELECT * FROM playstore;

DELIMITER //
CREATE TRIGGER price_change_log
AFTER UPDATE
ON play
FOR EACH ROW
BEGIN
	INSERT INTO pricelog (app,old_price,new_price,operational_type,operational_date)
    VALUES (NEW.app,OLD.price,NEW.price,'update',CURRENT_TIMESTAMP);
END //
DELIMITER ;

UPDATE play
SET price = 4
WHERE
	app = 'Infinite Painter';
    
UPDATE play
SET price = 20
WHERE
	app = 'Sketch - Draw & Paint';


-- 6. Your IT team have neutralized the threat; however, hackers have made some changes in the prices, but because of your measure you 
-- have noted the changes, now you want correct data to be inserted into the database again.
UPDATE play AS a
INNER JOIN pricelog AS b ON a.app = b.app
SET a.price = b.old_price;


-- 7. As a data person you are assigned the task of investigating the correlation between two numeric factors: app ratings and the 
-- quantity of reviews.
SET @xmean = (SELECT ROUND(AVG(rating),2) FROM playstore);
SET @ymean = (SELECT ROUND(AVG(reviews),2) FROM playstore);
SELECT ROUND(num/(den1*den2),2) AS "Correlation"  FROM
(
SELECT
	ROUND(SUM((rating - @xmean) * (reviews - @ymean )),2) AS NUM,
    SQRT(SUM((rating - @xmean) * (rating -@xmean)))  AS den1,
    SQRT(SUM((reviews - @ymean) * (reviews -@ymean)))  AS den2
FROM 
	playstore
) AS t;


-- 8. Your boss noticed  that some rows in genres columns have multiple genres in them, which was creating issue when developing the  
-- recommender system from the data he/she assigned you the task to clean the genres column and make two genres out of it, rows that have 
-- only one genre will have other column as blank.
DELIMITER //
CREATE FUNCTION f_name(a VARCHAR(200))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
	set @l = locate(';',a);
    set @s = if(@l > 0 , left(a,@l - 1),a);
    return @s;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION l_name(a VARCHAR(200))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
	set @l = locate(';',a);
    set @s = if(@l = 0 ,' ',substring(a,@l + 1,length(a)));
    return @s;
END //
DELIMITER ;

SELECT 
	f_name(genres) AS "FirstGenre",
    l_name(genres) AS "LastGenre" 
FROM 
	playstore;


-- 9. Your senior manager wants to know which apps are not performing as par in their particular category, however he is not interested in
-- handling too many files or list for every  category and he/she assigned  you with a task of creating a dynamic tool where he/she  can 
-- input a category of apps he/she  interested in  and your tool then provides real-time feedback by displaying apps within that category
-- that have ratings lower than the average rating for that specific category.
DELIMITER //
CREATE PROCEDURE checking(IN cate VARCHAR(30))
BEGIN
	set @c = 
    (
		SELECT 
			average 
		FROM
			(
				SELECT 
					category,
					ROUND(AVG(rating),2) AS "Average" 
				FROM 
					playstore 
				GROUP BY 
					category
			) AS m WHERE category = cate
        );
        
        select 
			* 
		FROM 
			playstore 
		WHERE
			category=cate 
				AND 
			rating <@c;
END //
DELIMITER ;
        
CALL checking("Business");