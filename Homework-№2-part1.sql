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
CREATE TABLE tmp.table106
(
    `dt` DateTime,
    `position_id` UInt64,
    `item_id` UInt64,
    `src_office_id` UInt32,
    `dst_office_id` UInt32
)
ENGINE = MergeTree
PARTITION BY toStartOfWeek(dt, 1)
ORDER BY (src_office_id, position_id)
TTL dt + toIntervalDay(7)
SETTINGS index_granularity = 8192

-- 02 Добавить материализованную колонку dt_date с типом Date, которая будет считать текущую дату от колонки dt.
ALTER TABLE tmp.table106 ADD COLUMN dt_date Date materialized toDate(dt);

--03 Добавить материализованную колонку dt_last_load, которая будет заполняться текущем временем на момент вставки данных.
ALTER TABLE tmp.table106 ADD COLUMN dt_last_load Date materialized now()

--02.1 Вставить в таблицу данные, чтобы получилось 10 партиций.
-- Приложить запрос просмотра системной информации о вашей таблице.
INSERT INTO tmp.table106 
SELECT dt, position_id, item_id, src_office_id, dst_office_id
from history.OrderDetails 
where dt <= now() - interval 1 day
    and item_id > 0
limit 1000

SELECT * FROM tmp.table106;  -- вставка данных из history.OrderDetails

INSERT INTO tmp.table106(dt, position_id, item_id, src_office_id, dst_office_id)   -- сделал 10 партиций
VALUES('2022-08-15 18:37:45',1,1,1,1)('2022-08-22 18:37:45',1,1,1,1)('2022-08-29 18:37:45',1,1,1,1)
	('2022-09-05 18:37:45',1,1,1,1)('2022-09-12 18:37:45',1,1,1,1)('2022-09-19 18:37:45',1,1,1,1)('2022-09-26 18:37:45',1,1,1,1)
	('2022-10-03 18:37:45',1,1,1,1)('2022-10-10 18:37:45',1,1,1,1)('2022-10-17 18:37:45',1,1,1,1)   

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
ALTER TABLE tmp.table106 DELETE IN PARTITION '2022-08-15'; -- это просто данные из таблицы удалил 
ALTER TABLE tmp.table106 DELETE IN PARTITION '2022-08-15'; -- такой запрос не работает

-- 05 Добавить колонку column10 в конец таблицы.
ALTER TABLE tmp.table106 ADD COLUMN column10 UInt32 AFTER dst_office_id;

-- 06 Добавить колонку column1 в начало таблицы.
ALTER TABLE tmp.table106 ADD COLUMN column1 UInt32 FIRST;

-- 07 Добавить колонку с типом: для номеров 104-106 Массив строк
ALTER TABLE tmp.table106 ADD COLUMN arr Array(Tuple(DateTime, String)) materialized array(tuple(dt, position_id))
-- или другой вариант, не понял что именно надо
ALTER TABLE tmp.table106 ADD COLUMN arr2 TEXT after column10

-- 08 Вставить 3 новые строки с 3мя элементами массива.
INSERT INTO tmp.table106(arr2) VALUES ('{"sql", "postgres", "database", "plsql"}');
INSERT INTO tmp.table106(arr2) VALUES ('{"123", "YOHOHO", "BEbebe", "Lala"}');
INSERT INTO tmp.table106(arr2) VALUES ('{"892ql", "p2", "dat", "plade"}');

-- 09 Добавить колонку с типом для номеров 104-106 Массив последовательности (DateTime, String).
ALTER TABLE tmp.table106 ADD COLUMN arr3 Array(Tuple(DateTime, String));

-- 10 Вставить 3 новые строки с 3мя элементами массива.
INSERT INTO tmp.table106(arr3) VALUES({"1970-01-01 03:00:00", "postgres"}) -- не работает
				       
-- 11 Добавить материализованную колонку массив, чтобы она заполнялась из колонок dt, position_id.
ALTER TABLE tmp.table106 ADD COLUMN arr11 Array(Tuple(DateTime, UInt64)) materialized array(tuple(dt, position_id));

-- 12 Вставить 3 новые строки.
--Куда, в материализованную колонку?

-- 13 Удалить колонку dst_office_id.
ALTER TABLE tmp.table106 DROP COLUMN dst_office_id;

-- 14 Создать еще одну таблицу tmp.table2_10_ со структурой, которую мы получили в предыдущих шагах.
-- При создании таблицы сделать TTL:  для номеров 104-106 1 неделя




