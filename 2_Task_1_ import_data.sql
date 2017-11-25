/* Library Assignment Importing Data
	Script Date: July 28, 2017
*/




/***** Importing Data from txt files using Bulk inserts *****/

use Library
;
go

bulk insert Person.Adult
from 'J:\libassign\libassign\populate Library database\adult_data.txt'
with
(
	FirstRow = 1,
	FieldTerminator = '\t',
	RowTerminator = '\n'
)
;
go



bulk insert Production.Copy
from 'J:\libassign\libassign\populate Library database\copy_data.txt'
with
(
	FirstRow = 1,
	FieldTerminator = '\t',
	RowTerminator = '\n'
)
;
go




bulk insert Production.Item
from 'J:\libassign\libassign\populate Library database\item_data.txt'
with
(
	FirstRow = 1,
	FieldTerminator = '\t',
	RowTerminator = '\n'
)
;
go



bulk insert Person.Juvenile
from 'J:\libassign\libassign\populate Library database\juvenile_data.txt'
with
(
	FirstRow = 1,
	FieldTerminator = '\t',
	RowTerminator = '\n'
)
;
go



bulk insert Rental.Loan
from 'J:\libassign\libassign\populate Library database\loan_data.txt'
with
(
	FirstRow = 1,
	FieldTerminator = '\t',
	RowTerminator = '\n'
)
;
go


bulk insert Rental.Loanhist
from 'J:\libassign\libassign\populate Library database\loanhist_data.txt'
with
(
	FirstRow = 1,
	FieldTerminator = '\t',
	RowTerminator = '\n'
)
;
go


bulk insert Person.Member
from 'J:\libassign\libassign\populate Library database\member_data.txt'
with
(
	FirstRow = 1,
	FieldTerminator = '\t',
	RowTerminator = '\n'
)
;
go



bulk insert Rental.Reservation
from 'J:\libassign\libassign\populate Library database\reservation_data.txt'
with
(
	FirstRow = 1,
	FieldTerminator = '\t',
	RowTerminator = '\n'
)
;
go



bulk insert Production.Title
from 'J:\libassign\libassign\populate Library database\title_data.txt'
with
(
	FirstRow = 1,
	FieldTerminator = '\t',
	RowTerminator = '\n'
)
;
go