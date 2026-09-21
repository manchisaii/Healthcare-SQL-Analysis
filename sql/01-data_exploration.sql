-- Question 1: Total Patient Count
-- How many total patients are in the hospital database?

select 
	COUNT(*) as total_patients
from patients; 


-- Question 2: Appointment Status Breakdown
-- How many appointments are there for each status?

select 
	status, 
	COUNT(*) as total_appointments 
from appointments 
group by status
order by total_appointments DESC;


-- Question 3: Patients With Frequent Appointments
-- Which patients have had more than 3 appointments?

select 
	patient_id, 
	COUNT(*) as number_of_appointments
from appointments 
group by patient_id 
having COUNT(*)>3;


-- Question 4: Doctor Appointment Volume
-- How many appointments has each doctor handled?

select
	doctor_id,
	COUNT(*) as number_of_appointments 
from appointments 
group by doctor_id
order by number_of_appointments desc;


-- Question 5: Treatment Type Distribution
-- How many treatments have been performed for each treatment type?

select
	treatment_type,
	COUNT(*) as number_of_treatments
from treatments 
group by treatment_type 
order by number_of_treatments desc;


-- Question 6: Monthly Appointment Volume
-- How many appointments were scheduled in each month?

select 
	extract(month from appointment_date) as month,
	COUNT(*) as number_of_appointments 
from appointments 
group by month
order by month asc;





