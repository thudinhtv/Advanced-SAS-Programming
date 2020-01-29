Libname Orion 'Path';

/*Q1-L1 */
/*a: s109e01*/
proc sql;
   create table work.Products as
      select distinct * 
         from orion.Product_DIM;
quit;
proc print data=work.Products (obs=5);
run;


/*b*/
proc sql;
	create table work.Products as
       select distinct * 
       from orion.Product_DIM;

    create index Product_Name
       on Products (Product_Name);
quit;

/*c*/
options msglevel=I;
Proc SQL;
title "T-Shirt list";
     Select distinct Product_Name, Supplier_Name
	 From Products
	 Where Product_Name like '%T-Shirt';
quit;
title;


/*Q2-L2*/
/*a*/
proc sql;
   create table work.Products as
      select distinct * 
         from orion.Product_DIM;

   create unique index Product_ID
       on Products (Product_ID);
quit;


/*b*/
Options Msglevel=I;
Proc SQL;
Title "2007 Products Purchased";
     Select distinct Product_Name, Supplier_Name
	 From orion.Order_fact as F,
	      work.Products as P
	 Where F.Product_ID = P.Product_ID
	   And Year(Order_Date)= 2007;
quit;
title;

/*c*/
/* Index Product_ID of SQL table WORK.PRODUCTS (alias = P) selected for SQL
      WHERE clause (join) optimization */


/*Q3-L3*/


/*Q4-L1*/
/*a*/
proc sql;
   create table work.Products as
      select distinct * 
         from orion.Product_DIM
         order by Product_ID
   ;
quit;

Proc SQL;
	Update work.Products
		Set Product_Name = "Sunfit Speedy Swimming Trunks"
    	Where Product_ID = 210200200022;

	Select Product_ID, Product_Name
	from work.Products
    where Product_ID = 210200200022;
quit;

/*b*/
Proc SQL;
     Insert into work.Products
	            (Product_ID,Product_Line,Product_Category,Product_Group, 
      			Product_Name,Supplier_Country,Supplier_Name,Supplier_ID)
	 Values(240600100202,"Sports","Swim Sports","Snorkel Gear",
         "Coral Dive Mask - Med","AU","Dingo Divers",21001)
	 Values(240600100203,"Sports","Swim Sports","Snorkel Gear",
         "Coral Dive Mask - Large","AU","Dingo Divers",21001)
     Values(240600100212,"Sports","Swim Sports","Snorkel Gear",
         "Coral Dive Fins - Med","AU","Dingo Divers",21001)
     Values(240600100213,"Sports","Swim Sports","Snorkel Gear",
         "Coral Dive Fins - Large","AU","Dingo Divers",21001)
     Values(240600100222,"Sports","Swim Sports","Snorkel Gear",
         "Coral Advanced Snorkel","AU","Dingo Divers",21001)
     Values(240600100223,"Sports","Swim Sports","Snorkel Gear",
         "Coral Pro Snorkel","AU","Dingo Divers",21001);
quit;

/*c*/
Proc SQL; 
    Drop table work.Products;
quit;


/*Q5-L2*/
/*a*/
/*s109e05: create tables work.Products and New_Products*/
proc sql;
   create table work.Products as
      select distinct * 
      from orion.Product_DIM
      order by Product_ID
   ;
   create table work.New_Products
      (Product_ID num label='Product ID',
       Product_Line char(20) label='Product Line',
       Product_Category char(25) label='Product Category',
       Product_Group char(25) label='Product Group',
       Product_Name char(45) label='Product Name',
       Supplier_Country char(2) label='Supplier Country',
       Supplier_Name char(30) label='Supplier Name',
       Supplier_ID num label='Supplier ID'
      );
   insert into work.New_Products(Product_ID,Product_Line, 
               Product_Category, Product_Group, Product_Name,
               Supplier_Country, Supplier_Name, Supplier_ID)
      values(240600100202,"Sports","Swim Sports","Snorkel Gear",
             "Coral Dive Mask - Med","AU","Dingo Divers",21001)
      values(240600100203,"Sports","Swim Sports","Snorkel Gear",
             "Coral Dive Mask - Large","AU","Dingo Divers",21001)
      values(240600100212,"Sports","Swim Sports","Snorkel Gear",
             "Coral Dive Fins - Med","AU","Dingo Divers",21001)
      values(240600100213,"Sports","Swim Sports","Snorkel Gear",
             "Coral Dive Fins - Large","AU","Dingo Divers",21001)
      values(240600100222,"Sports","Swim Sports","Snorkel Gear",
             "Coral Advanced Snorkel","AU","Dingo Divers",21001)
      values(240600100223,"Sports","Swim Sports","Snorkel Gear",
             "Coral Pro Snorkel","AU","Dingo Divers",21001)
      values(240600100341,"Sports","Swim Sports","Snorkel Gear",
             "Coral Dive Skin - Small","AU","Dingo Divers",21001)
      values(240600100342,"Sports","Swim Sports","Snorkel Gear",
             "Coral Dive Skin - Med","AU","Dingo Divers",21001)
      values(240600100343,"Sports","Swim Sports","Snorkel Gear",
             "Coral Dive Skin - Large","AU","Dingo Divers",21001)
      values(240600100351,"Sports","Swim Sports","Snorkel Gear",
             "Coral Dive Goody Bag - Large","AU","Dingo Divers",21001)
      values(240600100352,"Sports","Swim Sports","Snorkel Gear",
             "Coral Dive Knife","AU","Dingo Divers",21001)
      values(240600100361,"Sports","Swim Sports","Snorkel Gear",
             "Coral Dive Duffel - Small","AU","Dingo Divers",21001)
      values(240600100362,"Sports","Swim Sports","Snorkel Gear",
             "Coral Dive Duffel - Med","AU","Dingo Divers",21001)
      values(240600100363,"Sports","Swim Sports","Snorkel Gear",
             "Coral Dive Duffel - Large","AU","Dingo Divers",21001)
      ;
quit;

/*Delete rows*/
Proc SQL;
	Delete from Work.Products
	Where Product_Group like '%Eclipse, Kid%';
quit; 

/*b*/
Proc SQL;
Insert into work.Products
       Select * from work.New_Products;
quit;

/*check if new data has been added*/
Proc SQL;
	Select Product_Name, Product_Category, Product_Group
	from work.Products
	Where Product_Category="Swim Sports";
quit;

/*c*/
Proc SQL;
 	Alter table work.Products
	    Add Shipping_Delay num;

	Update work.Products
	Set Shipping_Delay=7
	Where Supplier_ID=755
	and Product_Group = "Sleepingbags";
quit;

/*d*/
Proc SQL;
Title "Product Shipping Delays";
	Select Product_Name, Supplier_Name, Shipping_Delay
	From work.Products
	where Shipping_Delay is not missing;
quit;
title;

/*e*/
Proc SQL;
 	Alter table work.Products
	    Drop Shipping_Delay;

    Describe table work.Products;
quit;

/*f*/
Proc SQL;
	drop table work.Products;
	drop table work.New_Products;
quit;


/*Q6-L3*/

