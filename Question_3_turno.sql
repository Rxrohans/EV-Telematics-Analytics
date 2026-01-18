-- Create timestamp column and select daytime data
-- from question 2
Select * from test_data_with_ts WHERE hr BETWEEN 8 AND 22; -- only daytime rows
-- Add previous latitude and longitude to calculate distance
CREATE TEMPORARY TABLE data_with_prev_points AS
SELECT vin, yearr, mmm, ddd, ts, avg_lat, avg_long,
-- getting previous lat/lon for the same driver on the same day for comparision
LAG(avg_lat) OVER (PARTITION BY vin, yearr, mmm, ddd ORDER BY ts) AS prev_lat,
LAG(avg_long) OVER (PARTITION BY vin, yearr, mmm, ddd ORDER BY ts) AS prev_long
FROM test_data_with_ts
WHERE hr BETWEEN 8 AND 22;


Select * from data_with_prev_points limit 3000; -- check if the query works

--  Calculate the distance between current and previous point
CREATE TEMPORARY TABLE driver_distance AS
SELECT vin, yearr, mmm, ddd,
111 * SQRT(POW(avg_lat - prev_lat, 2) + POW(avg_long - prev_long, 2)) AS distance_km -- basic distance calculation using lat/lon difference (approx)
FROM data_with_prev_points
WHERE prev_lat IS NOT NULL AND prev_long IS NOT NULL;

select *from driver_distance limit 3000;

-- Sum the distance travelled per driver per day
CREATE TEMPORARY TABLE daily_driver_distance AS
SELECT vin, yearr, mmm, ddd, SUM(distance_km) AS total_km_in_day
FROM driver_distance
GROUP BY vin, yearr, mmm, ddd;
select  * from daily_driver_distance order by total_km_in_day;

-- Get average distance per day per driver
-- and find those who travel very little (less than 20 km/day)
SELECT vin, AVG(total_km_in_day) AS avg_daily_km
FROM daily_driver_distance
GROUP BY vin  
HAVING avg_daily_km <20;

