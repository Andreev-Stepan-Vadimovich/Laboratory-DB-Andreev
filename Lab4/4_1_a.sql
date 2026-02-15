CREATE OR REPLACE PROCEDURE get_overdue_clients()
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
BEGIN
    RAISE NOTICE 'Список клиентов, не погасивших кредиты в срок:';
    FOR rec IN
        SELECT 
            c.company_name AS клиент,
            cp.name AS название_кредита,
            cc.amount AS сумма,
            cc.start_date AS дата_выдачи,
            cc.end_date AS дата_погашения
        FROM Credit_Contract cc
        JOIN Client c ON cc.client_id = c.ID
        JOIN Credit_Product cp ON cp.contract_number = cc.number
        WHERE cc.repaid = FALSE AND cc.end_date < CURRENT_DATE
    LOOP
        RAISE NOTICE 'Клиент: %, Кредит: %, Сумма: %, Выдан: %, Погашен до: %',
            rec.клиент, rec.название_кредита, rec.сумма, rec.дата_выдачи, rec.дата_погашения;
    END LOOP;
END;
$$;

CALL get_overdue_clients();