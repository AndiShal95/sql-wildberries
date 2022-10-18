-- Домашняя работа №1

--01
 -- По каждому офису оформления src_office_id вывести кол-во qty уникальных заказов,
--  которые были в статусе Оформлен за последние 2е суток.
-- Использовать справочник имен BranchOffice для вывода имен Офисов office_name.
-- Для каждого офиса добавить колонку position с любым номером заказа для примера.
-- Упорядочить по Кол-ву от большего к меньшему.
-- Колонки: src_office_id, office_name, qty, position

SELECT src_office_id   - ошибка  SQL Error [1002]
	, uniq(item_id) qty
	, dictGet('dictionary.BranchOffice','office_name', src_office_id) src_office_name
	, position_id
FROM history.OrderDetails
WHERE dt >= toStartOfDay(now()) - INTERVAL 2 DAY
	AND status_id = 18
GROUP BY position_id
ORDER BY qty DESC
LIMIT 20


--02
-- По офису оформления src_office_id Электросталь вывести кол-во qty уникальных заказов за каждый час dt_h,
--   которые были в статусе На сборке за последние 2е суток.
-- Использовать справочник имен BranchOffice для вывода имен Офисов office_name.
-- Использовать функцию для работы с датами для колонки dt_h.
-- Для каждого офиса добавить колонку position с любым номером заказа для примера.
-- Добавить 2 колонки dt_min dt_max, которые показывают даты первого и последнего статуса в каждом часе.
-- Упорядочить по колонке dt_h.
-- Колонки: src_office_id, office_name, dt_h, qty, position, dt_min, dt_max

SELECT position_id
	, uniq(status_id) qty
	, MIN(dt) dt_min
	, MAX(dt) dt_max
FROM history.OrderDetails
WHERE dt >= now() - INTERVAL 2 DAY
	AND position_id IN
	(
		SELECT src_office_id
			, dictGet('dictionary.BranchOffice','office_name', src_office_id) office_name
			, toStartOfHour(dt) dt_h_
		FROM history.OrderDetails
		WHERE dt >= now() - INTERVAL 2 DAY
		AND office_name = 'Электросталь' AND status_id = 23
		ORDER BY dt_h_ DESC
	)
GROUP BY position_id
LIMIT 10


--03
