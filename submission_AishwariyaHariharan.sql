/* Printing all tables*/
SELECT * FROM orders.address;

SELECT * FROM orders.carton;

SELECT * FROM orders.online_customer;

SELECT * FROM orders.order_header;

SELECT * FROM orders.order_items;

SELECT * FROM orders.order_items;

SELECT * FROM orders.product;

SELECT * FROM orders.product_class;

SELECT * FROM orders.shipper;


/*
-- 1. WRITE A QUERY TO DISPLAY CUSTOMER FULL NAME WITH THEIR TITLE (MR/MS), BOTH FIRST NAME AND LAST NAME ARE IN UPPER CASE WITH 
-- CUSTOMER EMAIL ID, CUSTOMER CREATIONDATE AND DISPLAY CUSTOMER’S CATEGORY AFTER APPLYING BELOW CATEGORIZATION RULES:
	-- i.IF CUSTOMER CREATION DATE YEAR <2005 THEN CATEGORY A
    -- ii.IF CUSTOMER CREATION DATE YEAR >=2005 AND <2011 THEN CATEGORY B
    -- iii.IF CUSTOMER CREATION DATE YEAR>= 2011 THEN CATEGORY C
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER TABLE]
*/

USE ORDERS;
SELECT 
CONCAT(CASE CUSTOMER_GENDER WHEN 'M' THEN 'MR' WHEN 'F' THEN 'MS' END,' ',UPPER(CUSTOMER_FNAME),' ' ,UPPER(CUSTOMER_LNAME))
AS CUSTOMER_FULL_NAME,CUSTOMER_EMAIL,CUSTOMER_CREATION_DATE, 
CASE 
 WHEN YEAR(CUSTOMER_CREATION_DATE)<2005 THEN 'A' 
 WHEN 2005>=YEAR(CUSTOMER_CREATION_DATE) AND YEAR(CUSTOMER_CREATION_DATE)<2011 THEN 'B' 
 ELSE 'C' END AS CUSTOMERS_CATEGORY FROM orders.online_customer;

/*
-- 2. WRITE A QUERY TO DISPLAY THE FOLLOWING INFORMATION FOR THproductE PRODUCTS, WHICH HAVE NOT BEEN SOLD:  PRODUCT_ID, PRODUCT_DESC, 
-- PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE,INVENTORY VALUES(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE), NEW_PRICE AFTER APPLYING DISCOUNT 
-- AS PER BELOW CRITERIA. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- i.IF PRODUCT PRICE > 20,000 THEN APPLY 20% DISCOUNT
    -- ii.IF PRODUCT PRICE > 10,000 THEN APPLY 15% DISCOUNT
    -- iii.IF PRODUCT PRICE =< 10,000 THEN APPLY 10% DISCOUNT
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -PRODUCT, ORDER_ITEMS TABLE] 
*/

SELECT * FROM orders.product;

SELECT 
    PRODUCT_ID,
    PRODUCT_DESC,
    PRODUCT_QUANTITY_AVAIL,
    PRODUCT_PRICE,
    (PRODUCT_QUANTITY_AVAIL * PRODUCT_PRICE) AS INVENTORY_VALUE,
    CASE
        WHEN PRODUCT_PRICE > 20000 THEN PRODUCT_PRICE * 0.8
        WHEN PRODUCT_PRICE > 10000 THEN PRODUCT_PRICE * 0.85
        ELSE PRODUCT_PRICE * 0.9
    END AS NEW_PRICE
FROM 
    orders.product
WHERE 
    PRODUCT_ID NOT IN (SELECT PRODUCT_ID FROM orders.order_items)
ORDER BY 
    INVENTORY_VALUE DESC;

/*
-- 3. WRITE A QUERY TO DISPLAY PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESCRIPTION, COUNT OF PRODUCT TYPE IN EACH PRODUCT CLASS, 
-- INVENTORY VALUE (P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE). INFORMATION SHOULD BE DISPLAYED FOR ONLY THOSE PRODUCT_CLASS_CODE 
-- WHICH HAVE MORE THAN 1,00,000 INVENTORY VALUE. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS]
*/

SELECT 
    PC.PRODUCT_CLASS_CODE,
    PC.PRODUCT_CLASS_DESC,
    COUNT(P.PRODUCT_ID) AS PRODUCT_TYPE_COUNT,
    SUM(P.PRODUCT_QUANTITY_AVAIL * P.PRODUCT_PRICE) AS INVENTORY_VALUE
FROM 
    orders.product P
JOIN 
    orders.product_class PC ON P.PRODUCT_CLASS_CODE = PC.PRODUCT_CLASS_CODE
GROUP BY 
    PC.PRODUCT_CLASS_CODE, PC.PRODUCT_CLASS_DESC
HAVING 
    INVENTORY_VALUE > 100000
ORDER BY 
    INVENTORY_VALUE DESC;
    
/*
-- 4. WRITE A QUERY TO DISPLAY CUSTOMER_ID, FULL NAME, CUSTOMER_EMAIL, CUSTOMER_PHONE AND COUNTRY OF CUSTOMERS WHO HAVE CANCELLED 
-- ALL THE ORDERS PLACED BY THEM(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
*/

SELECT 
    OC.CUSTOMER_ID,
    CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS FULL_NAME,
    OC.CUSTOMER_EMAIL,
    OC.CUSTOMER_PHONE,
    A.COUNTRY
FROM 
    orders.online_customer OC
JOIN 
    orders.address A ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE 
    OC.CUSTOMER_ID IN (
        SELECT 
            OH.CUSTOMER_ID
        FROM 
            orders.order_header OH
        WHERE 
            OH.ORDER_STATUS = 'CANCELLED'
        GROUP BY 
            OH.CUSTOMER_ID
        HAVING 
            COUNT(*) = (
                SELECT 
                    COUNT(*) 
                FROM 
                    orders.order_header
                WHERE 
                    CUSTOMER_ID = OH.CUSTOMER_ID
            )
    );
    
    /*
    -- 5. WRITE A QUERY TO DISPLAY SHIPPER NAME, CITY TO WHICH IT IS CATERING, NUMBER OF CUSTOMER CATERED BY THE SHIPPER IN THE CITY AND 
-- NUMBER OF CONSIGNMENTS DELIVERED TO THAT CITY FOR SHIPPER DHL(9 ROWS)
	-- [NOTE: TABLES TO BE USED -SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
    */
    
    -- Display shipper information and delivery statistics for DHL in each city
SELECT 
    S.SHIPPER_NAME,
    A.CITY AS CITY_CATERED,
    COUNT(DISTINCT OC.CUSTOMER_ID) AS CUSTOMERS_CATERED,
    COUNT(OH.ORDER_ID) AS CONSIGNMENTS_DELIVERED
FROM 
    orders.shipper S
JOIN 
    orders.order_header OH ON S.SHIPPER_ID = OH.SHIPPER_ID
JOIN 
    orders.online_customer OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
JOIN 
    orders.address A ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE 
    S.SHIPPER_NAME = 'DHL'
GROUP BY 
    S.SHIPPER_NAME, A.CITY;
    
    /*
    -- 6. WRITE A QUERY TO DISPLAY CUSTOMER ID, CUSTOMER FULL NAME, TOTAL QUANTITY AND TOTAL VALUE (QUANTITY*PRICE) SHIPPED WHERE MODE 
-- OF PAYMENT IS CASH AND CUSTOMER LAST NAME STARTS WITH 'G'
	-- [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
    */
    SELECT OC.CUSTOMER_ID,
       CONCAT(OC.CUSTOMER_FNAME, ' ', OC.CUSTOMER_LNAME) AS CUSTOMER_FULL_NAME,
       SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY,
       SUM(OI.PRODUCT_QUANTITY * P.PRODUCT_PRICE) AS TOTAL_VALUE
FROM orders.online_customer OC
JOIN orders.order_header OH ON OC.CUSTOMER_ID = OH.CUSTOMER_ID
JOIN orders.order_items OI ON OH.ORDER_ID = OI.ORDER_ID
JOIN orders.product P ON OI.PRODUCT_ID = P.PRODUCT_ID
WHERE OH.PAYMENT_MODE = 'CASH'
  AND OC.CUSTOMER_LNAME LIKE 'G%'
GROUP BY OC.CUSTOMER_ID, CUSTOMER_FULL_NAME;

    /*
    -- 7. WRITE A QUERY TO DISPLAY ORDER_ID AND VOLUME OF BIGGEST ORDER (IN TERMS OF VOLUME) THAT CAN FIT IN CARTON ID 10  
	-- [NOTE: TABLES TO BE USED -CARTON, ORDER_ITEMS, PRODUCT]
    */
    SELECT ORDER_ID ,
VOLUME
FROM (
SELECT OI.ORDER_ID ,
P.PRODUCT_ID ,
SUM(LEN * WIDTH * HEIGHT) AS VOLUME
FROM ORDER_ITEMS OI
INNER JOIN PRODUCT P ON OI.PRODUCT_ID = P.PRODUCT_ID
GROUP BY OI.ORDER_ID , P.PRODUCT_ID
ORDER BY VOLUME ) TAB
HAVING VOLUME <= ( SELECT (LEN * WIDTH * HEIGHT) AS CARTON_VOL
FROM
CARTON WHERE CARTON_ID = 10 )
ORDER BY VOLUME DESC LIMIT 1;

/*
-- 8. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, QUANTITY SOLD, AND SHOW INVENTORY STATUS OF 
-- PRODUCTS AS BELOW AS PER BELOW CONDITION:
	-- A.FOR ELECTRONICS AND COMPUTER CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 10% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY', 
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 50% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 50% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- B.FOR MOBILES AND WATCHES CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 20% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 60% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 60% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- C.REST OF THE CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 30% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 70% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv. IF INVENTORY QUANTITY IS MORE OR EQUAL TO 70% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
        
			-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] (USE SUB-QUERY)
            */
            
	SELECT 
    P.PRODUCT_ID,
    P.PRODUCT_DESC,
    P.PRODUCT_QUANTITY_AVAIL,
    SUM(OI.PRODUCT_QUANTITY) AS QUANTITY_SOLD,
    CASE
        WHEN PC.PRODUCT_CLASS_DESC IN ('ELECTRONICS', 'COMPUTER') THEN
            CASE
                WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.1 * SUM(OI.PRODUCT_QUANTITY) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.5 * SUM(OI.PRODUCT_QUANTITY) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
                ELSE 'SUFFICIENT INVENTORY'
            END
        WHEN PC.PRODUCT_CLASS_DESC IN ('MOBILES', 'WATCHES') THEN
            CASE
                WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.2 * SUM(OI.PRODUCT_QUANTITY) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.6 * SUM(OI.PRODUCT_QUANTITY) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
                ELSE 'SUFFICIENT INVENTORY'
            END
        ELSE
            CASE
                WHEN SUM(OI.PRODUCT_QUANTITY) = 0 THEN 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.3 * SUM(OI.PRODUCT_QUANTITY) THEN 'LOW INVENTORY, NEED TO ADD INVENTORY'
                WHEN P.PRODUCT_QUANTITY_AVAIL < 0.7 * SUM(OI.PRODUCT_QUANTITY) THEN 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY'
                ELSE 'SUFFICIENT INVENTORY'
            END
    END AS INVENTORY_STATUS
FROM orders.product P
JOIN orders.product_class PC ON P.PRODUCT_CLASS_CODE= PC.PRODUCT_CLASS_CODE
LEFT JOIN orders.order_items OI ON P.PRODUCT_ID = OI.PRODUCT_ID
GROUP BY P.PRODUCT_ID, P.PRODUCT_DESC, P.PRODUCT_QUANTITY_AVAIL, PC.PRODUCT_CLASS_DESC;

/*
-- 9. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC AND TOTAL QUANTITY OF PRODUCTS WHICH ARE SOLD TOGETHER WITH PRODUCT ID 201 
-- AND ARE NOT SHIPPED TO CITY BANGALORE AND NEW DELHI. DISPLAY THE OUTPUT IN DESCENDING ORDER WITH RESPECT TO TOT_QTY.(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED -ORDER_ITEMS,PRODUCT,ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
    */
   SELECT
S.PRODUCT_ID ,
S.PRODUCT_DESC ,
S.TOT_QTY FROM
( SELECT P.PRODUCT_ID , P.PRODUCT_DESC , SUM(PRODUCT_QUANTITY) AS TOT_QTY
FROM ORDER_ITEMS OI
INNER JOIN PRODUCT P WHERE OI.PRODUCT_ID = P.PRODUCT_ID
AND ORDER_ID IN
( SELECT OI.ORDER_ID FROM ORDER_ITEMS OI
JOIN ORDER_HEADER OH ON OI.ORDER_ID = OH.ORDER_ID
JOIN ONLINE_CUSTOMER OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
JOIN ADDRESS A ON OC.ADDRESS_ID = A.ADDRESS_ID WHERE OI.PRODUCT_ID = 201
AND OH.ORDER_STATUS = 'SHIPPED'
AND A.CITY NOT IN ( 'BANGALORE' , 'NEW DELHI' ) )
AND P.PRODUCT_ID != 201
GROUP BY P.PRODUCT_ID , PRODUCT_DESC ) S
ORDER BY TOT_QTY DESC; 

/*
-- 10. WRITE A QUERY TO DISPLAY THE ORDER_ID,CUSTOMER_ID AND CUSTOMER FULLNAME AND TOTAL QUANTITY OF PRODUCTS SHIPPED FOR ORDER IDS 
-- WHICH ARE EVENAND SHIPPED TO ADDRESS WHERE PINCODE IS NOT STARTING WITH "5" 
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER,ORDER_HEADER, ORDER_ITEMS, ADDRESS]
    */

SELECT 
OH.ORDER_ID, 
OH.CUSTOMER_ID, 
CONCAT(OC.CUSTOMER_FNAME,' ',OC.CUSTOMER_LNAME) AS CUSTOMER_FULL_NAME, 
SUM(OI.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM orders.order_header OH 
JOIN orders.online_customer OC ON OH.CUSTOMER_ID = OC.CUSTOMER_ID
JOIN orders.order_items OI ON OH.ORDER_ID = OI.ORDER_ID
JOIN orders.address A ON OC.ADDRESS_ID = A.ADDRESS_ID
WHERE (OI.ORDER_ID % 2) = 0  AND OH.ORDER_STATUS = 'SHIPPED' AND A.PINCODE NOT LIKE '5%'
GROUP BY 
OH.ORDER_ID,
OH.CUSTOMER_ID,
CUSTOMER_FULL_NAME;

    

    




   