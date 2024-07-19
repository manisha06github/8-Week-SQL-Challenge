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
Total 14 pizzas were ordered.

### 2. How many unique customer orders were made?
````sql
SELECT COUNT(DISTINCT order_id) AS unique_orders
FROM customer_orders;
````
#### Answer:
| unique_orders |
|---------------|
|      10       |
There were 10 unique customer orders made.

### 3. How many successful orders were delivered by each runner?
````sql
SELECT runner_id, COUNT(order_id) AS success_order
FROM runner_orders 
WHERE cancellation IS NULL
GROUP BY runner_id;
````
#### Answer:
|   runner_id   |  success_order  |
|---------------|-----------------|
|       1       |        4        |
|       2       |        3        |
|       3       |        1        |
Runner 1 had 4, runner 2 had 3 and runner 3 had 1 successful order delivered respectively.

### 4. How many of each type of pizza was delivered?
````sql
SELECT c.pizza_id, COUNT(c.pizza_id) as total
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.pizza_id;
````
#### Answer:
|  pizza_id  |  total  |
|------------|---------|
|     1      |    9    |
|     2      |    3    |
There were total 9 pizza delivered with pizza id 1 and 3 pizza with pizza id 2.

### 5. How many Vegetarian and Meatlovers were ordered by each customer?
````sql
SELECT c.customer_id, p.pizza_name, COUNT(c.pizza_id) total_ordered
FROM customer_orders c
JOIN pizza_names p ON c.pizza_id = p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id ASC;
````
#### Answer:
| customer_id | pizza_name | total_ordered |
|-------------|------------|---------------|
|     101	    | Meatlovers	|       2       |
|     101     |	Vegetarian	|       1       |
|     102	    | Meatlovers	|       2       |
|     102	    | Vegetarian	|       1       |
|     103	    | Meatlovers	|       3       |
|     103	    | Vegetarian	|       1       |
|     104	    | Meatlovers	|       3       |
|     105	    | Vegetarian	|       1       |

### 6.What was the maximum number of pizzas delivered in a single order?
````sql
SELECT MAX(total_pizza) AS maxpizza_delivered
FROM (
    SELECT c.order_id, COUNT(c.pizza_id) total_pizza
    FROM customer_orders c
    JOIN runner_orders r ON c.order_id = r.order_id
    WHERE r.cancellation IS NULL
    GROUP BY c.order_id
    ) AS pizza_delivered;
````
#### Answer:
| maxpizza_delivered |
|--------------------|
|         3          |
Maximum 3 pizzas were delivered in a single order.

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
````sql
SELECT c.customer_id, COUNT(c.pizza_id) AS pizza,
SUM(CASE 
    WHEN c.exclusions IS NOT NULL OR c.extras IS NOT NULL THEN 1 
    ELSE 0
    END) AS atleast_1_change,
SUM(CASE
    WHEN c.exclusions IS NULL AND c.extras IS NULL THEN 1
    ELSE 0
    END) AS no_change
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.customer_id
ORDER BY c.customer_id;
````
#### Answer:
| customer_id | pizza | atleast_1_change | no_change |
|-------------|-------|------------------|-----------|
|     101	    |   2  	|         0        |     2     |
|     102     |	  3   |         0        |     3     |
|     103	    |   3   |         3        |     0     |
|     104	    |   3   |         2        |     1     |
|     105	    |   1   |         1        |     0     |

### 8. How many pizzas were delivered that had both exclusions and extras?
````sql
SELECT c.customer_id, COUNT(c.pizza_id) AS pizza,
SUM(CASE 
    WHEN c.exclusions IS NOT NULL AND c.extras IS NOT NULL THEN 1 
    ELSE 0
    END) AS both_change
FROM customer_orders c
JOIN runner_orders r ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.customer_id;
````
#### Answer:
| customer_id | pizza | both_change | 
|-------------|-------|-------------|
|     101	    |   2  	|      0      |
|     102     |	  3   |      0      |
|     103	    |   3   |      0      |
|     104	    |   3   |      1      |
|     105	    |   1   |      0      |

### 9. What was the total volume of pizzas ordered for each hour of the day?
````sql
SELECT HOUR(order_time) AS order_hour,
COUNT(pizza_id) AS pizza_vol
FROM customer_orders
GROUP BY HOUR(order_time)
ORDER BY HOUR(order_time);
````
#### Answer:
| order_hour | pizza_vol |
|------------|-----------|
|     11     |     1     |
|     13     |     3     |
|     18     |     3     |
|     19     |     1     |
|     21     |     3     |
|     23     |     3     |

### 10. What was the volume of orders for each day of the week?
````sql
SELECT DAYNAME(order_time) AS order_day,
COUNT(pizza_id) AS pizza_vol
FROM customer_orders
GROUP BY DAYNAME(order_time)
ORDER BY DAYNAME(order_time);
````
#### Answer:
| order_day  | pizza_vol |
|------------|-----------|
|   Friday   |     1     |
|  Saturday  |     5     |
|  Thursday  |     3     |
|  Wednesday |     5     |

***
