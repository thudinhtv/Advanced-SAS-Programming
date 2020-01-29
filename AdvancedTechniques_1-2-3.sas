libname Orion 'path';

/*Chap 1*/
/*Q1: p301e01*/
/*abc*/
OPTIONS FULLSTIMER;
data order_fact;
   infile 'order_fact.dat' pad; 
   input @37 Order_Date date9. @;
   input  @1 Customer_ID 12. 
         @13 Employee_ID 12.
         @25 Street_ID 12.
         @46 Delivery_Date Date9.
         @55 Order_ID 12.
         @67 Order_Type 2.
         @69 Product_ID 12.
         @81 Quantity 4.
         @90 Total_Retail_Price 13.
        @105 CostPrice_Per_Unit 10.
        @115 Discount 5.;
   if year(Order_Date)=2006;
   format Customer_ID Employee_ID Street_ID Order_ID 
          Product_ID 12. Order_Date Delivery_Date date9. 
          Order_Type 2. Quantity 4. Total_Retail_Price dollar13.2
          CostPrice_Per_Unit dollar10.2 Discount Percent.;
run;

/*def*/
data order_fact;
   infile 'order_fact.dat' pad; 
   input @37 Order_Date date9. @;
   if year(Order_Date)=2006;
   input  @1 Customer_ID 12. 
         @13 Employee_ID 12.
         @25 Street_ID 12.
         @46 Delivery_Date Date9.
         @55 Order_ID 12.
         @67 Order_Type 2.
         @69 Product_ID 12.
         @81 Quantity 4.
         @90 Total_Retail_Price 13.
        @105 CostPrice_Per_Unit 10.
        @115 Discount 5.;
   format Customer_ID Employee_ID Street_ID Order_ID 
          Product_ID 12. Order_Date Delivery_Date date9. 
          Order_Type 2. Quantity 4. Total_Retail_Price dollar13.2
          CostPrice_Per_Unit dollar10.2 Discount Percent.;
run;


/*-------------------------------------------------------------------------------------------------------------------*/

/*Chap 2*/
/*Q1: p302e01*/

options fullstimer;
SASFILE orion.organization_dim LOAD;

proc print data=orion.organization_dim noobs;
   where Department='Administration';
   var Employee_ID Employee_Country Section Job_Title;
run;

proc means data=orion.organization_dim min mean max;
   var Salary;
   class Department;
run;

proc report data=orion.organization_dim headline headskip nowd;
   column Company Department 
          Employee_Hire_Date Employee_BirthDate 
		  HiredAge;
   define Company/order;
   define Department/order;
   define HiredAge/computed format=12.2 'Age when Hired';
   compute HiredAge;
      HiredAge=yrdif(Employee_BirthDate.sum,Employee_Hire_Date.sum,'Act/Act');
   endcomp;
run;

proc freq data=orion.organization_dim;
   table Department*Company/norow nocol;
run;

proc means data=orion.organization_dim min mean max maxdec=2;
   class Company;
   var Salary;
run;

SASFILE orion.organization_dim CLOSE;
options nofullstimer;

/*f: User CPU time decreases*/


/*Q2: p302e02*/
options fullstimer;
sasfile orion.employee_addresses load;
sasfile orion.employee_donations load;

proc means data=orion.employee_donations sum mean median;
   class Recipients;
   var Qtr1-Qtr4;
run;

proc freq data=orion.employee_donations;
   tables Recipients;
run;

proc report data=orion.employee_addresses headline headskip nowd;
   columns Employee_ID Employee_Name City State;
   define State/width=5;
   where Country='US';
run;

proc freq data=orion.employee_addresses;
   tables Country;
run;

proc sql;
   select Employee_Name, sum(Qtr1, Qtr2, Qtr3, Qtr4) as Total_Contribution, 
          Recipients
       from orion.employee_addresses as a, 
            orion.employee_donations as d
       where a.Employee_ID=d.Employee_ID;
quit;

sasfile orion.employee_addresses close;
sasfile orion.employee_donations close;
options nofullstimer;


/*Q3*/
/*a: p302e03*/
proc copy in=orion out=work;
   select sales nonsales;
run; 

/*b*/
SASFILE work.sales LOAD;

/*Method 1: Use Proc Datasets to change the names of variables in the nonsales data to be compatible with the 
            variables in the sales data. Then use Proc Append to append nonsales data to sales data*/
Proc Datasets Lib=Work;
     MODIFY nonsales;
	      RENAME First = First_Name
		         Last = Last_Name;
quit;

Proc Append base=sales data=nonsales FORCE;
Run;

Proc print data=sales;
run;

/*Method 2: Use Proc Append with Rename option*/
Proc Append base=sales 
            data=nonsales (RENAME (First = First_Name
		                           Last = Last_Name)
            FORCE;
run;

SASFILE work.sales CLOSE;


/*Q4*/
/*a*/
Proc contents data=orion.internet;
run;
Proc contents data=orion.retail;
run;
Proc contents data=orion.catalog;
run;

/*b: p302e04*/
data all_customers;
   length quantity 3 
          customer_id order_date delivery_date 4 
          employee_id 5 
          street_id order_id 6
   	  product_ID 7 ;
   set orion.catalog orion.internet orion.retail;
run;

proc contents data=all_customers;
run;


/*Q5: p302e05*/
data five;
   length Num5 5 Num8 8;
   do Num8=1e10 to 1e13 by 1e11;
      Num5=Num8;
      output;
   end;
run;

proc print data=five;
   title 'Reducing the length of numeric data to 5';
   format Num5 Num8 20.;
run;


/*Q6: p302e06*/
data numbers;
   input Value;
   datalines;
8191
8192
8193
8194
;

data temp;
   set numbers;
   X=Value;
   do L=8 to 1 by -1;
      if X NE trunc(X,L) then
      do;
         MinLen=L+1;
         output;
         return;
      end;
   end;
run;
title;

proc print noobs;
   var Value MinLen;
run;


/*Q7: p302e07*/
/********************************************/
/* If you did not run the previous activity */
/* run these steps. If you did run the      */
/* previous activity, comment them out.     */
/********************************************/

/*  These SORT steps need only be run once */

proc sort data=orion.employee_addresses 
          out=employee_addresses;
   by Employee_ID;
run;

proc sort data=orion.employee_organization 
          out=employee_Organization;
   by Employee_ID;
run;

proc sort data=orion.employee_payroll out=employee_payroll;
   by Employee_ID;
run;

proc sort data=orion.employee_phones out=employee_phones;
   by Employee_ID;
run;


/*  Create uncompressed employees data set */

data employees;
   merge employee_addresses employee_organization 
         employee_payroll employee_phones;
   by Employee_ID;
run;


/*  Create short numerics employees data set */

data emps_short;
   length Street_ID 6 Employee_ID Manager_ID 5  
          Street_Number Employee_Hire_Date 
          Employee_Term_Date 4 
          Dependents 3;
   merge employee_addresses 
         employee_organization 
         employee_payroll 
         employee_phones;
   by Employee_ID;
run;

/*  Create RLE compressed employees data set */

data empchar(compress=char);
   merge Employee_addresses Employee_organization 
         Employee_payroll Employee_phones;
   by Employee_ID;
run;

/*  Create RDC compressed employees data set */

data empbin(compress=binary);
   merge Employee_addresses Employee_organization 
         Employee_payroll Employee_phones;
   by Employee_ID;
run;


/**************************************************/
/* If you ran the previous activities, start here */
/**************************************************/

/*  Comparison of reading the four employees data sets */
options fullstimer;
data _null_;
  set employees;
run;

data _null_;
  set emps_short;
run;

data _null_;
  set empchar;
run;

data _null_;
  set empbin;
run;



/*Q8*/
/*b*/
Proc sort data=orion.product_list out=sorted_product_list;
     By Supplier_ID;
run;

Data supplier_names (COMPRESS=CHAR);
     Merge orion.supplier sorted_product_list;
	 By Supplier_ID;
run;


/*c*/
Proc sort data=orion.product_list out=sorted_product_list;
     By Supplier_ID;
run;

Data supplier_names (COMPRESS=BINARY);
     Merge orion.supplier sorted_product_list;
	 By Supplier_ID;
run;


/*Q9*/
/*a*/
libname orcomp 'C:\temp' compress=yes;

/*b*/
Proc copy in=orion out=orcomp NOCLONE;
     SELECT c: ;
run;

/*e*/
Proc datasets lib=orcomp;
     DELETE c: ;
quit;

libname orcomp clear;

/*-------------------------------------------------------------------------------------------------------------------------*/


/*Chap 3*/
/*Q1*/
/*a*/
Options msglevel=I;
data orders (Index= (Customer_ID Order_ID/ UNIQUE));
   set orion.orders;
   Days_To_Delivery=Delivery_Date - Order_Date;
run;
Options msglevel=n;

/*b*/
Proc SQL;
     Drop index Order_ID
	 From orders;
quit;

/*c*/
Proc Datasets library=work nolist;
     Modify orders;
     index create OrDate=(Order_ID Order_Date);
quit;
	
/*d*/
Proc contents data=orders;
run;

/*C2*/
Proc datasets library=work nolist;
     contents data=orders;
quit;


/*Q2*/
/*a*/
Options Msglevel=I;
Data price_list (index=(Product_ID / UNIQUE));
     Set orion.price_list;
	 Unit_Profit=Unit_Sales_Price - Unit_Cost_Price;
run;

/*b: p303e02*/
proc sql;
   insert into price_list(Product_ID, 
			  Start_Date,
                          End_Date, 
		          Unit_Cost_Price,
		          Unit_Sales_Price, 
                          Factor,
		          Unit_Profit)
      values (210200100009, '15FEB2007'd, '31DEC9999'd, 15.50, 34.70, 1.00, 19.20);
quit;


/*Q3*/
data all_staff (index=(Age_Hired));
     Set orion.sales 
	     orion.nonsales (rename=(First=First_Name
		                         Last=Last_Name));
	 Aged_Hired=int(Hire_Date - Birth_Date)/ 365.25;
run;


/*Q4*/
options msglevel=i;

*** Example 1;

data rdu;
   set orion.sales_history;
   if Order_ID=1230166613;
run;

*** Example 2;

proc print data=orion.sales_history;
   where Order_ID=1230166613 or Product_ID=220200100100;
run;

*** Example 3;

proc print data=orion.sales_history;
   where Product_Group ne 'Shoes';
run;

*** Example 4;

proc print data=orion.sales_history;
   where Customer_ID=12727;
run;

**** Example 5;

proc print data=orion.sales_history;
   Where Product_Group='Tents';
run;

*****Example 6;

data saleshistorycopy;
   set orion.sales_history;
run;


/*Q5*/
Options Msglevel=I;

Proc print data=orion.supplier(IDXWHERE=NO);
   where Supplier_ID > 1000;
run;



/*Q6*/
/*a: p303e06*/
data orders(index=(Order_ID/unique Customer_ID));
   set orion.orders;
run;

proc contents data=orders centiles;
run;

/*b*/
Proc datasets lib=work nolist;
     Modify orders;
	     index centiles order_ID/ updatecentiles=1;
quit;


/*c: p303e06c*/
data neworders;
  set orion.orders (obs=5);
  month=month(order_date);
  day=day(order_date);
  order_date=mdy(month, day, 2008);
  month=month(delivery_date);
  day=day(delivery_date);
  delivery_date=mdy(month, day, 2008);
  order_id + 14239000;
  drop month day;
run;

proc append base=orders data=neworders;
run;

/*d*/
proc contents data=orders centiles;
run;


/*Q7*/
data products_sample;
    do i=1 to TotObs=10 by 10;
	    set orion.product_dim
		    (keep=Product_Line Product_ID Product_Name Supplier_Name)
			point=i
			nobs=TotObs;
		output;
	end;
	stop;
run;

proc print data=products_sample (obs=5) noobs;
     title "Systematic Smaple of Products";
run;
title; 


/*Q8: with replacemnent*/
data underforty fortyplus;
   drop i SampSize;
   SampSize=50;
   do i=1 to SampSize;
      PickIt=ceil(ranuni(0) *TotObs);
      set orion.customer_dim point=PickIt nobs=TotObs;
      if Customer_Age < 40 then output underforty;
	  else output fortyplus;
    end;
    stop;
run;
 
proc print data=fortyplus; 
   title 'Customers with Age >= 40';
run;
 
proc print data=underforty; 
   title 'Customers with Age < 40';
run;
title;


/*Q9*/
data sample(drop=ObsLeft SampSize);
   SampSize=int(.10 * TotObs);
   ObsLeft=TotObs;
   do while(SampSize > 0 and ObsLeft > 0);
      PickIt + 1;
      if ranuni(0) < SampSize / ObsLeft then
         do;
            ObsPicked=PickIt;
            set orion.customer_dim point=PickIt
                                   nobs=TotObs;
            output;
            SampSize=SampSize - 1;
         end;
      ObsLeft=ObsLeft - 1;
   end;
   stop;
run;


/* Alternative Method */
/* to get an approximate 10% sample */
data sample;
   set orion.customer_dim;
   if ranuni(0) <= .10;
run;


