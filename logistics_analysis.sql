-- ==============================================================================
-- DATABASE COMPATIBILITY: PostgreSQL / MySQL
-- AUTHOR: Zelalem Hailu Gedey (Zeleman22)
-- PURPOSE: Simulates an active relational fleet database.
--          Executes aggregation, JOINs, CTEs, and a RANK() window function 
--          to pinpoint high-consumption anomalies.
-- ==============================================================================

-- 1. DATABASE SCHEMA SETUP
DROP TABLE IF EXISTS fuel_logs;
DROP TABLE IF EXISTS vehicles;

CREATE TABLE vehicles (
    vehicle_id VARCHAR(10) PRIMARY KEY,
    model VARCHAR(50),
    vehicle_type VARCHAR(30),
    fuel_capacity_liters INT
);

CREATE TABLE fuel_logs (
    log_id SERIAL PRIMARY KEY,
    vehicle_id VARCHAR(10) REFERENCES vehicles(vehicle_id),
    log_date DATE,
    liters_filled NUMERIC(6,2),
    cost_usd NUMERIC(6,2),
    distance_traveled_km NUMERIC(6,2)
);

-- 2. POPULATE STRUCTURAL MOCK DATA
INSERT INTO vehicles VALUES
('V-101', 'Toyota Hilux 4WD', 'Light Transport', 80),
('V-102', 'Isuzu FSR Truck', 'Medium Cargo', 150),
('V-103', 'Toyota Land Cruiser', 'Light Transport', 90),
('V-104', 'Scania Heavy Hauler', 'Heavy Transport', 350);

INSERT INTO fuel_logs (vehicle_id, log_date, liters_filled, cost_usd, distance_traveled_km) VALUES
('V-101', '2026-05-01', 45.00, 67.50, 450.0),
('V-102', '2026-05-01', 120.00, 180.00, 600.0),
('V-103', '2026-05-02', 50.00, 75.00, 410.0),
('V-101', '2026-05-04', 48.00, 72.00, 470.0),
('V-102', '2026-05-05', 135.00, 202.50, 620.0),
-- LOG ERROR IN V-103 (Abnormal high consumption/potential fuel theft)
('V-103', '2026-05-06', 110.00, 165.00, 120.0), 
('V-104', '2026-05-06', 310.00, 465.00, 950.0);

-- 3. ANALYTICAL QUERIES

-- QUERY A: Basic Aggregation & Multi-Table Join
-- Goal: Fetch lifetime operational running cost and average cost per kilometer.
SELECT 
    v.vehicle_id,
    v.model,
    v.vehicle_type,
    SUM(f.liters_filled) AS total_liters,
    SUM(f.cost_usd) AS total_fuel_cost_usd,
    SUM(f.distance_traveled_km) AS total_distance_km,
    ROUND((SUM(f.cost_usd) / SUM(f.distance_traveled_km))::numeric, 2) AS cost_per_km_usd
FROM vehicles v
JOIN fuel_logs f ON v.vehicle_id = f.vehicle_id
GROUP BY v.vehicle_id, v.model, v.vehicle_type
ORDER BY total_fuel_cost_usd DESC;

-- QUERY B: RANK() Window Function
-- Goal: Calculate fuel efficiency (L/100km) per refuel and rank the efficiency 
--       records partition-ranked by vehicle type. Lower liters/100km is more efficient.
WITH RefuelEfficiency AS (
    SELECT 
        v.vehicle_type,
        v.vehicle_id,
        f.log_date,
        f.liters_filled,
        f.distance_traveled_km,
        ROUND(((f.liters_filled / f.distance_traveled_km) * 100)::numeric, 2) AS consumption_rate_l_100km
    FROM vehicles v
    JOIN fuel_logs f ON v.vehicle_id = f.vehicle_id
)
SELECT 
    vehicle_type,
    vehicle_id,
    log_date,
    consumption_rate_l_100km,
    RANK() OVER(PARTITION BY vehicle_type ORDER BY consumption_rate_l_100km ASC) AS efficiency_rank_in_category
FROM RefuelEfficiency;

-- QUERY C: Isolation of Compliance Anomalies (Fuel Logs Exceeding Tank Capacity)
-- Goal: In multi-site logistics, tracking system audits must immediately flags 
--       any entry where liters filled exceed the theoretical fuel capacity of the physical tank.
SELECT 
    f.log_id,
    f.vehicle_id,
    v.model,
    f.log_date,
    f.liters_filled,
    v.fuel_capacity_liters AS actual_tank_limit,
    (f.liters_filled - v.fuel_capacity_liters) AS surplus_liters_anomaly
FROM fuel_logs f
JOIN vehicles v ON f.vehicle_id = v.vehicle_id
WHERE f.liters_filled > v.fuel_capacity_liters;
