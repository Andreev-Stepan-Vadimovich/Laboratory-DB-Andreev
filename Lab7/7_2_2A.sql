-- READ UNCOMMITTED (в pg автоматически повышается до READ COMMITTED)
-- Грязное чтение
BEGIN;
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

UPDATE Client SET phone = '+71112223344' WHERE ID = 1;
-- Не делаем commit