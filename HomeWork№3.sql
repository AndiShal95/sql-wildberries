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









