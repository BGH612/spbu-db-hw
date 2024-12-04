
CREATE TABLE suppliers(
supplier_id SERIAL PRIMARY KEY,
name VARCHAR(50),
jewelry_type INTEGER[]
);
INSERT INTO suppliers (name,jewelry_type)
VALUES ('Ker',array[1,2,3]),('Nte', array[1,2,3]),('Kfa', array[2,3,4]),('Wer', array[3,4,5]),('Kpo', array[1,4,5]);
--найдем поставщиков которые продают изделия с id=2
SELECT supplier_id FROM suppliers WHERE 2 = ANY(jewelry_type) LIMIT 50;

CREATE TABLE jewelry_type(
jewelry_id SERIAL PRIMARY KEY,
name VARCHAR(50),
supply_price INT,
sale_price INT,
suppliers INTEGER[],
manager_motivation INT
);
INSERT INTO jewelry_type (name,supply_price,sale_price,manager_motivation,suppliers)
VALUES ('Chain','30','40','5',array[1,2,5]),('Wristband','25','42','7', array[1,2,3]), ('Ring', '30','35','3',array[1,2,3,4]),
('Earrings','45','60','10' ,array[3,4,5]),('Pendant','33','45','9', array[4,5]);

-- найдем самые маржинальные продукты
SELECT (sale_price- supply_price) AS margin, jewelry_id FROM jewelry_type ORDER BY  margin DESC LIMIT 40;

CREATE TABLE sales(
sale_id SERIAL PRIMARY KEY ,
sale_date DATE NOT NULL,
product_id INT NOT NULL REFERENCES jewelry_type(jewelry_id),
quantity INT NOT NULL,
employee_id INT REFERENCES employees(employee_id)
);
INSERT INTO sales (sale_date, product_id, quantity, employee_id)
VALUES ('2024-01-11','1','23','3'),('2024-02-11','2','30','2'),('2024-03-11','1','40','2'),('2024-04-11','3','30','3'),
('2024-05-11','5','40','1'),('2024-06-11','3','30','1'),('2024-07-11','4','33','2'),('2024-08-11','1','30','3');
--найдем количесвто продаж для каждого продукта и отсортируем по возрастанию количества продаж
SELECT SUM(quantity) AS total_sales ,product_id FROM sales GROUP BY product_id ORDER BY total_sales LIMIT 50;
--найдем количество продаж для каждого продукта и сотрудника и отсортируем по уменьшению количества продаж
SELECT SUM(quantity) AS total_sales ,product_id,employee_id FROM sales GROUP BY product_id, employee_id 
ORDER BY total_sales DESC LIMIT 50;


DROP TABLE sales

CREATE TABLE employees(
employee_id SERIAL PRIMARY KEY,
name VARCHAR(50) NOT NULL,
position VARCHAR(50) NOT NULL,
division VARCHAR(50) NOT NULL,
salary NUMERIC(10, 2) NOT NULL,
premium NUMERIC(10, 2)
);
INSERT INTO employees (name,position,division,salary)
VALUES ('Ivan Antonov','Head manager','sales','60000'), ('Andrei Fedorov','manager','sales','40000'),
('Dmitriy Feliks','manager','sales','40000'), ('Gleb Trifonov','sales assistan','sales','30000'),
('Dmitriy Ivanov', 'Director', 'Head office','100000'),('Denis Carbin', 'Operator','IT','70000');

--Найдем сотрудника, у которого зарплата самая большая 
SELECT * FROM employees ORDER BY salary DESC LIMIT 1 ;
--вычислим премию для менеджеров, для этого перемножим их мотивацию на общее количество продаж
UPDATE employees 
SET premium= CASE


