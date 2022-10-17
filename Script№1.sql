SELECT min(dt) dt_min, max(dt) dt_max
from history.OrderDetails od 
limit 100

SELECT count() qty
from history.OrderDetails od 
where dt >= now() - INTERVAL 2 DAY 


SELECT toDate(dt) dt_date , count() qty
from history.OrderDetails
where dt >= now() - INTERVAL 7 DAY 
group by dt_date 
order by dt_date desc


SELECT DISTINCT status_id, 
	dictGet('dictionary.OrderStatus', 'status_name', status_id) status_name,
	count(qty)
FROM history.OrderDetails
where dt >= now() - INTERVAL 3 DAY 
group by dt_date, status_id 
ORDER BY dt_date, status_id



SELECT position_id , dt, item_id, status_id
,dictGet('dictionary.OrderStatus', 'status_name', status_id) status_name
FROM history.OrderDetails
where dt >= now() - INTERVAL 15 DAY 
	and position_id  = 600717994491
order by dt 



SELECT position_id, uniq(status_id) qty_status
FROM history.OrderDetails
where dt >= now() - INTERVAL 10 DAY
	and position_id IN
	(
		SELECT position_id
		FROM history.OrderDetails
		where dt >= now() - INTERVAL 1 DAY
			and status_id = 1
			order by dt desc
	)
group by position_id 
having qty_status desc


-- 10

SELECT dictGet('dictionary.OrderStatus', 'status_name', status_id) status_name
		, position_id, dt, item_id, status_id
FROM history.OrderDetails
where dt >= now() - INTERVAL 10 DAY
and position_id = 600717994491
order by dt

-- 11 замена товаров в заказе
SELECT position_id
	, uniq(item_id) qty_item
	, anyIf(status_id, status_id = 16) is_delivered
FROM history.OrderDetails
where dt >= toStartOfDay(now()) - interval 5 DAY 
			and status_id in(18, 23, 16)
group by position_id 
having is_delivered = 16
	and qty_item > 2
	limit 100
	
	
--12
	
SELECT position_id
	, toHour(dt) dt_h
	, toStartOfHour(dt) dt_h_
	, toStartOfDay(dt) dt_day
	, toStartOfWeek(dt) dt_week
	, toStartOfMonth(dt) dt_mon
	, toDateTime(dt_mon) dt_mon_
	, toDateTime(2000000000) dt_item
	, toMinute(dt) dt_min
FROM history.OrderDetails
where dt >= now() - INTERVAL 1 DAY
limit 100


--14

SELECT position_id
	, toDateTime(0) dt_zero
	, toString(item_id) item_str
	, toString(dt) dt_str
	, concat(item_str, ', ', dt_str) con_str
	, [item_str, dt_str] arr_str
	, arrayStringConcat(arr_str, ', ') arr_str_concat
FROM history.OrderDetails
where dt >= now() - INTERVAL 1 DAY
limit 100


--15


SELECT position_id
, toString(item_id) item_str
, toString(dt) dt_str
, [item_str, dt_str] arr_str
, arr_str[2] arr_1
FROM history.OrderDetails
where dt >= now() - INTERVAL 1 DAY
limit 100


--16

SELECT *
FROM history.OrderDetails od 
LIMIT 10



