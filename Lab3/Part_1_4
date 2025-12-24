-- Ранжирование кредитов по сумме (без PARTITION BY)
SELECT 
    cc.number as contract_number,
    c.company_name,
    cc.amount as credit_amount,
    cc.debt_balance,
    ROW_NUMBER() OVER (ORDER BY cc.amount DESC) as row_num_by_amount,
    RANK() OVER (ORDER BY cc.amount DESC) as rank_by_amount,
    DENSE_RANK() OVER (ORDER BY cc.amount DESC) as dense_rank_by_amount
FROM Credit_Contract cc
JOIN Client c ON cc.client_id = c.ID
WHERE cc.repaid = FALSE
ORDER BY cc.amount DESC;

-- Ранжирование внутри каждого клиента (с PARTITION BY)
SELECT 
    c.company_name,
    cc.number as contract_number,
    cc.start_date,
    cc.amount,
    cc.debt_balance,
    ROW_NUMBER() OVER (
        PARTITION BY c.ID 
        ORDER BY cc.amount DESC
    ) as client_contract_row_num,
    RANK() OVER (
        PARTITION BY c.ID 
        ORDER BY cc.start_date
    ) as contract_chronological_rank,
    DENSE_RANK() OVER (
        PARTITION BY c.ID 
        ORDER BY EXTRACT(YEAR FROM cc.start_date)
    ) as year_dense_rank
FROM Credit_Contract cc
JOIN Client c ON cc.client_id = c.ID
ORDER BY c.company_name, cc.amount DESC;

-- Рейтинг клиентов по количеству договоров и общей сумме
SELECT 
    c.company_name,
    COUNT(cc.number) as contract_count,
    SUM(cc.amount) as total_credit_amount,
    SUM(cc.debt_balance) as total_debt,
    ROW_NUMBER() OVER (ORDER BY COUNT(cc.number) DESC, SUM(cc.amount) DESC) as row_num,
    RANK() OVER (ORDER BY SUM(cc.amount) DESC) as rank_by_total_amount,
    DENSE_RANK() OVER (ORDER BY COUNT(cc.number) DESC) as dense_rank_by_contract_count
FROM Client c
LEFT JOIN Credit_Contract cc ON c.ID = cc.client_id AND cc.repaid = FALSE
GROUP BY c.ID, c.company_name
ORDER BY contract_count DESC, total_credit_amount DESC;

-- Ранжирование платежей по договорам с анализом
WITH Contract_Payments AS (
    SELECT 
        cc.number as contract_number,
        c.company_name,
        p.date as payment_date,
        p.amount as payment_amount,
        p.type as payment_type,
        a.type as accrual_type,
        SUM(p.amount) OVER (
            PARTITION BY cc.number 
            ORDER BY p.date
        ) as cumulative_payments
    FROM Payment p
    JOIN Accruals a ON p.accrual_id = a.ID
    JOIN Credit_Contract cc ON a.contract_number = cc.number
    JOIN Client c ON cc.client_id = c.ID
)
SELECT 
    contract_number,
    company_name,
    payment_date,
    payment_amount,
    payment_type,
    accrual_type,
    cumulative_payments,
    ROW_NUMBER() OVER (
        PARTITION BY contract_number 
        ORDER BY payment_date
    ) as payment_sequence,
    RANK() OVER (
        PARTITION BY contract_number, accrual_type 
        ORDER BY payment_amount DESC
    ) as amount_rank_by_type,
    DENSE_RANK() OVER (
        ORDER BY EXTRACT(MONTH FROM payment_date), EXTRACT(YEAR FROM payment_date)
    ) as month_dense_rank
FROM Contract_Payments
ORDER BY contract_number, payment_date;