import pandas as pd
import numpy as np
import io
import datetime

# ==============================================================================
# SCRIPT: clean_logistics_data.py
# AUTHOR: Zelalem Hailu Gedey (Zeleman22)
# PURPOSE: Simulates, cleans, and analyzes raw, messy fleet telematics data.
#          Demonstrates missing value imputation, type casting, outlier
#          detection, and KPI engineering (Fuel Efficiency L/100km).
# ==============================================================================

# 1. GENERATE MESSY MOCK DATA
# To ensure this script is runnable out-of-the-box by any hiring manager, 
# we programmatically generate a messy raw dataset simulating system failures 
# and human manual entry errors in fleet logs.
print("Step 1: Simulating messy raw logistics database logs...")

raw_data = """log_id,vehicle_id,date,fuel_liters,odometer_start,odometer_end,driver_notes
LOG-001,V-101,2026-05-01,45.2,12500,12950,Routine Refuel
LOG-002,V-102,2026-05-01,55.0,24100,24680,Refuel - Heavy Load
LOG-003,V-103,2026-05-02,missing,31400,31850,Missing fuel slip
LOG-004,V-101,2026-05-03,42.8,12950,13390,
LOG-005,V-102,2026-05-03,,24680,25240,System lag during entry
LOG-006,V-103,2026-05-04,50.1,31850,32310,Refuel
LOG-007,V-101,2026-05-05,48.5,13390,13420,Short regional trip
LOG-008,V-102,2026-05-05,58.2,25240,999999,Odometer sensor glitch (outlier)
LOG-009,V-104,2026-05-06,30.0,5000,5200,New active asset
LOG-010,V-103,2026-05-06,-15.0,32310,32780,Error - negative liters logged
"""

# Read the string database stream into a pandas DataFrame
df = pd.read_csv(io.StringIO(raw_data))
print("\n--- Raw Unclean Dataset ---")
print(df)

# 2. DATA CLEANING PIPELINE
print("\nStep 2: Executing data cleaning pipeline...")

# Convert fuel_liters to numeric, forcing strings like 'missing' to NaN (Not a Number)
df['fuel_liters'] = pd.to_numeric(df['fuel_liters'], errors='coerce')

# Convert dates to robust datetime format
df['date'] = pd.to_datetime(df['date'])

# Fix negative values (e.g. human typo adding a negative sign before 15.0)
df['fuel_liters'] = df['fuel_liters'].abs()

# Calculate the median fuel liters used to impute missing records logically
median_fuel = df['fuel_liters'].median()
df['fuel_liters'] = df['fuel_liters'].fillna(median_fuel)

# Standardize text columns (fillna with placeholder)
df['driver_notes'] = df['driver_notes'].fillna('No Notes')

# 3. DETECTING AND RESOLVING OUTLIERS (Odometer Glitch)
# At LOG-008, an odometer value of 999999 indicates a sensor short circuit.
# We calculate distance: odometer_end - odometer_start
# If the distance is physically impossible (> 2,000km for a single refuel dispatch),
# we replace odometer_end with a logical estimate based on that vehicle's average trip distance (approx 550km).
df['distance_km'] = df['odometer_end'] - df['odometer_start']

# Flag outliers where distance is negative or exceeding standard range (>2000 km)
outlier_mask = (df['distance_km'] <= 0) | (df['distance_km'] > 2000)
print(f"-> Flagged {outlier_mask.sum()} physical telematics outlier(s). Correcting...")

# Replace the outlier distance with the median distance of valid records
median_valid_distance = df.loc[~outlier_mask, 'distance_km'].median()
df.loc[outlier_mask, 'distance_km'] = median_valid_distance
df.loc[outlier_mask, 'odometer_end'] = df.loc[outlier_mask, 'odometer_start'] + median_valid_distance

# 4. FEATURE ENGINEERING (Calculate Fuel consumption rate: Liters per 100 Kilometers)
df['liters_per_100km'] = (df['fuel_liters'] / df['distance_km']) * 100
df['liters_per_100km'] = df['liters_per_100km'].round(2)

# 5. GENERATE CLEANED EXPORT
print("\nStep 3: Verification - Printing fully cleaned operational data logs...")
print(df[['log_id', 'vehicle_id', 'date', 'fuel_liters', 'distance_km', 'liters_per_100km', 'driver_notes']])

# Export clean file
output_filepath = "clean_logistics_report.csv"
df.to_csv(output_filepath, index=False)
print(f"\nPipeline execution successful. Exported clean file to: {output_filepath}")
