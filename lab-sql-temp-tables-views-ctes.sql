USE sakila;

-- Create a View
-- First, create a view that summarizes rental information for each customer. 
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW customer_rental_count  AS 
	SELECT 
		 c.customer_id,
		 c.first_name,
		 c.last_name,
		 c.email,     
		 customer_rentals.rental_count
	FROM (
		SELECT 
			customer_id,
			COUNT(inventory_id) as rental_count
		FROM 
			rental
		GROUP BY customer_id
	) as customer_rentals
	JOIN  
		customer as c
	ON c.customer_id = customer_rentals.customer_id;



-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.
CREATE TEMPORARY TABLE IF NOT EXISTS temp_total_per_customer (
	SELECT 
		crc.customer_id, crc.first_name, crc.last_name, crc.email,
		-- MIN(crc.rental_count) AS rental_count,
		sum(amount) as total_paid    
	FROM 
		customer_rental_count as crc
	JOIN
		payment as p
	ON
		crc.customer_id = p.customer_id
	GROUP BY crc.customer_id, crc.first_name, crc.last_name, crc.email);
    
    
SELECT 
	*
FROM 
	temp_total_per_customer;
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, rental count, and total amount paid.
with CTE_TOTAL AS
	(SELECT
		ttpc.customer_id,
		ttpc.first_name,
		ttpc.last_name,
		ttpc.email,
		ttpc.total_paid,
		crc.rental_count
	FROM 
		temp_total_per_customer as ttpc
	JOIN 
		customer_rental_count as crc
	ON 
		crc.customer_id = ttpc.customer_id
	)

    
    
-- Next, using the CTE, create the query to generate the final customer summary report, which should include: 
-- customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

SELECT 
	*,
    ROUND(c.total_paid / c.rental_count,2) as average_payment_per_rental
FROM 
	CTE_TOTAL as c