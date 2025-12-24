-- Все уникальные контакты из клиентов и банков из кредитной истории
SELECT 
    contact_person as name,
    phone,
    'Клиент' as type
FROM Client
WHERE phone IS NOT NULL

UNION ALL

SELECT 
    bank_name as name,
    NULL as phone,
    'Банк' as type
FROM Credit_History
WHERE bank_name IS NOT NULL

ORDER BY type, name;

-- Клиенты, которые брали кредиты в определенных банках
SELECT DISTINCT 
    c.ID,
    c.company_name,
    c.contact_person,
    'Сбербанк' as preferred_bank
FROM Client c
JOIN Credit_History ch ON c.ID = ch.client_id
WHERE ch.bank_name = 'Сбербанк'

UNION

SELECT DISTINCT 
    c.ID,
    c.company_name,
    c.contact_person,
    'ВТБ' as preferred_bank
FROM Client c
JOIN Credit_History ch ON c.ID = ch.client_id
WHERE ch.bank_name = 'ВТБ'

ORDER BY preferred_bank, company_name;

-- Клиенты, у которых есть и активные и закрытые договоры
SELECT DISTINCT c.ID, c.company_name
FROM Client c
JOIN Credit_Contract cc ON c.ID = cc.client_id
WHERE cc.repaid = FALSE

INTERSECT

SELECT DISTINCT c.ID, c.company_name
FROM Client c
JOIN Credit_Contract cc ON c.ID = cc.client_id
WHERE cc.repaid = TRUE

ORDER BY company_name;

-- Клиенты без просроченных начислений
SELECT DISTINCT c.ID, c.company_name
FROM Client c

EXCEPT

SELECT DISTINCT c.ID, c.company_name
FROM Client c
JOIN Credit_Contract cc ON c.ID = cc.client_id
JOIN Accruals a ON cc.number = a.contract_number
WHERE a.repaid = FALSE 
  AND a.accrual_date < CURRENT_DATE - INTERVAL '30 days'

ORDER BY company_name;