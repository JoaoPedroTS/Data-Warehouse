/*
=======================================================
Script: Criação do banco de dados 'DataWarehouse'
Descrição: Cria o banco e os schemas principais
   (`bronze`, `silver`, `gold`) para organização das
   camadas de dados do Data Warehouse
=======================================================
*/

-- Conecta ao banco de sistema 'master'
USE master;
GO

-- Verifica se já existe um banco chamado 'DataWarehouse'
IF EXISTS (
    SELECT 1
    FROM sys.databases 
    WHERE name = 'DataWarehouse'
)
BEGIN
    -- Caso exista, força o banco a entrar em modo de usuário único
    -- e encerra quaisquer conexões ativas imediatamente.
    ALTER DATABASE DataWarehouse
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;
    
    -- Remove o banco existente
    DROP DATABASE DataWarehouse;
END;
GO

-- Cria o novo banco de dados 'DataWarehouse'
CREATE DATABASE DataWarehouse;

-- Define o contexto atual para o novo banco
USE DataWarehouse;
GO

-- Cria o schema 'bronze'
-- → Responsável por armazenar os dados brutos (raw data)
--   extraídos diretamente das fontes de origem.
CREATE SCHEMA bronze;
GO

-- Cria o schema 'silver'
-- → Contém dados tratados, padronizados e transformados
--   a partir do bronze, prontos para integração.
CREATE SCHEMA silver;
GO

-- Cria o schema 'gold'
-- → Contém dados prontos para consumo analítico,
--   geralmente organizados em modelos dimensionais
--   (tabelas fato e dimensão).
CREATE SCHEMA gold;
GO