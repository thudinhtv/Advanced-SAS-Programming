Libname orion 'path';

/*Chap 3*/
/*Q1-L1*/
/*a: m103e01*/
proc print data=orion.customer_dim;
   var Customer_Group Customer_Name Customer_Gender Customer_Age;
   where Customer_Group contains "&type";
   title "&type Customers";
run;

/*b*/
OPTIONS MCOMPILENOTE=ALL;
%macro Customers;
proc print data=orion.customer_dim;
   var Customer_Group Customer_Name Customer_Gender Customer_Age;
   where Customer_Group contains "&type";
   title "&type Customers";
run;
%mend Customers;

/*c*/
%Let Type=Gold;
%Customers

/*d*/
%Let Type=Internet;

/*e*/
OPTIONS MPRINT;
%Customers


/*Q2-L2*/
/*a: m103e02*/
%macro tut;
   king tut
%mend tut;


/*Q3-L3*/
/*a*/
%macro CURRTIME;
     %Sysfunc(time(), TIMEAMPM.)
%mend CURRTIME;

/*b: m103e03*/
proc print data=orion.customer_dim(obs=10);
   var Customer_Name Customer_Group;
	title 'Customer List';
	title2 "%CURRTIME";
run;
title;


/*Q4-L1*/
/*a: m103e04*/
%macro customers;
   proc print data=orion.customer_dim;
      var Customer_Name Customer_Gender Customer_Age;
      where Customer_Group contains "&type";
      title "&type Customers";
   run;
%mend customers;

/*b*/
OPTIONS MCOMPILENOTE=ALL;
%macro customers (type);
   proc print data=orion.customer_dim;
      var Customer_Name Customer_Gender Customer_Age;
      where Customer_Group contains "&type";
      title "&type Customers";
   run;
%mend customers;

/*c*/
OPTIONS MPRINT;
%customers(Gold)

/*d*/
%customers(Catalog)

/*e*/
OPTIONS MCOMPILENOTE=ALL;
%macro customers (type=Club);
   proc print data=orion.customer_dim;
      var Customer_Name Customer_Gender Customer_Age;
      where Customer_Group contains "&type";
      title "&type Customers";
   run;
%mend customers;

/*f*/
%customers(type=Internet)

/*g*/
%customers()


/*Q5-L2*/
/*a: m103e05*/
options nolabel;
title 'Order Stats';
proc means data=orion.order_fact maxdec=2 mean;
   var total_retail_price;
   class order_type;
run;
title;

/*b*/
OPTIONS MCOMPILENOTE=ALL;
%macro Orders (Var=total_retail_price, Class=order_type, stats=mean range, dec=2);
   	options nolabel;
	title 'Order Stats';
	proc means data=orion.order_fact maxdec=&dec &stats;
   		var &Var;
   		class &Class;
	run;
	title;
%mend Orders;

/*c*/
%Orders()

/*d*/
%Orders(Var=costprice_per_unit, Class=quantity, stats=min max, dec=0)

/*e*/
%Orders(stats=nmiss min max, dec=1)


/*Q6-L3*/
/*a: m103e06*/
%macro specialchars(name);
   proc print data=orion.employee_addresses;
      where Employee_Name="&name";
      var Employee_ID Street_Number Street_Name City State Postal_Code;
      title "Data for &name";
   run;
%mend specialchars;

/*b*/
%specialchars(%str(Abbott, Ray))


/*Q7-L1*/
/*a*/
proc options group=macro;
run;

/*b*/
%put %sysfunc(pathname(sasautos));


/*Q8-L2*/
/*a*/
Options mautosource sasautos=('C:\DATA\MSBAN 2018\Sem2_Spring2019\MKTG5253\Data and Programs\Macro\Macro1 Programs for D2L', sasautos);

/*b: m103e08 - Save the macro as autocall macro. DO NOT RUN*/

title; 
footnote; 

%macro autocust;
   proc print data=orion.customer_dim;
      var Customer_Name Customer_Gender Customer_Age;
      title "Customers Listing as of &systime";      
   run;
%mend autocust;


/*c*/
options mautosource;
%autocust


/*Q9-L3*/
/*a-b*/
OPTIONS MAUTOLOCDISPLAY;

/*c*/
Options mautosource sasautos=('C:\Program Files\SASHome\SASFoundation\9.4\core\sasmacro', sasautos);

/*d*/
options mautosource;
%calc

/*e*/
%put %lowcase(FIRE);



/*-------------------------------------------------------------------------------------------------------------------*/

/*Chap4*/
/*Q1-L1*/
/*a: m104e01*/
%macro emporders(idnum=121044);
   proc print data=orion.orders noobs;
      var Order_ID Order_Type Order_Date Delivery_Date;
      where Employee_ID=&idnum;
      title "Orders Taken by Employee &idnum";
   run;
%mend emporders;
%emporders()

/*b*/
%macro emporders(idnum=121044);

	data _null_;
		set orion.employee_addresses;
	where Employee_ID=&idnum;
	CALL SYMPUTX('Name', Employee_Name);
	run;

   proc print data=orion.orders noobs;
      var Order_ID Order_Type Order_Date Delivery_Date;
      where Employee_ID=&idnum;
      title "Orders Taken by Employee &idnum";
   run;
%mend emporders;
%emporders()

/*c*/
%macro emporders(idnum=121044);

	data _null_;
		set orion.employee_addresses;
	where Employee_ID=&idnum;
	CALL SYMPUTX('Name', Employee_Name);
	run;

   proc print data=orion.orders noobs;
      var Order_ID Order_Type Order_Date Delivery_Date;
      where Employee_ID=&idnum;
      title "Orders Taken by Employee &Name";
   run;
%mend emporders;
%emporders()

/*d*/
%emporders(idnum=121066)


/*Q2-L2*/
/*a: m104e02 part a*/

proc means data=orion.order_fact sum nway noprint; 
   var Total_Retail_Price;
   class Customer_ID;
   output out=customer_sum sum=CustTotalPurchase;
run;

proc sort data=customer_sum ;
   by descending CustTotalPurchase;
run;

proc print data=customer_sum(drop=_type_);
run;
 

/*b: m104e02 part b*/
data _null_;
     Set customer_sum (obs=1);
Call Symputx('Top', Customer_ID);
run;

proc print data=orion.orders noobs;
   Where Customer_ID=&Top;
   var Order_ID Order_Type Order_Date Delivery_Date;
   Title "Orders for Customer &Top - Orion's Top Customer";
run;
Title;

/*c*/
data _null_;
     Set customer_sum (obs=1);
Call Symputx('Top', Customer_ID);
run;

data _null_;
     Set orion.customer_dim;
	 where Customer_ID=&top;
Call Symputx('Top_Name', Customer_Name);
run;

proc print data=orion.orders noobs;
   Where Customer_ID=&Top;
   var Order_ID Order_Type Order_Date Delivery_Date;
   Title "Orders for Customer &Top_Name - Orion's Top Customer";
run;
Title;


/*Q3-L3*/
/*a: m104e03*/
title; 
footnote; 

proc means data=orion.order_fact nway noprint; 
   var Total_Retail_Price;
   class Customer_ID;
   output out=customer_sum sum=CustTotalPurchase;
run;

proc sort data=customer_sum ;
   by descending CustTotalPurchase;
run;

proc print data=customer_sum(drop=_type_);
run;

/*b*/
data _null_;
     Set customer_sum (obs=3)end=last;
	 length Top3 $50;
	 retain Top3;
	 Top3=catx(' ', Top3, Customer_ID);
	 if last then Call Symputx('Top3', Top3);
run;

/*c*/
proc print data=orion.customer_dim noobs;
   Where Customer_ID in (&Top3);
   var Customer_ID Customer_Name Customer_Type;
   Title "Top 3 Customers";
run;
Title;


/*Q4-L1*/
/*a: m104e04*/
%macro memberlist(id=1020);
   %put _user_;
   title "A List of &id";
   proc print data=orion.customer;
      var Customer_Name Customer_ID Gender;
      where Customer_Type_ID=&id;
   run;
%mend memberlist;

%memberlist()

/*b*/
%macro memberlist(id=1020);
data _null_;
    set orion.customer_type;
	Call Symputx('Type'||left(Customer_Type_ID), Customer_Type);
run;

%put _user_;
title "A List of &id";
   proc print data=orion.customer;
      var Customer_Name Customer_ID Gender;
      where Customer_Type_ID=&id;
   run;
%mend memberlist;

%memberlist()

/*c*/
%macro memberlist(id=1020);
data _null_;
    set orion.customer_type;
	Call Symputx('Type'||left(Customer_Type_ID), Customer_Type);
run;

%put _user_;
title "A List of &&Type&id";
   proc print data=orion.customer;
      var Customer_Name Customer_ID Gender;
      where Customer_Type_ID=&id;
   run;
%mend memberlist;

%memberlist()

/*d*/
%memberlist(id=2030)


/*Q5-L2*/
/*a: m104e05*/
data _null_;
   set orion.customer_type;
   call symputx('type'||left(Customer_Type_ID), Customer_Type);
run;

%put _user_;

%macro memberlist(custtype);
   proc print data=orion.customer_dim;
      var Customer_Name Customer_ID Customer_Age_Group;
      where Customer_Type="&custtype";
      title "A List of &custtype";
   run;
%mend memberlist;

/*b*/
%let Num=2010;
%memberlist(&&type&num)


/*Q6-L3*/
/*a*/
data _null_;
    Set orion.country;
Call Symputx(Country, Country_Name);
run;

%put _user_;

/*b: m104e06*/
%let code=AU;
proc print data=Orion.Employee_Addresses;
   var Employee_Name City;
   where Country="&code";
   title "A List of xxxxx Employees";
run;

/*c*/
%let code=AU;
proc print data=Orion.Employee_Addresses;
   var Employee_Name City;
   where Country="&code";
   title "A List of &&&code Employees";
run;
title;


/*Q7-L1*/
/*a: m104e07*/
data _null_;
   set orion.customer_type;
   call symputx('type'||left(Customer_Type_ID), Customer_Type);
run;

%put _user_;

/*b*/
data _null_;
   set orion.customer_type;
   call symputx('type'||left(Customer_Type_ID), Customer_Type);
run;

%put _user_;

data us;
   set orion.customer;
   where Country="US";
   CustType=Symget("type"||Left(Customer_Type_ID));
   keep Customer_ID Customer_Name Customer_Type_ID CustType;
run;

proc print data=us noobs;
   title "US Customers";
run;
title;


/*Q8-L2*/
%let var1=cat;
%let var2=3;
data test;
	length s1 s4 s5 $3;
	call symputx('var3', 'dog');
	r1="&var1";
	r2=&var2;
	r3="&var3";
	s1=symget('var1');
	s2=symget('var2');
	s3=input(symget('var2'),2.);
	s4=symget('var3');
	s5=symget('var'||left(r2));
run;


/*Q9-L1*/
/*a&b: m104e09*/
%let start=01Jan2007;
%let stop=31Jan2007;

proc means data=orion.order_fact noprint;
   where order_date between "&start"d and "&stop"d;
   var Quantity Total_Retail_Price;
   output out=stats mean=Avg_Quant Avg_Price;
   run;

data _null_;
   set stats;
   call symputx('Quant',put(Avg_Quant,4.2));
   call symputx('Price',put(Avg_Price,dollar7.2));
run;

proc print data=orion.order_fact noobs n;
   where order_date between "&start"d and "&stop"d;
   var Order_ID Order_Date Quantity Total_Retail_Price;
   sum Quantity Total_Retail_Price;
   format Total_Retail_Price dollar6.;
   title1 "Report from &start to &stop";
   title3 "Average Quantity: &quant";
   title4 "Average Price: &price";
run;

/*c*/
%symdel quant price;

/*d*/
Proc SQL noprint;
     Select mean(quantity) format=4.2, mean(Total_Retail_Price) format=dollar7.2
	 INTO :Quant, :Price
	 From orion.order_fact 
	 Where order_date between "&start"d and "&stop"d;
quit;

/*e*/
proc print data=orion.order_fact noobs n;
   where order_date between "&start"d and "&stop"d;
   var Order_ID Order_Date Quantity Total_Retail_Price;
   sum Quantity Total_Retail_Price;
   format Total_Retail_Price dollar6.;
   title1 "Report from &start to &stop";
   title3 "Average Quantity: &quant";
   title4 "Average Price: &price";
run;


/*Q10-L2*/
/* m104e10*/
Proc SQL noprint outobs=3;
  select customer_id, sum(Total_Retail_Price) as total
  INTO :Top3 separated by ', '
  from orion.order_fact
  group by Customer_ID
  order by total descending;
quit;

proc print data=orion.customer_dim noobs;
   where Customer_ID in (&top3);
   var Customer_ID Customer_Name Customer_Type;
   title 'Top 3 Customers';
run;
title;


/*Q11-L3*/
/*a*/
Proc SQL noprint;
     Select Count(*) INTO :NumRows
	 From Orion.Customer_Type;

%let NumRows=&NumRows;
 
     Select Customer_Type_ID INTO :CTYPE1-:CTYPE&NumRows
	 From Orion.Customer_Type;
quit;

/*b: m104e11*/
title 'Macro Variable beginning with CTYPE';
proc sql;
   select name, value
     from dictionary.macros
	where name like "CTYPE%";
quit;
title;

