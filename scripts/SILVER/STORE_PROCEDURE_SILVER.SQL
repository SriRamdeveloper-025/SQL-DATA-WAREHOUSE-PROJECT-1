CREATE OR ALTER PROCEDURE SILVER.load_silver AS
BEGIN
        print'==============================================';
		print'silver layer';
		print'===============================================';

		print'==============================================';
		print'SILVER .CUSTOM_INFO';
		print'===============================================';
		PRINT '>> TRUNCATING DATA TABLE : SILVER .CUSTOM_INFO';
		TRUNCATE TABLE [dbo].[silver.cust_info];
		PRINT'>> INSERTING DATA INTO : [dbo].[silver.cust_info]';
		INSERT INTO [dbo].[silver.cust_info] (
		CST_ID,
		CST_KEY,                          
		CST_FIRSTNAME,
		CST_LASTNAME,
		cst_marital_status,
		cst_gndr,
		cst_create_date
		)
		SELECT 
		CST_ID,
		CST_KEY,
		TRIM(cst_firstname) AS CST_FIRSTNAME ,
		TRIM(cst_lastname) AS CST_LASTNAME ,
		CASE WHEN   UPPER(TRIM(cst_marital_status))= 'S' THEN 'SINGLE'
			   WHEN    UPPER(TRIM(cst_marital_status)) = 'M' THEN 'MARRIED'
			   ELSE 'N/A'   
		END cst_marital_status
			,
		CASE WHEN UPPER(CST_gndr) ='F' THEN 'FEMALE'
			 WHEN UPPER(CST_gndr) = 'M' THEN 'MALE'
			 ELSE 'N/A'
		END cst_gndr,
		cst_create_date
			FROM (
		SELECT *,
			ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY CST_CREATE_DATE DESC) AS FALG_LAST
			FROM [dbo].[bronze.cust_info]
			WHERE  cst_id is not null
			)T where falg_last = 1;
           print'==============================================';
		print'silver.prd_info';
		print'===============================================';

		PRINT '>> TRUNCATING DATA TABLE : [dbo].[silver.prd_info]';
		TRUNCATE TABLE [dbo].[silver.prd_info];
		PRINT'>> INSERTING DATA INTO : [dbo].[silver.prd_info]';

			INSERT INTO [dbo].[silver.prd_info] (
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
		REPLACE(SUBSTRING(prd_key,1,5), '-','_') as cat_id,
		SUBSTRING(prd_key,7,len(prd_key))as prd_key,
		prd_nm,
		ISNULL(prd_cost,0) AS PRD_COST,
		CASE UPPER(TRIM(prd_line)) 
			 WHEN  'M' THEN 'MOUNTAIN'
			 WHEN  'R' THEN 'ROAD'
			 WHEN  'S' THEN 'ORTHER SALES'
			 WHEN 'T' THEN 'TOURING'
			 ELSE 'N/A'
		END prd_line,
		prd_start_dt,
		LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) as prd_end_dt
		  FROM [dbo].[bronze.prd_info];
		    print'==============================================';
		print'SILVER.crm_sales';
		print'===============================================';

		 PRINT '>> TRUNCATING DATA TABLE : [dbo].[SILVER.crm_sales]';
		TRUNCATE TABLE [dbo].[SILVER.crm_sales];
		PRINT'>> INSERTING DATA INTO : [dbo].[SILVER.crm_sales]';

		  INSERT INTO [dbo].[SILVER.crm_sales] (
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
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			CASE WHEN SLS_PRICE IS NULL  OR SLS_PRICE = 0
				 THEN SLS_SALES / NULLIF(SLS_QUANTITY,0)
				 ELSE SLS_PRICE
			END SLS_SALES,
			sls_quantity,
			CASE WHEN SLS_PRICE IS NULL  OR SLS_PRICE = 0
				 THEN SLS_SALES / NULLIF(SLS_QUANTITY,0)
				 ELSE SLS_PRICE
			END SLS_PRICE
			FROM [dbo].[bronze.crm_sales];

		PRINT'-------------------------------------------------------------------------'
		PRINT'ERP'
		PRINT'-------------------------------------------------------------------------'

		  print'==============================================';
		print'silver.CUST_AZ12';
		print'===============================================';

		PRINT '>> TRUNCATING DATA TABLE : [dbo].[silver.CUST_AZ12]';
		TRUNCATE TABLE [dbo].[silver.CUST_AZ12];
		PRINT'>> INSERTING DATA INTO : [dbo].[silver.CUST_AZ12]';

		INSERT INTO  [dbo].[silver.CUST_AZ12](            
		CID,BDATE,GEN
		)
		SELECT 
		CASE WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
			 ELSE CID
		END AS CID,
		CASE WHEN BDATE > GETDATE() THEN NULL
			 ELSE BDATE
		END AS BDATE,
		CASE 
			 WHEN UPPER(TRIM(GEN)) IN  ('F','FEMALE') THEN 'FEMALE'
			 WHEN UPPER(TRIM(GEN)) IN  ('M','MALE') THEN 'MALE'
			 ELSE 'N/A'
		END GEN 
		FROM [dbo].[bronze.CUST_AZ12];
		  print'==============================================';
		print'SILVER.LOC_A101';
		print'===============================================';

		PRINT '>> TRUNCATING DATA TABLE 101 : [dbo].[SILVER.LOC_A101]';
		TRUNCATE TABLE [dbo].[SILVER.LOC_A101];
		PRINT'>> INSERTING DATA INTO : [dbo].[SILVER.LOC_A101]';

		INSERT INTO [dbo].[SILVER.LOC_A101](CID,CNTRY)
		SELECT 
		REPLACE(CID,'-',''),
		CASE WHEN TRIM(CNTRY) = 'DE' THEN 'GERMANY'
			 WHEN TRIM(CNTRY) IN ('US','USA') THEN 'UNITED STATES'
			 WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'N/A'
			 ELSE TRIM(CNTRY)
		END CNTRY 
		FROM[dbo].[bronze.LOC_A101];

		  print'==============================================';
		print'silver.erp_PX';
		print'===============================================';

		PRINT'------------------------------------------------'
		PRINT '>> TRUNCATING DATA TABLE : [[dbo].[ silver.erp_PX]';
		TRUNCATE TABLE [dbo].[ silver.erp_PX];
		PRINT'>> INSERTING DATA INTO : [dbo].[ silver.erp_PX]';

		INSERT INTO [dbo].[ silver.erp_PX](ID,CAT,SUBCAT,MAINTENANCE)
		SELECT  
		 ID,
		 CAT,
		SUBCAT,
		CASE WHEN MAINTENANCE ='1' THEN 'YES'
			 WHEN MAINTENANCE = '0' THEN 'NO'
			 ELSE 'N/A'
		END MAINTENANCE
		FROM [dbo].[bronze.erp_PX];
END
