********************
*** adult***********
********************
// I use "if inlist" instead of "capture" for sys&dial, in case the variables listed in "capture" appears in other surveys but not related to BP. 

*a_inpatient	18y+ household member hospitalized, recall period as close to 12 months as possible  (1/0)
    gen a_inpatient_1y = . 
	
*a_inpatient_ref	18y+ household member hospitalized recall period (in month), as close to 12 months as possible
    gen a_inpatient_ref = . 

	if inlist(name, "Colombia2010") {
		replace a_inpatient_1y = 0
		replace a_inpatient_1y = 1 if sh78o==hvidx 
		replace a_inpatient_ref = 12
	}
	
	if inlist(name, "Honduras2005") {
		replace a_inpatient_1y = 0 
		replace a_inpatient_1y = 1 if sh63b==1 | sh90==1
		replace a_inpatient_1y = . if sh63b==9 | inlist(sh90,8,9,.)		
		replace a_inpatient_ref = 12
	}
/*		
	if inlist(name, "Mali2006") { // subsample of those who are sick during the last 30 days
		replace a_inpatient_1y = 0 
		foreach k in 1 2 3 4 5 6 {
			replace a_inpatient_1y =1 if hvidx == sh71_`k' & (sh75d_`k' == 1 | sh77d_`k' == 1)
		}
		replace a_inpatient_ref = 12
	}
*/	
	if inlist(name, "Philippines2008") {
		drop a_inpatient_1y a_inpatient_ref
		tempfile ip
		preserve 
			use "${SOURCE}/DHS-Philippines2008/DHS-Philippines2008a_inpatient_1yr.dta", clear	
			keep hv001 hv002 hv003 sampleweight a_inpatient_1yr
			ren hv003 hvidx
			gen a_inpatient_1y = a_inpatient_1yr
			gen a_inpatient_ref = 12
			save `ip'
		restore
		merge 1:1 hv001 hv002 hvidx using `ip'
		tab _m //fully merged
		drop _m 
	}

*a_bp_treat	18y + being treated for high blood pressure 
    gen a_bp_treat = . 
	
	if inlist(name, "Bangladesh2011") {
		recode sh249 sh250 (9=.)
		gen a_bp_diag=(sh249==1) if sh249!=. 
		
		replace a_bp_treat=0 if sh250!=.  
		replace a_bp_treat=1 if sh250==1 
	}
	
*a_bp_sys & a_bp_dial: 18y+ systolic & diastolic blood pressure (mmHg) in adult population 
	gen a_bp_sys = .
	gen a_bp_dial = .
		
	if inlist(name, "Bangladesh2011") {	
		drop a_bp_sys a_bp_dial
		recode sh246s sh255s sh264s sh246d sh255d sh264d  (994 995 996 998 999 =.) 
		egen a_bp_sys = rowmean(sh246s sh255s sh264s)
		egen a_bp_dial = rowmean(sh246d sh255d sh264d)
    }	

*a_hi_bp140_or_on_med	18y+ with high blood pressure or on treatment for high blood pressure	
	gen a_hi_bp140=.
    replace a_hi_bp140=1 if (a_bp_sys>=140 & a_bp_sys!=.) | (a_bp_dial>=90 & a_bp_dial!=.)
    replace a_hi_bp140=0 if a_bp_sys<140 & a_bp_dial<90 
	
	gen a_hi_bp140_or_on_med = .
	replace a_hi_bp140_or_on_med=1 if a_bp_treat==1 | a_hi_bp140==1
    replace a_hi_bp140_or_on_med=0 if a_bp_treat==0 & a_hi_bp140==0
		
*a_bp_meas				18y+ having their blood pressure measured by health professional in the last year  
    gen a_bp_meas = . 

*a_diab_treat				18y+ being treated for raised blood glucose or diabetes 
    gen a_diab_treat = .

	if inlist(name, "Bangladesh2011") {	
		gen a_diab_diag=(sh258==1)
		replace a_diab_diag=. if sh257==.|sh257==8|sh257==9|sh258==9

		replace a_diab_treat=(sh259==1)
		replace a_diab_treat=. if  sh257==.|sh257==8|sh257==9|sh259==9
    }		

	if inlist(name, "Albania2008") {	
		drop  a_bp_treat a_bp_sys a_bp_dial  a_hi_bp140 a_hi_bp140_or_on_med
		tempfile t1 t2
		preserve 
		use "${SOURCE}/DHS-Albania2008/DHS-Albania2008ind.dta", clear	
		keep v001 v002 v003 s1032a s1032c_a s1036s_1 s1036s_2 s1036s_3 s1036d_1 s1036d_2 s1036d_3 
		save `t1'	
		
		use "${SOURCE}/DHS-Albania2008/DHS-Albania2008men.dta", clear	
		keep mv001 mv002 mv003 sm832a sm832c_a sm836s_1 sm836s_2 sm836s_3 sm836d_1 sm836d_2 sm836d_3
		ren (mv001 mv002 mv003 sm832a sm832c_a sm836s_1 sm836s_2 sm836s_3 sm836d_1 sm836d_2 sm836d_3) (v001 v002 v003 s1032a s1032c_a s1036s_1 s1036s_2 s1036s_3 s1036d_1 s1036d_2 s1036d_3)
		append using `t1'
		
		recode s1036s_1 s1036s_2 s1036s_3 s1036d_1 s1036d_2 s1036d_3 (994 995 996 997 998 999 =.)
		recode s1032a s1032c_a (2 8 =.)		

		gen a_bp_diag=s1032a
		
		egen a_bp_sys = rowmean(s1036s_1 s1036s_2 s1036s_3)
		egen a_bp_dial = rowmean(s1036d_1 s1036d_2 s1036d_3)
		
		gen a_bp_treat = 0 if a_bp_diag==1
		replace a_bp_treat = 1 if s1032c_a ==1 
		replace a_bp_treat = . if (s1032c_a==. & a_bp_diag!=0) 
		
		gen a_hi_bp140=.
		replace a_hi_bp140=1 if (a_bp_sys>=140 & a_bp_sys!=.) | (a_bp_dial>=90 & a_bp_dial!=.)
		replace a_hi_bp140=0 if a_bp_sys<140 & a_bp_dial<90 
		
		gen a_hi_bp140_or_on_med = .
		replace a_hi_bp140_or_on_med=1 if a_bp_treat==1 | a_hi_bp140==1
		replace a_hi_bp140_or_on_med=0 if a_bp_treat==0 & a_hi_bp140==0	
		
		keep v001 v002 v003 a_bp_diag a_bp_treat a_bp_sys a_bp_dial a_hi_bp140 a_hi_bp140_or_on_med
		ren (v001 v002 v003) (hv001 hv002 hvidx) 
		save `t2',replace 
		restore
		
		merge 1:1 hv001 hv002 hvidx using `t2'
		tab _m // fully merged 
		drop _m 
	} 
	
	if inlist(name, "Azerbaijan2006") {	
		drop a_bp_treat a_bp_sys  a_bp_dial a_bp_meas a_hi_bp140 a_hi_bp140_or_on_med
		tempfile t1 t2
		preserve 
		use "${SOURCE}/DHS-Azerbaijan2006/DHS-Azerbaijan2006ind.dta", clear	
		keep v001 v002 v003 s101as s101ad s581as s581ad s1134as s1134ad s1017 s1019 s1020 s1025a
		save `t1'	
		
		use "${SOURCE}/DHS-Azerbaijan2006/DHS-Azerbaijan2006men.dta", clear	
		keep mv001 mv002 mv003 sm101asn sm101adn sm509asn sm509adn sm839sn sm839dn sm821 sm821b sm822 sm827a
		ren (mv001 mv002 mv003 sm101asn sm101adn sm509asn sm509adn sm839sn sm839dn sm821 sm821b sm822 sm827a) (v001 v002 v003 s101as s101ad s581as s581ad s1134as s1134ad s1017 s1019 s1020 s1025a)
		append using `t1'
		
		recode s101as s101ad s581as s581ad s1134as s1134ad  (994 995 996 997 998 999 =.)
		recode s1017 s1019 s1020 s1025a (8 9 =.)		
		
		gen a_bp_meas=(s1017 ==1 & inlist(s1019,1,2)) if s1019<8   // bp meaure recall in 1 year 

		gen a_bp_diag=s1020
		
		egen a_bp_sys = rowmean(s101as s581as s1134as)
		egen a_bp_dial = rowmean(s101ad s581ad s1134ad)
		
		gen a_bp_treat = 0 if a_bp_diag==1
		replace a_bp_treat = 1 if s1025a==1 
		replace a_bp_treat = . if (s1025a==. & a_bp_diag!=0) 
		
		gen a_hi_bp140=.
		replace a_hi_bp140=1 if (a_bp_sys>=140 & a_bp_sys!=.) | (a_bp_dial>=90 & a_bp_dial!=.)
		replace a_hi_bp140=0 if a_bp_sys<140 & a_bp_dial<90 
		
		gen a_hi_bp140_or_on_med = .
		replace a_hi_bp140_or_on_med=1 if a_bp_treat==1 | a_hi_bp140==1
		replace a_hi_bp140_or_on_med=0 if a_bp_treat==0 & a_hi_bp140==0	
		
		keep v001 v002 v003  a_bp_diag a_bp_treat a_bp_sys a_bp_dial a_hi_bp140 a_hi_bp140_or_on_med a_bp_meas 
		ren (v001 v002 v003) (hv001 hv002 hvidx) 
		save `t2',replace 
		restore
		
		merge 1:1 hv001 hv002 hvidx using `t2'
		tab _m // fully merged 
		drop _m 
	} 

	
	if inlist(name, "Lesotho2009") {	
		drop a_diab_treat a_bp_treat a_bp_sys a_bp_dial a_bp_meas  a_hi_bp140  a_hi_bp140_or_on_med
		tempfile t1 t2
		preserve 
		use "${SOURCE}/DHS-Lesotho2009/DHS-Lesotho2009ind.dta", clear	
		keep v001 v002 v003 sbp1s sbp1d sbp2s sbp2d sbp3s sbp3d s1012b s1012c s1012e s1012g s1012h s1012ia s1012ig
		recode sbp1s sbp1d sbp2s sbp2d sbp3s sbp3d  (994 995 996 997 998 999 =.)
		save `t1'	
		
		use "${SOURCE}/DHS-Lesotho2009/DHS-Lesotho2009men.dta", clear	
		keep mv001 mv002 mv003 smbp1s smbp1d smbp2s smbp2d smbp3s smbp3d sm813g sm813h sm813j sm813l sm813m sm813na sm813ng
		ren (mv001 mv002 mv003 smbp1s smbp1d smbp2s smbp2d smbp3s smbp3d sm813g sm813h sm813j sm813l sm813m sm813na sm813ng) (v001 v002 v003 sbp1s sbp1d sbp2s sbp2d sbp3s sbp3d s1012b s1012c s1012e s1012g s1012h s1012ia s1012ig)
		append using `t1'
		
		recode sbp1s sbp1d sbp2s sbp2d sbp3s sbp3d  (994 995 996 997 998 999 =.)
		recode s1012ia s1012ig (3 =.)		
		
		gen a_diab_diag = s1012b
		gen a_diab_treat = s1012c 
		
		gen a_bp_meas=(s1012e==1 & inlist(s1012g,1,2)) if s1012e<9   // bp meaure recall in 1 year 

		gen a_bp_diag=s1012h
		
		egen a_bp_sys = rowmean(sbp1s sbp2s sbp3s)
		egen a_bp_dial = rowmean(sbp1d sbp2d sbp3d)
		
		egen bptreat = rowtotal(s1012ia s1012ig),mi
		gen a_bp_treat = 0 if a_bp_diag==1
		replace a_bp_treat = 1 if bptreat>=1 & bptreat !=. 
		replace a_bp_treat = . if (bptreat==. & a_bp_diag!=0) | (s1012ia+s1012ig==. & bptreat==0 )
		
		gen a_hi_bp140=.
		replace a_hi_bp140=1 if (a_bp_sys>=140 & a_bp_sys!=.) | (a_bp_dial>=90 & a_bp_dial!=.)
		replace a_hi_bp140=0 if a_bp_sys<140 & a_bp_dial<90 
		
		gen a_hi_bp140_or_on_med = .
		replace a_hi_bp140_or_on_med=1 if a_bp_treat==1 | a_hi_bp140==1
		replace a_hi_bp140_or_on_med=0 if a_bp_treat==0 & a_hi_bp140==0	
		
		keep v001 v002 v003 a_diab_diag a_diab_treat a_bp_diag a_bp_treat a_bp_sys a_bp_dial a_bp_meas a_hi_bp140 a_hi_bp140_or_on_med
		ren (v001 v002 v003) (hv001 hv002 hvidx) 
		save `t2',replace 
		restore
		
		merge 1:1 hv001 hv002 hvidx using `t2'
		tab _m // fully merged 
		drop _m 
	} 
/*
	if inlist(name, "Maldives2009") {	
		drop a_diab_treat a_bp_treat 
		tempfile t1 t2
		preserve 
		use "${SOURCE}/DHS-Maldives2009/DHS-Maldives2009ind.dta", clear	
		keep v001 v002 v003 s1102 s1104a s1106 s1108 s1109
		save `t1'	
		
		use "${SOURCE}/DHS-Maldives2009/DHS-Maldives2009men.dta", clear	
		keep mv001 mv002 mv003 sm902 sm904a sm906 sm908 sm909
		ren (mv001 mv002 mv003 sm902 sm904a sm906 sm908 sm909) (v001 v002 v003 s1102 s1104a s1106 s1108 s1109)
		append using `t1'

		recode s1102 s1104a s1106 s1108 s1109  (3 8 9 =.)
	
		gen a_diab_diag = s1106
		egen diabtreat = rowtotal(s1108 s1109),mi

		gen a_diab_treat = 0 if a_diab_diag ==1 
		replace a_diab_treat = 1 if diabtreat>=1 & diabtreat !=. 
		replace a_diab_treat = . if (diabtreat==. & a_diab_diag!=0) | (s1108+s1109==. & diabtreat==0 )
	
		gen a_bp_diag=s1102 
		gen a_bp_treat = s1104a 
		
		keep v001 v002 v003 a_diab_diag a_diab_treat a_bp_diag a_bp_treat 
		ren (v001 v002 v003) (hv001 hv002 hvidx) 
		save `t2',replace 
		restore
		
		merge 1:1 hv001 hv002 hvidx using `t2'
		tab _m // fully merged 
		drop _m 
	} 
*/
	if inlist(name, "Ukraine2007") {	
		drop a_bp_treat a_bp_sys a_bp_dial a_bp_meas  a_hi_bp140 a_hi_bp140_or_on_med
		tempfile t1 t2
		preserve 
		use "${SOURCE}/DHS-Ukraine2007/DHS-Ukraine2007ind.dta", clear	
		keep v001 v002 v003 s1135s s1135d s1136s s1136d s1137s s1137d s1017 s1019 s1020 s1025a
		save `t1'	
		
		use "${SOURCE}/DHS-Ukraine2007/DHS-Ukraine2007men.dta", clear	
		keep mv001 mv002 mv003 sm1135s sm1135d sm1136s sm1136d sm1137s sm1137d sm814 sm816 sm817 sm822a
		ren (mv001 mv002 mv003 sm1135s sm1135d sm1136s sm1136d sm1137s sm1137d sm814 sm816 sm817 sm822a) (v001 v002 v003 s1135s s1135d s1136s s1136d s1137s s1137d s1017 s1019 s1020 s1025a)
		append using `t1'
		
		recode s1135s s1135d s1136s s1136d s1137s s1137d  (994 995 996 997 998 999 =.)
		recode s1017 s1019 s1020 s1025a (8 9 =.)	
		recode s1025a (2=.)
		
		gen a_bp_meas=(s1017==1 & inlist(s1019,1,2)) if s1017<8   // bp meaure recall in 1 year 

		gen a_bp_diag=s1020
		
		egen a_bp_sys = rowmean(s1135s s1136s s1137s)
		egen a_bp_dial = rowmean(s1135d s1136d s1137d)
		
		gen a_bp_treat = 0 if a_bp_diag==1
		replace a_bp_treat = 1 if s1025a==1 
		replace a_bp_treat = . if (s1025a==. & a_bp_diag!=0)
		
		gen a_hi_bp140=.
		replace a_hi_bp140=1 if (a_bp_sys>=140 & a_bp_sys!=.) | (a_bp_dial>=90 & a_bp_dial!=.)
		replace a_hi_bp140=0 if a_bp_sys<140 & a_bp_dial<90 
		
		gen a_hi_bp140_or_on_med = .
		replace a_hi_bp140_or_on_med=1 if a_bp_treat==1 | a_hi_bp140==1
		replace a_hi_bp140_or_on_med=0 if a_bp_treat==0 & a_hi_bp140==0	
		
		keep v001 v002 v003 a_bp_diag a_bp_treat a_bp_sys a_bp_dial a_bp_meas a_hi_bp140 a_hi_bp140_or_on_med
		ren (v001 v002 v003) (hv001 hv002 hvidx) 
		save `t2',replace 
		restore
		
		merge 1:1 hv001 hv002 hvidx using `t2'
		tab _m // fully merged 
		drop _m 
	} 

	* For Peru2012 & Honduras2005, the hv002 lost 2-3 digits, fix this issue in main.do, 1.do,4.do & 13.do
	if inlist(name,"Peru2012","Peru2013","Peru2014","Peru2015","Peru2016") | inlist(name,"Peru2017","Peru2018","Peru2019","Peru2020","Peru2021"){
		drop hv002
		gen hv002 = substr(hhid,11,5)
		isid hv000 hv001 hv002 hvidx
		order hhid hv000 hv001 hv002 hv003
		gen subid = substr(hhid,14,2)
		destring hv002,replace 
	}	
	
	if inlist(name,"Honduras2005"){
		drop hv002
		gen hv002 = substr(hhid,10,3)
		isid hv000 hv001 hv002 hvidx
		order hhid hv000 hv001 hv002 hv003
		gen subid = substr(hhid,12,1)
		destring hv002,replace 
	}
