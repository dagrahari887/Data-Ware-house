/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema.
    Run this script to re-define the DDL structure of Bronze tables.
===============================================================================
*/

-- =====================================================
-- Create CRM Tables
-- =====================================================

CREATE TABLE bronze.crm_cust_info(
    cst_id INT,
    cst_key VARCHAR(50),
    cst_firstname VARCHAR(50),
    cst_lastname VARCHAR(50),
    cst_material_status VARCHAR(50),
    cst_gndr VARCHAR(50),
    cst_create_date DATE
);

CREATE TABLE bronze.crm_prd_info(
    prd_id INT,
    prd_key VARCHAR(50),
    prd_nm VARCHAR(50),
    prd_cost INT,
    prd_line VARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

CREATE TABLE bronze.crm_sales_details(
    sls_ord_num VARCHAR(50),
    sls_prd_key VARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

-- =====================================================
-- Create ERP Tables
-- =====================================================

CREATE TABLE bronze.erp_loc_a101(
    cid VARCHAR(50),
    cntry VARCHAR(50)
);

CREATE TABLE bronze.erp_cust_az12(
    cid VARCHAR(50),
    bdate DATE,
    gen VARCHAR(50)
);

CREATE TABLE bronze.erp_px_cat_g1v2(
    id VARCHAR(50),
    cat VARCHAR(50),
    subcat VARCHAR(50),
    maintenance VARCHAR(50)
);


DELIMITER //

DROP PROCEDURE IF EXISTS load_bronze//

CREATE PROCEDURE load_bronze()
BEGIN

    -- =====================================================
    -- Variable Declarations
    -- =====================================================

    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE batch_start_time DATETIME;
    DECLARE batch_end_time DATETIME;

    DECLARE err_msg TEXT;
    DECLARE err_no INT;
    DECLARE err_state CHAR(5);

    -- =====================================================
    -- Error Handler
    -- =====================================================

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            err_msg = MESSAGE_TEXT,
            err_no = MYSQL_ERRNO,
            err_state = RETURNED_SQLSTATE;

        SELECT '==========================================';
        SELECT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        SELECT CONCAT('Error Message : ', err_msg);
        SELECT CONCAT('Error Number  : ', err_no);
        SELECT CONCAT('Error State   : ', err_state);
        SELECT '==========================================';
    END;

    -- =====================================================
    -- Start Batch Load
    -- =====================================================

    SET batch_start_time = NOW();

    SELECT '================================================';
    SELECT 'Loading Bronze Layer';
    SELECT '================================================';

    -- =====================================================
    -- Load CRM Tables
    -- =====================================================

    SELECT '------------------------------------------------';
    SELECT 'Loading CRM Tables';
    SELECT '------------------------------------------------';

    -- =====================================================
    -- Load CRM Customer Information
    -- =====================================================

    SET start_time = NOW();

    SELECT '>> Truncating Table: bronze.crm_cust_info';

    TRUNCATE TABLE bronze.crm_cust_info;

    SELECT '>> Inserting Data Into: bronze.crm_cust_info';

    LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
    IGNORE
    INTO TABLE bronze.crm_cust_info
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES;

    SET end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    );

    SELECT '>> -------------';

    -- =====================================================
    -- Load CRM Product Information
    -- =====================================================

    SET start_time = NOW();

    SELECT '>> Truncating Table: bronze.crm_prd_info';

    TRUNCATE TABLE bronze.crm_prd_info;

    SELECT '>> Inserting Data Into: bronze.crm_prd_info';

    LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
    INTO TABLE bronze.crm_prd_info
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES
    (
        prd_id,
        prd_key,
        prd_nm,
        @prd_cost,
        prd_line,
        @prd_start_dt,
        @prd_end_dt
    )
    SET
        prd_cost = NULLIF(@prd_cost, ''),
        prd_start_dt = NULLIF(@prd_start_dt, ''),
        prd_end_dt = NULLIF(@prd_end_dt, '');

    SET end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    );

    SELECT '>> -------------';

    -- =====================================================
    -- Load CRM Sales Details
    -- =====================================================

    SET start_time = NOW();

    SELECT '>> Truncating Table: bronze.crm_sales_details';

    TRUNCATE TABLE bronze.crm_sales_details;

    SELECT '>> Inserting Data Into: bronze.crm_sales_details';

    LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
    INTO TABLE bronze.crm_sales_details
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES
    (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        @sls_sales,
        sls_quantity,
        @sls_price
    )
    SET
        sls_sales = NULLIF(@sls_sales, ''),
        sls_price = NULLIF(@sls_price, '');

    SET end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    );

    SELECT '>> -------------';

    -- =====================================================
    -- Load ERP Tables
    -- =====================================================

    SELECT '------------------------------------------------';
    SELECT 'Loading ERP Tables';
    SELECT '------------------------------------------------';
    -- =====================================================
    -- Load ERP Customer
    -- =====================================================

    SET start_time = NOW();

    SELECT '>> Truncating Table: bronze.erp_cust_az12';

    TRUNCATE TABLE bronze.erp_cust_az12;

    SELECT '>> Inserting Data Into: bronze.erp_cust_az12';

    LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CUST_AZ12.csv'
    INTO TABLE bronze.erp_cust_az12
    FIELDS TERMINATED BY '\t'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES
    (
        @cid,
        @bdate,
        @gen
    )
    SET
        cid = @cid,
        bdate = STR_TO_DATE(@bdate, '%d-%m-%Y'),
        gen = @gen;

    SET end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    );

    SELECT '>> -------------';

    -- =====================================================
    -- Load ERP Location
    -- =====================================================

    SET start_time = NOW();

    SELECT '>> Truncating Table: bronze.erp_loc_a101';

    TRUNCATE TABLE bronze.erp_loc_a101;

    SELECT '>> Inserting Data Into: bronze.erp_loc_a101';

    LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LOC_A101.csv'
    INTO TABLE bronze.erp_loc_a101
    FIELDS TERMINATED BY '\t'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES
    (
        @cid,
        @cntry
    )
    SET
        cid = @cid,
        cntry = @cntry;

    SET end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    );

    SELECT '>> -------------';

    -- =====================================================
    -- Load ERP Product Category
    -- =====================================================

    SET start_time = NOW();

    SELECT '>> Truncating Table: bronze.erp_px_cat_g1v2';

    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    SELECT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';

    LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PX_CAT_G1V2.csv'
    INTO TABLE bronze.erp_px_cat_g1v2
    FIELDS TERMINATED BY '\t'
    LINES TERMINATED BY '\r\n'
    IGNORE 1 LINES
    (
        @id,
        @cat,
        @subcat,
        @maintenance
    )
    SET
        id = @id,
        cat = @cat,
        subcat = @subcat,
        maintenance = @maintenance;

    SET end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    );

    SELECT '>> -------------';

    -- =====================================================
    -- Bronze Layer Completed
    -- =====================================================

    SET batch_end_time = NOW();

    SELECT '==========================================';
    SELECT 'Loading Bronze Layer is Completed';

    SELECT CONCAT(
        '>> Total Load Duration: ',
        TIMESTAMPDIFF(SECOND, batch_start_time, batch_end_time),
        ' seconds'
    );

    SELECT '==========================================';

END //

DELIMITER ;


SHOW PROCEDURE STATUS
WHERE Db = 'bronze';

CALL load_bronze();