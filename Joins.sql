-- Joins

USE Assignment;
SELECT * FROM country_ab;
SELECT * FROM country_cd;
SELECT * FROM country_cl;
SELECT * FROM country_efg;

-- 1. Find out top 10 countries' which have maximum A and D values.
SELECT 
    t1.country, a, d
FROM
    (SELECT 
        country, a
    FROM
        country_ab
    ORDER BY A DESC
    LIMIT 10) t1
        LEFT JOIN
    (SELECT 
        country, d
    FROM
        country_cd
    ORDER BY D DESC
    LIMIT 10) t2 ON t1.country = t2.country 
UNION SELECT 
    t2.country, a, d
FROM
    (SELECT 
        country, a
    FROM
        country_ab
    ORDER BY A DESC
    LIMIT 10) t1
        RIGHT JOIN
    (SELECT 
        country, d
    FROM
        country_cd
    ORDER BY D DESC
    LIMIT 10) t2 ON t1.country = t2.country
ORDER BY country;

-- 2. Find out highest CL value for 2020 for every region. Also sort the result in descending order. Also display the CL values in 
-- descending order.
SELECT 
    t2.region, MAX(t1.cl) AS 'Max_Cl'
FROM
    country_cl t1
        INNER JOIN
    country_ab t2 ON t1.country = t2.country
        AND t1.edition = t2.edition
WHERE
    t1.edition = 2020
GROUP BY t2.region
ORDER BY Max_Cl DESC;


SELECT * FROM customers;
SELECT * FROM employees;
SELECT * FROM products;
SELECT * FROM sales1;

-- 3.  Find top-5 most sold products.
SELECT 
    ProductID, ROUND(SUM(Quantity), 2) AS Total
FROM
    sales1
        NATURAL JOIN
    products
GROUP BY ProductID
ORDER BY Total DESC
LIMIT 5;

-- 4. Find sales man who sold most no of products.
SELECT 
    employees.EmployeeID, SUM(Quantity) AS 'Total_Sold'
FROM
    sales1
        INNER JOIN
    employees ON sales1.SalesPersonID = employees.EmployeeID
GROUP BY employees.EmployeeID
ORDER BY Total_Sold DESC
LIMIT 1;

-- 5. Sales man name who has most no of unique customer.
SELECT 
    FirstName, LastName
FROM
    employees
WHERE
    EmployeeID = (SELECT 
            employees.EmployeeID
        FROM
            sales1
                INNER JOIN
            employees ON sales1.SalesPersonID = employees.EmployeeID
        GROUP BY employees.EmployeeID
        ORDER BY COUNT(DISTINCT CustomerID) DESC
        LIMIT 1);

-- 6.  Sales man who has generated most revenue. Show top 5.
SELECT 
    t1.SalesPersonID,
    ROUND(SUM(t1.Quantity * t2.Price), 2) AS Revenue
FROM
    sales1 t1
        INNER JOIN
    products t2 ON t1.ProductID = t2.ProductID
        INNER JOIN
    employees t3 ON t1.SalesPersonID = t3.EmployeeID
GROUP BY t1.SalesPersonID
ORDER BY Revenue DESC
LIMIT 5;

-- 7. List all customers who have made more than 10 purchases.
SELECT 
    CustomerID, COUNT(*) AS 'Purchase'
FROM
    sales1
GROUP BY CustomerID
HAVING Purchase > 10;

-- 8. List all salespeople who have made sales to more than 5 customers.
SELECT 
    employees.EmployeeID,
    COUNT(DISTINCT CustomerID) AS 'TotalUniqueCustomer'
FROM
    sales1
        INNER JOIN
    employees ON sales1.SalesPersonID = employees.EmployeeID
GROUP BY employees.EmployeeID
HAVING TotalUniqueCustomer > 5;

-- 9. List all pairs of customers who have made purchases with the same salesperson.
SELECT DISTINCT
    t1.CustomerID AS 'First_Customer',
    t2.CustomerID AS 'Second_Customer',
    t1.SalesPersonID
FROM
    sales1 t1
        INNER JOIN
    sales1 t2 ON t1.SalesPersonID = t2.SalesPersonID
        AND t1.CustomerId <> t2.CustomerID;