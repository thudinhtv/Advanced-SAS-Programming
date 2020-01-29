libname Orion 'path';

/* Chap 9 - Q2 */
/*a&b*/
data profit07(sortedby=Company);
   infile 'C:\DATA\MSBAN 2018\Sem2_Spring2019\MKTG5253\Data and Programs\Advanced Techniques\Advanced Data\profit07.dat' dlm=',';  
   input Company : $30. Sales Cost Salaries Profit;
run;


/*c */
proc contents data=profit07;
run;

/*d */
proc print data=profit07(obs=24);
   by Company;
run;


/* e */
proc sort data=profit07 presorted;
   by Company;
run;

proc contents data=profit07;
run;


/* Chap 9 - Q5 */
/* b */
options ls=80;

proc sort data=orion.purchased_products out=purchased_products;
   by descending Order_Type;
run;

proc tabulate data=purchased_products format=comma12.2 ;
   where Supplier_Name contains 'Sports';
   by descending Order_Type; 
   class Customer_Age_Group Supplier_Name;
   var Quantity Total_Retail_Price;
   table Supplier_Name,  
         Customer_Age_Group * Total_Retail_Price=' ' * sum=' '
                  / printmiss misstext='$0' box='Total Retail Price';
   title 'Products by Sales Supplier and Customer Age Groups';
run;

/* c */

proc tabulate data=orion.purchased_products format=comma12.2 ;
   where Supplier_Name contains 'Sports';
   class Supplier_Name Customer_Age_Group; 
   class Order_Type/descending; 
   var Quantity Total_Retail_Price;
   table Order_Type,
         Supplier_Name,  
         Customer_Age_Group * Total_Retail_Price=' ' * sum=' '
                         / printmiss misstext='$0' box='Total Retail Price';
   title 'Products by Sales Supplier and Customer Age Groups';
run;
title;


/* Chap 10 - Q2 */
data all_levels;
   drop i;
   length Customer_Name $ 40 Customer_Age_Group $ 12 
          Customer_Type $ 40 Customer_Group $ 40;
   do i=1 to 3;
      NextFile=cats('C:\DATA\MSBAN 2018\Sem2_Spring2019\MKTG5253\Data and Programs\Advanced Techniques\Advanced Data\level_', i, '.dat');  
      infile levels filevar=NextFile dlm=',' 
                       end=Last;
      do while (Last=0);

         input Customer_Name $ Customer_Age_Group $ 
               Customer_Type $  
               Customer_Group $;
         output;
      end;
   end;
   stop;
run;

proc print data=all_levels;
title "Customer_";
run;
title;


/*Chap 10 - Q5*/
/*  Part a, b, c */
data older60 younger60 / view=younger60;
   set orion.employee_payroll;
   Age=int(yrdif(Birth_Date, today(), 'act/act'));
   if Age >= 60 then output older60;
   else output younger60;
   format Birth_Date Employee_Hire_Date Employee_Term_Date date9.;
run;

/*  Part d */
proc print data=older60;
   title 'Older60 Data Set';
run;

/*  Part e */
proc print data=younger60;
   title 'Younger60 Data Set';
run;

/*  Part f */
proc print data=older60;
   title 'Older60 Data Set';
run;


/*8*/
proc sort data=orion.employee_addresses out=employee_addresses;
   by Employee_ID;
run;


data _null_;
   merge orion.employee_donations(in=D) employee_addresses;
   by Employee_ID;
   if D;   
   Total_Donation=sum(of Qtr1 - Qtr4);

   email=compress(scan(Employee_Name,2,',')||'.'||scan(Employee_Name,1,',')||'@orion.com');
   file 'C:\DATA\MSBAN 2018\Sem2_Spring2019\MKTG5253\Data and Programs\Advanced Techniques\Advanced Data\donations.sas';  
   put "filename mail email '" email "' subject='Your Donation';";
   put 'data _null_;';
   put 'file mail;';
   put "put 'Your donation of " Total_Donation dollar3. " has been sent to " 
        Recipients "';";
   put 'run;';
run;


/*Chap 10 - Q11*/
/*a, b*/
proc fcmp outlib=work.functions.Marketing;
  function AGE(BirthDate, ActualDate);
  return(intck('year', BirthDate, ActualDate)
       -(put(BirthDate, mmddyy4.) gt put(ActualDate, mmddyy4.))
       +(put(BirthDate, mmddyy4.)||put(ActualDate, mmddyy4.)||
       put(ActualDate + 1, mmddyy4.)='022902280301')
        );
endsub;
run;
quit;


/*c, d */
options cmplib=work.functions;

data real_ages;
   do Birth_Date='28feb1960'd to '01mar1960'd;
      do Actual_Date='28feb2004'd to '01mar2004'd, 
                       '28feb2005'd to '01mar2005'd;

          Real_Age=AGE(Birth_Date, Actual_Date);
          Age=intck('year', Birth_Date, Actual_Date);
         output;
      end;
   end;
   format Birth_Date Actual_Date worddate.;
run;


proc print data=real_ages;
   var Birth_Date Actual_Date Real_Age Age;
   title1 'Age Calculations based using INTCK';
run;


/* e */
data customer_ages;
   set orion.customer_dim(keep=Customer_ID Customer_Name
                               Customer_Group Customer_BirthDate);
   Real_Age=AGE(Customer_BirthDate, '01jan2008'd);
   Age=intck('year', Customer_BirthDate, '01jan2008'd);
   format Customer_BirthDate worddate.;
run;

proc print data=customer_ages(obs=5);
   title1 'Age Calculations based using INTCK';
run;

