/* Library Assignment Creating Database, Schemas and Tables
	Script Date: July 26, 2017
*/


use Library
;
go

/***** RESERVING BOOKS *****/

alter table rental.loanhist
drop column holduntil

if OBJECT_ID('rental.reserveProcedure', 'P') is not null
drop procedure rental.reserveProcedure;
go

create procedure rental.reserveProcedure
@isbn int
as
set nocount on;
begin
select 
	m.member_id,
	m.lastname,
	m.firstname,
	iif(a.expr_date is null, v.expr_date, a.expr_date) as exprdate,
	person.expiredCardFN(m.member_id,iif(a.expr_date is null, v.expr_date, a.expr_date)) as 'Status',
	iif(a.phone is null, v.phone, a.phone) as 'Phone Number', 
	r.log_date,
	r.holdUntil
from person.Member as m
left join person.Adult as a
on m.member_id = a.member_id
left join person.exprView as v
on m.member_id = v.juvi
left join Rental.reservation as r
on m.member_id = r.member_id
where r.isbn = @isbn
order by r.log_date
end
;
go

execute rental.reserveProcedure @isbn = 1
;
go



/***** DETERMINING BOOK AVALIABILITY *****/
/*** copies book on loan ***/

if OBJECT_ID('Rental.onloanPr','P') is not null
drop procedure Rental.onloanPr
;
go
create procedure Rental.onloanPr
@isbn int
as
select count(*) as 'copies on loaned'
from rental.loan as l
where l.isbn = @isbn
;
go

execute Rental.onloanPr @isbn = 5

/*** books are on reserve ***/

if OBJECT_ID('rental.onReservedPR', 'P') is not null
drop procedure rental.onReservedPR
;
go
create procedure rental.onReservedPR
@isbn int
as
select isbn, count(*) as 'Number of reservation'
from rental.Reservation
where isbn = @isbn
group by isbn
;
go

execute Rental.onReservedPR @isbn = 288
;
go

select *
from rental.Reservation
group by isbn
;
go



/*** Search synopsis ***/
if OBJECT_ID ('Production.synopsisProcedure','P') is not null
drop procedure Production.synopsisProcedure
;
go 

create procedure Production.synopsisProcedure
@isbnChoice int
as
set nocount on;
select i.isbn, t.title, t.synopsis
from Production.Item as i
inner join Production.title as t
on i.title_id = t.title_id
where i.isbn = @isbnChoice
;
go

exec Production.synopsisProcedure 501
;
go

/** search isbn  based on partial title **/
if OBJECT_ID('Production.SearchTitleProcedure', 'P') is not null
drop procedure Production.SearchTitleProcedure
;
go

create procedure Production.SearchTitleProcedure
@titleS varchar(30)
as
set nocount on;

select i.isbn, i.language, i.cover, t.title, t.synopsis, i.loanable
from Production.Item as i
inner join Production.title as t
on i.title_id = t.title_id
where t.title like ('%' + @titleS +'%')
;
go

exec Production.SearchTitleProcedure mohi
;
go

/***** ENROLLING MEMBERS *****/

-- input lastname, firstname, middlename, photograph
-- input address, phone, exprydate is 1+getdate, dob


if object_id('person.enrollMemberPR', 'P') is not null
drop procedure person.enrollMemberPR
;
go
create procedure person.enrollMemberPR
(
	@lastname varchar(40),
	@firstname varchar(40),
	@middleinitial varchar (40),
	@photograph varbinary(max),
	@street varchar(50),
	@city varchar (50),
	@state varchar (2),
	@zip varchar (10),
	@phone varchar (15)
)
	as
	declare @expr_date datetime, @member_id int

	insert into person.member(lastname, firstname, middleinitial, photograph)
	values(@lastname, @firstname, @middleinitial, @photograph)
	select @member_id = SCOPE_IDENTITY();

	insert into person.adult(member_ID, street, city, state, zip, phone)
	values(@member_id, @street, @city, @state, @zip, @phone)
;
go
	exec person.enrollMemberPR '22janputra',' 22winoto',null, null, '50 hepworth', 'lasalle', 'qc', 12345, null;
;
go

if object_id('person.enrollJuvenilePR', 'Y') is not null
drop procedure person.enrollJuvenilePR
;
go

create procedure person.enrollJuvenilePR
(
	@lastname varchar(40),
	@firstname varchar(40),
	@middleinitial varchar (40),
	@photograph varbinary(max),
	@Adultmember int,
	@DOB datetime
)
	as
	declare @expr_date datetime, @member_id int

	insert into person.member(lastname, firstname, middleinitial, photograph)
	values(@lastname, @firstname, @middleinitial, @photograph)
	select @member_id = SCOPE_IDENTITY();

	insert into person.Juvenile(member_ID, adult_member_id, birth_date)
	values(@member_id, @Adultmember, @dob)
;
go
exec person.enrollJuvenilePR 'lastchild', 'firstchild', 'midfirst', null, 1, '2006/01/01'
;
go

/* move juvenile to adult */
alter table person.adult
drop constraint ck_adult_phone

if OBJECT_ID('Person.JuvenileTr','P') is not null
drop procedure Person.JuvenileTr
;
go

create trigger Person.JuvenileTr
on Person.Juvenile
for delete
as
	begin
		-- declare variables
		declare @memberID as int,
				@adult_member_id as int,
				@street varchar(50),
				@city varchar(50),
				@state varchar(2),
				@zip varchar(10),
				@phone varchar(15),
				@expr_date datetime
		-- Compute the return value
		select @memberID = member_id,
				@adult_member_id = adult_member_id
		from deleted
		select @street = a.street, @city = a.city, @state = a.state, @zip = a.zip, @phone = a.phone
		from person.adult as a
		where a.member_id = @adult_member_id
				 -- making decision
		begin
			-- set the ModifiedDate to the current date
			insert into person.adult(member_id,street, city, state, zip, phone, expr_date)
			values (@memberID, @street,@city, @state, @zip, @phone, @expr_date)			
			
		 end
	end
;
go
delete from person.Juvenile
where datediff(year, birth_date, getdate()) >17



/***** CHECKING OUT THE BOOKS *****/

-- create view to assign expiry date to juvenile

if OBJECT_ID('person.exprView','V') is not null
drop view person.exprView
;
go

create view person.exprView
as
select 
	a.member_id as adult, 
	j.member_id as juvi, 
	a.expr_date,
	a.street,
	a.city,
	a.state, 
	a.zip,
	a.phone
from person.Adult as a
inner join person.Juvenile as j
on a.member_id = j.adult_member_id
;
go

-- create function to calculate expiry date

if OBJECT_ID('person.expiredCardFN','FN') is not null
drop function person.expiredCardFN
;
go
create function person.expiredCardFN
(
@memberid int,
@vexpr datetime

)
returns varchar(30)
as
begin
declare @expire varchar(30),
		@noDays int
	
select @noDays = datediff(day, getdate(),@vexpr)
from person.Member as m
where m.member_id = @memberid
if (@noDays > 0 and  @noDays <= 30) 
begin
set @expire = 'About expire in ' + cast(@noDays as varchar) + ' days'
end
else if (@noDays > 30 )
begin
set @expire = 'Membership is ok'
end
else if (@noDays < 1)
begin
set @expire = 'Membership is expired'
end
else
begin
set @expire = 'other'
end
return @expire
end
;
go
-- create procedure, when card is scan, this procedure is called before place the order
if OBJECT_ID('rental.CheckOutProcedure', 'P') is not null
drop procedure rental.CheckOutProcedure
;
go
create procedure rental.CheckOutProcedure
@memberID int
as
set nocount on;
select 
	m.member_id,
	iif(a.expr_date is null, v.expr_date, a.expr_date) as exprdate,
	person.expiredCardFN(m.member_id,iif(a.expr_date is null, v.expr_date, a.expr_date)) as 'Status',
	iif(a.street is null, v.street, a.street) as ' Street',
	iif(a.city is null, v.city, a.city) as ' City',
	iif(a.state is null, v.state, a.state) as ' State',
	iif(a.zip is null, v.zip, a.zip) as 'zip code', 
	iif(a.phone is null, v.phone, a.phone) as 'Phone Number',
	t.title, 
	l.out_date, 
	l.due_date,
	case
	when l.due_date is not null
	then DATEDIFF(day,l.due_date, GETDATE())
	end as 'due in'
from person.Member as m
left join person.Adult as a
on m.member_id = a.member_id
left join person.exprView as v
on m.member_id = v.juvi
left join Rental.loan as l
on m.member_id = l.member_id
left join Production.Title as t
on t.title_id = l.title_id
where m.member_id = @memberID
order by l.due_date
;
go

exec rental.CheckOutProcedure @memberID = 2
;
go

-- create trigger to insert into loan table and update copy table
if OBJECT_ID('Rental.CheckOutBookTR', 'TR') is not null
drop trigger Rental.CheckOutBookTR
;
go

create trigger Rental.CheckOutBookTR
on Rental.Loan
for insert
as
begin
	-- declare variable
	declare @member_id as int,
			@isbn as int,
			@title_id as int,
			@copy_id as int
	-- compute
	select
		@member_id = member_id,
		@isbn = isbn,
		@title_id = title_id,
		@copy_id = copy_id
		from inserted
	-- making decission
	-- set the change/insert
	begin

		update rental.loan
		set out_date = GETDATE(), due_date = DATEADD(day, 14, GETDATE())
		from inserted
		where rental.loan.isbn = @isbn and rental.loan.copy_id = @copy_id and rental.loan.title_id = @title_id

		update Production.copy
		set on_loan ='Y'
		from inserted as i
		inner join Production.copy as c
		on i.isbn = c.isbn and i.copy_id = c.copy_id
		where c.isbn = @isbn and c.copy_id = i.copy_id
	end
end
;
go

--insert new data and test trigger
insert into Rental.Loan (isbn, copy_id, title_id, member_id)
values (1, 7, 1, 5422)
;
go

alter table rental.loan
alter column out_date datetime null
;


select *
from rental.loan
;
go
select *
from Production.copy
;
go



/***** CHECKING IN BOOKS *****/

/*checkIn procedure*/
if OBJECT_ID('Rental.CheckInBooksSP','Sp')is not null
drop procedure Rental.CheckInBooksSP
go
create proc Rental.CheckInBooksSP
(
@Isbn as int,
@copyNumber as int
)
as begin
select 
	i.isbn as 'ISBN',
	l.copy_id as 'Copy Number',
	t.title as 'Title', 
	t.author as 'Author',
	l.member_id as 'Member No.',
	CONCAT(m.firstname,' ',m.lastname) as 'Member Name',
	l.due_date as 'Due Date'
from Production.Item as i
	inner join Production.Title as T
on i.title_id=t.title_id 
	inner Join Rental.Loan as l
on l.isbn=i.isbn
	inner join Person.Member as m
on l.member_id=m.member_id 
where ((l.isbn = @Isbn) and (l.copy_id = @copyNumber))
update Production.Copy
set on_loan='N'
where isbn=@isbn and copy_id=@copyNumber
delete from Rental.Loan 
where ((rental.loan.isbn = @Isbn) and (rental.loan.copy_id = @copyNumber)) 
end
go

/*add trigger for updating the loan.history table after book was returned*/
create trigger UpdateLoanhistotyTR
on Rental.loan
after delete
as begin
insert into Rental.loanhist
(isbn,
copy_id,
out_date,
title_id,
member_id,
due_date,
in_date )
select del.isbn,del.copy_id,del.out_date,del.title_id,del.member_id,del.due_date, getdate()
from deleted as del
end
go

exec Rental.CheckInBooksSP @Isbn=13, @copyNumber=8
go



/*check if the book is avaliable to CheckIN*/
select *
from Production.Copy
go
if OBJECT_ID('Rental.CkeckInTestSP','Sp')is not null
drop procedure Rental.CkeckInTestSP
go
create proc Rental.CkeckInTestSP
(
@Isbn as int,
@copyNumber as int
)
as 
begin
if exists(
select l.isbn,l.copy_id 
from Rental.Loan as l
where ((l.isbn = @Isbn) and (l.copy_id = @copyNumber))
)
print 'This Book  is alreadt cheked out' 
select 
CONCAT(m.firstname,' ',m.lastname) as 'Member Name',
l.out_date as 'Date out',
l.due_date as 'Due Date'
from Rental.Loan as l
inner join Person.Member as m
on m.member_id=l.member_id
where  (l.isbn = @Isbn) and (l.copy_id = @copyNumber)
if not exists(
select l.isbn,l.copy_id 
from Rental.Loan as l
where ((l.isbn = @Isbn) and (l.copy_id = @copyNumber))
)
print 'This Book  ready for check out' 
end
go

/*Procedure to force CheckIn*/
create proc Rental.ForceCheckInSP
(
@Isbn as int,
@copyNumber as int
)
as begin
update Production.Copy
set on_loan='N'
where isbn=@isbn and copy_id=@copyNumber
delete from Rental.Loan 
where ((rental.loan.isbn = @Isbn) and (rental.loan.copy_id = @copyNumber))
end
go


