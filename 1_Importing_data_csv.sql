CREATE TABLE customers (
    customer_id VARCHAR PRIMARY KEY,
    customer_unique_id VARCHAR,
    customer_zip_code_prefix VARCHAR,
    customer_city VARCHAR,
    customer_state VARCHAR
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR,
    geolocation_lat DECIMAL(10, 4),
    geolocation_lng DECIMAL(10, 4),
    geolocation_city VARCHAR,
    geolocation_state VARCHAR
);

CREATE TABLE orders (
    order_id VARCHAR PRIMARY KEY,
    customer_id VARCHAR,
    order_status VARCHAR,
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE product (
	row_index INT,
    product_id VARCHAR PRIMARY KEY,
    product_category_name VARCHAR,
    product_name_length NUMERIC,
    product_description_length NUMERIC,
    product_photos_qty NUMERIC,
    product_weight_g NUMERIC,
    product_length_cm NUMERIC,
    product_height_cm NUMERIC,
    product_width_cm NUMERIC
);

CREATE TABLE sellers (
    seller_id VARCHAR PRIMARY KEY,
    seller_zip_code_prefix VARCHAR,
    seller_city VARCHAR,
    seller_state VARCHAR
);

CREATE TABLE order_items (
    order_id VARCHAR,
    order_item_id VARCHAR,
    product_id VARCHAR,
    seller_id VARCHAR,
    shipping_limit_date TIMESTAMP,
    price DECIMAL(10, 2),
    freight_value DECIMAL(10, 2),
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE order_payments (
    order_id VARCHAR,
    payment_sequential INT,
    payment_type VARCHAR,
    payment_installments INT,
    payment_value DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE order_reviews (
    review_id VARCHAR,
    order_id VARCHAR,
    review_score INT,
    review_comment_title VARCHAR,
    review_comment_message VARCHAR,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

SET datestyle = 'ISO, MDY';

COPY customers from 'C:\eCommerceDataset\customers_dataset.csv' DELIMITER ',' CSV HEADER;
COPY geolocation from 'C:\eCommerceDataset\geolocation_dataset.csv' DELIMITER ',' CSV HEADER;
COPY orders from 'C:\eCommerceDataset\orders_dataset.csv' DELIMITER ',' CSV HEADER;
COPY product from 'C:\eCommerceDataset\product_dataset.csv' DELIMITER ',' CSV HEADER;
COPY sellers from 'C:\eCommerceDataset\sellers_dataset.csv' DELIMITER ',' CSV HEADER;
COPY order_items from 'C:\eCommerceDataset\order_items_dataset.csv' DELIMITER ',' CSV HEADER;
COPY order_payments from 'C:\eCommerceDataset\order_payments_dataset.csv' DELIMITER ',' CSV HEADER;
COPY order_reviews from 'C:\eCommerceDataset\order_reviews_dataset.csv' DELIMITER ',' CSV HEADER;

ALTER TABLE product DROP COLUMN row_index;

SELECT review_id, COUNT(*)
FROM order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1;

-- menambahkan nomor urut di akhir review_id untuk membuat review_id menjadi unik
UPDATE order_reviews AS o
SET review_id = CONCAT(o.review_id, '_', subquery.rn)
FROM (
    SELECT review_id, ROW_NUMBER() OVER (PARTITION BY review_id ORDER BY review_id) AS rn
    FROM order_reviews
) AS subquery
WHERE o.review_id = subquery.review_id
AND subquery.rn > 1;