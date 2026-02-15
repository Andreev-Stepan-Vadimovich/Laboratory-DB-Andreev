-- REPEATABLE READ
-- Неповторяющееся чтение
BEGIN;
UPDATE Client SET phone = '+75556667788' WHERE ID = 1;
COMMIT;