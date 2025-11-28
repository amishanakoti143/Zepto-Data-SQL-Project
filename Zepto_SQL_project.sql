--------------------------------------------
-- ZEPTO SQL PROJECT
--------------------------------------------

-- 1. CREATE & SELECT DATABASE
CREATE DATABASE ZEPTO_SQL_PROJECT;
USE ZEPTO_SQL_PROJECT;

--------------------------------------------
-- 2. INITIAL CHECK
--------------------------------------------
SELECT * FROM zepto;

-- ADD PRIMARY KEY
ALTER TABLE zepto 
ADD COLUMN sku_id INT AUTO_INCREMENT PRIMARY KEY FIRST;

--------------------------------------------
-- 3. DATA EXPLORATION
--------------------------------------------

-- TOTAL ROW COUNT
SELECT COUNT(*) AS total_rows FROM zepto;

-- SAMPLE DATA
SELECT * FROM zepto LIMIT 10;

-- CHECK NULL VALUES
SELECT *
FROM zepto
WHERE category IS NULL
   OR name IS NULL
   OR mrp IS NULL
   OR discountpercent IS NULL
   OR availablequantity IS NULL
   OR discountedsellingprice IS NULL
   OR weightingms IS NULL
   OR outofstock IS NULL
   OR quantity IS NULL;

-- DISTINCT CATEGORIES
SELECT DISTINCT category 
FROM zepto 
ORDER BY category;

-- STOCK VS OUT OF STOCK
SELECT outofstock, COUNT(sku_id) AS total_products
FROM zepto
GROUP BY outofstock;

-- DUPLICATE PRODUCT NAMES
SELECT 
    name, COUNT(*) AS sku_count
FROM zepto
GROUP BY name
HAVING COUNT(*) > 1
ORDER BY sku_count DESC;

--------------------------------------------
-- 4. DATA CLEANING
--------------------------------------------

-- PRODUCTS WITH ZERO PRICE
SELECT * 
FROM zepto
WHERE mrp = 0 OR discountedsellingprice = 0;

-- DISABLE SAFE MODE
SET SQL_SAFE_UPDATES = 0;

-- DELETE BAD RECORDS
DELETE FROM zepto WHERE mrp = 0;
DELETE FROM zepto WHERE sku_id IS NULL;

-- CONVERT PAISE TO RUPEES
UPDATE zepto
SET 
    mrp = mrp / 100,
    discountedsellingprice = discountedsellingprice / 100;

--------------------------------------------
-- 5. BUSINESS QUERIES / ANALYSIS
--------------------------------------------

-- 1. TOP 10 BEST-VALUE PRODUCTS (HIGHEST DISCOUNT)
SELECT 
    name, mrp, discountpercent
FROM zepto
ORDER BY discountpercent DESC
LIMIT 10;

-- 2. HIGH MRP BUT OUT OF STOCK
SELECT 
    name, mrp
FROM zepto
WHERE outofstock = 1 AND mrp > 300
ORDER BY mrp DESC;

-- 3. ESTIMATED REVENUE PER CATEGORY
SELECT 
    category,
    SUM(discountedsellingprice * availablequantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;

-- 4. MRP > 500 AND DISCOUNT < 10%
SELECT 
    name, mrp, discountpercent
FROM zepto
WHERE mrp > 500 AND discountpercent < 10
ORDER BY mrp DESC;

-- 5. TOP 5 CATEGORIES WITH HIGHEST AVERAGE DISCOUNT
SELECT 
    category,
    ROUND(AVG(discountpercent), 2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- 6. PRICE PER GRAM — BEST VALUE FIRST
SELECT 
    name,
    weightingms,
    discountedsellingprice,
    ROUND(discountedsellingprice / weightingms, 4) AS price_per_gram
FROM zepto
WHERE weightingms >= 100
ORDER BY price_per_gram ASC;

-- 7. WEIGHT CATEGORY (LOW / MEDIUM / BULK)
SELECT 
    name,
    weightingms,
    CASE
        WHEN weightingms < 1000 THEN 'LOW'
        WHEN weightingms < 5000 THEN 'MEDIUM'
        ELSE 'BULK'
    END AS weight_category
FROM zepto;

-- 8. TOTAL INVENTORY WEIGHT PER CATEGORY
SELECT 
    category,
    SUM(weightingms * availablequantity) AS total_weight_gms
FROM zepto
GROUP BY category
ORDER BY total_weight_gms DESC;
