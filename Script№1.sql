-- Домашняя работа №1

--01
 -- По каждому офису оформления src_office_id вывести кол-во qty уникальных заказов,
--  которые были в статусе Оформлен за последние 2е суток.
-- Использовать справочник имен BranchOffice для вывода имен Офисов office_name.
-- Для каждого офиса добавить колонку position с любым номером заказа для примера.
-- Упорядочить по Кол-ву от большего к меньшему.
-- Колонки: src_office_id, office_name, qty, position
SELECT src_office_id
    , any(position_id) position
    , uniq(position_id) as qty
    , dictGet('dictionary.BranchOffice','office_name', src_office_id) src_office_name
FROM history.OrderDetails
WHERE dt >= toStartOfDay(now()) - INTERVAL 2 DAY
    AND status_id = 18
GROUP BY src_office_id
LIMIT 100


--02
-- По офису оформления src_office_id Электросталь вывести кол-во qty уникальных заказов за каждый час dt_h,
--   которые были в статусе На сборке за последние 2е суток.
-- Использовать справочник имен BranchOffice для вывода имен Офисов office_name.
-- Использовать функцию для работы с датами для колонки dt_h.
-- Для каждого офиса добавить колонку position с любым номером заказа для примера.
-- Добавить 2 колонки dt_min dt_max, которые показывают даты первого и последнего статуса в каждом часе.
-- Упорядочить по колонке dt_h.
-- Колонки: src_office_id, office_name, dt_h, qty, position, dt_min, dt_max
SELECT src_office_id
    , any(position_id) position
    , uniq(position_id) as qty
    , dictGet('dictionary.BranchOffice','office_name', src_office_id) src_office_name
    , toStartOfHour(dt) dt_h
    , minIf(dt, status_id = 23) dt_min
    , maxIf(dt, status_id = 23) dt_max
FROM history.OrderDetails
WHERE dt >= toStartOfDay(now()) - INTERVAL 2 DAY
    AND status_id = 23 AND src_office_name = 'Электросталь'
GROUP BY src_office_id, dt_h
ORDER BY dt_h
LIMIT 100


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
SELECT src_office_id
    ,    dictGet('dictionary.BranchOffice','office_name', src_office_id) src_office_name
    ,    toDate(dt) dt_date 
    ,    count() qty
    ,    any(position_id) position
    ,    minIf(dt, status_id = 3) min_dt_3
    ,    minIf(dt, status_id = 16) min_dt_16
    ,    maxIf(dt, status_id = 1) max_dt_1
    ,    maxIf(dt, status_id = 8) max_dt_8
    ,    anyIf(position_id, status_id = 25)
    ,    anyIf(position_id, status_id = 16)
from history.OrderDetails
where dt >= now() - interval 2 day
    and src_office_id in [318939, 410475]
group by dt_date, src_office_id 
order by src_office_id, dt_date
limit 100



--04
-- За 7 дней по офису Екатеринбург вывести кол-во qty уникальных заказов за каждый час.
-- Добавить колонку hour Час заказа. Например, 14.
-- Оставить строки, в которых более 40т заказов. Также оставить строки с четными Часами в колонке hour.
-- Упорядочить по офису и dt_h.
-- Колонки: src_office_id, office_name, dt_h, qty, hour.
SELECT 
    src_office_id
    ,    dictGet('dictionary.BranchOffice','office_name', src_office_id) office_name
    ,    uniq(position_id) qty
    ,    toStartOfHour(dt) dt_h
    ,    toHour(dt) hour
FROM history.OrderDetails
WHERE src_office_id = 3480
    AND dt >= now() - interval 2 day
    AND hour in(2,4,6,8,10,12,14,16,18,20,22,24)
GROUP BY dt_h, src_office_id, hour
HAVING qty > 40000
ORDER BY src_office_id, dt_h, hour
LIMIT 100


--5
-- По офису Хабаровск за последние 3 дня посчитать кол-во Доставленных заказов, которые были Оформлены в период между -7 и -3 дня.
-- Также показать 1 пример заказа в колонке position.
-- Упорядочить по убыванию кол-ва.
-- Колонки: src_office_id, office_name, dt_date, qty, position.
select src_office_id
	,	dictGet('dictionary.BranchOffice','office_name', src_office_id) office_name
	,	toDate(dt) dt_date    
	,	count() qty
	,	any(position_id) position
from history.OrderDetails
where dt >= now() - interval 3 day
	and src_office_id = 2400
	and	status_id = 16
	and src_office_id in
	(
	select 
	src_office_id
		from history.OrderDetails
		where toHour(dt) between 3 and 7
			and dt >= now() - interval 3 day
			and status_id = 18
	limit 100
	)
group by src_office_id, dt_date
order by qty desc
limit 10


-- 6
-- По офису Хабаровск за последние 7 дней посчитать кол-во Возвращенных заказов, которые были доставлены за такой же период.
-- Также показать 1 пример заказа в колонке position.
-- Упорядочить по убыванию кол-ва.
-- Колонки: src_office_id, office_name, dt_date, qty, position.
select 
	src_office_id
	,	dictGet('dictionary.BranchOffice','office_name', src_office_id) office_name
	,	toDate(dt) dt_date
	,	count() qty
	,	any(position_id) position
from history.OrderDetails
where dt >= now() - interval 7 day
	and src_office_id = 2400
	and	status_id = 8
	and src_office_id in
	(
	select 
	src_office_id
		from history.OrderDetails
		where toHour(dt) between 3 and 7
			and dt >= now() - interval 7 day
			and status_id = 16
	limit 100
	)
group by src_office_id, dt_date 
order by qty desc
limit 10


-- 7 
-- Для офисов, у которых за 3 дня было между 10т и 50т заказов в статусе Собран, вывести следующую информацию.
-- За 3 дня показать 5 заказов по каждому офису за каждый день по и по каждому статусу из Доставлен, Возвращен.
-- Для вывода 5 заказов использовать оператор limit 5 by ...
-- Колонки: src_office_id, office_name, dt_date, position_id, item_id, status_id.
select 
	src_office_id
	,	dictGet('dictionary.BranchOffice','office_name', src_office_id) office_name
	,	toDate(dt) dt_date 
	,	position_id
	,	item_id 
	,	status_id 
from history.OrderDetails
	where src_office_id in 
		(
		select src_office_id
		from history.OrderDetails
		where dt >= now() - interval 3 day 
			and status_id = 25
		group by src_office_id
		having count() between 10000 and 50000
		order by src_office_id
		limit 100
		)
			and status_id in [16, 8]
			and dt >= now() - interval 2 day
order by src_office_id, dt_date 
limit 5 by src_office_id, status_id 
limit 100

