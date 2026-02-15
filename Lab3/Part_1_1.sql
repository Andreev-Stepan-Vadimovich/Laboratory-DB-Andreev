-- Сортировка клиентов по названию фирмы по возрастанию и ID по убыванию
SELECT * FROM Client 
ORDER BY company_name ASC, ID DESC;

-- Сортировка кредитных договоров по сумме (по убыванию) и дате начала (по возрастанию)
SELECT * FROM Credit_Contract 
ORDER BY amount DESC, start_date ASC;

-- Сортировка начислений по типу (по возрастанию) и дате (по убыванию)
SELECT * FROM Accruals 
ORDER BY type ASC, accrual_date DESC;

-- Выбор клиентов из Москвы
SELECT * FROM Client 
WHERE legal_address LIKE '%Москва%';

-- Выбор непогашенных кредитных договоров на сумму больше 500000
SELECT * FROM Credit_Contract 
WHERE repaid = FALSE AND amount > 500000;

-- Общая сумма всех кредитных договоров
SELECT SUM(amount) as total_credit_amount FROM Credit_Contract;

-- Количество уникальных клиентов с кредитной историей
SELECT COUNT(DISTINCT client_id) as unique_clients FROM Credit_History;

-- Сумма кредитов по каждому клиенту
SELECT client_id, SUM(amount) as total_client_credit
FROM Credit_Contract 
GROUP BY client_id;

-- Количество кредитных договоров по статусу погашения
SELECT repaid, COUNT(*) as contract_count
FROM Credit_Contract 
GROUP BY repaid;

-- Сумма начислений по типам и статусу погашения с подытогами
SELECT 
    type,
    repaid,
    SUM(amount) as total_amount,
    COUNT(*) as count_accruals
FROM Accruals 
GROUP BY ROLLUP(type, repaid)
ORDER BY type, repaid;

-- Количество кредитных договоров по клиентам и статусу с итогами
SELECT 
    client_id,
    repaid,
    COUNT(*) as contract_count,
    SUM(amount) as total_amount
FROM Credit_Contract 
GROUP BY ROLLUP(client_id, repaid)
ORDER BY client_id, repaid;

-- Анализ платежей по типам и датам (все комбинации)
SELECT 
    type,
    EXTRACT(YEAR FROM date) as payment_year,
    EXTRACT(MONTH FROM date) as payment_month,
    COUNT(*) as payment_count,
    SUM(amount) as total_paid
FROM Payment 
GROUP BY CUBE(type, EXTRACT(YEAR FROM date), EXTRACT(MONTH FROM date))
ORDER BY type, payment_year, payment_month;

-- Анализ кредитной истории по банкам и статусу погашения
SELECT 
    bank_name,
    repaid,
    COUNT(*) as history_count,
    AVG(amount) as avg_amount
FROM Credit_History 
GROUP BY CUBE(bank_name, repaid)
ORDER BY bank_name, repaid;

-- Клиенты, в названии фирмы которых нет "ООО"
SELECT * FROM Client 
WHERE company_name NOT LIKE '%ООО%';

-- Банки в кредитной истории, в названии которых нет "банк" (без учета регистра)
SELECT * FROM Credit_History 
WHERE bank_name NOT ILIKE '%банк%';