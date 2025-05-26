DROP SCHEMA clothing_ecommerce CASCADE;
CREATE SCHEMA clothing_ecommerce;

SET search_path TO clothing_ecommerce;


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
    user_type VARCHAR(20) NOT NULL CHECK (user_type IN ('guest', 'registered')),
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
    quantity INT DEFAULT 0,
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

-- Create Orders table with relationships to Users and Location
CREATE TABLE Orders (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(id),
    location_id INT REFERENCES Location(id),
    date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_product_cost DECIMAL(10, 2),
    total_shipping_cost DECIMAL(10, 2),
    payment_method VARCHAR(50),
    total_price DECIMAL(10, 2)
);

-- Create junction table for Orders and Product (M:N)
CREATE TABLE OrderProduct (
    order_id INT REFERENCES Orders(id),
    product_id INT REFERENCES Product(id),
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
    discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('percentage', 'fixed'))
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