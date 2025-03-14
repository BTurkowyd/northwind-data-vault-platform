-- Enable UUID generation for PostgreSQL (if not enabled)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Insert 100 Customers
INSERT INTO customers (customer_id, name, email, created_at)
SELECT
    uuid_generate_v4(),
    'Customer_' || i,
    'customer' || i || '@example.com',
    NOW() - (random() * interval '365 days')
FROM generate_series(1, 100) i;

-- Insert 100 Products
INSERT INTO products (product_id, name, category, price, created_at)
SELECT
    uuid_generate_v4(),
    'Product_' || i,
    CASE WHEN i % 3 = 0 THEN 'Electronics'
         WHEN i % 3 = 1 THEN 'Apparel'
         ELSE 'Home & Kitchen' END,
    round((random() * 200 + 10)::numeric, 2), -- Price between $10 and $210
    NOW() - (random() * interval '365 days')
FROM generate_series(1, 100) i;

-- Insert 10,000 Orders
INSERT INTO orders (order_id, customer_id, total_amount, status, created_at)
SELECT
    uuid_generate_v4(),
    c.customer_id, -- Randomly selected customer
    0.00 AS total_amount, -- Initialize total_amount to 0
    CASE
        WHEN random() < 0.7 THEN 'Shipped'
        WHEN random() < 0.9 THEN 'Delivered'
        ELSE 'Pending'
    END, -- Random order status
    NOW() - (random() * interval '180 days')
FROM generate_series(1, 10000) g
JOIN (
    SELECT customer_id FROM customers ORDER BY random() LIMIT 10000
) c ON true;

-- Insert 100,00 Order Items
INSERT INTO order_items (item_id, order_id, product_id, quantity, price)
SELECT
    uuid_generate_v4(), -- Generate unique UUID for each item
    o.order_id, -- Random order_id
    p.product_id, -- Random product_id
    q.quantity, -- Random quantity
    p.price * q.quantity AS price -- Compute price based on quantity
FROM (
    -- Generate 100,000 rows and assign each row a random order_id
    SELECT order_id, ROW_NUMBER() OVER () AS rn
    FROM orders
    ORDER BY random()
    LIMIT 100000
) o
JOIN (
    -- Assign each row a random product_id
    SELECT product_id, price, ROW_NUMBER() OVER () AS rn
    FROM products
    ORDER BY random()
) p ON (o.rn % 100) = (p.rn % 100) -- Ensures products are randomly distributed
JOIN (
    -- Generate random quantity for each row
    SELECT generate_series(1, 100000) AS id, floor(random() * 5 + 1) AS quantity
) q ON q.id = o.rn;

-- Insert total_amount in orders table based on order_items
UPDATE orders o
SET total_amount = (
    SELECT COALESCE(SUM(oi.price), 0)
    FROM order_items oi
    WHERE oi.order_id = o.order_id
);