CREATE OR REPLACE FUNCTION enforce_interest_rate_change()
RETURNS TRIGGER AS $$
DECLARE
    has_active_contracts BOOLEAN;
BEGIN
    -- Проверяем, есть ли активные (непогашенные и не просроченные) договоры
    SELECT EXISTS (
        SELECT 1
        FROM Credit_Contract cc
        WHERE cc.number = NEW.contract_number
          AND cc.repaid = FALSE
          AND cc.end_date >= CURRENT_DATE
    ) INTO has_active_contracts;

    IF has_active_contracts THEN
        RAISE EXCEPTION 'Нельзя изменить ставку: по кредиту есть активные непогашенные договоры.';
    END IF;

    -- Проверка увеличения не более чем в 1.1 раза
    IF NEW.interest_rate > OLD.interest_rate * 1.1 THEN
        RAISE EXCEPTION 'Ставка не может быть увеличена более чем на 10%%. Максимум: %', ROUND(OLD.interest_rate * 1.1);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_unfair_rate_change
BEFORE UPDATE OF interest_rate ON Credit_Product
FOR EACH ROW
WHEN (OLD.interest_rate IS DISTINCT FROM NEW.interest_rate)
EXECUTE FUNCTION enforce_interest_rate_change();