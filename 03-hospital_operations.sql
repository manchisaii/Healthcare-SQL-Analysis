-- Question 1: Doctor Appointment Volume
-- Which doctors have the highest number of appointments?

select
	d.doctor_id,
	d.first_name,
	d.last_name,
	COUNT(a.appointment_id) as number_of_appointments
from doctors d
join appointments a 
	on d.doctor_id = a.doctor_id 
group by d.doctor_id, d.first_name, d.last_name
order by number_of_appointments desc;


-- Question 2: Appointment Status by Doctor
-- How many appointments of each status has each doctor handled?

select
	d.doctor_id,
	d.first_name,
	d.last_name,
	a.status,
	COUNT(a.appointment_id) as number_of_appointments
from doctors d
join appointments a 
	on d.doctor_id = a.doctor_id 
group by d.doctor_id, d.first_name, d.last_name, a.status 
order by d.doctor_id; 


-- Question 3: Doctor Appointment Utilization
-- What percentage of each doctor's appointments were completed?

select 
	d.doctor_id,
	d.first_name,
	d.last_name,
	COUNT(a.appointment_id) as total_appointments,
	SUM(case
			when a.status = 'Completed' then 1 
			else 0
		end
	) as completed_appointments,
	ROUND(SUM(case
			when a.status = 'Completed' then 1 
			else 0
		end
	) * 100.0 / COUNT(a.appointment_id),2 ) as completion_rate
	from doctors d 
join appointments a 
	on d.doctor_id = a.doctor_id 
group by d.doctor_id, d.first_name, d.last_name
order by completion_rate desc, total_appointments desc;


-- Question 4: Treatment Volume by Doctor
-- How many treatments has each doctor been associated with?

select 
	d.doctor_id,
	d.first_name,
	d.last_name,
	COUNT(t.treatment_id) as number_of_treatments
from doctors d
join appointments a 
	on d.doctor_id = a.doctor_id 
join treatments t 
	on a.appointment_id = t.appointment_id 
group by d.doctor_id, d.first_name, d.last_name 
order by number_of_treatments desc;


-- Question 5: Treatment Revenue by Doctor
-- How much total treatment revenue is associated with each doctor?

select 
	d.doctor_id,
	d.first_name,
	d.last_name,
	SUM(b.amount) as total_treatment_revenue
from doctors d
join appointments a 
	on d.doctor_id = a.doctor_id 
join treatments t 
	on a.appointment_id = t.appointment_id 
join billing b 
	on t.treatment_id = b.treatment_id 
group by d.doctor_id, d.first_name, d.last_name 
order by total_treatment_revenue desc;


-- Question 6: Average Treatment Cost by Treatment Type
-- What is the average cost of each type of treatment?

select 
	treatment_type,
	AVG(cost) as average_treatment_cost
from treatments 
group by treatment_type 
order by average_treatment_cost desc;


-- Question 7: Appointment Cancellation Rate by Doctor
-- What percentage of each doctor's appointments were cancelled?

with doctor_stats as (
	select 
		d.doctor_id,
		d.first_name,
		d.last_name,
		COUNT(a.appointment_id) as total_appointments,
		SUM(case
				when a.status = 'Cancelled' then 1 
				else 0
			end
		) as cancelled_appointments
		from doctors d 
	join appointments a 
		on d.doctor_id = a.doctor_id 
	group by d.doctor_id, d.first_name, d.last_name
)
select
	doctor_id,
	first_name,
	last_name,
	total_appointments,
	cancelled_appointments,
	ROUND(cancelled_appointments * 100.0 / total_appointments,2) as cancellation_rate
from doctor_stats 
	order by cancellation_rate desc, total_appointments desc;
	
	
-- Question 8: Hospital Operational Summary
-- How do doctors compare across appointment volume, completion rate, and cancellation rate?
	
with doctor_stats as (
	select 
		d.doctor_id,
		d.first_name,
		d.last_name,
		COUNT(a.appointment_id) as total_appointments,
		SUM(case
			when a.status = 'Completed' then 1 
			else 0
		end
	) as completed_appointments,
		SUM(case
				when a.status = 'Cancelled' then 1 
				else 0
			end
		) as cancelled_appointments
		from doctors d 
	join appointments a 
		on d.doctor_id = a.doctor_id 
	group by d.doctor_id, d.first_name, d.last_name
)
select
	doctor_id,
	first_name,
	last_name,
	total_appointments,
	completed_appointments,
	ROUND(completed_appointments * 100.0 / total_appointments,2) as completion_rate,
	cancelled_appointments,
	ROUND(cancelled_appointments * 100.0 / total_appointments,2) as cancellation_rate
from doctor_stats 
	order by total_appointments desc;