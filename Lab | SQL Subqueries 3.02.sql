-- Lab | SQL Subqueries 3.02 (3.03)
-- In this lab, you will be using the Sakila database of movie rentals. Create appropriate joins wherever necessary.

USE sakila;

-- Instructions

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT * FROM inventory LIMIT 10; 
SELECT film_id, title FROM film WHERE title = 'Hunchback impossible'; #439
SELECT * FROM INVENTORY WHERE film_id = 439; #Store1, store2 --> count

#SELECT i.inventory_id, i.film_id, f.title
#FROM inventory i
#JOIN film f USING (film_id)
#WHERE f.title = 'Hunchback Impossible'; #store1 store2


SELECT COUNT(i.inventory_id) AS copies, f.title
FROM inventory i
JOIN film f USING (film_id)
WHERE f.title = 'Hunchback Impossible';

#count 6


-- 2. List all films whose length is longer than the average of all the films.

SELECT AVG(length) AS average_length FROM film; # average 115.27

SELECT title, length
FROM film
WHERE length >(
	SELECT AVG(length) AS average_length
    FROM film)
ORDER BY length;

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.

SELECT * FROM actor LIMIT 5; #actor_id, first_name, last_name
SELECT * FROM film LIMIT 5;

SELECT CONCAT(a.first_name," ", a.last_name) AS full_name
FROM actor a
JOIN film_actor fa USING (actor_id)
WHERE fa. film_id IN (
	SELECT film_id
    FROM film
    WHERE title = 'ALONE TRIP');



-- 4. Sales have been lagging among young families,
-- and you wish to target all family movies for a promotion.
-- Identify all movies categorized as family films.

SELECT rating FROM film LIMIT 5; # 'G' --> GENERAL AUDIENCES
SELECT * FROM film LIMIT 5;

SELECT title, rating
FROM FILM
WHERE rating = 'G';


-- 5. Get name and email from customers from Canada using subqueries.
-- Do the same with joins. Note that to create a join, you will have to identify
-- the correct tables with their primary keys and foreign keys,
-- that will help you get the relevant information.

SELECT * FROM country WHERE country = 'Canada'; #country_id = 20
SELECT * FROM city LIMIT 5; #address_id / country_id
SELECT * FROM address LIMIT 5; #address_id, city_id
SELECT * FROM customer LIMIT 5; #address_id

# With Subqueries

SELECT first_name, email
FROM customer
WHERE address_id IN (
	SELECT address_id
	FROM address
	WHERE city_id IN (
		SELECT city_id                 #worked
		FROM city
		WHERE country_id = (
			SELECT country_id
			FROM country
			WHERE country = 'Canada')
        ));


# With Join

SELECT CONCAT(c.first_name," ", c.last_name) AS full_name, email
FROM customer c
JOIN address USING (address_id)
JOIN city USING (city_id)
JOIN country USING (country_id)
WHERE country = 'Canada';



-- 6. Which are films starred by the most prolific actor?
-- Most prolific actor is defined as the actor that has acted in the most number of films.
-- First you will have to find the most prolific actor and then use that actor_id
-- to find the different films that he/she starred.

SELECT * from film_actor LIMIT 5;
SELECT * FROM film LIMIT 5;

#actors and appearances. --> inner query
SELECT fa.actor_id, COUNT(fa.film_id) as appearances
FROM film_actor fa
GROUP BY fa.actor_id
ORDER BY appearances desc;
#LIMIT 1; #107

#PROVISIONAL SOLUTION
SELECT title
FROM film
WHERE film_id in (
		SELECT film_id
        FROM film 
		JOIN film_actor USING (film_id) 
		WHERE film_actor.actor_id=107);



-- 7. Films rented by most profitable customer.
-- You can use the customer table and payment table to find the most profitable customer
-- ie the customer that has made the largest sum of payments

SELECT * FROM payment LIMIT 5; #rental_id
SELECT * FROM customer LIMIT 5;
SELECT * FROM rentAL limit 5; #inventory_id
SELECT * from inventory limit 5; #film_id
SELECT * from FILM limit 5; #film_id title

SELECT customer_id, sum(amount) AS total_amount.
FROM payment
GROUP BY customer_id
ORDER BY total_amount desc; #most profitable customer_id 526

#provisional solution:		
SELECT title
FROM film
WHERE film_id IN (
	SELECT film_id
    FROM inventory
    WHERE inventory_id IN (
		SELECT inventory_id
        FROM rental
        WHERE customer_id = 526
            ));        

SELECT title
FROM film
WHERE film_id IN (
	SELECT film_id
    FROM inventory
    WHERE inventory_id IN (
		SELECT inventory_id
        FROM rental
        WHERE customer_id IN (
			SELECT customer_id, max(sum(amount)) AS total_amount
			FROM payment
			#GROUP BY customer_id
            #HAVING max(sum(amount))
			#ORDER BY total_amount desc
            )));





# 8. Customers who spent more than the average payments.

SELECT first_name, last_name
FROM customer
WHERE customer.customer_id IN (
	SELECT payment.customer_id
	FROM payment
	GROUP BY payment.customer_id
	HAVING AVG(payment.amount) > (
		SELECT AVG(amount)
		FROM payment
 ));