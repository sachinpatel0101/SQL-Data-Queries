/* write an SQL query that finds all clients who talked for atleast 10 minutes in total.
   The table of results should contain one column, the name of client(name). 
   Rows should be sorted alphabatically */


create table phones (
    name varchar ( 20 ) not null unique ,
    phone_number integer not null unique) ;


create table calls (
    id integer not null ,
    caller integer not null ,
    callee integer not null ,
    duration integer not null ,
    unique ( id ) );
    
insert into phones values
('Jack',1234),
('Lena',3333),
('Mark',9999),
('Anna',7582);

insert into calls values
(25,1234,7582,8),
(7,9999,7582,1),
(18,9999,3333,4),
(2,7582,3333,3),
(3,3333,1234,1),
(21,3333,1234,1);

select * from phones;

select * from calls;



with temp1 as(
    select caller as ph_no, duration from calls
    union all
    select callee as ph_no, duration from calls),
    temp2 as(
    select ph_no, sum(duration) as talking_time
    from temp1
    group by 1)

select p.name as name
from temp2 t join phones p
on t.ph_no = p.phone_number
where t.talking_time >=10
order by 1;   
    