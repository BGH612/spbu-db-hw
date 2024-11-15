
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
DROP TABLE sales;
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

   --Создайте временную таблицу high_sales_products, которая будет содержать продукты, проданные в количестве более 10 единиц за последние 7 дней. Выведите данные из таблицы high_sales_products 
DROP TABLE high_sales_products;
CREATE TEMP TABLE high_sales_products AS SELECT * FROM sales WHERE quantity>10
AND sale_date >= CURRENT_DATE - INTERVAL '7 days';
SELECT * FROM high_sales_products LIMIT 5;
--Создайте CTE employee_sales_stats, который посчитает общее количество продаж и среднее количество продаж для каждого сотрудника за последние 30 дней. Напишите запрос, который выводит сотрудников с количеством продаж выше среднего по компании
WITH employee_sales_stats AS (SELECT 
employee_id,
COUNT(sale_id) AS total_sales,
AVG(quantity) AS avg_sales_per_sale
FROM sales
WHERE sale_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY employee_id),
average_sales AS (SELECT AVG(total_sales) AS company_avg_sales FROM employee_sales_stats)
SELECT e.employee_id,es.total_sales,es.avg_sales_per_sale
FROM employee_sales_stats es
JOIN average_sales a ON es.total_sales > a.company_avg_sales
JOIN employees e ON es.employee_id = e.employee_id;

--Используя CTE, создайте иерархическую структуру, показывающую всех сотрудников, которые подчиняются конкретному менеджеру
WITH RECURSIVE EmployeeHierarchy AS (
SELECT 
employee_id, name, position, manager_id,0 AS level  
FROM employees
 WHERE employee_id = 1 
UNION ALL
SELECT e.employee_id,e.name, e.position, e.manager_id,eh.level + 1  
FROM employees e
INNER JOIN EmployeeHierarchy eh ON e.manager_id = eh.employee_id
)
SELECT 
REPEAT(' ', level * 2) || name AS employee_name,
position
FROM EmployeeHierarchy
ORDER BY level,name LIMIT 10;
--Напишите запрос с CTE, который выведет топ-3 продукта по количеству продаж за текущий месяц и за прошлый месяц. В результатах должно быть указано, к какому месяцу относится каждая запись
WITH monthly_sales AS (
    SELECT product_id,
SUM(quantity) AS total_quantity,
EXTRACT(MONTH FROM sale_date) AS sale_month
FROM sales
GROUP BY product_id, sale_month
),
ranked_sales AS (
SELECT
product_id,
total_quantity,
sale_month,
ROW_NUMBER() OVER (PARTITION BY sale_month ORDER BY total_quantity DESC) AS rank
FROM monthly_sales
)
SELECT
product_id,
total_quantity,
sale_month
FROM ranked_sales
WHERE rank <= 3
ORDER BY  sale_month, total_quantity DESC LIMIT 10;
--Создайте индекс для таблицы sales по полю employee_id и sale_date. Проверьте, как наличие индекса влияет на производительность следующего запроса, используя трассировку (EXPLAIN ANALYZE)
CREATE INDEX ind_employee_id ON sales(employee_id);
CREATE INDEX ind_sale_date ON sales(sale_date)
--Используя трассировку, проанализируйте запрос, который находит общее количество проданных единиц каждого продукта.
CREATE INDEX ind_sale_date ON sales(product_id);
DROP INDEX ind_sale_date
EXPLAIN ANALYZE
WITH max_sales_product AS (SELECT product_id, SUM(quantity) FROM sales GROUP BY product_id)
SELECT * FROM max_sales_product LIMIT 10
--Без индекса "Planning Time: 0.843 ms"
"Execution Time: 0.055 ms"
--С индексом
--"Planning Time: 0.146 ms"
"Execution Time: 0.058 ms"
-- На таком объеме данных сложно заметить какие либо изменения, необходим объем данных содержащий 10к данных и более


