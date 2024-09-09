use icud_hhc;
-- To see what dates are in database
select distinct Date from blankets WHERE date like '2024-08%'order by Date desc ;

select * from temps;

select * from blankets WHERE date like '2024-03-23';
-- to delete data
SET SQL_SAFE_UPDATES = 0;
DELETE FROM temps WHERE Date = '2024-05-18000';
SET SQL_SAFE_UPDATES = 1;
-- to find duplicates
SELECT * from blankets where time like '00:00:00' order by Date desc;
SELECT * from temps where date like '2024-08%';

-- Export for Temps table
SELECT * FROM temps WHERE date like'2024-07%';

-- Export for Blanket table with Celsius
SELECT
    `Date`,
    `Time`,
	(pv_blkt_2 - 32) * 5 / 9 AS "Porch Temp 1",
    (pv_blkt_4 - 32) * 5 / 9 AS "Porch Temp 2",
    `pv_blkt_7` AS "Encl Temp",
    (op_blkt_7/100)*700 AS "op_blkt_7_W"
FROM
    blankets
WHERE Date like'2024-08%';
