CREATE OR REPLACE FUNCTION prevent_client_deletion_with_debt()
RETURNS TRIGGER AS $$
DECLARE
    has_active_debt BOOLEAN;
    total_contracts INTEGER;
BEGIN
    -- Считаем общее количество контрактов у клиента
    SELECT COUNT(*) INTO total_contracts
    FROM Credit_Contract
    WHERE client_id = OLD.ID;

    -- Проверяем наличие непогашенных кредитов
    SELECT EXISTS (
        SELECT 1
        FROM Credit_Contract
        WHERE client_id = OLD.ID 
          AND (repaid IS NOT TRUE)
    ) INTO has_active_debt;

    IF has_active_debt THEN
        RAISE EXCEPTION 'Невозможно удалить клиента "%". Имеются непогашенные кредиты.', OLD.company_name;
        RETURN NULL; 
    ELSE
        IF total_contracts > 0 THEN
            RAISE NOTICE 'Клиент "%" не имеет активных долгов. Удаление разрешено (найдено погашенных контрактов: %).', OLD.company_name, total_contracts;
        END IF;
        
        RETURN OLD; 
    END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_deletion_with_debt ON Client;

CREATE TRIGGER trg_prevent_deletion_with_debt
BEFORE DELETE ON Client
FOR EACH ROW
EXECUTE FUNCTION prevent_client_deletion_with_debt();