use sakila;
-- 1 --
-- 1A : Display the first and last names of all actors from the table actor.
SELECT first_name, last_name 
FROM actor;

-- 1B: Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(first_name,  ' ', last_name) AS ' Actor Name'
FROM actor;

-- 2 --
-- 2a:  find the ID number, first name, and last name  of actor "joe"
SELECT actor_id, first_name, last_name 
FROM actor
WHERE first_name = 'JOE';

-- 2b: fFind all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name 
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c: Find actors who have last names with 'LI' + order rows by LN and FN, In that order -____-
SELECT actor_id, first_name, last_name 
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id,  country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3 --
-- 3a: Add a middle_name column to the table actor. Position it between first_name and last_name
SELECT * FROM actor;

ALTER TABLE actor
ADD COLUMN  middle_name VARCHAR(50) AFTER first_name;


-- 3b  Change the data type of the middle_name column to blobs.
ALTER TABLE actor 
MODIFY COLUMN middle_name BLOB;

-- 3c Now delete the middle_name column.  N.B. WOW OK Mr. Indecisive 

ALTER TABLE actor
DROP COLUMN middle_name;

-- ROUND 4 ! 
-- 4a List the last names of actors, as well as how many actors have that last name. 
SELECT last_name, COUNT(*) AS `Count`
FROM actor
GROUP BY last_name;

-- 4b List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS `Count`
FROM actor
GROUP BY last_name
HAVING Count > 2;

-- 4c HARPO WILLIAMS was  entered in the actor table as GROUCHO WILLIAMS. fix it. 
UPDATE actor 
SET first_name= 'HARPO'
WHERE first_name='GROUCHO' AND last_name='WILLIAMS';

-- 4d: JK it was right to begin with, change his name back to el groucho
UPDATE actor 
SET first_name= 'GROUCHO'
WHERE first_name='HARPO' AND last_name='WILLIAMS';

-- ROUND 5!!!
-- 5a write query that recreates schema for address
DESCRIBE sakila.address

-- ROUND 6 !!!
-- 6a Use JOIN to display the first and last names, and address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address
FROM staff s LEFT JOIN address a ON s.address_id = a.address_id;

-- 6b Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name, s.last_name, SUM(p.amount) AS 'TOTAL'
FROM staff s LEFT JOIN payment p  ON s.staff_id = p.staff_id
GROUP BY s.first_name, s.last_name;

-- 6c List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(a.actor_id) AS 'TOTAL'
FROM film f LEFT JOIN film_actor  a ON f.film_id = a.film_id
GROUP BY f.title;

-- 6d How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, COUNT(inventory_id)
FROM film f
INNER JOIN inventory i 
ON f.film_id = i.film_id
WHERE title = "Hunchback Impossible";

-- THE ANSWER IS 6 ---- 

-- 6e: Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS 'TOTAL'
FROM customer c LEFT JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.first_name, c.last_name
ORDER BY c.last_name

-- OH MY ROUND 7 HERE WE GO

-- 7a Use subqueries to display  titles of movies starting with   K and Q whose language is English.
SELECT title
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%') 
AND language_id=(SELECT language_id FROM language where name='English')

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id
	IN (SELECT actor_id FROM film_actor WHERE film_id 
		IN (SELECT film_id from film where title='ALONE TRIP'))
        
-- 7c: you will need the names and email addresses of all Canadian customers. Use joins
SELECT first_name, last_name, email 
FROM customer cu
JOIN address a ON (cu.address_id = a.address_id)
JOIN city cit ON (a.city_id=cit.city_id)
JOIN country cntry ON (cit.country_id=cntry.country_id)

-- 7d: Identify all movies categorized as famiy films.
SELECT title from film f
JOIN film_category fcat on (f.film_id=fcat.film_id)
JOIN category c on (fcat.category_id=c.category_id);

-- 7e Display the most frequently rented movies in descending order.
SELECT title, COUNT(f.film_id) AS 'Count_of_Rented_Movies'
FROM  film f
JOIN inventory i ON (f.film_id= i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
GROUP BY title ORDER BY Count_of_Rented_Movies DESC;

-- 7f display how much business, in dollars, each store brought in.
SELECT s.store_id, SUM(p.amount) 
FROM payment p
JOIN staff s ON (p.staff_id=s.staff_id)
GROUP BY store_id;

-- 7g Write a query to display for each store its store ID, city, and country.
SELECT store_id, city, country FROM store s
JOIN address a ON (s.address_id=a.address_id)
JOIN city c ON (a.city_id=c.city_id)
JOIN country cntry ON (c.country_id=cntry.country_id);

-- 7h: List the top five genres in gross revenue in descending order.
SELECT c.name AS "Top Five", SUM(p.amount) AS "Gross" 
FROM category c
JOIN film_category fc ON (c.category_id=fc.category_id)
JOIN inventory i ON (fc.film_id=i.film_id)
JOIN rental r ON (i.inventory_id=r.inventory_id)
JOIN payment p ON (r.rental_id=p.rental_id)
GROUP BY c.name ORDER BY Gross  LIMIT 5;

-- LAST ROUND! NUMERO 8 
-- 8a create a view.
CREATE VIEW top_five AS

SELECT name, SUM(p.amount)
FROM category c
INNER JOIN film_category fc
INNER JOIN inventory i
ON i.film_id = fc.film_id
INNER JOIN rental r
ON r.inventory_id = i.inventory_id
INNER JOIN payment p
GROUP BY name
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM top_five;

-- 8c. You find that you no longer need the view top_five. Write a query to delete it.
DROP VIEW top_five;
 











