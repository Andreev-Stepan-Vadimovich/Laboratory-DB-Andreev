-- a) Для каждого клиента вывести количество взятых им кредитов и их общую сумму
SELECT 
    c.ID,
    c.company_name as "Название фирмы",
    c.contact_person as "Контактное лицо",
    COUNT(cc.number) as "Количество кредитов",
    COALESCE(SUM(cc.amount), 0) as "Общая сумма кредитов",
    COALESCE(SUM(cc.debt_balance), 0) as "Текущая задолженность",
    COUNT(CASE WHEN cc.repaid = TRUE THEN 1 END) as "Погашенные кредиты",
    COUNT(CASE WHEN cc.repaid = FALSE THEN 1 END) as "Активные кредиты"
FROM Client c
LEFT JOIN Credit_Contract cc ON c.ID = cc.client_id
GROUP BY c.ID, c.company_name, c.contact_person
ORDER BY "Общая сумма кредитов" DESC, "Количество кредитов" DESC;

-- b) Найти самые выгодные кредиты (минимальная процентная ставка + возможность погашения по частям)
SELECT 
    cp.name as "Название кредитного продукта",
    cp.interest_rate as "Процентная ставка",
    CASE 
        WHEN cp.installment_repayment = TRUE THEN 'Да' 
        ELSE 'Нет' 
    END as "Погашение по частям",
    cp.max_amount as "Максимальная сумма",
    cp.max_term as "Максимальный срок",
    cc.number as "Номер договора",
    c.company_name as "Клиент",
    cc.amount as "Сумма договора",
    ROUND((100 - cp.interest_rate) + 
          CASE WHEN cp.installment_repayment THEN 20 ELSE 0 END, 2) as "Индекс выгодности"
FROM Credit_Product cp
JOIN Credit_Contract cc ON cp.contract_number = cc.number
JOIN Client c ON cc.client_id = c.ID
WHERE cp.installment_repayment = TRUE
ORDER BY cp.interest_rate ASC,
         cp.max_amount DESC,
         "Индекс выгодности" DESC
LIMIT 5;

-- c) Выдать информацию о количестве заключенных сделок за каждый день с начала текущего месяца
SELECT 
    DATE(cc.start_date) as "Дата заключения",
    COUNT(cc.number) as "Количество договоров",
    SUM(cc.amount) as "Общая сумма договоров",
    STRING_AGG(c.company_name, ', ') as "Клиенты"
FROM Credit_Contract cc
JOIN Client c ON cc.client_id = c.ID
WHERE cc.start_date >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY DATE(cc.start_date)
ORDER BY "Дата заключения" DESC;

-- d) Найти виды кредитов, не пользующиеся спросом (по которым не заключено ни одной сделки)
WITH AllCreditProducts AS (
    SELECT 'Ипотека стандарт' as product_name UNION
    SELECT 'Ипотека льготная' UNION
    SELECT 'Автокредит' UNION
    SELECT 'Потребительский кредит' UNION
    SELECT 'Бизнес-кредит' UNION
    SELECT 'Рефинансирование' UNION
    SELECT 'Сельхозкредит' UNION
    SELECT 'Образовательный кредит' UNION
    SELECT 'Кредит на развитие бизнеса'
)
SELECT 
    acp.product_name as "Непопулярные кредитные продукты",
    'Не заключено ни одного договора' as "Причина"
FROM AllCreditProducts acp
LEFT JOIN Credit_Product cp ON acp.product_name = cp.name
WHERE cp.name IS NULL
ORDER BY acp.product_name;

-- e) Среди клиентов с наибольшим количеством кредитов в данном банке найти тех, у кого «плохая» кредитная история (непогашенные кредиты в др.банках)
WITH BankClients AS (
    SELECT 
        c.ID,
        c.company_name,
        COUNT(DISTINCT cc.number) as bank_contracts_count,
        SUM(cc.amount) as bank_total_amount,
        RANK() OVER (ORDER BY COUNT(DISTINCT cc.number) DESC) as rank_by_contracts
    FROM Client c
    JOIN Credit_Contract cc ON c.ID = cc.client_id
    JOIN Credit_Product cp ON cc.number = cp.contract_number
    WHERE EXISTS (
        SELECT 1 FROM Credit_History ch 
        WHERE ch.client_id = c.ID 
        AND ch.bank_name = 'Сбербанк'
    )
    GROUP BY c.ID, c.company_name
),
BadCreditHistory AS (
    SELECT 
        ch.client_id,
        COUNT(*) as unpaid_other_banks,
        STRING_AGG(DISTINCT ch.bank_name, ', ') as problem_banks,
        SUM(ch.amount) as total_unpaid_amount
    FROM Credit_History ch
    WHERE ch.repaid = FALSE
      AND ch.bank_name != 'Сбербанк'
    GROUP BY ch.client_id
    HAVING COUNT(*) > 0
)
SELECT 
    bc.company_name as "Клиент",
    bc.bank_contracts_count as "Кредитов в Сбербанке",
    bc.bank_total_amount as "Общая сумма в Сбербанке",
    COALESCE(bch.unpaid_other_banks, 0) as "Непогашенных в других банках",
    COALESCE(bch.problem_banks, 'Нет') as "Проблемные банки",
    COALESCE(bch.total_unpaid_amount, 0) as "Сумма непогашенных",
    CASE 
        WHEN bch.unpaid_other_banks IS NOT NULL THEN 'Плохая КИ'
        ELSE 'Хорошая КИ'
    END as "Кредитная история",
    CASE 
        WHEN bch.unpaid_other_banks >= 2 THEN 'Высокий риск'
        WHEN bch.unpaid_other_banks = 1 THEN 'Средний риск'
        ELSE 'Низкий риск'
    END as "Уровень риска"
FROM BankClients bc
LEFT JOIN BadCreditHistory bch ON bc.ID = bch.client_id
WHERE bc.rank_by_contracts <= 10
   OR bch.unpaid_other_banks IS NOT NULL
ORDER BY bc.bank_contracts_count DESC, bch.unpaid_other_banks DESC NULLS LAST;