
Use turno;
-- Question 2
-- Create a real timestamp to order rows
CREATE TABLE test_data_with_ts AS SELECT *, STR_TO_DATE( CONCAT(
    yearr, '-', 
    LPAD(mmm, 2, '0'), '-', 
    LPAD(ddd, 2, '0'), ' ', 
    LPAD(hr, 2, '0'), ':', 
    IF(half_hour = 'h1', '00', '30'), ':00'
),
  '%Y-%m-%d %H:%i:%s'
) AS ts 
FROM test_data;

-- Create table that compares battery level to previous two rows -- Compary battery level for each vehicle
CREATE TABLE battery_with_previous AS
SELECT vin, ts, avg_lat, avg_long, avg_bat_charge,
       LAG(avg_bat_charge) OVER (PARTITION BY vin ORDER BY ts) AS prev_charge,
       LAG(avg_bat_charge, 2) OVER (PARTITION BY vin ORDER BY ts) AS prev_prev_charge
FROM test_data_with_ts;

select * from battery_with_previous;

-- Identify when charging starts
CREATE TABLE charging_start AS
SELECT vin, ts AS charging_time, avg_lat, avg_long
FROM battery_with_previous
WHERE prev_prev_charge IS NOT NULL AND prev_charge IS NOT NULL -- to ensure separate vehicles selected
  AND prev_charge < prev_prev_charge -- battery was decreasing
  AND avg_bat_charge >= prev_charge; -- now it's increasing
     
-- Store data for  First charging start for each Vehicle
CREATE TABLE charging_start_data AS
SELECT vin, MIN(charging_time) AS charging_start_time, Min(avg_lat) AS charging_lat, Min(avg_long) AS charging_long
FROM charging_start
GROUP BY vin;

SELECT * from Charging_start_data;

-- check if any vehicle is missing in the charging data table
SELECT vin FROM test_data
WHERE vin NOT IN (SELECT vin FROM charging_start_data)
GROUP BY vin;

-- check if misssing Vin has charging or discharging pattern 
SELECT vin, ts, avg_bat_charge
FROM test_data_with_ts
WHERE vin = 'MD9EMHDL22J217005' -- this is for 195 such vin (i checked for one)
ORDER BY ts;



