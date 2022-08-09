create database cointab;

use cointab;

CREATE TABLE `Company_X_Order_Report` (
	`ExternOrderNo` DECIMAL(38, 0) NOT NULL, 
	`SKU` VARCHAR(30) NOT NULL, 
	`Order Qty` DECIMAL(38, 0) NOT NULL
);

LOAD DATA INFILE 'D:/Company_X_Order_Report.csv'
into table Company_X_Order_Report
FIELDS TERMINATED by ','
ENCLOSED by '"'
lines terminated by '\n'
IGNORE 1 ROWS;


CREATE TABLE `Company_X_Pincode_Zones` (
	`Warehouse Pincode` DECIMAL(38, 0) NOT NULL, 
	`Customer Pincode` DECIMAL(38, 0) NOT NULL, 
	`Zone` VARCHAR(1) NOT NULL
);

LOAD DATA INFILE 'D:/Company_X_Pincode_Zones.csv'
into table Company_X_Pincode_Zones
FIELDS TERMINATED by ','
ENCLOSED by '"'
lines terminated by '\n'
IGNORE 1 ROWS;


CREATE TABLE `Company_X_SKU_Master` (
	`SKU` VARCHAR(30) NOT NULL, 
	`Weight (g)` DECIMAL(38, 0) NOT NULL
);

LOAD DATA INFILE 'D:/Company_X_SKU_Master.csv'
into table Company_X_SKU_Master
FIELDS TERMINATED by ','
ENCLOSED by '"'
lines terminated by '\n'
IGNORE 1 ROWS;

CREATE TABLE `Courier_Company_Invoice` (
	`AWB Code` DECIMAL(38, 0) NOT NULL, 
	`Order ID` DECIMAL(38, 0) NOT NULL, 
	`Charged Weight` DECIMAL(38, 2) NOT NULL, 
	`Warehouse Pincode` DECIMAL(38, 0) NOT NULL, 
	`Customer Pincode` DECIMAL(38, 0) NOT NULL, 
	`Zone` VARCHAR(1) NOT NULL, 
	`Type of Shipment` VARCHAR(23) NOT NULL, 
	`Billing Amount (Rs.)` DECIMAL(38, 1) NOT NULL
);

LOAD DATA INFILE 'D:/Courier_Company_Invoice.csv'
into table Courier_Company_Invoice
FIELDS TERMINATED by ','
ENCLOSED by '"'
lines terminated by '\n'
IGNORE 1 ROWS;

CREATE TABLE `Courier_Company_Rates` (
	charges_type VARCHAR(23) NOT NULL, 
	zone VARCHAR(1) NOT NULL, 
	`additional charges` DECIMAL(38, 1) NOT NULL, 
	`fixed charges` DECIMAL(38, 1) NOT NULL
);

LOAD DATA INFILE 'D:/Courier_Company_Rates.csv'
into table Courier_Company_Rates
FIELDS TERMINATED by ','
ENCLOSED by '"'
lines terminated by '\n'
IGNORE 1 ROWS;



select distinct * from company_x_order_report;
select * from company_x_pincode_zones;
select distinct * from company_x_sku_master;
select distinct * from courier_company_invoice;
select * from courier_company_rates;



create view output_1 as(
with order_sku as(
	select distinct o.ExternOrderNo, o.SKU, o.`Order Qty`, s.`Weight (g)`, (o.`Order Qty`* s.`Weight (g)`)/1000 as total_weight_kg
    from company_x_order_report o join company_x_sku_master s
    on o.SKU = s.SKU),
    
    grouped_order_weights as(
    select `ExternOrderNo`, sum(total_weight_kg) as `total_weight_as_per_X_KG`,
    case when sum(total_weight_kg) <= 0.5 then 0.5
		when sum(total_weight_kg) > 0.5 and sum(total_weight_kg)<=1.0 then 1.0
        when sum(total_weight_kg) > 1.0 and sum(total_weight_kg) <=1.5 then 1.5
        when sum(total_weight_kg) > 1.5 and sum(total_weight_kg) <=2.0 then 2.0
        when sum(total_weight_kg) > 2.0 and sum(total_weight_kg) <= 2.5 then 2.5
        when sum(total_weight_kg) > 2.5 and sum(total_weight_kg) <=3.0 then 3.0
        when sum(total_weight_kg) > 3.0 and sum(total_weight_kg) <= 3.5 then 3.5
        end as `weight_slab_as_per_X_KG`
    from order_sku
    group by ExternOrderNo),
    
    invoice_join_order as(
    select distinct i.`Order ID`, i.`AWB Code`,
			g.`total_weight_as_per_X_KG`,
            g.`weight_slab_as_per_X_KG`,
            i.`Charged Weight` as Total_weight_as_per_Courier_Company_KG,
            case when i.`Charged Weight` <= 0.5 then 0.5
			when i.`Charged Weight` > 0.5 and i.`Charged Weight` <=1.0 then 1.0
			when i.`Charged Weight` > 1.0 and i.`Charged Weight` <=1.5 then 1.5
			when i.`Charged Weight` > 1.5 and i.`Charged Weight` <=2.0 then 2.0
			when i.`Charged Weight` > 2.0 and i.`Charged Weight` <= 2.5 then 2.5
			when i.`Charged Weight` > 2.5 and i.`Charged Weight` <=3.0 then 3.0
			when i.`Charged Weight` > 3.0 and i.`Charged Weight` <= 3.5 then 3.5
            when i.`Charged Weight` > 3.5 and i.`Charged Weight` <= 4.0 then 4.0
            when i.`Charged Weight` > 4.0 and i.`Charged Weight` <= 4.5 then 4.5
			end as Weight_slab_charged_by_Courier_Company_KG,
            z.Zone as Delivery_Zone_as_per_X,
            i.Zone as Delivery_Zonecharged_by_Courier_Company,
            i.`Type of Shipment`,
            i.`Billing Amount (Rs.)` as  Charges_Billed_by_Courier_Company_Rs


    from courier_company_invoice i 
    left join grouped_order_weights g
    on i.`Order ID`  = g.`ExternOrderNo`
    join company_x_pincode_zones z 
    on i.`Warehouse Pincode`= z.`Warehouse Pincode` and i.`Customer Pincode`= z.`Customer Pincode`),
    
    final_join_rates as(
    select *,
		case when j.`weight_slab_as_per_X_KG` < 0.5 and j.`Type of Shipment` = 'Forward charges' and j.Delivery_Zone_as_per_X = 'a' then r.`fixed charges`
        when j.`weight_slab_as_per_X_KG` <= 0.5 and j.`Type of Shipment` = 'Forward charges' and j.Delivery_Zone_as_per_X = 'b' then r.`fixed charges`
        when j.`weight_slab_as_per_X_KG` <= 0.5 and j.`Type of Shipment` = 'Forward charges' and j.Delivery_Zone_as_per_X = 'c' then r.`fixed charges`
        when j.`weight_slab_as_per_X_KG` <= 0.5 and j.`Type of Shipment` = 'Forward charges' and j.Delivery_Zone_as_per_X = 'd' then r.`fixed charges`
        when j.`weight_slab_as_per_X_KG` <= 0.5 and j.`Type of Shipment` = 'Forward charges' and j.Delivery_Zone_as_per_X = 'e' then r.`fixed charges`
        when j.`weight_slab_as_per_X_KG` > 0.5 and j.`Type of Shipment` = 'Forward charges' and j.Delivery_Zone_as_per_X = 'a' then (r.`fixed charges`+ (j.`weight_slab_as_per_X_KG`-0.5)*2*r.`additional charges`)
        when j.`weight_slab_as_per_X_KG` > 0.5 and j.`Type of Shipment` = 'Forward charges' and j.Delivery_Zone_as_per_X = 'b' then (r.`fixed charges`+ (j.`weight_slab_as_per_X_KG`-0.5)*2*r.`additional charges`) 
        when j.`weight_slab_as_per_X_KG` > 0.5 and j.`Type of Shipment` = 'Forward charges' and j.Delivery_Zone_as_per_X = 'c' then (r.`fixed charges`+ (j.`weight_slab_as_per_X_KG`-0.5)*2*r.`additional charges`)
        when j.`weight_slab_as_per_X_KG` > 0.5 and j.`Type of Shipment` = 'Forward charges' and j.Delivery_Zone_as_per_X = 'd' then (r.`fixed charges`+ (j.`weight_slab_as_per_X_KG`-0.5)*2*r.`additional charges`)
        when j.`weight_slab_as_per_X_KG` > 0.5 and j.`Type of Shipment` = 'Forward charges' and j.Delivery_Zone_as_per_X = 'e' then (r.`fixed charges`+ (j.`weight_slab_as_per_X_KG`-0.5)*2*r.`additional charges`)
        when j.`weight_slab_as_per_X_KG` <= 0.5 and j.`Type of Shipment` = 'Forward and RTO charges' and j.Delivery_Zone_as_per_X = 'a' then r.`fixed charges`
        when j.`weight_slab_as_per_X_KG` <= 0.5 and j.`Type of Shipment` = 'Forward and RTO charges' and j.Delivery_Zone_as_per_X = 'b' then r.`fixed charges`
        when j.`weight_slab_as_per_X_KG` <= 0.5 and j.`Type of Shipment` = 'Forward and RTO charges' and j.Delivery_Zone_as_per_X = 'c' then r.`fixed charges`
        when j.`weight_slab_as_per_X_KG` <= 0.5 and j.`Type of Shipment` = 'Forward and RTO charges' and j.Delivery_Zone_as_per_X = 'd' then r.`fixed charges`
        when j.`weight_slab_as_per_X_KG` <= 0.5 and j.`Type of Shipment` = 'Forward and RTO charges' and j.Delivery_Zone_as_per_X = 'e' then r.`fixed charges`
        when j.`weight_slab_as_per_X_KG` > 0.5 and j.`Type of Shipment` = 'Forward and RTO charges' and j.Delivery_Zone_as_per_X = 'a' then (r.`fixed charges`+ (j.`weight_slab_as_per_X_KG`-0.5)*2*r.`additional charges`)
        when j.`weight_slab_as_per_X_KG` > 0.5 and j.`Type of Shipment` = 'Forward and RTO charges' and j.Delivery_Zone_as_per_X = 'b' then (r.`fixed charges`+ (j.`weight_slab_as_per_X_KG`-0.5)*2*r.`additional charges`)
        when j.`weight_slab_as_per_X_KG` > 0.5 and j.`Type of Shipment` = 'Forward and RTO charges' and j.Delivery_Zone_as_per_X = 'c' then (r.`fixed charges`+ (j.`weight_slab_as_per_X_KG`-0.5)*2*r.`additional charges`)
        when j.`weight_slab_as_per_X_KG` > 0.5 and j.`Type of Shipment` = 'Forward and RTO charges' and j.Delivery_Zone_as_per_X = 'd' then (r.`fixed charges`+ (j.`weight_slab_as_per_X_KG`-0.5)*2*r.`additional charges`)
        when j.`weight_slab_as_per_X_KG` > 0.5 and j.`Type of Shipment` = 'Forward and RTO charges' and j.Delivery_Zone_as_per_X = 'e' then (r.`fixed charges`+ (j.`weight_slab_as_per_X_KG`-0.5)*2*r.`additional charges`)
        end as Expected_Charge_as_per_X_RS
    
    from invoice_join_order j left join courier_company_rates r
    on j.`Type of Shipment`= r.charges_type and j.Delivery_Zone_as_per_X = r.zone)
    
    
    select `Order ID`, 
			`AWB Code`,
			`total_weight_as_per_X_KG`,
            `weight_slab_as_per_X_KG`, 
            Total_weight_as_per_Courier_Company_KG,
            Weight_slab_charged_by_Courier_Company_KG,
            Delivery_Zone_as_per_X,
            Delivery_Zonecharged_by_Courier_Company,
            Expected_Charge_as_per_X_RS,
            Charges_Billed_by_Courier_Company_Rs,
            (Expected_Charge_as_per_X_RS - Charges_Billed_by_Courier_Company_Rs) as Difference_Between_Expected_Charges_and_Billed_Charges_Rs
    from final_join_rates);
    
 -- for first output   
    select * from output_1;
    
    
-- for second out put
    select mark, 
			count(mark) as counts,
			sum(if(difference=0, Expected_Charge_as_per_X_RS, difference))   as Amount_Rs
    from (
		select Difference_Between_Expected_Charges_and_Billed_Charges_Rs as difference,
			Expected_Charge_as_per_X_RS,
			case when Difference_Between_Expected_Charges_and_Billed_Charges_Rs = 0 then 'Total orders where X has been correctly charged'
				 when Difference_Between_Expected_Charges_and_Billed_Charges_Rs > 0 then 'Total orders where X has been undercharged'
				 when Difference_Between_Expected_Charges_and_Billed_Charges_Rs < 0 then 'Total orders where X has been overcharged'
				 end as mark
		from output_1) x
        group by mark;

    
    
    
    

    
    
    
    
    





