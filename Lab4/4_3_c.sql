CREATE OR REPLACE FUNCTION prevent_client_deletion_with_debt()
RETURNS TRIGGER AS $$
DECLARE
    has_unpaid BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM Credit_Contract
        WHERE client_id = OLD.ID AND repaid = FALSE
    ) INTO has_unpaid;

    IF has_unpaid THEN
        RAISE NOTICE 'Клиент % имеет непогашенные кредиты. Удаление отменено.', OLD.company_name;
        RETURN NULL; -- отменяет удаление
    ELSE
        RETURN OLD; -- разрешает удаление
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_deletion_with_debt
BEFORE DELETE ON Client
FOR EACH ROW
EXECUTE FUNCTION prevent_client_deletion_with_debt();