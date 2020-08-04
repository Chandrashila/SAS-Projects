
*Creating and setting the library to final

libname final 'Desktop/finalproject';

*Importing a the dataset into a table "Ferma"

proc import datafile="Desktop/finalproject/FermaLogis_Event_Type.csv" 
out=final.Ferma dbms=csv replace;
getnames=YES;
run;

*Data Preprocessing
*Creating new column "Turnover_Type" using turnover='Yes' and type

data final.Ferma;
length Turnover_Type $30.;
set final.Ferma;


if turnover='Yes' and type=1 then Turnover_Type="Retirement";
else if turnover='Yes' and type=2 then Turnover_Type="Voluntary Resignation";
else if turnover='Yes' and type=3 then Turnover_Type="Involuntary Resignation";
else if turnover='Yes' and type=4 then Turnover_Type="Job Termination";
else Turnover_Type="No turnover";
run;

*Value counts of Turnover_Type to see which categories contribute towards the turnover

proc datasets library=final memtype=data;
contents data=Ferma;
run;
proc freq data=final.Ferma;
where Turnover_Type <> 'No turnover';
tables type /chisq;
run;
* Value counts of Over18 and EmployeeCount
proc sql;
	select count(*) as N_obs 
	from final.Ferma
	where Over18 not in ('Y');
quit;

proc sql;
	select count(*) as N_obs 
	from final.Ferma
	where EmployeeCount not in (1);
quit;

*Dropping the ID varaiable and variables with a single value

DATA final.Ferma(DROP=','n X Over18 EmployeeCount EmployeeNumber);
SET final.Ferma;
RUN;


*Detecting the Missing Values
*Detecting missing values in numeric variables

proc means data = final.Ferma n nmiss;
var _numeric_;
run;


*Detecting if there are any missing values in each observation 
data final.Ferma;
  set final.Ferma;
  miss_n = cmiss(of Age -- bonus_40);
run;

*Counting the number of missing values
proc sql;
	select count(*) as N_obs 
	from final.Ferma
	where miss_n not in (0);
quit;

*Counting the no. of NA values in bonus_1
proc sql;
	select count(*) as N_obs 
	from final.Ferma
	where bonus_1 like ('NA');
quit;


*Replace the NA's in bonus columns to 0

data final.Ferma;
set final.Ferma;
array bns _character_;
do _n_=1 to dim(bns);
if bns(_n_)="NA" then bns(_n_)="0";
end;
run;

DATA final.Ferma(DROP=miss_n);
SET final.Ferma;
RUN;
*creating new columns with grouping the values to enable data exploration and further analysis

data final.Ferma;
set final.Ferma;
If EnvironmentSatisfaction>=3 then Env_Satisfied='Yes'; else Env_Satisfied='No';
If StockOptionLevel>0 then stocks='Yes'; else stocks='No';
If JobSatisfaction>=3 then Satisfied='Yes'; else Satisfied='No';
If JobInvolvement>=3 then Involvement='Yes'; else Involvement='No';
If Education=3 or Education=4 or Education=5 then HigherEducation='Yes'; else HigherEducation='No';
run;


*Cummulative sum of the bonus

data final.bonuscumsum;
set final.bonuscumsum;
array bonus_(*) bonus_1-bonus_40;
array cumm(*) cumm1-cumm40;
cumm1=bonus_1;
do i=2 to 40;
cumm(i)=cumm(i-1)+bonus_(i);
end;
run;


DATA final.Ferma(DROP=i);
SET final.Ferma;
RUN;



*Hazard and Survival Curves for each Type

*Retiring employees

proc lifetest data=final.Ferma plots=(S H) method=LIFE;
time YearsAtCompany*Type(0, 2, 3, 4);
strata stocks;
title "Survival curves of stock vs Retirement type";
run;

*Voluntary Resignation

proc lifetest data=final.Ferma plots=(S H) method=LIFE;
time YearsAtCompany*Type(0, 1, 3, 4);
strata stocks;
title "Survival curves of stock vs Voluntary Resignation type";
run;

*Involuntary Resignation

proc lifetest data=final.Ferma plots=(S H) method=LIFE;
time YearsAtCompany*Type(0, 1, 2, 4);
strata stocks;
title "Survival curves of stock vs Involuntary Resignation type";
run;

*Job Termination

proc lifetest data=final.Ferma plots=(S H) method=LIFE;
time YearsAtCompany*Type(0, 1, 2, 3);
strata stocks;
title "Survival curves of stock vs Job Termination type";
run;

*Job Satisfaction Plot

proc sgplot data=final.Ferma;
vbar Turnover_Type /group=Satisfied;
title 'Employee Job satisfaction vs Turnover_Type';
where Turnover_Type <> 'No turnover';
run;

*Overtime Plot

proc sgplot data=final.Ferma;
vbar Turnover_Type /group=Overtime;
title 'Overtime vs Turnover_Type';
where Turnover_Type <> 'No turnover';
run;

*EducationField Plot

proc sgplot data=final.Ferma;
vbar Turnover_Type /group=EducationField;
title 'EducationField vs Turnover_Type';
where Turnover_Type <> 'No turnover';
run;

*Environment Satisfaction Plot

proc sgplot data=final.Ferma;
vbar Turnover_Type /group=Env_Satisfied;
title 'Employee Environment satisfaction vs Turnover_Type';
where Turnover_Type <> 'No turnover';
run;

*Business Travel Plot

proc sgplot data=final.Ferma;
vbar Turnover_Type /group=BusinessTravel;
title 'Business Travel vs Turnover_Type';
where Turnover_Type <> 'No turnover';
run;


*Education Plot

proc sgplot data=final.Ferma;
vbar Turnover_Type /group=HigherEducation;
title 'HigherEducation vs Turnover_type';
where Turnover_Type <> 'No turnover';
run;

*Gender Plot and Freq Plot ;

proc sgplot data=final.Ferma;
vbar Turnover_Type /group=Gender;
title 'Gender  Vs Turnover_types';
where Turnover_Type <> 'No turnover';
run;
proc freq DATA=final.Ferma;
tables Gender*Turnover_Type/ CHISQ plots=freqplot;
title ' Freq Plot of Gender vs Turnover_type';
where Turnover_Type <> 'No turnover';
run;

*Job Involvement Plot

proc sgplot data=final.Ferma;
vbar Turnover_Type /group=Involvement;
title 'Employee Job Involvement vs Turnover_type';
where Turnover_Type <> 'No turnover';
run;

*PerformanceRating Plot

proc sgplot data=final.Ferma;
vbar Turnover_Type /group=PerformanceRating;
title 'Performance vs Turnover_type';
where Turnover_Type <> 'No turnover';
run;


*WorkLife Balance Plot

proc sgplot data=final.Ferma;
vbar Turnover_Type /group=WorkLifeBalance;
title 'WorkLifeBalance vs Turnover_type';
where Turnover_Type <> 'No turnover';
run;


*Checking for non proportional variables using assess statement for martingale residuals ;

PROC phreg DATA=final.bonuscumsum;
	where YearsAtCompany>1;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction 
		StockOptionLevel WorkLifeBalance StockOptionLevel TrainingTimesLastYear 
		WorkLifeBalance stocks HigherEducation;
	MODEL YearsAtCompany*Type(0)=Age BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobRole JobSatisfaction DistanceFromHome 
		NumCompaniesWorked OverTime TotalWorkingYears YearsInCurrentRole Jobrole 
		stocks;
	title PHreg validation model/ties=efron;
	ASSESS PH/resample;
	title PHreg Non Proportional check model;
RUN;

*Checking for time dependent variables/ non proportional with Schoenfeld residuals;

PROC phreg DATA=final.bonuscumsum;
	where YearsAtCompany>1;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction 
		StockOptionLevel WorkLifeBalance StockOptionLevel WorkLifeBalance stocks
		HigherEducation;
	MODEL YearsAtCompany*Type(0)=BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobRole JobSatisfaction DistanceFromHome 
		NumCompaniesWorked OverTime TotalWorkingYears YearsInCurrentRole Jobrole 
		stocks trainingtimeslastyear /ties=efron;
	OUTPUT OUT=TimeDependentVariableModel RESSCH=age BusinessTravel 
		EnvironmentSatisfaction JobInvolvement OverTime JobRole JobSatisfaction 
		DistanceFromHome NumCompaniesWorked OverTime TotalWorkingYears 
		YearsInCurrentRole Jobrole stocks;
	title PHreg validation model;
RUN;

DATA TimeDependentVariableModel;
	SET TimeDependentVariableModel;
	id=_n_;
RUN;

/*find the correlations with years in thecompany and it's functions */
DATA CorrTimeDependentVariableModel;
	SET TimeDependentVariableModel;
	logYearsAtCompany=log(YearsAtCompany);
	YearsAtCompany2=YearsAtCompany*YearsAtCompany;

PROC CORR data=CorrTimeDependentVariableModel;
	VAR YearsAtCompany logYearsAtCompany YearsAtCompany2;
	WITH DistanceFromHome NumCompaniesWorked TotalWorkingYears YearsInCurrentRole;
RUN;

*Residuals of Number of Companies Worked vs Years At Company;

proc sgplot data=TimeDependentVariableModel;
	scatter x=YearsAtCompany y=NumCompaniesWorked / datalabel=id;
	title residuals of Number of Companies Worked vs Years At Company;
	*Residuals of Total Working Years vs Years At Company;

proc sgplot data=TimeDependentVariableModel;
	scatter x=YearsAtCompany y=TotalWorkingYears / datalabel=id;
	title Total Working Years vs Years At Company;
	*Residuals of Years In Current role vs Years At Company;

proc sgplot data=TimeDependentVariableModel;
	scatter x=YearsAtCompany y=YearsInCurrentRole/ datalabel=id;
	title Years In Current role vs Years At Company;
run;

*adding interactions for non proportional variables using YearsAtCompany ;

PROC phreg DATA=final.bonuscumsum;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction 
		StockOptionLevel WorkLifeBalance StockOptionLevel TrainingTimesLastYear 
		WorkLifeBalance stocks HigherEducation;
	MODEL YearsAtCompany*Type(0)=BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobRole JobSatisfaction DistanceFromHome OverTime 
		Jobrole stocks EmployBonus TotalWorkingYears YearsInCurrentRole 
		NumCompaniesWorked TimeIntercatWorkingYears TimeIntercatCurrentRole 
		TimeIntercatNumCompaniesWorked trainingtimeslastyear/ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	title PHreg interaction model;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmployBonus=cum[YearsAtCompany-1];
	else
		EmployBonus=bonus_1;
RUN;

*Checking number of employees left in each type;

PROC FREQ DATA=final.Ferma;
	TABLES Type*Turnover_Type / CHISQ plots=freqplot;
	TITLE 'employees left in each type ';
RUN;

/*Graphically test for linear relation between type hazards*/
DATA Retirement;
	/*create Retirementexit data*/
	SET final.Ferma;
	event=(Type=1);

	/*this is for censoring out other types, another way to write if statement*/
	Turnover_Type='Retirement';

DATA VoluntaryResignation;
	/*create Voluntary Resignation exit data*/
	SET final.Ferma;
	event=(Type=2);

	/*this is for censoring out other types, another way to write if statement*/
	Turnover_Type='Voluntary Resignation';

DATA InvoluntaryResignation;
	/*create Involuntary Resignation  exit data*/
	SET final.Ferma;
	event=(Type=3);

	/*this is for censoring out other types, another way to write if statement*/
	Turnover_Type='Involuntary Resignation';

DATA JobTermination;
	/*create Job Termination  exit data*/
	SET final.Ferma;
	event=(Type=4);

	/*this is for censoring out other types, another way to write if statement*/
	Turnover_Type='Job Termination';

Data final.combine;
	set Retirement VoluntaryResignation InvoluntaryResignation JobTermination;

	/*Graphically test for linear relation between type hazards*/
PROC LIFETEST DATA=final.combine method=life PLOTS=(LLS);
	/*LLS plot is requested*/
	TIME YearsAtCompany*event(0);
	STRATA Turnover_Type /diff=all;
RUN;

*Implementing phreg using programming step for all the turnover types in one model;

PROC phreg DATA=final.bonuscumsum;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction 
		StockOptionLevel WorkLifeBalance StockOptionLevel WorkLifeBalance stocks 
		HigherEducation;
	MODEL YearsAtCompany*Type(0)=BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobRole JobSatisfaction DistanceFromHome 
		NumCompaniesWorked OverTime TotalWorkingYears YearsInCurrentRole Jobrole 
		stocks EmployBonus TimeIntercatWorkingYears TimeIntercatCurrentRole 
		TimeIntercatNumCompaniesWorked TrainingTimesLastYear/ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	title PHreg model;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmployBonus=cum[YearsAtCompany-1];
	else
		EmployBonus=bonus_1;
RUN;

*Implementing phreg using programming step for the type Retirement;

PROC phreg DATA=final.bonuscumsum;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction 
		StockOptionLevel WorkLifeBalance StockOptionLevel WorkLifeBalance stocks 
		HigherEducation;
	MODEL YearsAtCompany*Type(0, 2, 3, 4)=Age BusinessTravel 
		EnvironmentSatisfaction JobInvolvement OverTime JobRole JobSatisfaction 
		DistanceFromHome NumCompaniesWorked OverTime TotalWorkingYears 
		YearsInCurrentRole Jobrole stocks EmployBonus TimeIntercatWorkingYears 
		TimeIntercatCurrentRole TimeIntercatNumCompaniesWorked /ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	title PHreg Retirement Event Type Model;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmployBonus=cum[YearsAtCompany-1];
	else
		EmployBonus=bonus_1;
RUN;

*Implementing phreg using programming step for the type Voluntary Resignation/ Turnover;

PROC phreg DATA=final.bonuscumsum;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction satisfied MaritalStatus PerformanceRating 
		RelationshipSatisfaction StockOptionLevel WorkLifeBalance StockOptionLevel 
		WorkLifeBalance stocks HigherEducation involvement;
	MODEL YearsAtCompany*Type(0, 1, 3, 4)=BusinessTravel EnvironmentSatisfaction 
		OverTime satisfied involvement DistanceFromHome NumCompaniesWorked OverTime 
		TotalWorkingYears YearsInCurrentRole stocks EmployBonus 
		TimeIntercatWorkingYears TimeIntercatCurrentRole TrainingTimesLastYear 
		/ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	title PHreg model for Voluntary Resignation/ Turnover;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmployBonus=cum[YearsAtCompany-1];
	else
		EmployBonus=cum1;
RUN;

*Implementing phreg using programming step for the type InVoluntary Resignation;

PROC phreg DATA=final.bonuscumsum;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction 
		StockOptionLevel WorkLifeBalance StockOptionLevel WorkLifeBalance stocks 
		HigherEducation satisfied;
	MODEL YearsAtCompany*Type(0, 1, 2, 4)=age BusinessTravel 
		EnvironmentSatisfaction JobInvolvement OverTime JobRole satisfied 
		DistanceFromHome NumCompaniesWorked OverTime TotalWorkingYears 
		YearsInCurrentRole Jobrole stocks EmployBonus TimeIntercatWorkingYears 
		TimeIntercatCurrentRole TimeIntercatNumCompaniesWorked TrainingTimesLastYear 
		HigherEducation /ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	title PHreg model;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmployBonus=cum[YearsAtCompany-1];
	else
		EmployBonus=bonus_1;
RUN;

*Implementing phreg using programming step for the type Termination;

PROC phreg DATA=final.bonuscumsum;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction 
		StockOptionLevel WorkLifeBalance StockOptionLevel TrainingTimesLastYear 
		WorkLifeBalance stocks HigherEducation;
	MODEL YearsAtCompany*Type(0, 1, 2, 3)=BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobRole JobSatisfaction DistanceFromHome OverTime 
		TotalWorkingYears YearsInCurrentRole Jobrole stocks EmployBonus 
		TotalWorkingYears TimeIntercatWorkingYears YearsInCurrentRole 
		TimeIntercatCurrentRole NumCompaniesWorked TimeIntercatNumCompaniesWorked 
		/ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	title PHreg model;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmployBonus=cum[YearsAtCompany-1];
	else
		EmployBonus=bonus_1;
RUN;

DATA LogRatioTest_PHregTime;
	Nested=2221.764;
	Retirement=128.640;
	VoluntaryResignation=971.656;
	InVoluntaryResignation=499.934;
	Termination=379.974;
	Total=Retirement+ VoluntaryResignation+InVoluntaryResignation+Termination;
	Diff=Nested - Total;
	P_value=1 - probchi(Diff, 66);
	*30-(30+17+30+29coef. in 3 models - 26coef. in nested;
RUN;

PROC PRINT DATA=LogRatioTest_PHregTime;
	FORMAT P_Value 5.3;
	title total nested vs individual hypothesis;
RUN;

*checking involuntry  resignation and job termination;

PROC phreg DATA=final.bonuscumsum;
	class BusinessTravel Department Education EducationField 
		EnvironmentSatisfaction Gender JobInvolvement JobLevel OverTime JobRole 
		JobSatisfaction MaritalStatus PerformanceRating RelationshipSatisfaction 
		StockOptionLevel WorkLifeBalance StockOptionLevel TrainingTimesLastYear 
		WorkLifeBalance stocks HigherEducation satisfied ;
	MODEL YearsAtCompany*Type(0, 1, 2)=BusinessTravel EnvironmentSatisfaction 
		JobInvolvement OverTime JobSatisfaction DistanceFromHome NumCompaniesWorked 
		OverTime TotalWorkingYears YearsInCurrentRole Jobrole stocks EmployBonus 
		TimeIntercatWorkingYears TimeIntercatCurrentRole 
		TimeIntercatNumCompaniesWorked /ties=efron;
	TimeIntercatWorkingYears=YearsAtCompany*TotalWorkingYears;
	TimeIntercatCurrentRole=YearsAtCompany*YearsInCurrentRole;
	TimeIntercatNumCompaniesWorked=YearsAtCompany*NumCompaniesWorked;
	title PHreg model for involuntary resignation and job termination;
	ARRAY cum(*) cum1-cum40;

	if YearsAtCompany>1 then
		EmployBonus=cum[YearsAtCompany-1];
	else
		EmployBonus=bonus_1;
RUN;

*checking involuntry  resignation and job termination;

DATA LogRatioTest_PHregIVJT;
	Nested=916.165;
	InVoluntaryResignation=499.944;
	Termination=379.74;
	Total=InVoluntaryResignation+Termination;
	Diff=Nested - Total;
	P_value=1 - probchi(Diff, 30);
	*26*2coef. in 2 models - 26coef. in nested;
RUN;

*checking involuntry  resignation and job termination;

PROC PRINT DATA=LogRatioTest_PHregIVJT;
	FORMAT P_Value 5.3;
	title nested(involuntry, termination) vs individual hypothesis;

