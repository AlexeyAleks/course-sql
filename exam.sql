DROP DATABASE IF EXISTS book_shop;
CREATE DATABASE book_shop;
USE book_shop;
DROP TABLE IF EXISTS author, book, countrie, sale, shop, theme;

CREATE TABLE countrie (
	countrie_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name NVARCHAR(50) NOT NULL CHECK(name != '') UNIQUE
);

INSERT countrie VALUES (1, 'Испания');
INSERT countrie VALUES (2, 'Англия');
INSERT countrie VALUES (3, 'Италия');
INSERT countrie VALUES (4, 'Германия');
INSERT countrie VALUES (5, 'Франция');

CREATE TABLE author (
	author_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name NVARCHAR(30) NOT NULL CHECK (name != ''),
    surname NVARCHAR(30) NOT NULL CHECK (surname != ''),
    countrie_id INT NOT NULL,
    FOREIGN KEY (countrie_id) REFERENCES countrie (countrie_id)
);

INSERT author VALUES (1, 'Уильям', 'Шекспир', 1);
INSERT author VALUES (2, 'Агата', 'Кристи', 2);
INSERT author VALUES (3, 'Чарльз', 'Диккенс', 3);
INSERT author VALUES (4, 'Джон', 'Толкин', 4);
INSERT author VALUES (5, 'Оскар', 'Уайльд', 5);

CREATE TABLE theme (
	theme_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name NVARCHAR(100) NOT NULL CHECK(name != '') UNIQUE
);

INSERT theme VALUES (1, 'Фантастика');
INSERT theme VALUES (2, 'Фэнтези');
INSERT theme VALUES (3, 'Приключение');
INSERT theme VALUES (4, 'Детектив');
INSERT theme VALUES (5, 'Боевик');


CREATE TABLE shop (
	shop_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name NVARCHAR(50) NOT NULL CHECK(name != ''),
    countrie_id INT NOT NULL,
    FOREIGN KEY (countrie_id) REFERENCES countrie (countrie_id)
);

INSERT shop VALUES
	(1, 'OZON', 1),
	(2, 'Читай Город', 2),
	(3, 'Буквоед', 3),
	(4, 'ЛитРес', 4),
	(5, 'Book24', 5);

CREATE TABLE book (
	book_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name NVARCHAR(30) NOT NULL CHECK (name != ''),
    page INT NOT NULL CHECK (page > 0),
    price DECIMAL(15,2) NOT NULL CHECK (price > 0),
    publish_date DATE CHECK (DATE (publish_date) < sysdate()) NOT NULL,
    author_id INT NOT NULL,
    theme_id INT NOT NULL,
    FOREIGN KEY (author_id) REFERENCES author (author_id),
    FOREIGN KEY (theme_id) REFERENCES theme (theme_id)
);

INSERT book VALUES
	(1, 'Король Лир', 550.0, 150, '1900.10.03', 1, 1 ),
	(2, 'Пуаро ведёт следствие', 160.0, 450, '1910.11.21', 2,  2),
	(3, 'Властелин Оливер Твист', 170.0, 270, '1920.12.11', 3,  3),
	(4, 'Властелин колец', 180.0, 387, '1930.06.17', 4,  4),
	(5, 'Могила Шелли', 190.0, 777, '1940.07.27', 5,  5);

SELECT *
FROM book;

CREATE TABLE sale (
	sale_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    price DECIMAL(15,2) NOT NULL CHECK (price > 0),
    quantity INT NOT NULL CHECK (quantity > 0),
    sale_date DATE CHECK (DATE (sale_date) < sysdate()) NOT NULL,
    book_id INT NOT NULL,
    shop_id INT NOT NULL,
    FOREIGN KEY (book_id) REFERENCES book (book_id),
    FOREIGN KEY (shop_id) REFERENCES shop (shop_id)
);

INSERT sale VALUES
	(1, 189.0, 7, '2017.01.01', 1, 1),
    (2, 876.0, 8, '2018.02.02', 2, 2),
    (3, 345.0, 9, '2019.03.03', 3, 3),
    (4, 865.0, 50, '2020.01.01', 4, 4),
    (5, 982.0, 5, '2017.05.05', 5, 5);

-- 1. Показать все книги, количество страниц в которых больше 500, но меньше 650.

SELECT name
FROM book
WHERE page > 500 AND page < 650;

-- 2. Показать все книги, в которых первая буква названия либо «А», либо «З».

SELECT *
FROM book AS b
WHERE b.name LIKE 'К%' OR b.name LIKE 'П%';

-- 3. Показать все книги жанра «Детектив», количество проданных книг более 30 экземпляров.

SELECT b.name
FROM sale AS s
JOIN book AS b ON s.book_id = b.book_id
JOIN theme AS t ON b.theme_id = t.theme_id
WHERE t.name = 'Детектив' AND s.quantity > 30;

-- 4. Показать все книги, в названии которых есть слово «Micro soft», но нет слова «Windows».

SELECT *
FROM book AS b
WHERE b.name LIKE '%Властелин%' AND b.name NOT LIKE '%Оливер%';

-- 5. Показать все книги (название, тематика, полное имя автора в одной ячейке), цена одной страницы которых меньше 65 копеек.

SELECT b.name, t.name, CONCAT(a.name, ' ', a.surname) AS 'fullname'
FROM sale AS s
JOIN book AS b ON s.book_id = b.book_id
JOIN theme AS t ON b.theme_id = t.theme_id
JOIN author AS a ON b.author_id = a.author_id;

-- 7. Показать информацию о продажах в следующем виде:
	-- ▷Название книги, но, чтобы оно не содержало букву «А».
	-- ▷Тематика, но, чтобы не «Программирование».
	-- ▷Автор, но, чтобы не «Герберт Шилдт».
	-- ▷Цена, но, чтобы в диапазоне от 10 до 20 гривен.
	-- ▷Количество продаж, но не менее 8 книг.
	-- ▷Название магазина, который продал книгу, но он не должен быть в Украине или России.

SELECT b.name, t.name, CONCAT(a.name, ' ', a.surname) AS 'fullname', b.price, s.quantity, sh.name, c.name
FROM shop AS sh
JOIN sale AS s ON sh.shop_id = s.shop_id
JOIN book AS b ON s.book_id = b.book_id
JOIN theme AS t ON b.theme_id = t.theme_id
JOIN author AS a ON b.author_id = a.author_id
JOIN countrie AS c ON sh.countrie_id = c.countrie_id
WHERE b.name NOT LIKE '%П%'
AND t.name NOT LIKE 'Приключение'
AND a.surname NOT LIKE 'Диккенс'
AND b.price > 100 AND b.price < 800
AND s.quantity > 6
AND c.name != 'Испания' AND c.name != 'Англия';

-- 8. Показать следующую информацию в два столбца (числа в правом столбце приведены в качестве примера):
-- ▷Количество авторов: 14 ▷Количество книг: 47
-- ▷Средняя цена продажи: 85.43 грн.
-- ▷Среднее количество страниц: 650.6.

SELECT  'Количество авторов:' , COUNT(a.name)
FROM author AS a
UNION
SELECT 'Количество книг:' , COUNT(b.name)
FROM book AS b
UNION
SELECT 'Средняя цена продажи:' , format(AVG (s.price) , 2)
FROM sale AS s
UNION
SELECT 'Среднее количество страниц:' , format(AVG (b.page) , 2)
FROM book b;

-- 9. Показать тематики книг и сумму страниц всех книг по каждой из них.

SELECT  t.name , 'Сумма страниц : ' , SUM(b.page)
FROM book AS b
JOIN theme AS t ON t.theme_id = b.book_id
GROUP BY b.name;

-- 10. Показать количество всех книг и сумму страниц этих книг по каждому из авторов.

SELECT CONCAT(a.name, ' ', a.surname) AS 'fullname', COUNT(b.name), SUM(b.page)
FROM book AS b
JOIN author AS a ON b.author_id = a.author_id
GROUP BY b.name;

-- 11. Показать книгу тематики «Фантастика» с наибольшим количеством страниц.

SELECT b.name, MAX(b.page)
FROM book AS b
JOIN theme AS t ON b.theme_id = t.theme_id
WHERE t.name = 'Фантастика';