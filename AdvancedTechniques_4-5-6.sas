libname Orion 'path';

/*CHAPTER 5*/
/*Q1-L1*/
/*a*/
Data Compare;
    Drop Month1-Month12 Statistic;
	Array mon{1:12} Month1-Month12;
	If _N_=1 then Set Orion.retail_information
	         (where=(Statistic='Median_Retail_Price'));
	Set Orion.retail;
	Month=month(Order_Date);
	Median_Retail_Price=mon(Month);
run;

/*b*/
Proc print data=compare (obs=8);
title "Partial Compare Data set";
run;
title;


/*Q2-L2*/
Data trans;
	Drop Product21-Product24;
	Array prod{21:24} Product21-Product24;
	Set orion.shoe_stats;
	do Product_Line=21 to 24;
	   Value=prod{Product_Line};
	output;
	end;
run;

proc print data=trans;
title "The TRANS data set";
run;
title;


/*Q3*/
/*a: p305e03*/

proc sort data=orion.order_fact out=order_fact(keep=Customer_ID Order_Type Order_Date                                                     Delivery_Date Quantity);
   where Customer_ID in (89, 2550) and year(Order_Date)=2007; 
   by Order_Type;
run;

proc sql;
   select Order_Type, count(*)
      from order_fact
         group by Order_Type;
quit;

/*  All SQL starter */
/*
proc sql;
  create table order_fact as
    select Customer_ID,
		   Order_Type,
           Order_Date,
           Delivery_Date,
           Quantity
	  from orion.order_fact
	    where Customer_ID in (89, 2550) and year(Order_Date)=2007
		  order by Order_Type;
   select Order_Type, count(*)
      from order_fact
         group by Order_Type;
quit;
*/

DATA all;   
     Array Ord_Dt{*} Ordered_Date1-Ordered_Date4;
	 Array Delv_Dt{*} Delivery_Date1-Delivery_Date4;
	 Array Quant{*} Quantity1-Quantity4;
	 Format Ordered_Date1-Ordered_Date4
            Delivery_Date1-Delivery_Date4
			date9.;
     N=0;
	 Do until (Last.Order_Type);
	    Set order_fact;
		By Order_Type;
	    N+1;
		Ord_Dt{N}=Order_Date;
		Delv_Dt{N}=Delivery_Date;
		Quant{N}=Quantity;
	 End;
run;

Proc print data=all (obs=3);
title "The Resulting Data Set";
run;


/*Q4-L1*/
Data customer_coupons;
	 Array Coupon{3,6} _temporary_ (10, 10, 15, 20, 20, 25,
	                                10, 15, 20, 25, 25, 30,
									10, 15, 15, 20, 25, 25);
     Set orion.order_fact (Keep=Customer_ID Order_Type Quantity);
	 Coupon_Value=Coupon{Order_Type, Quantity};
run;

Proc print data=customer_coupons (obs=5);
Title "The Coupon Value";
run;
title;


/*Q5-L2*/
Data Combine;
    Array MSRP {21:24, 1:2} _temporary_ (., 70.79, 173.79, 174.40, ., ., 29.65, 287.8);
	Set orion.shoe_sales;
	Prod_ID=put(Product_ID, 12.);
	Product_Line=input(Substr(Product_ID, 1,2),2.);
	Product_Cat_ID=input(Substr(Product_ID, 3,2),2.);
	Manufacturer_Suggested_Price=MSRP{Product_Line, Product_Cat_ID};
run;

Proc print data=Combine (obs=5);
run;


/*Q6-L3: p305e06*/

data Warehouse;
	Array Loc {21:22,0:2, 0:1} $5 _temporary_  ('A2100',
                                            	'A2101',
                                            	'A2110',
                                            	'A2111',
                                            	'A2120',
                                            	'A2121',
                                            	'B2200',
                                            	'B2201',
                                           	 	'B2210',
                                            	'B2211',
                                            	'B2220',
                                            	'B2221');
	set orion.product_list(keep=Product_ID Product_Name Product_Level
                           where=(Product_Level=1));
   	Prod_ID=put(Product_ID,12.);
   	Product_Line=input(substr(Prod_ID,1,2),2.);
   	Product_Cat_ID=input(substr(Prod_ID,3,2),2.);
   	Product_Loc_ID=input(substr(Prod_ID,12,1),1.);
   	if Product_Line in (21,22) and Product_Cat_ID <= 2
      and Product_Loc_ID < 2;
	Warehouse=Loc{Product_Line, Product_Cat_ID, Product_Loc_ID};
run;

proc print data=Warehouse (obs=5);
Title "Warehouses Data";
run;


/*Q7-L1*/
Data customer_coupons;
     Drop OT i j Quantity1-Quantity6;
	 Array Coupon{3,6} _temporary_ ;
	 If _N_=1 then do i=1 to 3;
	    	Set orion.coupons;
			Array quan{6} Quantity1-Quantity6;
			do j=1 to 6;
		   	Coupon{i,j}=quan{j};
			end;
	 end;
     Set orion.order_fact (Keep=Customer_ID Order_Type Quantity);
	 Coupon_Value=Coupon{Order_Type, Quantity};
run;

Proc print data=customer_coupons (obs=10);
Title "customer_coupons Data Set";
run;
title;


/*Q8-L1*/
Data customer_coupons;
     Drop OT Quant Value;
	 Array Coupon{3,6} _temporary_ ;
	 If _N_=1 then do i=1 to N_Obs;
	    	Set orion.coupon_pct nobs=N_Obs;
			Coupon{OT, Quant}=Value
	 end;
     Set orion.order_fact (Keep=Customer_ID Order_Type Quantity);
	 Coupon_Value=Coupon{Order_Type, Quantity};
run;

Proc print data=customer_coupons (obs=10);
Title "The Coupon Value";
run;
title;


/*Q9-L2*/
data combine;
   array ASRP{21:24,2} _temporary_ ;
   keep Product_ID Product_Name Total_Retail_Price Manufacturer_Suggested_Price; 
   format Manufacturer_Suggested_Price Dollar8.2;
   if _N_= 1 then do i=1 to N_Obs;
      set orion.msp nobs=N_Obs;
	  ASRP{Prod_Line,input(substr(put(Prod_Cat_ID,4.),3,2),2.)}=Avg_Suggested_Retail_Price;
   end;
   set orion.shoe_sales;
   Prod_ID=put(Product_ID,12.);
   Product_Line=input(substr(Prod_ID,1,2),2.);
   Product_Cat_ID=input(substr(Prod_ID,3,2),2.);
   Manufacturer_Suggested_Price= ASRP{Product_Line, Product_Cat_ID};
run;

proc print data=combine(obs=5);
run;


/*Q10-L3*/
Data warehouses;
	Keep Product_ID Product_Name Warehouse;
    Array W{21:24,0:8, 0:9} $5 _temporary_;
	If _N_=1 then do i=1 to N_Obs;
	     Set orion.warehouses nobs=N_Obs;
		 W{Product_Line, Product_Cat_ID, Product_Loc_ID} = Warehouse;
	End;
	Set orion.product_list(keep=Product_ID Product_Name Product_Level
                           where=(Product_Level=1));
	Prod_ID=put(Product_ID,12.);
   	Product_Line=input(substr(Prod_ID,1,2),2.);
   	Product_Cat_ID=input(substr(Prod_ID,3,2),2.);
   	Product_Loc_ID=input(substr(Prod_ID,12,1),1.);
	Warehouse=W{Product_Line, Product_Cat_ID, Product_Loc_ID};
run;

Proc print data=warehouses (obs=5);
title "warehouses";
run;
title;


/*-------------------------------------------------------------------------------------------------------*/

/*CHAPTER 6*/
/*Q1_L1*/
Data orders;
	Length Order_Code $1 Sale_Type $20;
	Keep Order_ID Order_Type Sale_Type;
	If _N_=1 then do;
		Declare Hash Ord();
		Ord.definekey('Order_Type');
		Ord.definedata('Sale_Type');
		Ord.definedone();
		Ord.add(key:1, data: 'Retail Sale');
		Ord.add(key:2, data: 'Catalog Sale');
		Ord.add(key:3, data: 'Internet Sale');
		Call missing(Sale_Type);
	End;
	Set orion.orders;
	rc=Ord.find();
	if rc=0;
run;

proc print data=orders (obs=5);
run;


/*Q2-L2*/

Data emps;
   Length State_Name $20 Country_Name $20;
	Keep State_Name Country_Name Employee_ID Country;
	If _N_=1 then do;
		Declare Hash SC();
		SC.definekey('State','Country');
		SC.definedata('State_Name', 'Country_Name');
		SC.definedone();
		SC.add(key:'FL', key:'US', data:'Florida', data:'United States');
      	SC.add(key:'PA', key:'US', data:'Pennsylvania', data:'United States');
      	SC.add(key:'CA', key:'US', data:'California', data:'United States');
      	SC.add(key:' ', key:'AU', data:' ', data:'Australia');
      	call missing(State_Name, Country_Name);
	End;
	Set orion.employee_addresses;
	rc=SC.find(key: Upcase(State), key: Upcase(Country));
	if rc=0;
run;

proc print data=emps (obs=10);
	title "Partial Data Set emps";
run;
title;


/*Q3-L3*/
Data _null_;
   	Length Continent_ID 8 Continent_Name $30 Location $10;
	If _N_=1 then do;
		Declare Hash C(ordered: 'descending');
		C.definekey('Continent_ID');
		C.definedata('Continent_ID', 'Continent_Name', 'Location');
		C.definedone();
		C.add(key:91, data:91, data:'North America', data:'North');
      	C.add(key:93, data:93, data:'Europe', data:'North');
      	C.add(key:94, data:94, data:'Africa', data:'South');
      	C.add(key:95, data:95, data:'Asia', data:'South');
      	C.add(key:96, data:96, data:'Australia/Pacific', data:'South');
      call missing(Continent_ID, Continent_Name, Location);
   end;
   C.output(dataset:"continents");
run;

proc print data=continents;
   title 'continents Data Set';
run;
title;


/*Q4-L1*/
Data customers;
    Length Customer_Type $50;
	Keep Customer_Type Customer_ID Customer_Type_ID;
	If _N_=1 then do;
		Declare Hash C(dataset: 'orion.customer_type');
		C.definekey('Customer_Type_ID');
		C.definedata('Customer_Type');
		C.definedone();
      	call missing(Customer_Type);
   	end;
	set orion.customer;
	If C.find()=0;
run;

proc print data=customers;
   title 'Partial customers Data Set';
run;
title;


/*Q5-L2*/
Data billing;
	Drop rc1 rc2 rc3 Country;
	If _N_=1 then do;
		If 0 then set orion.product_list (keep=Product_ID Product_Name);
		If 0 then set orion.customer_dim (keep=Customer_ID Customer_Country Customer_Name);
		If 0 then set orion.country (keep=Country Country_Name);

		Declare Hash Prod(dataset:'orion.product_list');
		Prod.definekey('Product_ID');
		Prod.definedata('Product_Name');
		Prod.definedone();

	    Declare Hash Cust(dataset:'orion.customer_dim');
		Cust.definekey('Customer_ID');
		Cust.definedata('Customer_Country', 'Customer_Name');
		Cust.definedone();

	    Declare Hash Con(dataset:'orion.country');
		Con.definekey('Country');
		Con.definedata('Country_Name');
		Con.definedone();

	end;

	set orion.order_fact (keep=Customer_ID Order_Date Product_ID Quantity Total_Retail_Price);

	rc1=Cust.find();
	if rc1=0;
	rc2=Prod.find();
	if rc2=0;
	rc3=Con.find(key: Customer_Country);
	if rc3=0;
run;

Proc Sort data=billing;
	By Customer_ID Product_ID;
run;

Proc print data=billing (obs=5);
     Var Customer_ID Customer_Name Customer_Country Country_Name
	     Product_ID Product_Name Order_Date Quantity Total_Retail_Price;
	 title1 "Billing Information";
	 title2 "Using a HASH Data Step Object";
run;
title;

	
/*Q6-L3*/
data manager;
   	length Employee_Name EmpName ManagerName $40;
   	keep Employee_ID EmpName Manager_ID ManagerName Salary;
   	if _N_=1 then do;
      	declare hash M(dataset:'orion.staff');
      	M.definekey('Employee_ID');
      	M.definedata('Manager_ID');
      	M.definedone();

		declare hash N(dataset:'orion.employee_addresses');
      	N.definekey('Employee_ID');
      	N.definedata('Employee_Name');
      	N.definedone();

		call missing(Employee_Name); 
   	end;

	set orion.employee_payroll(keep=Employee_ID Salary);

	rc1=M.find(key:Employee_ID);

	rc2=N.find(key:Employee_ID);
	if rc2=0 then EmpName=Employee_Name;
   	else EmpName=' ';

	rc3=N.find(key:Manager_ID);
   	if rc3=0 then ManagerName=Employee_Name;
   	else ManagerName=' ';
run;

proc print data=manager(obs=5);
  title "Partial Manager Data Set";
run;
title;


/*Q7-L1*/
Data expensive least_expensive;
	Drop i;
	If 0 then set orion.shoe_sales (keep=Product_ID Product_Name Total_Retail_Price);
	If _N_=1 then do;
		Declare Hash Shoes (dataset: 'orion.shoe_sales',
							ordered: 'descending');
		Shoes.definekey('Total_Retail_Price');
		Shoes.definedata('Total_Retail_Price', 'Product_ID', 'Product_Name');
		Shoes.definedone();
		Declare Hiter S('Shoes');
	end;

	S.first();
	do i=1 to 5;
		output expensive;
		S.next();
	end;

	S.Last();
	do i=1 to 5;
		output least_expensive;
		S.prev();
	end;
	stop;
run;

proc print data=expensive;
  title "The Five Most Expensive Shoes";
run;

proc print data=least_expensive;
  title "The Five Least Expensive Shoes";
run;

title;


/*Q8-L2*/
Data shoe_sales;
	Length Rank $10;
	Drop i;
	If 0 then set orion.shoe_sales (keep=Product_ID Product_Name Total_Retail_Price);
	If _N_=1 then do;
		Declare Hash Shoes (dataset: 'orion.shoe_sales',
							ordered: 'descending');
		Shoes.definekey('Total_Retail_Price');
		Shoes.definedata('Total_Retail_Price', 'Product_ID', 'Product_Name');
		Shoes.definedone();
		Declare Hiter S('Shoes');
	end;

	S.first();
	do i=1 to 5;
		Rank=Catx(' ', 'Top', i);
		output;
		S.next();
	end;

	S.Last();
	do i=1 to 5;
		Rank=Catx(' ', 'Bottom', i);
		output;
		S.prev();
	end;
	stop;
run;

proc print data=shoe_sales;
	Var Product_ID Product_Name Total_Retail_Price Rank;
  	title "Shoes";
run;
title;


/*Q9-L3*/
Data different;
	Drop rc;
	If _N_=1 then do;
		If 0 then set orion.order_fact (keep=Customer_ID Order_Type);
		Declare Hash O(dataset: 'orion.order_fact',
		  			   ordered: 'yes');
		Declare Hiter OF('O');
		O.definekey('Customer_ID', 'Order_Type');
		O.definedata('Customer_ID', 'Order_Type');
		O.definedone();
	end;
	rc=OF.first();
	do while (rc=0);
	output;
	rc=OF.next();
	end;
	stop;
run;

proc print data=different (obs=10);
	title "No Duplicates";
run;
title;


/*Q10-L1*/
proc sort data=orion.order_fact(keep=Customer_ID Product_ID Total_Retail_Price)
          out=order_fact;
   by Customer_ID;
run;

data order_fact;
  set order_fact;
  rename Product_ID=PID Total_Retail_Price=TRP;
  ObsNum=_N_; 
run;

data next_products;
   keep Customer_ID Product_ID Total_Retail_Price 
        Next_Product_ID Next_Price;

   if _N_=1 then do; 
      declare hash LU(dataset: "order_fact");
      LU.definekey('ObsNum');
      LU.definedata('PID', 'TRP');
      LU.definedone();
      call missing(PID, TRP);
   end;

   set order_fact(rename=(PID=Product_ID 
                          TRP=Total_Retail_Price));   
   by Customer_ID;

   Obs=ObsNum + 1; 
   rc=LU.find(key:Obs);
 
   if rc=0 then do;
      Next_Product_ID=PID; 
      Next_Price=TRP;
   end;

   if last.Customer_ID then do;
      Next_Product_ID=.; 
      Next_Price=.;
   end;
run;

proc print data=next_products(obs=10);
   title 'Next Product Ordered';
   format Next_Price dollar8.2;
run;
title;


/*Q11-L2*/
Proc Sort data=orion.customer (keep=Country Customer_ID)
		  out=customer_list;
	 By Country;
run;

Data customer_list;
     set customer_list;
	 ObsNum=_N_;
run;

Data customer_list;
	 length All_Customers $300;
	 if _N_=1 then do; 
      	declare hash LU(dataset: "customer_list");
      	LU.definekey('ObsNum', 'Country');
      	LU.definedata('Country', 'Customer_ID');
      	LU.definedone();
     end;

	 do until (Last);
   		set customer_list end=Last;
        by Country;
		if first.Country then All_Customers=Customer_ID;
		Obs=ObsNum + 1; 
   		rc=LU.find(key:Obs, key: Country);
  
		if  rc=0 then All_Customers=catx(', ', All_Customers, Customer_ID);
		else output;
	 end;
run;

proc report data=customer_list nowd headline headskip;
   column Country All_Customers;
   define Country / width=20 order 'Customer/Country';
   define All_Customers / width=50 flow 'Customer/List';
   break after Country / skip;
run;


/*Q12-L3*/
proc sort data=orion.product_dim out=product_dim;
   by Supplier_ID;
run;

data product_dim;
  set product_dim;
  ObsNum=_N_; 
run;

data suppliers;
   length All_Products $500 All_Names $750;
   if _N_=1 then do; 
      declare hash LU(dataset: "product_dim");
      LU.definekey('ObsNum', 'Supplier_ID');
      LU.definedata('Supplier_Name', 'Product_ID',' Product_Name');
      LU.definedone();
   end;
   do until (Last);
      set product_dim end=Last;
      by Supplier_ID;
      if first.Supplier_ID then do;
         All_Products=put(Product_ID,12.);
         All_Names=Product_Name;
      end;
      Obs=ObsNum + 1; 
      rc=LU.find(key:Obs, key:Supplier_ID); 
      if rc=0 then do; 
         All_Products=catx(', ', All_Products, put(Product_ID,12.));
         All_Names=catx(', ', All_Names, Product_Name);
      end;
      else output;
   end; 
run;
 
title 'Supplier Product List';
proc report data=suppliers nowd headline headskip ls=132;
   column Supplier_Name All_Products All_Names;
   define Supplier_Name / width=30 order 'Supplier';
   define All_Products / width=30 flow 'Product/List';
   define All_Names / width=50 flow 'Names of/Products';
   break after Supplier_Name / skip;
run;
title;
