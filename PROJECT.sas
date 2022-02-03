/*Q1 part a*/
libname PH1624 'C:\Users\bthakur\Downloads\New folder';

/*Q2 part b*/
proc surveyselect data=PH1624.obesity method=srs n=500 seed=2065249 out=PH1624.obesity2010;
	where year=2010;
run;
proc print data =PH1624.OBESITY2010;
RUN;
PROC SORT DATA=PH1624.OBESITY2010;
BY INTVID;
RUN;

proc surveyselect data=PH1624.obesity method=srs n=500 seed=2065249 out=PH1624.obesity2012;
	where year=2012;
run;
proc print data =PH1624.OBESITY2012;
RUN;
PROC SORT DATA=PH1624.OBESITY2012;
BY INTVID;
RUN;

/*Q1 part c*/
data PH1624.Finaldata;
set PH1624.OBESITY2010 PH1624.OBESITY2012; BY INTVID;
if _PA150R1=9 then _PA150R1=.;
ELSE IF AGE=9 THEN AGE=.;
else if _PA300R1=9 then _PA300R1=.;
else if _INCOMG=9 then _INCOMG=.;
ELSE IF _BMI4=9999 THEN _BMI4=.;
run;
proc print data=PH1624.Finaldata;
run;

/*Q2*/
data PH1624.Finaldata;
set PH1624.OBESITY2010 PH1624.OBESITY2012; BY INTVID;
if _PA150R1=9 then _PA150R1=.;
ELSE IF AGE=9 THEN AGE=.;
else if _PA300R1=9 then _PA300R1=.;
else if _INCOMG=9 then _INCOMG=.;
ELSE IF _BMI4=9999 THEN _BMI4=.;
if YEAR=2010 THEN YR=0;
ELSE YR=1;
IF DRSSDY_ = 0 THEN SODA=1;
ELSE IF DRSSDY_ <=49.99 THEN SODA=2;
ELSE IF DRSSDY_ <=99.99 THEN SODA=3;
ELSE IF DRSSDY_ <=299.99 THEN SODA=4;
ELSE SODA=5;
IF DRSDDY_ =0 THEN SUGAR=1;
ELSE IF DRSDDY_ <=49.99 THEN SUGAR=2;
ELSE IF DRSDDY_ <=99.99 THEN SUGAR=3;
ELSE IF DRSDDY_ <=299.99 THEN SUGAR=4;
ELSE SUGAR=5;
if _PA150R1=3 and _PA300R1=3 then PA=1; 
ELSE if _PA150R1=2 then PA=2; 
ELSE if _PA150R1=1 and _PA300R1=2 then PA=3; 
ELSE PA=4;
IF _FRUTSUM <=99 THEN FRUIT=1;
ELSE IF _FRUTSUM <=299 THEN FRUIT=2;
ELSE IF _FRUTSUM <=499 THEN FRUIT=3;
ELSE FRUIT=4;
IF _VEGESUM <=99 THEN VEG=1;
ELSE IF _VEGESUM <=299 THEN VEG=2;
ELSE IF _VEGESUM <=499 THEN VEG=3;
ELSE VEG=4;
BMI=_BMI4/100;
IF BMI<18.5 THEN BMICAT=1;
ELSE IF BMI<=25 THEN BMICAT=2;
ELSE IF BMI<=30 THEN BMICAT=3;
ELSE BMICAT=4;
PAFQ =PAFREQ1_ /1000;
RUN;
proc print data=PH1624.Finaldata;
run;

/*Q3 part a*/
proc means data=PH1624.finaldata mean std q1 q3 ;
	class YEAR;
	var AGE BMI PADUR1_ PAFQ;
	output out=demo1 mean= std= q1= q3= /autoname;
run;
PROC PRINT DATA=demo1;
run;

data demo1_2010 demo1_2012;
	set demo1;
	if year = 2010 then output demo1_2010;
		else if year = 2012 then output demo1_2012;
run;

%Let iterations= 4;
data long_demo1_2010;
	set demo1_2010;
	array a1[4] age_mean bmi_mean  PADUR1__Mean pafq_mean;
	array a2[4] age_stddev bmi_stddev padur1__stddev pafq_stddev;
	array a3[4] age_q1 bmi_q1  padur1__q1 pafq_q1;
	array a4[4] age_q3 bmi_q3  padur1__q3 pafq_q3;
	do i = 1 to &iterations;
		mean = a1[i]; 
		std = a2[i];  
		q1 = a3[i];   
		q3 = a4[i];   
		output;
	end;
	keep year mean std q1 q3;
run;
PROC PRINT DATA=long_demo1_2010;
run;

data long_demo1_2012;
	set demo1_2012;
	array a1[4] age_mean bmi_mean  PADUR1__Mean pafq_mean;
	array a2[4] age_stddev bmi_stddev padur1__stddev pafq_stddev;
	array a3[4] age_q1 bmi_q1  padur1__q1 pafq_q1;
	array a4[4] age_q3 bmi_q3  padur1__q3 pafq_q3;
	do i = 1 to &iterations;
		mean = a1[i]; 
		std = a2[i];  
		q1 = a3[i];   
		q3 = a4[i];   
		output;
	end;
	keep year mean std q1 q3;
run;
PROC PRINT DATA=long_demo1_2012;
run;

%let i=8;
data PH1624.TABLE1;
	merge long_demo1_2010(rename=(mean=mean_2010 std=std_2010 q1=q1_2010 q3=q3_2010))   
		  long_demo1_2012(rename=(mean=mean_2012 std=std_2012 q1=q1_2012 q3=q3_2012));
	array a[8] mean_2010 std_2010 q1_2010 q3_2010 mean_2012 std_2012 q1_2012 q3_2012;
	array b[8] mean_2010r std_2010r q1_2010r q3_2010r mean_2012r std_2012r q1_2012r q3_2012r;
	do i = 1 to &i;
b[i] = round(a[i], .01);     
	end;
	keep mean_2010r std_2010r q1_2010r q3_2010r mean_2012r std_2012r q1_2012r q3_2012r;
run;
proc print data=PH1624.table1;
title 'Table 1';
run;

/*Q3 partb*/
proc freq data=PH1624.finaldata;
	tables (SEX _RACE_G BMICAT)*year/nocol nopercent;
	ods output crosstabfreqs = demo2;
run;

%LET YR=2010;
data demo2_2010 demo2_2012;
	set demo2;
	if _type_ = '11';
	if year = &YR then output demo2_2010;
		else output demo2_2012;
	keep table frequency rowpercent;
run;
proc SORT data=demo2_2010;
BY TABLE;
run;
proc SORT data=demo2_2012;
BY TABLE;
run;
proc PRINT data=demo2_2010;
TITLE 'Demo2_2010';
run;
proc PRINT data=demo2_2012;
title 'Demo2_2012';
run;


data TABLE2;
merge demo2_2010 (rename=(frequency=freq2010 rowpercent=rowpct2010))
 demo2_2012 (rename=(frequency=freq2012 rowpercent=rowpct2012));  BY TABLE;
format freq2010 rowpct2010 freq2012 rowpct2012 6.2;
run;
Proc print data= Table2;
title 'Table 2';
run;
proc export data=table2 outfile='C:\Users\bthakur\Downloads\New Folder\Table2.xls' DBMS=xls replace;
run;

/*Q4 PART a*/
ods graphics on;
PROC SGSCATTER DATA=PH1624.Finaldata;
MATRIX AGE BMI PADUR1_ PAFQ / GROUP = Year DIAGONAL = (histogram normal);
title 'Graphics by year';
run;
ods graphics off;

/*Q4 PART B*/
ods graphics on;
PROC SGPLOT DATA=PH1624.Finaldata (WHERE=(year=2010));;
VBAR SODA /GROUP=BMICAT GROUPDISPLAY=CLUSTER;
LABEL BMICAT = 'Categorized body mass index';
TITLE '2010';
RUN;
ods graphics off;

ods graphics on;
PROC SGPLOT DATA=PH1624.Finaldata (WHERE=(year ne 2010));
VBAR SODA /GROUP=BMICAT GROUPDISPLAY=CLUSTER;
LABEL BMICAT = 'Categorized body mass index';
TITLE '2012';
RUN;
ods graphics off;

ods graphics on;
PROC SGPLOT DATA=PH1624.Finaldata (WHERE=(year=2010));
VBAR FRUIT / GROUP=BMICAT GROUPDISPLAY=CLUSTER;
LABEL BMICAT = 'Categorized body mass index';
TITLE '2010';
RUN;
ods graphics off;

ods graphics on;
PROC SGPLOT DATA=PH1624.Finaldata (WHERE=(year ne 2010));
VBAR FRUIT /GROUP=BMICAT GROUPDISPLAY=CLUSTER;
LABEL BMICAT = 'Categorized body mass index';
TITLE '2012';
RUN;
ods graphics off;

ods graphics on;
PROC SGPLOT DATA=PH1624.Finaldata (WHERE=(year=2010));
VBAR veg / GROUP=BMICAT GROUPDISPLAY=CLUSTER;
LABEL BMICAT = 'Categorized body mass index';
TITLE '2010';
RUN;
ods graphics off;

ods graphics on;
PROC SGPLOT DATA=PH1624.Finaldata (WHERE=(year ne 2010));
VBAR veg /GROUP=BMICAT GROUPDISPLAY=CLUSTER;
LABEL BMICAT = 'Categorized body mass index';
TITLE '2012';
RUN;
ods graphics off;

ods graphics on;
PROC SGPLOT DATA=PH1624.Finaldata (WHERE=(year=2010));
VBAR SUGAR / GROUP=BMICAT GROUPDISPLAY=CLUSTER;
LABEL BMICAT = 'Categorized body mass index';
TITLE '2010';
RUN;
ods graphics off;

ods graphics on;
PROC SGPLOT DATA=PH1624.Finaldata (WHERE=(year ne 2010));
VBAR SUGAR /GROUP=BMICAT GROUPDISPLAY=CLUSTER;
LABEL BMICAT = 'Categorized body mass index';
TITLE '2012';
RUN;
ods graphics off;

/* Q4 part d*/
ods graphics on;
PROC SGPLOT DATA=PH1624.Finaldata;
VBOX PAFQ / CATEGORY = SEX;
LABEL PAFQ=“Physical activity frequency per week (times)”;
TITLE 'PAFQ by Sex';
RUN;
ods graphics off;

ods graphics on;
PROC SGPLOT DATA=PH1624.Finaldata;
VBOX PADUR1_ / CATEGORY = SEX;
LABEL PADUR1_=“Physical activity duration per week (minutes)” ;
TITLE 'PADUR1_ by Sex';
RUN;
ods graphics off;

ods graphics on;
PROC SGPLOT DATA=PH1624.Finaldata;
VBOX PAFQ / CATEGORY = _RACE_G;
LABEL PAFQ=“Physical activity frequency per week (times)”;
TITLE 'PAFQ by Race';
RUN;
ods graphics off;

ods graphics on;
PROC SGPLOT DATA=PH1624.Finaldata;
VBOX PADUR1_ / CATEGORY = _Race_G;
LABEL PADUR1_=“Physical activity duration per week (minutes)” ;
TITLE 'PADUR1_ by Race';
RUN;
ods graphics off;

ods graphics on;
PROC SGPLOT DATA=PH1624.Finaldata;
VBOX PAFQ / CATEGORY = _INCOMG;
LABEL PAFQ=“Physical activity frequency per week (times)”;
TITLE 'PAFQ by Income';
RUN;
ods graphics off;

ods graphics on;
PROC SGPLOT DATA=PH1624.Finaldata;
VBOX PADUR1_ / CATEGORY = _IncomG;
LABEL PADUR1_=“Physical activity duration per week (minutes)” ;
TITLE 'PADUR1_ by Income';
RUN;
ods graphics off;

/*Q5*/
proc sort data=PH1624.finaldata; 
	by _PASTRNG; 
run;

proc ttest data=PH1624.finaldata; 
by _PASTRNG;
	class Year;
	var BMI PAFQ PADUR1_;
	ods output statistics = stat ConfLimits = cl TTests = ttests;
run;


data n2010 n2012;
	set stat;
	if _PASTRNG ne .;
	if class = '2010' then output n2010;
		else if class = '2012' then output n2012;
	keep _PASTRNG variable n;
run;


/*Extract means and 95% CIs*/
data stat2010 stat2012 diff;
	set cl;
	format mean 5.2 LowerCLMean 5.2 UpperCLMean 5.2;
	if _PASTRNG ne .;
	if class = '2010' then output stat2010;
		else if class = '2012' then output stat2012;
			else if variances = 'Equal' then output diff;
	keep _PASTRNG variable mean LowerCLMean UpperCLMean;
run;

/*Extract p-values*/
data ttests1;
	set ttests;
	if _PASTRNG ne .;
	if variances = 'Equal';
	keep _PASTRNG variable Probt;
run;

/*Merge N, Mean, 95% CI, and P-value*/
data table3;
	merge n2010 (rename=(n=n1))  /*This rename option can be ignored*/
		  stat2010(rename=(mean=mean1 lowerclmean=lower1 upperclmean=upper1))   /*This rename option can be ignored*/
		  n2012 (rename=(n=n2))
		  stat2012(rename=(mean=mean2 lowerclmean=lower2 upperclmean=upper2))
		  diff (rename=(mean=mean3 lowerclmean=lower3 upperclmean=upper3))
		  ttests1; 
run;
proc print data=table3;
TITLE 'Table 3';
run;

/*Q6*/
proc freq data=Ph1624.finaldata;
	where bmicat > 1;
	tables (SODA SUGAR FRUIT VEG)*BMICAT/CHISQ;
	ods output crosstabfreqs = crosstabfreqs ChiSq = ChiSq;
run;


data soda sugar fruit veg;
	set crosstabfreqs;
	if _type_ = 11;
	if soda ne . then output soda;
		else if sugar ne . then output sugar; 
			else if fruit ne . then output fruit;
				else if veg ne . then output veg;
	keep bmicat soda sugar fruit veg frequency rowpercent;
run;
proc print data=soda;
run;

%macro bar;
proc sort data=soda;
by soda bmicat;
run;


proc transpose data=soda out=out;
	by soda;
	var frequency rowpercent;
run;


data soda;
	retain n1 pct1 n2 pct2 n3 pct3;
	merge out(where=(_name_='Frequency') drop=_label_ rename=(col1=n1 col2=n2 col3=n3))
	      out(where=(_name_='RowPercent') drop=_label_ rename=(col1=pct1 col2=pct2 col3=pct3));
	pct1 = round(pct1, .01);
	pct2 = round(pct2, .01);
	pct3 = round(pct3, .01);
	drop soda _name_;
run;

proc print data=soda;
run; 
%mend;
%bar;

%macro bar;
proc sort data=sugar;
by sugar bmicat;
run;


proc transpose data=sugar out=out1;
	by sugar;
	var frequency rowpercent;
run;


data sugar;
	retain n1 pct1 n2 pct2 n3 pct3;
	merge out1(where=(_name_='Frequency') drop=_label_ rename=(col1=n1 col2=n2 col3=n3))
	      out1(where=(_name_='RowPercent') drop=_label_ rename=(col1=pct1 col2=pct2 col3=pct3));
	pct1 = round(pct1, .01);
	pct2 = round(pct2, .01);
	pct3 = round(pct3, .01);
	drop sugar _name_;
run;

proc print data=sugar;
run; 
%mend;
%bar;

%macro bar;
proc sort data=fruit;
by fruit bmicat;
run;


proc transpose data=fruit out=out2;
	by fruit;
	var frequency rowpercent;
run;


data fruit;
	retain n1 pct1 n2 pct2 n3 pct3;
	merge out2(where=(_name_='Frequency') drop=_label_ rename=(col1=n1 col2=n2 col3=n3))
	      out2(where=(_name_='RowPercent') drop=_label_ rename=(col1=pct1 col2=pct2 col3=pct3));
	pct1 = round(pct1, .01);
	pct2 = round(pct2, .01);
	pct3 = round(pct3, .01);
	drop fruit _name_;
run;

proc print data=fruit;
run; 
%mend;
%bar;

%macro bar;
proc sort data=veg;
by veg bmicat;
run;


proc transpose data=veg out=out3;
	by veg;
	var frequency rowpercent;
run;


data veg;
	retain n1 pct1 n2 pct2 n3 pct3;
	merge out3(where=(_name_='Frequency') drop=_label_ rename=(col1=n1 col2=n2 col3=n3))
	      out3(where=(_name_='RowPercent') drop=_label_ rename=(col1=pct1 col2=pct2 col3=pct3));
	pct1 = round(pct1, .01);
	pct2 = round(pct2, .01);
	pct3 = round(pct3, .01);
	drop veg _name_;
run;

proc print data=veg;
run; 
%mend;
%bar;

/**** create similar table for sugar fruit veg ****/
data table4;
	set soda sugar fruit veg;
run;
proc print data=table4;
run;
proc export data=table4 outfile='C:\Users\bthakur\Downloads\New Folder\Table4.xls' DBMS=xls replace;
run;

/*Q6 S8 With CALL SYMPUT*/
data _null_;
set table4;
x=0.1768;
y=0.0263;
z=0.3473;
v=0.2290;
if _N_=1 THEN call SYMPUT("prob",x);
else IF _N_=6 THEN CALL SYMPUT("pro",y);
else IF _N_=11 THEN CALL SYMPUT("pr",z);
else IF _N_=15 THEN CALL SYMPUT("p",v);
run;

data tabl;
	set table4;
if _n_=1 then p_value= "&prob";
 else IF _n_=6 THEN p_value= "&pro";
else IF _n_=11 THEN p_value= "&pr";
else IF _n_=15  THEN p_value= "&p";
run;
proc print data=tabl;
run;

/*Q6 S8 WITHOUT CALL SYMPUT*/
data table4;
	set soda sugar fruit veg;
	if _n_=1 then p_value=0.0177;
ELSE IF _n_=6 THEN p_value=0.0263;
ELSE IF _n_=11 THEN p_value=0.3473;
ELSE IF _n_=15 THEN p_value=0.2290;
run;
proc print data=table4;
run;

/*Q7  parta*/
ods trace on;
proc corr data=ph1624.finaldata;
	var BMI AGE PADUR1_ PAFQ;
run;
ods trace off; 

proc corr data=ph1624.finaldata;
	var BMI AGE PADUR1_ PAFQ;
	ods output PearsonCorr=corr;
run; 

data corr;
	set corr;
	array a[4] bmi age PADUR1_ PAFQ;
	do i = 1 to 4;
		if _n_ <= i then a[i] = .;
	end;
	format bmi 6.3 age 6.3 PADUR1_ 6.3 PAFQ 6.3;
	keep bmi age PADUR1_ PAFQ;
run;

proc print data=corr;
run;

data corr;
	set corr;
	if _n_ = 1 then bmi = .;
	if _n_ in (1 2) then age = .;
	if _n_ in (1 2 3) then PADUR1_ = .;
	PAFQ = .;
format bmi 6.3 age 6.3 PADUR1_ 6.3 PAFQ 6.3;
	keep bmi age PADUR1_ PAFQ;
run;
proc print data=corr;
run;
proc export data=corr outfile='C:\Users\bthakur\Downloads\New Folder\corr.xls' DBMS=xls replace;
run;

/*Q7 partb*/
/*Model 1*/
ods trace on;
proc reg data=ph1624.finaldata;
model bmi= year age PADUR1_ PAFQ;
ods output FitStatistics=statis ParameterEstimates=Param;
RUN;
ods trace off;

data finalparam;
set Param;
drop model DF tvalue label;
run;
proc print data=Finalparam;
run;


data finalstatis;
set statis (obs=2);
drop model label1 cvalue1 nvalue2 nvalue1;
Estimate=input(cvalue2,5.2);
rename label2=Variable;
drop cvalue2;
run;
proc print data=Finalstatis;
run;

data Model1;
set finalparam finalstatis;
by dependent;
Est=round(Estimate,.01);
SE= round(StdErr,.01);
P= round(Probt,.01);
drop StdErr Probt Estimate;
run;
proc print data=Model1 (DROP = Dependent);
title 'Model 1';
run;


data finaldata;
set ph1624.finaldata;
Female= (sex=2);
White= (_Race_G=1);
Black= (_Race_G=2);
Hisp= (_Race_G=3);
MED_INC=(_INCOMG=4);
HIGH_INC=(_INCOMG=5);
HIGH_SODA=(soda=4);
HIGH_SUGAR=(sugar=4);
HIGH_FRUIT=(FRUIT=4);
HIGH_VEG=(VEG=4);
run;

/*Model 2*/
proc reg data=finaldata;
model bmi= year age PADUR1_ PAFQ Female White Black Hisp MED_INC HIGH_INC;
ods output FitStatistics=stati ParameterEstimates=Parame;
RUN;


data finalparame;
set parame;
drop model DF tvalue label;
run;
proc print data=Finalparame;
run;


data finalstati;
set stati (obs=2);
drop model label1 cvalue1 nvalue2 nvalue1;
Estimate=input(cvalue2,5.2);
rename label2=Variable;
drop cvalue2;
run;
proc print data=Finalstati;
run;

data Model2;
set finalparame finalstati;
by dependent;
Est=round(Estimate,.01);
SE= round(StdErr,.01);
P= round(Probt,.01);
drop StdErr Probt Estimate;
run;
proc print data=Model2 (DROP = Dependent);
title 'Model 2';
run;

ods trace on;
proc reg data=finaldata;
model bmi= year age PADUR1_ PAFQ Female White Black Hisp MED_INC HIGH_INC HIGH_SODA HIGH_SUGAR HIGH_FRUIT HIGH_VEG;
RUN;
ods trace off;

/*Model 3*/
proc reg data=finaldata;
model bmi= year age PADUR1_ PAFQ Female White Black Hisp MED_INC HIGH_INC HIGH_SODA HIGH_SUGAR HIGH_FRUIT HIGH_VEG;
ods output FitStatistics=statistics ParameterEstimates=Parameter;
RUN;


data finalparameter;
set parameter;
drop Model DF tvalue label;
run;
proc print data=Finalparameter;
run;


data finalstat;
set statistics (obs=2);
drop model label1 cvalue1 nvalue2 nvalue1;
Estimate=input(cvalue2,5.2);
rename label2=Variable;
drop cvalue2;
run;
proc print data=Finalstat;
run;

data Model3;
set finalparameter finalstat;
by dependent;
Est=round(Estimate,.01);
SE= round(StdErr,.01);
P= round(Probt,.01);
drop StdErr Probt Estimate;
run;
proc print data=Model3 (DROP = Dependent);
title 'Model 3';
run;

data tabe;
merge Model1 Model2(rename=(Variable=Variable2 Est=Est2 SE=SE2 P=P2));
RUN;
Proc print data=tabe;
run;

data Table6;
merge tabe Model3 (rename=(Variable=Variable3 Est=Est3 SE=SE3 P=P3));
drop dependent;
run;
Proc print data=Table6;
Title 'Table 6';
run;
proc export data=table6 outfile='C:\Users\bthakur\Downloads\New Folder\Table6.xls' DBMS=xls replace;
run;

/*Q7 partc*/
ods graphics on;
proc reg data = finaldata plots (only) = (Diagnostics fitplot);
model bmi= year age PADUR1_ PAFQ Female White Black Hisp MED_INC HIGH_INC HIGH_SODA HIGH_SUGAR HIGH_FRUIT HIGH_VEG;
run;
ods graphics off;

proc reg data = finaldata;
model bmi= year age PADUR1_ PAFQ Female White Black Hisp MED_INC HIGH_INC HIGH_SODA HIGH_SUGAR HIGH_FRUIT HIGH_VEG;
output out=output1 r=res p=predval;
run;
 /*i*/
ods graphics on;
proc SGplot DATA=OUTPUT1;
scatter x=predval y=res;
refline 0;
Title 'Residuals v/s Predicted value';
run;
ods graphics off;

/*ii*/
ods graphics on;
proc sgplot data=OUTPUT1;
histogram res;
density res/type=normal;
TITLE 'Residuals with normal curve';
run;
ods graphics off;

/*iii*/
ODS GRAPHICS ON;
proc univariate data=output1 normal;
var res;
QQPLOT res/ normal (mu=est sigma=est);
title 'QQ Plot of Residuals';
run;
ODS GRAPHICS OFF;


/*Q7 partd*/
ods trace on;
proc reg data=finaldata;
model bmi= year age PADUR1_ PAFQ Female White Black Hisp MED_INC HIGH_INC HIGH_SODA HIGH_SUGAR HIGH_FRUIT HIGH_VEG/collin;
ods output CollinDiag=CollinDiagnost;
run;
ods trace off;

data CollinDiagnost;
set CollinDiagnost;
drop model dependent Eigenvalue conditionindex intercept;
run;
proc print data=CollinDiagnost noobs;
title 'Table 7';
run;
