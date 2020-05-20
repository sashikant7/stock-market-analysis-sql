-- Stock Market Analysis
use assignment;


-- Creating a new table named 'bajaj1' containing the date, close price, 20 Day MA and 50 Day MA. 
CREATE TABLE bajaj1 AS 
(SELECT Date, `Close Price`, 
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS "20 Day MA",
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS "50 Day MA"
FROM bajaj_auto);

-- Creating a new table named 'eicher_motors1'
CREATE TABLE eicher_motors1 AS 
(SELECT Date, `Close Price`, 
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS "20 Day MA",
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS "50 Day MA"
FROM eicher_motors);

-- Creating a new table named 'hero1'
CREATE TABLE hero1 AS 
(SELECT Date, `Close Price`, 
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS "20 Day MA",
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS "50 Day MA"
FROM hero_motocorp);

-- Creating a new table named 'tvs_motors1'
CREATE TABLE tvs_motors1 AS 
(SELECT Date, `Close Price`, 
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS "20 Day MA",
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS "50 Day MA"
FROM tvs_motors);

-- Creating a new table named 'infosys1'
CREATE TABLE infosys1 AS 
(SELECT Date, `Close Price`, 
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS "20 Day MA",
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS "50 Day MA"
FROM infosys);

-- Creating a new table named 'tcs1'
CREATE TABLE tcs1 AS 
(SELECT Date, `Close Price`, 
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS "20 Day MA",
AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS "50 Day MA"
FROM tcs);

-- Lets make top 19 values of 20 Day MA and top 49 values of 50 Day MA as NULL 
-- since the moving average for those rows do not make any sense.

update bajaj1 
set `20 Day MA` = NULL
limit 19;
update bajaj1 
set `50 Day MA` = NULL
limit 49;
update eicher_motors1 
set `20 Day MA` = NULL
limit 19;
update eicher_motors1 
set `50 Day MA` = NULL
limit 49;
update hero1 
set `20 Day MA` = NULL
limit 19;
update hero1 
set `50 Day MA` = NULL
limit 49;
update tcs1 
set `20 Day MA` = NULL
limit 19;
update tcs1 
set `50 Day MA` = NULL
limit 49;
update infosys1 
set `20 Day MA` = NULL
limit 19;
update infosys1 
set `50 Day MA` = NULL
limit 49;
update tvs_motors1 
set `20 Day MA` = NULL
limit 19;
update tvs_motors1 
set `50 Day MA` = NULL
limit 49;


-- Creating a master table containing the date and close price of all the six stocks. 

CREATE TABLE price_master AS 
(select A.Date, A.`Close Price` AS "Bajaj",
			 B.`Close Price` AS "TCS",
			 C.`Close Price` AS "TVS",
			 D.`Close Price` AS "Infosys",
			 E.`Close Price` AS "Eicher",
			 F.`Close Price` AS "Hero"
FROM bajaj_auto A
LEFT OUTER JOIN tcs B ON A.Date = B.Date
LEFT OUTER JOIN tvs_motors C ON A.Date = C.Date
LEFT OUTER JOIN infosys D ON A.Date = D.Date
LEFT OUTER JOIN eicher_motors E ON A.Date = E.Date
LEFT OUTER JOIN hero_motocorp F ON A.Date = F.Date
ORDER BY A.Date);

-- Creating a User Defined Function to generate buy, sell and hold  signal

drop function if exists Trading;

DELIMITER $$

create function Trading(MA19 float(8,2), MA49 float(8,2), MA20 float(8,2), MA50 float(8,2))
  returns Varchar(20) 
  deterministic
begin
  declare VarTrade Varchar(20);

   if (MA49 > MA19 and MA20 >= MA50) then
     set VarTrade = "Buy";
   elseif (MA19 > MA49 and MA50 >= MA20) then
     set VarTrade = "Sell";
   else
     set VarTrade = "Hold";
  end if;

return (VarTrade);
end
$$

DELIMITER ;


        
-- Creating 6 different tables with signal column using the UDF described earlier

-- Creating bajaj2

CREATE TABLE bajaj2 AS (SELECT Date, `Close Price`,
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 18 PRECEDING) AS "19 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 48 PRECEDING) AS "49 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS "20 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS "50 Day MA"
FROM bajaj1);

-- Adding a blank column with name signals

alter table bajaj2
ADD COLUMN Signals nvarchar(100) null;  

-- now we will use the function to update the column with signal value

-- setting safe mode off
SET SQL_SAFE_UPDATES = 0;

Update bajaj2 SET Signals=Trading(`19 Day MA`, `49 Day MA`, `20 Day MA`, `50 Day MA`);

-- Removing the unnecessary columns

ALTER TABLE bajaj2
DROP COLUMN `19 Day MA`,
DROP COLUMN `49 Day MA`,
DROP COLUMN `20 Day MA`,
DROP COLUMN `50 Day MA`
;

-- Creating eicher_motors2 

create TABLE eicher_motors2 AS SELECT Date, `Close Price`,
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 18 PRECEDING) AS "19 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 48 PRECEDING) AS "49 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS "20 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS "50 Day MA"
        from eicher_motors1;

-- Adding a blank column with name signals

alter table eicher_motors2
ADD COLUMN Signals nvarchar(100) null;

-- Using the UDF to update the column with signal value

Update eicher_motors2 SET Signals=Trading(`19 Day MA`, `49 Day MA`, `20 Day MA`, `50 Day MA`);

-- Removing the unnecessary columns

ALTER TABLE eicher_motors2
DROP COLUMN `19 Day MA`,
DROP COLUMN `49 Day MA`,
DROP COLUMN `20 Day MA`,
DROP COLUMN `50 Day MA`
;

-- Creating hero2  

create TABLE hero2  AS SELECT Date, `Close Price`,
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 18 PRECEDING) AS "19 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 48 PRECEDING) AS "49 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS "20 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS "50 Day MA"
        from hero1;

-- Adding a blank column with name signals

alter table hero2
ADD COLUMN Signals nvarchar(100) null;

-- Using the UDF to update the column with signal value

Update hero2 
SET Signals=Trading(`19 Day MA`, `49 Day MA`, `20 Day MA`, `50 Day MA`);

-- Removing the unnecessary columns

ALTER TABLE hero2
DROP COLUMN `19 Day MA`,
DROP COLUMN `49 Day MA`,
DROP COLUMN `20 Day MA`,
DROP COLUMN `50 Day MA`
;

-- Creating tvs_motors2  

create TABLE tvs_motors2  AS SELECT Date, `Close Price`,
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 18 PRECEDING) AS "19 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 48 PRECEDING) AS "49 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS "20 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS "50 Day MA"
        from tvs_motors1 ;

-- Adding a blank column with name signals

alter table tvs_motors2
ADD COLUMN Signals nvarchar(100) null;

-- Using the UDF to update the column with signal value

Update tvs_motors2 
SET Signals=Trading(`19 Day MA`, `49 Day MA`, `20 Day MA`, `50 Day MA`);

-- Removing the unnecessary columns

ALTER TABLE tvs_motors2
DROP COLUMN `19 Day MA`,
DROP COLUMN `49 Day MA`,
DROP COLUMN `20 Day MA`,
DROP COLUMN `50 Day MA`;

-- Creating infosys2   

create TABLE infosys2   AS SELECT Date, `Close Price`,
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 18 PRECEDING) AS "19 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 48 PRECEDING) AS "49 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS "20 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS "50 Day MA"
        from infosys1 ;

-- Adding a blank column with name signals

alter table infosys2
ADD COLUMN Signals nvarchar(100) null;

-- Using the UDF to update the column with signal value

Update infosys2 
SET Signals=Trading(`19 Day MA`, `49 Day MA`, `20 Day MA`, `50 Day MA`);

-- Removing the unnecessary columns

ALTER TABLE infosys2
DROP COLUMN `19 Day MA`,
DROP COLUMN `49 Day MA`,
DROP COLUMN `20 Day MA`,
DROP COLUMN `50 Day MA`;

-- Creating tcs2   

create TABLE tcs2 AS SELECT Date, `Close Price`,
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 18 PRECEDING) AS "19 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 48 PRECEDING) AS "49 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 19 PRECEDING) AS "20 Day MA",
		AVG(`Close Price`) OVER (ORDER BY Date ASC ROWS 49 PRECEDING) AS "50 Day MA"
        from tcs1;

-- Adding a blank column with name signals

alter table tcs2
ADD COLUMN Signals nvarchar(100) null;

-- Using the UDF to update the column with signal value

Update tcs2 
SET Signals=Trading(`19 Day MA`, `49 Day MA`, `20 Day MA`, `50 Day MA`);

-- Removing the unnecessary columns

ALTER TABLE tcs2
DROP COLUMN `19 Day MA`,
DROP COLUMN `49 Day MA`,
DROP COLUMN `20 Day MA`,
DROP COLUMN `50 Day MA`;

-- Creating a procedure, 
-- that takes the date as input and returns the signal for that particular day (Buy/Sell/Hold) for the Bajaj stock.

drop procedure if exists SignalBajaj;

DELIMITER $$
create procedure SignalBajaj
  (in n date)
begin
  select Signals
  from bajaj2
  where 
    Date = n;
end $$
DELIMITER ;

-- --------------------------------------End-----------------------------------------------------------

