--bad>>
EXPLAIN ANALYZE
SELECT 
    (SELECT product_category FROM (
        SELECT p.product_category, COUNT(o.order_id) as total_orders
        FROM opt_orders o
        JOIN opt_products p ON o.product_id = p.product_id
        JOIN opt_clients c ON o.client_id = c.id
        WHERE c.status = 'active' AND o.order_date >= DATE '2020-01-01'
        GROUP BY p.product_category
    ) sub1 ORDER BY total_orders DESC LIMIT 1) AS top_category,
    
    (SELECT product_category FROM (
        SELECT p.product_category, COUNT(o.order_id) as total_orders
        FROM opt_orders o
        JOIN opt_products p ON o.product_id = p.product_id
        JOIN opt_clients c ON o.client_id = c.id
        WHERE c.status = 'active' AND o.order_date >= DATE '2020-01-01'
        GROUP BY p.product_category
    ) sub2 ORDER BY total_orders ASC LIMIT 1) AS worst_category;
--oprimized>>
EXPLAIN ANALYZE
WITH joined_data AS (
    SELECT p.product_category, o.order_id
    FROM opt_orders o
    JOIN opt_products p ON o.product_id = p.product_id
    JOIN opt_clients c ON o.client_id = c.id
    WHERE c.status = 'active' AND o.order_date >= DATE '2020-01-01'
),
category_counts AS (
    SELECT product_category, COUNT(order_id) AS total_orders
    FROM joined_data
    GROUP BY product_category
),
ranked_categories AS (
    SELECT 
        product_category,
        ROW_NUMBER() OVER (ORDER BY total_orders DESC) AS rank_desc,
        ROW_NUMBER() OVER (ORDER BY total_orders ASC) AS rank_asc
    FROM category_counts
)
SELECT 
    MAX(product_category) FILTER (WHERE rank_desc = 1) AS top_category,
    MAX(product_category) FILTER (WHERE rank_asc = 1) AS worst_category
FROM ranked_categories;
-- with bonus task>>
CREATE INDEX IF NOT EXISTS idx_custom_orders_date ON opt_orders(order_date);
CREATE INDEX IF NOT EXISTS idx_custom_orders_prod ON opt_orders(product_id);
CREATE INDEX IF NOT EXISTS idx_custom_orders_client ON opt_orders(client_id);
CREATE INDEX IF NOT EXISTS idx_custom_clients_status ON opt_clients(status);
SET enable_indexscan = off; -- bonus 
EXPLAIN ANALYZE
WITH joined_data AS (
    SELECT p.product_category, o.order_id
    FROM opt_orders o
    JOIN opt_products p ON o.product_id = p.product_id
    JOIN opt_clients c ON o.client_id = c.id
    WHERE c.status = 'active' AND o.order_date >= DATE '2020-01-01'
),
category_counts AS (
    SELECT product_category, COUNT(order_id) AS total_orders
    FROM joined_data
    GROUP BY product_category
),
ranked_categories AS (
    SELECT 
        product_category,
        ROW_NUMBER() OVER (ORDER BY total_orders DESC) AS rank_desc,
        ROW_NUMBER() OVER (ORDER BY total_orders ASC) AS rank_asc
    FROM category_counts
)
SELECT 
    MAX(product_category) FILTER (WHERE rank_desc = 1) AS top_category,
    MAX(product_category) FILTER (WHERE rank_asc = 1) AS worst_category
FROM ranked_categories;
