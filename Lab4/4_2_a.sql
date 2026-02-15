CREATE OR REPLACE FUNCTION get_revenue_current_year(contract_num INT)
RETURNS NUMERIC AS $$
    SELECT COALESCE(SUM(amount), 0)
    FROM Accruals
    WHERE contract_number = contract_num
      AND repaid = TRUE
      AND EXTRACT(YEAR FROM accrual_date) = EXTRACT(YEAR FROM CURRENT_DATE);
$$ LANGUAGE sql;

SELECT get_revenue_current_year(1001);