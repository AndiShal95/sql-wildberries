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

