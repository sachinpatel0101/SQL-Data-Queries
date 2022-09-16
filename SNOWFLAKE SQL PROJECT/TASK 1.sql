-- Write an SQL query that, for each "product", retums the total amount of money spent on it. Rows should be 
-- ordered in descending alphabetical order by "product".



create table shopping_history (
   product varchar not null ,
   quantity integer not null ,
   unit_price integer not null) ;
   
   
insert into shopping_history values
('milk',3,10),
('bread',7,3),
('bread',5,2);




select product, sum((quantity*unit_price)) as tot_price
from shopping_history
group by 1
order by 1 desc;