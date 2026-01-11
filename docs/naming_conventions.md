# **Convenções de Nomenclatura**

Este documento descreve as convenções de nomenclatura utilizadas para schemas, tabelas, views, colunas e outros objetos no data warehouse.

## **Sumário**

1. [Princípios Gerais](#princípios-gerais)
2. [Convenções de Nomenclatura de Tabelas](#convenções-de-nomenclatura-de-tabelas)
   - [Regras da Bronze](#regras-da-bronze)
   - [Regras da Silver](#regras-da-silver)
   - [Regras da Gold](#regras-da-gold)
3. [Convenções de Nomenclatura de Colunas](#convenções-de-nomenclatura-de-colunas)
   - [Chaves Substitutas](#chaves-substitutas)
   - [Colunas Técnicas](#colunas-técnicas)
4. [Stored Procedures](#stored-procedures)
---

## **Princípios Gerais**

- **Convenções de Nomenclatura**: Utilizar `snake_case`, com letras minúsculas e underscores (`_`) para separar palavras.
- **Idioma**: Utilizar inglês para todos os nomes.
- **Evitar Palavras Reservadas**: Não utilizar palavras reservadas do SQL como nomes de objetos.

## **Convenções de Nomenclatura de Tabelas**

### **Regras da Bronze**
- Todos os nomes devem começar com o nome do sistema de origem, e os nomes das tabelas devem corresponder exatamente aos nomes originais, sem renomeação.
- **`<sourcesystem>_<entity>`**  
  - `<sourcesystem>`: Nome do sistema de origem (ex.: `crm`, `erp`).  
  - `<entity>`: Nome exato da tabela no sistema de origem.  
  - Exemplo: `crm_customer_info` → Informações de clientes provenientes do sistema CRM.

### **Regras da Silver**
- Todos os nomes devem começar com o nome do sistema de origem, e os nomes das tabelas devem corresponder exatamente aos nomes originais, sem renomeação.
- **`<sourcesystem>_<entity>`**  
  - `<sourcesystem>`: Nome do sistema de origem (ex.: `crm`, `erp`).  
  - `<entity>`: Nome exato da tabela no sistema de origem.  
  - Exemplo: `crm_customer_info` → Informações de clientes provenientes do sistema CRM.

### **Regras da Gold**
- Todos os nomes devem utilizar nomes significativos e alinhados ao negócio, iniciando com um prefixo de categoria.
- **`<category>_<entity>`**  
  - `<category>`: Descreve o papel da tabela, como `dim` (dimensão) ou `fact` (tabela de fatos).  
  - `<entity>`: Nome descritivo da tabela, alinhado ao domínio de negócio (ex.: `customers`, `products`, `sales`).  
  - Exemplos:
    - `dim_customers` → Tabela de dimensão para dados de clientes.  
    - `fact_sales` → Tabela de fatos contendo transações de vendas.  

#### **Glossário de Padrões de Categoria**

| Padrão      | Significado                     | Exemplo(s)                                     |
|-------------|---------------------------------|------------------------------------------------|
| `dim_`      | Tabela de dimensão              | `dim_customer`, `dim_product`                  |
| `fact_`     | Tabela de fatos                 | `fact_sales`                                   |
| `report_`   | Tabela de relatórios            | `report_customers`, `report_sales_monthly`     |

## **Convenções de Nomenclatura de Colunas**

### **Chaves Substitutas**  
- Todas as chaves primárias em tabelas de dimensão devem utilizar o sufixo `_key`.
- **`<table_name>_key`**  
  - `<table_name>`: Refere-se ao nome da tabela ou entidade à qual a chave pertence.  
  - `_key`: Sufixo que indica que esta coluna é uma chave substituta.  
  - Exemplo: `customer_key` → Chave substituta na tabela `dim_customers`.

### **Colunas Técnicas**
- Todas as colunas técnicas devem iniciar com o prefixo `dwh_`, seguido de um nome descritivo que indique a finalidade da coluna.
- **`dwh_<column_name>`**  
  - `dwh`: Prefixo exclusivo para metadados gerados pelo sistema.  
  - `<column_name>`: Nome descritivo que indica o propósito da coluna.  
  - Exemplo: `dwh_load_date` → Coluna gerada pelo sistema para armazenar a data de carga do registro.
 
## **Stored Procedures**

- Todas as stored procedures utilizadas para carga de dados devem seguir o padrão de nomenclatura:
- **`load_<layer>`**.
  
  - `<layer>`: Representa a camada que está sendo carregada, como `bronze`, `silver` ou `gold`.
  - Exemplos: 
    - `load_bronze` → Stored procedure para carga de dados na camada Bronze.
    - `load_silver` → Stored procedure para carga de dados na camada Silver.
