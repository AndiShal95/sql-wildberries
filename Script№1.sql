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
    , minIf(dt, status_id = 23) dt_min -- условия лишнее. т.к. уже есть фильтр в блоке WHERE
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
    ,    toDate(dt) dt_date -- форматирование. много пробелов почему-то
    ,    count() qty
    ,    any(position_id) position
    ,    minIf(dt, status_id = 3) min_dt_3
    ,    minIf(dt, status_id = 16) min_dt_16
    ,    maxIf(dt, status_id = 1) max_dt_1
    ,    maxIf(dt, status_id = 8) max_dt_8
    ,    anyIf(position_id, status_id = 25)
    ,    anyIf(position_id, status_id = 16)
FROM history.OrderDetails
WHERE dt >= now() - interval 2 day
    AND src_office_id IN [318939, 410475] -- круглные скобки должны быть
GROUP BY dt_date, src_office_id 
ORDER BY src_office_id, dt_date
LIMIT 100



--04
-- За 7 дней по офису Екатеринбург вывести кол-во qty уникальных заказов за каждый час.
-- Добавить колонку hour Час заказа. Например, 14.
-- Оставить строки, в которых более 40т заказов. Также оставить строки с четными Часами в колонке hour.
-- Упорядочить по офису и dt_h.
-- Колонки: src_office_id, office_name, dt_h, qty, hour.
SELECT -- в первой строке первая колонка. форматирование важно)
    src_office_id
    ,    dictGet('dictionary.BranchOffice','office_name', src_office_id) office_name
    ,    uniq(position_id) qty
    ,    toStartOfHour(dt) dt_h
    ,    toHour(dt) hour -- вычислить ко колонке dt_h
FROM history.OrderDetails
WHERE src_office_id = 3480
    AND dt >= now() - interval 2 day
    AND hour % 2 = 0 -- нужно использовать функцию остатка от деления на 2. (+)
GROUP BY dt_h, src_office_id, hour
HAVING qty > 40000
ORDER BY src_office_id, dt_h, hour -- hour лишняя
LIMIT 100


--5
-- По офису Хабаровск за последние 3 дня посчитать кол-во Доставленных заказов, которые были Оформлены в период между -7 и -3 дня.
-- Также показать 1 пример заказа в колонке position.
-- Упорядочить по убыванию кол-ва.
-- Колонки: src_office_id, office_name, dt_date, qty, position.

-- Решение не подойдет. Нет проверки position_id на предмет "3 дня посчитать кол-во Доставленных заказов" и "Оформлены в период между -7 и -3 дня".
-- Заказы position_id должны быть Доставлены "3 дня посчитать кол-во Доставленных заказов" и эти же position_id должны быть ранее заказаны "Оформлены в период между -7 и -3 дня".
SELECT
    src_office_id
    , dictGet('dictionary.BranchOffice','office_name', src_office_id) office_name
    , toDate(dt) dt_date
    , uniq(position_id) qty
    , any(position_id) position
FROM history.OrderDetails
WHERE dt >= now() - INTERVAL 3 DAY
AND status_id = 16
AND src_office_id = 2400
AND position_id in
    (
    SELECT 
    position_id
        FROM history.OrderDetails
        where dt between now() - interval 7 day and now() - interval 3 day
            AND src_office_id = 2400
            AND status_id = 18
            )
GROUP BY dt_date, src_office_id
ORDER BY qty DESC
LIMIT 100


-- 6
-- По офису Хабаровск за последние 7 дней посчитать кол-во Возвращенных заказов, которые были доставлены за такой же период.
-- Также показать 1 пример заказа в колонке position.
-- Упорядочить по убыванию кол-ва.
-- Колонки: src_office_id, office_name, dt_date, qty, position.

-- Тут аналогично как в задаче 5. Нужно использовать Доставленные position_id. И дня них проверить сколько из них были Возвращены.

SELECT 
    src_office_id,
    dictGet('dictionary.BranchOffice','office_name', src_office_id) office_name,
    toDate(dt) dt_date,
    uniq(position_id) qty,
    any(position_id) position
FROM history.OrderDetails
WHERE dt >= now() - interval 7 day
    AND    status_id = 8
    AND position_id in
    (
    SELECT 
    position_id
        FROM history.OrderDetails
        where dt >= now() - interval 7 day
            AND src_office_id = 2400
            AND status_id = 16
    )
GROUP BY src_office_id, dt_date
ORDER BY qty DESC
LIMIT 100


-- 7 
-- Для офисов, у которых за 3 дня было между 10т и 50т заказов в статусе Собран, вывести следующую информацию.
-- За 3 дня показать 5 заказов по каждому офису за каждый день по и по каждому статусу из Доставлен, Возвращен.
-- Для вывода 5 заказов использовать оператор limit 5 by ...
-- Колонки: src_office_id, office_name, dt_date, position_id, item_id, status_id.

-- форматирование в коде плывет сильно

SELECT src_office_id
	,	dictGet('dictionary.BranchOffice','office_name', src_office_id) office_name
	,	toDate(dt) dt_date 
	,	position_id
	,	item_id 
	,	status_id 
FROM history.OrderDetails
WHERE src_office_id IN 
		(
			SELECT src_office_id
			FROM history.OrderDetails
			WHERE dt >= now() - interval 3 day AND status_id = 25
			GROUP BY src_office_id
			HAVING count() BETWEEN 10000 AND 50000	
		)
			AND status_id in [16, 8] -- круглные скобки
			AND dt >= now() - interval 2 day
ORDER BY src_office_id, dt_date 
LIMIT 5 BY src_office_id, dt_date, status_id-- 5 заказов по каждому офису за каждый день и по каждому статусу. Не хвататет Даты (+)



--8
-- Для офисов, у которых за 3 дня процент Возвращен к Доставлен в диапазоне 12-14%
--   вывести такую же информацию как в предыдущей задаче.
-- За 3 дня показать 5 заказов по каждому офису за каждый день по и по каждому статусу из Доставлен, Возвращен.
-- Для вывода 5 заказов использовать оператор limit 5 by ...
-- Колонки: src_office_id, office_name, dt_date, position_id, item_id, status_id.
SELECT src_office_id
	,	dictGet('dictionary.BranchOffice','office_name', src_office_id) office_name
	,	toDate(dt) dt_date 
	,	position_id
	,	item_id 
	,	status_id 
from history.OrderDetails
where src_office_id in
    (
       SELECT src_office_id
			FROM history.OrderDetails
			WHERE dt >= now() - interval 3 day AND status_id = 25
			GROUP BY src_office_id
			HAVING count() BETWEEN 12 AND 14 -- тут нужно посчитать процент сежду статусами 8 и 16
			ORDER BY src_office_id -- лишнее, возможно поэтому и не отрабатывает
			LIMIT 100 -- лишнее
    )
	AND status_id in [16, 8] -- круглые скобки
			AND dt >= now() - interval 2 day -- форматирование
ORDER BY src_office_id, dt_date 
LIMIT 5 BY src_office_id, status_id -- 5 заказов по каждому офису за каждый день по и по каждому статусу. Не хвататет даты.
LIMIT 100 -- лишнее

-- ........................№8 не работает и не успел

