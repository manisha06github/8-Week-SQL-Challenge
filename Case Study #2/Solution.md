# Case Study 2. Pizza Runner

## Solution

***
 Our Dataset consist of null values. So we perform data cleaning first.

### (I) substituting the 'null' string and blank space with NULL in extras column in customer_orders
````sql
 UPDATE customer_orders
 SET extras = NULL
 WHERE extras = 'null' OR extras = '';
 
UPDATE customer_orders
SET exclusions = NULL
WHERE exclusions IN ('null','');
 ````
 ### (II) trimming km and any space from distance column in runner_orders table
 ````sql
 UPDATE runner_orders
 SET distance = TRIM(REPLACE(distance, 'km',''));
 
 UPDATE runner_orders
 SET distance = NULL
 WHERE distance = 'null';
 ````
### (III) substituting the 'null' string and blank space with NULL in cancellation column of runner_orders 
````sql
UPDATE runner_orders
SET cancellation = NULL
WHERE cancellation IN ('null','');

UPDATE runner_orders
SET duration = NULL
WHERE duration = 'null';

UPDATE runner_orders
SET pickup_time = NULL
WHERE pickup_time = 'null';
````
### (IV) remove strings and null from duration column in runner_orders
````sql
UPDATE runner_orders
SET duration = REGEXP_REPLACE(duration, '[^0-9]', '')
WHERE duration IS NOT NULL;
````
### (V) change datatype of distance and duration column
````sql
ALTER TABLE runner_orders
MODIFY COLUMN distance FLOAT;

ALTER TABLE runner_orders
MODIFY COLUMN duration INT;
````
### (VI) check the type of columns in the table
````sql
describe runner_orders;
describe customer_orders;
describe pizza_names;
describe pizza_recipes;
describe pizza_toppings;
````

##  A. Pizza Metrics
### 1. How many pizzas were ordered?
````sql
SELECT COUNT(*) AS pizza_ordered
FROM customer_orders;
````
#### Answer:

| pizza_ordered |
|---------------|
|      14       |

***
