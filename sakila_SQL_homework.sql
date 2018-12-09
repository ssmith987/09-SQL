USE sakila;

-- 1a. Display the first and last names of all actors from the table actor. 
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name, ' ' , last_name) as "Actor Name" FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
SELECT * FROM actor
WHERE first_name = "joe";

-- 2b. Find all actors whose last name contain the letters GEN
SELECT * FROM actor
WHERE last_name LIKE "%GEN%";

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China
SELECT country_id, country FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. create a column in the table actor named description and use the data type BLOB
ALTER TABLE actor
ADD description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS actor_count FROM actor
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS actor_count FROM actor
GROUP BY last_name
HAVING actor_count > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO'
AND last_name = 'WILLIAMS';

-- 4d. In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it
DESCRIBE sakila.address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member.
SELECT staff.first_name, staff.last_name, address.address 
FROM staff
INNER JOIN address ON staff.address_id=address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005.
SELECT first_name, last_name, (
	SELECT SUM(amount) FROM payment 
		WHERE payment_date 
        LIKE '2005-08%' 
        AND staff.staff_id=payment.staff_id) AS 'August Amount'
FROM staff;

-- 6c. List each film and the number of actors who are listed for that film. 
SELECT title, COUNT(actor_id) AS 'Actor Count' FROM film_actor
INNER JOIN film ON film_actor.film_id=film.film_id
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT count(*) FROM inventory
WHERE film_id IN(
	SELECT film_id FROM film
	WHERE title = 'Hunchback Impossible');

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name
SELECT first_name, last_name, (
	SELECT SUM(amount) FROM 
		payment WHERE customer.customer_id=payment.customer_id)
	AS 'Total Amount Paid'
FROM customer
ORDER BY last_name;

-- 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title FROM film
WHERE title LIKE 'k%' OR title LIKE 'q%'
AND language_id IN (
	SELECT language_id FROM language
	WHERE name='English');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name FROM actor
WHERE actor_id IN (
	SELECT actor_id FROM film_actor
	WHERE film_id = (
		SELECT film_id FROM film
		WHERE title = 'Alone Trip'));

-- 7c. Use joins to retrieve the names and email addresses of all Canadian customers.
SELECT first_name, last_name, email FROM customer
LEFT JOIN address ON customer.address_id=address.address_id
LEFT JOIN city ON address.city_id=city.city_id
LEFT JOIN country ON city.country_id=country.country_id
WHERE country='Canada';

-- 7d. Identify all movies categorized as family films.
SELECT title FROM film
WHERE film_id IN (SELECT film_id FROM film_category
WHERE category_id = (SELECT category_id FROM category
WHERE name='Family'));

-- 7e. Display the most frequently rented movies in descending order
SELECT title, COUNT(rental_id) AS 'Rental Count' FROM rental
LEFT JOIN inventory ON rental.inventory_id=inventory.inventory_id
LEFT JOIN film ON inventory.film_id=film.film_id
GROUP BY title
ORDER BY COUNT(rental_id) DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in
SELECT store_id, SUM(amount) FROM payment
LEFT JOIN staff ON payment.staff_id=staff.staff_id
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country
SELECT store_id, city, country FROM store
JOIN address on store.address_id=address.address_id
JOIN city on address.city_id=city.city_id
JOIN country on city.country_id=country.country_id;

-- List the top five genres in gross revenue in descending order
SELECT name, SUM(amount) AS 'Revenue' FROM payment
LEFT JOIN rental ON payment.rental_id=rental.rental_id
LEFT JOIN inventory ON rental.inventory_id=inventory.inventory_id
LEFT JOIN film_category ON inventory.film_id=film_category.film_id
LEFT JOIN category ON film_category.category_id=category.category_id
GROUP BY name
ORDER BY SUM(amount) DESC
LIMIT 5;

-- 8a. Use the solution from the problem above to create a view
CREATE VIEW `Top_5_Genres` AS 
SELECT name, SUM(amount) AS 'Revenue' FROM payment
LEFT JOIN rental ON payment.rental_id=rental.rental_id
LEFT JOIN inventory ON rental.inventory_id=inventory.inventory_id
LEFT JOIN film_category ON inventory.film_id=film_category.film_id
LEFT JOIN category ON film_category.category_id=category.category_id
GROUP BY name
ORDER BY SUM(amount) DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a
SELECT * FROM top_5_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_5_genres;
