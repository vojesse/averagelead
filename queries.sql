#Get total WMOV/MOV
SELECT a.Home, .5*(homeWMOV-awayWMOV) as avgWMOV, .5*(homeMOV-awayMOV) as avgMOV
FROM 
	(SELECT Home, AVG(WMOV) as homeWMOV, AVG(MOV) as homeMOV from WMOV GROUP BY Home) as a 
INNER JOIN 
	(SELECT Away, AVG(WMOV) as awayWMOV, AVG(MOV) as awayMOV from WMOV GROUP BY Away) as b 
ON a.Home = b.Away 
ORDER BY avgWMOV desc;