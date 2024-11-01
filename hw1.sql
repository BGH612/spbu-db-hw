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



select * from courses 


create table groups(
	id SERIAL primary key,
	full_name VARCHAR(50),
	short_name VARCHAR(50),
	students_ids varchar
	);
	
insert INTO groups (full_name, short_name, students_ids) VALUES ('Ivanst', 'Iv', '1,2,3'),
('Golan', 'Gol', '4,5,6' ),('Efremov', 'Efr', '7,8'),('Balkanov', 'Bal', '9,10' )
;
select * from groups



create table students(
	student_id SERIAL primary key,
	first_name VARCHAR(50),
	last_name VARCHAR(50),
	group_id int,
	courses_ids varchar,
	foreign key (group_id) references groups(id)
	);


-- Напишем такой фильтр, который позволит понять в какой группе находится каждый студент
select id  from groups where students_ids like '%1,%' OR students_ids like '%,1';
select id  from groups where students_ids like '%2,%' OR students_ids like '%,2';
select id  from groups where students_ids like '%3,%' OR students_ids like '%,3';
select id  from groups where students_ids like '%4,%' OR students_ids like '%,4';
select id  from groups where students_ids like '%5,%' OR students_ids like '%,5';
select id  from groups where students_ids like '%6,%' OR students_ids like '%,6';
select id  from groups where students_ids like '%7,%' OR students_ids like '%,7';
select id  from groups where students_ids like '%8,%' OR students_ids like '%,8';
select id  from groups where students_ids like '%9,%' OR students_ids like '%,9';
select id  from groups where students_ids like '%10,%' OR students_ids like '%,10';



insert INTO students (first_name, last_name, group_id, courses_ids) VALUES ('Ivanov', 'Ivan', '1','1,2,3'),
('Golubev', 'Andrei', '1','2,3,4' ),('Efremov', 'Artem', '1','3,4,5'),('Balkanov', 'Anatoly','2', '2,4,5' ),
('Seleznev','georgy','2',  '1,2,3'),('Antonov', 'Mikhail', '2','2,3,4'),('Dmitriev','Aleksei','3','1,4,5'),
('Ivanov', 'Ivan', '3','1,3,5'),('Ivanov', 'Ivan', '4','1,2,5'),('Ivanov', 'Ivan', '4','1,2,3');
select * from students

create table mathematics(
	student_id int,
	grade int,
	grade_str VARCHAR(50),
	foreign key (student_id) references students(student_id)
	);



--найдем, какие студенты относятся к математике
select student_id  from students where courses_ids like '%1%';

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
			
end 

select * from mathematics 

	
