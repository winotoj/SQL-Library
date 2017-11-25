/* Library Assignment Adding Relations (Foreign Keys)
	Script Date: July 26, 2017
*/



/****** Altering Tables, Adding Foreign Keys *****/

use Library
;
go

/* add foreign key into adult */
alter table person.adult
add
	constraint fk_adult_member foreign key (member_id)
	references person.member (member_id)
;
go

/* add foriegn key into juvenile */

alter table person.juvenile
add
	constraint fk_juvenile_member foreign key (member_id)
	references person.member (member_id)
;
go

/* add foreign key into item */

alter table production.item
add
	constraint fk_item_title foreign key (title_id)
	references production.title (title_id)
;
go

/* add foreign key into copy */

alter table production.copy
add
	constraint fk_copy_item foreign key (isbn)
	references production.item (isbn)
;
go

/* add foreign key into reservation */

alter table rental.reservation
add
	constraint fk_reservation_item foreign key (isbn)
	references production.item (isbn),
	constraint fk_reservation_member foreign key (member_id)
	references person.member (member_id)
;
go

/* add foreign key into loan */

alter table rental.loan
add
	constraint fk_loan_copy foreign key (isbn, copy_id)
	references production.copy (isbn, copy_id)
;
go

/* add foreign key into loanhist */
alter table rental.loanhist
add
	constraint fk_loanhist_copy foreign key (isbn, copy_id)
	references production.copy (isbn, copy_id)
;
go
