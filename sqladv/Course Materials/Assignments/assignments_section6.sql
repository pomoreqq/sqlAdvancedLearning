-- Connect to database
use maven_advanced_sql;

-- ASSIGNMENT 1: Duplicate values

-- View the students data
select * from students;

-- Create a column that counts the number of times a student appears in the table
select student_name,count(*) as duplicateCount from students
group by student_name;

-- Return student ids, names and emails, excluding duplicates students
select id,student_name,email, row_number() over(partition by student_name order by id DESC) as rnk from students;


select id,student_name,email from (
select id,student_name,email, row_number() over(partition by student_name order by id DESC) as rnk from students
) as t
where rnk = 1;

-- ASSIGNMENT 2: Min / max value filtering

-- View the students and student grades tables
select*from students;
select * from student_grades;
-- For each student, return the classes they took and their final grades
select s.student_name,sg.class_name,sg.final_grade, row_number() over(partition by student_name order by final_grade DESC) as rnk from students s
inner join student_grades sg
on s.id = sg.student_id;
        
-- Return each student's top grade and corresponding class
with cte as (
select s.student_name,sg.class_name,sg.final_grade, rank() over(partition by s.student_name order by sg.final_grade DESC) as rnk from students s
inner join student_grades sg
on s.id = sg.student_id
)
select * from cte 
where rnk = 1;
                    
-- ASSIGNMENT 3: Pivoting

-- Combine the students and student grades tables
	select * from students;
	select * from student_grades;
    select * from students s
    inner join student_grades g
    on s.id = g.student_id;
-- View only the columns of interest
select department,grade_level,final_grade from students s
inner join student_grades g
on s.id = g.student_id;
        
-- Pivot the grade_level column
select g.department,
		case when s.grade_level = 9 then 1 else 0 end as freshman,
        case when s.grade_level = 10 then 1 else 0 end as sophomore,
        case when s.grade_level = 11 then 1 else 0 end as junior,
        case when s.grade_level = 12 then 1 else 0 end as senior
 from students s
left join student_grades g
on s.id = g.student_id;
        
-- Update the values to be final grades
select g.department,
		case when s.grade_level = 9 then g.final_grade else 0 end as freshman,
        case when s.grade_level = 10 then g.final_grade else 0 end as sophomore,
        case when s.grade_level = 11 then g.final_grade else 0 end as junior,
        case when s.grade_level = 12 then g.final_grade else 0 end as senior
 from students s
left join student_grades g
on s.id = g.student_id;

-- Create the final summary table
select g.department,
		round(avg(case when s.grade_level = 9 then g.final_grade else null end)) as freshman,
        round(avg(case when s.grade_level = 10 then g.final_grade else null end )) as sophomore,
        round(avg(case when s.grade_level = 11 then g.final_grade else null end)) as junior,
        round(avg(case when s.grade_level = 12 then g.final_grade else null end)) as senior
 from students s
left join student_grades g
on s.id = g.student_id
where g.department is not NULL
group by g.department;

-- ASSIGNMENT 4: Rolling calculations

-- Calculate the total sales each month
select year(o.order_date) as yr, month(o.order_date) as mnth, sum(p.unit_price * o.units) as totalSum
 from orders o
inner join products p
on p.product_id = o.product_id
group by yr,mnth
order by yr,mnth;

-- Add on the cumulative sum and 6 month moving average
with cte as (
select year(o.order_date) as yr, month(o.order_date) as mnth, sum(p.unit_price * o.units) as totalSum
 from orders o
inner join products p
on p.product_id = o.product_id
group by yr,mnth
order by yr,mnth
)
select yr,mnth,totalSum,
sum(totalSum) over(order by yr,mnth) as cumSum,
avg(totalSum) over(order by yr,mnth rows between 5 preceding and current row) as movingAvg
 from cte;

