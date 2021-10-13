
********************
***Demographics*****
********************

*hm_live Alive (1/0)
    gen hm_live = 1          
   
*hm_male Male (1/0)         
    recode hv104 (2 = 0) (9=.),gen(hm_male)  
	
*hm_age_yrs	Age in years       
    clonevar hm_age_yrs = hv105
	replace hm_age_yrs = . if inlist(hv105,98,99)
	
*hm_age_mon	Age in months (children only)
	clonevar hm_age_mon = hc1
	
	if inlist(name, "Turkey2008") {	
		drop hm_age_mon
		tempfile t1
	preserve 
		use "${SOURCE}/DHS-Turkey2008/DHS-Turkey2008birth.dta", clear	
		keep v001 v002 v003 b16 hw1 
		drop if inlist(b16,0,.)
		isid v001 v002 b16
		ren (v001 v002 b16) (hv001 hv002 hvidx)
		save `t1',replace 
	restore
		merge 1:1 hv001 hv002 hvidx using `t1'
		tab _m 
		drop _m 
		clonevar hm_age_mon = hw1
	} 	

*hm_headrel	Relationship with HH head
	clonevar hm_headrel = hv101
	replace hm_headrel = . if inlist(hm_headrel,98,99) 
	
*hm_stay Stayed in the HH the night before the survey (1/0)
    gen hm_stay = hv103 if hv103!= 9 //vary by survey, afg is missing.
	
*hm_dob	date of birth (cmc)
    clonevar hm_dob = hc32  
	
*hm_doi	date of interview (cmc)
    clonevar hm_doi = hv008

*ln	Original line number of household member
    clonevar ln = hvidx
	



