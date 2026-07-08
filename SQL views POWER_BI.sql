CREATE VIEW fact_sales AS
SELECT
    oi.order_id,
    o.customer_id,
    oi.product_id,
    oi.seller_id,

    o.order_purchase_timestamp::date AS order_date,
    o.order_purchase_timestamp,

    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    oi.price,
    oi.freight_value,

    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
        THEN ROUND(
            EXTRACT(EPOCH FROM (
                o.order_delivered_customer_date -
                o.order_purchase_timestamp
            )) / 86400,
            1
        )
    END AS delivery_days

FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id

WHERE o.order_status = 'delivered';




-----------------------------

CREATE VIEW dim_customers AS
SELECT
    customer_id,
    customer_city,
    customer_state
FROM customers;

CREATE VIEW dim_sellers AS
SELECT
    seller_id,
    seller_city,
    seller_state
FROM sellers;



--------------------------------
CREATE OR REPLACE VIEW dim_products AS

WITH category_translation AS (

    SELECT *
    FROM (VALUES
        ('beleza_saude', 'Health & Beauty'),
        ('relogios_presentes', 'Watches & Gifts'),
        ('cama_mesa_banho', 'Bed, Bath & Table'),
        ('esporte_lazer', 'Sports & Leisure'),
        ('informatica_acessorios', 'Computer Accessories'),
        ('moveis_decoracao', 'Furniture & Decor'),
        ('cool_stuff', 'Cool Stuff'),
        ('utilidades_domesticas', 'Home Utilities'),
        ('automotivo', 'Automotive'),
        ('ferramentas_jardim', 'Garden Tools'),
        ('brinquedos', 'Toys'),
        ('bebes', 'Baby Products'),
        ('perfumaria', 'Perfume & Beauty'),
        ('telefonia', 'Telephony'),
        ('moveis_escritorio', 'Office Furniture'),
        ('papelaria', 'Stationery'),
        ('pcs', 'Computers'),
        ('pet_shop', 'Pet Shop'),
        ('instrumentos_musicais', 'Musical Instruments'),
        ('eletroportateis', 'Small Appliances'),
        ('eletronicos', 'Electronics'),
        ('consoles_games', 'Games & Consoles'),
        ('fashion_bolsas_e_acessorios', 'Fashion Bags & Accessories'),
        ('construcao_ferramentas_construcao', 'Construction Tools & Building'),
        ('malas_acessorios', 'Luggage & Accessories'),
        ('eletrodomesticos_2', 'Home Appliances (2nd line)'),
        ('casa_construcao', 'Home Construction'),
        ('eletrodomesticos', 'Home Appliances'),
        ('agro_industria_e_comercio', 'Agribusiness & Industry'),
        ('moveis_sala', 'Living Room Furniture'),
        ('telefonia_fixa', 'Fixed Telephony'),
        ('casa_conforto', 'Home Comfort'),
        ('climatizacao', 'Air Conditioning & Climate'),
        ('audio', 'Audio'),
        ('portateis_casa_forno_e_cafe', 'Portable Kitchen Appliances'),
        ('livros_interesse_geral', 'Books (General Interest)'),
        ('moveis_cozinha_area_de_servico_jantar_e_jardim', 'Kitchen, Dining & Garden Furniture'),
        ('construcao_ferramentas_iluminacao', 'Lighting Tools'),
        ('construcao_ferramentas_seguranca', 'Safety Tools'),
        ('industria_comercio_e_negocios', 'Industry, Commerce & Business'),
        ('alimentos', 'Food'),
        ('market_place', 'Marketplace'),
        ('construcao_ferramentas_jardim', 'Garden Construction Tools'),
        ('artes', 'Arts'),
        ('fashion_calcados', 'Fashion Shoes'),
        ('bebidas', 'Beverages'),
        ('sinalizacao_e_seguranca', 'Signaling & Safety'),
        ('moveis_quarto', 'Bedroom Furniture'),
        ('livros_tecnicos', 'Technical Books'),
        ('construcao_ferramentas_ferramentas', 'Construction Tools'),
        ('alimentos_bebidas', 'Food & Beverages'),
        ('fashion_roupa_masculina', 'Men Fashion'),
        ('fashion_underwear_e_moda_praia', 'Underwear & Swimwear'),
        ('artigos_de_natal', 'Christmas Items'),
        ('tablets_impressao_imagem', 'Tablets, Printing & Imaging'),
        ('cine_foto', 'Photography & Cinema'),
        ('musica', 'Music'),
        ('dvds_blu_ray', 'DVDs & Blu-ray'),
        ('livros_importados', 'Imported Books'),
        ('artigos_de_festas', 'Party Supplies'),
        ('moveis_colchao_e_estofado', 'Mattresses & Upholstery'),
        ('portateis_cozinha_e_preparadores_de_alimentos', 'Portable Food Prep Appliances'),
        ('fashion_roupa_feminina', 'Women Fashion'),
        ('fashion_esporte', 'Sports Fashion'),
        ('la_cuisine', 'Cooking'),
        ('artes_e_artesanato', 'Arts & Crafts'),
        ('fraldas_higiene', 'Diapers & Hygiene'),
        ('pc_gamer', 'Gaming PC'),
        ('flores', 'Flowers'),
        ('casa_conforto_2', 'Home Comfort II'),
        ('cds_dvds_musicais', 'Music CDs & DVDs'),
        ('fashion_roupa_infanto_juvenil', 'Kids Fashion'),
        ('seguros_e_servicos', 'Insurance & Services')
    ) AS t(category_pt, category_en)

)

SELECT
    p.product_id,

    COALESCE(
        ct.category_en,
        'Unknown'
    ) AS product_category

FROM products p

LEFT JOIN category_translation ct
    ON p.product_category_name = ct.category_pt;


-----------------------------

CREATE VIEW dim_payment AS
SELECT DISTINCT
    payment_type
FROM payments;

CREATE VIEW fact_payments AS
SELECT
    order_id,
    payment_type,
    payment_value,
    payment_installments
FROM payments;



-----------------------------
CREATE OR REPLACE VIEW dim_customers AS
SELECT
    customer_id,
    customer_city,
    customer_state,
    'Brazil' AS country
FROM customers;


-----------------------------
CREATE OR REPLACE VIEW dim_sellers AS
SELECT
    seller_id,
    seller_city,
    seller_state,
    'Brazil' AS country
FROM sellers;



-----------------------------
CREATE VIEW customer_orders AS
SELECT customer_id, COUNT(DISTINCT order_id) AS orders_count, SUM(price) AS customer_revenue
FROM fact_sales GROUP BY customer_id;

-----------------------------
sql/
├── 01_fact_sales.sql
├── 02_dim_customers.sql
├── 03_dim_products.sql
├── 04_dim_sellers.sql
├── 05_dim_payment.sql
├── 06_fact_payments.sql