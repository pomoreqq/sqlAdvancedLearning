
use finalproject;
-- PART I: SCHOOL ANALYSIS
-- 1. View the schools and school details tables
select * from schools;
select * from school_details;
-- 2. In each decade, how many schools were there that produced players?
select count(distinct schoolID), floor(yearid/10)*10  as decade from schools
group by decade;

-- 3. What are the names of the top 5 schools that produced the most players?
select sd.name_full,count(*) from school_details sd
inner join schools s
on s.schoolID = sd.schoolID
group by sd.name_full
order by count(*) DESC
limit 5;
-- 4. For each decade, what were the names of the top 3 schools that produced the most players?
with cte as (
select s.schoolID,sd.name_full,floor(yearid/10)*10 as decade,count(*) as playerCount from schools s
inner join school_details sd
on sd.schoolID = s.schoolID
group by s.schoolID,floor(yearid/10)*10
order by floor(yearid/10)*10 DESC
),
cte2 as(
select decade,name_full,playerCount,
dense_rank() over(partition by decade order by playerCount DESC ) as dsnrnk
from cte
)
select * from cte2
where dsnrnk <= 3
order by decade DESC, playerCount DESC;
-- PART II: SALARY ANALYSIS
-- 1. View the salaries table
-- 2. Return the top 20% of teams in terms of average annual spending
-- 3. For each team, show the cumulative sum of spending over the years
-- 4. Return the first year that each team's cumulative spending surpassed 1 billion

-- PART III: PLAYER CAREER ANALYSIS
-- 1. View the players table and find the number of players in the table
-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years). Sort from longest career to shortest career.
-- 3. What team did each player play on for their starting and ending years?
-- 4. How many players started and ended on the same team and also played for over a decade?

-- PART IV: PLAYER COMPARISON ANALYSIS
-- 1. View the players table
-- 2. Which players have the same birthday?
-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both
-- 4. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?
