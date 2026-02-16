-- Роль для руководителя (администратора)
CREATE ROLE role_manager WITH LOGIN PASSWORD 'manager_pass';
GRANT ALL PRIVILEGES ON DATABASE lab TO role_manager;

-- Роль для сотрудника
CREATE ROLE role_employee WITH LOGIN PASSWORD 'employee_pass';


-- Для role_manager
-- Доступ ко всем таблицам
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO role_manager WITH GRANT OPTION;

-- Доступ ко всем последовательностям (если есть SERIAL)
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO role_manager WITH GRANT OPTION;

-- Доступ ко всем функциям и процедурам
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO role_manager WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON ALL PROCEDURES IN SCHEMA public TO role_manager WITH GRANT OPTION;

-- Возможность создавать объекты
ALTER ROLE role_manager CREATEDB;
ALTER ROLE role_manager CREATEROLE;


-- Для role_employee
-- Чтение клиентов (без конфиденциальных данных)
CREATE VIEW client_public AS
SELECT ID, company_name
FROM Client;

GRANT SELECT ON client_public TO role_employee;

-- Полный доступ к Credit_Contract и Credit_Product (для работы)
GRANT SELECT, INSERT, UPDATE, DELETE ON Credit_Contract TO role_employee;
GRANT SELECT, INSERT, UPDATE, DELETE ON Credit_Product TO role_employee;

-- Доступ к Accruals и Payment (только чтение и вставка)
GRANT SELECT, INSERT ON Accruals TO role_employee;
GRANT SELECT, INSERT ON Payment TO role_employee;

-- Выполнение только разрешённых функций
GRANT EXECUTE ON FUNCTION get_revenue_current_year(INT) TO role_employee;

-- Последовательности
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO role_employee;


-- Создание пользователей и привязка ролей
CREATE USER manager WITH PASSWORD '12345678';
CREATE USER employee WITH PASSWORD '12345678';

-- Руководитель
GRANT role_manager TO manager;

-- Сотрудник
GRANT role_employee TO employee;