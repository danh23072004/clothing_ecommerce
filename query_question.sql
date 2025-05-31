-- Question b)

SET search_path TO public;

SELECT *
FROM users;


WITH new_location AS (
    INSERT INTO public.Location (province, district, commune, address, housing_type)
        VALUES ('Bắc Kạn', 'Ba Bể', 'Phúc Lộc', '73 tân hòa 2', 'nhà riêng')
        RETURNING id),
     new_user AS (
         INSERT INTO public.Users (is_registered, name, email, password, phone, location_id, cart_id)
             VALUES (FALSE, 'assessment', 'gu@gmail.com', NULL, '328355333', NULL, NULL)
             RETURNING id),
     new_product AS (
         INSERT INTO public.Product (store_id, discount_entity_id, name, price, size, color)
             VALUES (3, NULL, 'KAPPA Women''s Sneakers', 980000.00, '36', 'yellow')
             RETURNING id),
     new_category_product AS (
         INSERT INTO public.CategoryProduct (category_id, product_id)
             VALUES (3, (SELECT id FROM new_product))),
     new_order AS (
         INSERT INTO public.Orders (user_id, location_id, total_product_cost, total_shipping_cost, payment_method,
                                    total_price)
             VALUES ((SELECT id FROM new_user),
                     (SELECT id FROM new_location),
                     4900000.00, -- 980000 * 5
                     5.00,
                     false,
                     4900005.00)
             RETURNING id)
INSERT
INTO public.OrderProduct (order_id, product_id, quantity)
VALUES ((SELECT id FROM new_order), (SELECT id FROM new_product), 5);

-- Question c)

SELECT
    EXTRACT(MONTH FROM date) AS month,
    ROUND(AVG(total_price), 2) AS average_order_value
FROM
    public.Orders
WHERE
    EXTRACT(YEAR FROM date) = EXTRACT(YEAR FROM CURRENT_DATE)
GROUP BY
    EXTRACT(MONTH FROM date)
ORDER BY
    month;

-- Question d)

SELECT * FROM orders;

SELECT
    (COUNT(DISTINCT CASE WHEN NOT EXISTS (
        SELECT 1
        FROM Orders o2
        WHERE o2.user_id = o.user_id
          AND o2.date >= CURRENT_TIMESTAMP - interval '6 months'
          AND o2.date <= CURRENT_TIMESTAMP
    ) THEN o.user_id END)::float / COUNT(DISTINCT o.user_id)) * 100 AS churn_rate
FROM Orders o
WHERE o.date >= CURRENT_TIMESTAMP - interval '12 months'
    AND o.date < CURRENT_TIMESTAMP - interval '6 months';

-- Query for this question: "Fetches a list of products that belong to a specific category"
SELECT c.id, c.category_name, cp.product_id, p.name
FROM category AS c
    LEFT JOIN categoryproduct AS cp ON c.id = cp.category_id
    LEFT JOIN product AS p ON cp.product_id = p.id
WHERE c.category_name = 'Shoes';

-- Enable unaccent
CREATE EXTENSION IF NOT EXISTS unaccent;