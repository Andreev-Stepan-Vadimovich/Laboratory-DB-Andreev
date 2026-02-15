-- REPEATABLE READ
-- Phantom Read
BEGIN;
INSERT INTO Client (ID, contact_person, legal_address, company_name, phone)
VALUES (999, 'Фантом Ф.Ф.', 'г. Город', 'ООО "Фантом"', '+70000000000');
COMMIT;