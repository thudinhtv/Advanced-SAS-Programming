Libname Orion 'Path';

/*Q1-L1*/
/*a*/
Proc SQL FLOW= 6 35;
title "Dictionary Tables";
     Select DISTINCT Memname, Memlabel
	 From dictionary.Dictionaries;
quit;
title;

/*b*/
Proc SQL;
title "Tables containing Customer_ID";
     Select Memname, type, length
	 From dictionary.Columns
	 Where libname="ORION"
	 and upcase(Name) = "CUSTOMER_ID";
quit;
title;


/*Q2-L2*/
/*a*/
Proc SQL FLOW= 6 35;
title "Dictionary Tables";
     Select Memname, Memlabel,
	        Count(*) as Columns
	 From dictionary.Dictionaries
     Group by Memname, Memlabel;
quit;
title;

/*b*/
Proc SQL FLOW= 6 35;
title "Orion Library Tables";
     Select Memname 'Table',
			nobs 'Rows', 
			nvar 'Columns',
			filesize 'File Size',
			maxvar 'Widest Column',
			maxlabel 'Widest Label'
	 From dictionary.Tables
     Where libname="ORION"
	 and memtype ne 'VIEW'
     Order by Memname;
quit;
title;


/*Q3-L3*/


/*Q4-L1*/
/*a*/
Proc SQL;
title "Highest Salary in Employee_Payroll";
     Select max(Salary)
	 From Orion.Employee_payroll
quit;
title;

/*b*/
%LET DataSet = Employee_payroll;
%LET VariableName = Salary;
%put Note: DataSet = &DataSet, VariableName = &VariableName;

/*c*/
Proc SQL;
title "Highest &VariableName in &DataSet";
     Select max(&VariableName)
	 From Orion.&DataSet
quit;
title;

/*d*/
%LET DataSet = Price_List;
%LET VariableName = Unit_Sales_Price;
Proc SQL;
title "Highest &VariableName in &DataSet";
     Select max(&VariableName)
	 From Orion.&DataSet
quit;
title;


/*Q5-L2*/
/*a*/
Proc SQL;
Title "2007 Purchases by Country";
     Select Country,
	        sum(Total_Retail_Price) format=Dollar10.2 As Purchases
	 From orion.Order_fact as F,
	      orion.Customer as C
	 Where F.Customer_ID = C.Customer_ID
	   And Year(Order_Date)= 2007
	 Group by Country
	 Order by Purchases desc;
quit;
title;

/*b*/
Proc SQL;
Title1 "2007 US Customer Purchases";
Title2 "Total US Purchases: $10,655.97";
     Select Customer_Name,
	        sum(Total_Retail_Price) format=Dollar10.2 As Purchases
	 From orion.Order_fact as F,
	      orion.Customer as C
	 Where F.Customer_ID = C.Customer_ID
	   And Year(Order_Date)= 2007
	   And Country = "US"
	 Group by Customer_Name
	 Order by Purchases desc;
quit;
title;

/*c*/
Proc SQL noprint;
     Select Country,
	        sum(Total_Retail_Price) format=Dollar10.2 As Purchases
	 INTO :Country, :Country_Purchases
	 From orion.Order_fact as F,
	      orion.Customer as C
	 Where F.Customer_ID = C.Customer_ID
	   And Year(Order_Date)= 2007
	 Group by Country
	 Order by Purchases desc;

reset print;
Title1 "2007 &Country Customer Purchases";
Title2 "Total &Country Purchases: &Country_Purchases";
     Select Customer_Name,
	        sum(Total_Retail_Price) format=Dollar10.2 As Purchases
	 From orion.Order_fact as F,
	      orion.Customer as C
	 Where F.Customer_ID = C.Customer_ID
	   And Year(Order_Date)= 2007
	   And Country = "&Country"
	 Group by Customer_Name
	 Order by Purchases desc;
quit;
title;

/*d*/
Proc SQL noprint;
     Select Country,
	        sum(Total_Retail_Price) format=Dollar10.2 As Purchases
	 INTO :Country, :Country_Purchases
	 From orion.Order_fact as F,
	      orion.Customer as C
	 Where F.Customer_ID = C.Customer_ID
	   And Year(Order_Date)= 2007
	 Group by Country
	 Order by Purchases;

reset print;
Title1 "2007 &Country Customer Purchases";
Title2 "Total &Country Purchases: &Country_Purchases";
     Select Customer_Name,
	        sum(Total_Retail_Price) format=Dollar10.2 As Purchases
	 From orion.Order_fact as F,
	      orion.Customer as C
	 Where F.Customer_ID = C.Customer_ID
	   And Year(Order_Date)= 2007
	   And Country = "&Country"
	 Group by Customer_Name
	 Order by Purchases desc;
quit;
title;

/*Q6-L3*/

