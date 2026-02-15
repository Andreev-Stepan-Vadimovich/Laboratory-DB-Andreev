CREATE OR REPLACE FUNCTION check_client_reliability_on_contract_insert()
RETURNS TRIGGER AS $$
DECLARE
    total_contracts INT;
    repaid_contracts INT;
    unreliable_exists BOOLEAN;
BEGIN
    -- Считаем договоры клиента ДО текущего (исключаем NEW.number)
    SELECT 
        COUNT(*),
        COUNT(*) FILTER (WHERE repaid = TRUE)
    INTO total_contracts, repaid_contracts
    FROM Credit_Contract
    WHERE client_id = NEW.client_id AND number != NEW.number;

    -- Если были кредиты, но не все погашены → ненадёжный
    IF total_contracts > 0 AND repaid_contracts < total_contracts THEN
        -- Удаляем созданный договор (если уже вставлен в AFTER)
        DELETE FROM Credit_Contract WHERE number = NEW.number;
        RAISE EXCEPTION 'Клиент % имеет непогашенные кредиты. Договор не может быть заключён.', NEW.client_id;
    END IF;

    -- Если ≥2 погашенных кредита → даём льготу
    IF total_contracts >= 2 AND repaid_contracts = total_contracts THEN
        -- Уменьшаем ставку на 2 процентных пункта, но не ниже 1%
        UPDATE Credit_Product
        SET interest_rate = GREATEST(interest_rate - 2, 1)
        WHERE contract_number = NEW.number;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_client_on_contract_insert
AFTER INSERT ON Credit_Contract
FOR EACH ROW
EXECUTE FUNCTION check_client_reliability_on_contract_insert();