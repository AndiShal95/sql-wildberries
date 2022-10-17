-- Домашняя работа №1

--01
SELECT DISTINCT status_id qty
	, src_office_id
	, dictGet('dictionary.BranchOffice', 'office_name', src_office_id) office_name
	, position_id position
FROM history.OrderDetails
WHERE dt >= now() - INTERVAL 2 DAY
ORDER BY position DESC
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

