-- Drop and recreate schema
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;

SET search_path TO public;

-- Create Location table to store location-related fields
CREATE TABLE Location (
    id SERIAL PRIMARY KEY,
    province VARCHAR(50),
    district VARCHAR(50),
    commune VARCHAR(50),
    address VARCHAR(255),
    housing_type VARCHAR(50)
);

-- Create Cart table
CREATE TABLE Cart (
    id SERIAL PRIMARY KEY,
    number_of_items INT DEFAULT 0,
    total_product_cost DECIMAL(10, 2) DEFAULT 0.00
);

-- Create Users table with user_type and references to Location and Cart
CREATE TABLE Users (
    id SERIAL PRIMARY KEY,
    is_registered BOOLEAN NOT NULL,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    password VARCHAR(255),
    phone VARCHAR(20),
    location_id INT REFERENCES Location(id),
    cart_id INT UNIQUE REFERENCES Cart(id)
);

-- Create DiscountEntity table
CREATE TABLE DiscountEntity (
    id SERIAL PRIMARY KEY
);

-- Create Category table with foreign key to DiscountEntity
CREATE TABLE Category (
    id SERIAL PRIMARY KEY,
    discount_entity_id INT UNIQUE REFERENCES DiscountEntity(id),
    category_name VARCHAR(100) NOT NULL
);

-- Create Store table
CREATE TABLE Store (
    id SERIAL PRIMARY KEY,
    store_name VARCHAR(100) NOT NULL,
    num_of_products INT DEFAULT 0
);

-- Create Product table with foreign keys to Store and DiscountEntity
CREATE TABLE Product (
    id SERIAL PRIMARY KEY,
    store_id INT REFERENCES Store(id),
    discount_entity_id INT UNIQUE REFERENCES DiscountEntity(id),
    name VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    size VARCHAR(20),
    color VARCHAR(20)
);

-- Create junction table for Category and Product (M:N)
CREATE TABLE CategoryProduct (
    category_id INT REFERENCES Category(id),
    product_id INT REFERENCES Product(id),
    PRIMARY KEY (category_id, product_id)
);

-- Create Fee table
CREATE TABLE Fee (
    id SERIAL PRIMARY KEY
);

-- Create junction table for Product and Fee (M:N)
CREATE TABLE ProductFee (
    product_id INT REFERENCES Product(id),
    fee_id INT REFERENCES Fee(id),
    PRIMARY KEY (product_id, fee_id)
);

-- Create Orders table with relationships to Users and Location, payment_method as BOOLEAN
CREATE TABLE Orders (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(id),
    location_id INT REFERENCES Location(id),
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_product_cost DECIMAL(10, 2),
    total_shipping_cost DECIMAL(10, 2),
    payment_method BOOLEAN,  -- true for online payment (1), false for cash (0)
    total_price DECIMAL(10, 2)
);

-- Create junction table for Orders and Product (M:N) with quantity field
CREATE TABLE OrderProduct (
    order_id INT REFERENCES Orders(id),
    product_id INT REFERENCES Product(id),
    quantity INT NOT NULL DEFAULT 1,
    PRIMARY KEY (order_id, product_id)
);

-- Create Discount table with reference to DiscountEntity
CREATE TABLE Discount (
    id SERIAL PRIMARY KEY,
    discount_entity_id INT REFERENCES DiscountEntity(id),
    description TEXT
);

-- Create base Voucher table with discount_type
CREATE TABLE Voucher (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(id),
    is_percentage BOOLEAN NOT NULL
);

-- Create ProductVoucher table with foreign key to Voucher and DiscountEntity
CREATE TABLE ProductVoucher (
    voucher_id INT PRIMARY KEY REFERENCES Voucher(id),
    discount_entity_id INT REFERENCES DiscountEntity(id)
);

-- Create ShippingVoucher table with foreign key to Voucher
CREATE TABLE ShippingVoucher (
    voucher_id INT PRIMARY KEY REFERENCES Voucher(id)
);

-- Create PaymentVoucher table with foreign key to Voucher
CREATE TABLE PaymentVoucher (
    voucher_id INT PRIMARY KEY REFERENCES Voucher(id)
);

-- Create junction table to apply Vouchers to Orders
CREATE TABLE OrderVoucher (
    order_id INT REFERENCES Orders(id),
    voucher_id INT REFERENCES Voucher(id),
    PRIMARY KEY (order_id, voucher_id)
);

-- Insert mock data with explicit schema qualification

-- Insert into Location (5 entries)
INSERT INTO public.Location (province, district, commune, address, housing_type) VALUES
('Hanoi', 'Ba Dinh', 'Kim Ma', '123 Kim Ma Street', 'Apartment'),
('Ho Chi Minh', 'District 1', 'Ben Thanh', '456 Le Loi Street', 'House'),
('Da Nang', 'Hai Chau', 'Thanh Khe', '789 Tran Phu Street', 'Villa'),
('Hue', 'Phu Nhuan', 'Thanh Loc', '101 Nguyen Hue Street', 'Townhouse'),
('Can Tho', 'Ninh Kieu', 'Cai Khe', '202 Vo Van Tan Street', 'Condo');

-- Insert into Cart (10 entries, one per user)
INSERT INTO public.Cart (number_of_items, total_product_cost) VALUES
(0, 0.00), (0, 0.00), (0, 0.00), (0, 0.00), (0, 0.00),
(0, 0.00), (0, 0.00), (0, 0.00), (0, 0.00), (0, 0.00);

-- Insert into Users (10 entries: 5 registered, 5 guests)
INSERT INTO public.Users (is_registered, name, email, password, phone, location_id, cart_id) VALUES
(TRUE, 'John Doe', 'john@example.com', 'password123', '0123456789', 1, 1),
(TRUE, 'Jane Smith', 'jane@example.com', 'password456', '0987654321', 2, 2),
(TRUE, 'Alice Johnson', 'alice@example.com', 'password789', '0112233445', 3, 3),
(TRUE, 'Bob Brown', 'bob@example.com', 'passwordabc', '0556677889', 4, 4),
(TRUE, 'Charlie Davis', 'charlie@example.com', 'passworddef', '0998877665', 5, 5),
(FALSE, 'Guest1', NULL, NULL, NULL, NULL, 6),
(FALSE, 'Guest2', NULL, NULL, NULL, NULL, 7),
(FALSE, 'Guest3', NULL, NULL, NULL, NULL, 8),
(FALSE, 'Guest4', NULL, NULL, NULL, NULL, 9),
(FALSE, 'Guest5', NULL, NULL, NULL, NULL, 10);

-- Insert into DiscountEntity (14 entries to support categories and products)
DO $$
BEGIN
    FOR i IN 1..14 LOOP
        INSERT INTO public.DiscountEntity DEFAULT VALUES;
    END LOOP;
END $$;

-- Insert into Category (4 entries with discount_entity_id 1 to 4)
INSERT INTO public.Category (discount_entity_id, category_name) VALUES
(1, 'Clothing'),
(2, 'Accessories'),
(3, 'Shoes'),
(4, 'Bags');

-- Insert into Store (3 entries)
INSERT INTO public.Store (store_name, num_of_products) VALUES
('Fashion Store', 0),
('Accessory Shop', 0),
('Shoe Outlet', 0);

-- Insert into Product (10 entries with discount_entity_id 5 to 14)
INSERT INTO public.Product (store_id, discount_entity_id, name, price, size, color) VALUES
(1, 5, 'T-Shirt', 19.99, 'M', 'Blue'),
(1, 6, 'Jeans', 29.99, 'L', 'Black'),
(1, 7, 'Jacket', 49.99, 'XL', 'Red'),
(1, 8, 'Sweater', 39.99, 'S', 'Green'),
(2, 9, 'Hat', 9.99, 'One Size', 'Black'),
(2, 10, 'Scarf', 14.99, 'One Size', 'White'),
(2, 11, 'Gloves', 19.99, 'M', 'Gray'),
(3, 12, 'Sneakers', 59.99, '42', 'White'),
(3, 13, 'Boots', 79.99, '40', 'Brown'),
(3, 14, 'Sandals', 29.99, '38', 'Blue');

-- Insert into CategoryProduct (associating products with categories)
INSERT INTO public.CategoryProduct (category_id, product_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), -- Clothing
(2, 5), (2, 6), (2, 7), -- Accessories
(3, 8), (3, 9), (3, 10); -- Shoes

-- Insert into Fee (3 entries)
INSERT INTO public.Fee (id) VALUES
(1), (2), (3);

-- Insert into ProductFee (associating products with fees)
INSERT INTO public.ProductFee (product_id, fee_id) VALUES
(1, 1), (2, 1), (3, 2), (4, 2), (5, 3),
(6, 3), (7, 3), (8, 1), (9, 2), (10, 3);

-- Insert into Orders (5 entries with payment_method as boolean)
INSERT INTO public.Orders (user_id, location_id, date, total_product_cost, total_shipping_cost, payment_method, total_price) VALUES
(1, 1, '2023-01-01 12:00:00', 19.99, 5.00, true, 24.99),   -- true: online payment
(2, 2, '2023-01-02 13:00:00', 29.99, 5.00, false, 34.99),  -- false: cash
(3, 3, '2023-01-03 14:00:00', 49.99, 5.00, true, 54.99),
(4, 4, '2023-01-04 15:00:00', 39.99, 5.00, false, 44.99),
(5, 5, '2023-01-05 16:00:00', 59.99, 5.00, true, 64.99);

-- Insert into OrderProduct (associating orders with products, with quantity)
INSERT INTO public.OrderProduct (order_id, product_id, quantity) VALUES
(1, 1, 1), -- T-Shirt
(2, 2, 1), -- Jeans
(3, 3, 1), -- Jacket
(4, 4, 1), -- Sweater
(5, 8, 1); -- Sneakers

-- Insert into Discount (6 entries for some DiscountEntity)
INSERT INTO public.Discount (discount_entity_id, description) VALUES
(1, '10% off on Clothing'),
(2, '5% off on Accessories'),
(3, '15% off on Shoes'),
(4, '20% off on Bags'),
(5, 'Special discount on T-Shirt'),
(6, 'Discount on Jeans');

-- Insert into Voucher (5 entries for registered users)
INSERT INTO public.Voucher (user_id, is_percentage) VALUES
(1, TRUE),
(2, FALSE),
(3, TRUE),
(4, FALSE),
(5, TRUE);

-- Insert into ProductVoucher (1 entry)
INSERT INTO public.ProductVoucher (voucher_id, discount_entity_id) VALUES
(1, 5); -- Voucher for T-Shirt discount

-- Insert into ShippingVoucher (1 entry)
INSERT INTO public.ShippingVoucher (voucher_id) VALUES
(2);

-- Insert into PaymentVoucher (1 entry)
INSERT INTO public.PaymentVoucher (voucher_id) VALUES
(3);

-- Insert into OrderVoucher (3 entries)
INSERT INTO public.OrderVoucher (order_id, voucher_id) VALUES
(1, 1), -- Order 1 uses product voucher
(2, 2), -- Order 2 uses shipping voucher
(3, 3); -- Order 3 uses payment voucher