
************************
*** Sexual health*******
************************ 	

	gen w_married=(v502==1)
	replace w_married=. if v502==.
	
	*w_condom_conc: 18-49y woman who had more than one sexual partner in the last 12 months and used a condom during last intercourse
     ** Concurrent partnerships 
	replace v766b=. if v766b==98|v766b==99
	gen wconc_partnerships=1 if v766b>1&v766b!=.
	replace wconc_partnerships=0 if v766b==0|v766b==1

     ** Condom usage
	rename v761 wcondom
		replace wcondom=. if wcondom==8|wcondom==9
		replace wcondom=. if v766b==0 | v766b==.
		
	gen w_condom_conc=1 if wcondom==1&wconc_partnerships==1
    replace w_condom_conc=0 if wcondom==0&wconc_partnerships==1
	
    /*18-49y woman who had more than one sexual partner in the last 12 months and used a condom during last intercourse*/
    cap confirm variable w_condom_conc
    if _rc==0 {
    replace w_condom_conc=. if hm_age_yrs<18
    }

	*w_CPR: Use of modern contraceptive methods of women age 15(!)-49 married or living in union
	gen w_CPR=(v313==3)
    replace w_CPR=. if v313==.
    replace w_CPR=. if w_married!=1
	
	*w_unmet_fp 15-49y married or in union with unmet need for family planning (1/0)
	*w_need_fp 15-49y married or in union with need for family planning (1/0)
	*w_metany_fp 15-49y married or in union with need for family planning using modern contraceptives (1/0)
	*w_metmod_fp 15-49y married or in union with need for family planning using any contraceptives (1/0)
	
	 tempfile temp1 temp2 temp3
	 
	 if inlist(name,"Peru2018") {
		cap gen v007 = 2018
	 }
	 
	 preserve
     do "${DO}/Add unmetFP_DHS.do"
	 gen w_metany_fp = 1 if inlist(unmet,3,4)
     replace w_metany_fp = 0 if inlist(unmet,1,2) 
     keep caseid w_unmet_fp w_metany_fp
	 
     save `temp1'
	 restore
	 
	 preserve
	 do "${DO}/Add unmetFPmod_DHS.do"
     gen w_metmod_fp = 1 if inlist(unmet,3,4)
     replace w_metmod_fp = 0 if inlist(unmet,1,2)
	 
	 gen w_need_fp = 1 if w_metmod_fp!=.
     replace w_need_fp = 0 if inlist(unmet,7,9)
	 
     keep w_metmod_fp  w_need_fp w_metmod_fp caseid
	 save `temp2'
	 
	 merge 1:1 caseid using `temp1'
	 drop _merge
	 save `temp3'
	 restore 
	 
	 merge 1:m caseid using `temp3'
     drop if _m == 1
    
	replace w_metany_fp = . if w_married!=1
	replace w_metmod_fp = . if w_married!=1
	replace w_need_fp = . if w_married!=1
	replace w_unmet_fp = . if w_married!=1
	
    *w_metany_fp_q 15-49y married or in union using modern contraceptives among those with need for family planning who use any contraceptives (1/0)
    gen w_metany_fp_q = (w_CPR == 1) if w_need_fp == 1 
	 
	* For Peru2012, the v002 lost 2-3 digits, fix this issue in main.do, 1.do,4.do,12.do & 13.do
	if inlist(name,"Peru2012","Peru2013","Peru2014","Peru2015") | inlist(name,"Peru2016","Peru2017","Peru2018","Peru2019","Peru2020","Peru2021"){
		* DW : Peru2013 misses observations for v001/002/003
		if inlist(name,"Peru2013") {
			rename (v001 v003) (v001orig v003orig)
			gen v001 = substr(caseid,4,7)
			destring v001,replace
			gen v003 = substr(caseid,16,3)
			destring v003,replace

		}
	
		drop v002
		gen v002 = substr(caseid,11,5)
		gen subid = substr(caseid,14,2)
		isid  v001 v002 v003
		order caseid v000 v001 v002 v003
		destring v002,replace
	}	


	if inlist(name,"Honduras2005"){
		drop v002
		gen v002 = substr(caseid,10,3)
		gen subid = substr(caseid,12,1)
		isid  v001 v002 v003
		order caseid v000 v001 v002 v003
		destring v002,replace
	}	
	
