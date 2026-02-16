-- Вложенная процедура: определить самый популярный кредит и клиентов, которые его взяли
CREATE OR REPLACE PROCEDURE get_clients_with_most_popular_credit()
LANGUAGE plpgsql
AS $$
DECLARE
    popular_product_name TEXT;
    client_rec RECORD;
BEGIN
    SELECT cp.name INTO popular_product_name
    FROM Credit_Product cp
    GROUP BY cp.name
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    RAISE NOTICE 'Самый популярный кредит: %', popular_product_name;
    RAISE NOTICE 'Клиенты, взявшие этот кредит:';

    FOR client_rec IN
        SELECT DISTINCT cl.company_name
        FROM Client cl
        JOIN Credit_Contract cc ON cl.ID = cc.client_id
        JOIN Credit_Product cp ON cp.contract_number = cc.number
        WHERE cp.name = popular_product_name
    LOOP
        RAISE NOTICE '%', client_rec.company_name;
    END LOOP;
END;
$$;

CALL get_clients_with_most_popular_credit();
