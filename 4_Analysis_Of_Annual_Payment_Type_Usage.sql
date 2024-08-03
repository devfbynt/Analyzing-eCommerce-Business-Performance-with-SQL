-- 1. Menampilkan jumlah penggunaan masing-masing tipe pembayaran secara all time diurutkan dari yang terfavorit
CREATE VIEW payment_type_usage_view AS
SELECT 
    payment_type,
    COUNT(*) AS usage_count
FROM 
    order_payments
GROUP BY 
    payment_type
ORDER BY 
    usage_count DESC;

-- 2. Menampilkan detail informasi jumlah penggunaan masing-masing tipe pembayaran untuk setiap tahun
CREATE VIEW yearly_payment_type_usage_view AS
SELECT 
    DATE_PART('year', o.order_purchase_timestamp) AS year,
    p.payment_type,
    COUNT(*) AS usage_count
FROM 
    order_payments p
JOIN 
    orders o ON p.order_id = o.order_id
GROUP BY 
    year, p.payment_type
ORDER BY 
    year, usage_count DESC;