-- Active: 1790280629501@@127.0.0.1@5432@northwind_elt

\set ON_ERROR_STOP on
\encoding UTF8

BEGIN;

CREATE SCHEMA IF NOT EXISTS gold;

-- Subdimensions --------------------------------------------------------------

-- dim_date ---------------------------

CREATE TABLE IF NOT EXISTS gold.sdim_day(
    day_id      INT PRIMARY KEY,
    day         INT NOT NULL,
    day_of_week VARCHAR(15) NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.sdim_month(
    month_id    INT PRIMARY KEY,
    month       INT NOT NULL,
    month_name  VARCHAR(15) NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.sdim_quartal(
    quartal_id      INT PRIMARY KEY,
    quartal         INT NOT NULL,
    quartal_label   VARCHAR(2) NOT NULL
);

-- dim_time ---------------------------

CREATE TABLE IF NOT EXISTS gold.sdim_hour(
    hour_id INT PRIMARY KEY,
    hour    INT NOT NULL,
    hour_12 INT NOT NULL,
    am_pm   VARCHAR(2)
);

CREATE TABLE IF NOT EXISTS gold.sdim_part_of_day(
    part_of_day_id  INT PRIMARY KEY,
    part_of_day     VARCHAR(15) NOT NULL
);

-- dim_customer -----------------------

CREATE TABLE IF NOT EXISTS gold.sdim_address(
    address_id  SERIAL PRIMARY KEY,
    address     VARCHAR(50) NOT NULL,
    postal_code VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.sdim_city(
    city_id SERIAL PRIMARY KEY,
    city    VARCHAR(20) NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.sdim_country(
    country_id  SERIAL PRIMARY KEY,
    country     VARCHAR(15) NOT NULL
);

-- dim_product ------------------------

CREATE TABLE IF NOT EXISTS gold.sdim_category(
    category_id     INT NOT NULL UNIQUE,
    category_name   VARCHAR(25) NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.sdim_supplier(
    supplier_id     INT NOT NULL UNIQUE,
    supplier_name   VARCHAR(50) NOT NULL,
    address         VARCHAR(50) NOT NULL,
    postal_code     VARCHAR(20) NOT NULL,
    city            VARCHAR(15) NOT NULL,
    country         VARCHAR(15) NOT NULL
);

-- Dimensions -----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS gold.dim_date(
    date_id     INT PRIMARY KEY,
    day_id      INT NOT NULL REFERENCES gold.sdim_day (day_id),
    week        INT NOT NULL,
    month_id    INT NOT NULL REFERENCES gold.sdim_month (month_id),
    quartal_id  INT NOT NULL REFERENCES gold.sdim_quartal (quartal_id),
    year        INT NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.dim_time(
    time_id         INT PRIMARY KEY,
    hour_id         INT NOT NULL REFERENCES gold.sdim_hour (hour_id),
    minute          INT NOT NULL,
    second          INT NOT NULL,
    part_of_day_id  INT NOT NULL REFERENCES gold.sdim_part_of_day (part_of_day_id)
);

CREATE TABLE IF NOT EXISTS gold.dim_customer(
    customer_id     INT NOT NULL UNIQUE,
    customer_name   VARCHAR(50) NOT NULL,
    address_id      INT NOT NULL REFERENCES gold.sdim_address (address_id),
    city_id         INT NOT NULL REFERENCES gold.sdim_city (city_id),
    country_id      INT NOT NULL REFERENCES gold.sdim_country (country_id)
);

CREATE TABLE IF NOT EXISTS gold.dim_product(
    product_id      INT NOT NULL UNIQUE,
    product_name    VARCHAR(50) NOT NULL,
    unit            VARCHAR(25),
    price           DECIMAL(8, 2),
    category_id     INT NOT NULL REFERENCES gold.sdim_category (category_id),
    supplier_id     INT NOT NULL REFERENCES gold.sdim_supplier (supplier_id)
);

CREATE TABLE IF NOT EXISTS gold.dim_employee(
    employee_id INT NOT NULL UNIQUE,
    first_name  VARCHAR(15) NOT NULL,
    last_name   VARCHAR(15) NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.dim_shipper(
    shipper_id      INT NOT NULL UNIQUE,
    shipper_name    VARCHAR(25) NOT NULL
);

-- Fact table -----------------------------------------------------------------

CREATE TABLE IF NOT EXISTS gold.fact_orders(
    order_id    INT NOT NULL UNIQUE,
    quantity    INT NOT NULL,
    date_id     INT NOT NULL REFERENCES gold.dim_date (date_id),
    time_id     INT NOT NULL REFERENCES gold.dim_time (time_id),
    customer_id INT NOT NULL REFERENCES gold.dim_customer (customer_id),
    employee_id INT NOT NULL REFERENCES gold.dim_employee (employee_id),
    shipper_id  INT NOT NULL REFERENCES gold.dim_shipper (shipper_id),
    product_id  INT NOT NULL REFERENCES gold.dim_product (product_id)
);

CREATE INDEX ON gold.dim_date (day_id);
CREATE INDEX ON gold.dim_date (month_id);
CREATE INDEX ON gold.dim_date (quartal_id);
CREATE INDEX ON gold.dim_time (hour_id);
CREATE INDEX ON gold.dim_time (part_of_day_id);
CREATE INDEX ON gold.dim_customer (address_id);
CREATE INDEX ON gold.dim_customer (city_id);
CREATE INDEX ON gold.dim_customer (country_id);
CREATE INDEX ON gold.dim_product (category_id);
CREATE INDEX ON gold.dim_product (supplier_id);
CREATE INDEX ON gold.fact_orders (date_id);
CREATE INDEX ON gold.fact_orders (time_id);
CREATE INDEX ON gold.fact_orders (customer_id);
CREATE INDEX ON gold.fact_orders (employee_id);
CREATE INDEX ON gold.fact_orders (shipper_id);
CREATE INDEX ON gold.fact_orders (product_id);

TRUNCATE 
    gold.sdim_day, gold.sdim_month, gold.sdim_quartal,
    gold.sdim_hour, gold.sdim_part_of_day,
    gold.sdim_address, gold.sdim_city, gold.sdim_country,
    gold.sdim_category, gold.sdim_supplier,
    gold.dim_date, gold.dim_time, gold.dim_customer, gold.dim_product,
    gold.dim_employee, gold.dim_shipper,
    gold.fact_orders RESTART IDENTITY;

-- Subdimensions --------------------------------------------------------------

-- dim_date ---------------------------

INSERT INTO gold.sdim_day
    SELECT
        d       AS day_id,
        d + 1   AS day,
        CASE
            WHEN d = 0  THEN 'Sunday'
            WHEN d = 1  THEN 'Monday'
            WHEN d = 2  THEN 'Tuesday'
            WHEN d = 3  THEN 'Wednesday'
            WHEN d = 4  THEN 'Thursday'
            WHEN d = 5  THEN 'Friday'
            WHEN d = 6  THEN 'Saturday'
        END     AS day_of_week
    FROM GENERATE_SERIES(0, 6) AS gs(d);

INSERT INTO gold.sdim_month
    SELECT
        m       AS month_id,
        m + 1   AS month,
        CASE
            WHEN m = 0  THEN 'January'
            WHEN m = 1  THEN 'February'
            WHEN m = 2  THEN 'March'
            WHEN m = 3  THEN 'April'
            WHEN m = 4  THEN 'May'
            WHEN m = 5  THEN 'June'
            WHEN m = 6  THEN 'July'
            WHEN m = 7  THEN 'August'
            WHEN m = 8  THEN 'September'
            WHEN m = 9  THEN 'October'
            WHEN m = 10 THEN 'November'
            WHEN m = 11 THEN 'December'
        END     AS month_name
    FROM GENERATE_SERIES(0, 11) AS gs(m);

INSERT INTO gold.sdim_quartal
    SELECT
        q       AS quartal_id,
        q + 1   AS quartal,
        CASE
            WHEN q = 0  THEN 'Q1'
            WHEN q = 1  THEN 'Q2'
            WHEN q = 2  THEN 'Q3'
            WHEN q = 3  THEN 'Q4'
        END     AS quartal_label
    FROM GENERATE_SERIES(0, 3) AS gs(q);

-- dim_time ---------------------------

INSERT INTO gold.sdim_hour
    SELECT
        h       AS hour_id,
        h       AS hour,
        h % 12  AS hour_12,
        CASE
            when H < 12 THEN    'AM'
            ELSE                'PM'
        END             AS am_pm
    FROM GENERATE_SERIES(0, 23) AS gs(h);

INSERT INTO gold.sdim_part_of_day
    SELECT
        p   AS part_of_day_id,
        CASE
            WHEN p = 0  THEN 'morning'
            WHEN p = 1  THEN 'afternoon'
            WHEN p = 2  THEN 'evening'
            WHEN p = 3  THEN 'night'
        END AS part_of_day
    FROM GENERATE_SERIES(0, 3) AS gs(p);

-- dim_customer -----------------------

INSERT INTO gold.sdim_address (address, postal_code)
    SELECT DISTINCT address, postal_code 
    FROM silver.stg_customers;

INSERT INTO gold.sdim_city (city)
    SELECT DISTINCT city
    FROM silver.stg_customers;

INSERT INTO gold.sdim_country (country)
    SELECT DISTINCT country
    FROM silver.stg_customers;

-- dim_product ------------------------

INSERT INTO gold.sdim_category
    SELECT
        category_id     AS category_id,
        category_name   AS category_name
    FROM silver.stg_categories;

INSERT INTO gold.sdim_supplier
    SELECT
        supplier_id     AS supplier_id,
        supplier_name   AS supplier_name,
        address         AS address,
        postal_code     AS postal_code,
        city            AS city,
        country         AS country
    FROM silver.stg_suppliers;

-- Dimensions -----------------------------------------------------------------

INSERT INTO gold.dim_date
    SELECT
        TO_CHAR(d, 'YYMMDD')::INT               AS date_id,
        EXTRACT(DOW FROM d)::INT                AS day_id,
        EXTRACT(WEEK FROM d)::INT               AS week,
        EXTRACT(MONTH FROM d)::INT - 1          AS month_id,
        (EXTRACT(MONTH FROM d)::INT / 4)::INT   AS quartal_id,
        EXTRACT(YEAR FROM d)::INT               AS year
    FROM GENERATE_SERIES(
        (SELECT MIN(order_date)::DATE FROM silver.stg_orders),
        (SELECT MAX(order_date)::DATE FROM silver.stg_orders),
        INTERVAL '1 day'
    ) AS gs(d);

INSERT INTO gold.dim_time
    SELECT
        TO_CHAR(MAKE_INTERVAL(secs => sec), 'HH24MISS')::INT    AS time_id,
        sec / 3600                                              AS hour_id,
        (sec / 60) % 60                                         AS minute,
        sec % 60                                                AS second,
        CASE
            WHEN sec / 3600 BETWEEN 5 AND 11    THEN 0
            WHEN sec / 3600 BETWEEN 12 AND 17   THEN 1
            WHEN sec / 3600 BETWEEN 8 AND 21    THEN 2
            ELSE                                3
        END                                                     AS part_of_day
    FROM GENERATE_SERIES(0, 86399) AS gs(sec);

INSERT INTO gold.dim_customer
    SELECT
        cu.customer_id      AS customer_id,
        cu.customer_name    AS customer_name,
        a.address_id        AS address_id,
        ci.city_id          AS city_id,
        co.country_id       AS country_id
    FROM silver.stg_customers cu
    LEFT JOIN gold.sdim_address a ON a.address = cu.address
    LEFT JOIN gold.sdim_city ci ON ci.city = cu.city
    LEFT JOIN gold.sdim_country co ON co.country = cu.country
    ORDER BY cu.customer_id;

INSERT INTO gold.dim_product
    SELECT
        p.product_id    AS product_id,
        p.product_name  AS product_name,
        p.unit          AS unit,
        p.price         AS price,
        p.category_id   AS category_id,
        p.supplier_id   AS supplier_id
    FROM silver.stg_products p
    ORDER BY p.product_id;

INSERT INTO gold.dim_employee
    SELECT
        e.employee_id   AS employee_id,
        e.first_name    AS first_name,
        e.last_name     AS last_name
    FROM silver.stg_employees e
    ORDER BY e.employee_id;

INSERT INTO gold.dim_shipper
    SELECT
        s.shipper_id    AS shipper_id,
        s.shipper_name  AS shipper_name
    FROM silver.stg_shippers s
    ORDER BY s.shipper_id;

-- Fact table -----------------------------------------------------------------

INSERT INTO gold.fact_orders
    SELECT
        o.order_id                              AS order_id,
        (
            SELECT od.quantity
            FROM silver.stg_order_details od
            WHERE od.order_id = o.order_id
            LIMIT 1
        )                                       AS quantity,
        TO_CHAR(o.order_date, 'YYMMDD')::INT    AS date_id,
        TO_CHAR(o.order_date, 'HH24MISS')::INT  AS time_id,
        o.cusotmer_id                           AS customer_id,
        o.employee_id                           AS employee_id,
        o.shipper_id                            AS shipper_id,
        (
            SELECT od.product_id
            FROM silver.stg_order_details od
            WHERE od.order_id = o.order_id
            LIMIT 1
        )                                       AS product_id
    FROM silver.stg_orders o
    ORDER BY o.order_id;

COMMIT;

--psql -h localhost -p 5432 -U postgres -d northwind_elt -f 03_transform.sql