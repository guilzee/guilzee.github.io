*Step 1 assumes the library reference is being created.;

************************************************************************************
************************************************************************************
Step 2: Import the National Outbreak Public Data Tool worksheet into sas and check out
the contents of the file;

PROC IMPORT DATAFILE=NationalOutbreakPublicDataTool DBMS=XLSX OUT=WORK.IMPORT;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=WORK.IMPORT;
RUN;

************************************************************************************
************************************************************************************
Step 3: Rename the dataset and save it to the work library to clean and manipulate 
the data without losing the original info;

data listeria;
	set Import;
RUN;

************************************************************************************
************************************************************************************
Step 4: List the different settings where the events have occured, and list them in
desc (greatest to least) order.;

proc freq data=WORK.Listeria order=freq;
	tables Setting / plots=(freqplot);
run;

************************************************************************************
************************************************************************************
Step 5: Recategorize the different settings to reduce overlapping and over
granulation of categories.;

proc sql;
    create table NewListeria as
    select *,
        case 
            when Setting like "Private%" then "Private_Residence"
            when Setting like "Restaurant%" then "Restaurant"
            when Setting like "Long-term%" or Setting like "Hospital%" then "Healthcare_Facility"
            when Setting like "Grocer%" then "Grocery_Store"
            when Setting like "Banque%" then "Banquet_Facility"
            else Setting
        end as New_Setting
    from work.Listeria;
quit;

************************************************************************************
************************************************************************************
Step 6: Relist the newly categorized settings;

proc freq data=WORK.NewListeria order=freq;
	tables New_Setting / plots=(freqplot);
run;

************************************************************************************
************************************************************************************
Step 7: Create frequency tables for Illnesses, Hospitalization and Deaths. Add
a title and subtitle to each table. Remove cumulative columns;

ODS noproctitle;
Title1 "Outbreak Settings Associated with Highest Number of Illnesses";
title2 "Unknown and Other settings excluded";
proc freq data= NewListeria order=freq;
	table New_Setting/nocum;
	weight illnesses;
	where New_Setting <> "Other" and New_Setting <> "Unknown";
RUN;


ODS noproctitle;
Title1 "Outbreak Settings Associated with Highest Number of Hospitalizations";
title2 "Unknown and Other settings excluded";
proc freq data= NewListeria order=freq;
	table New_Setting/nocum;
	weight hospitalizations;
	where New_Setting <> "Other" and New_Setting <> "Unknown";
RUN;


ODS noproctitle;
Title1 "Outbreak Settings Associated with Highest Number of Deaths";
title2 "Unknown and Other settings excluded";
proc freq data= NewListeria order=freq;
	table New_Setting/nocum;
	weight deaths;
	where New_Setting <> "Other" and New_Setting <> "Unknown";
RUN;
ODS reset;
Title;

************************************************************************************
************************************************************************************
Step 8: Create a bar chart that visualizes the frequency of Listeria outbreaks by 
year;

ods graphics / reset width=6.4in height=4.8in imagemap;
proc sgplot data=WORK.NewListeria;
	title height=14pt "Frequency of Listeria Outbreaks by Year";
	vbar Year / fillattrs=(color=CX9a51d5) datalabel;
	yaxis grid;
run;
ods graphics / reset;
title;

