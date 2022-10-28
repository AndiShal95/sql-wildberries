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
SELECT employee_id
	 , minIf(dt, is_in = 0) outwork
	 , maxIf(dt, is_in = 1) inter
	 , datediff('hour', outwork, inter) diff_h
	 , CASE WHEN diff_h > 7 AND diff_h < 24 THEN 'absent from 7-24h' END 1st_category
	 , CASE WHEN diff_h > 24 AND diff_h < 168 THEN 'absent from 24h-7d' END 2nd_category
	 , CASE WHEN diff_h > 168 THEN 'absent more 7d' END 3rd_category
FROM history.turniket
GROUP BY employee_id
HAVING diff_h > 7
ORDER BY outwork DESC
LIMIT 100;


-- 02
-- Посчитать кол-во смен по каждому сотруднику.
-- Начало смены считаем так. Вход, перед которым есть выход более 7ч.
SELECT uniq(employee_id) tabel_number
	 , office_id
	 , minIf(dt, is_in = 0) outwork
	 , maxIf(dt, is_in = 1) inter
	 , datediff('hour', outwork, inter) diff_h
	 , countIf(is_in, is_in = 1) work_shifts
FROM history.turniket
GROUP BY office_id
HAVING diff_h > 7
ORDER BY work_shifts
LIMIT 100;


-- 03
-- Найти 100 сотрудников, у которых есть два или более входа подряд.
SELECT uniq(employee_id) tabel_number   -- where is_in != 0 
	 , toDate(dt) dt_date
	 , uniq(dt) qty_in_out
FROM history.turniket 
WHERE dt >= now() - interval 30 day
GROUP BY dt_date
HAVING countIf(is_in, is_in=1) >= 2
LIMIT 100
	 
	 
-- 04
-- Найти 100 сотрудников, у которых есть два или более выхода подряд.



