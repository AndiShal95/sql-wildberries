-- 01 Создать таблицу со своим номером tmp.table10_ (Например, tmp.table115)
-- Движок MergeTree.
-- Партиционирование: для номеров 104-106 по 1 неделе
-- Сортировка position_id: для номеров 104-106 по src_office_id
-- гранулярность индекса 8192
-- Колонки:
--     `dt`            DateTime
--     `position_id`   UInt64
--     `item_id`       UInt64
--     `src_office_id` UInt32
--     `dst_office_id` UInt32
CREATE TABLE tmp.table106
(
    `dt` DateTime,
    `position_id` UInt64,
    `item_id` UInt64,
    `src_office_id` UInt32,
    `dst_office_id` UInt32
)
ENGINE = MergeTree
PARTITION BY toStartOfWeek(dt, 1)
ORDER BY (src_office_id, position_id)
TTL dt + toIntervalDay(7)
SETTINGS index_granularity = 8192

-- 02 Добавить материализованную колонку dt_date с типом Date, которая будет считать текущую дату от колонки dt.


