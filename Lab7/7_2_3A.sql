-- READ COMMITTED
-- Неповторяющееся чтение
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT phone FROM Client WHERE ID = 1;

-- Ждём, пока Сессия B обновит и закоммитит
SELECT phone FROM Client WHERE ID = 1;
COMMIT;