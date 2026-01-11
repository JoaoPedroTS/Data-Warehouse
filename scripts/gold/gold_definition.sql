/*
=======================================================
Script: Definição da camada 'gold'
Camada: Silver → Gold
Descrição:
    Cria as views dimensionais e de fatos da camada Gold
    do Data Warehouse. Esta camada é otimizada para
    análises, relatórios e consumo por ferramentas de BI.
    
    A modelagem segue o padrão dimensional (Star Schema),
    separando:
      - Dimensões (clientes e produtos)
      - Fato (vendas)
    
    Objetos criados:
      - gold.dim_customers
      - gold.dim_products
      - gold.fact_sales
=======================================================
*/

USE DataWarehouse;
GO

/*=====================================================
View: gold.dim_customers
Descrição:
    Dimensão de clientes consolidada a partir das fontes
    CRM e ERP. Centraliza informações demográficas,
    geográficas e cadastrais dos clientes.
    
    Regras aplicadas:
      - Geração de chave substituta (customer_key)
      - Prioridade do gênero vindo do CRM
      - Enriquecimento com dados de país e data de nascimento
=====================================================*/
CREATE VIEW gold.dim_customers AS (
    SELECT
        -- Chave substituta da dimensão
        ROW_NUMBER() OVER (
            ORDER BY cst_id
        ) AS customer_key,

        -- Identificadores de negócio
        ci.cst_id AS customer_id,
        ci.cst_key AS customer_number,

        -- Dados pessoais
        ci.cst_firstname AS first_name,
        ci.cst_lastname AS last_name,

        -- Localização
        la.cntry AS country,

        -- Estado civil
        ci.cst_marital_status AS marital_status,

        -- Regra de priorização do gênero (CRM > ERP)
        CASE 
            WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
            ELSE COALESCE(ca.gen, 'N/A')
        END AS gender,

        -- Dados complementares
        ca.bdate AS birthdate,
        ci.cst_create_date AS create_date

    FROM silver.crm_cust_info ci
    LEFT JOIN silver.erp_cust_az12 ca
        ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_loc_a101 la
        ON ci.cst_key = la.cid
);
GO

/*=====================================================
View: gold.dim_products
Descrição:
    Dimensão de produtos com informações comerciais
    e categorização. Considera apenas produtos ativos
    (vigência atual).
    
    Regras aplicadas:
      - Chave substituta baseada em data e chave do produto
      - Enriquecimento com categoria e subcategoria
      - Filtro de produtos com prd_end_dt IS NULL
=====================================================*/
CREATE VIEW gold.dim_products AS (
    SELECT
        -- Chave substituta da dimensão
        ROW_NUMBER() OVER (
            ORDER BY pn.prd_start_dt, pn.prd_key
        ) AS product_key,

        -- Identificadores de negócio
        pn.prd_id AS product_id,
        pn.prd_key AS product_number,

        -- Descrição do produto
        pn.prd_nm AS product_name,

        -- Categorização
        pn.cat_id AS category_id,
        pc.cat AS category,
        pc.subcat AS subcategory,
        pc.maintenance,

        -- Atributos comerciais
        pn.prd_cost AS cost,
        pn.prd_line AS product_line,

        -- Vigência
        pn.prd_start_dt AS start_date

    FROM silver.crm_prd_info pn
    LEFT JOIN silver.erp_px_cat_g1v2 pc
        ON pn.cat_id = pc.id

    -- Apenas produtos ativos
    WHERE pn.prd_end_dt IS NULL
);
GO

/*=====================================================
View: gold.fact_sales
Descrição:
    Tabela fato de vendas, representando eventos de
    compra. Conecta clientes e produtos às métricas
    quantitativas e financeiras.
    
    Métricas principais:
      - Valor da venda
      - Quantidade
      - Preço unitário
    
    Relacionamentos:
      - Produto → dim_products
      - Cliente → dim_customers
=====================================================*/
CREATE VIEW gold.fact_sales AS (
    SELECT
        -- Identificador do pedido
        sd.sls_ord_num AS order_number,

        -- Chaves dimensionais
        pr.product_key,
        cu.customer_key,

        -- Datas do processo de venda
        sd.sls_order_dt AS order_date,
        sd.sls_ship_dt AS shipping_date,
        sd.sls_due_dt AS due_date,

        -- Métricas
        sd.sls_sales AS sales_amount,
        sd.sls_quantity AS quantity,
        sd.sls_price AS price

    FROM silver.crm_sales_details sd
    LEFT JOIN gold.dim_products pr
        ON sd.sls_prd_key = pr.product_number
    LEFT JOIN gold.dim_customers cu
        ON sd.sls_cust_id = cu.customer_id
);
GO