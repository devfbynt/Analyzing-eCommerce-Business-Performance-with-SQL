-- 1. Menampilkan rata-rata jumlah customer aktif bulanan (monthly active user) untuk setiap tahun
WITH monthly_active_users AS (
    SELECT
        DATE_PART('year', order_purchase_timestamp) AS tahun,
        DATE_PART('month', order_purchase_timestamp) AS bulan,
        COUNT(DISTINCT customer_id) AS jumlah_customer_aktif
    FROM
        orders
    GROUP BY
        tahun, bulan
),
average_monthly_active_users AS (
    SELECT
        tahun,
        AVG(jumlah_customer_aktif) AS rata_rata_customer_aktif_bulanan
    FROM
        monthly_active_users
    GROUP BY
        tahun
),
-- 2. Menampilkan jumlah customer baru pada masing-masing tahun
first_orders AS (
    SELECT
        customer_id,
        MIN(order_purchase_timestamp) AS first_order_date
    FROM
        orders
    GROUP BY
        customer_id
),
new_customers AS (
    SELECT
        DATE_PART('year', fo.first_order_date) AS tahun,
        COUNT(*) AS jumlah_customer_baru
    FROM
        first_orders fo
    GROUP BY
        tahun
),
-- 3. Menampilkan jumlah customer yang melakukan pembelian lebih dari satu kali (repeat order) pada masing-masing tahun
customer_repeat_orders AS (
    SELECT
        customer_id,
        DATE_PART('year', order_purchase_timestamp) AS tahun,
        COUNT(*) AS jumlah_order
    FROM
        orders
    GROUP BY
        customer_id, tahun
    HAVING
        COUNT(*) > 1
),
repeat_customers AS (
    SELECT
        tahun,
        COUNT(DISTINCT customer_id) AS jumlah_customer_repeat_order
    FROM
        customer_repeat_orders
    GROUP BY
        tahun
),
-- 4. Menampilkan rata-rata jumlah order yang dilakukan customer untuk masing-masing tahun
customer_order_count AS (
    SELECT
        customer_id,
        DATE_PART('year', order_purchase_timestamp) AS tahun,
        COUNT(*) AS jumlah_order
    FROM
        orders
    GROUP BY
        customer_id, tahun
),
average_order_per_customer AS (
    SELECT
        tahun,
        AVG(jumlah_order) AS rata_rata_order_per_customer
    FROM
        customer_order_count
    GROUP BY
        tahun
)
-- 5. Menggabungkan ketiga metrik yang telah berhasil ditampilkan menjadi satu tampilan tabel
SELECT
    COALESCE(a.tahun, n.tahun, r.tahun, o.tahun) AS tahun,
    a.rata_rata_customer_aktif_bulanan,
    n.jumlah_customer_baru,
    r.jumlah_customer_repeat_order,
    o.rata_rata_order_per_customer
FROM
    average_monthly_active_users a
FULL JOIN
    new_customers n ON a.tahun = n.tahun
FULL JOIN
    repeat_customers r ON a.tahun = r.tahun
FULL JOIN
    average_order_per_customer o ON a.tahun = o.tahun
ORDER BY
    tahun;