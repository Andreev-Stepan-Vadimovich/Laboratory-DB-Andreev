ROLLBACK;

DELETE FROM Credit_Product WHERE contract_number = 2000;
DELETE FROM Credit_Contract WHERE number = 2000;
DELETE FROM Client WHERE ID = 100;

-- Начало транзакции
BEGIN;

-- Вставка нового клиента
INSERT INTO Client (ID, contact_person, legal_address, company_name, phone)
VALUES (
    100,
    'Тестов Тест Тестович',
    'г. Тестоград, ул. Тестовая, д. 99',
    'ООО "ТестКредит"',
    '+79998887766'
);

-- Вставка кредитного договора
INSERT INTO Credit_Contract (number, amount, repaid, start_date, end_date, debt_balance, client_id)
VALUES (
    2000,
    1000000,
    FALSE,
    '2026-02-15',
    '2029-02-15',
    1000000,
    100
);

-- Вставка кредитного продукта
INSERT INTO Credit_Product (name, installment_repayment, interest_rate, max_amount, max_term, contract_number)
VALUES (
    'Тестовый льготный кредит',
    TRUE,
    3,
    5000000,
    '2040-01-01',
    2000
);

-- Проверка: данные существуют внутри транзакции
SELECT 'Данные ДО отката:' AS stage, c.company_name, cc.number, cp.name
FROM Client c
JOIN Credit_Contract cc ON c.ID = cc.client_id
JOIN Credit_Product cp ON cp.contract_number = cc.number
WHERE c.ID = 100;

-- Создаём точку сохранения (для демонстрации)
SAVEPOINT sp1;

-- Удалим данные (имитация ошибки)
DELETE FROM Credit_Product WHERE contract_number = 2000;
DELETE FROM Credit_Contract WHERE number = 2000;
DELETE FROM Client WHERE ID = 100;

-- Проверка: данных больше нет
SELECT 'После удаления (до ROLLBACK TO SAVEPOINT):' AS stage, COUNT(*) 
FROM Client WHERE ID = 100;

-- Откатываемся к точке сохранения — восстанавливаем данные
ROLLBACK TO SAVEPOINT sp1;

-- Проверка: данные снова есть
SELECT 'После ROLLBACK TO SAVEPOINT:' AS stage, c.company_name
FROM Client c
WHERE c.ID = 100;

-- Теперь делаем полный откат всей транзакции
ROLLBACK;

-- Проверка извне транзакции: данных нет
SELECT 'После ROLLBACK всей транзакции:' AS stage, COUNT(*) 
FROM Client WHERE ID = 100;