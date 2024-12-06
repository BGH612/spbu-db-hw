
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





--Триггеры и транзакции

--Создадим тригер, который не будет давать добавлять в таблицу поставщиков, уркашения jewelry_type=0
CREATE OR REPLACE FUNCTION check_jewelry()
RETURNS TRIGGER AS $$
DECLARE
    jewelry_type_value integer;
BEGIN
	IF NEW.jewelry_type IS NOT NULL THEN
        FOREACH jewelry_type_value IN ARRAY NEW.jewelry_type
        LOOP
            IF jewelry_type_value = 0 THEN
                RAISE EXCEPTION 'Уркашения с типом 0- нет!!!';
            END IF;
        END LOOP;
    END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_jewelry_trigger
BEFORE INSERT ON suppliers
FOR EACH ROW 
EXECUTE PROCEDURE check_jewelry();

INSERT INTO suppliers (name,jewelry_type)
VALUES ('Ker',array[0,2,3])


--создадим тригер, который будет проверять, чтобы sale price не было меньше supply price
CREATE OR REPLACE FUNCTION check_margin()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.sale_price< NEW.supply_price THEN
		RAISE EXCEPTION 'Цена продажи не должна быть меньше цены покупки!';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER check_margin_trigger
BEFORE INSERT OR UPDATE ON jewelry_type
FOR EACH ROW 
EXECUTE PROCEDURE check_margin();


INSERT INTO jewelry_type (name,supply_price,sale_price,manager_motivation,suppliers)
VALUES ('Chain','30','20','5',array[1,2,5])

--Создадим тригер, который не будет нам давать возможность удалить данные продаж за последний месяц
CREATE OR REPLACE FUNCTION chech_saledate()
RETURNS TRIGGER AS $$
BEGIN
	IF OLD.sale_date>=CURRENT_DATE- INTERVAL '30 days' THEN
		RAISE EXCEPTION 'Нельзя удалить данные за последний месяц';
	END IF;
	RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER chech_saledate_trigger
BEFORE DELETE ON sales
FOR EACH ROW 
EXECUTE PROCEDURE chech_saledate();

DELETE FROM sales WHERE sale_date = '2024-07-11'
	
--создадим триггер, который будет отслеживать изменение продаж 

CREATE TABLE sales_logs(
 log_id SERIAL PRIMARY KEY,
    sale_id INT,
    operation_type VARCHAR(10),
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_value JSONB,
    new_value JSONB
);

CREATE OR REPLACE FUNCTION sales_logging()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP='INSERT' THEN
		INSERT INTO sales_logs(sale_id,operation_type,new_value)
		VALUES (NEW.sale_id, 'INSERT', row_to_json(NEW));
        RAISE NOTICE 'Inserted sales %', NEW.sale_id;
	ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO sales_logs(sale_id, operation_type, old_value, new_value)
        VALUES (NEW.sale_id, 'UPDATE', row_to_json(OLD), row_to_json(NEW));
        RAISE NOTICE 'Updated sales %', NEW.sale_id;
	RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO sales_logs(sale_id, operation_type, old_value)
        VALUES (OLD.sale_id, 'DELETE', row_to_json(OLD));
        RAISE NOTICE 'Deleted sales %', OLD.sale_id;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER sales_changes
AFTER INSERT OR UPDATE OR DELETE ON sales
FOR EACH ROW EXECUTE FUNCTION sales_logging();

INSERT INTO sales (sale_date, product_id, quantity, employee_id)
VALUES ('2024-09-11','1','13','3'),('2024-10-11','2','32','2')






--Теперь посмотрим как наши тригеры работают с транзакциями

--успешная транзакция
BEGIN;
INSERT INTO employees (name, position, division, salary)
VALUES
    ('Anatoly Back', 'Sales assistant', 'Sale', 20000),
	('Ksenia Beluvi', 'Devops', 'it', 50000);
COMMIT;



BEGIN;
INSERT INTO jewelry_type (name,supply_price,sale_price,manager_motivation,suppliers)
VALUES ('Chain','30','20','5',array[1,2,5]);
INSERT INTO sales (sale_date, product_id, quantity, employee_id)
VALUES ('2024-09-11','1','13','3'),('2024-10-11','2','32','2');
COMMIT;
ROLLBACK;

--транзакция работает новые данные не вставляются