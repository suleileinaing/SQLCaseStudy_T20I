--1. Identify matches played between two specific teams (e.g. India and South Africa) im 2024 and their result. 
SELECT *
FROM T20I
WHERE ((Team1 = 'India' and Team2 = 'South Africa' ) or (Team2 = 'India' and Team1 = 'South Africa' ))
AND YEAR(MatchDate) = 2024


--2. Find the team with the highest number of wins in 2024 and the total matches it won . 
SELECT TOP 1 Winner, COUNT(*) as Win_Count
FROM T20I 
WHERE YEAR(MatchDate) = 2024
GROUP BY Winner
ORDER BY Win_Count DESC


--3. Rank the teams based on total numbers of wins in 2024
SELECT Winner, COUNT(*) as Win_Count,
DENSE_RANK() OVER (ORDER BY COUNT(*) DESC)AS RANK
FROM T20I 
WHERE YEAR(MatchDate)= 2024 and Winner not in ('tied', 'no result')
GROUP BY Winner


--4. Which team had the highest average winner margin (in runs) and what was the average margin?
SELECT Top 1 Winner, AVG(CAST(SUBSTRING(Margin, 1, (CHARINDEX(' ', Margin)-1)) AS INT))AS Avg
FROM T20I
WHERE Margin like '%runs'
GROUP BY Winner
ORDER BY Avg DESC


--5. List all matches where the winning margin was greater than the average margin across all matches. 
WITH Avg_Margin AS 
    (SELECT AVG(CAST(SUBSTRING(Margin, 1, (CHARINDEX(' ', Margin)-1)) AS INT))AS Avg
    FROM T20I
    WHERE Margin like '%runs')

SELECT t.Team1, t.Team2, T.Winner, T.Margin
FROM T20I t
LEFT JOIN Avg_Margin A on 1=1
WHERE t.Margin like '%runs'
AND CAST(SUBSTRING(Margin, 1, (CHARINDEX(' ', Margin)-1)) AS INT) > A.Avg


--6. Find the team with the most wins when chasing a target (wins by wickets)

SELECT WINNER, Total_Win
FROM 
    (SELECT Winner, COUNT(*) AS Total_Win,
    RANK() OVER (ORDER BY COUNT(*) DESC) as Rank
    FROM T20I
    WHERE Margin like '%wickets'
    GROUP BY Winner) A
WHERE Rank= 1
 

--7. Head-to-head record between two selected teams (e.g., England vs Australia)

SELECT Winner, COUNT(*) as Matches_Won
FROM T20I
WHERE (Team1 = 'England' AND Team2= 'Australia') OR (Team2 = 'England' AND Team1= 'Australia')
GROUP BY Winner


--8. Identify the month in 2024 with the higheset number of T201 matches played. 
SELECT Top 1 DATENAME(MONTH,MatchDate) as Month, COUNT(*) as Matched_Played
FROM T20I
WHERE YEAR(MatchDate) = 2024
GROUP BY DATENAME(MONTH,MatchDate)
ORDER BY Matched_Played DESC



--9. For each team, find how many matches they played in 2024 and their win percentage. 
SELECT Team, Matches_played, ISNULL(Wins,0), CAST(ISNULL((Wins*100.0/Matches_played),0) AS decimal(5,2)) as Win_Rate
FROM 
(SELECT Team, COUNT(*) as 'Matches_played'
FROM 
    (SELECT Team1 as Team
    FROM T20I
    WHERE YEAR(MatchDate) = 2024
    UNION ALL
    SELECT Team2 as Team 
    FROM T20I
    WHERE YEAR(MatchDate) = 2024) t
GROUP BY Team) t LEFT JOIN
(SELECT Winner , COUNT(*) as Wins
FROM T20I
GROUP BY Winner
) w on t.Team = w.Winner
ORDER BY Win_Rate DESC


--10. Identify the most successful team at each ground (teams with most wins per ground)
SELECT g.Ground as Ground, Winner as Team_with_most_wins, Wins
FROM (SELECT Ground 
FROM T20I
GROUP BY GROUND) g LEFT JOIN 
(SELECT Winner, COUNT(*) as Wins , Ground, RANK() OVER (PARTITION BY Ground ORDER BY COUNT(*) DESC) as RANK
FROM T20I
WHERE Winner not in ('tied', 'no result')
GROUP BY Winner, Ground
) w on g.Ground = w.Ground
WHERE Rank = 1