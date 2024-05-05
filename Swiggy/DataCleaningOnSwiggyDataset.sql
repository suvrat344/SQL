USE casestudy;
set sql_safe_updates= 0;

-- Check Null Values
SELECT * FROM swiggy;
SELECT
	SUM(CASE WHEN hotel_name = "" THEN 1 ELSE 0 END),
    SUM(CASE WHEN rating = "" THEN 1 ELSE 0 END),
    SUM(CASE WHEN time_minutes = "" THEN 1 ELSE 0 END),
    SUM(CASE WHEN food_type = "" THEN 1 ELSE 0 END),
    SUM(CASE WHEN location = "" THEN 1 ELSE 0 END),
    SUM(CASE WHEN offer_above = "" THEN 1 ELSE 0 END),
    SUM(CASE WHEN offer_percentage = "" THEN 1 ELSE 0 END)
FROM 
	swiggy;
    
    
-- Get Null Values In Column
SELECT * FROM information_schema.columns WHERE table_name="swiggy";
SELECT column_name FROM information_schema.columns WHERE table_name="swiggy";

DELIMITER //
CREATE PROCEDURE count_blank_rows()
BEGIN
	SELECT 
		group_concat(concat('SUM(CASE WHEN `', column_name, '`='''' THEN 1 ELSE 0 END) AS `', column_name,'`')) INTO @sql 
	FROM
		information_schema.columns 
	WHERE 
		table_name = "swiggy";
    set @sql = concat('SELECT ',@sql,' FROM swiggy');
    PREPARE 
		smt 
	FROM 
		@sql;
    EXECUTE smt;
    DEALLOCATE PREPARE smt;
END //
DELIMITER ;
CALL count_blank_rows();


-- Cleaning Column time_minutes
DELIMITER //
CREATE FUNCTION get_first(a VARCHAR(200)) 
RETURNS varchar(100) 
DETERMINISTIC
BEGIN
	set @l = locate(' ',a);
    set @s = if(@l > 0 , left(a,@l - 1),a);
    return @s;
END //
DELIMITER ;

DELIMITER //
CREATE FUNCTION get_last(a VARCHAR(200)) 
RETURNS varchar(100)
DETERMINISTIC
BEGIN
	set @l = locate('-',a);
    set @s = if(@l = 0 ,' ',substring(a,@l + 1,length(a)));
    return @s;
END //
DELIMITER ;

CREATE TABLE 
	temp1 AS 
		SELECT 
					* 
			FROM 
					swiggy 
			WHERE 
					rating 
			LIKE 
				"%mins%";
            
CREATE TABLE 
	temp2 AS 
		SELECT 
			*,
			get_first(rating) AS 'rat' 
		FROM 
			temp1;
            
UPDATE 
	swiggy AS s 
		INNER JOIN 
	temp2 AS c ON s.hotel_name = c.hotel_name
SET 
	s.time_minutes = c.rat;
DROP TABLE 
	temp1;
DROP TABLE 
	temp2;

CREATE TABLE  
	temp1 AS 
		SELECT 
			* 
		FROM 
			swiggy 
		WHERE 
			time_minutes 
		LIKE 
			"%-%";
        
CREATE TABLE  
	temp2 AS 
		SELECT 
			*,
            get_first(time_minutes) as f1,
            get_last(time_minutes) as f2 
		FROM 
			temp1;
            
UPDATE 
	swiggy AS s 
		INNER JOIN 
	temp2 c ON s.hotel_name = c.hotel_name 
SET 
	s.time_minutes = ROUND((c.f1 + c.f2)/2,2);
DROP TABLE 
	temp1,
    temp2;
    
    
-- Cleaning Column Rating
UPDATE 
	swiggy AS s 
		JOIN 
	(
		SELECT 
			location,
            ROUND(AVG(rating),2) AS "average" 
		FROM 
			swiggy 
		WHERE 
			rating 
		NOT LIKE 
			"%min%" 
		GROUP BY 
			location
		) AS avg_table ON s.location = avg_table.location
SET 
	s.rating = avg_table.average
WHERE 
	s.rating 
LIKE 
	"%min%";
    
set @average = 
	(
		SELECT 
			AVG(rating) 
		FROM 
			swiggy 
		WHERE 
			rating 
		NOT LIKE 
			"%min%"
	);
    
UPDATE 
	swiggy 
SET 
	rating = @average
WHERE 
	rating 
LIKE 
	"%min%";
    
    
-- CLeaning Column Location
UPDATE 
	swiggy 
SET 
	location = "Kandivali East" 
WHERE 
	location 
LIKE 
	"%East%";
    
UPDATE 
	swiggy 
SET 
	location = "Kandivali West" 
WHERE 
	location 
LIKE 
	"%West%";
    
UPDATE 
	swiggy 
SET 
	location = "Kandivali East" 
WHERE 
	location 
LIKE 
	"%E%";
    
UPDATE 
	swiggy 
SET 
	location = "Kandivali West" 
WHERE 
	location 
LIKE 
	"%W%";
    
    
-- Cleaning Column Offer_Percentage
UPDATE
	swiggy
SET
	offer_percentage = 0
WHERE
	offer_above = "not_available";
    

-- Cleaning Column Food_Type
SELECT 
	*,
    SUBSTRING_INDEX(SUBSTRING_INDEX(food_type,',',numbers.n),',',-1) AS "food" 
FROM 
	swiggy
JOIN
(
SELECT 
	1 + a.N + b.N * 10 AS n 
FROM
(
	(
		SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
	) AS a
	CROSS JOIN 
	(
		SELECT 0 AS N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 
        UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
	) AS b
) 
) AS numbers ON char_length(food_type) - char_length(REPLACE(food_type,',','')) >= numbers.n - 1;