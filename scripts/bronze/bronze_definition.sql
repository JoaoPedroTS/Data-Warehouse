/*
=======================================================
Script: Criação das tabelas da camada 'bronze'
Descrição: Cria as tabelas brutas (raw) da camada Bronze
    do Data Warehouse. Essas tabelas armazenam dados
    importados diretamente das fontes CRM e ERP,
    preservando o formato original antes de qualquer
    transformação ou limpeza.
    
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
-- Tabela: bronze.crm_cust_info
-- Descrição: Contém informações cadastrais dos clientes
-- da fonte CRM, incluindo nome, gênero e data de criação.
-- ======================================================
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;
GO
CREATE TABLE bronze.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);
GO

-- ======================================================
-- Tabela: bronze.crm_prd_info
-- Descrição: Contém informações sobre produtos
-- cadastrados no CRM, como nome, custo, linha de produto
-- e datas de vigência.
-- ======================================================
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;
GO
CREATE TABLE bronze.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);
GO

-- ======================================================
-- Tabela: bronze.crm_sales_details
-- Descrição: Armazena detalhes das vendas registradas
-- no CRM, incluindo número do pedido, produto, cliente,
-- datas e valores associados à transação.
-- ======================================================
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;
GO
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);
GO

--------------------------------------------------------
-- ERP TABLES
--------------------------------------------------------

-- ======================================================
-- Tabela: bronze.erp_cust_az12
-- Descrição: Dados cadastrais dos clientes vindos do ERP,
-- contendo identificador, data de nascimento e gênero.
-- ======================================================
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;
GO
CREATE TABLE bronze.erp_cust_az12 (
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50)
);
GO

-- ======================================================
-- Tabela: bronze.erp_loc_a101
-- Descrição: Relaciona clientes e seus respectivos países,
-- conforme registros do sistema ERP.
-- ======================================================
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
GO
CREATE TABLE bronze.erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);
GO

-- ======================================================
-- Tabela: bronze.erp_px_cat_g1v2
-- Descrição: Contém dados de categorias e subcategorias
-- de produtos do ERP, incluindo informações de manutenção.
-- ======================================================
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
GO
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);
GO