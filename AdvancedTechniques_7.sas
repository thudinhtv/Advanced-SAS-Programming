libname Orion 'path';

/*Chap 7*/
/*Q1-L1*/
/*a*/
data continent;
   keep Start Label FmtName;
   retain FmtName 'continent';
   set orion.continent(rename=(Continent_ID=Start
                                 Continent_Name=Label));
run;

proc print data=continent(obs=10) noobs;
   title 'Continent';
run;

/*b*/
proc format library=orion.MyFmts cntlin=continent fmtlib;
   select continent;
   title 'Continent format';
quit;

/*c*/
options fmtsearch=(orion.MyFmts);

data countries;
   set orion.country;
   Continent_Name=put(Continent_ID, continent.);
run;

proc print data=countries(obs=10);
   title 'Continent Names';
run;
title;


/*d*/

proc format library=orion.Myfmts cntlout=continentfmt;
   select continent;
run;

proc sql;
    insert into continentfmt(FmtName, Start, End, Label)
	   values('Continent', '90', '90', 'Antarctica')
	   values('Continent', '92', '92', 'South America');
quit;

proc format library=orion.Myfmts cntlin=continentfmt fmtlib;
   select Continent;
run;
title;


/*Q2-L2*/
/*a*/
data ages;
   set orion.ages(rename=(First_Age=Start 
                            Last_Age=End Description=Label));
   retain FmtName 'ages';
run;

proc format library=orion.MyFmts fmtlib cntlin=ages;
   select ages;
run;

/*b & c */
options fmtsearch=(orion.MyFmts);

data sales;
   set orion.sales(keep=Employee_ID Birth_Date);
   Age=int(yrdif(Birth_Date, today(), 'ACT/ACT'));
   Age_Cat=put(Age, ages.);
run;

proc print data=sales(obs=5);
  format Birth_Date date9.;
  title 'Sales Data Set';
run;
title;


/*Q3-L3*/


data ages_mod;
   set orion.ages_mod(rename=(First_Age=Start Last_Age=End
                                Description=Label));
   retain fmtname 'ages_mod';
   EEXCL='Y'; 
run;

proc format library=orion.MyFmts fmtlib cntlin=ages_mod;
   select ages_mod;
run;

options fmtsearch=(orion.MyFmts);

data sales;
   set orion.sales(keep=Employee_ID Birth_Date);
   Age=int(yrdif(Birth_Date, today(), 'ACT/ACT'));
   Age_Cat=put(Age,ages_mod.);
run;

proc print data=sales(obs=5);
  format birth_date date9.;
  Title 'Sales Data Set';
run;

title;


/*Q4-L1*/

proc format;
   picture product low-high='99-99-99-9999';
run;

proc print data=orion.order_fact(obs=5);
   format Order_ID product.;
   var Order_ID;
   title "Formatted Values of Order_ID";
run;
title;


/*Q5-L2*/

Proc format;
   picture RevPrice_fmt 0-high='000.009,99 eks.moms' (mult=100 prefix='kr. ');
run;

Proc print data=orion.denmark_customers(obs=5);
   format Total_Retail_Price RevPrice_fmt.; 
   title 'Using a PICTURE Format';
   var Total_Retail_Price;
run;
title;


/*Q6-L3*/


proc format;
   picture day_of_week(default=21) low-high='%A, %m.%d.%Y' 
                                                  (datatype=date);
run;

proc print data=orion.order_fact(obs=5);
   title 'Day of Week Format';
   format Order_Date day_of_week.;
   var Order_Date;
run;

title;


/*********************/
/*  p307s07          */
/*********************/


/* Using PROC SUMMARY and the DATA STEP */

proc summary data=orion.customer_dim;
   var Customer_Age;
   output out=average mean=AvgAge;
run;

data Age_Dif;
   if _n_=1 then set average(keep=AvgAge);
   set orion.customer_dim(keep=Customer_ID Customer_Age);
   Age_Difference=Customer_Age-AvgAge;
run;

/* Using PROC SUMMARY and PROC SQL */

proc summary data=orion.customer_Dim;
   var Customer_Age;
   output out=average mean=AvgAge;
run;

proc sql;
   create table age_dif as
   select AvgAge, Customer_ID, Customer_Age, 
          Customer_Age-AvgAge as Age_Difference
   from orion.customer_dim, average;
quit;
  
/* Using PROC SQL only */

proc sql;
   create table age_dif as
   select mean(Customer_Age) as AvgAge, Customer_ID,
			Customer_Age,
          Customer_Age-calculated AvgAge as Age_Difference
   from orion.customer_dim;
quit;

/* Using the DATA step only */

data age_dif;
   drop i Tot_Age;
   if _n_=1 then do i=1 to TotObs;
      set orion.customer_Dim(keep=Customer_Age) nobs=TotObs;
      Tot_Age+Customer_Age;
   end;
   set orion.customer_Dim(keep=Customer_ID Customer_Age);
   AvgAge=Tot_Age/TotObs;
   Age_Difference=Customer_Age-AvgAge;
run;



/*********************/
/*  p307s08          */
/*********************/


/* Using PROC SUMMARY and the DATA STEP */

data donations;
   set orion.employee_donations;
   Total_Donation=sum(of Qtr1-Qtr4);
run;

proc summary data=donations;
   var Total_Donation;
   output out=totals mean=Avg_Donation;
run;

data compare;
   if _n_=1 then set totals;
   set donations;
   Difference=Total_Donation-Avg_Donation;
run;

/* Using PROC SUMMARY and PROC SQL*/
proc sql;
   create table donations as
   select Employee_ID,
          Qtr1,
          Qtr2,
          Qtr3,
          Qtr4,
		  Recipients,
          Paid_By,
          sum(Qtr1, Qtr2, Qtr3, Qtr4) as Total_Donation
   from orion.employee_donations;


proc summary data=donations;
   var Total_Donation;
   output out=totals mean=Avg_Donation;
run;

proc sql;
   create table compare as
      select Avg_Donation, donations.*, 
         Total_Donation-Avg_Donation as Difference
         from totals, donations;
quit;

/* Using PROC SQL only */

proc sql;
   create table compare as
   select mean(sum(Qtr1, Qtr2, Qtr3, Qtr4)) as Avg_Donation,
          Employee_Donations.*, sum(Qtr1, Qtr2, Qtr3, Qtr4) as
          Total_Donation,
          calculated Total_Donation-calculated Avg_Donation 
          as Difference
   from orion.employee_donations;
quit;

/* Using the DATA step only */

data compare;
   drop i;
   if _n_=1 then do i=1 to TotObs;
      set orion.employee_donations(keep=Qtr1-Qtr4) nobs=TotObs;
      Total+sum(of Qtr1-Qtr4);
   end;
   set orion.employee_donations;
   Total_Donation=sum(of Qtr1-Qtr4);
   Avg_Donation=Total/totObs;
   Difference=Total_Donation-Avg_Donation;
run;

proc print data=compare(obs=5);
   var Avg_Donation Employee_ID Qtr1 Qtr2 Qtr3 Qtr4
		Recipients Paid_By Total_Donation Difference;	
   title 'The compare Data Set';
   title2 '(Partial Output)';
run;


/*********************/
/*  p307s09          */
/*********************/


/* Using PROC SUMMARY and the DATA STEP */

proc summary data=orion.order_fact;
   var CostPrice_Per_Unit;
   weight Quantity;
   output out=totals sum=Total_Cost;
run;

proc sort data=orion.order_fact out=order_fact;
   by Product_ID;
run;

data products(keep=Customer_ID CostPrice_Per_Unit Quantity 
				Percent Product_Name);
   if _n_=1 then set totals(keep=Total_Cost);
   merge order_fact(keep=Customer_ID Product_ID 
						CostPrice_Per_Unit Quantity in=O)
         orion.product_dim(keep=Product_ID Product_Name in=P);
   by Product_ID;
   if O and P;
   Percent=(CostPrice_Per_Unit*Quantity)/Total_Cost;
   format Percent percent9.3;
run;



/* Using PROC SUMMARY and PROC SQL*/

proc summary data=orion.order_fact;
   var CostPrice_Per_Unit;
   weight Quantity;
   output out=totals sum=Total_Cost;
run;

proc sql;
   create table products as
   select Customer_ID, CostPrice_Per_Unit, Quantity, Product_Name, 
          (Quantity*CostPrice_Per_Unit)/Total_Cost as Percent format=percent9.3 
   from totals, orion.order_fact, orion.product_dim
   where order_fact.Product_ID=product_dim.Product_ID;
quit;


/* Using PROC SQL only */

proc sql;
   create table products as
   select Customer_ID, CostPrice_Per_Unit, Quantity, Product_Name, 
          (Quantity*CostPrice_Per_Unit)/sum(Quantity*CostPrice_Per_Unit)
          as Percent format=percent9.3 
   from  orion.order_fact, orion.product_dim
   where order_fact.Product_ID=product_dim.Product_ID;
quit;



/* Using the DATA step only */

proc sort data=orion.order_fact out=order_fact;
   by Product_ID;
run;

data products(keep=Customer_ID CostPrice_Per_Unit Quantity Percent Product_Name);
   if _n_=1 then do i=1 to TotObs;
      set orion.order_fact nobs=TotObs;
	  Total_Cost+(Quantity*CostPrice_Per_Unit);
   end;
   merge order_fact(keep=Customer_ID Product_ID CostPrice_Per_Unit Quantity in=O)
         orion.product_dim(keep=Product_ID Product_Name in=P);
   by Product_ID;
   if O and P;
   Percent=(CostPrice_Per_Unit*Quantity)/Total_Cost;
   format Percent percent9.3;
run;


proc print data=products(obs=5);
   var Customer_ID Quantity CostPrice_Per_Unit Product_Name
   		Percent;
   title 'The products Data Set';
   title2 '(Partial Output)';
run;




/*********************/
/*  p307s10          */
/*********************/


/* Using PROC SQL */

proc sql;
   create table age_groups as
      select Customer_ID,  
             Customer_Name, 
             int(yrdif(Birth_Date,'01Jan2008'd, 'ACT/ACT')) as Age, 
             Description
        from orion.customer, orion.ages_mod
           where calculated Age between First_Age and Last_Age;
quit;

proc print data=age_groups(obs=5);
   title  'age_groups';
   title2 '(Partial Output)';
run;



/*********************/
/*  p307s11          */
/*********************/


/* Using the DATA Step */

proc sort data=orion.customer(keep=Customer_ID Birth_Date Customer_Name) 
          out=customer;
   by descending Birth_Date;
run;


data age_groups;
   keep Customer_ID Customer_Name Age Description;
   set customer;
   Age=int(yrdif(Birth_Date,'01Jan2008'd, 'ACT/ACT'));
   do while (not (First_Age le Age lt
                           Last_Age));
     set orion.ages_mod;
   end;
run;

proc print data=age_groups(obs=5);
   title  'age_groups';
   title2 '(Partial Output)';
run;



/*********************/
/*  p307s12          */
/*********************/


/* Using the DATA Step Hash Object */

data age_groups;
   keep Customer_ID Customer_Name Age Description;
   if _n_=1 then do;
      if 0 then set orion.ages_mod;
      declare hash AG(dataset: 'orion.ages_mod', ordered: 'ascending');
      AG.defineKey('First_Age');
      AG.defineData('First_Age','Last_Age','Description');
      AG.defineDone();
      declare hiter A('AG');
   end;
   set orion.customer(keep=Customer_ID Birth_Date Customer_Name); 
   Age=int(yrdif(Birth_Date,'01Jan2008'd, 'ACT/ACT'));
   A.first();
   do until (rc ne 0);
      if First_Age <= Age < Last_Age then do;
         output;
         leave;
      end;
      else if First_Age > Age then leave;
      rc=A.next();
   end;
run;

proc print data=age_groups(obs=5);
   title  'age_groups';
   title2 '(Partial Output)';
run;


/* alternative solution */


data age_groups(keep=Description Customer_ID Customer_Name
				Age);
   if _n_=1 then do;
      if 0 then set orion.ages_mod;
      declare hash ag (dataset:'orion.ages_mod',
			ordered: 'ascending');
      ag.definekey('First_Age');
      ag.definedata('Description');
      ag.definedata('First_Age' ,'Last_Age');
      ag.definedone();
      declare hiter hag ('ag');
   end;
   set orion.customer(keep=Customer_ID Customer_Name
	   birth_date);
   Age=int(yrdif(Birth_date,'01jan2008'd,'act/act'));
   rc=hag.first();
   do until (First_Age le Age le Last_Age);
      rc=hag.next();
   end;
run;
		
proc print data=age_groups(obs=5);
   title  'age_groups';
   title2 '(Partial Output)';
run;












proc print data=age_dif(obs=5);
   var AvgAge Customer_ID Customer_Age Age_Difference;	
   title 'The age_dif Data Set';
   title2 '(Partial Output)';
run;
