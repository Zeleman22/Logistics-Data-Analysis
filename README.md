Logistics Data Analytics & Fleet Optimization Portfolio

Author: Zelalem Hailu Gedey

Profile: linkedin.com/in/zelalem-hailu-32b928398

Email: zelalemhailugedey@gmail.com

📌 Project Overview

This repository showcases analytical proof of work bridging 10+ years of active, hands-on fleet and supply chain operations with modern technical computing tools (Python, Pandas, SQL, PostgreSQL).

As an operations professional transitioned into a data professional, I specialize in identifying budget leaks, automating KPI calculations, isolating route outliers, and auditing multi-site compliance tracking sheets.

🛠️ Repository Contents

1. clean_logistics_data.py (Python Data Cleaning)

Problem Statement: Fleet tracking systems frequently import messy entries due to manual log errors, dead cellular transmission sectors (GPS), or sensor shorts.

Technical Approach:

Imports raw strings into Pandas DataFrames utilizing memory buffers.

Corrects structural typos, strips invalid negative numbers, and parses datetimes.

Leverages statistical median imputation to populate missing data elements logically without distorting dataset distributions.

Identifies physical odometer telematics anomalies using logical threshold masks, correcting corrupt inputs.

Computes standard performance metrics: Fuel Consumption (Liters per 100km).

How to Run:

python clean_logistics_data.py


2. logistics_analysis.sql (Relational Schema & Query Design)

Problem Statement: Operational managers must trace cost variances, rank regional asset efficiencies, and flag audit anomalies (such as fuel entries exceeding vehicle tank limits).

Technical Approach:

Defines relational primary-foreign database constraints (vehicles and fuel_logs).

Demonstrates aggregation pipelines with advanced multitable inner joins.

Employs nested Common Table Expressions (CTEs) and analytic window ranking functions (RANK() OVER(PARTITION BY...)) to evaluate asset groups independently.

Automates risk management compliance checking by flagging log entries with tank volume inconsistencies.

📈 Real-world Domain Insights Applied

Instead of querying generic sales or retail datasets, this portfolio applies technical analytical concepts directly to fleet parameters learned from managing 300+ commercial assets at Coca-Cola and 50+ humanitarian vehicles across Ethiopia (COOPI).

Sensor Failures: Replaces hard-coded outlier detection with flexible pandas masks to resolve standard GPS errors.

Cost Controls: Pinpoints precise metrics to assist regional managers in cutting asset downtime and eliminating fuel budget variances.
