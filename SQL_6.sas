Libname Orion 'Path';

/*Q1-L1 Using the EXCEPT Operator*/
Proc SQL;
title "Employee IDs with Phone Numbers But Not Address Information";
      Select Employee_ID from orion.Employee_phones
	  EXCEPT
	  Select Employee_ID from orion.Employee_Addresses;
quit;
title;


/*Q2-L1 Using the INTERSECT Operator*/
Proc SQL;
title "Customers Who Placed Orders";
      Select Customer_ID from orion.Order_fact
	  INTERSECT
	  Select Customer_ID from orion.Customer;
quit;
title;

/*Q3-L2 Using the EXCEPT Operator to Count Rows*/
Proc SQL;
	Select Count(*) label = "No. Employees w/ No Charitable Donations"
	From (Select Employee_ID from orion.Employee_organization
	      EXCEPT
		  Select Employee_ID from orion.Employee_donations);
quit;

/*Q4-L2 Using the INTERSECT Operator to Count Rows*/
Proc SQL;
	Select Count(*) label = "No. Customers w/ Orders"
	From (Select Customer_ID from orion.Customer
	      INTERSECT
		  Select Customer_ID from orion.Order_fact);
quit;


/*Q5-L3 Using the EXCEPT Operator with a Subquery*/


/*Q6-L3 Using the INTERSECT Operator with a Subquery*/


/*Q7-L1 Using the Union Operator*/
Proc SQL;
Title "Payroll Report for Sales Representatives";
     Select 'Total Paid to All Female Sales Representatives', 
	        sum(Salary) format=Dollar12.,
			count(*) 'Total'
	 From orion.Salesstaff
	 Where Gender='F' and Job_title like '%Rep%'
	 UNION
	 Select 'Total Paid to All Male Sales Representatives',
            sum(Salary) format=Dollar12.,
			count(*) 'Total'
	 From orion.Salesstaff
	 Where Gender='M' and Job_title like '%Rep%';
quit; 
title;


/*Q8-L1 Using the OUTER UNION Operator with the CORR Keyword*/
Proc SQL;
Title "First and Second Quarter 2007 Sales";
     Select * 
	 From orion.Qtr1_2007
	 OUTER UNION CORR
	 Select * 
	 From orion.Qtr2_2007;
quit; 
title;


/*Q9-L2 Comparing UNION and OUTER UNION Operators*/
/*a*/
Proc SQL;
Title "Union Operator Results";
     Select * 
     From orion.Qtr1_2007
     UNION
     Select * 
	 From orion.Qtr2_2007;
quit; 
title;
 
/*b*/
options ls=140;
Proc SQL;
Title "Outer Union Operator Results";
     Select * 
     From orion.Qtr1_2007
     OUTER UNION
     Select * 
	 From orion.Qtr2_2007;
quit; 
title;

/*d*/
Proc SQL;
Title "Union CORR Operator Results";
     Select * 
     From orion.Qtr1_2007
     UNION CORR
     Select * 
	 From orion.Qtr2_2007;
quit; 
title;

Proc SQL;
Title "Outer Union CORR Operator Results";
     Select * 
     From orion.Qtr1_2007
     OUTER UNION CORR
     Select * 
	 From orion.Qtr2_2007;
quit; 
title;



/*Chapter Review*/
proc sql;
   create table One
      (ID num, Var char(3));
   insert into One
      values (1,'Abc')
      values (2,'Def')
      values (3,'Ghi');
   select * from One;

      create table Two
         (ID num, Var char(3));
   insert into Two
      values (1,'Abc')
      values (2,'Zxy')
      values (3,'Ghi');
   select * from Two;
quit;

proc sql;
select * from One
Except
select * from Two;
quit;
