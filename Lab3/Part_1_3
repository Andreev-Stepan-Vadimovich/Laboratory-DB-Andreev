-- Активные кредиты клиентов
CREATE VIEW Active_Credits AS
SELECT 
    c.company_name,
    c.contact_person,
    c.phone,
    cc.number as contract_number,
    cc.amount as total_amount,
    cc.debt_balance as current_debt,
    cc.start_date,
    cc.end_date,
    cp.name as credit_product,
    cp.interest_rate
FROM Client c
JOIN Credit_Contract cc ON c.ID = cc.client_id
JOIN Credit_Product cp ON cc.number = cp.contract_number
WHERE cc.repaid = FALSE
ORDER BY c.company_name, cc.start_date;

-- Анализ кредитного положения клиента
WITH Client_Credit_Analysis AS (
    SELECT 
        c.ID,
        c.company_name,
        COUNT(DISTINCT cc.number) as active_contracts_count,
        SUM(cc.debt_balance) as total_debt,
        AVG(cp.interest_rate) as avg_interest_rate,
        MAX(cc.amount) as max_credit_amount
    FROM Client c
    LEFT JOIN Credit_Contract cc ON c.ID = cc.client_id AND cc.repaid = FALSE
    LEFT JOIN Credit_Product cp ON cc.number = cp.contract_number
    GROUP BY c.ID, c.company_name
),
Payment_Analysis AS (
    SELECT 
        cc.client_id,
        SUM(p.amount) as total_payments_last_month
    FROM Payment p
    JOIN Accruals a ON p.accrual_id = a.ID
    JOIN Credit_Contract cc ON a.contract_number = cc.number
    WHERE p.date >= CURRENT_DATE - INTERVAL '1 month'
    GROUP BY cc.client_id
)
SELECT 
    cca.company_name,
    cca.active_contracts_count,
    cca.total_debt,
    cca.avg_interest_rate,
    COALESCE(pa.total_payments_last_month, 0) as recent_payments
FROM Client_Credit_Analysis cca
LEFT JOIN Payment_Analysis pa ON cca.ID = pa.client_id
ORDER BY cca.total_debt DESC;

-- Расчет среднего чека по типам платежей с нарастающим итогом
WITH Monthly_Payments AS (
    SELECT 
        EXTRACT(YEAR FROM p.date) as payment_year,
        EXTRACT(MONTH FROM p.date) as payment_month,
        p.type as payment_type,
        SUM(p.amount) as monthly_amount,
        COUNT(*) as payment_count
    FROM Payment p
    WHERE p.date >= '2023-01-01'
    GROUP BY EXTRACT(YEAR FROM p.date), EXTRACT(MONTH FROM p.date), p.type
),
Cumulative_Summary AS (
    SELECT 
        payment_year,
        payment_month,
        payment_type,
        monthly_amount,
        payment_count,
        SUM(monthly_amount) OVER (
            PARTITION BY payment_type 
            ORDER BY payment_year, payment_month
        ) as cumulative_amount_by_type,
        SUM(monthly_amount) OVER (
            ORDER BY payment_year, payment_month
        ) as cumulative_total_amount
    FROM Monthly_Payments
)
SELECT 
    payment_year,
    payment_month,
    payment_type,
    monthly_amount,
    ROUND(monthly_amount / payment_count, 2) as avg_payment_amount,
    cumulative_amount_by_type,
    cumulative_total_amount
FROM Cumulative_Summary
ORDER BY payment_year, payment_month, payment_type;