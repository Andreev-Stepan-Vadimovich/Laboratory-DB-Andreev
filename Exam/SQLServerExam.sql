use [2025_PMI_33];

--Задание 1.1 Создание и заполнение отношений
create table Departments (
	dept_id numeric primary key identity(1, 1),
	dept_name varchar(100) not null,
	ept_count numeric not null default 0
);

insert into Departments (dept_name, ept_count)
values('name1', 0), ('name2', 0), ('name3', 0)

select * from Departments;

--Задание 1.2
create table Employees (
	table_id numeric(6, 0) primary key identity(1, 1),
	fio varchar(20) not null,
	gender varchar(1) check (gender in ('M', 'F')) default 'M' not null,
	birth_day date,
	education varchar(20) check (education in ('высшее', 'среднее', 'начальное')),
	dept_id numeric not null,
	stat varchar(20) not null,
	in_date date not null,
	out_date date,

	constraint fk_emp_dept
		foreign key (dept_id)
		references Departments(dept_id),
);

insert into Employees (fio, gender, birth_day, education, dept_id, stat, in_date, out_date)
values ('Иванов Иван', 'M', '2000-01-01', 'высшее', 1, 'начальник', '2020-01-01', '2025-01-01'),
		('Сергеев Сергей', 'M', '2001-01-01', 'высшее', 1, 'начальник', '2020-01-01', '2025-01-01'),
		('Любая Маша', 'F', '2001-01-01', 'высшее', 1, 'начальник', '2020-01-01', null);

select * from Employees;

--Задание 1.3
create table Children (
	child_id numeric primary key identity(1, 1),
	table_id numeric(6, 0) not null,
	child_name varchar(50) not null,
	birth_day date not null,

	constraint fk_child_emp
		foreign key (table_id)
		references Employees(table_id)
		on delete cascade
);

insert into Children (table_id, child_name, birth_day)
values (5, 'Даша', '2021-01-01'),
		(4, 'Паша', '2021-01-01');

select * from Children;

-- Задание 2. Представление
go
create view Education_level as
	select education as 'Уровень образования',
		count(case when gender = 'M' then 1 end) as 'Количество мужчин',
		count(case when gender = 'F' then 1 end) as 'Количество женщин',
		count(*) as 'Всего сотрудников'
	from Employees
	group by education
;
go

select * from Education_level;

-- Задание 3. Хранимая процедура
go
create procedure GetDepartmentsMaxTerminations
    @TargetYear int
as
begin
    select dept_name, cnt as termination_count
    from (
        select d.dept_name, count(e.table_id) as cnt
        from Departments d

        inner join Employees e on d.dept_id = e.dept_id

        where e.out_date is not null and year(e.out_date) = @TargetYear

        group by d.dept_id, d.dept_name
    ) as Stats
    where 
        cnt = (
            select max(cnt) 
            from (
                select count(e.table_id) as cnt
                from Departments d
                
				inner join Employees e on d.dept_id = e.dept_id
                where e.out_date is not null and year(e.out_date) = @TargetYear

                group by d.dept_id
            ) as MaxStats
        );
end;
go

exec GetDepartmentsMaxTerminations @TargetYear = 2025;

select * from Employees;

insert into Employees (fio, gender, birth_day, education, dept_id, stat, in_date, out_date)
values ('Любая Даша', 'F', '2001-01-01', 'высшее', 2, 'начальник', '2020-01-01', '2025-01-01'),
		('Любая Саша', 'F', '2001-01-01', 'высшее', 2, 'начальник', '2020-01-01', '2025-01-01'),
		('Любая Катя', 'F', '2001-01-01', 'высшее', 2, 'начальник', '2020-01-01', '2025-01-01');


-- Задание 4. Триггер 
go
create trigger trg_UpdateDepartmentEmployeeCount
on Employees
after insert, update, delete
as
begin
    declare @AffectedDepts table (dept_id int);

    insert into @AffectedDepts (dept_id)
    select dept_id from deleted where dept_id is not null
    union
    select dept_id from inserted where dept_id is not null;

    update d
    set ept_count = (
        select count(*) 
        from Employees e 
        where e.dept_id = d.dept_id
    )
    from Departments d
    where d.dept_id in (select dept_id from @AffectedDepts);
end;
go

insert into Employees (fio, gender, birth_day, education, dept_id, stat, in_date, out_date)
values ('Иванов Петр', 'M', '2000-01-01', 'высшее', 1, 'начальник', '2020-01-01', '2025-01-01'),
		('Иванов Сергей', 'M', '2001-01-01', 'высшее', 2, 'начальник', '2020-01-01', '2025-01-01');

update Employees
set dept_id = 3 where table_id = 3;


-- Задание 5. Права
create role Exem;
grant execute on GetDepartmentsMaxTerminations to Exem;
grant select on Education_level to Exem;
grant update, delete, insert on Children to Exem;
revoke update, delete, insert on Employees to Exem;
revoke update, delete, insert on Departments to Exem;

create login test with password = 'test';
create user test for login test;
alter role Exem add member test;