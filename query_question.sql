-- Câu b)

SET search_path TO public;


-- INSERT INTO public.new_location (province, district, commune, address, housing_type)
-- VALUES ('Bắc Kạn', 'Ba Bể', 'Phúc Lộc', '73 tân hòa 2', 'nhà riêng');

-- INSERT INTO public.Users (is_registered, name, email, password, phone, location_id, cart_id)
-- VALUES (FALSE, 'assessment', 'gu@gmail.com', NULL, '328355333', NULL, NULL);

-- INSERT INTO public.Product (store_id, discount_entity_id, name, price, size, color)
-- VALUES (3, NULL, 'KAPPA Women''s Sneakers', 980000.00, '36', 'yellow');

-- INSERT INTO public.CategoryProduct (category_id, product_id)
-- VALUES (3, (SELECT id FROM new_product));

-- INSERT INTO 

WITH new_location AS (
    INSERT INTO public.Location (province, district, commune, address, housing_type)
    VALUES ('Bắc Kạn', 'Ba Bể', 'Phúc Lộc', '73 tân hòa 2', 'nhà riêng')
    RETURNING id
),
new_user AS (
    INSERT INTO public.Users (is_registered, name, email, password, phone, location_id, cart_id)
    VALUES (FALSE, 'assessment', 'gu@gmail.com', NULL, '328355333', NULL, NULL)
    RETURNING id
),
new_product AS (
    INSERT INTO public.Product (store_id, discount_entity_id, name, price, size, color)
    VALUES (3, NULL, 'KAPPA Women''s Sneakers', 980000.00, '36', 'yellow')
    RETURNING id
),
new_category_product AS (
    INSERT INTO public.CategoryProduct (category_id, product_id)
    VALUES (3, (SELECT id FROM new_product))
),
new_order AS (
    INSERT INTO public.Orders (user_id, location_id, total_product_cost, total_shipping_cost, payment_method, total_price)
    VALUES (
        (SELECT id FROM new_user),
        (SELECT id FROM new_location),
        4900000.00, -- 980000 * 5
        5.00,
        false,
        4900005.00
    )
    RETURNING id
)
INSERT INTO public.OrderProduct (order_id, product_id, quantity)
VALUES ((SELECT id FROM new_order), (SELECT id FROM new_product), 5);