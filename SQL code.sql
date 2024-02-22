--inspecting data
select * from [PortfolioDB].[dbo].[sales_data]

--checking unique values
select distinct PRODUCTLINE from [PortfolioDB].[dbo].[sales_data] --Nice to plot
select distinct STATUS from [PortfolioDB].[dbo].[sales_data] --Nice to plot
select distinct COUNTRY from [PortfolioDB].[dbo].[sales_data] --Nice to plot
select distinct DEALSIZE from [PortfolioDB].[dbo].[sales_data] --Nice to plot
select distinct YEAR_ID from [PortfolioDB].[dbo].[sales_data]
select distinct TERRITORY from [PortfolioDB].[dbo].[sales_data] --Nice to plot


--ANALYSIS 
--I am starting by grouping sales by product line
select PRODUCTLINE , sum(SALES) as REVENUE
from [PortfolioDB].[dbo].[sales_data]
group by PRODUCTLINE
order by 2 DESC


select YEAR_ID , sum(SALES) as REVENUE
from [PortfolioDB].[dbo].[sales_data]
group by YEAR_ID
order by 2 DESC


select DEALSIZE , sum(SALES) as REVENUE
from [PortfolioDB].[dbo].[sales_data]
group by DEALSIZE
order by 2 DESC


-- What was the best month for sales in a specific year?
select MONTH_ID , sum(SALES) as REVENUE ,count(ORDERNUMBER) as FREQUENCY
from [PortfolioDB].[dbo].[sales_data]
where YEAR_ID =2004
group by MONTH_ID
order by 2 DESC

-- November seems to be the month with most sales . What products are sold this month?
select MONTH_ID,PRODUCTLINE , sum(SALES) as REVENUE 
from [PortfolioDB].[dbo].[sales_data]
where MONTH_ID = 11 and YEAR_ID =2004
group by MONTH_ID,PRODUCTLINE
order by 3 DESC

--What is the best costumer ? (RFM analysis)

DROP TABLE IF EXISTS #rfm
;with rfm as(
	select 
		CUSTOMERNAME, 
		sum(sales) as MonetaryValue,
		avg(sales) as AvgMonetaryValue,
		count(ORDERNUMBER) as Frequency,
		max(ORDERDATE) as last_order_date,
		(select max(ORDERDATE) from [PortfolioDB].[dbo].[sales_data]) as max_order_date,
		DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE) from [PortfolioDB].[dbo].[sales_data])) as Recency
	from [PortfolioDB].[dbo].[sales_data]
	group by CUSTOMERNAME
),
rfm_calc as(

select r.*,
		NTILE(4) OVER (order by Recency desc) rfm_recency,
		NTILE(4) OVER (order by Frequency) rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) rfm_monetary
from rfm r
)
select 
	c.*, rfm_recency+rfm_frequency + rfm_monetary as rfm_cell,
	cast(rfm_recency as varchar)+cast(rfm_frequency as varchar)+ cast( rfm_monetary as varchar) as rfm_cell_string
into #rfm
from rfm_calc c




select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment

from #rfm






---EXTRAs----
--What city has the highest number of sales in a specific country
select city, sum (sales) Revenue
from [PortfolioDB].[dbo].[sales_data]
where country = 'UK'
group by city
order by 2 desc



---What is the best product in United States?
select country, YEAR_ID, PRODUCTLINE, sum(sales) Revenue
from [PortfolioDB].[dbo].[sales_data]
where country = 'USA'
group by  country, YEAR_ID, PRODUCTLINE
order by 4 desc
