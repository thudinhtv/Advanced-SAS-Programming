Libname Orion 'Path';

/*Q1-L1 Inner join*/
Proc SQL;
title1 "Employees With More Than 30 Years of Service";
title2 "As of December 31, 2007";
	Select Employee_Name 'Name',
	       int(('31Dec2007'd - Employee_Hire_Date)/365.25) as YOS label = "Years of Service"
	from Orion.Employee_Addresses as A, Orion.Employee_Payroll as P
	Where A.Employee_ID = P.Employee_ID
	And calculated YOS > 30
	Order by Employee_Name;
quit;
title;


/*Q2-L1 Outer join*/
Proc SQL;
	Select Employee_Name 'Name',
	       City, Job_Title
	from Orion.Employee_Addresses as A
    LEFT JOIN Orion.Sales as S
	ON A.Employee_ID = S.Employee_ID
	Order by City, Job_Title, Employee_Name;
quit;


/*Q3-L2 joining Multiple Table*/
Proc SQL;
title1 "US and Australian Internet Customers";
title2 "Purchasing Foreign Manufactured Products";
	Select Customer_Name 'Name',
	       Count(*) As Purchases
	from Orion.Customer as C, 
         Orion.Order_Fact as O,
		 Orion.Product_Dim as P
	Where C.Customer_ID = O.Customer_ID
	And O.Product_ID = P.Product_ID
	And Employee_ID = 99999999
	And Country in ('US', 'AU')
	And Supplier_Country ne Country
	Group by Customer_Name
	Order by Purchases desc, Customer_Name;
quit;
title;


/*Q4-L3 Joining Multiple Table*/
Proc SQL; 
title1 "Employees with more than 30 years of service";
title2 "as of December 31, 2007";
Select emp.Employee_Name "Employee Name",
	   int(('31Dec2007'd - Employee_Hire_Date)/365.25) as YOS label = "Years of Service",
       mgr.Employee_Name as Manager_Name label="Manager Name"
From orion.Employee_Addresses as emp, 
	 orion.Employee_Addresses as mgr,
     orion.Employee_Payroll as pay,
	 orion.Employee_Organization as org
Where emp.Employee_ID = pay.Employee_ID
and emp.Employee_ID = org.Employee_ID
and mgr.Employee_ID = org.Manager_ID
and calculated YOS > 30
order by Manager_Name, YOS desc, Employee_Name;
quit;
title;



/*Q5-L1 Using In-line views*/
/*a*/
Proc SQL;
title1 "2007 Sales Force Sales Statistics";
title2 "For Employees With 200.00 or More In Sales";
Select Country, First_Name, Last_Name,
       sum(Total_Retail_Price) as Value_Sold format=comma10.2,
       Count(*) As Orders,
	   calculated Value_Sold/ calculated Orders As Avg_Order format=comma8.2
	from Orion.Order_Fact as O,
		 Orion.Sales as S
	Where O.Employee_ID = S.Employee_ID
	And Year(Order_Date)=2007
	Group by Country, First_Name, Last_Name
	Having Value_Sold ge 200
	Order by Country, Value_Sold desc, Orders desc;
quit;
title;

/*b*/
Proc SQL;
title1 "2007 Sales Summary by Country";
      Select Country, 
	         Max(Value_Sold) label='Max Value Sold' format=comma10.2,
			 Max(Orders) label='Max Orders' format=comma8.2,
             Max(Avg_Order) label='Max Average' format=comma8.2,
			 Min(Avg_Order) label='Min Average' format=comma8.2
	  From
	      (Select Country, First_Name, Last_Name,
                  sum(Total_Retail_Price) as Value_Sold,
                  Count(*) As Orders,
	              calculated Value_Sold/ calculated Orders As Avg_Order
	       from Orion.Order_Fact as O,
		        Orion.Sales as S
	       Where O.Employee_ID = S.Employee_ID
	       And Year(Order_Date)=2007
	       Group by Country, First_Name, Last_Name
	       Having Value_Sold ge 200)
	 Group by Country
	 Order by Country;
quit;
title;


/*Q6-L2 Building Complex Queries with In-Line Views*/
/*a*/
Proc SQL;
     Select Department, sum(Salary) As Dept_Salary_Total
	 From orion.Employee_Payroll as P,
	      orion.Employee_Organization as O
	 Where P.Employee_ID = O.Employee_ID
	 Group by Department;
quit;

/*b*/
Proc SQL;
     Select A.Employee_ID, Employee_Name, Department
	 From orion.Employee_Addresses as A,
	      orion.Employee_Organization as O
	 Where A.Employee_ID = O.Employee_ID;
quit;

/*c*/
Proc SQL;
title "Employee Salaries as a percent of Department Total";
      Select PO.Department, AO.Employee_Name, Salary format =comma9.2,
	         Salary/ Dept_Salary_Total as Percent format=Percent6.2
	  From orion.Employee_Payroll as P,
		   (Select Department, sum(Salary) As Dept_Salary_Total
	        From orion.Employee_Payroll as P,
	             orion.Employee_Organization as O
            Where P.Employee_ID = O.Employee_ID
	        Group by Department) as PO,
	       (Select A.Employee_ID, Employee_Name, O.Department
	        From orion.Employee_Addresses as A,
	             orion.Employee_Organization as O
	        Where A.Employee_ID = O.Employee_ID) as AO
 	  Where P.Employee_ID = AO.Employee_ID
	  and AO.Department = PO.Department
	  Order by Department, Percent desc;
quit;
title;


/*Q7-L3*/
Proc SQL;
title "2007 Total Sales Figure";

