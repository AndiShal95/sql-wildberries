--ДЗ №4 Часть 1.

-- 01  Сколько записей в таблице.
SELECT COUNT(*) FROM history.turniket;

-- 02 Сколько записей на каждый день.
SELECT COUNT(*) qty_record -- елси это кол-во, то делаем префикс qty_. получается qty_record. поправь везде) (+)
	   , toDate(dt) dt_date -- для даты используем dt_date. для даты-время dt. поправь везде)   (+)
FROM history.turniket
GROUP BY dt_date
ORDER BY dt_date

-- 03 Сколько записей на каждый день по каждому офису.
SELECT COUNT(*) qty_record
	   , office_id
	   , toDate(dt) dt_date
FROM history.turniket
GROUP BY office_id, dt_date
ORDER BY dt_date, office_id DESC;

-- 04 Сколько уникальных сотрудников в таблице.
SELECT uniq(employee_id) 
FROM history.turniket;

-- 05 Сколько уникальных сотрудников на каждый день.
SELECT uniq(employee_id) 
	 , toDate(dt) dt_date
FROM history.turniket
GROUP BY dt_date;
	 

-- 06
-- Сколько уникальных сотрудников на каждый день по каждому офису.
-- Кол-во входов.
-- Кол-во выходов.
-- Среднее кол-во входов на каждого сотрудника.
-- Среднее кол-во выходов на каждого сотрудника.
SELECT uniq(employee_id) person_num
	 , office_id
	 , toDate(dt) dt_date
	 , countIf(is_in, is_in = 1) interwork
	 , countIf(is_in, is_in = 0) outwork
	 , round(count(is_in = 1)/person_num, 0) avg_in_emp
	 , round(count(is_in = 0)/person_num, 0) avg_out_emp
FROM history.turniket
GROUP BY dt_date, office_id
ORDER BY dt_date, interwork DESC;


-- Часть 2. Запросы к таблице history.turniket

-- 01
-- Вывести 100 записей для сотрудников, которые зашли после отсутствия более 7 часов.
-- Вывести колонку с кол-вом часов отсутствия.
-- Добавить колонку с номером категории:
-- категория 1: отсутствовал от 7ч до 24ч
-- категория 2: отсутствовал от 24ч до 7д
-- категория 3: отсутствовал более 7д

-- в этой задаче нужно использовать asof join (+)
select employee_id
     , dt_in
     , dt_out
     , date_diff('hour', dt_in, dt_out) diff_h -- нижний комент поправить. потом в этой строке поменять порядок дат в date_diff
     , multiIf(diff_h > 7 AND diff_h <= 24, '1st_category'
             , diff_h > 24 AND diff_h <= 168, '2nd_category', '3rd_category') out_category
from
(
    select employee_id, dt dt_in
    from history.turniket
    where dt >= now() - interval 30 day
        and is_in = 1
    group by employee_id, dt -- группировка не нужна
) l
asof join
(
    select employee_id, dt dt_out
    from history.turniket
    where dt >= now() - interval 30 day
        and is_in = 0
) r
on l.employee_id = r.employee_id and l.dt_in < r.dt_out -- Зашли после отсутствия более 7 часов. Т.е. dt_in < dt_out
WHERE diff_h > 7
ORDER BY out_category
LIMIT 100


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


