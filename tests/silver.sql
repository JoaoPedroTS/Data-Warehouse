/*
=======================================================
Script: Verificação de qualidade dos dados - camada 'silver'
Descrição: Executa consultas de validação sobre a tabela
    `silver.crm_cust_info`, garantindo que as transformações
    aplicadas na camada Silver foram efetivas, como:
      - Remoção de duplicidades
      - Eliminação de valores nulos
      - Correção de formatação em textos
      - Padronização de domínios categóricos
=======================================================
*/
USE DataWarehouse;
GO

--------------------------------------------------------
-- Verificação 1: Duplicidades e valores nulos
--------------------------------------------------------
-- Após o processo de transformação, espera-se que cada
-- cliente possua um identificador único e válido (sem NULL).
SELECT 
    cst_id,
    COUNT(*) AS qtd_ocorrencias
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING 
    COUNT(*) > 1 OR cst_id IS NULL;
GO

--------------------------------------------------------
-- Verificação 2: Seleção do registro mais recente por cliente
--------------------------------------------------------
-- Mesmo após deduplicação, esta consulta é útil para
-- confirmar que existe apenas uma linha válida por cliente
-- e que as datas foram corretamente convertidas para o tipo DATE.
SELECT *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id 
            ORDER BY cst_create_date DESC
        ) AS flag_last
    FROM silver.crm_cust_info
) t
WHERE flag_last = 1;
GO

--------------------------------------------------------
-- Verificação 3: Formatação incorreta em campos de texto
--------------------------------------------------------
-- Após limpeza e padronização, nenhum campo textual deve
-- apresentar espaços à esquerda ou à direita.
--------------------------------------------------------

-- 3.1 Verifica formatação em 'cst_firstname'
SELECT
    cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
GO

-- 3.2 Verifica formatação em 'cst_lastname'
SELECT
    cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
GO

-- 3.3 Verifica formatação em 'cst_gndr'
SELECT
    cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);
GO

--------------------------------------------------------
-- Verificação 4: Domínios de valores em colunas categóricas
--------------------------------------------------------
-- Verifica se os valores categóricos estão padronizados
-- conforme esperado após a transformação (ex: “M” e “F”
-- no lugar de variações como “Masculino”, “Fem”, etc).
--------------------------------------------------------

-- 4.1 Domínio de valores da coluna 'cst_gndr'
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;
GO

-- 4.2 Domínio de valores da coluna 'cst_marital_status'
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;
GO

--------------------------------------------------------
-- Verificação 5: Auditoria da criação no Data Warehouse
--------------------------------------------------------
-- Garante que a coluna 'dwt_create_date' foi preenchida
-- corretamente e contém valores válidos de data/hora.
--------------------------------------------------------
SELECT 
    COUNT(*) AS total_registros,
    COUNT(dwt_create_date) AS registros_com_data,
    MIN(dwt_create_date) AS menor_data,
    MAX(dwt_create_date) AS maior_data
FROM silver.crm_cust_info;
GO

/*
========================================================
Tabela: crm_prd_info
========================================================
*/
SELECT
    prd_id,
    COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING 
    COUNT(*) > 1
    OR prd_id IS NULL;

SELECT prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

SELECT prd_cost
FROM silver.crm_prd_info
WHERE
    prd_cost < 0
    OR prd_cost IS NULL;

SELECT DISTINCT prd_line
FROM silver.crm_prd_info;

SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

/*
===========================
Tabela crm_sales_details
===========================
*/
SELECT sls_prd_key
FROM bronze.crm_sales_details
WHERE
    sls_prd_key NOT IN (
        SELECT prd_key
        FROM silver.crm_prd_info
    );


SELECT sls_cust_id
FROM bronze.crm_sales_details
WHERE
    sls_cust_id NOT IN (
        SELECT cst_id
        FROM silver.crm_cust_info
    );

/*
===========================
Tabela crm_sales_details
===========================
*/
SELECT sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

SELECT *
FROM silver.crm_sales_details
WHERE 
    sls_order_dt > sls_ship_dt
    OR sls_order_dt > sls_due_dt;

SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE
    sls_sales != sls_quantity * sls_price
    OR sls_sales IS NULL
    OR sls_quantity IS NULL
    OR sls_price IS NULL
    OR sls_sales <= 0
    OR sls_quantity <= 0
    OR sls_price <= 0
ORDER BY sls_sales, sls_quantity;

/*
===========================
Tabela erp_cust_az12
===========================
*/

SELECT *
FROM silver.erp_cust_az12;

SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE
    bdate < '1924-01-01'
    OR bdate > GETDATE();

SELECT DISTINCT gen
FROM silver.erp_cust_az12;

/*
===========================
Tabela erp_loc_a101
===========================
*/

SELECT *
FROM silver.erp_loc_a101;

SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

/*
===========================
Tabela erp_px_cat_g1v2
===========================
*/

SELECT *
FROM silver.erp_px_cat_g1v2;

SELECT *
FROM silver.erp_px_cat_g1v2
WHERE 
    cat != TRIM(cat)
    OR subcat != TRIM(subcat)
    OR maintenance != TRIM(maintenance);

SELECT DISTINCT cat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2;