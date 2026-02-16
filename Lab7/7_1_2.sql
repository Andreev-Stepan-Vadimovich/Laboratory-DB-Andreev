ROLLBACK;

DELETE FROM Credit_Product WHERE contract_number = 2000;
DELETE FROM Credit_Contract WHERE number = 2000;
DELETE FROM Client WHERE ID = 100;

-- Начало новой транзакции
BEGIN;

-- Вставляем те же данные
INSERT INTO Client (ID, contact_person, legal_address, company_name, phone)
VALUES (
    100,
    'Тестов Тест Тестович',
    'г. Тестоград, ул. Тестовая, д. 99',
    'ООО "ТестКредит"',
    '+79998887766'
);

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

INSERT INTO Credit_Product (name, installment_repayment, interest_rate, max_amount, max_term, contract_number)
VALUES (
    'Тестовый льготный кредит',
    TRUE,
    3,
    5000000,
    '2040-01-01',
    2000
);

-- Проверка внутри транзакции
SELECT 'Данные перед COMMIT:' AS stage, c.company_name, cc.amount
FROM Client c
JOIN Credit_Contract cc ON c.ID = cc.client_id
WHERE c.ID = 100;

-- Фиксируем изменения
COMMIT;

-- Проверка после COMMIT (вне транзакции)
SELECT 'После COMMIT:' AS stage, c.company_name, cp.name
FROM Client c
JOIN Credit_Contract cc ON c.ID = cc.client_id
JOIN Credit_Product cp ON cp.contract_number = cc.number
WHERE c.ID = 100;