CREATE OR REPLACE FUNCTION check_client_reliability_on_contract_insert()
RETURNS TRIGGER AS $$
DECLARE
    total_contracts INT;
    repaid_contracts INT;
    overdue_contracts INT;
BEGIN
    -- Считаем статистику по существующим контрактам клиента
    SELECT 
        COUNT(*),
        COUNT(*) FILTER (WHERE repaid = TRUE),
        COUNT(*) FILTER (WHERE repaid = FALSE AND end_date < CURRENT_DATE) -- Только просроченные
    INTO total_contracts, repaid_contracts, overdue_contracts
    FROM Credit_Contract
    WHERE client_id = NEW.client_id;

    -- Если есть хоть один кредит с истекшим сроком и статусом "не погашен"
    IF overdue_contracts > 0 THEN
        RAISE EXCEPTION 'Клиент % имеет просроченные кредиты (% шт.). Новый договор не может быть заключён.', 
                        NEW.client_id, overdue_contracts;
        RETURN NULL; 
    END IF;

    -- Если есть 2 или более полностью погашенных кредита в истории
    IF total_contracts >= 2 AND repaid_contracts = total_contracts THEN
        UPDATE Credit_Product
        SET interest_rate = GREATEST(interest_rate - 2, 1)
        WHERE contract_number = NEW.number;
        
        RAISE NOTICE 'Клиент % получил льготную ставку по продукту.', NEW.client_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_client_on_contract_insert ON Credit_Contract;

CREATE TRIGGER trg_check_client_on_contract_insert
BEFORE INSERT ON Credit_Contract
FOR EACH ROW
EXECUTE FUNCTION check_client_reliability_on_contract_insert();


-------
INSERT INTO Credit_Contract (number, amount, repaid, start_date, end_date, debt_balance, client_id)
VALUES (4003, 500000, FALSE, '2026-06-01', '2028-06-01', 500000, 4),
		(4004, 500000, FALSE, '2026-06-01', '2028-06-01', 500000, 4);

INSERT INTO Credit_Contract (number, amount, repaid, start_date, end_date, debt_balance, client_id)
VALUES (4007, 500000, FALSE, '2026-06-01', '2028-06-01', 500000, 2);
------
