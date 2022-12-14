-- 01 Создать таблицу со своим номером tmp.table10_ (Например, tmp.table115)
-- Движок MergeTree.
-- Партиционирование: для номеров 104-106 по 1 неделе
-- Сортировка position_id: для номеров 104-106 по src_office_id
-- гранулярность индекса 8192
-- Колонки:
--     `dt`            DateTime
--     `position_id`   UInt64
--     `item_id`       UInt64
--     `src_office_id` UInt32
--     `dst_office_id` UInt32
drop TABLE tmp.table106;
CREATE TABLE tmp.table106
(
    `dt` DateTime,
    `position_id` UInt64,
    `item_id` UInt64,
    `src_office_id` UInt32,
    `dst_office_id` UInt32
)
ENGINE = MergeTree
PARTITION BY toStartOfWeek(dt)  -- Если не знаешь, что означает 1, то не пиши) (+)
ORDER BY (src_office_id, position_id)
SETTINGS index_granularity = 8192

-- 02 Добавить материализованную колонку dt_date с типом Date, которая будет считать текущую дату от колонки dt.
ALTER TABLE tmp.table106 ADD COLUMN dt_date Date materialized toDate(dt);

--03 Добавить материализованную колонку dt_last_load, которая будет заполняться текущем временем на момент вставки данных.
ALTER TABLE tmp.table106 ADD COLUMN dt_last_load Date materialized now()

--02.1 Вставить в таблицу данные, чтобы получилось 10 партиций.
INSERT INTO tmp.table106(dt, position_id, item_id, src_office_id, dst_office_id)   -- сделал 10 партиций
VALUES('2022-08-15 18:37:45',1,1,1,1)('2022-08-22 18:37:45',1,1,1,1)('2022-08-29 18:37:45',1,1,1,1)
	('2022-09-05 18:37:45',1,1,1,1)('2022-09-12 18:37:45',1,1,1,1)('2022-09-19 18:37:45',1,1,1,1)('2022-09-26 18:37:45',1,1,1,1)
	('2022-10-03 18:37:45',1,1,1,1)('2022-10-10 18:37:45',1,1,1,1)('2022-10-17 18:37:45',1,1,1,1);

-- Приложить запрос просмотра системной информации о вашей таблице.
SELECT path, partition, min_time, max_time, active, marks, rows, round(bytes_on_disk/1024/1024,2) Mb
    , engine
FROM system.parts
WHERE database = 'tmp'
    AND table = 'table106'
ORDER BY active, partition, name

-- 03 Удалить 3 последние партиции.
ALTER TABLE tmp.table106 DROP PARTITION '2022-10-10';
ALTER TABLE tmp.table106 DROP PARTITION '2022-10-03';
ALTER TABLE tmp.table106 DROP PARTITION '2022-09-26'

-- 04 Удалить данные в крайней старшей партиции через мутацию.
-- Думаю надо переделать. Правильный синтаксис alter table tmp.table101 delete where dt >= '2022-10-22 00:00:00'
ALTER TABLE tmp.table106 DELETE WHERE dt >= '2022-10-15 00:00:00' -- удаление данных из таблицы
					--(был застой: смотрел в запросе системной информации партиции увеличиваются)

-- 05 Добавить колонку column10 в конец таблицы.
ALTER TABLE tmp.table106 ADD COLUMN column10 UInt32 AFTER dst_office_id;

-- 06 Добавить колонку column1 в начало таблицы.
ALTER TABLE tmp.table106 ADD COLUMN column1 UInt32 FIRST;

-- 07 Добавить колонку с типом: для номеров 104-106 Массив строк
ALTER TABLE tmp.table106 ADD COLUMN arr2 Array(String) AFTER column10; -- Array(String) (+)

-- 08 Вставить 3 новые строки с 3мя элементами массива.
INSERT INTO tmp.table106(arr2) VALUES([('Bronto'),('Pagani'),('Audi')]);
INSERT INTO tmp.table106(arr2) VALUES([('Lada'),('Largus'),('Borjomi')]);
INSERT INTO tmp.table106(arr2) VALUES ([('Tesla'), ('Plaid'), ('Goodcar')])

-- 09 Добавить колонку с типом для номеров 104-106 Массив последовательности (DateTime, String).
ALTER TABLE tmp.table106 ADD COLUMN arr3 Array(Tuple(DateTime, String));

-- 10 Вставить 3 новые строки с 3мя элементами массива.
INSERT INTO tmp.table106(arr3) VALUES([(now(),'One'),(now(),'Two'),(now(),'Three')]);
INSERT INTO tmp.table106(arr3) VALUES([(now(),'543678'),(now(),'T7483wo'),(now(),'T456ee')]);
INSERT INTO tmp.table106(arr3) VALUES([(now(),'42343678'),(now(),'483wo'),(now(),'T4ee')]);
				       
-- 11 Добавить материализованную колонку массив, чтобы она заполнялась из колонок dt, position_id.
ALTER TABLE tmp.table106 ADD COLUMN arr11 Array(Tuple(DateTime, UInt64)) materialized array(tuple(dt, position_id));

-- 12 Вставить 3 простые строки со значениями в таблицу
INSERT INTO tmp.table106(column1, dt, position_id, column10) VALUES('2', '1970-01-01 03:00:00', '60056', '5');
INSERT INTO tmp.table106(column1, dt, position_id, column10) VALUES('3', '1980-01-01 03:00:00', '60057', '6');
INSERT INTO tmp.table106(column1, dt, position_id, column10) VALUES('4', '1990-01-01 03:00:00', '60058', '7');

-- 13 Удалить колонку dst_office_id.
ALTER TABLE tmp.table106 DROP COLUMN dst_office_id;

-- 14 Создать еще одну таблицу tmp.table2_10_ со структурой, которую мы получили в предыдущих шагах.
-- При создании таблицы сделать TTL:  для номеров 104-106 1 неделя
drop TABLE if exists tmp.table2_106
CREATE TABLE tmp.table2_106
(
    `column1` UInt32,
    `dt` DateTime,
    `position_id` UInt64,
    `item_id` UInt64,
    `src_office_id` UInt32,
    `column10` UInt32,
    `arr2` String,
    `dt_date` Date MATERIALIZED toDate(dt),
    `dt_last_load` Date MATERIALIZED now(),
    `arr3` Array(Tuple(DateTime, String)),
    `arr11` Array(Tuple(DateTime, UInt64)) MATERIALIZED [(dt, position_id)]
)
ENGINE = MergeTree
PARTITION BY toStartOfWeek(dt)
ORDER BY (src_office_id, position_id)
TTL toStartOfDay(dt) + interval 7 day
SETTINGS index_granularity = 8192

-- 15 Залить данные из первой таблицы во вторую.
INSERT INTO tmp.table2_106 SELECT column1, dt, position_id, item_id, src_office_id, 
column10, arr2, arr3
FROM tmp.table106
LIMIT 150

-- 16 Добавить код запроса просмотра системной информации своей таблицы.
SELECT path, partition, name, min_time, max_time, active, marks, rows
    , round(bytes_on_disk/1024/1024,2) Mb
    , engine
FROM system.parts
WHERE database = 'tmp'
    and table = 'table2_106'
ORDER BY partition, name

-- HomeWork2 part2
-- ДЗ. Запрос для второй группы.
-- Порядок колонок использовать как написано в задании. Это сокращает время проверки.
-- За последние сутки по офису Хабаровск вывести 100 заказов со следующими колонками.
-- position_id
-- Дата первого статуса Оформлен. данные колонку округлить до начала часа. См.соответсвующую функцию.
-- Дата первого статуса На Сборке.
-- Дата последнего статуса В пути в филиал.
-- Разница в Часах между колонками На Сборке и В пути в филиал.
-- Посчитать кол-во замен в заказе. (Сколько уникальных item_id было в заказе.) Вывести заказы с кол-вом = 1.
-- Вывести все (dt, status_id) в массив. Использовать функцию groupArray(). Отсортировать массив по возрастанию (см.документацию).
-- Вывести первый элемент массива.
--
-- Почему у некоторых заказов diff_h более 48 или менее 48 часов. Написать словами почему так произошло.
-- Попробуйте написать доп условия в запрос, чтобы это избежать.
SELECT src_office_id
	, position_id position
	, minIf(toStartOfHour(dt), status_id = 18) min_dt_18
	, minIf(dt, status_id = 23) min_dt_23
	, maxIf(dt, status_id = 27) max_dt_27
	, date_diff('hour', max_dt_27, min_dt_23) as diff_h -- перепиши на функцию date_diff (+)
	, uniq(item_id) qty
	, arraySort(groupArray((dt, status_id))) arr_dt_st
FROM history.OrderDetails
WHERE dt >= now() - interval 1 day
	AND src_office_id = 2400
GROUP BY src_office_id, position
HAVING diff_h > -48 AND diff_h < 48   -- having добавь условия для фильтрации min_dt_23 и max_dt_27, чтобы выполнить полностью это задание(+/-)-?
ORDER BY diff_h
LIMIT 100;
