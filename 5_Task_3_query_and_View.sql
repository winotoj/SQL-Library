/* Library Assignment Queries and Views
	Script Date: July 27, 2017
*/



use Library;
go

/* View no.1 */
select 
	CONCAT(m.firstname, ' ', m.middleinitial, ' ', m.lastname) as 'Full Name',
	a.street,
	a.city,
	a.state,
	a.zip
from Person.Member as m
inner join Person.Adult as a
	on m.member_id = a.member_id
;
go

/* View no.2 */

select i.isbn, 
	c.copy_id, 
	c.on_loan, 
	t.title, 
	i.language, 
	i.cover
from production.copy as c
inner join production.item as i
	on c.isbn = i.isbn
inner join Production.title as t
	on i.title_id = t.title_id
where c.isbn in('1', '500', '1000')
order by c.isbn asc
;
go

/* View no.3 */

select m.member_id, 
	concat(firstname, ' ', middleinitial, ' ', lastname) as 'Full Name', 
	r.isbn, 
	r.log_date as 'Reserve Date' 
from person.member as m
left join rental.reservation as r
	on m.member_id = r.member_id
where m.member_id in('250', '341', '1675')
;
go


/*View no.4 */

create view adultwideView
as
select concat(M.firstname, ' ', M.middleinitial, ' ', M.lastname) as 'Name', concat(A.street, ',', A.city, ',', A.state, ',', A.zip) as Address
from Person.Member M
inner join Person.Adult A
on M.member_id = A.member_id
;
go


/* View no.5 */

select concat(m.firstname, ' ', m.middleinitial, ' ', m.lastname) as 'Full Name',
	a.street, 
	a.city, 
	a.state, 
	a.zip, 
	m.member_id
from person.Juvenile as j
inner join person.Member as m
	on m.member_id = j.member_id
inner join person.Adult as a
	on a.member_id = j.adult_member_id	
;
go

select *
from person.Juvenile
;
go

/* View no.6 */

if object_id('production.copywideview','v') is not null
drop view production.copywideview;
go 

create view production.CopyWideView 
as
select i.isbn,
	c.copy_id, 
	t.title_id, 
	t.title, 
	i.language, 
	i.cover, 
	t.author, 
	iif(c.on_loan='Y', 'N', 'Y') as loanable, --tried use procedure with case after view created, only if first copy of isbn is on loan then status was changed. try with update... where.... will update all --WJ
	c.on_loan, 
	t.synopsis
from Production.Title as t
inner join Production.Item as i
	on t.title_id = i.title_id
inner join production.Copy as c
	on i.isbn = c.isbn
;
go

select *
from Production.CopyWideView
;
go



/*View no.7 */

create view Production.LoanableView as
select *
from Production.CopyWideView
where loanable = 'Y'
;
go


/*View no.8*/
create view OnshelfView
as
select *
from dbo.CopywideView as cv
where cv.[On Loan] ='N'
go

/*View no.9*/
Create view OnloanView
as
select     
	m.member_id as 'Member ID', 
	CONCAT(m.firstname,' ',m.lastname) as 'Member Name',
	l.isbn as 'ISBN',
	l.copy_id as 'Copy Number',
	t.title as 'Book title',
	l.out_date as 'From date',
	l.due_date as 'To date'
from Person.Member as m
inner join Rental.Loan as l
on m.member_id=l.member_id
inner join Production.Title as t
on l.title_id=t.title_id
where (l.out_date < getdate()) -- and (l.due_date > getdate())
go

/*View No.10 */
Create view OverdueView
as
select *
from dbo.OnloanView as ol
where ol.[To date]< GETDATE()
go


select *
from dbo.OnshelfView

select *
from rental.loan
order by out_date

update Rental.Loan
set out_date= DATEADD(month,-6,out_date)
go

truncate table rental.loan
