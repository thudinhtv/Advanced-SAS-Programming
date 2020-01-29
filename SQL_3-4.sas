Libname Orion 'Path';

/*Chapter 3 exercises*/
/*Q1: s103e01*/

/*Q2 - L2*/
Proc SQL;
title 'Australian Clothing Products';
	 Select Supplier_Name label='Supplier' format=$18.,
			Product_Group label='Group' format=$12., 
			Product_Name label='Product' format=$30.
	 From orion.Product_dim
	 Where Product_Category = "Clothes" 
	 And Supplier_Country = "AU"
	 Order by Product_Name
;
quit;
title;


/*Q3 - L3*/
proc print data=orion.Customer (obs=5);
run;

Proc SQL;
title 'US Customers >50 Years Old as of 31Dec2007';
	 Select Customer_ID format=z9.,
            Catx(', ', Customer_LastName, Customer_FirstName) label='Last Name, First Name' length=20,
			gender 'Gender',
			int(('31Dec2007'd - Birth_Date)/365.25) as Age
	 From orion.Customer
	 Where Country = 'US'
	 and calculated Age > 50
	 Order by calculated Age desc, Customer_LastName, Customer_FirstName
;
quit;
title;


/*Q4-L1*/
Proc SQL;
title 'Cities Where Employees Live';
	 Select City, Count(*) as Count	        
     From orion.Employee_Addresses
	 Group by City
	 Order by City
;
quit;
title;


/*Q5-L1*/
Proc SQL;
title 'Age at Employment';
	 Select Employee_ID label='Employee ID', 
			Birth_Date format=MMDDYY10. label='Birth Date', 
			Employee_Hire_Date format=MMDDYY10. label='Hire Date',
			int((Employee_Hire_Date - Birth_Date)/365.25) as Age
	 From orion.Employee_Payroll
	 Order by Employee_ID
;
quit;
title;


/*Q6-L2*/
Proc SQL;
title 'Customer Demographics: Gender by Country';
	 Select Country label='Customer Country', 
			Count(*) as Customers, 
			sum(Find(gender, "M", "i")>0) as Men,
			sum(Find(gender, "F", "i")>0) as Women,
			calculated Men/ calculated Customers as percent_male label='Percent Male' format=percent8.
	 From orion.Customer
	 Group by Country
	 Order by percent_male, Country
;
quit;
title;


/*Q7-L2*/
Proc SQL;
title 'Countries with more Female than Male Customers';
	 Select Country 'Country', 
			sum(Find(gender, "M", "i")>0) as male_customers label='Male Customers',
			sum(Find(gender, "F", "i")>0) as female_customers label='Female Customers'
	 From orion.Customer
	 Group by Country 
	 Having calculated male_customers < calculated female_customers
	 Order by female_customers desc
;
quit;
title;


/*Q8-L3*/
/*must sort by column number in order to avoid duplicates, b/c by default, the ORDER BY & GROUP BY clauses 
operate in the Country and City values found in the original table, before case correction. 
Using column position numbers causes SQL to group by and sort by the values in the interediate result set (corrected data)*/

Proc SQL;
title 'Countries and Cities Where Employees Live';
	 Select Upcase(Country) 'Country',
			propcase(City) 'City',
			Count(*)as Employees
	 From orion.Employee_Addresses
	 Group by 1,2
	 Order by 1,2
;
quit;
title;


/*----------------------------------------------------------------------------------------------------------------------*/


/*Chapter 4 exercises*/
/*Q1-L1*/
proc print data=orion.Order_Fact (obs=5);
run;

/*a*/
Proc SQL;
     select avg(Quantity)
	 from orion.Order_fact
;
quit;

/*b*/
Proc SQL;
title1 "Employees whose Average Quantity Items Sold";
title2 "Exceeds the Company's Average Items Sold";
     Select Employee_ID, Avg(Quantity) as MeanQuantity format 6.2
	 From orion.Order_fact
	 Group by Employee_ID
	 Having MeanQuantity > (Select avg(Quantity) from orion.Order_fact)
	 Order by Employee_ID
;
quit;
title;


/*Q2-L2*/
/*a*/
Proc SQL;
title "Employee IDs for February Anniversaries";
     Select Employee_ID
	 from orion.Employee_Payroll
	 where month(Employee_Hire_Date)=2
	 order by Employee_ID
;
quit;
title;


/*b*/
proc print data=orion.Employee_Addresses (obs=5);
run;
Proc SQL;
title "Employee with February Anniversaries";
	   Select Employee_ID, 
	          scan(Employee_Name, 2, ',') format=$15. as FirstName 'First Name',
			  scan(Employee_Name, 1, ',') format=$15. as LastName 'Last Name'
       From Orion.Employee_Addresses
	   Where Employee_ID in 
	       (Select Employee_ID
	 		from Orion.Employee_Payroll
	 		where month(Employee_Hire_Date)=2)
	   order by LastName
;
quit;
title;


/*Q3_L3*: Created subquerry using ALL Keyword*/
Proc SQL;
title1 "Level I or II Purchasing Agents";
title2 "Who are older than ALL Purchasing Agent IIIs";
	   Select Employee_ID 'Employee ID', 
	          Job_Title 'Employee Job Title',
			  Birth_Date 'Employee Birth Date',
			  int(('24Nov2007'd - Birth_Date)/365.25) as Age
       From orion.Staff
	   Where Job_Title in ('Purchasing Agent I', 'Purchasing Agent II')
	   and Birth_Date < AlL
	       (select Birth_Date from orion.Staff
		    where Job_Title = 'Purchasing Agent III')
;
quit;
title;



/*Q4-L3: Nested Subquerries*/
/*a*/
Proc SQL;
title "Employee with the Highest Total Sales";
      Select Employee_ID, 
	         sum(Total_retail_price * Quantity) as Total_Sales format=Dollar12.2
	  from Orion.Order_Fact
	  Where Employee_ID ne 99999999
	  Group by Employee_ID
	  Having Total_Sales =
             (select max(Total_sales)
			  from (Select sum(Total_retail_price * Quantity) as Total_Sales
                    from Orion.Order_Fact
	                Where Employee_ID ne 99999999
	                Group by Employee_ID))
	  ;
quit;
title;

/*b*/
Proc SQL;
title "Name of the Employee with the Highest Total Sales";
      Select Employee_ID, Employee_Name
	  from orion.Employee_Addresses
	  where Employee_ID =
      (Select Employee_ID 
	         from Orion.Order_Fact
	  Where Employee_ID ne 99999999
	  Group by Employee_ID
	  Having sum(Total_retail_price * Quantity) =
             (select max(Total_sales)
			  from (Select sum(Total_retail_price * Quantity) as Total_Sales
                    from Orion.Order_Fact
	                Where Employee_ID ne 99999999
	                Group by Employee_ID)))
	  ;
quit;
title;

/*c*/
Proc SQL;
title "Employee with the Highest Sales";
      Select Employee_ID label="Employee Identification Number",
	  Employee_Name label = "Employee Name",
	  Total_Sales format=Dollar12.2 label = "Total Sales"
	  from orion.Employee_Addresses as E,
	       (Select Employee_ID, 
	               sum(Total_retail_price * Quantity) as Total_Sales format=Dollar12.2
	        from Orion.Order_Fact
	        Where Employee_ID ne 99999999
	        Group by Employee_ID
	        Having Total_Sales =
                               (select max(Total_sales)
			  					from (Select sum(Total_retail_price * Quantity) as Total_Sales
                    				  from Orion.Order_Fact
	                				  Where Employee_ID ne 99999999
	                                  Group by Employee_ID)
	  							 )
			) as O
	  WHERE E.Employee_ID = O.Employee_ID
	  ;
quit;
title;


/*Q5-L1*/
Proc SQL;
title "Australian Employees' Birth Months";
      Select Employee_ID,
	         month(Birth_Date) format=2. as Birth_Month label='Birth Month'
	  From orion.Employee_Payroll
	  Where 'AU'=
	       (Select Country
		          From orion.Employee_Addresses
				  Where Employee_Addresses.Employee_ID = Employee_Payroll.Employee_ID)
	  Order by Birth_Month
;
quit;
title;

/*Q6-L2*/
Proc SQL;
title "Employees With Donations > 0.002 Of Their Salary";
      Select Employee_ID, Employee_Gender, Marital_Status
	  From orion.Employee_Payroll
	  Where 0.002*Salary <
	       (Select sum(Qtr1, Qtr2, Qtr3, Qtr4)
		          From orion.Employee_donations
				  Where Employee_Payroll.Employee_ID = Employee_donations.Employee_ID)
;
quit;
title;

