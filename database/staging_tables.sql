USE nyc_restaurant_finder;

-- 1) Staging for DOHMH Restaurant Inspection Results 
DROP TABLE IF EXISTS staging_health_inspections;
DROP TABLE IF EXISTS stg_dohmh;

CREATE TABLE stg_dohmh (
  camis_id VARCHAR(50),
  dba VARCHAR(255),
  boro VARCHAR(50),
  building VARCHAR(50),
  street VARCHAR(255),
  zipcode VARCHAR(20),
  phone VARCHAR(20),
  cuisine_description VARCHAR(100),
  inspection_date DATETIME,
  score INT,
  grade VARCHAR(2),
  violation_description TEXT
);

SHOW PROCESSLIST;

SELECT COUNT(*) FROM stg_dohmh;

SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';

INSERT IGNORE INTO cuisines(name)
SELECT DISTINCT cuisine_description
FROM stg_dohmh
WHERE cuisine_description IS NOT NULL AND cuisine_description <> '';

INSERT IGNORE INTO restaurants(camis_id, name, phone)
SELECT DISTINCT camis_id, dba, phone
FROM stg_dohmh
WHERE camis_id IS NOT NULL AND camis_id <> '';

INSERT INTO locations (restaurant_id, boro, street_address, zip)
SELECT
  r.restaurant_id,
  s.boro,
  CONCAT(s.building, ' ', s.street),
  s.zipcode
FROM stg_dohmh s
JOIN restaurants r ON r.camis_id = s.camis_id
WHERE s.boro IS NOT NULL
GROUP BY r.restaurant_id, s.boro, s.building, s.street, s.zipcode;

INSERT IGNORE INTO restaurant_cuisines (restaurant_id, cuisine_id)
SELECT DISTINCT r.restaurant_id, c.cuisine_id
FROM stg_dohmh s
JOIN restaurants r ON r.camis_id = s.camis_id
JOIN cuisines c ON c.name = s.cuisine_description;

INSERT INTO health_inspections
  (restaurant_id, inspection_date, score, grade, violation_summary)
SELECT
  r.restaurant_id,
  s.inspection_date,
  s.score,
  s.grade,
  s.violation_description
FROM stg_dohmh s
JOIN restaurants r ON r.camis_id = s.camis_id;

SELECT COUNT(*) FROM restaurants;
SELECT COUNT(*) FROM locations;
SELECT COUNT(*) FROM cuisines;
SELECT COUNT(*) FROM health_inspections;


-- 2) Staging for Open Restaurants Inspections (4dx7-axux)

USE nyc_restaurant_finder;
DROP TABLE IF EXISTS staging_open_restaurants;
DROP TABLE IF EXISTS stg_openrest;

CREATE TABLE stg_openrest (
  borough              VARCHAR(50),
  restaurantname       VARCHAR(255),
  seatingchoice        VARCHAR(50),
  legalbusinessname    VARCHAR(255),
  businessaddress      VARCHAR(255),
  restaurantinspectionid VARCHAR(100),
  issidewaycompliant   VARCHAR(10),
  isroadwaycompliant   VARCHAR(255),
  skippedreason        VARCHAR(255),
  inspectedon          DATETIME,
  agencycode           VARCHAR(50),
  postcode             VARCHAR(20),
  latitude             DECIMAL(9,6),
  longitude            DECIMAL(9,6),
  communityboard       VARCHAR(50),
  councildistrict      VARCHAR(50),
  censustract          VARCHAR(50),
  bin                  VARCHAR(50),
  bbl                  VARCHAR(50),
  nta                  VARCHAR(50)
);


TRUNCATE TABLE stg_openrest;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/openrest_2000.csv'
INTO TABLE stg_openrest
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@borough,@restaurantname,@seatingchoice,@legalbusinessname,@businessaddress,
 @restaurantinspectionid,@issidewaycompliant,@isroadwaycompliant,@skippedreason,
 @inspectedon,@agencycode,@postcode,@latitude,@longitude,@communityboard,
 @councildistrict,@censustract,@bin,@bbl,@nta)
SET
  borough = @borough,
  restaurantname = @restaurantname,
  seatingchoice = @seatingchoice,
  legalbusinessname = @legalbusinessname,
  businessaddress = @businessaddress,
  restaurantinspectionid = @restaurantinspectionid,
  issidewaycompliant = @issidewaycompliant,
  isroadwaycompliant = @isroadwaycompliant,
  skippedreason = @skippedreason,
  inspectedon = NULLIF(@inspectedon,''),
  agencycode = @agencycode,
  postcode = @postcode,
  latitude = NULLIF(@latitude,''),
  longitude = NULLIF(@longitude,''),
  communityboard = @communityboard,
  councildistrict = @councildistrict,
  censustract = @censustract,
  bin = @bin,
  bbl = @bbl,
  nta = @nta;

SELECT COUNT(*) FROM stg_openrest;

INSERT INTO open_restaurants_inspections
  (restaurant_id, inspection_date, seating_choice,
   roadway_compliant, sidewalk_compliant, skipped_reason)
SELECT
  r.restaurant_id,
  s.inspectedon,
  s.seatingchoice,
  CASE WHEN LOWER(s.isroadwaycompliant) IN ('true','t','yes','y','1') THEN 1 ELSE 0 END,
  CASE WHEN LOWER(s.issidewaycompliant) IN ('true','t','yes','y','1') THEN 1 ELSE 0 END,
  s.skippedreason
FROM stg_openrest s
JOIN locations l ON l.boro = s.borough
JOIN restaurants r ON r.restaurant_id = l.restaurant_id
WHERE r.name = s.restaurantname;


SELECT COUNT(*) FROM open_restaurants_inspections;


-- 3) Staging for 311 Service Requests (erm2-nwe9)
USE nyc_restaurant_finder;

DROP TABLE IF EXISTS staging_311;

DROP TABLE IF EXISTS stg_311;

CREATE TABLE stg_311 (
  unique_key BIGINT,
  created_date DATETIME,
  closed_date DATETIME,
  agency VARCHAR(50),
  agency_name VARCHAR(255),
  complaint_type VARCHAR(255),
  descriptor VARCHAR(255),
  location_type VARCHAR(255),
  incident_zip VARCHAR(20),
  incident_address VARCHAR(255),
  street_name VARCHAR(255),
  cross_street_1 VARCHAR(255),
  cross_street_2 VARCHAR(255),
  intersection_street_1 VARCHAR(255),
  intersection_street_2 VARCHAR(255),
  address_type VARCHAR(50),
  city VARCHAR(100),
  landmark VARCHAR(255),
  facility_type VARCHAR(255),
  status VARCHAR(50),
  due_date DATETIME,
  resolution_description TEXT,
  resolution_action_updated_date DATETIME,
  community_board VARCHAR(50),
  bbl VARCHAR(50),
  borough VARCHAR(50),
  x_coordinate_state_plane VARCHAR(50),
  y_coordinate_state_plane VARCHAR(50),
  open_data_channel_type VARCHAR(50),
  park_facility_name VARCHAR(255),
  park_borough VARCHAR(50),
  vehicle_type VARCHAR(100),
  taxi_company_borough VARCHAR(100),
  taxi_pick_up_location VARCHAR(255),
  bridge_highway_name VARCHAR(255),
  bridge_highway_direction VARCHAR(50),
  road_ramp VARCHAR(50),
  bridge_highway_segment VARCHAR(255),
  latitude DECIMAL(9,6),
  longitude DECIMAL(9,6),
  location VARCHAR(255)
);

TRUNCATE TABLE stg_311;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sr311_5000.csv'
INTO TABLE stg_311
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@unique_key,@created_date,@closed_date,@agency,@agency_name,@complaint_type,@descriptor,@location_type,
 @incident_zip,@incident_address,@street_name,@cross_street_1,@cross_street_2,@intersection_street_1,
 @intersection_street_2,@address_type,@city,@landmark,@facility_type,@status,@due_date,@resolution_description,
 @resolution_action_updated_date,@community_board,@bbl,@borough,@x_coord,@y_coord,@open_data_channel_type,
 @park_facility_name,@park_borough,@vehicle_type,@taxi_company_borough,@taxi_pick_up_location,
 @bridge_highway_name,@bridge_highway_direction,@road_ramp,@bridge_highway_segment,@latitude,@longitude,@location)
SET
  unique_key = NULLIF(@unique_key,''),
  created_date = NULLIF(@created_date,''),
  closed_date = NULLIF(@closed_date,''),
  agency = @agency,
  agency_name = @agency_name,
  complaint_type = @complaint_type,
  descriptor = @descriptor,
  location_type = @location_type,
  incident_zip = @incident_zip,
  incident_address = @incident_address,
  street_name = @street_name,
  cross_street_1 = @cross_street_1,
  cross_street_2 = @cross_street_2,
  intersection_street_1 = @intersection_street_1,
  intersection_street_2 = @intersection_street_2,
  address_type = @address_type,
  city = @city,
  landmark = @landmark,
  facility_type = @facility_type,
  status = @status,
  due_date = NULLIF(@due_date,''),
  resolution_description = @resolution_description,
  resolution_action_updated_date = NULLIF(@resolution_action_updated_date,''),
  community_board = @community_board,
  bbl = @bbl,
  borough = @borough,
  x_coordinate_state_plane = @x_coord,
  y_coordinate_state_plane = @y_coord,
  open_data_channel_type = @open_data_channel_type,
  park_facility_name = @park_facility_name,
  park_borough = @park_borough,
  vehicle_type = @vehicle_type,
  taxi_company_borough = @taxi_company_borough,
  taxi_pick_up_location = @taxi_pick_up_location,
  bridge_highway_name = @bridge_highway_name,
  bridge_highway_direction = @bridge_highway_direction,
  road_ramp = @road_ramp,
  bridge_highway_segment = @bridge_highway_segment,
  latitude = NULLIF(@latitude,''),
  longitude = NULLIF(@longitude,''),
  location = @location;
  
  
INSERT INTO service_requests_311
  (restaurant_id, complaint_type, created_date, resolution_description)
SELECT
  NULL,
  complaint_type,
  created_date,
  resolution_description
FROM stg_311;
