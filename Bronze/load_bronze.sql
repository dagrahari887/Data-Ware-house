USE bronze;

-- =====================================================
-- Start Batch Load
-- =====================================================

SET @batch_start_time = NOW();

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

SET @start_time = NOW();

SELECT '>> Truncating Table: bronze.crm_cust_info';

TRUNCATE TABLE bronze.crm_cust_info;

SELECT '>> Inserting Data Into: bronze.crm_cust_info';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
IGNORE
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

SET @end_time = NOW();

SELECT CONCAT(
    '>> Load Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' seconds'
);

SELECT '>> -------------';


-- =====================================================
-- Load CRM Product Information
-- =====================================================

SET @start_time = NOW();

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

SET @end_time = NOW();

SELECT CONCAT(
    '>> Load Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' seconds'
);

SELECT '>> -------------';

-- =====================================================
-- Load CRM Sales Details
-- =====================================================

SET @start_time = NOW();

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

SET @end_time = NOW();

SELECT CONCAT(
    '>> Load Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
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

SET @start_time = NOW();

SELECT '>> Truncating Table: bronze.erp_cust_az12';

TRUNCATE TABLE bronze.erp_cust_az12;

SELECT '>> Inserting Data Into: bronze.erp_cust_az12';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CUST_AZ12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
    @cid,
    @bdate,
    @gen
)
SET
    cid = @cid,
    bdate = STR_TO_DATE(@bdate, '%Y-%m-%d'),
    gen = @gen;

SET @end_time = NOW();

SELECT CONCAT(
    '>> Load Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' seconds'
);

SELECT '>> -------------';

-- =====================================================
-- Load ERP Location
-- =====================================================

SET @start_time = NOW();

SELECT '>> Truncating Table: bronze.erp_loc_a101';

TRUNCATE TABLE bronze.erp_loc_a101;

SELECT '>> Inserting Data Into: bronze.erp_loc_a101';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(
    @cid,
    @cntry
)
SET
    cid = @cid,
    cntry = @cntry;

SET @end_time = NOW();

SELECT CONCAT(
    '>> Load Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' seconds'
);

SELECT '>> -------------';

-- =====================================================
-- Load ERP Product Category
-- =====================================================

SET @start_time = NOW();

SELECT '>> Truncating Table: bronze.erp_px_cat_g1v2';

TRUNCATE TABLE bronze.erp_px_cat_g1v2;

SELECT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
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

SET @end_time = NOW();

SELECT CONCAT(
    '>> Load Duration: ',
    TIMESTAMPDIFF(SECOND, @start_time, @end_time),
    ' seconds'
);

SELECT '>> -------------';

-- =====================================================
-- Bronze Layer Completed
-- =====================================================

SET @batch_end_time = NOW();

SELECT '==========================================';
SELECT 'Loading Bronze Layer is Completed';

SELECT CONCAT(
    '>> Total Load Duration: ',
    TIMESTAMPDIFF(SECOND, @batch_start_time, @batch_end_time),
    ' seconds'
);

SELECT '==========================================';

select * from bronze.erp_px_cat_g1v2;