use master
go

if db_id('lebowski') is null
begin
	create database lebowski
end

use lebowski
go

if object_id('dbo.role', 'u') is not null
begin
	if exists (select 1 from sys.objects o where o.object_id = object_id('FK_attorney_roleid') and OBJECTPROPERTY(o.object_id, 'isforeignkey') = 1)
	begin
		alter table dbo.attorney drop constraint FK_attorney_roleid
	end

	drop table dbo.role
end

create table dbo.role
(
	role_id int primary key,
	role_desc nvarchar(50)
)

insert into role values (1, 'Attorney role')
insert into role values (2, 'Legal Assistant role')

if object_id('dbo.member_type', 'u') is not null
begin
	if exists (select 1 from sys.objects o where o.object_id = object_id('FK_membertypes_membertypeid') and OBJECTPROPERTY(o.object_id, 'isforeignkey') = 1)
	begin
		alter table dbo.member_types drop constraint FK_membertypes_membertypeid
	end
	
	drop table dbo.member_type
end

create table dbo.member_type
(
	member_type_id int primary key,
	member_type_name nvarchar(50) not null,
	member_type_desc nvarchar(200)
)

insert into member_type values (1, 'Attorney', 'Account used for attorneys')
insert into member_type values (2, 'Client', 'Account used for clients')

if object_id('dbo.account', 'u') is not null
begin
	if exists (select 1 from sys.objects o where o.object_id = object_id('FK_account_accountid') and OBJECTPROPERTY(o.object_id, 'isforeignkey') = 1)
	begin
		alter table dbo.member drop constraint FK_account_accountid
	end
	
	drop table dbo.account
end

create table dbo.account
(
	account_id int primary key,
	username nvarchar(100) not null,
	password nvarchar(50) not null,
	is_active bit default(0) not null,
	create_date datetime default(getdate()) not null,
	modified_date datetime,
	constraint AK_username unique(username)
)

if object_id('dbo.member', 'u') is not null
begin
	if exists (select 1 from sys.objects o where o.object_id = object_id('FK_member_memberid') and OBJECTPROPERTY(o.object_id, 'isforeignkey') = 1)
	begin
		alter table dbo.client drop constraint FK_member_memberid
	end

	if exists (select 1 from sys.objects o where o.object_id = object_id('FK_membertypes_memberid') and OBJECTPROPERTY(o.object_id, 'isforeignkey') = 1)
	begin
		alter table dbo.member_types drop constraint FK_membertypes_memberid
	end
	
	drop table dbo.member
end

create table dbo.member
(
	member_id int primary key,
	account_id int not null,
	first_name nvarchar(50) not null,
	last_name nvarchar(50) not null,
	title nvarchar(10),
	constraint FK_account_accountid foreign key (account_id) references dbo.account(account_id)
)

if object_id('dbo.client', 'u') is not null
begin
	drop table dbo.client
end

create table dbo.client
(
	client_id int primary key,
	member_id int not null,
	business_name nvarchar(100),
	business_title nvarchar(20),
	street_address1 nvarchar(100) not null,
	street_address2 nvarchar(100),
	street_city nvarchar(50) not null,
	street_state_code nvarchar(50) not null,
	street_country_code nvarchar(5) not null,
	street_postal_code nvarchar(10) not null,
	mailing_address1 nvarchar(100) not null,
	mailing_address2 nvarchar(100),
	mailing_city nvarchar(50) not null,
	mailing_state_code nvarchar(50) not null,
	mailing_country_code nvarchar(5) not null,
	mailing_postal_code nvarchar(10) not null,
	other_email_address nvarchar(100),
	mobile_phone_number nvarchar(10) not null,
	other_phone_number nvarchar(10),
	fax_number nvarchar(10),
	social_security_number nvarchar(9),
	employer_identification_number nvarchar(9),
	is_active bit default(1) not null,
	create_date datetime default(getdate()) not null,
	created_by int not null,
	modified_date datetime,
	modified_by int,
	constraint FK_member_memberid foreign key (member_id) references dbo.member(member_id)
)

if object_id('dbo.member_types', 'u') is not null
begin
	drop table member_types
end

create table dbo.member_types
(
	member_id int not null,
	member_type_id int not null,
	primary key (member_id, member_type_id),
	constraint FK_membertypes_memberid foreign key (member_id) references dbo.member(member_id),
	constraint FK_membertypes_membertypeid foreign key (member_type_id) references dbo.member_type(member_type_id)
)

if object_id('dbo.firm', 'u') is not null
begin
	drop table dbo.firm
end

create table dbo.firm
(
	firm_id int primary key,
	firm_name nvarchar(100) not null,
	street_address1 nvarchar(100) not null,
	street_address2 nvarchar(100),
	street_city nvarchar(50) not null,
	street_state_code nvarchar(50) not null,
	street_country_code nvarchar(5) not null,
	street_postal_code nvarchar(10) not null,
	mailing_address1 nvarchar(100) not null,
	mailing_address2 nvarchar(100),
	mailing_city nvarchar(50) not null,
	mailing_state_code nvarchar(50) not null,
	mailing_country_code nvarchar(5) not null,
	mailing_postal_code nvarchar(10) not null,
	main_phone_number nvarchar(10) not null,
	alt_phone_number nvarchar(10),
	fax_number nvarchar(10),
	website_url nvarchar(50),
	create_date datetime default(getdate()) not null,
	created_by int not null,
	modified_date datetime,
	modified_by int
)

if object_id('dbo.attorney', 'u') is not null
begin
	drop table dbo.attorney
end

create table dbo.attorney
(
	member_id int not null,
	firm_id int not null,
	role_id int not null,
	bar_number nvarchar(20),
	email_address nvarchar(100) not null,
	mobile_phone_number nvarchar(10) not null,
	other_phone_number nvarchar(10),
	fax_number nvarchar(10),
	hourly_billing_rate decimal,
	minimum_billing_increment decimal,
	is_active bit default(1) not null,
	is_primary_contact bit default(0) not null,
	create_date datetime default(getdate()) not null,
	created_by int not null,
	modified_date datetime,
	modified_by int,
	primary key (member_id, firm_id),
	constraint FK_attorney_roleid foreign key (role_id) references dbo.role(role_id)
)