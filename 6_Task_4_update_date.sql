/* Library Assignment Updating Dates
	Script Date: July 27, 2017
*/


/* add 9 years and 6 months in adult */
select *
from person.Adult
order by expr_date
;
go
update person.adult
	set expr_date = dateadd(year, 9, expr_date)
;
go
update person.adult
	set expr_date = dateadd(month, 6, expr_date)
;
go

/* add 9 years and 6 months in reservation */
select *
from rental.reservation
order by isbn
;
go

update rental.reservation
	set log_date = DATEADD(year, 9, log_date)
;
update rental.reservation
	set log_date = DATEADD(month, 6, log_date)
;
go
update rental.reservation
	set log_date = DATEADD(day, 21, log_date)
	where member_id between 9501 and 10000
;
go

/* change date in loan and loanhist */
select *
from rental.loan
order by out_date
;
go

update Rental.loan
	set due_date = DATEADD(year, 9, due_date)
;
update Rental.loan
	set due_date = DATEADD(month, 6, due_date)
update Rental.loan
	set due_date = DATEADD(day, 5, due_date)
;
go

update Rental.loan
	set out_date = DATEADD(day, -14, due_date)
;
go

select *
from rental.loanhist
;
go

update Rental.loanhist
	set due_date = DATEADD(year, 9, due_date)
;
update Rental.loanhist
	set due_date = DATEADD(month, 6, due_date)
update Rental.loanhist
	set due_date = DATEADD(day, 5, due_date)
;
go
update Rental.loanhist
	set out_date = DATEADD(day, -14, due_date)
;
go

update Rental.loanhist
	set in_date = DATEADD(year, 9, in_date)
;
update Rental.loanhist
	set in_date = DATEADD(month, 6, in_date)
update Rental.loanhist
	set in_date = DATEADD(day, 5, in_date)
;
go