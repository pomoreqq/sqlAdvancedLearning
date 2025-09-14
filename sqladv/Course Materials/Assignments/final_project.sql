
use finalproject;
-- PART I: SCHOOL ANALYSIS
-- 1. View the schools and school details tables
select * from schools;
select * from school_details;
-- 2. In each decade, how many schools were there that produced players?
select count(distinct schoolID), floor(yearid/10)*10  as decade from schools
group by decade;

-- 3. What are the names of the top 5 schools that produced the most players?
select sd.name_full,count(distinct s.playerID) from school_details sd
left join schools s
on s.schoolID = sd.schoolID
group by sd.name_full
order by count(distinct s.playerID) DESC
limit 5;
-- 4. For each decade, what were the names of the top 3 schools that produced the most players?
with cte as (
select s.schoolID,sd.name_full,floor(yearid/10)*10 as decade,count(distinct s.playerID) as playerCount from schools s
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

select * from salaries;
-- 2. Return the top 20% of teams in terms of average annual spending
WITH ts AS (SELECT 	teamID, yearID, SUM(salary) AS total_spend
			FROM	salaries
			GROUP BY teamID, yearID
			ORDER BY teamID, yearID), -- ORDER BY in CTE is not needed and can be omitted
            
	 sp AS (SELECT	teamID, AVG(total_spend) AS avg_spend,
					NTILE(5) OVER (ORDER BY AVG(total_spend) DESC) AS spend_pct
			FROM	ts
			GROUP BY teamID)
            
SELECT	teamID, ROUND(avg_spend / 1000000, 1) AS avg_spend_millions
FROM	sp
WHERE	spend_pct = 1;

-- 3. For each team, show the cumulative sum of spending over the years
with cte as (
select teamID,yearID, sum(salary) as annualSum from salaries
group by teamID,yearID
order by teamID,yearID
)
select teamID,yearID,annualSum,
sum(annualSum) over(partition by teamID order by teamID,yearID) as cumSum
from cte;
-- 4. Return the first year that each team's cumulative spending surpassed 1 billion
with cte as (
select teamID,yearID, sum(salary) as annualSum from salaries
group by teamID,yearID
order by teamID,yearID
),
 cte2 as (
 select teamID,yearID,annualSum,
sum(annualSum) over(partition by teamID order by teamID,yearID) as cumSum
from cte
 ),
	cte3 as (
     select teamID,yearID,annualSum,cumSum,
 row_number() over(partition by teamID order by yearID) as rwNmbr from cte2 
 where cumSum > 1000000000 
    )
select * from cte3 where rwNmbr = 1;
 
-- PART III: PLAYER CAREER ANALYSIS
select * from players;
-- 1. View the players table and find the number of players in the table
select count(distinct playerID) from players;
-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years). Sort from longest career to shortest career.
select nameGiven, year(debut) - birthYear as firstGameAge, year(finalGame) - birthYear as finalGameAge, year(finalGame) - year(debut) as carrerLength from players
group by playerID
order by carrerLength DESC;
-- 3. What team did each player play on for their starting and ending years?
SELECT 	p.nameGiven,
		s.yearID AS starting_year, s.teamID AS starting_team,
        e.yearID AS ending_year, e.teamID AS ending_team
FROM	players p INNER JOIN salaries s
							ON p.playerID = s.playerID
							AND YEAR(p.debut) = s.yearID
				  INNER JOIN salaries e
							ON p.playerID = e.playerID
							AND YEAR(p.finalGame) = e.yearID
		order by nameGiven;

-- 4. How many players started and ended on the same team and also played for over a decade?
SELECT 	p.nameGiven,
		s.yearID AS starting_year, s.teamID AS starting_team,
        e.yearID AS ending_year, e.teamID AS ending_team
FROM	players p INNER JOIN salaries s
							ON p.playerID = s.playerID
							AND YEAR(p.debut) = s.yearID
				  INNER JOIN salaries e
							ON p.playerID = e.playerID
							AND YEAR(p.finalGame) = e.yearID
WHERE	s.teamID = e.teamID AND e.yearID - s.yearID > 10;

-- PART IV: PLAYER COMPARISON ANALYSIS
-- 1. View the players table
select * from players;
-- 2. Which players have the same birthday?
select a.nameGiven,CONCAT(a.birthYear, '-', a.birthMonth, '-', a.birthDay) as AbirthDate, b.nameGiven,CONCAT(b.birthYear, '-', b.birthMonth, '-', b.birthDay) as BbirthDate from players a
inner join players b
on CONCAT(a.birthYear, '-', a.birthMonth, '-', a.birthDay) = CONCAT(b.birthYear, '-', b.birthMonth, '-', b.birthDay) and a.nameGiven > b.nameGiven;

WITH bn AS (SELECT	CAST(CONCAT(birthYear, '-', birthMonth, '-', birthDay) AS DATE) AS birthdate,
					nameGiven
			FROM	players)
            
SELECT	birthdate, GROUP_CONCAT(nameGiven SEPARATOR ', ') AS players
FROM	bn
WHERE	YEAR(birthdate) BETWEEN 1980 AND 1990
GROUP BY birthdate
ORDER BY birthdate;
-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both
 select * from players;
 
 
 with cte as (select distinct s.teamID,s.playerID,p.bats
 from salaries s left join players p
 on p.playerID = s.playerID)
 select teamID,
 round(sum(case when bats = 'R' then 1 else 0 end) / count(playerID) * 100, 1) as rigthB,
  round(sum(case when bats = 'L' then 1 else 0 end) / count(playerID) * 100, 1) as leftB,
   round(sum(case when bats = 'B' then 1 else 0 end) / count(playerID) * 100, 1) as bothB
   from cte
   group by teamID;
-- 4. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?
WITH hw AS (SELECT	FLOOR(YEAR(debut) / 10) * 10 AS decade,
					AVG(height) AS avg_height, AVG(weight) AS avg_weight
			FROM	players
			GROUP BY decade)
            
SELECT	decade,
		avg_height - LAG(avg_height) OVER(ORDER BY decade) AS height_diff,
        avg_weight - LAG(avg_weight) OVER(ORDER BY decade) AS weight_diff
FROM	hw
WHERE	decade IS NOT NULL;
