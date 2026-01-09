/*
=====================================================
Script: Verificação de qualidade dos dados - camada "bronze"
Descrição: Executa consultas de diagnóstico para identificar
            possíveis problemas de qualidade nas tabelas brutas
            (camada bronze) antes do processo de tranformação 
            para a camada "silver"
Objetivos:
    - Identificar duplicatas e valores nulos
    - Verificar formatação incorretas em campos de texto
    - Validar domínios de valores e colunas categóricas
=====================================================
*/
USE DataWarehouse;
GO

/*
========================================================
Tabela: crm_cust info
========================================================
*/
--------------------------------------------------------
-- Verificação 1: Duplicidades e valores nulos
--------------------------------------------------------
-- Esta consulta agrupa os registros por 'cst_id' e conta
-- quantas vezes cada identificador aparece. O objetivo é
-- detectar possíveis duplicidades (COUNT > 1) ou registros
-- com identificador ausente (IS NULL).
SELECT 
    cst_id,
    COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING 
    COUNT(*) > 1 OR cst_id IS NULL;
GO

--------------------------------------------------------
-- Verificação 2: Seleção do registro mais recente por cliente
--------------------------------------------------------
-- Utiliza a função ROW_NUMBER para ordenar os registros
-- por data de criação e marcar o mais recente (flag_last = 1).
-- Essa técnica é útil para deduplicação posterior.
SELECT *
FROM(
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS flag_last
    FROM bronze.crm_cust_info
)t
WHERE flag_last = 1
GO

--------------------------------------------------------
-- Verificação 3: Formatação incorreta em campos de texto
--------------------------------------------------------
-- Estas consultas verificam se há espaços desnecessários
-- (à esquerda ou à direita) nos campos de texto,
-- comparando o valor original com a função TRIM().
--------------------------------------------------------

-- 3.1 Verifica espaços indevidos em 'cst_firstname'
SELECT
    cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname !=  TRIM(cst_firstname);
GO

-- 3.2 Verifica espaços indevidos em 'cst_lastname'
SELECT
    cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname !=  TRIM(cst_lastname);
GO

-- 3.3 Verifica espaços indevidos em 'cst_gndr'
SELECT
    cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr !=  TRIM(cst_gndr);
GO

--------------------------------------------------------
-- Verificação 4: Domínios de valores em colunas categóricas
--------------------------------------------------------
-- Estas consultas retornam todos os valores distintos
-- para verificar se existem categorias inesperadas
-- ou inconsistências de padronização (ex: 'Masculino', 'MASC', 'M').
--------------------------------------------------------

-- 4.1 Valores distintos de 'cst_gndr' (gênero)
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;
GO

-- 4.2 Valores distintos de 'cst_material_status' (status civil)
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;

/*
========================================================
Tabela: crm_prd_info
========================================================
*/
SELECT
    prd_id,
    COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING 
    COUNT(*) > 1
    OR prd_id IS NULL

SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

SELECT prd_cost
FROM bronze.crm_prd_info
WHERE
    prd_cost < 0
    OR prd_cost IS NULL;

SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;

SELECT *
FROM bronze.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

/*
===========================
Tabela crm_sales_details
===========================
*/
SELECT sls_ord_num
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

SELECT NULLIF(sls_order_dt, 0) sls_order_dt
FROM bronze.crm_sales_details
WHERE
    sls_order_dt <= 0
    OR LEN(sls_order_dt) != 8;

SELECT NULLIF(sls_order_dt, 0) sls_order_dt
FROM bronze.crm_sales_details
WHERE
    sls_order_dt > 20500101
    OR sls_order_dt < 19000101;

SELECT NULLIF(sls_ship_dt, 0) sls_ship_dt
FROM bronze.crm_sales_details
WHERE
    sls_ship_dt <= 0
    OR LEN(sls_ship_dt) != 8;

SELECT NULLIF(sls_ship_dt, 0) sls_ship_dt
FROM bronze.crm_sales_details
WHERE
    sls_ship_dt > 20500101
    OR sls_ship_dt < 19000101;

SELECT NULLIF(sls_due_dt, 0) sls_due_dt
FROM bronze.crm_sales_details
WHERE
    sls_due_dt <= 0
    OR LEN(sls_due_dt) != 8;

SELECT NULLIF(sls_due_dt, 0) sls_due_dt
FROM bronze.crm_sales_details
WHERE
    sls_due_dt > 20500101
    OR sls_due_dt < 19000101;

SELECT *
FROM bronze.crm_sales_details
WHERE 
    sls_order_dt > sls_ship_dt
    OR sls_order_dt > sls_due_dt;

SELECT DISTINCT
    sls_sales AS old_sls_sales,
    sls_quantity,
    sls_price AS old_sls_price,
    CASE
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,
    CASE
        WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details
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
FROM bronze.erp_cust_az12;

SELECT DISTINCT bdate
FROM bronze.erp_cust_az12
WHERE
    bdate < '1924-01-01'
    OR bdate > GETDATE();

SELECT DISTINCT gen
FROM bronze.erp_cust_az12;

/*
===========================
Tabela erp_loc_a101
===========================
*/

SELECT *
FROM bronze.erp_loc_a101;

SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
ORDER BY cntry;

/*
===========================
Tabela erp_px_cat_g1v2
===========================
*/

SELECT *
FROM bronze.erp_px_cat_g1v2;

SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE 
    cat != TRIM(cat)
    OR subcat != TRIM(subcat)
    OR maintenance != TRIM(maintenance);

SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2;

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2;