-- READ UNCOMMITTED (в pg автоматически повышается до READ COMMITTED)
-- Грязное чтение
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT phone FROM Client WHERE ID = 1;
-- Грязного чтения нет. Специфика постгреса.