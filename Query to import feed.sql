--create database 

----Load the a Xml file into different tables and make its relation if there is an parent child relation is present.

Use Flipkart



/*-------------------------------Different catalogs for different countries

Create Table catalogs(Catalogid varchar(20), Name varchar(500))
insert into catalogs values('flipkart01','Flipkart_IN'), ('flipkart02','Flipkart_US')

--------------------------Different items in different country.

create table account_catalogs (account_ID varchar(500),Catalog_ID varchar(500))
 INSERT INTO account_catalogs (account_ID, Catalog_ID)
    VALUES ('Flipkart','flipkart01' ),('Flipkart','flipkart02')


---------------------------------Different catalog for different appication like mobile, tab, desktop

Create table Applications(App_id varchar(50),Account_id varchar(50),Name varchar(50))
INSERT INTO Applications (App_id, Account_id, Name)
  VALUES ('01flipkart','Flipkart','IN Desktop' ),
  ('02flipkart','Flipkart','IN Mobile' ),('03flipkart','Flipkart','US Desktop'),('04flipkart','Flipkart','US Mobile')


  Create table Applications_catalog(App_id varchar(50),catalog_id varchar(50))
  insert into Applications_catalog (App_id,catalog_id)
  values('01flipkart','flipkart01'),('02flipkart','flipkart01')


-------------------------------*/

Declare @Account_ID varchar(50) = 'Flipkart'
Declare @Catalog_ID varchar(50) = 'flipkart01'
Declare @App_id varchar(50)='01flipkart'


if not exists(select * from catalogs where CatalogID = @Catalog_ID)
    insert into catalogs (CatalogID, Name)
    VALUES (@Catalog_ID, 'Flipkart IN')

if not exists(select * from Applications_catalog where App_ID = @App_ID and Catalog_ID = @Catalog_ID)
    insert into Applications_catalog (App_ID, Catalog_ID)
    VALUES (@App_ID, @Catalog_ID)

if not exists(select * from account_catalogs where account_ID = @Account_ID and Catalog_ID = @Catalog_ID)
    insert into account_catalogs (account_ID, Catalog_ID)
    VALUES (@Account_ID, @Catalog_ID)


------------------------------------------

	 SELECT CAST(MY_XML AS xml) as xml_doc 
	 into #test_catalog
     FROM OPENROWSET(BULK 'D:\Essential\SQL\Flipkart.xml', SINGLE_BLOB) AS T(MY_XML)
	  

  create table #Parent_items
  	  (
	   itemid varchar(500),
	   isdisable varchar(225),
	   name varchar(500),
	   value varchar(500)
	  )


	    create table #child_items
	  (
	   itemid varchar(500),
	   id varchar(500),
	   recommendable varchar(500),
	   searchable varchar(500),
	   name varchar(500),
	   value varchar(500)
	  )


declare	  @xmlDoc xml
select @xmlDoc=(select xml_doc from #test_catalog)

insert into #Parent_items
SELECT     
	 itemId = X.value('(itemId)[1]', 'varchar(500)'),
	 isDisabled=X.value('(isDisabled)[1]','varchar(500)'),
	 name=x2.value('@name','varchar(500)'),
	 value=x2.value('(value)[1]', 'varchar(500)')
  FROM @xmlDoc.nodes('/certonaFeed/catalog/items/item') AS XT1(X)
	Cross apply X.nodes('parentAttributes/attribute') AS XT2(X2)


insert into #child_items
SELECT     
     itemId = X.value('(itemId)[1]', 'varchar(500)'),
	 id = X1.value('(id)[1]', 'varchar(500)'),
	 recommendable=X1.value('(recommendable)[1]','varchar(500)'),
	  searchable=X1.value('(searchable)[1]','varchar(500)'),
	 name=x2.value('@name','varchar(500)'),
	 value=x2.value('(value)[1]', 'varchar(500)')
  FROM
    @xmlDoc.nodes('/certonaFeed/catalog/items/item') AS XT(X)
	Cross apply X.nodes('childIds/childId') AS XT1(X1)
	Cross apply X1.nodes('attributes/attribute') AS XT2(X2)

	
--(5180 row(s) affected)

--(149376 row(s) affected)

	select  *
	from #Parent_items
	where itemid='TOKYO'
	--'21AF'

	select  *
	from #child_items
	where itemid='TOKYO'
	

	
--------------------------


--create table Object_Lookup (Object_ID nvarchar(500),Item_ID varchar(500), Account_ID varchar(500))

insert into Object_Lookup (Object_ID, Item_ID, Account_ID)
select NewID() as object_id,itemId,'Flipkart'
from(
select distinct df.itemId
--into #objects
from #parent_items as df
    left join object_lookup
	on object_lookup.account_id = 'Flipkart'
	and object_lookup.Item_ID = df.itemId
where object_lookup.Item_ID is NULL
)a


select * from Object_Lookup
----------------------------

--select distinct name from #Parent_items


--select distinct name from #child_items


---------------------------

--drop table Parent_ItemInfo

create table Parent_ItemInfo (Itemuid nvarchar(500),Object_ID nvarchar(500),Catalog_ID varchar(500),Account_ID VARCHAR(500),itemId varchar(500), isdisable varchar(500),apmaApproved varchar(500),sizes varchar(500),itemName varchar(500),adjustable varchar(500),instockFlag varchar(500),
description varchar(500),collection varchar(500),saleFlag varchar(500),category varchar(500),brand varchar(500),
weatherResistant varchar(500),subCategory varchar(500),age varchar(500),slipResistant varchar(500),gender varchar(500),
currencyCode varchar(500),colors varchar(500),newFlag varchar(500),widths varchar(500),itemRating varchar(500),
promotionFlag varchar(500),imageUrl varchar(500),allCategories varchar(500),originalPrice varchar(500),reviewCount varchar(500),
currentPrice varchar(500),detailUrl varchar(500),parentCategory varchar(500))


Declare @Account_ID varchar(500) = 'Flipkart'
Declare @Catalog_ID varchar(500) = 'flipkart01'

insert into Parent_ItemInfo
select newid(),Object_ID,Catalog_ID,Account_ID,itemId , isdisable,[apmaApproved],[sizes],[itemName],[adjustable],[instockFlag],[description],[collection],[saleFlag],[category],
[brand],[weatherResistant],[subCategory],[age],[slipResistant],[gender],[currencyCode],[colors],[newFlag],
[widths],[itemRating],[promotionFlag],[imageUrl],[allCategories],[originalPrice],[reviewCount],[currentPrice]
,[detailUrl],[parentCategory]
from(

	select  o.Object_ID,@Catalog_ID as Catalog_ID ,@Account_ID as Account_ID,df.*
	from #Parent_items  df 
	inner join object_lookup o
	on o.account_id = @Account_ID and  df.itemid=o.Item_ID
	 left join Parent_ItemInfo i
		on i.itemId = df.itemid
		and i.Account_ID = @Account_ID
		and i.Catalog_ID = @Catalog_ID
	where I.itemId is null
	)s
	pivot
	(
	max(value) for name in( [apmaApproved],[sizes],[itemName],[adjustable],[instockFlag],[description],[collection],[saleFlag],[category],
[brand],[weatherResistant],[subCategory],[age],[slipResistant],[gender],[currencyCode],[colors],[newFlag],
[widths],[itemRating],[promotionFlag],[imageUrl],[allCategories],[originalPrice],[reviewCount],[currentPrice]
,[detailUrl],[parentCategory])
	)a



	select * from Parent_ItemInfo

----------------------------------------------------------------------------

	select * from #child_items
	where name like '%inventory%'

	insert into Object_Lookup (Object_ID, Item_ID, Account_ID)
select NewID() as object_id,id,'Flipkart'

from(
select distinct df.id
--into #objects
from #child_items as df
    left join object_lookup
	on object_lookup.account_id = 'Flipkart'
	and object_lookup.Item_ID = df.Id
where object_lookup.Item_ID is NULL
)a
-------------------------------------------------------

select *
from #child_items


create table Child_ItemInfo (Itemuid nvarchar(500),Object_ID nvarchar(500),Catalog_ID varchar(500),Account_ID VARCHAR(500),itemId varchar(500),
 recommenable varchar(500),searchable varchar(500),image varchar(500),instockFlag varchar(500),saleFlag varchar(500),clearanceFlag varchar(500),inventoryCount varchar(500),link varchar(500),newFlag varchar(500),width varchar(500),leatherFree varchar(500),displayName varchar(500),promotionFlag varchar(500),size varchar(500),originalPrice varchar(500),currentPrice varchar(500),color varchar(500),leather varchar(500))
insert into Child_ItemInfo
select newid(),Object_ID,Catalog_ID,Account_ID,Id , recommendable,searchable,[image],[instockFlag],[saleFlag],[clearanceFlag],[inventoryCount],[link],[newFlag],[width],[leatherFree],[displayName],[promotionFlag],[size],[originalPrice],[currentPrice],[color],[leather]
from(

	select  o.Object_ID,@Catalog_ID as Catalog_ID ,@Account_ID as Account_ID,df.*
	from #child_items  df 
	inner join object_lookup o
	on o.account_id = @Account_ID and  df.id=o.Item_ID
	 left join Child_ItemInfo i
		on i.itemId = df.id
		and i.Account_ID = @Account_ID
		and i.Catalog_ID = @Catalog_ID
	where I.itemId is null
	)s
	pivot
	(
	max(value) for name in( [image],[instockFlag],[saleFlag],[clearanceFlag],[inventoryCount],[link],[newFlag],[width],[leatherFree],[displayName],[promotionFlag],[size],[originalPrice],[currentPrice],[color],[leather])
	)a


------------------------------parent and child object mappng

select *
from Object_Lookup

select * from Parent_ItemInfo

select * from Child_ItemInfo

 Create table Object_Rollup(Parent_Object_ID nvarchar(500),Child_Object_ID nvarchar(500),Last_Update datetime)

	INSERT INTO Object_Rollup (Parent_Object_ID, Child_Object_ID, Last_Update)
	SELECT pc.parentObject, pc.childObject, getdate()
	FROM 
	(
	   SELECT distinct p.object_id as parentObject, c.object_id as childObject
	   FROM object_lookup p--#pObjects p
		INNER JOIN #child_items df
		ON p.item_id = df.itemid
		INNER JOIN object_lookup c
		ON df.id = c.Item_ID
		--where p.Object_ID='01A93978-A1FB-484B-B53F-AF8D340A6BFE'
	
	) pc
		LEFT JOIN Object_Rollup r on
		pc.childObject = r.Child_Object_ID
	WHERE r.Child_Object_ID is null;


	/*select * from Object_Lookup
	where Item_ID in(
	--='01A93978-A1FB-484B-B53F-AF8D340A6BFE'

	select distinct id from #child_items
	where itemid='335MILES'
	)order by object_id

	SELECT distinct p.object_id as parentObject, c.object_id as childObject
	   FROM object_lookup p--#pObjects p
		INNER JOIN #child_items df
		ON p.item_id = df.itemid
		INNER JOIN object_lookup c
		ON df.id = c.Item_ID
		where p.Object_ID='01A93978-A1FB-484B-B53F-AF8D340A6BFE'
		order by c.object_id
		*/

select p.*,c.*
from Object_Rollup r
inner join Parent_ItemInfo p on p.Object_ID=r.Parent_Object_ID
inner join Child_ItemInfo c on c.Object_ID=r.Child_Object_ID
where r.Parent_Object_ID='01A93978-A1FB-484B-B53F-AF8D340A6BFE'


------------------------------------------------




------------------------------------------------
	
	/*
declare	  @xmlDoc xml
select @xmlDoc=(select xml_doc from #test_catalog)
declare @idoc int;
exec sp_xml_preparedocument @idoc OUTPUT, @xmlDoc;

select *
from openxml(@idoc, '/certonaFeed/catalog/items/item/parentAttributes/attribute')
with
(
itemId varchar(255) '../../itemId'
, isDisabled varchar(255) '../../isDisabled'
, name varchar(255) '@name'
, value varchar(255) './value'

)

*/
