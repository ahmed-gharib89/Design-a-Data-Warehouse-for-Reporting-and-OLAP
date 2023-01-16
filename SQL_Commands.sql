/* 
 * 1. Create a new database YELP
 * 2. Create a new schema STAGING
 * 3. Create a new schema ODS
 * 4. Create a new schema DWH
 * 5. Create a new file format for csv
 * 6. Create a new snowflake manged stage with file format csv
 * 7. Create a new file format for json
 * 8. Create a new snowflake manged stage with file format json
 * 9. Create a new tables in STAGING schema for business, COVID, Check_in, Review, Tips and Customer
 * 10. Copy data from local to snowflake stage
 * 11. Copy data from snowflake stage to snowflake tables
 */

-- Creating a new database YELP
CREATE OR REPLACE DATABASE YELP;
USE DATABASE YELP;

-- Creating a new schema STAGING
CREATE OR REPLACE SCHEMA STAGING;

-- Creating a new schema ODS
CREATE OR REPLACE SCHEMA ODS;

-- Creating a new schema DWH
CREATE OR REPLACE SCHEMA DWH;

-- Creating a new file format for csv
CREATE OR REPLACE FILE FORMAT CSV_FILE_FORMAT 
TYPE = 'CSV'
FIELD_DELIMITER = ','
COMPRESSION = 'AUTO'
RECORD_DELIMITER = '\n'
SKIP_HEADER = 1
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE
NULL_IF = ('NULL', 'null')
EMPTY_FIELD_AS_NULL = TRUE;

-- Creating a new snowflake manged stage with file format csv
CREATE OR REPLACE STAGE CSV_STAGE file_format = CSV_FILE_FORMAT;

-- Creating a new file format for json
CREATE OR REPLACE FILE FORMAT JSON_FILE_FORMAT
TYPE = 'JSON'
COMPRESSION = 'AUTO'
STRIP_OUTER_ARRAY = TRUE;

-- Creating a new snowflake manged stage with file format json
CREATE OR REPLACE STAGE JSON_STAGE file_format = JSON_FILE_FORMAT;

-- Creating a new tables in STAGING schema for business, COVID, Check_in, Review, Tips and Customer
USE WAREHOUSE COMPUTE_WH;
USE DATABASE YELP;
USE SCHEMA STAGING;
CREATE OR REPLACE TABLE business (v VARIANT);
CREATE OR REPLACE TABLE covid (v VARIANT);
CREATE OR REPLACE TABLE check_in (v VARIANT);
CREATE OR REPLACE TABLE review (v VARIANT);
CREATE OR REPLACE TABLE tips (v VARIANT);
CREATE OR REPLACE TABLE customer (v VARIANT);

CREATE OR REPLACE TABLE precipitation (date DATE, precipitation STRING, precipitation_normal FLOAT);
CREATE OR REPLACE TABLE temperature (date DATE, min FLOAT, max FLOAT, normal_min FLOAT, normal_max FLOAT);

-- Copy data from local to snowflake stage
USE WAREHOUSE COMPUTE_WH;
USE DATABASE YELP;
USE SCHEMA STAGING;
PUT file://./data/yelp_academic_dataset_covid_features.json @JSON_STAGE auto_compress=true;
PUT file://./data/yelp_academic_dataset_business.json @JSON_STAGE auto_compress=true;
PUT file://./data/yelp_academic_dataset_checkin.json @JSON_STAGE auto_compress=true;
PUT file://./data/yelp_academic_dataset_review.json @JSON_STAGE auto_compress=true;
PUT file://./data/yelp_academic_dataset_tip.json @JSON_STAGE auto_compress=true;
PUT file://./data/yelp_academic_dataset_user.json @JSON_STAGE auto_compress=true;

PUT file://./data/usw00023169-las-vegas-mccarran-intl-ap-precipitation-inch.csv @CSV_STAGE auto_compress=true;
PUT file://./data/usw00023169-temperature-degreef.csv @CSV_STAGE auto_compress=true;

-- Copy data from snowflake stage to snowflake tables
USE WAREHOUSE COMPUTE_WH;
USE DATABASE YELP;
USE SCHEMA STAGING;
COPY INTO business FROM @JSON_STAGE/yelp_academic_dataset_business.json.gz;
COPY INTO covid FROM @JSON_STAGE/yelp_academic_dataset_covid_features.json.gz;
COPY INTO check_in FROM @JSON_STAGE/yelp_academic_dataset_checkin.json.gz;
COPY INTO review FROM @JSON_STAGE/yelp_academic_dataset_review.json.gz;
COPY INTO tips FROM @JSON_STAGE/yelp_academic_dataset_tip.json.gz;
COPY INTO customer FROM @JSON_STAGE/yelp_academic_dataset_user.json.gz;

COPY INTO precipitation FROM @CSV_STAGE/usw00023169-las-vegas-mccarran-intl-ap-precipitation-inch.csv.gz;
COPY INTO temperature FROM @CSV_STAGE/usw00023169-temperature-degreef.csv.gz;

