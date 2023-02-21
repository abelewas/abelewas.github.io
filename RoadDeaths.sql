use Random

select * from ['road-deaths-by-type$']
---calculate total road deaths in each country for stated years.
DROP VIEW if exists Total_road_deaths
CREATE VIEW Total_road_deaths AS
(
Select Entity, year, [Deaths - Other road injuries - Sex: Both - Age: All Ages (Number] AS Other,
[Deaths - Cyclist road injuries - Sex: Both - Age: All Ages (Numb] AS Cyclist,
[Deaths - Motorcyclist road injuries - Sex: Both - Age: All Ages ] AS Motocyclist,
[Deaths - Motor vehicle road injuries - Sex: Both - Age: All Ages] AS Motor_Vehicle,
[Deaths - Pedestrian road injuries - Sex: Both - Age: All Ages (N] AS Pedestrian,
Sum([Deaths - Cyclist road injuries - Sex: Both - Age: All Ages (Numb]+
[Deaths - Motorcyclist road injuries - Sex: Both - Age: All Ages ]+
[Deaths - Pedestrian road injuries - Sex: Both - Age: All Ages (N]+
[Deaths - Other road injuries - Sex: Both - Age: All Ages (Number]+
[Deaths - Motor vehicle road injuries - Sex: Both - Age: All Ages]) AS Total_Road_Deaths
from ['road-deaths-by-type$']
WHERE Code is not Null
---and Entity like '%Ghana%'
GROUP BY Entity, Year,[Deaths - Cyclist road injuries - Sex: Both - Age: All Ages (Numb],
[Deaths - Motor vehicle road injuries - Sex: Both - Age: All Ages],[Deaths - Motorcyclist road injuries - Sex: Both - Age: All Ages ],
[Deaths - Other road injuries - Sex: Both - Age: All Ages (Number],[Deaths - Pedestrian road injuries - Sex: Both - Age: All Ages (N]
)

---Use Partition by to calculate cummulative deaths of the various countries over the years
---and create a view Cummulative_PercentPed_Deaths

DROP VIEW IF EXISTS Cummulative_PercentPed_Deaths
CREATE VIEW Cummulative_PercentPed_Deaths AS
SELECT Total_road_deaths.Entity, Total_road_deaths.Year, Total_road_deaths.Total_Road_Deaths, 
(Total_road_deaths.Pedestrian/Total_road_deaths.Total_Road_Deaths * 100) as PercentPedDeaths, 
(Total_road_deaths.Motor_Vehicle/Total_road_deaths.Total_Road_Deaths * 100) as PercentMotorVehicleDeaths,
SUM(Total_road_deaths.Total_Road_Deaths) OVER (Partition by Total_road_deaths.Entity ORDER BY Total_road_deaths.Entity, Total_road_deaths.Year) 
AS RollingTotRdDeaths
FROM Total_road_deaths
WHERE Total_road_deaths.Total_Road_Deaths not like 0
---and Entity like '%Nigeria%'

---Calculate average deaths/yr, highest and lowest percent deaths

SELECT Entity, MAX(Total_road_deaths) AS HighestOneYrRdDeaths, MAX(RollingTotRdDeaths)
AS Total30yrDeaths, MAX(RollingTotRdDeaths / 30) AS AvgDeathsPerYr,
MAX(PercentPedDeaths) AS HighestPercentPedDeath,
MIN(PercentPedDeaths) AS LowestPercentPedDeaths
FROM Cummulative_PercentPed_Deaths
WHERE Entity like '%United States%'
GROUP BY Entity
Order by HighestOneYrRdDeaths DESC;

