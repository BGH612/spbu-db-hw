-- Table: public.students

-- DROP TABLE IF EXISTS public.students;

CREATE TABLE courses(
	id SERIAL PRIMARY KEY,
	NAME VARCHAR(50),
	is_exam boolean,
	min_grade int, 
	max_grade int
	);



INSERT INTO courses (name, is_exam, min_grade, max_grade) VALUES ('mathematics', '0', '10', '50' ),
('CV', '0', '20', '50' ),('ML', '1', '10', '50' ),('SQL', '1', '20', '50' ),
('SN', '0', '30', '50' );



SELECT * FROM courses LIMIT 100;



CREATE TABLE groups(
	id SERIAL PRIMARY KEY,
	full_name VARCHAR(50),
	short_name VARCHAR(50),
	students_ids integer[]
	);
	
INSERT INTO groups (full_name, short_name, students_ids) VALUES ('Ivanst', 'Iv', array[1, 2, 3]),
('Golan', 'Gol', array[4, 5, 6] ),('Efremov', 'Efr', array[7, 8]),('Balkanov', 'Bal', array[9, 10] )
;
SELECT * FROM groups LIMIT 100;

CREATE TABLE students(
	student_id SERIAL PRIMARY KEY,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	group_id int,
	courses_ids integer[],
	FOREIGN KEY (group_id) REFERENCES GROUPS(id)
	);
--Найдем id группы для каждого студента 
select id  from groups where students_ids@>'{1}' limit 20;
select id  from groups where students_ids@>'{2}' limit 20;
select id  from groups where students_ids@>'{3}' limit 20;
select id  from groups where students_ids@>'{4}' limit 20;
select id  from groups where students_ids@>'{5}' limit 20;
select id  from groups where students_ids@>'{6}' limit 20;
select id  from groups where students_ids@>'{7}' limit 20;
select id  from groups where students_ids@>'{8}' limit 20;
select id  from groups where students_ids@>'{9}' limit 20;
select id  from groups where students_ids@>'{10}' limit 20;

INSERT INTO students (first_name, last_name, group_id, courses_ids) VALUES ('Ivanov', 'Ivan', '1','{1,2,3}'),
('Golubev', 'Andrei', '1','{2,3,4}' ),('Efremov', 'Artem', '1','{3,4,5}'),('Balkanov', 'Anatoly','2', '{2,4,5}' ),
('Seleznev','georgy','2',  '{1,2,3}'),('Antonov', 'Mikhail', '2','{2,3,4}'),('Dmitriev','Aleksei','3','{1,4,5}'),
('Ivanov', 'Ivan', '3','{1,3,5}'),('Ivanov', 'Ivan', '4','{1,2,5}'),('Ivanov', 'Ivan', '4','{1,2,3}');
SELECT * FROM students LIMIT 100;

CREATE TABLE mathematics(
	student_id int,
	grade int,
	grade_str VARCHAR(50),
	FOREIGN KEY (student_id) REFERENCES students(student_id)
	);



--найдем, какие студенты относятся к математике
SELECT student_id  FROM students WHERE courses_ids@>'{1}' LIMIT 20;

INSERT INTO mathematics (student_id, grade) VALUES ('1','45'),('5','35'),('7','30'),('8','20'),('9','27'),('10','37');


--добавим буквенные оценки по условию

UPDATE mathematics
SET grade_str = CASE	
		when grade>=45 then 'A'
		when grade>=40 then 'B'
		when grade>=35 then 'C'
		when grade>=30 then 'D'
		when grade>=25 then 'E'
		else  'F'
			
end;

SELECT * FROM mathematics LIMIT 100;


CREATE TABLE CV(
	student_id int,
	grade int,
	grade_str VARCHAR(50),
	FOREIGN KEY (student_id) REFERENCES students(student_id)
	);
INSERT INTO CV (student_id, grade) VALUES ('1','33'),('2','35'),('4','20'),('5','40'),('6','27'),('9','37'),('10','47');
UPDATE CV
SET grade_str = CASE	
		when grade>=45 then 'A'
		when grade>=40 then 'B'
		when grade>=35 then 'C'
		when grade>=30 then 'D'
		when grade>=25 then 'E'
		else  'F'
			
end;

SELECT * FROM CV LIMT 10;
CREATE TABLE ML(
	student_id int,
	grade int,
	grade_str VARCHAR(50),
	FOREIGN KEY (student_id) REFERENCES students(student_id)
	);
INSERT INTO ML (student_id, grade) VALUES ('1','33'),('2','35'),('3','20'),('5','30'),('6','27'),('8','35'),('10','37');
UPDATE ML
SET grade_str = CASE	
		WHEN grade>=45 THEN 'A'
		WHEN grade>=40 THEN 'B'
		WHEN grade>=35 THEN 'C'
		WHEN grade>=30 THEN 'D'
		WHEN grade>=25 THEN 'E'
		else  'F'
			
end;
SELECT * FROM ML LIMT 10;

CREATE TABLE SQL(
	student_id int,
	grade int,
	grade_str VARCHAR(50),
	FOREIGN KEY (student_id) REFERENCES students(student_id)
	);
INSERT INTO SQL (student_id, grade) VALUES ('2','33'),('3','35'),('4','20'),('6','30'),('7','27');
UPDATE SQL
SET grade_str = CASE	
		WHEN grade>=45 then 'A'
		WHEN grade>=40 then 'B'
		WHEN grade>=35 then 'C'
		WHEN grade>=30 then 'D'
		WHEN grade>=25 then 'E'
		else  'F'
			
end;

SELECT * FROM SQL LIMIT 10;
CREATE TABLE SN(
	student_id int,
	grade int,
	grade_str VARCHAR(50),
	FOREIGN KEY (student_id) REFERENCES students(student_id)
	);
INSERT INTO SN (student_id, grade) VALUES ('3','23'),('4','45'),('7','20'),('8','40'),('9','47');
UPDATE SN
SET grade_str = CASE	
		when grade>=45 then 'A'
		when grade>=40 then 'B'
		when grade>=35 then 'C'
		when grade>=30 then 'D'
		when grade>=25 then 'E'
		else  'F'
			
end;
SELECT * FROM SN LIMIT 10;







CREATE TABLE student_courses(
id SERIAL PRIMARY KEY,
student_id INTEGER REFERENCES students(student_id), 
course_id INTEGER REFERENCES courses(id),
grade INTEGER,
UNIQUE (student_id, course_id));

INSERT INTO student_courses (student_id,course_id,grade) VALUES ('1','1','45'),('1','2','33'),('1','3','33'),('2','2','35'),('2','3','35'),('2','4','33'),
('3','3','20'),('3','4','35'),('3','5','23'), ('4','2','20'),('4','4','20'),('4','5','45'),('5','1','35'),('5','2','40'),('5','3','30'),('6','2','27'),('6','3','27'),('6','4','30'),
('7','1','30'),('7','4','27'),('7','5','20'),('8','1','20'),('8','3','35'),('8','5','40'),('9','1','27'),('9','2','37'),('9','5','47'),('10','1','37'),('10','2','47'),('10','3','37');
SELECT * FROM student_courses LIMIT 50;


CREATE TABLE group_courses (
    id SERIAL PRIMARY KEY,
    group_id INTEGER REFERENCES groups(id),
    course_id INTEGER REFERENCES courses(id),
    UNIQUE (group_id, course_id) 
);
INSERT INTO group_courses (group_id,course_id) VALUES ('1','1'),('1','2'),('1','3'),('1','4'),('1','5'),('2','1'),
('2','2'),('2','4'),('2','5'), ('3','1'),('3','3'),('3','4'),('3','5'),('4','1'),('4','2'),('4','3'),('4','5');

ALTER TABLE students DROP courses_ids;


ALTER TABLE courses ADD CONSTRAINT unique_course_name unique(name);
CREATE INDEX group_ID ON students(group_id);

--Индексирование помогает улучшить производительность запросов, особенно при выполнении операций поиска, сортировки, 
--фильтрации или соединений. Оно сокращает количество строк, которые необходимо просмотреть в таблице, 
--что может значительно ускорить выполнение запросов, особенно на больших данных
SELECT students.student_id, first_name, last_name, course_id, courses.name FROM students INNER JOIN student_courses 
ON students.student_id = student_courses.student_id INNER JOIN courses ON student_courses.course_id = courses.id LIMIT 50;


SELECT students.student_id, students.group_id,AVG(student_courses.grade) AS average_grade 
FROM students INNER JOIN student_courses ON students.student_id=student_courses.student_id 
INNER JOIN courses ON student_courses.course_id=courses.id GROUP BY students.student_id
HAVING AVG (student_courses.grade)>(SELECT MAX (avg_grade) 
FROM (SELECT AVG(g.grade) AS avg_grade FROM students s JOIN student_courses g 
ON s.student_id=g.student_id 
WHERE s.student_id <> students.student_id 
AND s.group_id=students.group_id  
GROUP BY s.student_id) AS other) LIMIT 50;


SELECT
    course_id,
    COUNT(*) AS student_count,
	 AVG(grade) AS average_grade
FROM
    student_courses
GROUP BY
    course_id LIMIT 20;