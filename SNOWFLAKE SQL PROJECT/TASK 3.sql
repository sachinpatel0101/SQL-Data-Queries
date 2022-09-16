/* write an SQL query that returns a table containing one column, balance. The table should contain one row,
   with the total balance of your account at the end of the year, including the fee for holding a credit card. */




use INEURON_SQL_PROJECT;

CREATE TABLE transactions (
   Amount INTEGER NOT NULL, 
   Date DATE NOT NULL) ;
  
  
INSERT INTO transactions ( Amount , Date ) VALUES ( 1000 , ' 2020-01-06 ' ) ;
INSERT INTO transactions ( Amount , Date ) VALUES ( -10 , ' 2020-01-14 ' ) ;
INSERT INTO transactions ( Amount , Date ) VALUES ( -75 , ' 2020-01-20 ' ) ;
INSERT INTO transactions ( Amount , Date ) VALUES ( -5 , ' 2020-01-25 ' ) ;
INSERT INTO transactions ( Amount , Date ) VALUES ( -4 , ' 2020-01-29 ' ) ;
INSERT INTO transactions ( Amount , Date ) VALUES ( 2000 , ' 2020-03-10 ' ) ;
INSERT INTO transactions ( Amount , Date ) VALUES ( -75 , ' 2020-03-12 ' ) ;
INSERT INTO transactions ( Amount , Date ) VALUES ( -20 , ' 2020-03-15 ' ) ;
INSERT INTO transactions ( Amount , Date ) VALUES ( 40 , ' 2020-03-15 ' ) ;
INSERT INTO transactions ( Amount , Date ) VALUES ( -50 , ' 2020-03-17 ' ) ;
INSERT INTO transactions ( Amount , Date ) VALUES ( 200 , '2020-10-10 ' ) ;
INSERT INTO transactions ( Amount , Date ) VALUES ( -200 , ' 2020-10-10 ' ) ;
                                                   
                                                   
select * from transactions; 

create table months (
    mnt integer not null);

insert into months values (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12);

select * from months;

with temp1 as(
    select date, year(date) as yr, month(date) as mnt,
       case when AMOUNT > 0 then AMOUNT else null end as income,
       case when AMOUNT < 0 then AMOUNT else NULL end as credit_payment
    from TRANSACTIONS),
     temp2 as(
     select yr, mnt, sum(income) as income, sum(credit_payment) as credit_payment, count(credit_payment) as cnt
     from temp1
     group by 1,2),
     temp3 as (
     select m.mnt, t.* ,
       case when (cnt >= 3 and CREDIT_PAYMENT <= -100) then 0 else -5 end as charge
     from temp2 t right join MONTHS m on t.mnt = m.mnt)

select sum((coalesce(income,0) + coalesce(credit_payment,0) + coalesce(charge,0))) as balance

from temp3;