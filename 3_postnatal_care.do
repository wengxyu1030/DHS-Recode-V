
******************************
***Postnatal Care************* 
****************************** 

    *c_pnc_skill: m52,m72 by var label text. (m52 is added in Recode VI.
	//gen m52_skill = 0 if m51a != .   //using m51a (Time after the delivery for the respondent to receive a checkup) as filter question. However no info on who checked (unless at home m68)
	*c_pnc_any : mother OR child receive PNC in first six weeks by skilled health worker	
	
	foreach var of varlist m64 m68 m72 {
		local s=substr("`var'",-2,.)
		local t=`s'-2
		gen `var'_skill =0 if !mi(`var')|!inlist(m`t',0,1)

		cap decode `var', gen(`var'_lab)
		if !_rc {
			replace `var'_lab = lower(`var'_lab )
			replace  `var'_skill= 1 if ///
			(regexm(`var'_lab,"doctor|nurse|midwife|mifwife|aide soignante|assistante accoucheuse|clinical officer|pediatriacian|mch aide|midwile|matrone/|trained|rescuer|auxiliary birth attendant|physician assistant|professional|ferdsher|feldshare|lady health worker|skilled|community health care proVIder|birth attendant|hospital/health center worker|hew|auxiliary|icds|feldsher|mch|vhw|health team|health personnel|gynecolog(ist|y)|obstetrician|internist|pediatrician|family welfare visitor|medical assistant|health assistant|matron|general practitioner|health officer|extension|ob-gy") ///	
			&!regexm(`var'_lab,"na^|-na|traditional birth attendant|traditional midwife|vhw|untrained|unqualified|Matrone |empirical midwife|box|other|obstetrician|health assistant|health fieldworker|health worker") | (regexm(`var'_lab,"trained traditional|traditional birth attendant ") & !regexm(`var'_lab,"untrained|not train")) | regexm(`var'_lab,"matron with |gynecology/ obstetrician") | (regexm(`var'_lab,"doctor|health personnel|health professional") & regexm(`var'_lab,"other")))
			replace `var'_skill = . if mi(`var') | `var' == 99 | mi(`var'_lab) |`var' == 98
		}
	}

	/* consider as skilled if contain words in the first group but don't contain any words in the second group */
	// survey that child pnc is collected only if mother delivered at home or other facility
	gen c_pnc_any = .
	// survey that child pnc is collected from the whole sample 
	if inlist(name,"Bolivia2008","Cambodia2010","Egypt2008","Lesotho2009","Turkey2008") | inlist(name, "Peru2004","Peru2007","Peru2009","Peru20010","Peru2011","Peru2012","Peru2013") | inlist(name,"Peru2014","Peru2015","Peru2016","Peru2017","Peru2018","Peru2019","Peru2020","Peru2021") {	
		replace c_pnc_any = 0 if m62 != . | m66 != . | m70 != .
		replace c_pnc_any = 1 if ((m63 <= 242 | inrange(m63,301,306) | m63 == 299 ) & m64_skill == 1 ) | ((m67 <= 242 | inrange(m67,301,306) | m67 == 299 ) & m68_skill == 1 ) | ((m71 <= 242 | inrange(m71,301,306) | m71 == 299 ) & m72_skill == 1 )
		replace c_pnc_any = . if (((inlist(m63,399,995,998,999)|m64_skill ==.) & m62 !=0) & ((inlist(m67,399,995,998,999)|m68_skill ==.) & m66 !=0)) | ((inlist(m71,399,995,998,999)|m72_skill ==.) & m70 !=0) | inlist(m62,8,9)|inlist(m66,8,9)|inlist(m70,8,9)
	}
	*c_pnc_eff: mother AND child in first 24h by skilled health worker
	// survey that child pnc is collected only if mother delivered at home or other facility
	gen c_pnc_eff = . 
	/*
	gen c_pnc_eff = .
		replace c_pnc_eff = 0 if m62 != . | m66 != . | m70 != .
		replace c_pnc_eff = 1 if (((inrange(m63,100,124) | m63 == 201| m63 == 199 ) & m64_skill == 1) | ((inrange(m67,100,124) | m67 == 201| m67 == 199) & m68_skill == 1)) & ((inrange(m71,100,124) | m71 == 201| m71 == 199) & m72_skill == 1) 
		replace c_pnc_eff = . if ((inlist(m67,.,299,399,995,998,999)|m68_skill ==.) & m66 !=0) | ((inlist(m71,.,299,399,995,998,999)|m72_skill ==.) & m70 !=0)| inlist(m62,8,9) | inlist(m66,8,9) | inlist(m70,8,9)
	*/
	
	// survey that child pnc is collected from the whole sample 
	if inlist(name,"Bolivia2008","Cambodia2010","Egypt2008","Lesotho2009","Turkey2008") | inlist(name, "Peru2004","Peru2007","Peru2009","Peru2010","Peru2011","Peru2012","Peru2013","Peru2014") | inlist(name,"Peru2015","Peru2016","Peru2017","Peru2018","Peru2019","Peru2020","Peru2021") {	
	drop c_pnc_eff
	replace m62=0 if  m62 ==. & inlist(m15,11,12,96)       // for mother deliver at home/other facility, their pnc info. are record in m66-m68, and m62 m63 m64 are skipped. recode m62=0 if mother deliver at home
	replace m66=0 if  m66 ==. & !inlist(m15,11,12,96,98,99,.) // vice versa
	gen c_pnc_eff = .
		replace c_pnc_eff = 0 if m62 != . | m66 != . | m70 != .
		replace c_pnc_eff = 1 if (((inrange(m63,100,124) | m63 == 201| m63 == 199 ) & m64_skill == 1) | ((inrange(m67,100,124) | m67 == 201| m67 == 199) & m68_skill == 1)) & ((inrange(m71,100,124) | m71 == 201| m71 == 199) & m72_skill == 1) 		
		replace c_pnc_eff = . if (((inlist(m63,.,299,399,995,998,999)|m64_skill ==.) & m62 !=0) | ((inlist(m67,.,299,399,995,998,999)|m68_skill ==.) & m66 !=0)) | ((inlist(m71,.,299,399,995,998,999)|m72_skill ==.) & m70 !=0)| inlist(m62,8,9) | inlist(m66,8,9) | inlist(m70,8,9)
	}	

	/*
	
	gen m72_skill = 0 if !inlist(m70,0,1) 
	
	foreach var of varlist /* m52 */ m72 {
    decode `var', gen(`var'_lab)
	replace `var'_lab = lower(`var'_lab )
	replace  `var'_skill= 1 if ///
	(regexm(`var'_lab,"doctor|nurse|midwife|aide soignante|assistante accoucheuse|clinical officer|mch aide|trained|auxiliary birth attendant|physician assistant|professional|ferdsher|skilled|community health care provider|birth attendant|hospital/health center worker|hew|auxiliary|icds|feldsher|mch|vhw|village health team|health personnel|gynecolog(ist|y)|obstetrician|internist|pediatrician|family welfare visitor|medical assistant|health assistant") ///
	&!regexm(`var'_lab,"na^|-na|traditional birth attendant|untrained|unquallified|empirical midwife|other")) 
	replace `var'_skill = . if mi(`var') | `var' == 99
	}
	/* consider as skilled if contain words in 
	   the first group but don't contain any words in the second group */
	
	
	*c_pnc_any : mother OR child receive PNC in first six weeks by skilled health worker  //to be decided whether to keep? because m52_skill is missing. 
    gen c_pnc_any = 0 if !mi(m70) & !mi(m51a)  
    replace c_pnc_any = 1 if (m71 <= 306 & m72_skill == 1 ) | (m51a <= 306 /* & m52_skill == 1 */)
    replace c_pnc_any = . if inlist(m71,199,299,399,998)| inlist(m51a,998)| m72_skill == . /* | m52_skill == . */

	
	*c_pnc_eff: mother AND child in first 24h by skilled health worker	
	gen c_pnc_eff = .
	replace c_pnc_eff = 0 if m51a != . | /* m52_skill != . | */ m71 != . | m72_skill != .   
    replace c_pnc_eff = 1 if ((inrange(m51a,100,124) | m51a == 201 ) /* & m52_skill == 1 */) & ((inrange(m71,100,124) | m71 == 201) & m72_skill == 1 )
    replace c_pnc_eff = . if inlist(m51a,199,299,399,998) | /* m52_skill == . | */ inlist(m71,199,299,399,998) | m72_skill == .              
	*/
	
	
	*c_pnc_eff_q: mother AND child in first 24h by skilled health worker among those with any PNC
	gen c_pnc_eff_q = c_pnc_eff if c_pnc_any == 1
	
	*c_pnc_eff2: mother AND child in first 24h by skilled health worker and cord check, temperature check and breastfeeding counselling within first two days	
	gen c_pnc_eff2 = . 
	
	capture confirm variable m78a m78b m78d                            //m78* only available for Recode VII
	if _rc == 0 {
	egen check = rowtotal(m78a m78b m78d),mi
	replace c_pnc_eff2 = c_pnc_eff
	replace c_pnc_eff2 = 0 if check != 3
	replace c_pnc_eff2 = . if c_pnc_eff == . 
	}
	
	*c_pnc_eff2_q: mother AND child in first 24h weeks by skilled health worker and cord check, temperature check and breastfeeding counselling within first two days among those with any PNC
	gen c_pnc_eff2_q = c_pnc_eff2 if c_pnc_any ==1					  


