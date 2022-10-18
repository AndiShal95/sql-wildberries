-- Домашняя работа №1

--01
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
SELECT src_office_id 
	, dictGet('dictionary.BranchOffice', 'office_name', src_office_id) office_name
	, toHour(dt) dt_h
	, position_id position
FROM history.OrderDetails
WHERE dt >= now() - INTERVAL 2 DAY
order by status_id 
LIMIT 30  .................

