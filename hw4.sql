
CREATE TABLE IF NOT EXISTS employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    manager_id INT REFERENCES employees(employee_id)
);

-- Пример данных
INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Frank Miller', 'Intern', 'IT', 35000, 5);

SELECT * FROM employees LIMIT 5;

CREATE TABLE IF NOT EXISTS sales(
    sale_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    sale_date DATE NOT NULL
);

-- Пример данных
INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES
    (2, 1, 20, '2024-11-14'),
    (2, 2, 15, '2024-10-16'),
    (3, 1, 10, '2024-10-17'),
    (3, 3, 5, '2024-10-20'),
    (4, 2, 8, '2024-10-21'),
    (2, 1, 12, '2024-11-12');


CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

-- Пример данных
INSERT INTO products (name, price)
VALUES
    ('Product A', 150.00),
    ('Product B', 200.00),
    ('Product C', 100.00);


--Создать триггеры со всеми возможными ключевыми словами, а также рассмотреть операционные триггеры

--delete
CREATE OR REPLACE FUNCTION check_head()
RETURNS TRIGGER AS $$
BEGIN 
	 IF OLD.manager_id IS NULL THEN
        RAISE EXCEPTION 'Нельзя удалить менеджера, у которого есть подчиненные';
	END IF;
	RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER manager_hire_trigger
BEFORE DELETE ON employees
FOR EACH ROW 
EXECUTE PROCEDURE check_head();

DELETE FROM employees WHERE name = 'Alice Johnson'
--update, insert
CREATE OR REPLACE FUNCTION check_dep()
RETURNS TRIGGER AS $$
BEGIN 
	IF NEW.department NOT IN ('Sales', 'IT') THEN 
		RAISE EXCEPTION 'Такого отдела не существует';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_dep
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW 
WHEN (NEW.department IS NOT NULL)
EXECUTE FUNCTION check_salary();



--Попрактиковаться в созданиях транзакций (привести пример успешной и фейл транзакции, объяснить в комментариях почему она зафейлилась)
BEGIN;

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Anatoly Back', 'Sales assistant', 'Sale', 20000, NULL),
	('Ksenia Beluvi', 'Devops', 'it', 50000, NULL);
COMMIT;
ROLLBACK;
--фейл транзакция, потому что департамент написан неправильно
BEGIN;

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Anton Cherniy', 'Sales assistant', 'Sales', 26000, NULL),
	('Kristina Klev', 'Devops', 'IT', 50000, NULL);
	
COMMIT;
--транзакция сработает
SELECT * FROM employees LIMIT 50;


--Попробовать использовать RAISE внутри триггеров для логирования

CREATE TABLE employee_logs(
 log_id SERIAL PRIMARY KEY,
    employee_id INT,
    operation_type VARCHAR(10),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_value JSONB,
    new_value JSONB
);

CREATE OR REPLACE FUNCTION employee_logging()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP='INSERT' THEN
		INSERT INTO employee_logs(employee_id,operation_type,new_value)
		VALUES (NEW.employee_id, 'INSERT', row_to_json(NEW));
        RAISE NOTICE 'Inserted employee %', NEW.employee_id;
	ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO employee_logs(employee_id, operation_type, old_value, new_value)
        VALUES (NEW.employee_id, 'UPDATE', row_to_json(OLD), row_to_json(NEW));
        RAISE NOTICE 'Updated employee %', NEW.employee_id;
	RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO employee_logs(employee_id, operation_type, old_value)
        VALUES (OLD.employee_id, 'DELETE', row_to_json(OLD));
        RAISE NOTICE 'Deleted employee %', OLD.employee_id;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER employee_changes
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW EXECUTE FUNCTION employee_logging();


INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Denis Cherniy', 'Sales assistant', 'Sales', 35000, NULL);

UPDATE employees 
SET salary = 40000
WHERE name = 'Denis Cherniy';

DELETE FROM employees WHERE name= 'Denis Cherniy';

SELECT * FROM employee_logs LIMIT 10

