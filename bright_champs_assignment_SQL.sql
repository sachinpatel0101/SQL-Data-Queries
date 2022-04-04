/* Problem- 1
	Given a table of purchases by date, calculate the month-over-month percentage change in revenue. The output should 
    include the year-month date (YYYY-MM) and percentage change, rounded to the 2nd decimal point, and sorted from the 
    beginning of the year to the end of the year. The percentage change column will be populated from the 2nd month
    forward and can be calculated as ((this month's revenue - last month's revenue) / last month's revenue) * 100.*/
-- SOLVE WITHOUT USING WINDOW FINCTION    
 

 SET @row_number = 0;
 select t1.ym,
	((t2.monthly_revenue - t1.monthly_revenue)/t1.monthly_revenue)*100 as percentage_change
 from
	 (select *, num -1 as num2
	 from
		( 
		SELECT 
			(@row_number:=@row_number + 1) AS num, 
			extract(YEAR_MONTH from created_at) as ym,
			sum(value) as monthly_revenue
		FROM
			transactions
		group by ym
		ORDER BY  ym) t) as t1
        JOIN
        ((select *, num -1 as num2
	 from
		( 
		SELECT 
			(@row_number:=@row_number + 1) AS num, 
			extract(YEAR_MONTH from created_at) as ym,
			sum(value) as monthly_revenue
		FROM
			transactions
		group by ym
		ORDER BY  ym) t)) as t2
        ON
        t1.num = t2.num2
 order by 1 ;



/* Problem- 2
	Find the total number of downloads for paying and non-paying users by date. Include only records where non-paying
    customers have more downloads than paying customers. The output should be sorted by earliest date first and contain 
    3 columns date, non-paying downloads, paying downloads.*/



select *
from
	(select
		Date,
		sum( case when paying = "no" then Total_downloads else null end) as not_paying_downloads,
		sum( case when paying = "yes" then Total_downloads else null end) as paying_downloads
	from
		(select
			d.date as Date,
			p.paying_customer as paying,
			sum(d.downloads) as Total_downloads
		from downloads d
			join
			user_id_table u 
			on d.user_id = u.user_id
			join
			paying p 
			on u.acc_id = p.acc_id
		group by
			Date, paying
		order by
			Date asc) t
	group by 1
	order by 1)mt
where not_paying_downloads > paying_downloads
order by 1;