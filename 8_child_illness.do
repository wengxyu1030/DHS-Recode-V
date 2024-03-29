
**************************
*** Child illness ********
**************************   
	   	
/* 
Note: for phase 6: V000 = AM6 CG6 KE6, use the old code for formal provider for ARI and Diarrhea.
Because the for the formal provider, the information can not be captured from the variable label, but only 
from the report/survey, which presented in the adeptfile. 
 */


rename *,lower   //make lables all lowercase. 
order *,sequential  //make sure variables are in order. 

*c_diarrhea Child with diarrhea in last 2 weeks
		if inlist(name,"Turkey2008"){
			replace h11 = s476a 
		}

	    gen c_diarrhea=(h11   ==1|h11   ==2) 						/*symptoms in last two weeks*/ 
		replace c_diarrhea=. if h11   ==8|h11  ==9|h11  ==. 
					 
		gen ccough=(h31  ==1|h31  ==2) 
		replace ccough=. if h31  ==8|h31  ==9|h31  ==. 
					  
*c_treatdiarrhea Child with diarrhea receive oral rehydration salts (ORS)
		cap gen h13b  =. 
		gen c_treatdiarrhea=(h13  ==1|h13  ==2|h13b  ==1) 	if c_diarrhea == 1							/*ORS for diarrhea*/
		replace c_treatdiarrhea=. if (h13  ==8|h13  ==9 | h13  ==.)&(h13b  ==8|h13b  ==9 | h13b  ==.) 
		
*c_diarrhea_hmf	Child with diarrhea received recommended home-made fluids
		if inlist(name,"Turkey2008"){
			replace h14 = s481b
		}			
        gen c_diarrhea_hmf=(h14  ==1|h14  ==2) if c_diarrhea == 1			/* home made fluid for diarrhea*/
		replace c_diarrhea_hmf=. if  h14  ==8|h14  ==9 |h14  ==.		
		
*c_diarrhea_pro	The treatment was provided by a formal provider (all public provider except other public, pharmacy, and private sector)
       /*please cross check as there might be case where the diarreha treatment provider is not in h12a-h12x*/
	    order h12a-h12x,sequential
	    foreach var of varlist h12a-h12x {
	    local lab: variable label `var' 	   
        replace `var' = . if ///
	    (regexm("`lab'","( other|shop|Shop|store|Store|chemist/ PMS|private dispensary|chemist/ pms|hsa|oth.priv sect|cs med.priv sector|oth.priv sect (ngo)|mobile seller|Dumba Nengue|Market|pharmacy|market|Pharmacy|at home|kiosk|hakim|DAI-TBA|Traditional Practitioner|dispenser/compounder|Street|other public -|other private -|other -|Diarrhea: CS public sector|Diarrhea: CS private medical|Traditional practitioner|Relatives|diarrhea: cs private medical|volunteer|merchant|relative|Other|friend|church|Church|drug|addo|rescuer|trad|unqualified|stand|cabinet|ayush|^na|-na|na-|NA-|NA -|na -|na -|diarrhea: cs public sector)") ///
	    & !regexm("`lab'","(ngo|hospital|medical center|worker|women|bhu/fwc|maternity house|mchfp center|(sisca post)|pvt clinic|pvt nurse/midwife|cabinet|rescuer|national|(fap/dac/ph)|gov. family planning center/cabi|private policlinic/ woman's co|private family planning center|policlinic/ woman's consultation|cnss|NGO med.|health stand|moving|cs other public facility)")) & !regexm("`lab'", "( lay)")
	    replace `var' = . if !inlist(`var',0,1) 
	    }
	   /* do not consider formal if contain words in 
	   the first group but don't contain any words in the second group */
		if inlist(name,"Azerbaijan2006","TimorLeste2009") {
			replace h12u =. // fever/cough: cs oth.priv sect (ngo)
			replace h32u =.
		}

	    egen pro_dia = rowtotal(h12a-h12x),mi

        gen c_diarrhea_pro = 0 if c_diarrhea == 1
        replace c_diarrhea_pro = 1 if c_diarrhea_pro == 0 & pro_dia >= 1 
        replace c_diarrhea_pro = . if pro_dia == . 	
	   
	   /*for countries below there are categories that identified as formal 
	   provider but not shown in the label*/
	    if inlist(name,"Senegal2014","Senegal2012","Senegal2015"){
			foreach x in a b c d e g h j l m n p q {
            replace c_diarrhea_pro=1 if c_diarrhea==1 & h12`x'==1
            replace c_diarrhea_pro=. if c_diarrhea==1 & h12`x'==9			
			}
		}
			
	    if inlist(name,"Senegal2010") {
 			foreach x in a b c d e j l m n {
            replace c_diarrhea_pro=1 if c_diarrhea==1 & h12`x'==1
            replace c_diarrhea_pro=. if c_diarrhea==1 & h12`x'==9			
			}
		}		
		
*c_diarrhea_mof	Child with diarrhea received more fluids
        gen c_diarrhea_mof = (h38 == 5) if !inlist(h38,.,8,9) & c_diarrhea == 1

*c_diarrhea_medfor Get formal medicine except (ors hmf home other_med, country specific). 
        egen medfor = rowtotal(h12z h15 h15a h15b h15c h15e h15g h15h h15i),mi
		gen c_diarrhea_medfor = ( medfor > = 1 ) if c_diarrhea == 1 & medfor!=.
		// formal medicine don't include "home remedy, herbal medicine and other"
        replace c_diarrhea_medfor = . if inlist(h12z,8,9) |inlist(h15,8,9)|inlist(h15a,8,9)|inlist(h15b,8,9)|inlist(h15c,8,9)|inlist(h15e,8,9)|inlist(h15g,8,9)|inlist(h15h,8,9)|inlist(h15i,8,9)|inlist(h15j,8,9)

*c_diarrhea_med	Child with diarrhea received any medicine other than ORS or hmf (country specific)
        egen med = rowtotal(h12z h15 h15a h15b h15c h15d h15e h15f h15g h15h h15i h15j),mi
        gen c_diarrhea_med = ( med > = 1 ) if c_diarrhea == 1 & med!=.
        replace c_diarrhea_med = . if inlist(h12z,8,9) |inlist(h15,8,9)|inlist(h15a,8,9)|inlist(h15b,8,9)|inlist(h15c,8,9)|inlist(h15d,8,9)|inlist(h15e,8,9)|inlist(h15f,8,9)|inlist(h15g,8,9)|inlist(h15h,8,9)|inlist(h15i,8,9)|inlist(h15j,8,9)
		
*c_diarrheaact	Child with diarrhea seen by provider OR given any form of formal treatment
        gen c_diarrheaact = (c_diarrhea_pro==1 | c_diarrhea_medfor==1 | c_diarrhea_hmf==1 | c_treatdiarrhea==1) if c_diarrhea == 1
		replace c_diarrheaact = . if (c_diarrhea_pro == . | c_diarrhea_medfor == . | c_diarrhea_hmf == . | c_treatdiarrhea == .) & c_diarrhea == 1		
					 					
*c_diarrheaact_q	Child with diarrhea who received any treatment or consultation and received ORS
        gen c_diarrheaact_q = c_treatdiarrhea  if c_diarrheaact == 1
        replace c_diarrheaact_q = . if  c_treatdiarrhea == .
		
*c_fever	Child with a fever in last two weeks
        gen c_fever = (h22 == 1) if !inlist(h22,.,8,9)
		
*c_sevdiarrhea	Child with severe diarrhea
		gen eat = (inlist(h39,0,1,2)) if !inlist(h39,.,8,9) & c_diarrhea == 1
        gen c_sevdiarrhea = (c_diarrhea==1 & (c_fever == 1 | c_diarrhea_mof == 1 | eat == 1)) 
		replace c_sevdiarrhea = . if c_diarrhea == . | c_fever == . | (c_diarrhea == 1 & (c_diarrhea_mof ==.| eat==.))
		/* diarrhea in last 2 weeks AND any of the following three conditions: fever OR offered 
		more than usual to drink OR given much less or nothing to eat or stopped eating */
		
*c_sevdiarrheatreat	Child with severe diarrhea seen by formal healthcare provider
        gen c_sevdiarrheatreat = (c_sevdiarrhea == 1 & c_diarrhea_pro == 1) if c_diarrhea == 1
		replace c_sevdiarrheatreat = . if c_sevdiarrhea == . | c_diarrhea_pro == .
		
*c_sevdiarrheatreat_q	IV (intravenous) treatment of severe diarrhea among children with any formal provider visits
        gen iv = (h15c == 1) if !inlist(h15c,.,8,9) & c_diarrhea == 1
		gen c_sevdiarrheatreat_q = (iv ==1 ) if c_sevdiarrheatreat == 1
		
*c_ari	Child with acute respiratory infection (ARI)	
        gen c_ari = . 
		replace c_ari = 0 if ccough != .
		replace c_ari = 1 if h31b == 1 & ccough == 1 & inlist(h31c,1,3)
		replace c_ari = . if inlist(h31b,8,9) | inlist(h31c,8,9)	
		replace c_ari = . if (ccough==1 & h31b ==.) | (h31b ==1 & h31c ==.)
		
*DW July 2022 - added Benin2006, COD2007, COG2005, Indonesia2007, Mali2006
		if inlist(name,"Bolivia2008","Niger2006","Benin2006","Congodr2007","Congorep2005","Indonesia2007","Mali2006"){
			replace c_ari = .
		}
		
		/* Children under 5 with cough and rapid breathing in the 
		two weeks preceding the survey which originated from the chest. */
		
		gen c_ari2 = 0 if ccough != .
		replace c_ari2 = 1 if h31b == 1 & ccough == 1
		replace c_ari2 = . if inlist(h31b,8,9)
		replace c_ari2 = . if ccough==1 & h31b == .
	
		/* Children under 5 with cough and rapid breathing in the 
		two weeks preceding the survey. */
	
		
 
*c_treatARI	Child with acute respiratory infection (ARI) symptoms seen by formal provider
	    /*please cross check as there might be case where the treatment provider is not in h32a-h32x*/
     	gen c_treatARI= 0 if c_ari == 1
        gen c_treatARI2= 0 if c_ari2 == 1	
		
		if inlist(name,"Benin2006") {
			drop h32u //fever/cough: bar ("bar / buvette"), will stop the progress, have to drop 
		}	 
	    
		order h32a-h32x,sequential
if ~inlist(name,"Bolivia2008") {		
	    foreach var of varlist h32a-h32x {
	    local lab: variable label `var' 
        replace `var' = . if ///
		(regexm("`lab'","( other| oth |shop|pharmacy|Shop|store|private dispensary|chemist/pms|oth.priv sect|mobile sales|cs med.priv sect|oth.priv sect (ngo)|hsa|Store|Dumba Nengue|chemist/ PMS|Market|pharmacy|market|Pharmacy|at home|kiosk|hakim|DAI - TBA|Traditional Practitioner|dispenser/compounder|Street|other public -|other private -|other -|Fever/cough: CS public sector|Fever/cough: CS private medical|Traditional practitioner|Relatives|fever/cough: cs private medical|volunteer|merchant|market|kiosk|relative|friend|Other|church|drug|addo|rescuer|trad|unqualified|stand|cabinet|ayush|^na|-na|na-|NA-|na -|NA -|fever/cough: cs public sector)") ///
	    & !regexm("`lab'","(ngo|hospital|medical center|worker|women|bhu/fwc|cabinet|rescuer|national|(sisca post)|policlinic/ woman's consultat|(fap/dac/ph)|private family planning cente|private policlinic/ woman's c|gov. family planning center/c|private policlinic/ woman's co|cnss|NGO med.|health stand|moving|other public facility)")) & !regexm("`lab'", "( lay)")  
		replace `var' = . if !inlist(`var',0,1) 
	    }
	    /* do not consider formal if contain words in 
	    the first group but don't contain any words in the second group */
 
		egen pro_ari = rowtotal(h32a-h32x),mi
		
		foreach var of varlist c_treatARI c_treatARI2 {
        replace `var' = 1 if `var' == 0 & pro_ari >= 1 
        replace `var'  = . if pro_ari == . 	
		}
}

		if inlist(name,"Bolivia2008") {
	        local h32 h32a h32f h32g h32h h32j h32l h32n h32o h32p
	    }
        if inlist(name,"Senegal2014","Senegal2012","Senegal2015") {  //For v000 == SN6, there's category don't show in label but back to survey. 	
			local h32 h32a h32b h32c h32d h32e h32g h32h h32j h32l h32m h32n h32p h32q
	    }
	    if inlist(name,"Senegal2010") {
	        local h32 h32a h32b h32c h32d h32e h32j h32l h32m h32n
	    }
	    foreach var in $h32 {
			replace c_treatARI = 1 if c_treatARI == 0 & `var' == 1 
			replace c_treatARI = . if `var' == .
			
			replace c_treatARI2 = 1 if c_treatARI2 == 0 & `var' == 1 
			replace c_treatARI2 = . if `var' == .
		}
		
*c_fevertreat	Child with fever symptoms seen by formal provider
       if inlist(name,"Senegal2014","Senegal2012","Senegal2015","Senegal2010") {
	       gen c_fevertreat = 0 if c_fever == 1
			foreach var in $h32 {
				replace c_fevertreat = 1 if c_fevertreat == 0 & `var' == 1
				replace c_fevertreat = . if `var' == 9 
			}
	    }	
		
       if inlist(name,"Bolivia2008") {
	       gen c_fevertreat = .
	    }	
		
	   if ~inlist(name,"Senegal2014","Senegal2012","Senegal2015","Senegal2010","Bolivia2008") {
		gen c_fevertreat = 0 if c_fever == 1
			replace c_fevertreat = 1 if c_fevertreat == 0 & pro_ari >= 1
			replace c_fevertreat = . if pro_ari == .
	    }	
		
		
*c_illness	Child with any illness symptoms in last two weeks
   		gen c_illness = (c_diarrhea == 1 | c_ari == 1 | c_fever == 1) 
		replace c_illness =. if c_diarrhea == . | c_ari == . | c_fever == .
		
		gen c_illness2 = (c_diarrhea == 1 | c_ari2 == 1 | c_fever == 1) 
		replace c_illness2 =. if c_diarrhea == . | c_ari2 == . | c_fever == .
		
*c_illtreat	Child with any illness symptoms taken to formal provider
        gen c_illtreat = (c_fevertreat == 1 | c_diarrhea_pro == 1 | c_treatARI == 1) if c_illness == 1
		replace c_illtreat = . if (c_fever == 1 & c_fevertreat == .) | (c_diarrhea == 1 & c_diarrhea_pro == .) | (c_ari == 1 & c_treatARI == .) 
		
        gen c_illtreat2 = (c_fevertreat == 1 | c_diarrhea_pro == 1 | c_treatARI2 == 1) if c_illness2 == 1
		replace c_illtreat2 = . if (c_fever == 1 & c_fevertreat == .) | (c_diarrhea == 1 & c_diarrhea_pro == .) | (c_ari2 == 1 & c_treatARI2 == .) 

