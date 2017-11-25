/* Library Assignment Adding Constraints
	Script Date: July 27, 2017
*/


/**** add default constraint in adult table *****/
use Library
;
go

alter table person.adult
add 
constraint
	df_adult_state default ('WA') for state
;
go

/* add check constraint in adult */
alter table person.adult
with nocheck
add
constraint ck_adult_phone check (phone like '^[2-9]\d{2}-\d{3}-\d{4}$'),
constraint ck_adult_zip check (zip like '^\d{5}$|^\d{5}-\d{4}$')
;
go

/* add check constraint in loan */
alter table rental.loan
with nocheck
add
constraint ck_loan_date check (due_date >= out_date)
;
go

select *
from rental.loan
where due_date < out_date
;
go


/*Creating indexes */

--index for title columt in a production.title table
create nonclustered index ncl_Title on [production].[title] (title)
;
go
--index for author in production.title table
create unique nonclustered index u_ncl_Title on [production].[title] (author)
;
go
--index for membe last name for person.member.table
create nonclustered index ncl_MemberLastName on [person].[member] (lastname)
;
go


