-- Вложенная процедура: определить самый популярный кредит и клиентов, которые его взяли

-- Выводит клиентов для конкретного продукта
CREATE OR REPLACE PROCEDURE print_clients_for_product(IN p_product_name TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    client_rec RECORD;
BEGIN
    RAISE NOTICE 'Клиенты, взявшие этот кредит:';

    FOR client_rec IN
        SELECT DISTINCT cl.company_name
        FROM Client cl
        JOIN Credit_Contract cc ON cl.ID = cc.client_id
        JOIN Credit_Product cp ON cp.contract_number = cc.number
        WHERE cp.name = p_product_name
        AND cc.client_id IS NOT NULL
    LOOP
        RAISE NOTICE '%', client_rec.company_name;
    END LOOP;
END;
$$;

-- Находит популярный кредит и вызывает вспомогательную
CREATE OR REPLACE PROCEDURE get_clients_with_most_popular_credit()
LANGUAGE plpgsql
AS $$
DECLARE
    popular_product_name TEXT;
BEGIN
    SELECT cp.name INTO popular_product_name
    FROM Credit_Product cp
    JOIN Credit_Contract cc ON cp.contract_number = cc.number
    WHERE cc.client_id IS NOT NULL
    GROUP BY cp.name
    ORDER BY COUNT(*) DESC
    LIMIT 1;

    IF popular_product_name IS NULL THEN
        RAISE NOTICE 'В базе данных нет выданных кредитов.';
        RETURN;
    END IF;

    RAISE NOTICE 'Самый популярный кредит: %', popular_product_name;

    -- Вызов вложенной процедуры
    CALL print_clients_for_product(popular_product_name);
END;
$$;

-- Вызов основной процедуры 
CALL get_clients_with_most_popular_credit();
