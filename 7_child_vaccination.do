
******************************
*** Child vaccination ********
******************************   

*c_measles	child			Child received measles1/MMR1 vaccination
        
		gen c_measles  =. 
			replace c_measles = 1 if inrange(h9,1,3)  
			replace c_measles = 0 if h9 == 0 	

		if inlist(name,"Egypt2008") {
			drop c_measles 
			
			gen c_measles=.
			replace c_measles = 1 if inrange(h9,1,3) | inrange(smmr,1,3)
			replace c_measles = 0 if h9 == 0 & smmr == 0  
		}	
*c_dpt1	child	Child received DPT1/Pentavalent 1 vaccination	
        gen c_dpt1  = . 
		replace c_dpt1  = 1 if inrange(h3,1,3)
		replace c_dpt1  = 0 if  h3 == 0 
		
*c_dpt2	child			Child received DPT2/Pentavalent2 vaccination				
		gen c_dpt2  = . 
		replace c_dpt2  = 1 if inrange(h5,1,3)
		replace c_dpt2  = 0 if h5 == 0  
		
		
*c_dpt3	child			Child received DPT3/Pentavalent3 vaccination				
		gen c_dpt3  = . 
		replace c_dpt3  = 1 if inrange(h7,1,3) 
		replace c_dpt3  = 0 if h7 == 0  
		
*c_bcg	child			Child received BCG vaccination
		gen c_bcg  = . 
		replace c_bcg  = 1 if inrange(h2,1,3) 
		replace c_bcg  = 0 if h2 == 0  	
		
		if inlist(name,"Aczerbaijan2006") {
			drop c_measles c_bcg
			
			gen c_bcg = .
			replace c_bcg = 1 if inrange(h2,1,3) | sr509a==1
			replace c_bcg = 0 if h2==0 & sr509a==2
			
			gen c_measles = .
			replace c_measles = 1 if inrange(h9,1,3) | inrange(s506mr,1,3) | sr509g==1
			replace c_measles = 0 if h9 == 0 & s506mr == 0 & sr509g==2 
		}
		
		gen c_polio0  = .  
		replace c_polio0  = 1 if inrange(h0,1,3) 
		replace c_polio0  = 0 if h0 ==0  		
*c_polio1	child			Child received polio1/OPV1 vaccination
		gen c_polio1  = .  
		replace c_polio1  = 1 if inrange(h4,1,3) 
		replace c_polio1  = 0 if h4 ==0  

*c_polio2	child			Child received polio2/OPV2 vaccination				
		gen c_polio2  = .  
		replace c_polio2  = 1 if inrange(h6,1,3)  
		replace c_polio2  = 0 if h6 ==0 
		
*c_polio3	child			Child received polio3/OPV3 vaccination				
		gen c_polio3  = .  
		replace c_polio3  = 1 if inrange(h8,1,3)
		replace c_polio3  = 0 if h8 ==0  

		if inlist(name,"Colombia2010") {
			drop c_dpt1 c_dpt2 c_dpt3 
			
			gen c_dpt1  = . 
			replace c_dpt1  = 1 if inrange(h3,1,3) | inrange(spv1,1,3) 
			replace c_dpt1  = 0 if  h3 == 0 & spv1 ==0
			gen c_dpt2  = . 
			replace c_dpt2  = 1 if inrange(h5,1,3) | inrange(spv2,1,3)
			replace c_dpt2  = 0 if h5 == 0  & spv2 ==0
			gen c_dpt3  = . 
			replace c_dpt3  = 1 if inrange(h7,1,3) | inrange(spv3,1,3) 
			replace c_dpt3  = 0 if h7 == 0 & spv3 ==0
		}
		
		if inlist(name,"Peru2004","Peru2007","Peru2009","Peru2010","Peru2011","Peru2012") {
			drop c_dpt1 c_dpt2 c_dpt3
			
			gen c_dpt1  = . 
			replace c_dpt1  = 1 if inrange(h3,1,3) | inrange(s45pv1,1,3) //PENTAVALENTE
			replace c_dpt1  = 0 if  h3 == 0 & s45pv1 ==0
			gen c_dpt2  = . 
			replace c_dpt2  = 1 if inrange(h5,1,3) | inrange(s45pv2,1,3)
			replace c_dpt2  = 0 if h5 == 0  & s45pv2 ==0
			gen c_dpt3  = . 
			replace c_dpt3  = 1 if inrange(h7,1,3) | inrange(s45pv3,1,3) 
			replace c_dpt3  = 0 if h7 == 0 & s45pv3 ==0
		}
		
		if inlist(name,"Uganda2006") {
			drop c_dpt1 c_dpt2 c_dpt3
			
			gen c_dpt1  = . 
			replace c_dpt1  = 1 if inrange(h3,1,3) | inrange(sdh1,1,3) 
			replace c_dpt1  = 0 if  h3 == 0 & sdh1 ==0
			gen c_dpt2  = . 
			replace c_dpt2  = 1 if inrange(h5,1,3) | inrange(sdh2,1,3)
			replace c_dpt2  = 0 if h5 == 0  & sdh2 ==0
			gen c_dpt3  = . 
			replace c_dpt3  = 1 if inrange(h7,1,3) | inrange(sdh3,1,3) 
			replace c_dpt3  = 0 if h7 == 0 & sdh3 ==0
		}
		
		if inlist(name,"Zambia2007") {
			drop c_dpt1 c_dpt2 c_dpt3
			
			gen c_dpt1  = . 
			replace c_dpt1  = 1 if inrange(h3,1,3) | inrange(sdhh1,1,3) 
			replace c_dpt1  = 0 if  h3 == 0 & sdhh1 ==0
			gen c_dpt2  = . 
			replace c_dpt2  = 1 if inrange(h5,1,3) | inrange(sdhh2,1,3)
			replace c_dpt2  = 0 if h5 == 0  & sdhh2 ==0
			gen c_dpt3  = . 
			replace c_dpt3  = 1 if inrange(h7,1,3) | inrange(sdhh3,1,3) 
			replace c_dpt3  = 0 if h7 == 0 & sdhh3 ==0
		}
		
*c_fullimm	child			Child fully vaccinated						
		gen c_fullimm =.  										/*Note: polio0 is not part of allvacc- see DHS final report*/
		replace c_fullimm =1 if (c_measles==1 & c_dpt1 ==1 & c_dpt2 ==1 & c_dpt3 ==1 & c_bcg ==1 & c_polio1 ==1 & c_polio2 ==1 & c_polio3 ==1)  
		replace c_fullimm =0 if (c_measles==0 | c_dpt1 ==0 | c_dpt2 ==0 | c_dpt3 ==0 | c_bcg ==0 | c_polio1 ==0 | c_polio2 ==0 | c_polio3 ==0)  
		replace c_fullimm =. if b5 ==0  
						
