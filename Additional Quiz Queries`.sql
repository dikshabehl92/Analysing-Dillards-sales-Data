/*Question 2
 How many distinct skus have the brand “Polo fas”, and are either size “XXL” or “black” in color?*/

Select 
	count(distinct sku) 
from skuinfo
where brand = 'Polo fas' AND (size ='XXL' OR color = 'black');
GROUP BY brand



/* Question 3

There was one store in the database which had only 11 days in one of its months (in other words, that store/month/year combination only contained 11 days of transaction data). In what city and state was this store located? */

Select T.store, T.num_days, msa.state, msa.city
from`(
	Select store, EXTRACT(MONTH FROM saledate) AS dm, EXTRACT (YEAR FROM saledate) AS dy, COUNT(DISTINCT saledate) AS num_days
	FROM trnsact
	WHERE stype = 'P'
	GROUP BY store, dm, dy) AS T
JOIN store_msa as msa
ON msa.store = T.store
WHERE num_days = 11;



/*
Question 4
 
Which sku number had the greatest increase in total sales revenue from November to December? */


Select TOP 1 
	sku, SUM(Case WHEN EXTRACT(MONTH from saledate)= 11 THEN amt END) AS nov_amt,
	SUM(Case WHEN EXTRACT(MONTH from saledate)= 12 THEN amt END) AS dec_amt,
	COUNT (DISTINCT Case WHEN EXTRACT(MONTH from saledate)= 11 THEN saledate END) AS nov_days,
	COUNT (DISTINCT Case WHEN EXTRACT(MONTH from saledate)= 12 THEN saledate END) AS dec_days,
	(dec_amt-nov_amt) AS inc
from TRNSACT t where stype='P' AND (saledate<'2005-08-01')
group by sku
Having nov_days>19 AND dec_days>19
ORDER by inc DESC;


/*  
Question 5
 
What vendor has the greatest number of distinct skus in the transaction table that do not exist in the skstinfo table? (Remember that vendors are listed as distinct numbers in our data set).
 */
Select 
	sk.vendor, 
	count(distinct t.sku) AS numsku
from TRNSACT t, skuinfo sk
where t.sku = sk.sku AND stype='P' AND (saledate<'2005-08-01') AND not exists (select 
																						s.sku 
																				from skstinfo s 
																				where t.sku=s.sku AND t.store=s.store)
group by sk.vendor
order by numsku DESC;



/* Question 6
 
 
What is the brand of the sku with the greatest standard deviation in sprice? Only examine skus which have been part of over 100 transactions. */


SELECT TOP 1 
	t.sku, 
	STDDEV_POP(t.sprice) AS sprice_stdev, 
	count(t.sprice) AS num_transactions, 
	si.style, 
	si.color,
	si.size,	
	si.packsize,
	si.vendor,	
	si.brand
FROM trnsact t JOIN skuinfo si
ON t.sku=si.sku
WHERE stype='P'
GROUP BY t.sku,si.style,si.color,si.size,si.packsize,si.vendor,si.brand
HAVING num_transactions>100
ORDER BY sprice_stdev DESC;



/*  
Question 7
 
What is the city and state of the store which had the greatest increase in average daily revenue (as defined in Teradata Week 5 Exercise Guide) from November to December? */

select 
	tr.store, 
	st.city, 
	st.state, 
	tr.diff_daily_rev
from (Select TOP 1 
			store, 
			SUM(Case WHEN EXTRACT(MONTH from saledate)= 11 THEN amt END) AS nov_amt,
			SUM(Case WHEN EXTRACT(MONTH from saledate)= 12 THEN amt END) AS dec_amt,
			COUNT (DISTINCT Case WHEN EXTRACT(MONTH from saledate)=11 THEN saledate END) AS nov_days,
			COUNT (DISTINCT Case WHEN EXTRACT(MONTH from saledate)= 12 THEN saledate END) AS dec_days,
			nov_amt/nov_days AS ndailyrev, 
			dec_amt/dec_days AS ddailyrev, 
			(ddailyrev-ndailyrev) AS diff_daily_rev
	from TRNSACT 
	where stype='P' AND (saledate<'2005-08-01')
	group by store
	Having nov_days>19 AND dec_days>19
	ORDER by diff_daily_rev DESC ) AS tr JOIN STRINFO st 
ON tr.store=st.store 
group by tr.store, st.city, st.state, tr.diff_daily_rev;



/*  
Question 8
 
Compare the average daily revenue (as defined in Teradata Week 5 Exercise Guide) of the store with the highest msa_income and the store with the lowest median msa_income (according to the msa_income field). In what city and state were these two stores, and which store had a higher average daily revenue?  */

Select 
	t.store,
	st.city,
	st.state, 
	sm.msa_income, 
	sum(t.rev)/sum(t.saledays) As avgdrev
from (Select 
			store, 
			sum(amt) As rev, 
			count(distinct saledate) As saledays 
	from trnsact 
	where stype='P' AND (saledate<'2005-08-01') 
	group by store)AS t,store_msa sm, strinfo st
where t.store = sm.store AND t.store = st.store AND (sm.msa_income IN ((SELECT MAX(msa_income) FROM store_msa),(SELECT MIN(msa_income) FROM store_msa)))
group by t.store,sm.msa_income, st.city,st.state
order by avgdrev


/*  
Question 9
 
Divide the msa_income groups up so that msa_incomes between 1 and 20,000 are labeled 'low', msa_incomes between 20,001 and 30,000 are labeled 'med-low', msa_incomes between 30,001 and 40,000 are labeled 'med-high', and msa_incomes between 40,001 and 60,000 are labeled 'high'. Which of these groups has the highest average daily revenue (as defined in Teradata Week 5 Exercise Guide) per store? */


SELECT 
		(SUM(tr.revenue)/SUM(tr.saledays)) AS day_revenue,
		(case
		WHEN msa_income>1 AND msa_income<=20000 THEN 'low'
		WHEN msa_income>20000 AND msa_income<=30000 THEN 'med_low'
		WHEN msa_income>30000 AND msa_income<=40000 THEN 'med_high'
		WHEN msa_income>40000 AND msa_income<=60000 THEN 'high'
		ELSE 'Check'
		END) as inc_level
FROM (SELECT 
			t.store, 
			SUM(t.amt) AS revenue, 
			COUNT(DISTINCT t.saledate) AS saledays, 
			extract(month from t.saledate) as month_num, 
			s.msa_income
	FROM trnsact t JOIN store_msa s ON t.store=s.store
	WHERE stype='P' AND (saledate<'2005-08-01') 
	GROUP BY month_num, t.store, s.msa_income
	HAVING saledays>=20) AS tr
GROUP BY inc_level
order by day_revenue;



/*  
Question 10
 
Divide stores up so that stores with msa populations between 1 and 100,000 are labeled 'very small', stores with msa populations between 100,001 and 200,000 are labeled 'small', stores with msa populations between 200,001 and 500,000 are labeled 'med_small', stores with msa populations between 500,001 and 1,000,000 are labeled 'med_large', stores with msa populations between 1,000,001 and 5,000,000 are labeled “large”, and stores with msa_population greater than 5,000,000 are labeled “very large”. What is the average daily revenue (as defined in Teradata Week 5 Exercise Guide) for a store in a “very large” population msa? */

SELECT 
	(SUM(tr.revenue)/SUM(tr.saledays)) AS day_revenue,
	CASE
	WHEN msa_pop>=1 AND msa_pop<=100000 THEN 'very small'
	WHEN msa_pop>=100001 AND msa_pop<=200000 THEN 'small'
	WHEN msa_pop>=200001 AND msa_pop<=500000 THEN 'med-small'
	WHEN msa_pop>=500001 AND msa_pop<=1000000 THEN 'med-large'
	WHEN msa_pop>=1000001 AND msa_pop<=5000000 THEN 'large'
	WHEN msa_pop>=5000001 THEN 'very large'
	END AS poplevel
FROM (SELECT 
			t.store, 
			SUM(t.amt) AS revenue, 
			COUNT(DISTINCT t.saledate) AS saledays, 
			extract(month from t.saledate) as month_num, 
			s.msa_pop
	FROM trnsact t JOIN store_msa s ON t.store=s.store
	WHERE stype='P' AND (saledate<'2005-08-01') 
	GROUP BY month_num, t.store, s.msa_pop
	HAVING saledays>=20) AS tr
GROUP BY poplevel;



/*  
Question 11
 
Which department in which store had the greatest percent increase in average daily sales revenue from November to December, and what city and state was that store located in? Only examine departments whose total sales were at least $1,000 in both November and December. */

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
	from TRNSACT t JOIN skuinfo sk
	ON t.sku=sk.sku
	where stype='P' AND (saledate<'2005-08-01') 
	group by store,dept
	Having nov_days>19 AND dec_days>19 AND nov_amt >=1000 AND dec_amt >=1000
	ORDER by percentinc DESC) AS tr JOIN STRINFO st 
ON tr.store=st.store JOIN DEPTINFO dp 
ON tr.dept=dp.dept 
group by tr.store, dp.deptdesc, tr.dept, st.city, st.state, tr.percentinc;


/*  
Question 12
 
Which department within a particular store had the greatest decrease in average daily sales revenue from August to September, and in what city and state was that store located? */

select 
	tr.store, 
	dp.deptdesc, 
	tr.dept, 
	st.city, 
	st.state, 
	tr.dec_rev
from (Select TOP 1 
			dept, 
			store, 
			SUM(Case WHEN EXTRACT(MONTH from saledate)= 8 THEN amt END) AS aug_amt,
			SUM(Case WHEN EXTRACT(MONTH from saledate)= 9 THEN amt END) AS sep_amt,
			COUNT (DISTINCT Case WHEN EXTRACT(MONTH from saledate)= 8 THEN saledate END) AS aug_days,
			COUNT (DISTINCT Case WHEN EXTRACT(MONTH from saledate)= 9 THEN saledate END) AS sep_days,
			aug_amt/aug_days AS adailyrev, 
			sep_amt/sep_days AS sdailyrev, 
			(adailyrev-sdailyrev) AS dec_rev 
	from TRNSACT t JOIN skuinfo sk
	ON t.sku=sk.sku
	where stype='P' AND (saledate<'2005-08-01') 
	group by store,dept
	Having aug_days>19 AND sep_days>19 
	ORDER by dec_rev DESC) AS tr JOIN STRINFO st 
ON tr.store=st.store JOIN DEPTINFO dp 
ON tr.dept=dp.dept 
group by tr.store, dp.deptdesc, tr.dept, st.city, st.state, tr.dec_rev;



/*  
Question 13
 
Identify which department, in which city and state of what store, had the greatest DECREASE in the number of items sold from August to September. How many fewer items did that department sell in September compared to August? */

select 
	tr.store, 
	dp.deptdesc, 
	tr.dept, 
	st.city, 
	st.state, 
	tr.dec_qty, 
	tr.avg_dec_qty 
from (Select TOP 1 
				dept, 
				store, SUM(Case WHEN EXTRACT(MONTH from saledate)= 8 THEN quantity END) AS aug_qty,
				SUM(Case WHEN EXTRACT(MONTH from saledate)= 9 THEN quantity END) AS sep_qty,
				COUNT (DISTINCT Case WHEN EXTRACT(MONTH from saledate)= 8 THEN saledate END) AS aug_days,
				COUNT (DISTINCT Case WHEN EXTRACT(MONTH from saledate)= 9 THEN saledate END) AS sep_days,
				aug_qty/aug_days AS adailyqty, 
				sep_qty/sep_days AS sdailyqty, 
				(aug_qty-sep_qty) AS dec_qty,
				(adailyqty-sdailyqty)  AS avg_dec_qty 
	from TRNSACT t JOIN skuinfo sk
	ON t.sku=sk.sku
	where stype='P' AND (saledate<'2005-08-01') 
	group by store,dept
	Having aug_days>19 AND sep_days>19 
	ORDER by dec_qty DESC) AS tr JOIN STRINFO st 
ON tr.store=st.store JOIN DEPTINFO dp 
ON tr.dept=dp.dept 
group by tr.store, dp.deptdesc, tr.dept, st.city, st.state, tr.dec_qty,tr.avg_dec_qty;



/*  
Question 14
 
For each store, determine the month with the minimum average daily revenue (as defined in Teradata Week 5 Exercise Guide) . For each of the twelve months of the year, count how many stores' minimum average daily revenue was in that month. During which month(s) did over 100 stores have their minimum average daily revenue?
 */
 
 
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



/*  
Question 15
 
Write a query that determines the month in which each store had its maximum number of sku units returned. During which month did the greatest number of stores have their maximum number of sku units returned? */



Select 
	month_num, 
	count(store) 
from (Select 
			store, 
			EXTRACT(MONTH from saledate) AS month_num, 
			Count(SKU) As tot_sku, 
			count(distinct saledate) As saledays, 
			RANK( ) OVER (PARTITION BY store ORDER BY tot_sku DESC) AS Rank_tot_sku 
	from trnsact
	where stype='R' AND (saledate<'2005-08-01') 
	Having saledays>19 
	group by store, month_num) As t
Where Rank_tot_sku =1
group by month_num
order by month_num;
