create table messy_data_dirty(
order_id text,
customer_id text,
order_date text,
country text,
category text,
product text,
quantity text,
unit_price text,
total_amount text,
status text,
payment_method text,
is_returned text
);

select * from messy_data_dirty;

--staging tables in the database for data cleaning 

create table clean_messy_date as 
select * from messy_data_dirty;

select * from clean_messy_date;

select *,
row_number() over(partition by order_id,customer_id,order_date,country,category,product,quantity,
unit_price,total_amount,status,payment_method,is_returned ) as row_num 
from clean_messy_date;

-- time to remove duplicate from the dataset 

create table clean_messy_date_1(
order_id text,
customer_id text,
order_date text,
country text,
category text,
product text,
quantity text,
unit_price text,
total_amount text,
status text,
payment_method text,
is_returned text,
row_num int
);

insert into clean_messy_date_1 
select *,
row_number() over(partition by order_id,customer_id,order_date,country,category,product,quantity,
unit_price,total_amount,status,payment_method,is_returned ) as row_num 
from clean_messy_date;

select * from clean_messy_date_1;

with duplicate_cte as (
select *,
row_number() over(partition by order_id,customer_id,order_date,country,category,product,quantity,
unit_price,total_amount,status,payment_method,is_returned ) as row_num 
from clean_messy_date
)
select * from duplicate_cte 
where row_num >1;

select * from clean_messy_date_1 
where row_num >1;

delete from clean_messy_date_1
where row_num >1;

-- time to the standardize the dataset 

-- country 
select country from clean_messy_date_1;

select distinct country from clean_messy_date_1;

select country,trim(country) from clean_messy_date_1;

select country,initcap(trim(country)) from clean_messy_date_1;

update clean_messy_date_1 set country=trim(country);

update clean_messy_date_1 set country=initcap(trim(country));

select distinct country,
case 
when country in('Uk','U.K.') then 'United Kingdom'
when country in('U.S.A','Usa','Us') then 'United States'
when country='De' then 'Germany'
when country='Aus' then 'Australia'
else country 
end 
from  clean_messy_date_1;

update  clean_messy_date_1 set country=
case 
when country in('Uk','U.K.') then 'United Kingdom'
when country in('U.S.A','Usa','Us') then 'United States'
when country='De' then 'Germany'
when country='Aus' then 'Australia'
else country 
end 

-- category 
select category  from clean_messy_date_1;

select distinct category  from clean_messy_date_1;

select category ,trim(category ) from clean_messy_date_1;

select category ,initcap(trim(category)) from clean_messy_date_1;

update clean_messy_date_1 set category =trim(category );

update clean_messy_date_1 set category =initcap(trim(category ));

select * from clean_messy_date_1 
where category in ('Home And Garden','Home & Garden')

select distinct category,
case 
when category='Home And Garden' then 'Home & Garden'
else category
end 
from clean_messy_date_1;

update clean_messy_date_1 set category=
case 
when category='Home And Garden' then 'Home & Garden'
else category
end 

select * from clean_messy_date_1;

-- product 

select product from clean_messy_date_1;

select distinct product from clean_messy_date_1;

-- status 

select status from clean_messy_date_1;

select distinct status from clean_messy_date_1;

select status,trim(status) from clean_messy_date_1;

select status ,initcap(trim(status)) from clean_messy_date_1;

update clean_messy_date_1 set status =trim(status);

update clean_messy_date_1 set status =initcap(trim(status));

--payment_method 

select payment_method from clean_messy_date_1;

select distinct payment_method  from clean_messy_date_1;

select distinct payment_method,trim(payment_method) from clean_messy_date_1;

select distinct payment_method ,initcap(trim(payment_method)) from clean_messy_date_1;

-- is_returned 

select is_returned from clean_messy_date_1;

select distinct is_returned from clean_messy_date_1;

select distinct is_returned ,trim(is_returned) from clean_messy_date_1;

update clean_messy_date_1 set is_returned =trim(is_returned);

select distinct is_returned,
case 
when is_returned in ('yes','Yes','Y','1','TRUE','True') then 'YES'
when is_returned in ('False','N','no','0','FALSE','No') then 'NO'
else is_returned
end 
from clean_messy_date_1;

update clean_messy_date_1 set is_returned=
case 
when is_returned in ('yes','Yes','Y','1','TRUE','True') then 'YES'
when is_returned in ('False','N','no','0','FALSE','No') then 'NO'
else is_returned
end 

-- quantity 

select quantity  from clean_messy_date_1;

select distinct quantity from clean_messy_date_1;

select distinct quantity,trim(quantity) from clean_messy_date_1;

select distinct quantity,
case 
when quantity::int <0 then abs(quantity::int)
when quantity::int =0 then  null
else quantity::int
end 
from clean_messy_date_1;

update clean_messy_date_1 set quantity=
case 
when quantity::int <0 then abs(quantity::int)
when quantity::int =0 then  null
else quantity::int
end 

select quantity from clean_messy_date_1
where quantity is null;

select * from clean_messy_date_1
where quantity is null;

alter table clean_messy_date_1 
alter column quantity type int 
using quantity::int;

select round(avg(quantity),1) from clean_messy_date_1;

-- total_amount

select total_amount from clean_messy_date_1;

select distinct total_amount from clean_messy_date_1;

select distinct total_amount,trim(total_amount) from clean_messy_date_1;

select total_amount from clean_messy_date_1
where total_amount like '-%';

select total_amount from clean_messy_date_1
where total_amount = '0.0';

select distinct total_amount,
case 
when total_amount::numeric <0 then abs(total_amount::numeric)
when total_amount::numeric =0.0 then  null
else total_amount::numeric
end 
from clean_messy_date_1;

update clean_messy_date_1 set total_amount=
case 
when total_amount::numeric <0 then abs(total_amount::numeric)
when total_amount::numeric = 0.0 then  null
else total_amount::numeric
end 

select total_amount from clean_messy_date_1
where total_amount is null;

select * from clean_messy_date_1
where total_amount is null;

alter table clean_messy_date_1 
alter column total_amount type numeric 
using total_amount::numeric;

select round(avg(total_amount),1) from clean_messy_date_1;


-- unit_price 

select unit_price from clean_messy_date_1;

select distinct unit_price from clean_messy_date_1;

select distinct unit_price,trim(unit_price) from clean_messy_date_1;

select unit_price from clean_messy_date_1
where unit_price like '$%';

select unit_price from clean_messy_date_1
where unit_price like '£%';

select unit_price from clean_messy_date_1
where unit_price like '€%';


-- order_date 

select order_date from clean_messy_date_1;

select distinct order_date from clean_messy_date_1;

select distinct order_date,trim(order_date) from clean_messy_date_1;

create or replace function safe_to_date(p_date text,p_format text)
returns date
language plpgsql
as $$

begin
return to_date(trim(p_date),p_format);
exception 
when others then return null;

end; 
$$;

select distinct order_date,
coalesce(
--ISO format 
safe_to_date(replace(replace(trim(order_date),'/','-'),'-','.'),'YYYY-MM-DD'),

--EU format 
safe_to_date(order_date,'YYYY/MM/DD'),

--US format 
safe_to_date(order_date,'YYYY/DD/MM'),

--other format 
safe_to_date(order_date,'Months DD,YYYY'),
safe_to_date(order_date,'Months DD YYYY'),
safe_to_date(order_date,'Mon DD,YYYY'),
safe_to_date(order_date,'Mon DD YYYY'),
safe_to_date(order_date,'DD/MM/YYYY'),
safe_to_date(order_date,'DD-MM-YYYY'),
safe_to_date(order_date,'MM-DD-YYYY'),
safe_to_date(order_date,'DD Mon YYYY')
) end 
from clean_messy_date_1;

update clean_messy_date_1 set order_date =
coalesce(
--ISO format 
safe_to_date(replace(replace(trim(order_date),'/','-'),'-','.'),'YYYY-MM-DD'),

--EU format 
safe_to_date(order_date,'YYYY/MM/DD'),

--US format 
safe_to_date(order_date,'YYYY/DD/MM'),

--other format 
safe_to_date(order_date,'Months DD,YYYY'),
safe_to_date(order_date,'Months DD YYYY'),
safe_to_date(order_date,'Mon DD,YYYY'),
safe_to_date(order_date,'Mon DD YYYY'),
safe_to_date(order_date,'DD/MM/YYYY'),
safe_to_date(order_date,'DD-MM-YYYY'),
safe_to_date(order_date,'MM-DD-YYYY'),
safe_to_date(order_date,'DD Mon YYYY')
);

select order_date from clean_messy_date_1 
where order_date is null;

-- time work on null columns and values in the dateset 

select 
count(*) as check_null_values,
count(*)-count(order_id) as order_id_null,
count(*)-count(customer_id) as customer_id_null,
count(*)-count(order_date) as order_date_null,
count(*)-count(country) as country_null,
count(*)-count(category) as category_null,
count(*)-count(product) as product_null,
count(*)-count(quantity) as quantity_null,
count(*)-count(unit_price) as unit_price_null,
count(*)-count(total_amount) as total_amount_null,
count(*)-count(status) as status_null,
count(*)-count(payment_method) as paymethod_null,
count(*)-count(is_returned) as is_returned_null
from clean_messy_date_1;

select * from clean_messy_date_1
where customer_id is null or customer_id ='';

-- removing null columns in customer_id which also had a lot of null values in other columns 

delete from clean_messy_date_1
where customer_id is null;

select * from clean_messy_date_1;

select * from clean_messy_date_1
where country is null ;

select * from clean_messy_date_1
where category is null ;

select * from clean_messy_date_1
where quantity is null ;

select * from clean_messy_date_1
where total_amount is null ;

select * from clean_messy_date_1
where unit_price is null ;

select round(avg(quantity),1) from clean_messy_date_1;

select round(avg(total_amount),1) from clean_messy_date_1;

-- using then median number fill null values in quantity and total_amount column 

select quantity, total_amount,
coalesce( quantity ,5) as quantity1,
coalesce( total_amount, 1811.4) as total_amount1
from clean_messy_date_1;

select quantity, total_amount,
coalesce( quantity ,5) as quantity,
coalesce( total_amount, 1811.4) as total_amount
from clean_messy_date_1
where quantity is null and total_amount is null;

update clean_messy_date_1 set 
quantity=coalesce(quantity,5), 
total_amount= coalesce( total_amount, 1811.4); 

select country,category,
coalesce(country,'Unknown') as country1,
coalesce(category,'Unknown') as category1
from clean_messy_date_1
where country is null and category is null;

update clean_messy_date_1 set 
country=coalesce(country,'Unknown'),
category=coalesce(category,'Unknown');


select unit_price,
case 
when unit_price like '$%' then 'USD'
when unit_price like '£%' then 'GBP'
when unit_price like '€%' then 'EUR'
else unit_price 
end as Currency,

replace(replace(replace(replace(unit_price,'$',''),'£',''),'€',''),',',''):: numeric as amount_payment
from clean_messy_date_1;

alter table clean_messy_date_1 
add column Currency varchar(15),
add column amount_payment numeric;

update clean_messy_date_1 
set Currency=
case 
when unit_price like '$%' then 'USD'
when unit_price like '£%' then 'GBP'
when unit_price like '€%' then 'EUR'

end,
amount_payment=
replace(replace(replace(replace(unit_price,'$',''),'£',''),'€',''),',',''):: numeric;
 
 
alter table clean_messy_date_1
drop column row_num;

-- exploratory data anaylsis

select min(order_date),max(order_date)
from clean_messy_date_1;

select max(order_date::date) - min(order_date::date) as timespan
from clean_messy_date_1;

select sum(quantity),avg(quantity),max(quantity),min(quantity),count(quantity)
from clean_messy_date_1;

select sum(total_amount),round(avg(total_amount),1),round(max(total_amount),1),
min(total_amount),count(total_amount)
from clean_messy_date_1;

select sum(amount_payment),round(avg(amount_payment),1),round(max(amount_payment),1),
min(amount_payment),count(amount_payment)
from clean_messy_date_1;


-- country aggre(total_amount)

select country, sum(total_amount) as sum_amount
from clean_messy_date_1
group by country
order by 2 desc;

select country, round(avg(total_amount),1) as avg_amount
from clean_messy_date_1
group by country
order by 2 desc;

select country, round(max(total_amount),1) as max_amount
from clean_messy_date_1
group by country
order by 2 desc;

select country, min(total_amount) as min_amount
from clean_messy_date_1
group by country
order by 2 desc;

select country, count(total_amount) as count_amount
from clean_messy_date_1
group by country
order by 2 desc;

--country aggre(quantity)

select country, sum(quantity) as sum_quantity
from clean_messy_date_1
group by country
order by 2 desc;

select country, round(avg(quantity),1) as avg_quantity
from clean_messy_date_1
group by country
order by 2 desc;

select country, round(max(quantity),1) as max_quantity
from clean_messy_date_1
group by country
order by 2 desc;

select country, min(quantity) as min_quantity
from clean_messy_date_1
group by country
order by 2 desc;

select country, count(quantity) as count_amount
from clean_messy_date_1
group by country
order by 2 desc;

--country aggre(amount_payment)

select country, sum(amount_payment) as sum_amount_payment_quantity
from clean_messy_date_1
group by country
order by 2 desc;

select country, round(avg(amount_payment),1) as avg_amount_payment_quantity
from clean_messy_date_1
group by country
order by 2 desc;

select country, round(max(amount_payment),1) as max_amount_payment_quantity
from clean_messy_date_1
group by country
order by 2 desc;

select country, min(amount_payment) as min_amount_payment_quantity
from clean_messy_date_1
group by country
order by 2 desc;

select country, count(amount_payment) as count_amount_payment_amount
from clean_messy_date_1
group by country
order by 2 desc;

-- category aggre(total_amount)

select category, sum(total_amount) as sum_amount
from clean_messy_date_1
group by category 
order by 2 desc;

select category, round(avg(total_amount),1) as avg_amount
from clean_messy_date_1
group by category 
order by 2 desc;

select category, round(max(total_amount),1) as max_amount
from clean_messy_date_1
group by category 
order by 2 desc;

select category, min(total_amount) as min_amount
from clean_messy_date_1
group by category 
order by 2 desc;

select category, count(total_amount) as count_amount
from clean_messy_date_1
group by category 
order by 2 desc;

--category  aggre(quantity)

select category, sum(quantity) as sum_quantity
from clean_messy_date_1
group by category 
order by 2 desc;

select category, round(avg(quantity),1) as avg_quantity
from clean_messy_date_1
group by category 
order by 2 desc;

select category, round(max(quantity),1) as max_quantity
from clean_messy_date_1
group by category 
order by 2 desc;

select category , min(quantity) as min_quantity
from clean_messy_date_1
group by category 
order by 2 desc;

select category , count(quantity) as count_amount
from clean_messy_date_1
group by category 
order by 2 desc;

--category aggre(amount_payment)

select category, sum(amount_payment) as sum_amount_payment_quantity
from clean_messy_date_1
group by category 
order by 2 desc;

select category, round(avg(amount_payment),1) as avg_amount_payment_quantity
from clean_messy_date_1
group by category 
order by 2 desc;

select category, round(max(amount_payment),1) as max_amount_payment_quantity
from clean_messy_date_1
group by category 
order by 2 desc;

select category , min(amount_payment) as min_amount_payment_quantity
from clean_messy_date_1
group by category 
order by 2 desc;

select category , count(amount_payment) as count_amount_payment_amount
from clean_messy_date_1
group by category 
order by 2 desc;

-- product aggre(total_amount)

select product, sum(total_amount) as sum_amount
from clean_messy_date_1
group by product
order by 2 desc;

select product, round(avg(total_amount),1) as avg_amount
from clean_messy_date_1
group by product
order by 2 desc;

select product, round(max(total_amount),1) as max_amount
from clean_messy_date_1
group by product
order by 2 desc;

select product, min(total_amount) as min_amount
from clean_messy_date_1
group by product
order by 2 desc;

select product, count(total_amount) as count_amount
from clean_messy_date_1
group by product
order by 2 desc;

--product aggre(quantity)

select product, sum(quantity) as sum_quantity
from clean_messy_date_1
group by product
order by 2 desc;

select product, round(avg(quantity),1) as avg_quantity
from clean_messy_date_1
group by product
order by 2 desc;

select product, round(max(quantity),1) as max_quantity
from clean_messy_date_1
group by product
order by 2 desc;

select product, min(quantity) as min_quantity
from clean_messy_date_1
group by product
order by 2 desc;

select product, count(quantity) as count_amount
from clean_messy_date_1
group by product
order by 2 desc;

--product aggre(amount_payment)

select product, sum(amount_payment) as sum_amount_payment_quantity
from clean_messy_date_1
group by product
order by 2 desc;

select product, round(avg(amount_payment),1) as avg_amount_payment_quantity
from clean_messy_date_1
group by product
order by 2 desc;

select product, round(max(amount_payment),1) as max_amount_payment_quantity
from clean_messy_date_1
group by product
order by 2 desc;

select product, min(amount_payment) as min_amount_payment_quantity
from clean_messy_date_1
group by product
order by 2 desc;

select product, count(amount_payment) as count_amount_payment_amount
from clean_messy_date_1
group by product
order by 2 desc;

--  status aggre(total_amount)

select status, sum(total_amount) as sum_amount
from clean_messy_date_1
group by status
order by 2 desc;

select status, round(avg(total_amount),1) as avg_amount
from clean_messy_date_1
group by status
order by 2 desc;

select status, round(max(total_amount),1) as max_amount
from clean_messy_date_1
group by status
order by 2 desc;

select status, min(total_amount) as min_amount
from clean_messy_date_1
group by status
order by 2 desc;

select status, count(total_amount) as count_amount
from clean_messy_date_1
group by status
order by 2 desc;

--status aggre(quantity)

select status, sum(quantity) as sum_quantity
from clean_messy_date_1
group by status
order by 2 desc;

select status, round(avg(quantity),1) as avg_quantity
from clean_messy_date_1
group by status
order by 2 desc;

select status, round(max(quantity),1) as max_quantity
from clean_messy_date_1
group by status
order by 2 desc;

select status, min(quantity) as min_quantity
from clean_messy_date_1
group by status
order by 2 desc;

select status, count(quantity) as count_amount
from clean_messy_date_1
group by status
order by 2 desc;

--status aggre(amount_payment)

select status, sum(amount_payment) as sum_amount_payment_quantity
from clean_messy_date_1
group by status
order by 2 desc;

select status, round(avg(amount_payment),1) as avg_amount_payment_quantity
from clean_messy_date_1
group by status
order by 2 desc;

select status, round(max(amount_payment),1) as max_amount_payment_quantity
from clean_messy_date_1
group by status
order by 2 desc;

select status, min(amount_payment) as min_amount_payment_quantity
from clean_messy_date_1
group by status
order by 2 desc;

select status, count(amount_payment) as count_amount_payment_amount
from clean_messy_date_1
group by status
order by 2 desc;

-- payment_method aggre(total_amount)

select payment_method, sum(total_amount) as sum_amount
from clean_messy_date_1
group by payment_method
order by 2 desc;

select payment_method, round(avg(total_amount),1) as avg_amount
from clean_messy_date_1
group by payment_method
order by 2 desc;

select payment_method, round(max(total_amount),1) as max_amount
from clean_messy_date_1
group by payment_method
order by 2 desc;

select payment_method, min(total_amount) as min_amount
from clean_messy_date_1
group by payment_method
order by 2 desc;

select payment_method, count(total_amount) as count_amount
from clean_messy_date_1
group by payment_method
order by 2 desc;

--payment_method aggre(quantity)

select payment_method, sum(quantity) as sum_quantity
from clean_messy_date_1
group by payment_method
order by 2 desc;

select payment_method, round(avg(quantity),1) as avg_quantity
from clean_messy_date_1
group by payment_method
order by 2 desc;

select payment_method, round(max(quantity),1) as max_quantity
from clean_messy_date_1
group by payment_method
order by 2 desc;

select payment_method, min(quantity) as min_quantity
from clean_messy_date_1
group by payment_method
order by 2 desc;

select payment_method, count(quantity) as count_amount
from clean_messy_date_1
group by payment_method
order by 2 desc;

--payment_method aggre(amount_payment)

select payment_method, sum(amount_payment) as sum_amount_payment_quantity
from clean_messy_date_1
group by payment_method
order by 2 desc;

select payment_method, round(avg(amount_payment),1) as avg_amount_payment_quantity
from clean_messy_date_1
group by payment_method
order by 2 desc;

select payment_method, round(max(amount_payment),1) as max_amount_payment_quantity
from clean_messy_date_1
group by payment_method
order by 2 desc;

select payment_method, min(amount_payment) as min_amount_payment_quantity
from clean_messy_date_1
group by payment_method
order by 2 desc;

select payment_method, count(amount_payment) as count_amount_payment_amount
from clean_messy_date_1
group by payment_method
order by 2 desc;

select * from clean_messy_date_1;

--rolling sum 

select substring(country,1,20) as country1, sum(total_amount) as total_amount1
from clean_messy_date_1 
where substring(country,1,10) is not null 
group by country1 
order by 2 desc;

with rolling_sum as (
select substring(country,1,20) as country1, sum(total_amount) as total_amount1
from clean_messy_date_1 
where substring(country,1,10) is not null 
group by country1 
order by 2 desc
)
select country1,total_amount1,sum(total_amount1)
over(order by country1)
from rolling_sum;

select substring(category,1,20)as category1,sum(total_amount) as total_amount
from clean_messy_date_1
where substring(category,1,10) is not null
group by category1
order by 2 desc; 

with rolling_sum as (
select substring(category,1,20)as category1,sum(total_amount) as total_amount
from clean_messy_date_1
where substring(category,1,10) is not null
group by category1
order by 2 desc
)
select category1,total_amount,sum(total_amount)
over(order by category1)
from rolling_sum;

select order_date,total_amount,sum(total_amount)
over(order by order_date)
from rolling_sum;

select total_amount,country from clean_messy_date_1
where total_amount > (select avg(total_amount) from clean_messy_date_1);

alter table clean_messy_date_1 
alter column order_date type date 
using order_date:: date;

-- ranking 
select country,extract(year from order_date)as years,sum(total_amount) as total_amount
from clean_messy_date_1 
group by country,extract(year from order_date)
order by 3 desc;

with ranking_total as(
select country,extract(year from order_date)as years,sum(total_amount) as total_amount
from clean_messy_date_1 
where order_date is not null
group by country,extract(year from order_date)
),
ranking_total_final as (
select country,years,total_amount,
dense_rank()over(partition by years order by total_amount desc) as ranking 
from ranking_total 
where country is not null and total_amount is not null
)
select * from ranking_total_final
where ranking <=5;

select category,extract(year from order_date)as years,sum(total_amount) as total_amount
from clean_messy_date_1
group by category,extract(year from order_date)
order by 3 desc;

with ranking_total as (
select category,extract(year from order_date)as years,sum(total_amount) as total_amount
from clean_messy_date_1
where order_date is not null
group by category,extract(year from order_date)
),
ranking_total_final as (
select category,years,total_amount,
dense_rank()over(partition by years order by total_amount desc) as ranking
from ranking_total
where category is not null and total_amount is not null
)
select * from ranking_total_final
where ranking <=5;

-- advance analysis 

-- change over time Trend 
select extract(year from order_date) as order_year,
sum(total_amount) as total_amount,
count(customer_id) as num_of_customers,
sum(quantity) as total_quantity 
from clean_messy_date_1 
where order_date is not null 
group by extract(year from order_date)
order by 1,2,3,4;


select extract(year from order_date) as order_year,
extract(month from order_date) as order_month,
count(customer_id) as num_customers, 
sum(quantity) as total_quantity,
sum(total_amount) as total_amount 
from clean_messy_date_1 
where order_date is not null 
group by extract(year from order_date),extract(month from order_date)
order by 1,2,3;

--cumulative analysis
select country,extract(year from order_date) as order_year, 
count(customer_id) as total_customer, 
sum(quantity) as total_quantity,
sum(total_amount) as total_amount
from clean_messy_date_1
where order_date is not null
group by country,extract(year from order_date)
order by 2,1;

with cum_total_yearly as (
select country,extract(year from order_date) as order_year, 
count(customer_id) as total_customer, 
sum(quantity) as total_quantity,
sum(total_amount) as total_amount
from clean_messy_date_1
where order_date is not null
group by country,extract(year from order_date)
)
select country,order_year,total_customer,total_quantity 
,total_amount ,sum(total_amount) over(partition by order_year order by country) as total_amount_yearly,
sum(total_customer) over(partition by order_year order by country) as total_customer_yearly,
sum(total_quantity) over(partition by order_year order by country) as total_quanity_yearly
from cum_total_yearly
order by order_year
;

select country,extract(year from order_date) as order_year, 
extract(month from order_date) as order_month,
count(customer_id) as total_customer, 
sum(quantity) as total_quantity,
sum(total_amount) as total_amount
from clean_messy_date_1
where order_date is not null
group by country,extract(year from order_date),extract(month from order_date) 
order by 1,2,3;

with cum_monthly as (
select country,extract(year from order_date) as order_year, 
extract(month from order_date) as order_month,
count(customer_id) as total_customer, 
sum(quantity) as total_quantity,
sum(total_amount) as total_amount
from clean_messy_date_1
where order_date is not null
group by country,extract(year from order_date),extract(month from order_date) 
)
select country,order_year,order_month,total_customer,total_quantity,total_amount,
sum(total_amount) over(partition by order_year,order_month order by country) as total_amount_monthy,
sum(total_customer) over(partition by order_year,order_month order by country) as total_customer_monthly,
sum(total_quantity)  over(partition by order_year,order_month order by country) as total_quantity_monthly
from cum_monthly
order by order_year,order_month,country;

select category,extract(year from order_date) as order_year, 
count(customer_id) as total_customer, 
sum(quantity) as total_quantity,
sum(total_amount) as total_amount
from clean_messy_date_1
where order_date is not null
group by category,extract(year from order_date)
order by 2,1;

with cum_yearly_cate as (
select category,extract(year from order_date) as order_year, 
count(customer_id) as total_customer, 
sum(quantity) as total_quantity,
sum(total_amount) as total_amount
from clean_messy_date_1
where order_date is not null
group by category,extract(year from order_date)
)
select category,order_year,total_customer,total_quantity 
,total_amount ,sum(total_amount) over(partition by order_year order by category) as total_amount_yearly,
sum(total_customer) over(partition by order_year order by category) as total_customer_yearly,
sum(total_quantity) over(partition by order_year order by category) as total_quanity_yearly
from cum_yearly_cate
order by order_year;

---performance analysis
select extract(year from order_date),sum(total_amount)as total_amount,
avg(total_amount) as avg_total,
sum(total_amount)-avg(total_amount) as diff_amount
from clean_messy_date_1 
where order_date is not null 
group by extract(year from order_date)
order by 1,2;

with diff_amount_full as (
select extract(year from order_date) as order_year,sum(total_amount)as total_amount,
avg(total_amount) as avg_total,
sum(total_amount)-avg(total_amount) as diff_amount
from clean_messy_date_1 
where order_date is not null 
group by extract(year from order_date)
)
select order_year,total_amount,avg_total,diff_amount,
lag(total_amount)over(order by order_year),
lead(total_amount)over(order by order_year)
from diff_amount_full
order by order_year;

--country 

select country, extract(year from order_date),sum(total_amount)as total_amount,
avg(total_amount) as avg_total,
sum(total_amount)-avg(total_amount) as diff_amount
from clean_messy_date_1 
where order_date is not null 
group by country,extract(year from order_date)
order by 2,3;

with diff_amount_full as (
select country, extract(year from order_date) as order_year,sum(total_amount)as total_amount,
avg(total_amount) as avg_total,
sum(total_amount)-avg(total_amount) as diff_amount
from clean_messy_date_1 
where order_date is not null 
group by country,extract(year from order_date)
)
select country,order_year,total_amount,avg_total,diff_amount,
lag(total_amount)over(order by order_year),
lead(total_amount)over(order by order_year)
from diff_amount_full
order by order_year;

-- category 

select category, extract(year from order_date),sum(total_amount)as total_amount,
avg(total_amount) as avg_total,
sum(total_amount)-avg(total_amount) as diff_amount
from clean_messy_date_1 
where order_date is not null 
group by category,extract(year from order_date)
order by 2,3;

with diff_amount_full as (
select category, extract(year from order_date) as order_year,sum(total_amount)as total_amount,
avg(total_amount) as avg_total,
sum(total_amount)-avg(total_amount) as diff_amount
from clean_messy_date_1 
where order_date is not null 
group by category,extract(year from order_date)
)
select category,order_year,total_amount,avg_total,diff_amount,
lag(total_amount)over(order by order_year),
lead(total_amount)over(order by order_year)
from diff_amount_full
order by order_year,category;

-- part to whole 
 
select country, extract(year from order_date),
sum(total_amount)as total_amount,
from clean_messy_date_1 
where order_date is not null 
group by country,extract(year from order_date)
order by 2,3;

with percentage_country as (
select country, extract(year from order_date) as order_year,
sum(total_amount)as total_amount
from clean_messy_date_1 
where order_date is not null 
group by country,extract(year from order_date)
)
select country,order_year,total_amount,
-- Percentage of overall sales contributed by each country-year
round((100*total_amount)/sum(total_amount) over(),2) as percentage_of_overall_sales,

-- Percentage each year contributes to its country's sales
round((100*total_amount)/sum(total_amount) over(partition by country),2) as percentage_of_country_sales,

-- Percentage each country contributes to that year's sales
round((100*total_amount)/sum(total_amount) over(partition by order_year),2) as percentage_of_year_sales
from percentage_country
order by order_year,country;



