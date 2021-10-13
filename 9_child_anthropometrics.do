
******************************
*** Child anthropometrics ****
******************************   

*c_stunted: Child under 5 stunted

 gen ant_sampleweight = hv005/1000000
 
 drop if hv103==0
/*  ren hv001 v001 
 ren hv002 v002 
 ren hvidx b16 */

 
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

rename (hc70 hc71) (hm_hc70 hm_hc71)

	
