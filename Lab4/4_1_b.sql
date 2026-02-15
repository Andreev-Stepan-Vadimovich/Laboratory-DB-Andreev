CREATE OR REPLACE PROCEDURE get_client_credit_history(client_name TEXT)
LANGUAGE plpgsql
AS $$
DECLARE
    rec RECORD;
BEGIN
    RAISE NOTICE 'Кредитная история клиента "%":', client_name;
    FOR rec IN
        SELECT 
            cl.company_name AS название_клиента,
            ch.bank_name AS банк,
            ch.date AS дата_выдачи,
            CASE 
                WHEN ch.repaid THEN 'погашён'
                ELSE 'не погашён'
            END AS статус
        FROM Credit_History ch
        JOIN Client cl ON ch.client_id = cl.ID
        WHERE cl.company_name = client_name
    LOOP
        RAISE NOTICE 'Клиент: %, Банк: %, Выдан: %, Статус: %',
            rec.название_клиента, rec.банк, rec.дата_выдачи, rec.статус;
    END LOOP;
END;
$$;

CALL get_client_credit_history('ООО "Ромашка"');