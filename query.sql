-- TODO:

-- 1. Для каждой продажи вывести: id, сумму, имя менеджера, название товара
SELECT s.id ,s.price, (SELECT p.name FROM products p where  p.id = s.product_id),
       (SELECT m.name FROM managers m where m.id = s.manager_id) 
            FROM sales s;

-- 2. сосчитать, сколько (количество) продаж сделал каждый менеджер
SELECT m.name, 
    (SELECT  count(s.manager_id) FROM sales s where s.manager_id = m.id ) 
        FROM  managers m;

-- 3. сосчитать, на сколько (общая сумма) продал каждый менеджер
SELECT m.name,
    (SELECT  sum(s.price*s.qty)FROM sales s WHERE m.id = s.manager_id) 
        FROM managers m;

-- 4. сосчитать, на сколько (общая сумма) продано каждого товара
SELECT p.name,
    (SELECT sum(s.price*s.qty) FROM sales s WHERE s.product_id = p.id) 
        FROM products p;

-- 5. Найти топ-3 самых успешных  менеджеров по общей сумме продаж
SELECT m.name, 
    (SELECT sum(s.price*s.qty) FROM sales s WHERE m.id=s.manager_id) total 
        FROM managers m ORDER BY total DESC LIMIT 3;

-- 6. Найти топ-3 самых продаваемых товаров (по количеству)
SELECT p.name, 
    (SELECT sum(s.qty) FROM sales s where s.product_id = p.id) total 
        FROM products p ORDER BY total desc limit 3;

-- 7. Найти топ-3 самых продаваемых товаров (по сумме)
SELECT p.name,
    (SELECT sum(s.price*s.qty) FROM sales s WHERE s.product_id = p.id) AS total 
        FROM products p ORDER BY total desc limit 3;

-- 8. Найти % на сколько каждый менеджер выполныл план по продажам
SELECT m.name , m.plan, 
    (SELECT sum(s.price*s.qty) FROM sales AS s WHERE m.id = s.manager_id) AS sale,
       (SELECT round(sum(s.price*s.qty) *100.0 /  m.plan, 2) FROM sales s WHERE s.manager_id = m.id) AS total
FROM managers m;

-- 9. Найти % на сколько выполнен план продаж по подразделениям
SELECT DISTINCT(m.unit),
        ifnull(
            (SELECT ss.total FROM (SELECT sum(s.qty * s.price) total,
            (SELECT mm.unit FROM managers mm WHERE mm.id = s.manager_id) unit
                    FROM sales s WHERE unit = m.unit) ss ) * 100.0 /
            (SELECT sum(mm.plan) FROM managers mm WHERE mm.unit = m.unit), 0)
FROM managers m;

---------------------------------------------------------------------------------
-- WITH JOIN's
-- 1. Для каждой продажи вывести: id, сумму, имя менеджера, название товара
SELECT s.id, s.price, m.name, p.name FROM sales AS s
    JOIN managers m ON s.manager_id = m.id
    JOIN products p ON s.product_id = p.id;

-- 2. Cосчитать, сколько (количество) продаж сделал каждый менеджер
SELECT m.name, ifnull(st.total, 0) FROM managers m
    LEFT JOIN (
        SELECT s.manager_id, count(s.manager_id) total
        FROM sales s
            GROUP BY s.manager_id
        ) st
                   ON m.id = st.manager_id;

-- 3. Cосчитать, на сколько (общая сумма) продал каждый менеджер
SELECT m.name, ifnull(st.total, 0) from managers as m 
    LEFT JOIN (
        SELECT s.manager_id, sum(s.price * s.qty) total FROM sales s 
            GROUP BY s.manager_id) st 
                ON m.id = st.manager_id;

-- 4. Cосчитать, на сколько (общая сумма) продано каждого товара
SELECT p.name, sum(s.price * s.qty) 
    FROM products AS p 
    JOIN sales s ON p.id = s.product_id GROUP BY p.name;

-- 5. Найти топ-3 самых успешных  менеджеров по общей сумме продаж
SELECT m.name, sum(s.price * s.qty) AS total 
    FROM managers AS m 
    JOIN sales s ON m.id = s.manager_id  GROUP BY m.name order by total DESC LIMIT 3;

-- 6. Найти топ-3 самых продаваемых товаров (по количеству)
SELECT p.name, sum(s.qty) AS total 
    FROM products AS p 
    JOIN sales s ON p.id = s.product_id GROUP BY p.name ORDER BY total DESC LIMIT 3;

-- 7. Найти топ-3 самых продаваемых товаров (по сумме)
SELECT p.name, sum(s.qty * s.price) AS total 
    FROM products AS p 
    JOIN sales s ON p.id = s.product_id GROUP BY p.name ORDER BY total DESC limit 3;

-- 8. Найти % на сколько каждый менеджер выполныл план по продажам
SELECT m.name, round(sum(s.price * s.qty) * 100.0 / m.plan, 2)  AS total 
    FROM managers AS m JOIN sales s ON m.id = s.manager_id GROUP BY m.name;

-- 9. Найти % на сколько выполнен план продаж по подразделениям
SELECT m.unit, sum(qty * price) * 100 / sum(m.plan) AS total 
    FROM sales s 
        JOIN managers m ON m.id = s.manager_id 
        WHERE m.unit IS NOT NULL GROUP BY unit;