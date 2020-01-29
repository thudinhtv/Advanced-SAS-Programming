Libname Orion 'path';

/*Q1-L1 Creating and Using a View*/
/*a*/
Proc SQL;
     Create view orion.Phone_List As
	        Select Department format=$25.,
			       Employee_Name label='Name' format=$25.,
				   Phone_Number label='Home Phone' format=$16.
            From orion.Employee_Addresses as A,
			     orion.Employee_Organization as O,
				 orion.Employee_Phones as P
			Where A.Employee_ID = O.Employee_ID
			And O.Employee_ID = P.Employee_ID
			And Phone_Type='Home';
quit;

/*b*/
Proc SQL;
title "Engineering Department Home Phone Numbers";
     Select Employee_Name, Phone_Number
	 From orion.Phone_List
	 Where Department = "Engineering"
	 Order by Employee_Name;
quit; 
title;

/*Q2-L2 Creating and Using a View to Provide Consolidated Information*/
/*a*/

Proc SQL;
     Create view orion.T_Shirts As
	        Select Pd.Product_ID,
			       Supplier_Name format=$20.,
				   Product_Name,
				   Unit_Sales_Price As Price label='Retail Price' 
            From orion.Product_Dim as Pd,
			     orion.Price_list as Pl
			Where Pd.Product_ID = Pl.Product_ID
			And Product_Name like '%T-Shirt%';
quit;

/*b*/
Proc SQL;
title "Available T-Shirts";
     Select *
	 From orion.T_Shirts
	 Order by Supplier_Name, Product_ID;
quit; 
title;

/*c*/
Proc SQL;
title "T-Shirts under $20";
     Select Product_ID, Product_Name,
	        Price format=Dollar6.2
	 From orion.T_Shirts
	 Where Price < 20
	 Order by Price;
quit; 
title;



/*Q3-L3*/


/*Q4-L1 Creating a Table and Adding Data Using a Query*/
/*a*/
proc print data=orion.employee_payroll (obs=5);
run;
Proc SQL;
Create table Orion.Employees AS
      Select A.Employee_ID,
	         Employee_Hire_Date as Hire_Date format=MMDDYY10.,
			 Salary format=COMMA10.2,
			 Birth_Date format=MMDDYY10.,
			 Employee_Gender 'Gender',
			 Country, City
	  From orion.Employee_Addresses as A,
	       orion.Employee_Payroll as P
	  Where A.Employee_ID = P.Employee_ID
	  And Employee_Term_Date is missing
Order by Year(Employee_Hire_Date), Salary desc;
quit;

/*b*/
Proc SQL;
    Select *
    From orion.Employees;
quit; 


/*Q5-L2 Creating a Table by Defining its Structure and Adding Data*/
Proc SQL;
Create table Orion.Rewards
      (Purchased Num format=comma9.2,
       	Year Num format=4.,
		Level Char(9),
		Award Char(50));
quit;

Proc SQL;
Insert into Orion.Rewards
      (Purchased, Year, Level, Award)
	  Values (200, 2006, 'Silver', '25% Discount on one item over $25')
	  Values (300, 2006, 'Gold', '15% Discount on one order over $50')
	  Values (500, 2006, 'Platinum', '10% Discount on all 2007 purchases')
	  Values (225, 2007, 'Silver', '25% Discount on one item over $50')
	  Values (350, 2007, 'Gold', '15% Discount on one order over $100')
	  Values (600, 2007, 'Platinum', '10% Discount on all 2008 purchases');
quit;

Proc SQL;
	select * from Orion.Rewards;
quit;

/*Q6-L3*/
