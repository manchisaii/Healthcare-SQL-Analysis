-- Question 1: Patient Billing Revenue
-- Which patients have generated the most total billing revenue?

select 
	patient_id,
	SUM(amount) as total_bill_revenue 
from billing 
group by patient_id 
order by total_bill_revenue desc;


-- Question 2: Revenue by Insurance Provider
-- Which insurance providers generate the most total billing revenue?

select 
	insurance_provider,
	SUM(amount) as total_billing_revenue
from billing b
join patients p 
	on b.patient_id = p.patient_id 
group by insurance_provider 
order by total_billing_revenue desc;


-- Question 3: Insurance Revenue Share
-- What percentage of total billing revenue does each insurance provider represent?

select 
	insurance_provider,
	SUM(amount)/(
    SELECT SUM(amount)
    FROM billing
) *100 as revenue_percentage
from billing b
join patients p 
	on b.patient_id = p.patient_id 
group by insurance_provider 
order by revenue_percentage desc;


-- Question 4: Average Bill Amount by Patient
-- What is the average individual bill amount for each patient?

select 
	patient_id,
	AVG(amount) as average_billed
from billing 
group by patient_id 
order by average_billed desc;


-- Question 5: Average Billing per Patient
-- What is the average amount billed per patient?

select	
	AVG(total_billing) as average_billing_per_patient
from (
    select
        patient_id,
        SUM(amount) as total_billing
    from billing
    group by patient_id
) as patient_totals;


-- Question 6: High-Utilization, High-Revenue Patients
-- Which patients have had 3 or more appointments and generated more than $5,000 in total billing?

select 
	appointments_totals.patient_id,
	appointments_totals.total_appointments, 
	billings_totals.total_billed
FROM
(
select 
	patient_id,
	COUNT(*) as total_appointments 
from appointments 
group by patient_id
) as appointments_totals
join (
select 
	patient_id,
	SUM(amount) as total_billed
from billing
group by patient_id
) as billings_totals
on appointments_totals.patient_id = billings_totals.patient_id
where total_appointments >= 3 and total_billed > 5000
order by billings_totals.total_billed desc;


-- Question 7: Treatment Diversity by Patient
-- Which patients have received 2 or more different types of treatments?

select 
	a.patient_id,
	COUNT(distinct t.treatment_type ) as number_of_treatment_types
from appointments a
join treatments t 
	on a.appointment_id = t.appointment_id 
group by a.patient_id
having COUNT(distinct t.treatment_type) >= 2;


-- Question 8: Patient Appointment Status
-- Which patients have the highest number of cancelled appointments?

select 
	patient_id,
	SUM(case
		when status = 'Cancelled' then 1
		else 0
end
) as cancelled_appointments 
from appointments 
group by patient_id
order by cancelled_appointments DESC;


-- Question 9: Appointment Gaps
-- How many days passed between each patient's appointments?

select 
	patient_id,
	appointment_date,
	lag(appointment_date) over (
		partition by patient_id 
		order by appointment_date 
	) as previous_appointments,
	appointment_date - lag(appointment_date) over (
	partition by patient_id 
	order by appointment_date 
) as days_between
from appointments; 


-- Question 10: Patient Appointment Frequency
-- Which patients have the shortest average time between appointments?

with appointment_gaps as (
select 
	patient_id,
	appointment_date,
	appointment_date - lag(appointment_date) over (
		partition by patient_id 
		order by appointment_date 
	) as days_between
from appointments 
)
select 
	patient_id,
	AVG(days_between) as average_days_between,
	COUNT(patient_id) as number_of_appointments
from appointment_gaps 
group by patient_id
order by average_days_between asc