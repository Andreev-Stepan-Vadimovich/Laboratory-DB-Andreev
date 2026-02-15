-- Кредит со ставкой, ближайшей к заданной
CREATE OR REPLACE PROCEDURE find_closest_interest_rate(target_rate INT, OUT closest_product TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT name INTO closest_product
    FROM Credit_Product
    ORDER BY ABS(interest_rate - target_rate)
    LIMIT 1;
    
    IF closest_product IS NULL THEN
        closest_product := 'Не найдено';
    END IF;
END;
$$;

CALL find_closest_interest_rate(10, NULL);