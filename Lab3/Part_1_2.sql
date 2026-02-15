-- Информация о кредитных договорах с названием фирмы клиента
SELECT 
    cc.number as contract_number,
    cc.amount,
    cc.start_date,
    cc.end_date,
    cc.debt_balance,
    c.company_name,
    c.contact_person
FROM Credit_Contract cc, Client c
WHERE cc.client_id = c.ID;

-- Начисления с информацией о договоре и клиенте
SELECT 
    a.ID as accrual_id,
    a.amount,
    a.accrual_date,
    a.type,
    cc.number as contract_number,
    cc.amount as contract_amount,
    c.company_name
FROM Accruals a, Credit_Contract cc, Client c
WHERE a.contract_number = cc.number 
  AND cc.client_id = c.ID;

-- Кредитные договоры с информацией о клиенте и кредитном продукте
SELECT 
    cc.number as contract_number,
    cc.amount as contract_amount,
    cc.start_date,
    cc.end_date,
    c.company_name,
    cp.name as product_name,
    cp.interest_rate
FROM Credit_Contract cc
INNER JOIN Client c ON cc.client_id = c.ID
INNER JOIN Credit_Product cp ON cc.number = cp.contract_number;

-- Все платежи с информацией о начислении и договоре
SELECT 
    p.ID as payment_id,
    p.type as payment_type,
    p.date as payment_date,
    p.amount as payment_amount,
    a.type as accrual_type,
    a.accrual_date,
    cc.number as contract_number
FROM Payment p
INNER JOIN Accruals a ON p.accrual_id = a.ID
INNER JOIN Credit_Contract cc ON a.contract_number = cc.number;

-- Все клиенты, даже если у них нет кредитных договоров
SELECT 
    c.ID,
    c.company_name,
    c.contact_person,
    cc.number as contract_number,
    cc.amount,
    cc.start_date
FROM Client c
LEFT JOIN Credit_Contract cc ON c.ID = cc.client_id
ORDER BY c.company_name;

-- Все кредитные договоры с информацией о продукте (если есть)
SELECT 
    cc.number,
    cc.amount,
    cc.start_date,
    cc.end_date,
    cp.name as product_name,
    cp.interest_rate
FROM Credit_Contract cc
LEFT JOIN Credit_Product cp ON cc.number = cp.contract_number;

-- Все кредитные продукты с информацией о договоре (обратный порядок)
SELECT 
    cp.name as product_name,
    cp.interest_rate,
    cp.max_amount,
    cc.number as contract_number,
    cc.amount as contract_amount,
    cc.start_date
FROM Credit_Product cp
RIGHT JOIN Credit_Contract cc ON cp.contract_number = cc.number;

-- Все платежи и соответствующие начисления (включая начисления без платежей)
SELECT 
    p.ID as payment_id,
    p.type as payment_type,
    p.amount as payment_amount,
    a.ID as accrual_id,
    a.type as accrual_type,
    a.amount as accrual_amount
FROM Payment p
RIGHT JOIN Accruals a ON p.accrual_id = a.ID
WHERE a.repaid = FALSE;

-- Клиенты с общей суммой кредитов больше 1 млн
SELECT 
    c.company_name,
    SUM(cc.amount) as total_credit_amount,
    COUNT(cc.number) as contract_count
FROM Client c
INNER JOIN Credit_Contract cc ON c.ID = cc.client_id
GROUP BY c.ID, c.company_name
HAVING SUM(cc.amount) > 1000000
ORDER BY total_credit_amount DESC;

-- Банки, у которых более 1 кредита в истории
SELECT 
    bank_name,
    COUNT(*) as loan_count,
    AVG(amount) as avg_loan_amount
FROM Credit_History
GROUP BY bank_name
HAVING COUNT(*) > 1
ORDER BY loan_count DESC;

-- Клиенты, у которых есть непогашенные кредитные договоры
SELECT *
FROM Client
WHERE ID IN (
    SELECT DISTINCT client_id 
    FROM Credit_Contract 
    WHERE repaid = FALSE
);

-- Кредитные договоры, по которым есть начисления типа "штраф" (используя EXISTS)
SELECT *
FROM Credit_Contract cc
WHERE EXISTS (
    SELECT 1 
    FROM Accruals a 
    WHERE a.contract_number = cc.number 
      AND a.type = 'штраф'
);

-- Клиенты, у которых нет кредитной истории в Сбербанке (используя NOT EXISTS)
SELECT *
FROM Client c
WHERE NOT EXISTS (
    SELECT 1 
    FROM Credit_History ch 
    WHERE ch.client_id = c.ID 
      AND ch.bank_name = 'Сбербанк'
);

-- Кредитные продукты, которые используются в договорах на сумму больше 500000
SELECT *
FROM Credit_Product cp
WHERE contract_number IN (
    SELECT number 
    FROM Credit_Contract 
    WHERE amount > 500000
);