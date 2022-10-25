-- ДЗ №3
-- Создать таблицу с такой структурой колонок. tmp.table3_106

CREATE TABLE tmp.table3_106
(
  log_id         UInt64,
  position_id    UInt64,
  dt             DateTime,
  item_id        UInt64,
  status_id      UInt64,
  src_office_id  UInt32,
  dst_office_id  UInt32,
  delivery_dt    DateTime,
  is_marketplace UInt8,
  as_id          UInt64,
  dt_date        Date
)
ENGINE = MergeTree
ORDER BY position_id
SETTINGS index_granularity = 8192;

SELECT * FROM tmp.table3_106;
SELECT * FROM history.OrderDetails
LIMIT 50;

	
-- 01 Подготовить таблицу с тестовыми данными:
-- Из таблицы history.OrderDetails по складу Хабаровск отобрать в таблицу
-- tmp.table3_115 (использовать свой номер) по 200000 строк за каждые 5 последних суток.
-- В блоке фильтрации к условию по дате добавить следующее условие: status_id != 1.
-- Должно получиться 1млн строк.
INSERT INTO tmp.table3_106 
SELECT log_id, position_id, dt, item_id, status_id, src_office_id, dst_office_id
		, delivery_dt, is_marketplace, as_id, dt_date
FROM history.OrderDetails 
WHERE dt >= toStartOfDay(now()) - INTERVAL 3 DAY
AND src_office_id = 2400 AND status_id != 1
LIMIT 200000;

SELECT COUNT(log_id) FROM tmp.table3_106;  --до 1млн строк

-- 02 Провести исследование отобранного набора данных.
-- Сколько уникальных заказов есть в тестовой выборке.
SELECT uniq(position_id) as qty FROM tmp.table3_106;

-- 03 Сколько заказов было Оформлено, Собрано, Подготовлено к отгрузке, Доставлено, Возврещено.
SELECT countIf(status_id, status_id = 18) qty_18_status
	, countIf(status_id, status_id = 25) qty_25_status
	, countIf(status_id, status_id = 28) qty_28_status
	, countIf(status_id, status_id = 16) qty_16_status
	, countIf(status_id, status_id = 8) qty_8_status
FROM tmp.table3_106;


-- 04 Вывести 100 заказов, с наибольшей историей.
-- Добавить колонку массив со всеми товарами, которые были в заказе. Убрать дубли в массиве.
SELECT position_id
    , uniq(status_id)
    , arraySort(arrayDistinct(groupArray(item_id))) arr_item -- массив уникальных товаров в заказе
FROM tmp.table3_106
GROUP BY position_id
ORDER BY uniq(status_id) DESC
LIMIT 100;


-- 05 Из предыдущего полученного результата выбрать один заказ с максимальным кол-вом истории и
-- у которого была хотя бы одна замена товара в заказе.
-- За 7 дней из таблицы history.OrderDetails вывести детализацию по этому заказу.
-- Упорядочить по дате.
SELECT position_id
    , uniq(status_id)
    , arraySort(arrayDistinct(groupArray(item_id))) arr_item -- массив уникальных товаров в заказе
FROM tmp.table3_106
WHERE status_id IN 
( 
  SELECT status_id 
  FROM tmp.table3_106
  WHERE status_id = 8
)
GROUP BY position_id
ORDER BY uniq(status_id) DESC
LIMIT 1;

--Детализация по заказу из предыдущего запроса
SELECT log_id, position_id, dt, item_id, status_id, src_office_id, dst_office_id
		, delivery_dt, is_marketplace, as_id, dt_date
FROM history.OrderDetails od 
WHERE dt >= toStartOfDay(now()) - INTERVAL 7 DAY
AND position_id = 600703394373
ORDER BY dt;


-- 06 Сделать таблицу с движком ReplacingMergeTree. tmp.table4_115
-- Структура таблицы такая же как у тестового набора данных.
-- Сортировка по position_id.
-- Партиционирование не нужно.
-- Залить в эту таблицу все данные из тестововой таблицы два раза.
-- Скорее всего двойная заливка сделает дубликаты заказов в таблице, которые движок не успеет удалить.
CREATE TABLE tmp.table4_106
(
  log_id         UInt64,
  position_id    UInt64,
  dt             DateTime,
  item_id        UInt64,
  status_id      UInt64,
  src_office_id  UInt32,
  dst_office_id  UInt32,
  delivery_dt    DateTime,
  is_marketplace UInt8,
  as_id          UInt64,
  dt_date        Date
)
ENGINE = ReplacingMergeTree
ORDER BY position_id
SETTINGS index_granularity = 8192;

--Импорт данных из предыдущей таблицы 2 раза
INSERT INTO tmp.table4_106
SELECT log_id, position_id, dt, item_id, status_id, src_office_id, dst_office_id
		, delivery_dt, is_marketplace, as_id, dt_date
FROM tmp.table3_106;


-- 07 Найти заказы, которые встречаются в таблице более 1го раза.
SELECT dt_date, dt, position_id, item_id
     , status_id
     , dictGet('dictionary.OrderStatus','status_name',status_id) status_name
     , src_office_id
FROM tmp.table4_106 final
ORDER BY dt
LIMIT 100


-- 08 Вывести один из таких заказов.
SELECT dt_date, dt, position_id, item_id
     , status_id
     , dictGet('dictionary.OrderStatus','status_name',status_id) status_name
     , src_office_id
FROM tmp.table4_106
WHERE position_id = 600682328418
ORDER BY dt;


-- 09 Применить ключевое слово final для удаления дублей из результата.
optimize table tmp.table4_106 final;


-- 10 Вместо final применить функцию argMax, чтобы удалить дубли.
-- На данном шаге применить argMax к каждой колонке.
-- В функции вместо даты использовать колонку log_id.
-- в первой лекции была информация, что log_id это номер изменения.
SELECT argMax((log_id, position_id, dt, item_id, status_id, src_office_id, dst_office_id
		, delivery_dt, is_marketplace, as_id, dt_date), log_id)
FROM tmp.table4_106;


-- 11 Применить функцию argMax чтобы удалить дубли.
-- На данном шаге применить argMax к Tuple.
-- В функции вместо даты использовать колонку log_id.
-- Вывести все колонки.
SELECT position_id
    , t_max.1 dt_max
    , t_max.2 item_last
FROM 
(
  SELECT position_id, argMax((log_id, position_id, dt, item_id, status_id, src_office_id, dst_office_id
		, delivery_dt, is_marketplace, as_id, dt_date), log_id) t_max
  FROM tmp.table4_106
  WHERE position_id = 600682328418
  GROUP BY position_id
);


-- 12 Сделать новую таблицу tmp.table5_106 с сортировкой по position_id.
-- Партиционирвоание по dt_date. Функция партиционирования toDate.
-- Движок ReplacingMergeTree. Сортировка position_id.
-- Залить в нее все данные из тестового набора дынных один раз.
CREATE TABLE tmp.table5_106
(
  log_id         UInt64,
  position_id    UInt64,
  dt             DateTime,
  item_id        UInt64,
  status_id      UInt64,
  src_office_id  UInt32,
  dst_office_id  UInt32,
  delivery_dt    DateTime,
  is_marketplace UInt8,
  as_id          UInt64,
  dt_date        Date
)
ENGINE = ReplacingMergeTree
PARTITION BY toDate(dt_date)
ORDER BY position_id
SETTINGS index_granularity = 8192;

---------Залить все данные из тестового набора данных один раз.
INSERT INTO tmp.table5_106
SELECT log_id, position_id, dt, item_id, status_id, src_office_id, dst_office_id
		, delivery_dt, is_marketplace, as_id, dt_date
FROM tmp.table3_106;


-- 13 Вывести данные по выбранному заказу, который использовали в предыдущих запросах.
SELECT * FROM tmp.table5_106
WHERE position_id = 600682328418
ORDER BY dt;


-- 14 Попытаться удалить дубли через команду optimize.
-- Почему дубли не удаляются. Написать словами.
optimize table tmp.table5_106 final; 
 --Если делаю 2 INSERT вместо одного(из 12-го задания), то дубль удаляется
 
 
 -- 15 Получить последнее состояние заказа. Применить функцию argMax() по log_id.
SELECT argMax((log_id, position_id, dt, item_id, status_id, src_office_id, dst_office_id
		, delivery_dt, is_marketplace, as_id, dt_date), log_id)
FROM tmp.table4_106
WHERE position_id = 600682328418;


-- 16 Сделать новую таблицу tmp.table6_106 с сортировкой по position_id, dt_date.
-- Партиционирование по одному месяцу.
-- Движок ReplacingMergeTree.
-- Залить в нее все данные из тестового набора дынных один раз.
CREATE TABLE tmp.table6_106
(
  log_id         UInt64,
  position_id    UInt64,
  dt             DateTime,
  item_id        UInt64,
  status_id      UInt64,
  src_office_id  UInt32,
  dst_office_id  UInt32,
  delivery_dt    DateTime,
  is_marketplace UInt8,
  as_id          UInt64,
  dt_date        Date
)
ENGINE = ReplacingMergeTree
PARTITION BY toStartOfMonth(dt)
ORDER BY (position_id, dt_date)
SETTINGS index_granularity = 8192;
--------------------
INSERT INTO tmp.table6_106
SELECT log_id, position_id, dt, item_id, status_id, src_office_id, dst_office_id
		, delivery_dt, is_marketplace, as_id, dt_date
FROM tmp.table3_106;


-- 17 Получить последние данные по всем залитым заказам. Применить argMax()
SELECT position_id
     , argMax((log_id, position_id, dt, item_id, status_id, src_office_id, dst_office_id
		, delivery_dt, is_marketplace, as_id, dt_date), dt) status_last
FROM tmp.table6_106
GROUP BY position_id
ORDER BY position_id;
