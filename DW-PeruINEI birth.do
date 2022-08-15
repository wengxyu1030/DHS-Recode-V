
global SOURCE "/Volumes/Seagate Bas/HEFPI DATA/RAW DATA/DHS/Peru-INEI/Download/"
	
	
local i=2018
tempfile tempa tempb tempc tempd tempe tempf tempg tempabc

* DHS-Peru[year]birth.dta

import spss using "${SOURCE}/DHS/DHS-Peru`i'/REC21.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `tempa'

import spss using  "${SOURCE}/DHS/DHS-Peru`i'/REC0111.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `tempb'

import spss using  "${SOURCE}/DHS/DHS-Peru`i'/RE516171.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `tempc'

import spss using  "${SOURCE}/DHS/DHS-Peru`i'/REC41.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
save `tempd'

import spss using  "${SOURCE}/DHS/DHS-Peru`i'/REC43.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
	
rename hidx midx
save `tempe'

import spss using  "${SOURCE}/DHS/DHS-Peru`i'/REC95.sav", clear
	foreach var of varlist _all{
		rename `var' `=lower("`var'")'
	}
	
rename idx95 midx
save `tempf'

use `tempd', clear

merge 1:1 caseid midx using `tempe', update
tab _merge
pause d
drop _

merge 1:1 caseid midx using `tempf', update
tab _merge
pause f
drop _merge

rename midx bidx

save `tempg'


use `tempa', clear
merge m:1 caseid using `tempb', update
tab _merge
pause a
*drop if _merge != 3
drop _

merge m:1 caseid using `tempc', update
tab _merge
pause b
*drop if _merge != 3
drop _
save `tempabc'

merge m:1 caseid bidx using `tempg'
drop _merge


order caseid
save "${SOURCE}/DHS/DHS-Peru`i'/DHS-Peru`i'birth.dta", replace
