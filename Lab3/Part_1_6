-- Анализ клиентов по категориям задолженности
SELECT 
    c.company_name,
    c.contact_person,
    SUM(cc.amount) as total_credit_amount,
    SUM(cc.debt_balance) as total_debt,
    CASE 
        WHEN SUM(cc.debt_balance) = 0 THEN 'Нет задолженности'
        WHEN SUM(cc.debt_balance) <= 500000 THEN 'Маленькая задолженность'
        WHEN SUM(cc.debt_balance) <= 2000000 THEN 'Средняя задолженность'
        ELSE 'Большая задолженность'
    END as debt_category,
    CASE 
        WHEN COUNT(cc.number) = 0 THEN 'Без договоров'
        WHEN COUNT(cc.number) = 1 THEN 'Один договор'
        WHEN COUNT(cc.number) <= 3 THEN 'Несколько договоров'
        ELSE 'Много договоров'
    END as contract_category
FROM Client c
LEFT JOIN Credit_Contract cc ON c.ID = cc.client_id AND cc.repaid = FALSE
GROUP BY c.ID, c.company_name, c.contact_person
ORDER BY total_debt DESC;

-- Сводка платежей по месяцам с использованием CASE
SELECT 
    EXTRACT(YEAR FROM p.date) as year,
    EXTRACT(MONTH FROM p.date) as month,
    SUM(CASE WHEN p.type = 'банковский перевод' THEN p.amount ELSE 0 END) as bank_transfer_total,
    SUM(CASE WHEN p.type = 'наличные' THEN p.amount ELSE 0 END) as cash_total,
    SUM(CASE WHEN p.type = 'банковская карта' THEN p.amount ELSE 0 END) as card_total,
    SUM(CASE WHEN p.type = 'электронный платеж' THEN p.amount ELSE 0 END) as electronic_total,
    SUM(p.amount) as total_amount,
    COUNT(CASE WHEN p.type = 'банковский перевод' THEN 1 END) as bank_transfer_count,
    COUNT(CASE WHEN p.type = 'наличные' THEN 1 END) as cash_count,
    COUNT(CASE WHEN p.type = 'банковская карта' THEN 1 END) as card_count,
    COUNT(CASE WHEN p.type = 'электронный платеж' THEN 1 END) as electronic_count,
    ROUND(AVG(p.amount), 2) as avg_payment
FROM Payment p
WHERE p.date IS NOT NULL
GROUP BY EXTRACT(YEAR FROM p.date), EXTRACT(MONTH FROM p.date)
ORDER BY year DESC, month DESC;

-- Сводка платежей по типам по месяцам 
SELECT 
    TO_CHAR(p.date, 'YYYY-MM') as month_year,
    SUM(CASE WHEN p.type = 'банковский перевод' THEN p.amount ELSE 0 END) as "Банковский перевод",
    SUM(CASE WHEN p.type = 'наличные' THEN p.amount ELSE 0 END) as "Наличные",
    SUM(CASE WHEN p.type = 'банковская карта' THEN p.amount ELSE 0 END) as "Банковская карта",
    SUM(CASE WHEN p.type = 'электронный платеж' THEN p.amount ELSE 0 END) as "Электронный платеж",
    SUM(p.amount) as "Общая сумма"
FROM Payment p
WHERE p.date IS NOT NULL
GROUP BY TO_CHAR(p.date, 'YYYY-MM')
ORDER BY month_year DESC;


