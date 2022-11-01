--ДЗ №4 Часть 1.

-- 01  Сколько записей в таблице.
SELECT COUNT(*) FROM history.turniket;

-- 02 Сколько записей на каждый день.
SELECT COUNT(*) all_record -- елси это кол-во, то делаем префикс qty_. получается qty_record. поправь везде)
	   , toDate(dt) calend_day -- для даты используем dt_date. для даты-время dt. поправь везде)
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

-- в этой задаче нужно использовать asof join
SELECT employee_id
	 , minIf(dt, is_in = 0) outwork
	 , maxIf(dt, is_in = 1) inter
	 , datediff('hour', outwork, inter) diff_h
     -- все 3 строки ниже переделай в multiIf()
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

-- в этой задаче нужно использовать asof join. пример был на лекции

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
SELECT employee_id, dt_in, dt_in2
     , is_in
FROM
(
    SELECT employee_id
         , min(dt) dt_in -- просто dt dt_in
         , is_in
    FROM history.turniket
    WHERE dt >= now() - interval 30 day
        AND is_in = 1 -- это условие нужно перенести вниз
    -- GROUP BY employee_id -- не нужно
) l
asof JOIN
(
    SELECT employee_id, dt dt_in2, is_in
    FROM history.turniket
    WHERE dt >= now() - interval 30 day
        AND is_in = 1
) r
ON l.employee_id = r.employee_id AND l.dt_in < r.dt_in2;
-- where сюда
	 
-- 04
-- Найти 100 сотрудников, у которых есть два или более выхода подряд.

-- эту задачу тоже нужно переделать, как и предыдущую

SELECT employee_id, dt_out, dt_out2
     , is_in
FROM
(
    SELECT employee_id, min(dt) dt_out
    FROM history.turniket
    WHERE dt >= now() - interval 30 day
        AND is_in = 0
    GROUP BY employee_id
) l
asof JOIN
(
    SELECT employee_id, dt dt_out2, is_in
    FROM history.turniket
    WHERE dt >= now() - interval 30 day
        AND is_in = 0
) r
ON l.employee_id = r.employee_id AND l.dt_out < r.dt_out2
LIMIT 100;


-- 05
-- Показать 100 сотрудников, которые до сих пор на работе.
-- Вывести в отдельную колонку сколько времени прошло от начала их смены.
-- У кого с начала смены прошло более 15 часов, отметить цифрой в отдельной колонке is_long_work. 1 - Да, 0 - Нет.
-- Таблица turniket не пополняется, поэтому за текущее время брать максимальную дату по каждому офису, которая есть в таблице.
-- Т.е. более 15 часов должно быть от этой даты: office_id, max(dt) from turniket group by office_id.
SELECT employee_id
	 , argMax(office_id, dt) office_id
	 , minIf(dt, is_in = 1) start_work -- получается у некоторых сотрудников будет начало 10 дней назад.
	 , max(dt) dt_last
	 , date_diff('hour', start_work, dt_last) working_hours
	 , CASE WHEN working_hours > 15 THEN 1 WHEN working_hours < 15 THEN 0
	   END is_long_work
FROM history.turniket 
WHERE dt >= now() - INTERVAL 10 DAY
GROUP BY employee_id
HAVING is_in = 1
ORDER BY dt_last DESC, working_hours DESC
LIMIT 100;


-- 06
-- Посчитать среднее время между концом и началом смены по каждому офису и за каждый день.
SELECT office_id
	 , toDate(dt) every_day
	 , minIf(dt, is_in = 0) outwork
	 , maxIf(dt, is_in = 1) inter
	 , countIf(is_in, is_in = 1) work_shifts
	 , ((outwork - inter)/work_shifts) avg_work_shift   -- не понял как это делать
FROM history.turniket
WHERE dt >= now() - INTERVAL 30 DAY
GROUP BY office_id, every_day
LIMIT 100;


-- 07
-- Посчитать среднее время длительности смены по каждому офису и за каждый день.


-- В целом на уроке разбирали как считать начало смены.
-- Нам нужен вход перед которым есть выход 7 или более часов назад.
-- Т.е. сначала был выход. Потом прошло более 7ми часов. И после этого был вход.
-- В большинстве задач нужно использовать asof join для поиска начала смены.


