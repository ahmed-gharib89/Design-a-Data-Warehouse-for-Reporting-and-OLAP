/*
 * 1. Replace values in precipitation colum in precipitation table T with NULL
 * 2. Create new tables in ODS schema
 * 3. Load data from staging to ODS
 * 4. Query to show the integration between the 8 tables
 */

-- transform staging to ODS
USE WAREHOUSE COMPUTE_WH;
USE DATABASE YELP;
USE SCHEMA STAGING;

-- Replace values in precipitation colum in precipitation table T with NULL
UPDATE precipitation SET precipitation = NULL WHERE precipitation = 'T';

-- Create new tables in ODS schema and insert data from staging to ODS
USE SCHEMA ODS;

-- temperature table
CREATE OR REPLACE TABLE temperature (date DATE, min FLOAT, max FLOAT, normal_min FLOAT, normal_max FLOAT);
INSERT INTO temperature 
(
    date, min, max, normal_min, normal_max
)
SELECT 
    TO_DATE(date, 'YYYYMMDD'), min, max, normal_min, normal_max
FROM STAGING.temperature;

-- precipitation table
CREATE OR REPLACE TABLE precipitation (date DATE, precipitation FLOAT, precipitation_normal FLOAT);

INSERT INTO precipitation 
(
    date, precipitation, precipitation_normal
)
SELECT 
    TO_DATE(date, 'YYYYMMDD'), CAST(precipitation AS FLOAT), precipitation_normal
FROM STAGING.precipitation;

-- business table
CREATE OR REPLACE TABLE business 
    (
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
        hours VARIANT
    );

INSERT INTO business 
(
    business_id, name, address, city, state, postal_code, latitude, longitude, stars, review_count, is_open, attributes, categories, hours
)
SELECT
    PARSE_JSON(v):business_id,
    PARSE_JSON(v):name,
    PARSE_JSON(v):address,
    PARSE_JSON(v):city, 
    PARSE_JSON(v):state, 
    PARSE_JSON(v):postal_code, 
    PARSE_JSON(v):latitude, 
    PARSE_JSON(v):longitude, 
    PARSE_JSON(v):stars, 
    PARSE_JSON(v):review_count, 
    PARSE_JSON(v):is_open, 
    PARSE_JSON(v):attributes, 
    PARSE_JSON(v):categories, 
    PARSE_JSON(v):hours
FROM STAGING.business;

-- covid table
CREATE OR REPLACE TABLE covid 
    (
        business_id VARCHAR(50),
        cal_to_action_enabled VARIANT,
        covid_banner VARIANT,
        grubhub_enabled VARIANT,
        request_a_quote_enabled VARIANT,
        temporary_closed_until VARIANT,
        virtual_services_offered VARIANT,
        delivery_or_takeout VARIANT,
        highlights VARIANT

    );

INSERT INTO covid 
(
    business_id, cal_to_action_enabled, covid_banner, grubhub_enabled, request_a_quote_enabled, temporary_closed_until, virtual_services_offered, delivery_or_takeout, highlights
)
SELECT
    PARSE_JSON(v):business_id,
    PARSE_JSON(v):"Call To Action enabled",
    PARSE_JSON(v):"Covid Banner",
    PARSE_JSON(v):"Grubhub enabled",
    PARSE_JSON(v):"Request a Quote Enabled",
    PARSE_JSON(v):"Temporary Closed Until",
    PARSE_JSON(v):"Virtual Services Offered",
    PARSE_JSON(v):"delivery or takeout",
    PARSE_JSON(v):"highlights"
FROM STAGING.covid;

-- check_in table
CREATE OR REPLACE TABLE check_in 
    (
        business_id VARCHAR(50),
        date VARCHAR
    );
    
INSERT INTO check_in 
(
    business_id, date
)
SELECT
    PARSE_JSON(v):business_id,
    PARSE_JSON(v):date
FROM STAGING.check_in;

-- review table
CREATE OR REPLACE TABLE review 
    (
        business_id VARCHAR(50),
        review_id VARCHAR(50),
        user_id VARCHAR(50),
        date DATE,
        stars FLOAT,
        cool INTEGER,
        funny INTEGER,
        useful INTEGER,
        text VARCHAR(10000)
    );

INSERT INTO review 
(
    business_id, review_id, user_id, date, stars, cool, funny, useful, text
)
SELECT
    PARSE_JSON(v):business_id,
    PARSE_JSON(v):review_id,
    PARSE_JSON(v):user_id,
    PARSE_JSON(v):date,
    PARSE_JSON(v):stars,
    PARSE_JSON(v):cool,
    PARSE_JSON(v):funny,
    PARSE_JSON(v):useful,
    PARSE_JSON(v):text
FROM STAGING.review;

-- tips table
CREATE OR REPLACE TABLE tips 
    (
        business_id VARCHAR(50),
        user_id VARCHAR(50),
        date DATE,
        compliment_count INTEGER,
        text VARCHAR
    );

INSERT INTO tips
(
    business_id, user_id, date, compliment_count, text
)
SELECT
    PARSE_JSON(v):business_id,
    PARSE_JSON(v):user_id,
    PARSE_JSON(v):date,
    PARSE_JSON(v):compliment_count,
    PARSE_JSON(v):text
FROM STAGING.tips;

-- customer table
CREATE OR REPLACE TABLE customer 
    (
        user_id VARCHAR(50),
        name VARCHAR(255),
        review_count INTEGER,
        yelping_since DATE,
        friends VARCHAR,
        useful INTEGER,
        funny INTEGER,
        cool INTEGER,
        fans INTEGER,
        elite VARCHAR,
        average_stars FLOAT,
        compliment_hot INTEGER,
        compliment_more INTEGER,
        compliment_profile INTEGER,
        compliment_cute INTEGER,
        compliment_list INTEGER,
        compliment_note INTEGER,
        compliment_plain INTEGER,
        compliment_cool INTEGER,
        compliment_funny INTEGER,
        compliment_writer INTEGER,
        compliment_photos INTEGER
    );

INSERT INTO customer
(
    user_id, name, review_count, yelping_since, friends, useful, funny, cool, fans, elite, average_stars, compliment_hot, compliment_more, compliment_profile, compliment_cute, compliment_list, compliment_note, compliment_plain, compliment_cool, compliment_funny, compliment_writer, compliment_photos
)
SELECT
    PARSE_JSON(v):user_id,
    PARSE_JSON(v):name,
    PARSE_JSON(v):review_count,
    PARSE_JSON(v):yelping_since,
    PARSE_JSON(v):friends,
    PARSE_JSON(v):useful,
    PARSE_JSON(v):funny,
    PARSE_JSON(v):cool,
    PARSE_JSON(v):fans,
    PARSE_JSON(v):elite,
    PARSE_JSON(v):average_stars,
    PARSE_JSON(v):compliment_hot,
    PARSE_JSON(v):compliment_more,
    PARSE_JSON(v):compliment_profile,
    PARSE_JSON(v):compliment_cute,
    PARSE_JSON(v):compliment_list,
    PARSE_JSON(v):compliment_note,
    PARSE_JSON(v):compliment_plain,
    PARSE_JSON(v):compliment_cool,
    PARSE_JSON(v):compliment_funny,
    PARSE_JSON(v):compliment_writer,
    PARSE_JSON(v):compliment_photos
FROM STAGING.customer;


-- SQL Quiry to show integration between the 8 tables
SELECT 
    b.name,
    c.covid_banner,
    c.temporary_closed_until,
    ci.date AS check_in_date,
    t.compliment_count,
    AVG(r.stars) AS avg_stars,
    AVG(te.min) AS avg_min_temp,
    AVG(te.max) AS avg_max_temp,
    AVG(p.precipitation) AS avg_precip,
    COUNT(r.review_id) AS review_count,
    COUNT(cu.user_id) AS customer_count
FROM review r
    JOIN temperature te ON r.date = te.date
    JOIN precipitation p ON r.date = p.date
    JOIN business b ON b.business_id = r.business_id
    JOIN covid c ON b.business_id = c.business_id
    JOIN check_in ci ON b.business_id = ci.business_id
    JOIN tips t ON b.business_id = t.business_id
    JOIN customer cu ON r.user_id = cu.user_id
GROUP BY b.name, c.covid_banner, c.temporary_closed_until, ci.date, t.compliment_count
LIMIT 10;
