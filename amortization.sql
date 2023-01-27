--drop function amortization
CREATE OR REPLACE FUNCTION amortization(term INTEGER, rate DECIMAL(6,4), amount DECIMAL(10,2))
RETURNS TABLE 
(
	payment_index 		INTEGER, 
	starting_balance 	DECIMAL(10,2), 
	payment 			DECIMAL(10,2),
	interest 			DECIMAL(6,4), 
	principal 			DECIMAL(10,2), 
	ending_balance 		DECIMAL(10,2)
)
AS 
/*
	Basic amortization
	
	author					when				about
	--------------------	---------------		----------------------------------------------------
	softwareNuggets			2023-01-26			basic function to compute amortization of a car loan
	
	--sample run
	--buy a car for $25,000, finance for 36 months at 4.5% interest
	
	select * from amortization(36,.045,25000.00)
*/
$$

DECLARE current_balance 	DECIMAL(10,2);
DECLARE monthly_rate 		DECIMAL(6,4);
DECLARE monthly_payment 	DECIMAL(10,2);
DECLARE principal 			DECIMAL(10,2);
DECLARE interest 			DECIMAL(6,4);
DECLARE i 					INTEGER;

BEGIN

    current_balance = amount;
    monthly_rate = rate / 12;
    monthly_payment = (amount * monthly_rate) / (1 - (1 + monthly_rate)^(-term));

    FOR i IN 1..term LOOP
        interest = current_balance * monthly_rate;
        principal = monthly_payment - interest;
        current_balance = current_balance - principal;
        
		RETURN QUERY 
		SELECT (term+1)-i, current_balance + principal, monthly_payment, interest, principal, current_balance;
		
    END LOOP;
END;
$$ LANGUAGE plpgsql;