/*
=======================================================
Script: Procedimento 'bronze.load_bronze'
Descrição: Cria ou atualiza a procedure responsável por
    realizar o carregamento da camada Bronze do
    Data Warehouse. O script:
      - Trunca as tabelas existentes na camada Bronze;
      - Realiza o carregamento (BULK INSERT) dos arquivos
        CSV das fontes CRM e ERP;
      - Exibe logs e tempos de execução de cada etapa;
      - Possui tratamento de erros (TRY...CATCH) com
        mensagens detalhadas.
=======================================================
*/
USE DataWarehouse;
GO

-- Cria ou altera a stored procedure 'load_bronze' no schema 'bronze'
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    -- Declaração de variáveis para medir tempos de execução
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

    BEGIN TRY
        -- Marca o início do carregamento completo
        SET @batch_start_time = GETDATE();
        PRINT '===============================';
        PRINT 'Loading Bronze Layer';
        PRINT '===============================';

        -- Início do carregamento das tabelas CRM
        PRINT '-------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '-------------------------------';

        --------------------------------------------------------------------
        -- 1. Carregamento da tabela bronze.crm_cust_info
        --------------------------------------------------------------------
        SET @start_time = GETDATE();  -- Marca o início da carga da tabela

        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;  -- Remove todos os dados antigos (mantendo a estrutura da tabela)

        PRINT '>> Inserting data into: bronze.crm_cust_info';
        -- Carrega dados do arquivo CSV para a tabela
        BULK INSERT bronze.crm_cust_info
        FROM 'data/source_crm/cust_info.csv'
        WITH (
            FIRSTROW = 2,               -- Ignora o cabeçalho do CSV
            FIELDTERMINATOR = ',',      -- Define o separador de campos como vírgula
            TABLOCK                     -- Garante melhor performance travando a tabela inteira durante o load
        );

        -- Calcula e exibe o tempo de execução da carga
        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------';


        --------------------------------------------------------------------
        -- 2. Carregamento da tabela bronze.crm_prd_info
        --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting data into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'data/source_crm/prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------';


        --------------------------------------------------------------------
        -- 3. Carregamento da tabela bronze.crm_sales_details
        --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting data into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'data/source_crm/sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------';


        -- Agora inicia o carregamento das tabelas do ERP
        PRINT '-------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '-------------------------------';


        --------------------------------------------------------------------
        -- 4. Carregamento da tabela bronze.erp_cust_az12
        --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting data into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'data/source_erp/CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------';


        --------------------------------------------------------------------
        -- 5. Carregamento da tabela bronze.erp_loc_a101
        --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting data into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'data/source_erp/LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------';


        --------------------------------------------------------------------
        -- 6. Carregamento da tabela bronze.erp_px_cat_g1v2
        --------------------------------------------------------------------
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting data into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'data/source_erp/PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '---------------------------------------';


        --------------------------------------------------------------------
        -- Finalização da carga
        --------------------------------------------------------------------
        SET @batch_end_time = GETDATE();
        PRINT '============================================';
        PRINT 'Bronze Layer Load Completed Successfully!';
        PRINT ' - Total load duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '============================================';

    END TRY


    ------------------------------------------------------------------------
    -- Bloco de tratamento de erros
    ------------------------------------------------------------------------
    BEGIN CATCH
        PRINT '======================================================';
        PRINT 'Error occurred during loading bronze layer';
        PRINT 'Error message: ' + ERROR_MESSAGE();          -- Mensagem de erro
        PRINT 'Error number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);  -- Código do erro
        PRINT '======================================================';
    END CATCH
END;
GO

-- Comando para executar a procedure manualmente
-- USE DataWarehouse;
-- GO
-- EXEC bronze.load_bronze;