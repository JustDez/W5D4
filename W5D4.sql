SELECT *
FROM payment;

--creating a stored procedure
--simulating a late fee charge to a customer who was mean

CREATE OR REPLACE PROCEDURE late_fee(
	customer INTEGER, -- customer_id parameter
	late_payment INTEGER,
	late_fee_amount DECIMAL(4,2) --amount for latefee
)
LANGUAGE plpgsql -- setting the query language for the procedure
AS $$
BEGIN
		-- add a late fee to a custoner payment amount
		UPDATE payment
		SET amount = amount + late_fee_amount
		WHERE customer_id = customer AND payment_id = late_payment;
		
		--commit out update statement inside of our transaction
		COMMIT;
END;
$$

--calling a stored procedure
CALL late_fee(341, 17503, 3.50)

-- 7.99
-- 11.49
SELECT *
FROM payment
WHERE payment_id = 17503 AND customer_id =341;

DROP PROCEDURE late_fee;

-- Store FUNctions Example
-- INsert data into the actor table
CREATE  OR REPLACE FUNCTION add_actor(
	_actor_id INTEGER,
	_first_name VARCHAR,
	_last_name VARCHAR,
	_last_update TIMESTAMP WITHOUT TIME ZONE)
RETURNS void
LANGUAGE plpgsql
AS $MAIN$
BEGIN
	INSERT INTO actor
	VALUES(_actor_id, _first_name, _last_name, _last_update);
END;
$MAIN$

-- DO NOT 'CALL' A FUNCTION -- SELECT IT
SELECT add_actor(500, 'Orlando', 'Bloom', NOW()::TIMESTAMP);

SELECT *
FROM actor
WHERE actor_id = 500;

--functions to grab return total rentals
CREATE FUNCTION get_total_rentals()
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
	BEGIN
		RETURN (SELECT SUM(amount) FROM payment);
	END;
$$

SELECT get_total_rentals();

--A function to get a discount that a procedure will use to apply that discount
CREATE FUNCTION get_discount(price NUMERIC, percentage INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
	BEGIN
		RETURN (price * percentage/100);
	END;
$$

--procedure that alerts the data in a column usong the get_discount functino
CREATE PROCEDURE apply_discount(percentage INTEGER, _payment_id INTEGER)
AS $$
	BEGIN
		UPDATE payment
		SET amount = get_discount(payment.amount, percentage)
		WHERE payment_id = _payment_id;
	END;
$$ LANGUAGE plpgsql;

SELECT *
FROM payment;

CALL apply_discount(20, 17517);

SELECT *
FROM payment 
WHERE payment_id = 17517;

--------------------------------------------------------------------------------------------------------------------------------------
--USE the pyament and customer table
ALTER TABLE customer 
ADD COLUMN platinum_member BOOLEAN DEFAULT False;

SELECT *
FROM customer;

CREATE PROCEDURE update_platinum_member()
LANGUAGE plpgsql
AS $$
	BEGIN
		UPDATE customer
		SET platinum_member = TRUE
		WHERE customer_id IN (
			SELECT customer_id
			FROM payment
			GROUP BY payment.customer_id
			HAVING SUM (amount) > 200
		);
		COMMIT;
	END;
$$

CALL update_platinum_member()

SELECT *
FROM customer
WHERE customer_id = 526 OR customer_id = 148;

