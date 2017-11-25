/* Library Assignment Creating Database, Schemas and Tables
	Script Date: July 26, 2017
*/



use master
;
go

/* Creating The Database */

create database Library
on primary
(
	name = 'library',
	filename = 'C:\sqlProject\library.mdf',
	size = 10MB,
	filegrowth = 2MB,
	maxsize = 200MB
)

log on
(
	
	name = 'library_log',
	filename = 'C:\sqlProject\library_log.ldf',
	size = 2MB,
	filegrowth = 10%,
	maxsize = 25MB
)
go

/* Creating the Schemas */

use Library
;
go

create schema Person authorization dbo
;
go

create schema Production authorization dbo
;
go

create schema Rental authorization dbo
;
go


/* Creating the Tables */

use Library
;
go

/* Table 1 - Person.Member */

create table Person.Member
(
	member_id int identity (1,1) not null,
	lastname varchar(40) not null,
	firstname varchar(40) not null,
	middleinitial varchar(40) null,
	photograph varbinary(max) null,
	constraint pk_Member primary key clustered (member_id asc)
)
;
go


/* Table 2 - Person.Adult */

create table Person.Adult
(
	member_id int not null,      
	street varchar(50) not null,
	city varchar(50) not null,
	state varchar(2) not null,
	zip varchar(10) not null,
	phone varchar(15) null,
	expr_date datetime null,
	constraint pk_Adult primary key clustered (member_id asc)
)
;
go


/* Table 3 - Person.Juvenile */

create table Person.Juvenile
(
	member_id int not null,					
	adult_member_id int not null,
	birth_date datetime null,
	constraint pk_Juvenile primary key clustered (member_id asc)
)
;
go




/* Table 4 - Production.Item */

create table Production.Item
(
	isbn int not null,						
	title_id int not null, 
	language nvarchar(20) not null,
	cover varchar(15) not null,
	loanable char(1) null,
	constraint pk_Item primary key clustered (isbn asc)
	
)
;
go



/* Table 5 - Production.Title */

create table Production.Title
(
	title_id int identity(1,1) not null,
	title varchar(80) not null,
	author varchar(60) not null,
	synopsis varchar(max) null,
	constraint pk_Title primary key clustered (title_id asc)
)
;
go


/* Table 6 - Production.Copy */

create table Production.Copy
(
	isbn int not null,
	copy_id int not null,
	title_id int not null, 
	on_loan char(1) null,
	constraint pk_Copy primary key clustered (isbn, copy_id asc)
)
;
go



/* Table 7 - Rental.Loan */

create table Rental.Loan
(
	isbn int not null,						
	copy_id int not null,
	title_id int not null,
	member_id int not null,
	out_date datetime null,
	due_date datetime null,
	constraint pk_Loan primary key clustered (isbn, copy_id, title_id)

)
;
go



/* Table 8 - Rental.Reservation */

create table Rental.Reservation
(
	isbn int not null,				
	member_id int not null,
	log_date datetime null,
	remarks varchar(200) null,
	constraint pk_Reservation primary key clustered (isbn, member_id)
)
;
go



/* Table 9 - Rental.Loanhist */
create table Rental.Loanhist
(
	hist_id int identity(1,1) not null,
	isbn int not null,					
	copy_id int not null,
	out_date datetime null,
	title_id int null,
	member_id int not null,
	due_date datetime null,
	in_date datetime null,
	fine_assessed money null,
	fine_paid money null,
	fine_waived money null,
	remarks varchar(200) null,
	constraint pk_loanhist primary key clustered (hist_id)
)
;
go

