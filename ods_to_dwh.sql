/*
 * 1. CREATE tables for business, customer, weather, rweview
 * 2. LOAD data into tables
 * 3. SQL Generated report to show business name, temperature, precipitation, and ratings.
 */

USE WAREHOUSE COMPUTE_WH;
USE DATABASE YELP;
USE SCHEMA DWH;

 -- Create tables
 -- Business
 CREATE OR REPLACE TABLE business (
    business_id VARCHAR(50),
    name VARCHAR(255),
    address VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(3),
    postal_code VARCHAR(10),
    latitude FLOAT,
    longitude FLOAT,
    stars FLOAT,
    review_count INTEGER,
    is_open INTEGER,
    attributes VARIANT,
    categories VARIANT,
    hours VARIANT,
    cal_to_action_enabled VARIANT,
    covid_banner VARIANT,
    grubhub_enabled VARIANT,
    request_a_quote_enabled VARIANT,
    temporary_closed_until VARIANT,
    virtual_services_offered VARIANT,
    delivery_or_takeout VARIANT,
    highlights VARIANT,
    chick_in_date VARCHAR
 );

INSERT INTO business
SELECT
    b.business_id,
    name,
    address,
    city,
    state,
    postal_code,
    latitude,
    longitude,
    stars,
    review_count,
    is_open,
    attributes,
    categories,
    hours,
    cal_to_action_enabled,
    covid_banner,
    grubhub_enabled,
    request_a_quote_enabled,
    temporary_closed_until,
    virtual_services_offered,
    delivery_or_takeout,
    highlights,
    date AS chick_in_date
FROM 
    ODS.business b
    LEFT JOIN ODS.check_in ci ON b.business_id = ci.business_id
    LEFT JOIN ODS.covid c ON b.business_id = c.business_id;


-- Customer
CREATE OR REPLACE TABLE customer clone ODS.customer;

-- Weather
CREATE TABLE weather (
    date DATE,
    temp_min FLOAT,
    temp_max FLOAT, 
    temp_normal_min FLOAT, 
    temp_normal_max FLOAT,
    precipitation FLOAT, 
    precipitation_normal FLOAT
);

INSERT INTO weather
SELECT
    t.date,
    min,
    max,
    normal_min,
    normal_max,
    precipitation,
    precipitation_normal
FROM
    ODS.temperature t
    LEFT JOIN ODS.precipitation p ON t.date = p.date;


-- Review
CREATE OR REPLACE TABLE review CLONE ODS.review;


-- Generate report
SELECT
    b.name,
    w.temp_min,
    w.temp_max,
    w.precipitation,
    r.stars
FROM
    business b
    JOIN review r ON b.business_id = r.business_id
    JOIN weather w ON r.date = w.date;