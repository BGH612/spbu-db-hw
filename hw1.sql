create table courses(
	id SERIAL primary key,
	name VARCHAR(50),
	is_exam boolean,
	min_grade int, 
	max_grade int
	);



insert INTO courses (name, is_exam, min_grade, max_grade) VALUES ('mathematics', '0', '10', '50' ),
('CV', '0', '20', '40' ),('ML', '1', '10', '50' ),('SQL', '1', '20', '50' ),
('SN', '0', '30', '40' ),('Algebra', '1', '30', '50' );



select * from courses limit 100;



create table groups(
	id SERIAL primary key,
	full_name VARCHAR(50),
	short_name VARCHAR(50),
	students_ids integer[]
	);
	
insert INTO groups (full_name, short_name, students_ids) VALUES ('Ivanst', 'Iv', array[1, 2, 3]),
('Golan', 'Gol', array[4, 5, 6] ),('Efremov', 'Efr', array[7, 8]),('Balkanov', 'Bal', array[9, 10] )
;
select * from groups limit 100;

create table students(
	student_id SERIAL primary key,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	group_id int,
	courses_ids integer[],
	foreign key (group_id) references groups(id)
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

insert INTO students (first_name, last_name, group_id, courses_ids) VALUES ('Ivanov', 'Ivan', '1','{1,2,3}'),
('Golubev', 'Andrei', '1','{2,3,4}' ),('Efremov', 'Artem', '1','{3,4,5}'),('Balkanov', 'Anatoly','2', '{2,4,5}' ),
('Seleznev','georgy','2',  '{1,2,3}'),('Antonov', 'Mikhail', '2','{2,3,4}'),('Dmitriev','Aleksei','3','{1,4,5}'),
('Ivanov', 'Ivan', '3','{1,3,5}'),('Ivanov', 'Ivan', '4','{1,2,5}'),('Ivanov', 'Ivan', '4','{1,2,3}');
select * from students limit 100

create table mathematics(
	student_id int,
	grade int,
	grade_str VARCHAR(50),
	foreign key (student_id) references students(student_id)
	);



--найдем, какие студенты относятся к математике
select student_id  from students where courses_ids@>'{1}' limit 20;

insert INTO mathematics (student_id, grade) VALUES ('1','45'),('5','35'),('7','30'),('8','20'),('9','27'),('10','37');


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

select * from mathematics limit 100

	
