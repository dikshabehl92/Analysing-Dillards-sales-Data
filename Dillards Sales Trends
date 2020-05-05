
/*DB Platform: Teradata
Frontend Tool used: Teradata ViewPoint SQL scratchpad*/


/* Load Database*/
Database ua_dillards;

/*Objective: Sales Trend across stores over time*/

/*Exercise 1. How many distinct dates are there in the saledate column of the transaction table for each month/year combination in the database?*/

select 
EXTRACT(YEAR from saledate) AS year_num, 
EXTRACT(MONTH from saledate) AS month_num, 
count(distinct saledate) AS saledays
from TRNSACT
where stype='P' 
group by year_num, month_num
order by saledays;

/*Observations:
1. There are 27 days recorded in the database for the month of August in 2005, but 31 days recorded in the database during August 2004. 
Due to the missing data for August 2005, we will restrict our analysis of August sales to those recorded in 2004.
2. Data is missing for 3 days due to holidays -  Nov. 25 (Thanksgiving), Dec. 25 (Christmas), and March 27.
3. Since, each month has different number of days, we cannot simply add up all the sales in each month to look at sales trends across the year. We will get a skewed result as there will be more sales for the months that have more days in them. This will not reflect true buying trends. 
4. If we are looking at the sales performance associated with individual merchandise (SKU number), then we do not have to exclude August 2005 sales data. Since different stores will sell different numbers of items at different times anyway, we have no reason for assuming the missing data will affect any one SKU. */

/* Exercise 2. Use a CASE statement within an aggregate function to determine which SKU had the greatest total sales during the combined summer months of June, July, and August.*/

select 
DISTINCT SKU,
SUM(CASE WHEN EXTRACT(MONTH from saledate)=6 THEN amt END) AS june_sales, 
SUM(CASE WHEN EXTRACT(MONTH from saledate)=7 THEN amt END) AS july_sales, 
SUM(CASE WHEN EXTRACT(MONTH from saledate)=8 THEN amt END) AS aug_sales, 
(june_sales + july_sales + aug_sales ) As total_sales
from TRNSACT
where stype='P' AND saledate<'2005-08-01'
Group by SKU
order by total_sales DESC;

/*To check additional details about the items with maximum total sales-*/

SELECT TOP 5 
t.sku, 
t.june_sales, 
t.july_sales, 
t.aug_sales, 
t.total_sales, 
s.brand
FROM (Select 
DISTINCT SKU,
SUM(CASE WHEN EXTRACT(MONTH from saledate)=6 THEN amt END) AS june_sales, 
SUM(CASE WHEN EXTRACT(MONTH from saledate)=7 THEN amt END) AS july_sales, 
SUM(CASE WHEN EXTRACT(MONTH from saledate)=8 THEN amt END) AS aug_sales, 	
(june_sales + july_sales + aug_sales ) As total_sales
from TRNSACT
where stype='P' AND saledate<'2005-08-01'
Group by SKU) AS t, SKUINFO s
where t.sku = s.sku
order by t.total_sales DESC;

/*Exercise 3. How many distinct dates are there in the saledate column of the transaction table for each month/year/store combination in the database? Sort your results by the number of days per combination in ascending order.*/

Select 
EXTRACT(YEAR from saledate) AS year_num,
 EXTRACT(MONTH from saledate) AS month_num, 
store, 
count(distinct saledate) As saledays
from TRNSACT
group by year_num, month_num, store
order by saledays ASC;

/*Observations:
There are many month/year/store combinations that only have one day of transaction data stored in the database. This shows that data is missing for some months. In the upcoming queries, we will exclude months with missing data by including a criterion to check if number of sale days per month >= 20.*/


/*Exercise 4. What is the average daily revenue for each store/month/year combination in the database? Calculate this by dividing the total revenue for a group by the number of sales days available in the transaction table for that group.*/

select 
store,
EXTRACT(YEAR from saledate) AS year_num, 
EXTRACT(MONTH from saledate) AS month_num,
COUNT (DISTINCT saledate) AS saledays, sum(amt) AS rev, 
(rev/saledays) As daily_rev
from TRNSACT
where stype='P'
group by year_num, month_num, store
order by daily_rev DESC;

/*Modification:
Since there are missing sales records for August 2005, it is a good idea to remove August 2005 results from the above query.
Also, exclude all stores with less than 20 days of transaction data.*/


select 
	store,
EXTRACT(YEAR from saledate) AS year_num,
EXTRACT(MONTH from saledate) AS month_num,
COUNT (DISTINCT saledate) AS saledays, 
sum(amt) AS rev, (rev/saledays) As daily_rev
from TRNSACT
where stype='P' AND saledate<'2005-08-01'
group by year_num, month_num, store
Having saledays>19
order by saledays ASC;


/*Objective: Sales trends based on geographic location of stores*/

/*Exercise 5. What is the average daily revenue brought in by Dillard’s stores in areas of high, medium, or low levels of high school education? Define areas of “low” education as those that have high school graduation rates between 50-60%, areas of “medium” education as those that have high school graduation rates between 60.01-70%, and areas of “high” education as those that have high school graduation rates of above 70%.*/

/*I divided the problem and decided to first write a query to get number of stores within each education level.

Part a: */

Select 
EXTRACT(YEAR from saledate) AS year_num, 
EXTRACT(MONTH from saledate) AS month_num, 
t. store, 
COUNT (DISTINCT saledate) AS saledays, 
sum(amt) AS rev,
(case 
WHEN sm.msa_high>50 AND sm.msa_high<=60 THEN 'Low'
WHEN sm.msa_high>60 AND sm.msa_high<=70 THEN 'Medium'
WHEN sm.msa_high>70  THEN 'High'
ELSE 'Check'
END) As Edu_level
from TRNSACT t JOIN store_msa sm
ON t.store=sm.store
where stype='P' AND saledate<'2005-08-01'
group by YM,year_num, month_num, t.store, Edu_level
Having saledays>19;

/*Part b: Merging the above query to find daily average revenue for these education levels*/

select 
tr.Edu_level,
(SUM(tr.rev)/SUM(tr.saledays)) As daily_rev, 
from (Select 
EXTRACT(YEAR from saledate) AS year_num, 
EXTRACT(MONTH from saledate) AS month_num, 
t.store, 
COUNT (DISTINCT saledate) AS saledays, 
sum(amt) AS rev,
(case 
WHEN sm.msa_high>50 AND sm.msa_high<=60 THEN 'Low'
WHEN sm.msa_high>60 AND sm.msa_high<=70 THEN 'Medium'
WHEN sm.msa_high>70  THEN 'High'
ELSE 'Check'
END) As Edu_level
from TRNSACT t JOIN store_msa sm
ON t.store=sm.store
where stype='P' AND saledate<'2005-08-01'
group by YM,year_num, month_num, t.store, Edu_level
Having saledays>19) AS tr
group by tr.Edu_level 
order by daily_rev DESC;


/*Observation:
Average daily revenue brought in by Dillard’s stores in the low education group is the highest of all 3 groups. The average daily revenue in the medium education group is a little more than the average daily revenue in the high education group.*/


/*Exercise 6. Compare the average daily revenues of the stores with the highest median msa_income and the lowest median msa_income. In what city and state were these stores, and which store had a higher average daily revenue?*/

select 
tr.state, 
tr.city,
tr.msa_income,
(SUM(rev)/SUM(saledays)) As daily_rev
from ( Select 
t.store, 
COUNT (DISTINCT t.saledate) AS saledays, 
sum(t.amt) AS rev, 
sm.msa_income, 
sm.state, 
sm.city
from TRNSACT t JOIN store_msa sm
ON t.store=sm.store
where t.stype='P' AND saledate<'2005-08-01' AND (sm.msa_income IN ((SELECT MAX(msa_income) FROM store_msa),(SELECT MIN(msa_income) FROM store_msa)))
group by YM,t.store, sm.msa_income, sm.state, sm.city
Having saledays>19) AS tr
group by tr.msa_income, tr.state, tr.city
order by daily_rev DESC;

/*Observation: Average daily revenue is more for stores with minimum median income level and less for stores with maximum median income level*/


/**/Exercise 7: What is the brand of the sku with the greatest standard deviation in sprice? Only examine skus that have been part of over 100 transactions.


Select
DISTINCT t.SKU, 
s.brand, 
min(t.sprice), 
max(t.sprice), 
STDDEV_SAMP(t.sprice) As Price_Deviation, 
COUNT (Distinct (t.SEQ||t.STORE||t.REGISTER||t.TRANNUM||t.SALEDATE)) AS numtrans
from TRNSACT t JOIN SKUinfo s
ON t.SKU = s.SKU
where t.stype='P'
group by t.SKU, s.brand
Having numtrans>100
order by Price_Deviation DESC;


/*Exercise 8: Examine all the transactions for the SKU with the greatest standard deviation in sprice, but only consider SKUs that are part of more than 100 transactions.*/

SELECT 
DISTINCT t.SKU, 
t.sprice,
t.orgprice 
FROM trnsact t JOIN (Select TOP 1 
s.brand, t.SKU,
min(t.sprice) AS minval, 
max(t.sprice) AS maxval, 
STDDEV_SAMP(t.sprice) AS stdprice, 
COUNT (Distinct (t.SEQ||t.STORE||t.REGISTER||t.TRANNUM||t.SALEDATE)) AS numtrans
           from TRNSACT t JOIN SKUinfo s
           ON t.SKU = s.SKU
           where t.stype='P' AND (t.saledate<'2005-08-01') 
  		           group by s.brand, t.SKU
           Having numtrans>100
           order by stdprice DESC) AS cleaned_data
ON t.SKU=cleaned_data.SKU
ORDER BY t.sprice DESC;



/*Objective: Analyzing monthly (or seasonal) sales effects*/

/*Exercise 9: What was the average daily revenue Dillard’s brought in during each month of the year?*/

select 
month_num, 
SUM(saledays) AS num_days,
(SUM(rev)/SUM(saledays)) As daily_rev
from (Select 
EXTRACT(YEAR from saledate) AS year_num, 
EXTRACT(MONTH from saledate) AS month_num, 
COUNT (DISTINCT saledate) AS saledays, 
sum(amt) AS rev
from TRNSACT
where stype='P' AND  (t.saledate<'2005-08-01')	
group by year_num, month_num
Having saledays>19) AS tr 
group by month_num
order by daily_rev DESC;

/*Observation:
December has the best sales in the year and September has the worst sales. Even July has good number of sales but less than December.*/

/*

Exercise 10: Which department, in which city and state of what store, had the greatest % increase in average daily sales revenue from November to December?*/

select 
tr.store, 
dp.deptdesc, 
tr.dept, 
st.city, 
st.state, 
tr.percentinc 
from (Select TOP 1 
dept, 
store, 
SUM(Case WHEN EXTRACT(MONTH from saledate)= 11 THEN amt END) AS nov_amt,
SUM(Case WHEN EXTRACT(MONTH from saledate)= 12 THEN amt END) AS dec_amt,
COUNT (DISTINCT Case WHEN EXTRACT(MONTH from saledate)= 11 THEN saledate END) AS nov_days,
COUNT (DISTINCT Case WHEN EXTRACT(MONTH from saledate)= 12 THEN saledate END) AS dec_days,
nov_amt/nov_days AS ndailyrev, 
dec_amt/dec_days AS ddailyrev, 
((ddailyrev-ndailyrev)/ndailyrev)*100 AS percentinc 
from TRNSACT t JOIN SKUinfo sk
ON t.SKU=sk.SKU
where stype='P' AND (saledate<'2005-08-01')
group by store,dept
Having nov_days>19 AND dec_days>19
ORDER by percentinc DESC) AS tr JOIN STRINFO st 
ON tr.store=st.store JOIN DEPTINFO dp 
ON tr.dept=dp.dept
group by tr.store, dp.deptdesc, tr.dept, st.city, st.state, tr.percentinc;

/*Exercise 11: What is the city and state of the store that had the greatest decrease in average daily revenue from August to September?*/

select 
tr.store, 
st.city, 
st.state, 
tr.diff_daily_rev
from (Select TOP 1 
store, 
SUM(Case WHEN EXTRACT(MONTH from saledate)= 8 THEN amt END) AS aug_amt,
SUM(Case WHEN EXTRACT(MONTH from saledate)= 9 THEN amt END) AS sep_amt,
COUNT (DISTINCT Case WHEN EXTRACT(MONTH from saledate)= 8 THEN saledate END) AS aug_days,
COUNT (DISTINCT Case WHEN EXTRACT(MONTH from saledate)= 9 THEN saledate END) AS sep_days,
aug_amt/aug_days AS adailyrev, 
sep_amt/sep_days AS sdailyrev, 
(adailyrev-sdailyrev) AS diff_daily_rev
from TRNSACT 
where stype='P' AND (saledate<'2005-08-01')
group by store
Having sep_days>19 AND aug_days>19
ORDER by diff_daily_rev DESC ) AS tr JOIN STRINFO st 
ON tr.store=st.store 
group by tr.store, st.city, st.state, tr.diff_daily_rev;

/*Exercise 12: Determine the month of minimum total revenue for each store. Count the number of stores whose month of minimum total revenue was in each of the twelve months. Then determine the month of minimum average daily revenue. Count the number of stores whose month of minimum average daily revenue was in each of the twelve months. How do they compare?*/

/*To write these queries, I divided the task into sub-parts-
-	Calculate the average daily revenue for each store, for each month and order the rows as per average daily revenue from high to low
-	Assign a rank to each of the ordered rows and retrieve all of the rows that have the rank = 12
-	Count all of your retrieved rows

Part a – Query to determine the month of maximum total revenue for each store.*/

Select 
month_num, 
count(store)
from (Select 
store, 
EXTRACT(MONTH from saledate) AS month_num, 
SUM(amt) As tot_rev, 
RANK( ) OVER (PARTITION BY store ORDER BY tot_rev DESC) AS Rank_tot_rev
from trnsact
where stype='P' AND (saledate<'2005-08-01') 
Having count(distinct saledate)>19 
group by store, month_num) As t
Where Rank_tot_rev=12
group by month_num
order by month_num;

/*Part b – Query to determine the month of maximum daily average revenue for each store.*/

Select 
month_num, 
count(store) 
from (Select 
store, 
EXTRACT(MONTH from saledate) AS month_num, 
SUM(amt) As tot_rev, 
count(distinct saledate) As saledays, 
tot_rev/saledays AS daily_avg_rev, 
RANK( ) OVER (PARTITION BY store ORDER BY daily_avg_rev DESC) AS Rank_daily_avg_rev
from trnsact
where stype='P' AND (saledate<'2005-08-01') 
Having saledays>19 
group by store, month_num) As t
Where Rank_daily_avg_rev=12
group by month_num
order by month_num;

/*Observation:
77 stores have the minimum total sales in August, while 120 stores have the minimum average daily revenue in August.
Similarly, 108 stores have the minimum total sales in September, while only 72 stores have the minimum average daily revenue in September. This analysis shows a lot of outliers.*/


