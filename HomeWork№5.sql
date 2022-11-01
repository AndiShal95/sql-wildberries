-- ДЗ
-- 01
-- На примере из документации.
-- Сделать новую колонку в массиве, которая будет суммой чисел предыдущего элемента и текущего.
-- Ответ: [[3,1],[4,3],[5,5]]
SELECT arrayMap(x -> (x + 2), [1, 2, 3]) as arr,
	   arrayMap(x -> (x + 2), [-1, 1, 3]) as arr2,    --Сумма предыдущего и текущего??
	   arrayMap((x, y) -> (x, y), arr, arr2) as res;
	   
	   
-- 02
-- Из подобного массива получить новый массив: сколько секунд прошло между датами соседних элементов.
select position_id
    , arrayFilter(x -> x.1 != 0, arr_src_second) arr_new
    , arrayMap(x -> (date_diff('second', arr[x - 1].1, arr[x].1), arr[x], (toDateTime(0),0)), arrayEnumerate(arr)) arr_src_second  
    , arraySort(groupArray((dt, status_id))) arr
from tmp.table_05
group by position_id;	  


-- 03
-- Найти сотрудника с большим кол-вом проходов по турнику и для него получить данные.
-- Посчитать начало смены через массив. Должен получиться массив с началом смен.
-- Также добавить колонку конец смены. Должен получиться массив с окончанием смен.
-- Начало смены считаем так: is_in = 0, через 7 или более часов был вход. Этот вход и есть начало смены.
-- Конец смены считаем аналогично.
-- За исходник кода можно взять этот запрос и поправить его.
select position_id
    , arrayFilter(x -> x.1 != 0, arr_src) arr_new
    , arrayMap(x -> (if(date_diff('hour',arr[x - 1].1, arr[x].1) > 7, arr[x], (toDateTime(0),0))), arrayEnumerate(arr)) arr_src
    , arraySort(groupArray((dt, status_id))) arr
from tmp.table_05
group by position_id

