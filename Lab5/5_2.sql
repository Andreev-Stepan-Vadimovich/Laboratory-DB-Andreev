-- 1
CREATE OR REPLACE FUNCTION mask_phone(original TEXT)
RETURNS TEXT AS $$
BEGIN
    -- Если текущий пользователь — руководитель, показываем оригинал
    IF current_user = 'role_manager' OR pg_has_role(current_user, 'role_manager', 'member') THEN
        RETURN original;
    ELSE
        -- Маскируем: оставляем первые 5 и последние 2 цифры
        IF original IS NULL THEN
            RETURN NULL;
        END IF;
        RETURN REGEXP_REPLACE(original, '(\+\d{4})(\d+)(\d{2})', '\1xxxxx\3');
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;


-- Представление
CREATE OR REPLACE VIEW client_masked AS
SELECT 
    ID,
    contact_person,
    legal_address,
    company_name,
    mask_phone(phone) AS phone
FROM Client;


-- Руководитель работает напрямую с таблицей Client
GRANT ALL PRIVILEGES ON Client TO role_manager;

-- Сотрудник работает с представлением
GRANT SELECT ON client_masked TO role_employee;
REVOKE ALL PRIVILEGES ON Client FROM role_employee;


-- 2
-- Представление с маскировкой для employee
CREATE OR REPLACE VIEW client_employee_view AS
SELECT 
    ID,
    company_name,
    -- Маскируем contact_person: приводим к виду "Фамилия И.О."
    CASE 
        WHEN contact_person ~ '^[А-ЯЁ][а-яё]+\s[А-ЯЁ]\.[А-ЯЁ]\.$' THEN 
            contact_person  -- уже в нужном формате
        ELSE 
            -- Разбиваем на части по пробелам
            SPLIT_PART(contact_person, ' ', 1) || ' ' ||
            LEFT(SPLIT_PART(contact_person, ' ', 2), 1) || '.' ||
            LEFT(SPLIT_PART(contact_person, ' ', 3), 1) || '.'
    END AS contact_person,
    -- Маскируем адрес: оставляем только город (до первой запятой)
    SPLIT_PART(legal_address, ',', 1) || ', ...' AS legal_address,
    -- Маскируем телефон: +79161234567 → +7916xxxxx67
    CASE 
        WHEN phone IS NOT NULL AND LENGTH(phone) >= 7 THEN 
            LEFT(phone, 5) || 'xxxxx' || RIGHT(phone, 2)
        ELSE phone
    END AS phone
FROM Client;

-- Запретим сотруднику доступ к исходной таблице
REVOKE ALL ON Client FROM role_employee;

-- Разрешим только представление
GRANT SELECT ON client_employee_view TO role_employee;