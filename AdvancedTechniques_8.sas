libname Orion 'path';

/*Q1-L1*/

proc sort data=orion.order_fact(keep=Customer_ID Product_ID)  
          out=order_fact;
   by Customer_ID;
run;

data temp;
   merge order_fact(in=O) 
         orion.customer_dim(in=C keep=Customer_ID Customer_Name);
   by Customer_ID;
   if O and C;
run;

proc sort data=temp;
   by Product_ID;
run;

data purchases;
   keep Customer_Name Product_Name Supplier_Name;
   merge temp(in=T) 
         orion.product_dim( in=P keep=Product_ID Product_Name Supplier_Name);
   by Product_ID;
   if P and T;
run;

proc print data=purchases(obs=5);
   title 'Partial purchases Data Set';
run;


/* PROC SQL Solution   */
proc sql;
   create table purchases as
     select Customer_Name, 
            Product_Name, 
            Supplier_Name
       from orion.order_fact, 
            orion.product_dim, 
            orion.customer_dim
	 where order_fact.Customer_ID=customer_dim.Customer_ID and
               order_fact.Product_ID=product_dim.Product_ID
       order by order_fact.Product_ID;
quit;

proc print data=purchases(obs =5);
   title 'Partial purchases Data Set';
run;

title;


/*Q2-L2*/
/* PROC SQL Solution   */

Proc SQL;
    Create table no_purchases as
       select Customer_ID, 
              Customer_Name
	 from orion.customer_dim 
           where customer_dim.Customer_ID not in 
		 (select Customer_ID 
                    from orion.order_fact);

   create table purchases as
      select O.*, 
             Customer_Name, 
             Product_Name, 
             Supplier_Name
	  from orion.order_fact O, 
           orion.product_dim P, 
           orion.customer_dim C
	  where O.Customer_ID=C.Customer_ID 
            and O.Product_ID=P.Product_ID
      order by O.Product_ID;

	create table no_products as
       select Product_ID, 
              Product_Name
	  from orion.product_dim 
            where product_dim.Product_ID not in 
		       (select Product_ID 
                  from orion.order_fact);

quit;

proc print data=no_purchases;
   title 'no_purchases Data Set';
run;

proc print data=purchases(obs=5);
   title 'Partial purchases Data Set';
run;

proc print data=no_products(obs=5);
   title 'Partial no_products Data Set';
run;

title;


/*Q4-L1*/
data sales_emps;
   set orion.salesstaff;
   set orion.organization_dim(keep=Employee_ID Department Section Org_Group) key=Employee_ID;
   if _IORC_=0;
run;

proc print data=sales_emps(obs=5);
   title 'Sales Employee Data';
   title2 '(Partial Output)';
run;

title;

/*Q7-L1*/
/* Using PROC SUMMARY and the DATA STEP */

proc summary data=orion.customer_dim;
   var Customer_Age;
   output out=average mean=AvgAge;
run;

data age_dif;
   if _N_=1 then set average(keep=AvgAge);
   set orion.customer_dim(keep=Customer_ID Customer_Age);
   Age_Difference=Customer_Age - AvgAge;
run;

/* Using PROC SUMMARY and PROC SQL */

proc summary data=orion.customer_dim;
   var Customer_Age;
   output out=average mean=AvgAge;
run;

proc sql;
   create table age_dif as
     select AvgAge, 
            Customer_ID, 
            Customer_Age, 
            Customer_Age - AvgAge as Age_Difference
       from orion.customer_dim, 
            average;
quit;
  
/* Using PROC SQL only */

proc sql;
   create table age_dif as
   select mean(Customer_Age) as AvgAge, 
          Customer_ID,
	  Customer_Age,
          Customer_Age - calculated AvgAge as Age_Difference
   from orion.customer_dim;
quit;

/* Using the DATA step only */

data age_dif;
   drop i Tot_Age;
   if _N_=1 then do i=1 to TotObs;
      set orion.customer_dim(keep=Customer_Age) nobs=TotObs;
      Tot_Age + Customer_Age;
   end;
   set orion.customer_dim(keep=Customer_ID Customer_Age);
   AvgAge=Tot_Age / TotObs;
   Age_Difference=Customer_Age - AvgAge;
run;


proc print data=age_dif(obs=5);
   var AvgAge Customer_ID Customer_Age Age_Difference;	
   title 'The age_dif Data Set';
   title2 '(Partial Output)';
run;

title;


/*Q8*/
proc sql;
   create table compare as
     select mean(sum(Qtr1, Qtr2, Qtr3, Qtr4)) as Avg_Donation,
            D.*, 
            sum(Qtr1, Qtr2, Qtr3, Qtr4) as Total_Donation,
            calculated Total_Donation - calculated Avg_Donation as Difference
       from orion.employee_donations D;
quit;

proc print data=compare(obs=5);
   var Avg_Donation Employee_ID Qtr1 Qtr2 Qtr3 Qtr4
       Recipients Paid_By Total_Donation Difference;	
   title 'The compare Data Set';
   title2 '(Partial Output)';
run;

title;


/*Q10-L1*/

proc sql;
   create table age_groups as
      select Customer_ID,  
             Customer_Name, 
             int(yrdif(Birth_Date, '01Jan2008'd, 'ACT/ACT')) as Age, 
             Description
        from orion.customer, 
             orion.ages_mod
        where calculated Age between First_Age and Last_Age
        order by Customer_ID;
quit;

proc print data=age_groups(obs=5);
   title  'age_groups';
   title2 '(Partial Output)';
run;

title;


/*Q11-L2*/

proc sort data=orion.customer(keep=Customer_ID Birth_Date Customer_Name) 
          out=customer;
   by descending Birth_Date;
run;


data age_groups;
   keep Customer_ID Customer_Name Age;
   set customer;
   Age=int(yrdif(Birth_Date, '01Jan2008'd, 'ACT/ACT'));
   do while (not (First_Age le Age lt Last_Age));
     set orion.ages_mod;
   end;
run;

proc print data=age_groups(obs=5);
   title  'age_groups';
   title2 '(Partial Output)';
run;

title;
