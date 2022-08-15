* pause on 

/*
2012-2016 is converted
2017 adjusted code, data produced
2018 missing raw data: REC44.SAV
2019 adjusted code, data produced
2020 adjusted code, data produced
2021 data saved in wrong format: dta instead of sav
*/

global SOURCE "/Volumes/Seagate Bas/HEFPI DATA/RAW DATA/DHS/Peru-INEI/Download/"


local i=2018


tempfile temp1 temp2 temp3

* DHS-Peru[year]hh.dta
import spss using "${SOURCE}/DHS/DHS-Peru`i'/RECH0.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `temp1'

import spss using  "${SOURCE}/DHS/DHS-Peru`i'/RECH23.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `temp2'

capture {
import spss using  "${SOURCE}/DHS/DHS-Peru`i'/RECH8.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `temp3'
}

use `temp1', clear
merge 1:1 hhid using `temp2'
drop _
cap merge 1:1 hhid using `temp3'
cap drop _

keep hhid hv001 hv002 hv003 hhid hv009 hv021 hv025 hv205 hv024 hv270 hv271 hv201 hv270 hv271 hv201 hv205 hv220 hv219
 
save "${SOURCE}/DHS/DHS-Peru`i'/DHS-Peru`i'hh.dta", replace


* DHS-Peru[year]ind.dta
tempfile temp4 temp5 temp6 temp7 temp8 temp9 temp10 temp11 temp12 temp13 temp14 temp15

if `i' != 2012 {
	import spss using  "${SOURCE}/DHS/DHS-Peru`i'/RE223132.sav", clear
}
else {
	import spss using  "${SOURCE}/DHS/DHS-Peru`i'/RE212232.sav", clear	
}

	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `temp4'

import spss using  "${SOURCE}/DHS/DHS-Peru`i'/REC21.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
for var b0- b16: rename X  X_

gen bo = string(bord, "%02.0f")

if `i' == 2017 {
    drop bd bdd bmm baa bcmc bedad fnac_imp fentr_imp 
} //Added0727, only bord and bidx is needed, drop other irrelevant variables

if inlist(`i',2018,2019,2020,2021) {
    drop bd bdd bmm baa bcmc bedad qd333_1 qd333_2 qd333_3 qd333_4 qd333_5 qd333_6 q220a qult5
} //Added0727, only bord and bidx is needed, drop other irrelevant variables

reshape wide bord bidx b0- b16, i(caseid) j(bo) string
save `temp5'

import spss using  "${SOURCE}/DHS/DHS-Peru`i'/RE516171.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `temp6'
	
import spss using  "${SOURCE}/DHS/DHS-Peru`i'/REC42.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `temp7'

import spss using  "${SOURCE}/DHS/DHS-Peru`i'/RE758081.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `temp8'

import spss using  "${SOURCE}/DHS/DHS-Peru`i'/REC91.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `temp9'

import spss using  "${SOURCE}/DHS/DHS-Peru`i'/REC41.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
gen x = midx
for var midx- m73: rename X X_
reshape wide midx_- m73_, i(caseid) j(x)
save `temp10'

import spss using  "${SOURCE}/DHS/DHS-Peru`i'/REC43.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
gen x = hidx
for var hidx-h46b: rename X X_
if `i' == 2017{
    drop hidx1  //added 0727, drop irrelevant variable.
}
reshape wide hidx_- h46b_, i(caseid) j(x)
save `temp11'

import spss using  "${SOURCE}/DHS/DHS-Peru`i'/REC44.sav", clear //2018 warning: REC44.sav not found
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
gen x = hwidx
for var hwidx-hw73: rename X X_
reshape wide hwidx_- hw73_, i(caseid) j(x)
save `temp12'


if inrange(`i',2014,2021) {
import spss using  "${SOURCE}/DHS/DHS-Peru`i'/REC0111.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `temp13'
}

if inrange(`i',2014,2021) {
import spss using  "${SOURCE}/DHS/DHS-Peru`i'/RECH0.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `temp14'
}

use `temp4', clear
merge 1:1 caseid using `temp5', update
drop _
merge 1:1 caseid using `temp6', update
drop _
merge 1:1 caseid using `temp7', update
drop _
merge 1:1 caseid using `temp8', update
drop _
merge 1:1 caseid using `temp9', update
drop _
merge 1:1 caseid using `temp10', update
drop _
merge 1:1 caseid using `temp11', update
drop _
merge 1:1 caseid using `temp12', update
drop _
if inrange(`i',2014,2021) {
merge 1:1 caseid using `temp13', update
drop _
}
if inrange(`i',2014,2021) {
cap gen hhid = substr(caseid,1,9)
merge m:1 hhid using `temp14', update
drop if _ < 3
drop _
}
cap drop hhid
cap gen hhid = substr(caseid,1,9)
order caseid hhid
save "${SOURCE}/DHS/DHS-Peru`i'/DHS-Peru`i'ind.dta", replace

* DHS-Peru[year]hm.dta
tempfile temp20 temp21 temp22 temp23 temp24
import spss using  "${SOURCE}/DHS/DHS-Peru`i'/RECH0.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `temp20'


import spss using  "${SOURCE}/DHS/DHS-Peru`i'/RECH1.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `temp21'

import spss using  "${SOURCE}/DHS/DHS-Peru`i'/RECH6.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
	gen hvidx = hc0
save `temp22'
	
use `temp21',clear
merge 1:1 hhid hvidx using `temp22'

drop _merge
save `temp23'

import spss using  "${SOURCE}/DHS/DHS-Peru`i'/RECH23.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
	keep hhid hv270 hv271 hv201 hv205 hv220 hv219
save `temp24'

use `temp20', clear
merge 1:1 hhid using `temp24'
drop _merge

merge 1:m hhid using `temp23'
pause on 
pause check obs
drop if _merge != 3
drop _ 

cap egen caseid = concat(hhid hvidx), punct("  ")
order caseid hhid
save "${SOURCE}/DHS/DHS-Peru`i'/DHS-Peru`i'hm.dta", replace


if `i' != 2012 {
	import spss using  "${SOURCE}/DHS/DHS-Peru`i'/CSALUD01.sav", clear
		foreach var of varlist _all{
			rename `var' `=lower("`var'")'
		}
	cap egen caseid = concat(hhid qsnumero), punct("  ")
	order caseid hhid
	save "${SOURCE}/DHS/DHS-Peru`i'/DHS-Peru`i'adu.dta", replace
}







/*
--
Tests merges
use "${SOURCE}/DHS/DHS-Peru2013/DHS-Peru2013hh.dta", clear
merge 1:m hhid using "${SOURCE}/DHS/DHS-Peru2013/DHS-Peru2013ind.dta", update
drop _
merge 1:1 caseid using "${SOURCE}/DHS/DHS-Peru2013/DHS-Peru2013hm.dta"
drop _
merge 1:1 caseid using "${SOURCE}/DHS/DHS-Peru2013/DHS-Peru2013adu.dta"
drop _

*/
