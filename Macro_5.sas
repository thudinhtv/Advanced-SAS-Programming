Libname orion 'path';

/*Chap 5*/
/*Q1-L1*/
/*a: m105e01*/
%macro listing(custtype);
	proc print data=orion.customer noobs;
	run;
%mend listing;

%listing(2010)

/*b*/
%macro listing(custtype);
	proc print data=orion.customer noobs;
		%IF &custtype= %THEN %DO;
			var Customer_ID Customer_Name Customer_Type_ID;
			title "All Customers";
		%END;
		%ELSE %DO;
			Where Customer_Type_ID=&custtype;
			var Customer_ID Customer_Name;
			title "Customer Type: &custtype";
		%END;
	run;
%mend listing;
title;

/*c*/
%listing()

%listing(2010)


/*Q2-L2*/
/*a: m10e502*/
%macro day;
	%if &sysday=SATURDAY  
		%then %put Yes;
		%else %put Sorry;
%mend day;

options nomlogic nosymbolgen;

%day


/*b*/
%macro day;
	%if &sysday=Wednesday  
		%then %put Yes;
		%else %put Sorry;
%mend day;

options nomlogic nosymbolgen;

%day


/*Q3-L3*/
/*a: m105e03*/
%macro where(state);
	%if &state=OR
		%then %put Oregon;
		%else %put Wherever;
%mend where;

%where(CA)

/*b: We need the %STR function to interpret OR as plain text instead of a logical operator*/
%macro where(state);
	%if &state=%str(OR)
		%then %put Oregon;
		%else %put Wherever;
%mend where;

%where(CA)


/*Q4-L1*/
/*a: m105e04*/
%macro custtype(type);
   %let type=%upcase(&type);
    proc print data=orion.customer_dim;
       var Customer_Group Customer_Name Customer_Gender  
           Customer_Age;
       where upcase(Customer_Group) contains "&type";
       title "&type Customers";
    run;
%mend custtype;

%custtype(internet)

/*b*/
%macro custtype(type)/ MINOPERATOR;
   %let type=%upcase(&type);
   %IF &type in GOLD INTERNET %THEN %DO;
    	proc print data=orion.customer_dim;
       		var Customer_Group Customer_Name Customer_Gender Customer_Age;
       		where upcase(Customer_Group) contains "&type";
       		title "&type Customers";
    	run;
	%END;
	%ELSE %DO;
	     %PUT ERROR: Invalid TYPE: &type..;
		 %PUT ERROR: Valid TYPE values are INTERNET or GOLD.;
	%END;
%mend custtype;


/*c*/
%custtype(internet)

%custtype(Online)


/*d*/
%macro custtype(type)/ MINOPERATOR;
	%IF &type= %THEN %DO;
 		%PUT ERROR: Missing TYPE.;
		%PUT ERROR: Valid values are INTERNET or GOLD.;
	%END;
	%ELSE %DO;
   		%let type=%upcase(&type);
		%IF &type in GOLD INTERNET %THEN %DO;
    		proc print data=orion.customer_dim;
       			var Customer_Group Customer_Name Customer_Gender Customer_Age;
       			where upcase(Customer_Group) contains "&type";
       			title "&type Customers";
    		run;
		%END;
		%ELSE %DO;
	     	%PUT ERROR: Invalid TYPE: &type..;
		 	%PUT ERROR: Valid TYPE values are INTERNET or GOLD.;
		%END;
	%END;
%mend custtype;


/*e*/
%custtype()
%custtype(GOLD)
%custtype(internet)
%custtype(Gold)
%custtype(silver)


/*Q5-L2*/
/*a: m105e05*/
%macro listing(custtype);
   %if &custtype= %then %do;
		proc print data=orion.customer noobs;
   		var Customer_ID Customer_Name Customer_Type_ID;
   		title "All Customers"; 
		run;
   %end;
   %else %do;
		proc print data=orion.customer noobs;
      	where Customer_Type_ID=&custtype;
         var Customer_ID Customer_Name;
         title "Customer Type: &custtype";
      run;
	%end;
%mend listing;

%listing(1020)
%listing()

/*b*/
Options mprint;
%macro listing(custtype)/ minoperator;
   %if &custtype= %then %do;
		proc print data=orion.customer noobs;
   		var Customer_ID Customer_Name Customer_Type_ID;
   		title "All Customers"; 
		run;
   %end;
   %else %do;
   		Proc SQL noprint;
			Select distinct Customer_Type_ID INTO :IDlist separated by ' '
			from orion.customer_type;
		quit;
		%if &custtype in &IDlist %then %do;
			proc print data=orion.customer noobs;
      			where Customer_Type_ID=&custtype;
         		var Customer_ID Customer_Name;
         		title "Customer Type: &custtype";
      		run;
		%end;
		%else %do;
			%PUT ERROR: Value for CUSTTYPE is invalid.;
		 	%PUT Valid values are &IDlist..;
		%end;
	%end;
%mend listing;


/*c*/
%listing()
%listing(2030)
%listing(2050)


/*Q6-L3*/
/*a: m105e06*/
%macro salarystats(decimals=2,order=internal);
	options nolabel;
	title 'Salary Stats';
	proc means data=orion.staff maxdec=&decimals order=&order;
		where job_title contains 'Sales';
		var salary;
		class job_title;
	run;
	title;
%mend salarystats;

%salarystats()
%salarystats(decimals=5,order=fudge)

/*b*/
%macro salarystats(decimals=2,order=internal)/ MINOPERATOR;
	%let NUMERRORS=0;
	%if not(&decimals IN 0 1 2 3 4) %then %do;
       	%let NUMERRORS=%eval(&NUMERRORS+1);
	   	%put ERROR: Invalid DECIMALS parameter: &decimals..;
	   	%put ERROR: Valid DECIMALS values are 0 to 4.;
	%end;

	%let order=%upcase(&order);
	%if not(&order IN INTERNAL FREQ) %then %do;
       	%let NUMERRORS=%eval(&NUMERRORS+1);
	   	%put ERROR: Invalid ORDER parameter: &order..;
	   	%put ERROR: Valid ORDER values are INTERNAL or FREQ.;
	%end;

	%IF &NUMERRORS=0 %THEN %DO;
	options nolabel;
	title 'Salary Stats';
	proc means data=orion.staff maxdec=&decimals order=&order;
		where job_title contains 'Sales';
		var salary;
		class job_title;
	run;
	title;
	%END;
	%ELSE %PUT ERROR: &NUMERRORS errors. Code not submitted.;

%mend salarystats;


/*c*/
%salarystats()
%salarystats(decimals=5,order=fudge)



/*Q7-L1*/
/*a: m105e07*/

proc means data=orion.order_fact sum mean maxdec=2;
   where Order_Type=1;
   var Total_Retail_Price CostPrice_Per_Unit;  
   title "Summary Report for Order Type 1";
run;


/*b*/
%macro Report;
     %do i=1 %to 3;
	 	proc means data=orion.order_fact sum mean maxdec=2;
   		where Order_Type=&i;
   		var Total_Retail_Price CostPrice_Per_Unit;  
   		title "Summary Report for Order Type &i";
		run;
	 %end;
%mend Report;

%Report;


/*c*/
%macro Report;
data _null_;
   set orion.lookup_order_type;
   call symputx('type'||left(_n_), label);
run;
     %do i=1 %to 3;
	 	proc means data=orion.order_fact sum mean maxdec=2;
   		where Order_Type=&i;
   		var Total_Retail_Price CostPrice_Per_Unit;  
   		title "Summary Report for Order &&type&i";
		run;
	 %end;
%mend Report;

%Report;


/*d*/
%macro Report;
data _null_;
   set orion.lookup_order_type end=last;
   call symputx('type'||left(_n_), label);
   if last then call symputx('endloop', _n_);
run;
     %do i=1 %to %endloop;
	 	proc means data=orion.order_fact sum mean maxdec=2;
   		where Order_Type=&i;
   		var Total_Retail_Price CostPrice_Per_Unit;  
   		title "Summary Report for Order &&type&i";
		run;
	 %end;
%mend Report;

%Report;


/*Q8-L2*/
/*a: m105e08*/

title; 
footnote; 

%macro tops(obs=3);
    proc means data=orion.order_fact sum nway noprint; 
       var Total_Retail_Price;
       class Customer_ID;
       output out=customer_freq sum=sum;
    run;

    proc sort data=customer_freq;
       by descending sum;
    run;

    data _null_;
       set customer_freq(obs=&obs);
       call symputx('top'||left(_n_), Customer_ID);
    run;
%mend tops;

%tops()
%tops(obs=5)

/*b*/

title; 
footnote; 

%macro tops(obs=3);
    proc means data=orion.order_fact sum nway noprint; 
       var Total_Retail_Price;
       class Customer_ID;
       output out=customer_freq sum=sum;
    run;

    proc sort data=customer_freq;
       by descending sum;
    run;

    data _null_;
       set customer_freq(obs=&obs);
       call symputx('top'||left(_n_), Customer_ID);
    run;

	proc print data=orion.customer_dim noobs;
		Where Customer_ID in 
			(%DO i=1 %TO &obs; 
			    &&top&i
			 %END;);
		title "Top &obs Customers";
	run;
%mend tops;

%tops()
%tops(obs=5)


/*Q9-L3*/
/*a: m105e09*/
title; 
footnote; 

%macro memberlist(custtype);
   proc print data=Orion.Customer_dim;
      var Customer_Name Customer_ID Customer_Age_Group;
      where Customer_Type="&custtype";
      title "A List of &custtype";
   run;
%mend memberlist;

%macro listall;
   data _null_;
      set orion.customer_type end=final;
      call symputx('type'||left(_n_), Customer_Type);
      if final then call symputx('n',_n_);
   run;
   %put _user_; 
%mend listall;

%listall


/*b*/

title; 
footnote; 

%macro memberlist(custtype);
   proc print data=Orion.Customer_dim;
      var Customer_Name Customer_ID Customer_Age_Group;
      where Customer_Type="&custtype";
      title "A List of &custtype";
   run;
%mend memberlist;

%macro listall;
   data _null_;
      set orion.customer_type end=final;
      call symputx('type'||left(_n_), Customer_Type);
      if final then call symputx('n',_n_);
   run;
   %DO i=1 %TO &n;
		%memberlist(&&type&i);
   %END; 
%mend listall;

%listall

/*Q10-L1*/
/*a*/
%let dog=Paisley;
%macro whereisit;
	%put My dog is &dog;
%mend whereisit;

%whereisit

/*B/c the %Let statement is outside the macro definition, the macro variable DOG is stored in the GLOBAL symbol table*/

/*b*/
%macro whereisit;
	%let dog=Paisley;
	%put My dog is &dog;
%mend whereisit;

%whereisit

/*B/c the %Let statement is inside the macro definition, the macro variable DOG is stored in the LOCAL symbol table*/

/*c*/
%macro whereisit(dog);
	%put My dog is &dog;
%mend whereisit;

%whereisit (Paisley)

/*B/c the DOG is a macro parameter, it is stored in the LOCAL symbol table*/


/*Q11-L2*/
/*a: m105e11*/
title; 
footnote; 

%macro varscope;
   data _null_;
      set orion.customer_type end=final;
      call symputx('localtype'||left(_n_), Customer_Type);
      if final then call symputx('localn',_n_);
   run;
   %put _user_;
%mend varscope;

%varscope


/*b*/
%macro varscope;
   data _null_;
      set orion.customer_type end=final;
      call symputx('localtype'||left(_n_), Customer_Type, 'L');
      if final then call symputx('localn',_n_, 'L');
   run;
   %put _user_;
%mend varscope;

%varscope


/*c*/
%macro varscope;
   %LOCAL x;
   data _null_;
      set orion.customer_type end=final;
      call symputx('localtype'||left(_n_), Customer_Type);
      if final then call symputx('localn',_n_);
   run;
   %put _user_;
%mend varscope;

%varscope


/*d*/
%macro varscope;
   %LOCAL x;
   data _null_;
      set orion.customer_type end=final;
      call symputx('localtype'||left(_n_), Customer_Type, 'G');
      if final then call symputx('localn',_n_, 'G');
   run;
   %put _user_;
%mend varscope;

%varscope


/*Q12-L3*/
/*a: cleanup */
%macro cleanup;
%local delete;
proc sql noprint;
   select name into :delete separated by ' '
     from dictionary.macros
	 where scope='GLOBAL';
quit;
%symdel &delete;
%mend cleanup;

%cleanup

/*b: m105e12*/

title; 
footnote; 
options mprint;
%macro createmacvar;
   data _null_;
      set orion.lookup_order_type end=last;
      call symputx('type'||left(start), label, 'L');
      if last then call symputx('endloop', _n_, 'L');
   run;
%mend createmacvar;

%macro sumreport;
   %createmacvar
   %do num=1 %to &endloop;
      proc means data=orion.order_fact sum mean maxdec=2;
         where Order_Type = &num;
         var Total_Retail_Price CostPrice_Per_Unit;
         title "Summary Report for &&type&num";
      run;
   %end;
%mend sumreport;

%sumreport


/*c*/

title; 
footnote; 

%macro createmacvar;
   data _null_;
      set orion.lookup_order_type end=last;
      call symputx('type'||left(start), label);
      if last then call symputx('endloop', _n_);
   run;
%mend createmacvar;

%macro sumreport;
   %createmacvar
   %do num=1 %to &endloop;
      proc means data=orion.order_fact sum mean maxdec=2;
         where Order_Type = &num;
         var Total_Retail_Price CostPrice_Per_Unit;
         title "Summary Report for &&type&num..s";
      run;
   %end;
%mend sumreport;

%sumreport
