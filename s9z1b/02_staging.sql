-- Active: 1790280629501@@127.0.0.1@5432@northwind_elt

\set ON_ERROR_STOP on
\encoding UTF8

BEGIN;

CREATE SCHEMA IF NOT EXISTS silver;

CREATE VIEW silver.stg_categories AS
    SELECT
        TRIM(categoryid)::INT AS    category_id,
        TRIM(categoryname) AS       category_name,
        TRIM(description) AS        description
    FROM bronze.categories;

CREATE VIEW silver.stg_customers AS
    SELECT
        TRIM(customerid)::INT AS    customer_id,
        TRIM(customername) AS       customer_name,
        TRIM(contactname) AS        contact_name,
        TRIM(address) AS            address,
        TRIM(city) AS               city,
        TRIM(postalcode) AS         postal_code,
        TRIM(country) AS            country
    FROM bronze.customers;

CREATE VIEW silver.stg_employees AS
    SELECT
        TRIM(employeeid)::INT AS    employee_id,
        TRIM(lastname) AS           last_name,
        TRIM(firstname) AS          first_name,
        TRIM(birthdate)::DATE AS    birth_date,
        TRIM(photo) AS              photo,
        TRIM(notes) AS              notes
    FROM bronze.employees;

CREATE VIEW silver.stg_order_details AS
    SELECT
        TRIM(orderdetailid)::INT AS order_detail_id,
        TRIM(orderid)::INT AS       order_id,
        TRIM(productid)::INT AS     product_id,
        TRIM(quantity)::INT AS      quantity
    FROM bronze.orderdetails;

CREATE VIEW silver.stg_orders AS
    SELECT
        TRIM(orderid)::INT AS       order_id,
        TRIM(customerid)::INT AS    cusotmer_id,
        TRIM(employeeid)::INT AS    employee_id,
        TRIM(orderdate)::DATE AS    order_date,
        TRIM(shipperid)::INT AS     shipper_id
    FROM bronze.orders;

CREATE VIEW silver.stg_products AS
    SELECT
        TRIM(productid)::INT AS         product_id,
        TRIM(productname) AS            product_name,
        TRIM(supplierid)::INT AS        supplier_id,
        TRIM(categoryid)::INT AS        category_id,
        TRIM(unit) AS                   unit,
        TRIM(price)::NUMERIC(8, 2) AS   price
    FROM bronze.products;

CREATE VIEW silver.stg_shippers AS
    SELECT
        TRIM(shipperid)::INT AS     shipper_id,
        TRIM(shippername) AS        shipper_name,
        TRIM(phone) AS              phone
    FROM bronze.shippers;

CREATE VIEW silver.stg_suppliers AS
    SELECT
        TRIM(supplierid)::INT AS    supplier_id,
        TRIM(suppliername) AS       supplier_name,
        TRIM(contactname) AS        contact_name,
        TRIM(address) AS            address,
        TRIM(city) AS               city,
        TRIM(postalcode) AS         postal_code,
        TRIM(country) AS            country,
        TRIM(phone) AS              phone
    FROM bronze.suppliers;


COMMIT;