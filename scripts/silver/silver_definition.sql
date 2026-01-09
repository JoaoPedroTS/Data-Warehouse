/*
=======================================================
Script: Criação das tabelas da camada 'silver'
Descrição: Cria as tabelas transformadas e padronizadas
    da camada Silver do Data Warehouse. Nesta camada,
    os dados provenientes das fontes CRM e ERP já
    passaram por processos de limpeza, padronização
    e integração, tornando-se consistentes e prontos
    para análises e modelagem da camada Gold.
    
    Estrutura:
      - Tabelas CRM:
          • crm_cust_info
          • crm_prd_info
          • crm_sales_details
      - Tabelas ERP:
          • erp_cust_az12
          • erp_loc_a101
          • erp_px_cat_g1v2
=======================================================
*/
USE DataWarehouse;
GO

--------------------------------------------------------
-- CRM TABLES
--------------------------------------------------------

-- ======================================================
-- Tabela: silver.crm_cust_info
-- Descrição: Contém informações de clientes do CRM após
-- limpeza e padronização de nomes, status e datas.
-- ======================================================
IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO
CREATE TABLE silver.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE,
    dwt_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- ======================================================
-- Tabela: silver.crm_prd_info
-- Descrição: Contém informações de produtos do CRM com
-- padronização de tipos de dados e formatação de datas.
-- ======================================================
IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO
CREATE TABLE silver.crm_prd_info (
    prd_id INT,
    cat_id NVARCHAR(50),
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(100),
    prd_cost DECIMAL(10,2),
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwt_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- ======================================================
-- Tabela: silver.crm_sales_details
-- Descrição: Armazena as vendas do CRM com datas e valores
-- convertidos para tipos adequados e consistentes.
-- ======================================================
IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO
CREATE TABLE silver.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales DECIMAL(10,2),
    sls_quantity INT,
    sls_price DECIMAL(10,2),
    dwt_create_date DATETIME2 DEFAULT GETDATE()
);
GO

--------------------------------------------------------
-- ERP TABLES
--------------------------------------------------------

-- ======================================================
-- Tabela: silver.erp_cust_az12
-- Descrição: Dados de clientes do ERP tratados e
-- padronizados, com formatação de datas e campos válidos.
-- ======================================================
IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO
CREATE TABLE silver.erp_cust_az12 (
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(10),
    dwt_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- ======================================================
-- Tabela: silver.erp_loc_a101
-- Descrição: Relação entre clientes e países normalizada
-- para evitar duplicidades e inconsistências.
-- ======================================================
IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO
CREATE TABLE silver.erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50),
    dwt_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- ======================================================
-- Tabela: silver.erp_px_cat_g1v2
-- Descrição: Tabela de categorias e subcategorias de
-- produtos com padronização de nomenclaturas e colunas.
-- ======================================================
IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO
CREATE TABLE silver.erp_px_cat_g1v2 (
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50),
    dwt_create_date DATETIME2 DEFAULT GETDATE()
);
GO
