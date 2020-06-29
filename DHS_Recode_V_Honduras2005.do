////////////////////////////////////////////////////////////////////////////////////////////////////
*** DHS MONITORING: V
////////////////////////////////////////////////////////////////////////////////////////////////////

version 15.1
clear all
set matsize 3956, permanent
set more off, permanent
set maxvar 32767, permanent
capture log close
sca drop _all
matrix drop _all
macro drop _all

******************************
*** Define main root paths ***
******************************

//NOTE FOR WINDOWS USERS : use "/" instead of "\" in your paths

//global root "C:/Users/wb500886/WBG/Sven Neelsen - World Bank/MEASURE UHC DATA"
global root "C:\Users\Guan\OneDrive\DHS\MEASURE UHC DATA"

* Define path for data sources
global SOURCE "${root}/RAW DATA/Recode V"

* Define path for output data
global OUT "${root}/STATA/DATA/SC/FINAL_V"

* Define path for INTERMEDIATE
global INTER "${root}/STATA/DATA/SC/INTER_V"

* Define path for do-files
//global DO "C:\Users\wb500886\OneDrive - WBG\10_Health\UHC\GitHub\DHS-Recode-V"
global DO "${root}/STATA/DO/SC/DHS/Recode V/Git-DHS-Recode-V"


* Define the country names (in globals) in by Recode
do "${DO}/0_GLOBAL.do"
//$DHScountries_Recode_V

foreach name in Honduras2005 {	

tempfile birth ind men hm hiv hh zsc iso 

************************************
***domains using zsc data***********
************************************
capture confirm file "${SOURCE}/DHS-`name'/DHS-`name'zsc.dta"	
if _rc == 0 {
    use "${SOURCE}/DHS-`name'/DHS-`name'zsc.dta", clear
    if hwlevel == 2 {
		gen caseid = hwcaseid
		gen bidx = hwline   	  
		merge 1:1 caseid bidx using "${SOURCE}/DHS-`name'/DHS-`name'birth.dta"
    	gen ant_sampleweight = v005/10e6  
    	drop if _!=3
		
  		foreach var in hc70 hc71 {
  	 	replace `var'=. if `var'>900
  	 	replace `var'=`var'/100
  		}
  		replace hc70=. if hc70<-6 | hc70>6
  		replace hc71=. if hc71<-6 | hc71>5
 		gen c_stunted=1 if hc70<-2
 		replace c_stunted=0 if hc70>=-2 & hc70!=.
 		gen c_underweight=1 if hc71<-2
 		replace c_underweight=0 if hc71>=-2 & hc71!=.
		
		rename ant_sampleweight c_ant_sampleweight
		keep c_* caseid bidx hwlevel hc70 hc71
		save "${INTER}/zsc_birth.dta",replace
    }

 	if hwlevel == 1 {
 		use "${SOURCE}/DHS-`name'/DHS-`name'zsc.dta", clear
 		gen hhid = hwhhid
 		gen hvidx = hwline
 		merge 1:1 hhid hvidx using "${SOURCE}/DHS-`name'/DHS-`name'hm.dta", keepusing(hv103 hv001 hv002 hv005)
 		drop if hv103==0
 		gen ant_sampleweight = hv005/10e6
 		drop if _!=3
		gen ant_hm = 1
		
  		foreach var in hc70 hc71 {
  	 	replace `var'=. if `var'>900
  	 	replace `var'=`var'/100
  		}
  		replace hc70=. if hc70<-6 | hc70>6
  		replace hc71=. if hc71<-6 | hc71>5
 		gen c_stunted=1 if hc70<-2
 		replace c_stunted=0 if hc70>=-2 & hc70!=.
 		gen c_underweight=1 if hc71<-2
 		replace c_underweight=0 if hc71>=-2 & hc71!=.
	    
		rename ant_sampleweight c_ant_sampleweight
		keep c_* hhid hvidx hc70 hc71
		save "${INTER}/zsc_hm.dta",replace
    }

 }
 
******************************
*****domains using birth data*
******************************
use "${SOURCE}/DHS-`name'/DHS-`name'birth.dta", clear	

    gen hm_age_mon = (v008 - b3)           //hm_age_mon Age in months (children only)
    gen name = "`name'"
	
    do "${DO}/1_antenatal_care"
    do "${DO}/2_delivery_care"
    do "${DO}/3_postnatal_care"
    do "${DO}/7_child_vaccination"
    do "${DO}/8_child_illness"
    do "${DO}/10_child_mortality"
    do "${DO}/11_child_other"
	
	capture confirm file "${INTER}/zsc_birth.dta"
	if _rc == 0 {
	merge 1:1 caseid bidx using "${INTER}/zsc_birth.dta"
    }
	
*housekeeping for birthdata
   //generate the demographics for child who are dead or no longer living in the hh. 
   
    *hm_live Alive (1/0)
    recode b5 (1=0)(0=1) , ge(hm_live)   
	label var hm_live "died" 
	label define yesno 0 "No" 1 "Yes"
	label values hm_live yesno 

    *hm_dob	date of birth (cmc)
    gen hm_dob = b3  

    *hm_age_yrs	Age in years       
    gen hm_age_yrs = b8        

    *hm_male Male (1/0)         
    recode b4 (2 = 0),gen(hm_male)  
	
    *hm_doi	date of interview (cmc)
    gen hm_doi = v008

rename (caseid v001 v002 b16) (hhid hv001 hv002 hvidx)
keep hhid hv001 hv002 hvidx bidx c_* mor_* w_* hm_* 
save `birth'


******************************
*****domains using ind data***
******************************
use "${SOURCE}/DHS-`name'/DHS-`name'ind.dta", clear	
gen name = "`name'"
gen hm_age_yrs = v012
    do "${DO}/4_sexual_health"
    do "${DO}/5_woman_anthropometrics"
    do "${DO}/16_woman_cancer"
*housekeeping for ind data

    *hm_dob	date of birth (cmc)
    gen hm_dob = v011  
	
	
keep caseid v001 v002 v003 w_* hm_*
rename (caseid v001 v002 v003) (hhid hv001 hv002 hvidx)
save `ind' 


************************************
*****domains using hm level data****
************************************
use "${SOURCE}/DHS-`name'/DHS-`name'hm.dta", clear
gen name = "`name'"
    do "${DO}/13_adult"
    do "${DO}/14_demographics"

capture confirm file "${INTER}/zsc_hm.dta"	
	if _rc == 0 {
	merge 1:1 hhid hvidx using "${INTER}/zsc_hm.dta",nogen
	rename (hc70 hc71) (hm_hc70 hm_hc71)
	}
	if _rc != 0 {
	  capture confirm file "${INTER}/zsc_birth.dta"
	    if _rc != 0 {
          do "${DO}/9_child_anthropometrics"  //if there's no zsc related file, then run 9_child_anthropometrics
	      rename ant_sampleweight c_ant_sampleweight
		}
    }	
gen c_placeholder = 1
keep hhid hv001 hv002 hvidx hc70 hc71 ///
c_* a_* hm_* ln 
save `hm'

capture confirm file "${SOURCE}/DHS-`name'/DHS-`name'hiv.dta"
 	if _rc==0 {
    use "${SOURCE}/DHS-`name'/DHS-`name'hiv.dta", clear
    do "${DO}/12_hiv"
 	}
 	if _rc!= 0 {
    gen a_hiv = . 
    gen a_hiv_sampleweight = .
    }  
keep a_hiv* hv001 hv002 hvidx hhid
save `hiv'

use `hm',clear
merge 1:1 hhid hv001 hv002 hvidx using `hiv'
drop _merge
save `hm',replace

************************************
*****domains using hh level data****
************************************
use "${SOURCE}/DHS-`name'/DHS-`name'hm.dta", clear
    rename (hhid hv001 hv002 hvidx) (caseid v001 v002 v003)

    merge 1:m caseid v001 v002 v003 using "${SOURCE}/DHS-`name'/DHS-`name'birth.dta"
    rename (caseid v001 v002 v003) (hhid hv001 hv002 hvidx) 
    drop _merge

    do "${DO}/15_household"

keep hv001 hv002 hv003 hh_* hhid
save `hh' 


************************************
*****merge to microdata*************
************************************

***match with external iso data
use "${SOURCE}/external/iso", clear 
keep country iso2c iso3c
replace country = "Congodr"  if country == "Congo, the Democratic Republic of the"
replace country = "DominicanRepublic"  if country == "Dominican Republic"

save `iso'

***merge all subset of microdata
use `hm',clear

    merge 1:m hhid hv001 hv002 hvidx using `birth',update             //missing update is zero, non missing conflict for all matched.(hvidx different) 

	//bysort hv001 hv002: egen min = min(w_sampleweight)
	//replace w_sampleweight = min if w_sampleweight ==.
    replace hm_headrel = 99 if _merge == 2
	label define hm_headrel_lab 99 "dead/no longer in the household"
	label values hm_headrel hm_headrel_lab
	replace hm_live = 0 if _merge == 2 | inlist(hm_headrel,.,12,98)
	drop _merge
    merge m:m hhid hv001 hv002 hvidx using `ind',nogen update
	merge m:m  hv001 hv002       using `hh',nogen update

capture confirm variable c_hc70 c_hc71 
if _rc == 0 {
rename (c_hc70 c_hc71 ) (hc70 hc71 )
}

capture confirm variable hm_hc70 hm_hc71 
if _rc == 0 {
rename (hm_hc70 hm_hc71 ) (hc70 hc71 )
}
  
	rename c_ant_sampleweight ant_sampleweight
	drop c_placeholder
    tab hh_urban,mi  //check whether all hh member + dead child + child lives outside hh assinged hh info

***survey level data
    gen survey = "DHS-`name'"
	gen year = real(substr("`name'",-4,.))
	tostring(year),replace
    gen country = regexs(0) if regexm("`name'","([a-zA-Z]+)")
	
    merge m:1 country using `iso',force
    drop if _merge == 2
	drop _merge

*** Quality Control: Validate with DHS official data
gen surveyid = iso2c+year+"DHS"
gen name = "`name'"
	if inlist(name,"Eswatini2006") {
		replace surveyid = "SZ2006DHS"
	}

preserve
	do "${DO}/Quality_control"
	save "${INTER}/quality_control-`name'",replace
	cd "${INTER}"
	do "${DO}/Quality_control_result"
	save "${OUT}/quality_control",replace 
    restore 


	
*** Specify sample size to HEFPI
	
    ***for variables generated from 1_antenatal_care 2_delivery_care 3_postnatal_care
	foreach var of var c_anc	c_anc_any	c_anc_bp	c_anc_bp_q	c_anc_bs	c_anc_bs_q ///
	c_anc_ear	c_anc_ear_q	c_anc_eff	c_anc_eff_q	c_anc_eff2	c_anc_eff2_q ///
	c_anc_eff3	c_anc_eff3_q	c_anc_ir	c_anc_ir_q	c_anc_ski	c_anc_ski_q ///
	c_anc_tet	c_anc_tet_q	c_anc_ur	c_anc_ur_q	c_caesarean	c_earlybreast ///
	c_facdel	c_hospdel	c_sba	c_sba_eff1	c_sba_eff1_q	c_sba_eff2 ///
	c_sba_eff2_q	c_sba_q	c_skin2skin	c_pnc_any	c_pnc_eff	c_pnc_eff_q c_pnc_eff2	c_pnc_eff2_q {
    replace `var' = . if !(inrange(hm_age_mon,0,23)& bidx ==1)
    }
	
	***for variables generated from 7_child_vaccination
	foreach var of var c_bcg c_dpt1 c_dpt2 c_dpt3 c_fullimm c_measles ///
	c_polio1 c_polio2 c_polio3{
    replace `var' = . if !inrange(hm_age_mon,15,23)
    }
	
	***for variables generated from 8_child_illness	
	foreach var of var c_ari c_ari2	c_diarrhea 	c_diarrhea_hmf	c_diarrhea_medfor	c_diarrhea_mof	c_diarrhea_pro	c_diarrheaact ///
	c_diarrheaact_q	c_fever	c_fevertreat	c_illness	c_illtreat	c_sevdiarrhea	c_sevdiarrheatreat ///
	c_sevdiarrheatreat_q	c_treatARI c_treatARI2	c_treatdiarrhea	c_diarrhea_med {
    replace `var' = . if !inrange(hm_age_mon,0,59)
    }
	
	***for vriables generated from 9_child_anthropometrics
	foreach var of var c_underweight c_stunted	hc70 hc71 ant_sampleweight{
    replace `var' = . if !inrange(hm_age_mon,0,59)
    }
	
	***for hive indicators from 12_hiv
	foreach var of var a_hiv*{
	replace `var'=. if hm_age_yrs<15 | (hm_age_yrs>49 & hm_age_yrs!=.)
    }	
	
	***for hive indicators from 13_adult
	foreach var of var a_diab_treat	a_inpatient_1y a_bp_treat a_bp_sys a_bp_dial a_hi_bp140_or_on_med a_bp_meas{
    replace `var'=. if hm_age_yrs<18
    }
	
*** Label variables
    drop bidx surveyid
    do "${DO}/Label_var" 
	
*** Clean the intermediate data
    capture confirm file "${INTER}/zsc_birth.dta"
    if _rc == 0 {
    erase "${INTER}/zsc_birth.dta"
    }	
    
	capture confirm file"${INTER}/zsc_hm.dta"
    if _rc == 0 {
    erase "${INTER}/zsc_hm.dta"
    }	

	
save "${OUT}/DHS-`name'.dta", replace  
}




