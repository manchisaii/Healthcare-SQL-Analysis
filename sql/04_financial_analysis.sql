-- Question 1: Paid vs. Unpaid Revenue
-- How much billing revenue has been collected versus remaining unpaid?

select 
	payment_status,
	SUM(amount) as total_revenue
from billing 
	group by payment_status
	order by total_revenue desc;
	
	
-- Question 2: Revenue by Payment Method
-- How much total billing revenue is associated with each payment method?
	
select 
	payment_method,
	SUM(amount) as total_revenue 
from billing 
	group by payment_method 
	order by total_revenue desc;
	
	
-- Question 3: Monthly Revenue
-- How does total billing revenue change from month to month?
	
select 	
	extract(month from bill_date) as month,
	SUM(amount) as total_revenue 
from billing
group by month 
order by month;


-- Question 4: Average Bill Amount by Payment Method
-- What is the average billing amount for each payment method?

select
	payment_method,
	AVG(amount) as average_bill_amount 
from billing 
	group by payment_method 
	order by average_bill_amount desc;
	
	
-- Question 5: Revenue by Insurance Provider
-- How much total billing revenue is associated with each insurance provider?
	
select 
	p.insurance_provider,
	SUM(b.amount) as total_revenue 
from billing b
join patients p
	on b.patient_id = p.patient_id 
		group by p.insurance_provider 
		order by total_revenue desc;
		

-- Question 6: Treatment Cost vs. Billed Revenue
-- How does the average treatment cost compare with the average billed amount?
		
select 
	AVG(t.cost) as average_treatment_cost,
	AVG(b.amount) as average_billed_amount
from billing b 
join treatments t 
	on b.treatment_id = t.treatment_id; 

	
-- Question 7: Revenue by Treatment Type
-- Which types of treatments generate the most total billed revenue?

select 
	t.treatment_type,
	SUM(b.amount) as total_revenue 
from treatments t
join billing b 
	on t.treatment_id = b.treatment_id 
	group by t.treatment_type 
	order by total_revenue desc; 

	
-- Question 8: Revenue Collection Rate
-- What percentage of total billed revenue has been collected (paid)?
	
select 
	SUM(amount) as total_billed,
	SUM(case  
			when payment_status = 'Paid' then amount
			else 0
		end 
		) as total_paid,
	SUM(case  
			when payment_status = 'Paid' then amount
			else 0
		end 
		) *100.0 / SUM(amount) as collection_rate 
from billing;

		
