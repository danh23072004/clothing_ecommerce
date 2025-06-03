-- Drop and recreate schema
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

SET search_path TO public;

-- Create Location table to store location-related fields
CREATE TABLE Location
(
    id           SERIAL PRIMARY KEY,
    province     VARCHAR(50),
    district     VARCHAR(50),
    commune      VARCHAR(50),
    address      VARCHAR(255),
    housing_type VARCHAR(50)
);

-- Create Cart table
CREATE TABLE Cart
(
    id                 SERIAL PRIMARY KEY,
    number_of_items    INT            DEFAULT 0,
    total_product_cost DECIMAL(10, 2) DEFAULT 0.00
);

-- Create Users table with user_type and references to Location and Cart
CREATE TABLE Users
(
    id            SERIAL PRIMARY KEY,
    is_registered BOOLEAN NOT NULL,
    full_name     VARCHAR(100),
    user_name     VARCHAR(100) UNIQUE,
    email         VARCHAR(100) UNIQUE,
    password      VARCHAR(255),
    phone         VARCHAR(20),
    location_id   INT REFERENCES Location (id),
    cart_id       INT UNIQUE REFERENCES Cart (id)
);

-- Create Discount table
CREATE TABLE Discount
(
    id             SERIAL PRIMARY KEY,
    description    TEXT,
    discount_type  BOOLEAN NOT NULL, -- true for percentage, false for fixed amount
    discount_value INTEGER NOT NULL  -- value of the discount, percentage or fixed amount
);

-- Create Category table with foreign key to Discount
CREATE TABLE Category
(
    id            SERIAL PRIMARY KEY,
    discount_id   INT REFERENCES Discount (id),
    category_name VARCHAR(100) NOT NULL
);

-- Create Store table
CREATE TABLE Store
(
    id              SERIAL PRIMARY KEY,
    store_name      VARCHAR(100) NOT NULL,
    num_of_products INT DEFAULT 0
);

-- Create Product table with foreign keys to Store and Discount
CREATE TABLE Product
(
    id          SERIAL PRIMARY KEY,
    store_id    INT REFERENCES Store (id),
    discount_id INT REFERENCES Discount (id),
    name        VARCHAR(100)   NOT NULL,
    price       DECIMAL(10, 2) NOT NULL,
    size        VARCHAR(20),
    color       VARCHAR(20)
);

-- Create junction table for Category and Product (M:N)
CREATE TABLE CategoryProduct
(
    category_id INT REFERENCES Category (id),
    product_id  INT REFERENCES Product (id),
    PRIMARY KEY (category_id, product_id)
);

-- Create Fee table
CREATE TABLE Fee
(
    id          SERIAL PRIMARY KEY,
    fee_type    BOOLEAN NOT NULL, -- true for shipping fee (1), false for payment fee (0)
    fee_value   INTEGER,          -- Value of the fee, can be percentage or fixed amount
    amount_type BOOLEAN NOT NULL  -- true for percentage (1), false for fixed amount (0)
);

-- Create junction table for Product and Fee (M:N)
CREATE TABLE ProductFee
(
    product_id INT REFERENCES Product (id),
    fee_id     INT REFERENCES Fee (id),
    PRIMARY KEY (product_id, fee_id)
);

-- Create Orders table with relationships to Users and Location, payment_method as BOOLEAN
CREATE TABLE Orders
(
    id                 SERIAL PRIMARY KEY,
    user_id            INT REFERENCES Users (id),
    location_id        INT REFERENCES Location (id),
    date               TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_product_cost DECIMAL(10, 2),
    total_fee_cost     DECIMAL(10, 2),
    payment_method     BOOLEAN, -- true for online payment (1), false for cash (0)
    total_price        DECIMAL(10, 2)
);

-- Create junction table for Orders and Product (M:N) with quantity field
CREATE TABLE OrderProduct
(
    order_id   INT REFERENCES Orders (id),
    product_id INT REFERENCES Product (id),
    quantity   INT NOT NULL DEFAULT 1,
    PRIMARY KEY (order_id, product_id)
);

-- Create base Voucher table with discount_type (removed user_id)
CREATE TABLE Voucher
(
    id            SERIAL PRIMARY KEY,
    is_percentage BOOLEAN NOT NULL, -- (1) for percentage discount, (0) for fixed amount
    value         INTEGER           -- Value of the discount, can be percentage or fixed amount
);

-- Create UserVoucher table to handle many-to-many relationship between Users and Voucher
CREATE TABLE UserVoucher
(
    user_id    INT REFERENCES Users (id),
    voucher_id INT REFERENCES Voucher (id),
    amount     INTEGER, -- Amount of the voucher left for the user
    PRIMARY KEY (user_id, voucher_id)
);

-- Create ProductVoucher table with foreign key to Voucher and Product
CREATE TABLE ProductVoucher
(
    voucher_id INT PRIMARY KEY REFERENCES Voucher (id),
    product_id INT REFERENCES Product (id)
);

-- Create ShippingVoucher table with foreign key to Voucher
CREATE TABLE ShippingVoucher
(
    voucher_id INT PRIMARY KEY REFERENCES Voucher (id)
);

-- Create PaymentVoucher table with foreign key to Voucher
CREATE TABLE PaymentVoucher
(
    voucher_id INT PRIMARY KEY REFERENCES Voucher (id)
);

-- Create junction table to apply Vouchers to Orders
CREATE TABLE OrderVoucher
(
    order_id   INT REFERENCES Orders (id),
    voucher_id INT REFERENCES Voucher (id),
    PRIMARY KEY (order_id, voucher_id)
);

-- Insert mock data with explicit schema qualification

-- Insert into Location (6 entries)
INSERT INTO public.Location (province, district, commune, address, housing_type)
VALUES ('Hanoi', 'Ba Dinh', 'Kim Ma', '123 Kim Ma Street', 'Apartment'),
       ('Ho Chi Minh', 'District 1', 'Ben Thanh', '456 Le Loi Street', 'House'),
       ('Da Nang', 'Hai Chau', 'Thanh Khe', '789 Tran Phu Street', 'Villa'),
       ('Hue', 'Phu Nhuan', 'Thanh Loc', '101 Nguyen Hue Street', 'Townhouse'),
       ('Can Tho', 'Ninh Kieu', 'Cai Khe', '202 Vo Van Tan Street', 'Condo'),
       ('Bac Kan', 'Ba Be', 'Phuc Loc', '73 Tan Hoa 2', 'Private House');

-- Insert into Cart (11 entries with default values)
INSERT INTO public.Cart (number_of_items, total_product_cost)
SELECT 0, 0.00
FROM GENERATE_SERIES(1, 11);

-- Insert into Users (10 entries: 6 registered, 5 guests)
INSERT INTO public.Users (is_registered, full_name, user_name, email, password, phone, location_id, cart_id)
VALUES (TRUE, 'John Doe', 'johndoe', 'john@example.com', 'password123', '0123456789', 1, 1),
       (TRUE, 'Jane Smith', 'janesmith', 'jane@example.com', 'password456', '0987654321', 2, 2),
       (TRUE, 'Alice Johnson', 'alicejohnson', 'alice@example.com', 'password789', '0112233445', 3, 3),
       (TRUE, 'Bob Brown', 'bobbrown', 'bob@example.com', 'passwordabc', '0556677889', 4, 4),
       (TRUE, 'Charlie Davis', 'charliedavis', 'charlie@example.com', 'passworddef', '0998877665', 5, 5),
       (TRUE, 'Nguyen Minh Hieu', 'minhhieu', 'minhhieu@example.com', 'passwordminh_hieu', '0123456780', 6, 6),
       (FALSE, 'Nguyen Van An', 'Guest1', NULL, NULL, NULL, NULL, 7),
       (FALSE, 'Tran Thi Bich', 'Guest2', NULL, NULL, NULL, NULL, 8),
       (FALSE, 'Le Hoang Long', 'Guest3', NULL, NULL, NULL, NULL, 9),
       (FALSE, 'Pham Thi Mai', 'Guest4', NULL, NULL, NULL, NULL, 10),
       (FALSE, 'Hoang Van Nam', 'Guest5', NULL, NULL, NULL, NULL, 11);

-- Insert into Discount (6 entries with discount_type and discount_value)
INSERT INTO public.Discount (description, discount_type, discount_value)
VALUES ('10% off on Clothing', TRUE, 10),
       ('5% off on Accessories', TRUE, 5),
       ('15% off on Shoes', TRUE, 15),
       ('20% off on Bags', TRUE, 20),
       ('Special discount on T-Shirt', FALSE, 50000),
       ('Discount on Jeans', FALSE, 100000);

-- Insert into Category (4 entries with discount_id 1 to 4)
INSERT INTO public.Category (discount_id, category_name)
VALUES (1, 'Clothing'),
       (2, 'Accessories'),
       (3, 'Shoes'),
       (4, 'Bags');

-- Insert into Store (3 entries)
INSERT INTO public.Store (store_name, num_of_products)
VALUES ('Fashion Store', 0),
       ('Accessory Shop', 0),
       ('Shoe Outlet', 0);

-- Insert into Product (20 entries with discount_id mapped from original DiscountEntity)
INSERT INTO public.Product (store_id, discount_id, name, price, size, color)
VALUES (1, 5, 'Áo thun', 499750.00, 'M', 'Blue'),
       (1, 6, 'Quần jeans', 749750.00, 'L', 'Black'),
       (1, NULL, 'Áo khoác', 1249750.00, 'XL', 'Red'),
       (1, NULL, 'Áo len', 999750.00, 'S', 'Green'),
       (2, NULL, 'Mũ', 249750.00, 'One Size', 'Black'),
       (2, NULL, 'Khăn quàng', 374750.00, 'One Size', 'White'),
       (2, NULL, 'Găng tay', 499750.00, 'M', 'Gray'),
       (3, NULL, 'Giày thể thao', 1499750.00, '42', 'White'),
       (3, 1, 'Giày bốt', 1999750.00, '40', 'Brown'),
       (3, 2, 'Dép', 749750.00, '38', 'Blue'),
       (1, 3, 'Áo sơ mi nam', 250000.00, 'M', 'White'),
       (1, 4, 'Áo thun nữ', 150000.00, 'S', 'Pink'),
       (1, 5, 'Quần tây nam', 350000.00, 'L', 'Black'),
       (1, 6, 'Áo khoác gió', 450000.00, 'XL', 'Blue'),
       (2, NULL, 'Mũ lưỡi trai', 100000.00, 'One Size', 'Red'),
       (2, NULL, 'Khăn choàng cổ', 120000.00, 'One Size', 'Gray'),
       (2, NULL, 'Găng tay len', 80000.00, 'M', 'Brown'),
       (3, NULL, 'Giày thể thao', 600000.00, '41', 'White'),
       (3, NULL, 'Giày cao gót', 400000.00, '37', 'Black'),
       (3, NULL, 'Dép sandal', 200000.00, '39', 'Yellow');

-- Update Store num_of_products
WITH product_counts AS (SELECT store_id, COUNT(*) AS cnt
                        FROM Product
                        GROUP BY store_id)
UPDATE Store
SET num_of_products = COALESCE(product_counts.cnt, 0)
FROM product_counts
WHERE Store.id = product_counts.store_id;

-- Insert into CategoryProduct
INSERT INTO public.CategoryProduct (category_id, product_id)
VALUES (1, 1),
       (1, 2),
       (1, 3),
       (1, 4),
       (2, 5),
       (2, 6),
       (2, 7),
       (3, 8),
       (3, 9),
       (3, 10),
       (1, 11),
       (1, 12),
       (1, 13),
       (1, 14),
       (2, 15),
       (2, 16),
       (2, 17),
       (3, 18),
       (3, 19),
       (3, 20);

-- Insert into Fee (3 entries, updated to include fee_type, fee_value, and amount_type)
INSERT INTO public.Fee (fee_type, fee_value, amount_type)
VALUES (TRUE, 5, TRUE),   -- 5% shipping fee (percentage-based)
       (TRUE, 50000, FALSE), -- 50,000 VND shipping fee (fixed amount)
       (FALSE, 3, TRUE);  -- 3% payment fee (percentage-based)

-- Insert into ProductFee (associating products with fees)
INSERT INTO public.ProductFee (product_id, fee_id)
VALUES (1, 1), -- T-Shirt with shipping fee (5%)
       (2, 1), -- Jeans with shipping fee (5%)
       (3, 2), -- Jacket with shipping fee (50,000 VND)
       (4, 2), -- Sweater with shipping fee (50,000 VND)
       (5, 3), -- Hat with payment fee (3%)
       (6, 3), -- Scarf with payment fee (3%)
       (7, 3), -- Gloves with payment fee (3%)
       (8, 1), -- Sneakers with shipping fee (5%)
       (9, 2), -- Boots with shipping fee (50,000 VND)
       (10, 3); -- Sandals with payment fee (3%)

-- Insert into Orders (6 entries with payment_method as boolean)
INSERT INTO public.Orders (user_id, location_id, date, total_product_cost, total_fee_cost, payment_method, total_price)
VALUES (1, 1, '2023-01-01 12:00:00', 19.99, 5.00, TRUE, 24.99),
       (2, 2, '2023-01-02 13:00:00', 29.99, 5.00, FALSE, 34.99),
       (3, 3, '2023-01-03 14:00:00', 49.99, 5.00, TRUE, 54.99),
       (4, 4, '2023-01-04 15:00:00', 39.99, 5.00, FALSE, 44.99),
       (5, 5, '2023-01-05 16:00:00', 59.99, 5.00, TRUE, 64.99),
       (6, 6, '2024-09-06 17:00:00', 79.99, 5.00, FALSE, 84.99);

-- Insert mock orders for January to May 2025
INSERT INTO public.Orders (user_id, location_id, date, total_product_cost, total_fee_cost, payment_method, total_price)
VALUES
    -- January 2025
    (1, 1, '2025-01-10 10:00:00', 100.00, 10.00, TRUE, 110.00),
    (2, 2, '2025-01-15 11:00:00', 200.00, 15.00, FALSE, 215.00),
    (3, 3, '2025-01-20 12:00:00', 150.00, 12.00, TRUE, 162.00),
    -- February 2025
    (4, 4, '2025-02-05 13:00:00', 250.00, 20.00, FALSE, 270.00),
    (5, 5, '2025-02-10 14:00:00', 300.00, 25.00, TRUE, 325.00),
    (1, 1, '2025-02-15 15:00:00', 180.00, 15.00, TRUE, 195.00),
    -- March 2025
    (2, 2, '2025-03-01 16:00:00', 120.00, 10.00, FALSE, 130.00),
    (3, 3, '2025-03-15 17:00:00', 220.00, 18.00, TRUE, 238.00),
    (4, 4, '2025-03-20 18:00:00', 160.00, 12.00, FALSE, 172.00),
    -- April 2025
    (5, 5, '2025-04-05 19:00:00', 280.00, 22.00, TRUE, 302.00),
    (1, 1, '2025-04-10 20:00:00', 190.00, 15.00, FALSE, 205.00),
    -- May 2025
    (2, 2, '2025-05-01 21:00:00', 130.00, 10.00, TRUE, 140.00),
    (3, 3, '2025-05-10 22:00:00', 240.00, 20.00, FALSE, 260.00),
    (4, 4, '2025-05-15 23:00:00', 170.00, 15.00, TRUE, 185.00);

-- Insert mock orders for May 29, 2024, to November 29, 2024
INSERT INTO public.Orders (user_id, location_id, date, total_product_cost, total_fee_cost, payment_method, total_price)
VALUES
    -- June 2024
    (1, 1, '2024-06-10 10:00:00', 80.00, 8.00, TRUE, 88.00),
    (2, 2, '2024-06-15 11:00:00', 150.00, 12.00, FALSE, 162.00),
    -- July 2024
    (3, 3, '2024-07-01 12:00:00', 120.00, 10.00, TRUE, 130.00),
    (4, 4, '2024-07-10 13:00:00', 200.00, 15.00, FALSE, 215.00),
    -- August 2024
    (5, 5, '2024-08-05 14:00:00', 250.00, 20.00, TRUE, 270.00),
    (1, 1, '2024-08-15 15:00:00', 90.00, 9.00, TRUE, 99.00),
    -- September 2024
    (2, 2, '2024-09-01 16:00:00', 110.00, 10.00, FALSE, 120.00),
    (3, 3, '2024-09-10 17:00:00', 180.00, 15.00, TRUE, 195.00),
    -- October 2024
    (4, 4, '2024-10-05 18:00:00', 160.00, 12.00, FALSE, 172.00),
    (5, 5, '2024-10-15 19:00:00', 220.00, 18.00, TRUE, 238.00),
    -- November 2024 (before Nov 29, 2024, 22:16:00)
    (1, 1, '2024-11-01 20:00:00', 100.00, 10.00, TRUE, 110.00),
    (2, 2, '2024-11-10 21:00:00', 130.00, 10.00, FALSE, 140.00);

-- Insert into OrderProduct (associating orders with products, with quantity)
INSERT INTO public.OrderProduct (order_id, product_id, quantity)
VALUES (1, 1, 1), -- T-Shirt
       (2, 2, 1), -- Jeans
       (3, 3, 1), -- Jacket
       (4, 4, 1), -- Sweater
       (5, 8, 1); -- Sneakers

-- Insert into Voucher (5 entries for registered users, updated to include value)
INSERT INTO public.Voucher (is_percentage, value)
VALUES (TRUE, 10),      -- 10% product discount
       (FALSE, 50000),  -- 50,000 VND shipping discount
       (TRUE, 5),       -- 5% payment discount
       (FALSE, 100000), -- 100,000 VND product discount
       (TRUE, 15);      -- 15% product discount

-- Insert into UserVoucher (sample data for many-to-many relationship)
INSERT INTO public.UserVoucher (user_id, voucher_id, amount)
VALUES (1, 1, 3), -- John Doe has voucher 1
       (1, 2, 3), -- John Doe has voucher 2
       (2, 3, 3), -- Jane Smith has voucher 3
       (3, 4, 3), -- Alice Johnson has voucher 4
       (4, 5, 3), -- Bob Brown has voucher 5
       (5, 1, 3), -- Charlie Davis has voucher 1
       (6, 2, 3); -- Nguyen Minh Hieu has voucher 2

-- Insert into ProductVoucher (2 entries, updated to reference products)
INSERT INTO public.ProductVoucher (voucher_id, product_id)
VALUES (1, 1), -- Voucher 1 for T-Shirt (product 1)
       (4, 2); -- Voucher 4 for Jeans (product 2)

-- Insert into ShippingVoucher (1 entry)
INSERT INTO public.ShippingVoucher (voucher_id)
VALUES (2); -- Voucher 2 for shipping discount (50,000 VND)

-- Insert into PaymentVoucher (1 entry)
INSERT INTO public.PaymentVoucher (voucher_id)
VALUES (3); -- Voucher 3 for payment discount (5%)

-- Insert into OrderVoucher (3 entries)
INSERT INTO public.OrderVoucher (order_id, voucher_id)
VALUES (1, 1), -- Order 1 uses product voucher (10% on T-Shirt)
       (2, 2), -- Order 2 uses shipping voucher (50,000 VND)
       (3, 3); -- Order 3 uses payment voucher (5%)