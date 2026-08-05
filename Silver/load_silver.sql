USE silver;
  
DROP PROCEDURE IF EXISTS load_silver;
DELIMITER $$
CREATE PROCEDURE load_silver()
BEGIN
    -- Variables
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE batch_start_time DATETIME;
    DECLARE batch_end_time DATETIME;

    -- Error Handler
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @err_msg = MESSAGE_TEXT,
            @err_no = MYSQL_ERRNO;

        SELECT 'ERROR OCCURRED DURING SILVER LOAD' AS Status,
               @err_no AS Error_No,
               @err_msg AS Error_Message;
    END;

    SET batch_start_time= NOW();

    SELECT '=================================' AS '';
    SELECT 'Loading Silver Layer' AS '';
    SELECT '=================================' AS '';

    SELECT 'Loading CRM Customer Table' AS '';

    SET start_time = NOW();

    TRUNCATE TABLE crm_cust_info;

    INSERT INTO crm_cust_info
    (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )

    SELECT
        cst_id,
        cst_key,

        TRIM(cst_firstname),

        TRIM(cst_lastname),

        CASE
            WHEN UPPER(TRIM(cst_marital_status))='S'
                THEN 'Single'

            WHEN UPPER(TRIM(cst_marital_status))='M'
                THEN 'Married'

            ELSE 'n/a'
        END,

        CASE
            WHEN UPPER(TRIM(cst_gndr))='F'
                THEN 'Female'

            WHEN UPPER(TRIM(cst_gndr))='M'
                THEN 'Male'

            ELSE 'n/a'
        END,
        NULLIF(cst_create_date, '0000-00-00') AS cst_create_date
    FROM
    (
        SELECT *,
               ROW_NUMBER() OVER
               (
                   PARTITION BY cst_id
                   ORDER BY cst_create_date DESC
               ) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) t

    WHERE flag_last = 1;

    SET end_time = NOW();

    SELECT CONCAT(
        'CRM Customer Load Time : ',
        TIMESTAMPDIFF(SECOND,start_time,end_time),
        ' seconds'
    ) AS Message;

 SELECT '>> -------------' AS Message;
 
     SET start_time = NOW();

    SELECT '>> Truncating Table: silver.crm_prd_info' AS Message;

    TRUNCATE TABLE crm_prd_info;

    SELECT '>> Inserting Data Into: silver.crm_prd_info' AS Message;

    INSERT INTO crm_prd_info
    (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
        SELECT
        prd_id,

        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,

        SUBSTRING(prd_key, 7, LENGTH(prd_key)) AS prd_key,

        prd_nm,

        IFNULL(prd_cost, 0) AS prd_cost,

        CASE
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,

        CAST(prd_start_dt AS DATE) AS prd_start_dt,

        DATE_SUB(
            LEAD(prd_start_dt) OVER
            (
                PARTITION BY prd_key
                ORDER BY prd_start_dt
            ),
            INTERVAL 1 DAY
        ) AS prd_end_dt

    FROM bronze.crm_prd_info;
    
        SET end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS Message;

    SELECT '>> -------------' AS Message;
    
        SET start_time = NOW();

    SELECT '>> Truncating Table: silver.crm_sales_details' AS Message;

    TRUNCATE TABLE crm_sales_details;

    SELECT '>> Inserting Data Into: silver.crm_sales_details' AS Message;

    INSERT INTO crm_sales_details
    (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
        SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,

        CASE
            WHEN sls_order_dt = 0
                 OR LENGTH(sls_order_dt) <> 8
            THEN NULL
            ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d')
        END AS sls_order_dt,

        CASE
            WHEN sls_ship_dt = 0
                 OR LENGTH(sls_ship_dt) <> 8
            THEN NULL
            ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d')
        END AS sls_ship_dt,

        CASE
            WHEN sls_due_dt = 0
                 OR LENGTH(sls_due_dt) <> 8
            THEN NULL
            ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d')
        END AS sls_due_dt,

        CASE
            WHEN sls_sales IS NULL
                 OR sls_sales <= 0
                 OR sls_sales <> sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,

        sls_quantity,

        CASE
            WHEN sls_price IS NULL
                 OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END AS sls_price

    FROM bronze.crm_sales_details;
        SET end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS Message;

    SELECT '>> -------------' AS Message;	
        SET start_time = NOW();

    SELECT '>> Truncating Table: silver.erp_cust_az12' AS Message;

    TRUNCATE TABLE erp_cust_az12;
    SELECT '>> Inserting Data Into: silver.erp_cust_az12' AS Message;

    INSERT INTO erp_cust_az12
    (
        cid,
        bdate,
        gen
    )
    
        SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
            ELSE cid
        END AS cid,

        CASE
            WHEN bdate > CURDATE() THEN NULL
            ELSE bdate
        END AS bdate,

        CASE
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END AS gen

    FROM bronze.erp_cust_az12;
        SET end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS Message;

    SELECT '>> -------------' AS Message;
        SELECT '------------------------------------------------' AS Message;
    SELECT 'Loading ERP Tables' AS Message;
    SELECT '------------------------------------------------' AS Message;
        SET start_time = NOW();

    SELECT '>> Truncating Table: silver.erp_loc_a101' AS Message;

    TRUNCATE TABLE erp_loc_a101;

    SELECT '>> Inserting Data Into: silver.erp_loc_a101' AS Message;

    INSERT INTO erp_loc_a101
    (
        cid,
        cntry
    )
        SELECT
        REPLACE(cid, '-', '') AS cid,

        CASE
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry

    FROM bronze.erp_loc_a101;
        SET end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS Message;

    SELECT '>> -------------' AS Message;
        SET start_time = NOW();

    SELECT '>> Truncating Table: silver.erp_px_cat_g1v2' AS Message;

    TRUNCATE TABLE erp_px_cat_g1v2;

    SELECT '>> Inserting Data Into: silver.erp_px_cat_g1v2' AS Message;

    INSERT INTO erp_px_cat_g1v2
    (
        id,
        cat,
        subcat,
        maintenance
    )
        SELECT
        id,
        cat,
        subcat,
        maintenance
    FROM bronze.erp_px_cat_g1v2;
        SET end_time = NOW();

    SELECT CONCAT(
        '>> Load Duration: ',
        TIMESTAMPDIFF(SECOND, start_time, end_time),
        ' seconds'
    ) AS Message;

    SELECT '>> -------------' AS Message;
        SET batch_end_time = NOW();

    SELECT '==========================================' AS Message;

    SELECT 'Loading Silver Layer is Completed' AS Message;

    SELECT CONCAT(
        'Total Load Duration: ',
        TIMESTAMPDIFF(SECOND, batch_start_time, batch_end_time),
        ' seconds'
    ) AS Message;

    SELECT '==========================================' AS Message;
    END $$

DELIMITER ;



