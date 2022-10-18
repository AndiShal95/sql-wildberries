-- Домашняя работа №1

--01
 -- По каждому офису оформления src_office_id вывести кол-во qty уникальных заказов,
--  которые были в статусе Оформлен за последние 2е суток.
-- Использовать справочник имен BranchOffice для вывода имен Офисов office_name.
-- Для каждого офиса добавить колонку position с любым номером заказа для примера.
-- Упорядочить по Кол-ву от большего к меньшему.
-- Колонки: src_office_id, office_name, qty, position

SELECT src_office_id   
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
-- За 7 дней по офисам оформления src_office_id Астана и Белая дача вывести кол-во qty уникальных заказов за каждый день dt_date.
-- Использовать справочник имен BranchOffice для вывода имен Офисов office_name.
-- Для каждого офиса добавить колонку position с любым номером заказа для примера.
-- Добавить колонку минимальной даты для статуса Резерв.
-- Добавить колонку минимальной даты для статуса Доставлен.
-- Добавить колонку максимальной даты для статуса Отмена.
-- Добавить колонку максимальной даты для статуса Возврат.
-- Добавить колонку со случайным примером номера заказа для статуса Собран.
-- Добавить колонку со случайным примером номера заказа для статуса Доставлен.
-- Упорядочить по офису и по дате.
-- Колонки: src_office_id, office_name, dt_h, qty, position, min_dt_3, min_dt_16, max_dt_1, max_dt_8, position_25, position_16.

SELECT 
        dictGet('dictionary.BranchOffice','office_name', src_office_id) src_office_name,
        toStartOfHour(dt) dt_h,
        uniq(position_id) qty,
        position_id as position,
        minIf(dt, status_id = 3) min_dt_3,
        minIf(dt, status_id = 16) min_dt_16,
        maxIf(dt, status_id = 1) max_id_1,
        maxIf(dt, status_id = 8) max_id_8,
        anyIf (position_id, status_id = 25) position_25,
        anyIf(position_id, status_id = 16) position_16
FROM history.OrderDetails
WHERE src_office_id IN
    (
        SELECT src_office_id
        FROM history.OrderDetails
        WHERE src_office_name = 'Астана' and 'Белая дача'
	    AND WHERE dt >= now() - INTERVAL 7 DAY
    )
GROUP BY position, src_office_name, dt_h, qty
ORDER BY src_office_name, dt_h
LIMIT 100
