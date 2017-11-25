/* Library Assignment Questions 1 to 7
	Script Date: July 28, 2017
*/





/* add default constraint in adult table */
use Library
;
go

/* 1 how many loans did he library do last year */
IF OBJECT_ID ( 'rental.usptotalTransaction', 'P' ) IS NOT NULL   
    DROP PROCEDURE rental.usptotalTransaction;  
GO  
CREATE PROCEDURE rental.usptotalTransaction   
     @yearChoice int     
AS   
    SET NOCOUNT ON;  
    select count(*) as 'total transaction for 2016'
from rental.loanhist
where year(out_date) = @yearChoice
; 
GO

exec Rental.usptotalTransaction 2016;
go


/* 2 what percentage of the membership borrowed at least one book */
/* data is taken from last year */

if OBJECT_ID('rental.uspMemberPercentage', 'P') is not null
drop procedure rental.uspMemberPercentage
;
go

create procedure rental.uspMemberPercentage
	AS
	set NOCOUNT ON;
	select cast(count (distinct l.member_id) as decimal(7,2))/cast(count(distinct m.member_id)as decimal(7,2))*100 as 'Member Rent percentage'
	from rental.loanhist as l
	right join person.member as m
	on l.member_id = m.member_id
;
go

exec Rental.uspMemberPercentage
;
go
-- to check how many member rent
select count(*)
from rental.Loanhist
group by member_id
;
go

/* 3 What was the greatest number of books borrowed by anyone individual */

-- total how many book each member had borrowed

IF OBJECT_ID (N'rental.MemberBorrowedView', N'V') IS NOT NULL  
    DROP FUNCTION rental.MemberBorrowedView;  
GO
create view rental.MemberBorrowedView
as
select member_id, count(hist_id) as 'Total of borrowed' -- save as view and create query to see max
from rental.loanhist
group by member_id
;
go
select *
from rental.MemberBorrowedView as m
order by m.[Total of borrowed] desc
;
go

/* 4 what percentage of the books was loaned outat least once last year */

if OBJECT_ID ('rental.bookPercentageProcedure', 'P') is not null
drop procedure rental.bookPercentageProcedure
;
go
create procedure rental.bookPercentageProcedure
	@yearchoice int
	as
	set nocount on;
select loan3 as 'was loaned', book3 as 'total book', cast((loan3/book3*100) as decimal(7,2)) as percentage
from
(
	select 
		(
			select cast(count(loan1) as decimal)
			from
			(
				select distinct isbn, copy_id as loan1
				from rental.Loanhist
				where year(out_date) = @yearchoice
			) as loan2
	) as loan3,
		(
			select cast(count(book1) as decimal)
			from
			(
				select distinct isbn, copy_id as book1
				from production.copy
			)as book2
		) as book3
) as loan4
;
go

exec rental.bookPercentageProcedure 2016
;
go

/* 5 what percentage of all loans eventually becomes overdue */

-- set hour to 23 (library closed at 21) for due date

update rental.Loanhist
set due_date = dateadd(hour, 23, due_date) 
;
go

-- to check before creating view
select count(l1.hist_id) as overdue
from Rental.Loanhist as l1
where l1.due_date > l1.in_date
;
go
-- create view
if OBJECT_ID ('rental.bookOverdueView','V') is not null
drop view rental.bookOverdueView
;
go

create view rental.bookOverdueView
as
select overdue, count_total, cast((overdue/count_total * 100) as decimal(5,2)) as 'Overdue percentage'
from 
(
	select
		(
		select 
			cast(count(l1.hist_id) as decimal(5,2)) 
		from Rental.Loanhist as l1
		where l1.due_date > l1.in_date
		) as overdue,
		(
		select
			cast(count(l2.hist_id) as decimal(5,2))
		from Rental.Loanhist as l2
		) as count_total
) as ss		
;
go

select *
from rental.bookOverdueView
;
go

/* 6 what is the average length of a loan */
-- do calculation only with the right data ( some date in are older than date out)
select *
from rental.loanhist
where in_date < out_date
;
go
--create procedure
if OBJECT_ID ('rental.loanAverageProcedure', 'P') is not null
drop procedure rental.loanAverageProcedure
;
go

create procedure rental.loanAverageProcedure
	@yearchoice int,
	@startMonth int,
	@endMonth int
	as
	set nocount on;
select cast(avg(DATEDIFF(day, out_date, in_date)) as decimal(5,2)) as 'Average loan'
from rental.Loanhist as l
where in_date > out_date and year(out_date) = @yearchoice and month(out_date) between @startMonth and @endMonth
;
go

exec rental.loanAverageProcedure 2016, 1 , 12
;
go

/* 7 peak hours for loan */
select *
from rental.Loanhist
;
go

update rental.Loanhist
set out_date = DATEADD(hour, 12, out_date)
where datepart(hour, out_date) = 6
;
go

update top (800) rental.Loanhist
set out_date = DATEADD(hour, 10, out_date)
;
go

update top (700) rental.Loanhist
set out_date = DATEADD(hour, 11, out_date)
;
go
update top (600) rental.Loanhist
set out_date = DATEADD(hour, 12, out_date)
;
go
update top (450) rental.Loanhist
set out_date = DATEADD(hour, 13, out_date)
;
go
update top (300) rental.Loanhist
set out_date = DATEADD(hour, 16, out_date)
;
go
update top (250) rental.Loanhist
set out_date = DATEADD(hour, 17, out_date)
;
go
update top (175) rental.Loanhist
set out_date = DATEADD(hour, 18, out_date)
;
go
update top (160) rental.Loanhist
set out_date = DATEADD(hour, 19, out_date)
;
go
update top (60) rental.Loanhist
set out_date = DATEADD(hour, 20, out_date)
;
go



select datepart(hour,out_date) as 'peak hour',count(datepart(hour,out_date)) as 'Total book out'
from rental.Loanhist
where datepart(weekday, out_date) between 1 and 7
group by datepart(hour,out_date)
order by [Total book out] desc

;
go

IF OBJECT_ID (N'rental.ufn_peakhour', N'IF') IS NOT NULL  
    DROP FUNCTION rental.ufn_peakhour;  
GO  
CREATE FUNCTION rental.ufn_peakhour (@start_day int, @end_day int) 
RETURNs table
as
return
(
select datepart(hour,out_date) as 'peak hour',count(datepart(hour,out_date)) as 'Total book out'
from rental.Loanhist
where datepart(weekday, out_date) between @start_day and @end_day
group by datepart(hour,out_date)
)
;
go

select *
from rental.ufn_peakhour(1,7) as p
order by p.[Total book out] desc
;
go

