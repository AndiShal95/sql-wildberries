--ДЗ №4 Часть 1.

-- 01  Сколько записей в таблице.
SELECT COUNT(*) FROM history.turniket;

-- 02 Сколько записей на каждый день.
SELECT COUNT(*) all_record
	   , toDate(dt) calend_day
FROM history.turniket
GROUP BY calend_day
ORDER BY calend_day

-- 03 Сколько записей на каждый день по каждому офису.
SELECT COUNT(*) all_record
	   , office_id
	   , toDate(dt) calend_day
FROM history.turniket
GROUP BY office_id, calend_day
ORDER BY calend_day

-- 04 Сколько уникальных сотрудников в таблице.
SELECT uniq(employee_id) 
FROM history.turniket

-- 05 Сколько уникальных сотрудников на каждый день.
SELECT uniq(employee_id)
	 , toDate(dt) calend_day
FROM history.turniket
GROUP BY calend_day
	 
-- 06
-- Сколько уникальных сотрудников на каждый день по каждому офису.
-- Кол-во входов.
-- Кол-во выходов.
-- Среднее кол-во входов на каждого сотрудника.
-- Среднее кол-во выходов на каждого сотрудника.
SELECT uniq(employee_id) person_num
	 , office_id
	 , toDate(dt) calend_day
	 , countIf(is_in, is_in=1) interwork
	 , countIf(is_in, is_in=0) outwork
	 , round(count(is_in = 1)/person_num, 0) avg_in_emp
	 , round(count(is_in = 0)/person_num, 0) avg_out_emp
FROM history.turniket
GROUP BY calend_day, office_id
ORDER BY calend_day, interwork DESC;


-- Часть 2. Запросы к таблице history.turniket

-- 01
-- Вывести 100 записей для сотрудников, которые зашли после отсутствия более 7 часов.
-- Вывести колонку с кол-вом часов отсутствия.
-- Добавить колонку с номером категории:
-- категория 1: отсутствовал от 7ч до 24ч
-- категория 2: отсутствовал от 24ч до 7д
-- категория 3: отсутствовал более 7д
SELECT uniq(employee_id) person_num
	 , 




SELECT * FROM history.turniket
LIMIT 100;





