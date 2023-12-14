
-- Project on Namma Yatri taxi app --------

-- Below mention is the 5 main table i worked on (the data is of one day considering dummy date):
select * from trips;

select * from trip_details;

select * from payment;

select * from assembly;

select * from durations;


select count(*) from trips;

select count(*) from trip_details where end_ride=1; -- complete ride is 983 

-- Fetchig required data through query analysing data : 
-- total trips :
select count(distinct tripid) from trip_details;

-- To check duplicate values:
select tripid, count(tripid) as Total_count from trip_details
group by tripid
having count(tripid) > 1; -- as we get 0 i.e. there is no duplicate trips 

-- Total drivers:
select count(distinct driverid) as Total_drivers from trips;

-- Total Earning :
select * from trips;

select sum(fare) as Total_earning from trips;

-- Total completed trips :
select count(distinct tripid) as Total_completedTrips from trips;

-- Total searches:
select * from trip_details

select count(searches) searches from trip_details; -- 2161 searches

-- Total searches which got estimate : 
select count(searches_got_estimate) as searches from trip_details where searches_got_estimate = 1
--or
select sum(searches_got_estimate) searches from trip_details; -- 1758 

-- Total searches for quotes :
select * from trip_details;

select sum(searches_for_quotes) searches from trip_details; -- 1455 searches

-- Total  searches which got quotes:
select sum(searches_got_quotes) searches from trip_details; -- 1277 searches


-- Total driver cancelled :
select count(driver_not_cancelled) searches from trip_details where driver_not_cancelled=0; -- 1021 


-- Total OTP entered :
select sum(otp_entered) from trip_details; -- 983

-- Total number of end ride : 
select sum(end_ride) from trip_details; -- 983 


-- Average distance per trip in app :
select * from trips;

select avg(distance) avg_dis_trip from trips;

-- Average fare per trip :
select avg(fare) avg_fare_trip from trips;

-- Total distance travelled :
select sum(distance) avg_fare_trip from trips;



--which is the most used payment method :

select p.method as Most_used_Payment_method from payment p
inner join 
(select top 1 faremethod, count(faremethod) total_count from trips group by faremethod 
order by count(faremethod) desc) t
on p.id = t.faremethod;


-- The highest payment was made through which instrument:

select p.method as Payment_method, t.fare as Highest_payment from payment p
inner join
(select top 1 * from trips order by fare desc) t
on p.id = t.faremethod;

-- Which two location has the most trips:

with cte as(
	select *, dense_rank() over(order by trip desc) rnk 
	from
	(select loc_from, loc_to , count(distinct tripid) trip from trips
	group by loc_from, loc_to)a
)
select * from cte where rnk =1;

-- top 5 earning drivers:

with cte as(
	select *, DENSE_RANK() over(order by fare desc) ranking
	from 
	(select driverid, sum(fare) fare from trips
	group by driverid) a
)
select * from cte where ranking <=5;

-- Which duration had more trips:

with cte as(
	select *, DENSE_RANK() over(order by total_count desc) ranking
	from
	(select duration, count(distinct tripid) total_count  from trips
	group by duration) a
)
select * from cte where ranking =1;


-- Which driver, customer pair had more orders:

select * from (
select *, DENSE_RANK() over(order by cnt desc) ranking
from
	(select driverid, custid, count(distinct tripid) total_count from trips
	group by driverid, custid) a
) b
where ranking =1

-- search to estimate rate:

select * from trip_details

select round(sum(searches_got_estimate)*100.0/sum(searches),2) as search_estimate_rate from trip_details;

-- Estimate to search for quate rates:
select round(sum(searches_for_quotes)*100.0/sum(searches_got_estimate),2) as search_estimate_rate from trip_details;

-- Quote acceptance rate :
select round(sum(searches_got_quotes)*100.0/sum(searches_for_quotes),2) as search_estimate_rate from trip_details;

-- quotes for booking rate :

-- which area got higher number of trips in which duration :
with cte as (
	select *, dense_rank() over (partition by duration order by trip_count desc) rnk
	from 
		(select duration,loc_from, count(distinct tripid ) trip_count from trips
		group by duration, loc_from) a
)
select * from cte where rnk =1

-- Which duration got the highest number of trips in each of the location present.
with cte as (
	select *, dense_rank() over (partition by loc_from order by trip_count desc) rnk
	from 
		(select duration,loc_from, count(distinct tripid ) trip_count from trips
		group by duration, loc_from) a
)
select * from cte where rnk =1


-- > which location got the highest fares, cancellation, trips.

--which location got the highest fares
select * from 
	(select *, DENSE_RANK() over(order by fare desc) rnk
	from
	(select loc_from, sum(fare) fare from trips
	group by loc_from) a) b
where rnk =1

--which location got the highest driver cancellation :
select * from 
	(select *, DENSE_RANK() over(order by cnl desc) rnk
	from
		(select loc_from, (count(*) - sum(driver_not_cancelled)) cnl
		from trip_details
		group by loc_from) a ) b
where rnk =1 

--which location got the highest customer cancellation :
select * from 
	(select *, DENSE_RANK() over(order by cnl desc) rnk
	from
		(select loc_from, (count(*) - sum(customer_not_cancelled)) cnl
		from trip_details
		group by loc_from) a ) b
where rnk =1 


-- which duration got the highest trips and fare:
-- a. which duration got the highest fare:
select * from
(select *, DENSE_RANK() over(order by highest_fare desc) rnk from
(select duration, sum(fare) highest_fare from trips group by duration) a) b
where rnk =1
-- b. which duration got the highest trips :
select * from
(select *, DENSE_RANK() over(order by highest_trips desc) rnk from
(select duration, count(distinct tripid) highest_trips from trips group by duration) a) b
where rnk =1

