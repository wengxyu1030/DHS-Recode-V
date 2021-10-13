
***Look for variables in dta. file under specific folder
ssc install lookfor_all

lookfor_all mammogram pap smear, subdir de vlabs filter(ind)  dir("C:\Users\Guan\OneDrive\DHS\MEASURE UHC DATA\RAW DATA\Recode V")
lookfor_all hospital inpatient admission overnight stay, subdir de vlabs filter(hm)  dir("C:\Users\Guan\OneDrive\DHS\MEASURE UHC DATA\RAW DATA\Recode V")

Use this method to search for variables:
***ind.dta: 
w_papsmear
w_mammogram 
***hm.dta: 
a_inpatient_1y (key word: inpatient, hospital, admission, overnight stay, etc.)
a_bp_treat (blood pressure)
etc.



***Different definition from DHS report, which can explain some differences in quality control file.

c_measles: For AL5, age group is 18-29. For measles vaccine only, received by 18 months of age.
Benin2006: Include m3g, trained trad. birth attend, which explains the difference in c_sba
Congo2005: Include m3d fo c_sba
Eswatini2006: c_anc difference due to missing treatment, DHS report treat DK as 0; c_anc_ir allign with the report (88.2 on p141).


