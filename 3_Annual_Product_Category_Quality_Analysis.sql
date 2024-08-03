-- 1. Membuat tabel yang berisi informasi pendapatan/revenue perusahaan total untuk masing-masing tahun 
CREATE TABLE yearly_revenue (
    year INT,
    total_revenue DECIMAL(15, 2)
);

INSERT INTO yearly_revenue (year, total_revenue)
SELECT 
    DATE_PART('year', o.order_approved_at) AS year,
    SUM(oi.price + oi.freight_value) AS total_revenue
FROM 
    order_items oi
JOIN 
    orders o ON oi.order_id = o.order_id
WHERE 
    o.order_status = 'delivered'
    AND o.order_approved_at IS NOT NULL
GROUP BY 
    DATE_PART('year', o.order_approved_at)
ORDER BY 
    year;

-- 2. Membuat tabel yang berisi informasi jumlah cancel order total untuk masing-masing tahun
CREATE TABLE yearly_cancel_orders (
    year INT,
    total_cancel_orders INT
);

INSERT INTO yearly_cancel_orders (year, total_cancel_orders)
SELECT 
    DATE_PART('year', o.order_purchase_timestamp) AS year,
    COUNT(*) AS total_cancel_orders
FROM 
    orders o
WHERE 
    o.order_status = 'canceled'
GROUP BY 
    year
ORDER BY 
    year;

-- 3. Membuat tabel yang berisi nama kategori produk yang memberikan pendapatan total tertinggi untuk masing-masing tahun
CREATE TABLE top_category_revenue_per_year (
	year INT,
	product_category_name VARCHAR,
	total_revenue DECIMAL(15, 2)
);

INSERT INTO top_category_revenue_per_year (year, product_category_name, total_revenue)
SELECT 
    year,
    product_category_name,
    total_revenue
FROM (
    SELECT 
        DATE_PART('year', o.order_approved_at) AS year,
        p.product_category_name,
        SUM(oi.price + oi.freight_value) AS total_revenue,
        ROW_NUMBER() OVER(PARTITION BY DATE_PART('year', o.order_approved_at) ORDER BY SUM(oi.price + oi.freight_value) DESC) AS rank
    FROM 
        order_items oi
    JOIN 
        orders o ON oi.order_id = o.order_id
    JOIN 
        product p ON oi.product_id = p.product_id
    WHERE 
        o.order_status = 'delivered'
		AND o.order_approved_at IS NOT NULL
    GROUP BY 
        year, p.product_category_name
) AS yearly_category_revenue
WHERE 
    rank = 1
ORDER BY 
    year;

-- 4. Membuat tabel yang berisi nama kategori produk yang memiliki jumlah cancel order terbanyak untuk masing-masing tahun
CREATE TABLE top_category_cancel_orders_per_year (
    year INT,
    product_category_name VARCHAR,
    total_cancel_orders INT
);

INSERT INTO top_category_cancel_orders_per_year (year, product_category_name, total_cancel_orders)
SELECT 
    year,
    product_category_name,
    total_cancel_orders
FROM (
    SELECT 
        DATE_PART('year', o.order_approved_at) AS year,
        p.product_category_name,
        COUNT(*) AS total_cancel_orders,
        ROW_NUMBER() OVER(PARTITION BY DATE_PART('year', o.order_approved_at) ORDER BY COUNT(*) DESC) AS rank
    FROM 
        orders o
    JOIN 
        order_items oi ON o.order_id = oi.order_id
    JOIN 
        product p ON oi.product_id = p.product_id
    WHERE 
        o.order_status = 'canceled'
    GROUP BY 
        year, p.product_category_name
) AS yearly_category_cancel_orders
WHERE 
    rank = 1
ORDER BY 
    year;

-- 5. Menggabungkan informasi-informasi yang telah didapatkan ke dalam satu tampilan tabel
CREATE VIEW yearly_summary AS
SELECT 
    yr.year,
    COALESCE(yr.total_revenue, 0) AS total_revenue,
    COALESCE(yco.total_cancel_orders, 0) AS total_cancel_orders,
    tr.product_category_name AS top_revenue_category,
    co.product_category_name AS top_cancel_category
FROM 
    yearly_revenue yr
LEFT JOIN 
    yearly_cancel_orders yco ON yr.year = yco.year
LEFT JOIN 
    top_category_revenue_per_year tr ON yr.year = tr.year
LEFT JOIN 
    top_category_cancel_orders_per_year co ON yr.year = co.year;