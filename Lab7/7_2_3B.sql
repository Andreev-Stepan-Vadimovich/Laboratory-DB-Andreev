-- READ COMMITTED
-- Неповторяющееся чтение
BEGIN;
UPDATE Client SET phone = '+79998887766' WHERE ID = 1;
COMMIT;