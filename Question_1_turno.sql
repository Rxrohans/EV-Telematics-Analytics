Create database turno;
use turno;
CREATE TABLE test_data (
    vin Varchar(50),
    Yearr int,
    mmm int,
    ddd int,
    hr int,
    half_hour Varchar(10),
    avg_lat double,
    avg_long double,
    avg_bat_charge double
);
-- to allow null values
ALTER TABLE test_data 
MODIFY avg_lat DOUBLE NULL,
MODIFY avg_long DOUBLE NULL,
MODIFY avg_bat_charge DOUBLE NULL;
-- loaded csv file 
LOAD DATA INFILE 'D:/test_Datda.csv'
INTO TABLE test_data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
( vin, Yearr, mmm, ddd, hr, half_hour,
  @avg_lat, @avg_long, @avg_bat_charge
)
SET -- to allow null values 
  avg_lat = nullif(@avg_lat, ''),
  avg_long = NULLIF(@avg_long, ''),
  avg_bat_charge = NULLIF(@avg_bat_charge, '');

SELECT * FROM test_data WHERE avg_lat IS NULL;
-- can be deleted but will be used for next question
-- DELETE FROM test_data WHERE avg_lat IS NULL OR avg_long IS NULL OR avg_bat_charge IS NULL;

-- Question 1
-- table with location visit count (rounded to 4 decimals) during night hours
CREATE TABLE vehicle_night_locations AS
SELECT vin,
  ROUND(avg_lat, 4) AS lat,
  ROUND(avg_long, 4) AS lon,
  COUNT(*) AS cnt
FROM test_data
WHERE hr >= 22 OR hr <= 8 OR (hr>12 AND hr<14)
GROUP BY vin, lat, lon;

Select * from vehicle_night_locations; -- check 
Select distinct vin from vehicle_night_locations; -- check how many vehicles have consistent nighttime locations

--  table with max number of count per vehicle
CREATE TABLE max_count AS	
SELECT vin, MAX(cnt) AS max_cnt
FROM vehicle_night_locations
GROUP BY vin;
Select *  from max_count; -- check number of times each vehicle found at its likely residence location

-- Join to get most frequent location per vehicl -- use MIN() to ensure only one row per VIN
SELECT v.vin,
  MIN(v.lat) AS likely_home_lat,
  MIN(v.lon) AS likely_home_long,
  v.cnt AS records_at_location
FROM vehicle_night_locations v
JOIN max_count m ON v.vin = m.vin AND v.cnt = m.max_cnt
GROUP BY v.vin, v.cnt;


