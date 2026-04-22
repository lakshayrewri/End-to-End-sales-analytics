CREATE TABLE orders (
    order_id INT,
    order_date DATE,
    customer_id INT,
    product_id INT,
    sales DECIMAL,
    quantity INT,
    profit DECIMAL,
    profit_margin DECIMAL,
    risk_level VARCHAR(20)
);

SELECT * FROM orders;

CREATE TABLE customers (
    customer_id INT,
    customer_name VARCHAR(100),
    region VARCHAR(50),
    segment VARCHAR(50)
);

SELECT * FROM customers;

CREATE TABLE products (
    product_id INT,
    product_name VARCHAR(100),
    category VARCHAR(50),
    cost DECIMAL
);

SELECT * FROM products;

