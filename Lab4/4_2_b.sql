CREATE OR REPLACE FUNCTION get_unused_credits_current_year()
RETURNS TABLE(credit_name VARCHAR(50)) AS $$
    SELECT DISTINCT name
    FROM Credit_Product
    WHERE name NOT IN (
        SELECT cp.name
        FROM Credit_Product cp
        JOIN Credit_Contract cc ON cp.contract_number = cc.number
        WHERE cc.start_date >= DATE_TRUNC('year', CURRENT_DATE)::DATE
    );
$$ LANGUAGE sql;

SELECT * FROM get_unused_credits_current_year();