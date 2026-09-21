-- Question 1: Cumulative Monthly Revenue
-- How does total billing revenue accumulate throughout the year?

with monthly_totals as (
	select 
		extract(month from bill_date) as month,
		SUM(amount) as monthly_revenue
	from billing 
	group by month 
)
	select
		month,
		monthly_revenue,
		SUM(monthly_revenue) over ( 
			order by month
		) as cumulative_revenue
	from monthly_totals 
	order by month;


-- Question 2: Month-over-Month Revenue Change
-- How much did total billing revenue increase or decrease compared with the previous mont

with monthly_totals as (
	select 
		extract(month from bill_date) as month, 
		SUM(amount) as monthly_revenue 
	from billing 
	group by month 
)
	select 
		month, 
		monthly_revenue,
		LAG(monthly_revenue) over (
		order by month
	) as previous_month_revenue,
	monthly_revenue - LAG(monthly_revenue) over (
		order by month
	) as revenue_change
	from monthly_totals 
	order by month;

	
-- Question 3: Monthly Revenue Growth Rate
-- What percentage did total billing revenue increase or decrease compared with the previous month?

with monthly_totals as (
    select 
        extract(month from bill_date) as month, 
        SUM(amount) as monthly_revenue 
    from billing 
    group by month
)
select 
    month, 
    monthly_revenue,
    LAG(monthly_revenue) over (
        order by month
    ) as previous_month_revenue,
    (
        monthly_revenue - LAG(monthly_revenue) over (
            order by month
        )
    ) / LAG(monthly_revenue) over (
        order by month
    ) * 100.0 as revenue_growth_rate
from monthly_totals 
order by month;


-- Question 4: Patient Revenue per Appointment
-- Which patients generate the highest average billed amount per appointment?

with revenue_totals as (
    select 
        patient_id,
        SUM(amount) as total_revenue
    from billing
    group by patient_id 
),
appointment_totals as (
    select 
        patient_id,
        COUNT(appointment_id) as number_of_appointments
    from appointments 
    group by patient_id
)
select 
    r.patient_id,
    r.total_revenue,
    a.number_of_appointments,
    r.total_revenue / a.number_of_appointments as average_revenue_per_appointment
from revenue_totals r
join appointment_totals a 
    on r.patient_id = a.patient_id 
order by average_revenue_per_appointment desc;


-- Question 5: Patient Revenue Ranking
-- How do patients rank against each other based on their total billing revenue?

with revenue_totals as (
	select 
   	 	patient_id,
    	sum(amount) as total_revenue
    from billing
    	group by patient_id
   )
   	select
   		patient_id,
   		total_revenue,
   		rank() over(
   			order by total_revenue DESC
   		) as revenue_rank
   	from revenue_totals
   		order by revenue_rank asc;
   		
   		
-- Question 6: Doctor Revenue Performance
-- Which doctors generate the highest treatment revenue compared with the average doctor?

 with doctor_stats as (
  	select 
  		d.doctor_id,
		d.first_name,
		d.last_name,
		SUM(b.amount) as total_revenue
	from doctors d
	join appointments a 
		on d.doctor_id = a.doctor_id 
	join treatments t 
		on a.appointment_id = t.appointment_id 
	join billing b 
		on t.treatment_id = b.treatment_id 
	group by d.doctor_id, d.first_name, d.last_name 
  ),
  revenue_comparison as (
	select 	
		doctor_id,
		first_name,
		last_name,
		total_revenue,
		AVG(total_revenue) over() as average_revenue,
		total_revenue - AVG(total_revenue) over() as revenue_vs_average
	from doctor_stats
)
	select 
		doctor_id,
		first_name,
		last_name,
		total_revenue,
		average_revenue,
		revenue_vs_average
	from revenue_comparison 
	where total_revenue > average_revenue
	order by revenue_vs_average desc
	
	
-- Question 7: Patient Treatment Cost Ranking
-- How do patients rank based on their total treatment costs compared with other patients?

with treatment_totals as (
	select 
		patient_id,
		SUM(cost) as total_treatment_cost
	from appointments a 
	join treatments t 
		on a.appointment_id = t.appointment_id 
		group by patient_id
)
	select 
		patient_id,
		total_treatment_cost,
		rank() over (
			order by total_treatment_cost desc
		) as cost_rank
	from treatment_totals 
	order by cost_rank asc 
	
	
-- Question 8: Monthly Revenue Performance
-- Which months had the highest and lowest revenue compared with the previous month?

with monthly_revenue as (
select 
	extract(month from bill_date) as month,
	SUM(amount) as total_revenue
from billing
	group by month 
),
revenue_comparison as (
	select 
		month,
		total_revenue,
		lag(total_revenue) over (
			order by month
		) as previous_month_revenue,
		total_revenue - lag(total_revenue) over (
			order by month
		) as revenue_change
	from monthly_revenue
)
	select 
		month,
		total_revenue,
		previous_month_revenue,
		revenue_change,
		rank() over (
			order by revenue_change desc nulls last
		) as revenue_rank
	from revenue_comparison 
		order by month asc
