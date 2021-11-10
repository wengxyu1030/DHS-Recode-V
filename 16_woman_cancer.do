
***********************
*** Woman Cancer*******
***********************
	
*w_papsmear	Women received a pap smear  (1/0) 
*w_mammogram	Women received a mammogram (1/0)

gen w_papsmear = .
gen w_mammogram = .

if inlist(name, "Armenia2010"){
    ren v012 wage		
    replace w_papsmear=1 if s714dd==1 & s714ee==1
	replace w_papsmear=0 if s714dd==0 | s714ee==0
	replace w_papsmear=. if s714dd==9 | s714ee==9
    tab wage if w_papsmear!=. /*DHS sample is women aged 17-49*/
    replace w_papsmear=. if wage<20|wage>49	
}

if inlist(name,"Bolivia2008") {
	replace w_papsmear = s254
	replace w_papsmear = . if s254 == 8
    tab v012 if w_papsmear!=. /*DHS sample is women aged 15-49*/
	replace w_papsmear=. if v012<20|v012>49
}

if inlist(name,"DominicanRepublic2007") {
	replace w_papsmear = s1008a
	replace w_papsmear = . if s1008a == 9
    tab v012 if w_papsmear!=. /*DHS sample is women aged 15-49*/
	replace w_papsmear=. if v012<20|v012>49
	
	replace w_mammogram = 1 if inlist(s1008b,1,3)
	replace w_mammogram = 0 if inlist(s1008b,4,2)
    tab v012 if w_mammogram!=. /*DHS sample is women aged 15-49*/
    replace w_mammogram=. if v012<40|v012>49 /*DW Nov 2021: variable wage not available for DR2007*/
}

if inlist(name,"Colombia2010") {
	replace w_papsmear = 0 if s902!=.
	replace w_papsmear = 1 if s904==1 & s906==1	
	replace w_papsmear = . if inlist(s906,.,8)
    tab v012 if w_papsmear!=. /*DHS sample is women aged 19-49*/
	replace w_papsmear=. if v012<20|v012>49

	replace w_mammogram = 0 if s936!=.
	replace w_mammogram = 1 if s938 == 1
    tab v012 if w_mammogram!=. /*DHS sample is women aged 40-49*/
}

if inlist(name,"Honduras2005") {
	replace w_papsmear = s1018 
	replace w_papsmear = 0 if s1018a >3	
	replace w_papsmear = . if s1018==9 | inlist(s1018a,99,98)
    tab v012 if w_papsmear!=. /*DHS sample is women aged 15-49*/
	replace w_papsmear=. if v012<20|v012>49

	replace w_mammogram= 0 if s1020!=9
	replace w_mammogram=1 if s1021==1
    replace w_mammogram=. if s1021==9
    tab v012 if w_mammogram!=. /*DHS sample is women aged 15-49*/
    replace w_mammogram=. if v012<40|v012>49

}
	
if inlist(name, "Honduras2011"){
    ren v012 wage	
	replace s1011a=. if s1011a==98|s1011a==99
    replace w_papsmear=1 if (s1011==1&s1011a<=23)
    replace w_papsmear=0 if s1011==0
    replace w_papsmear=0 if w_papsmear == . & s1011a>35 & s1011a<100
    replace w_papsmear=. if s1011==.|s1011==9
    tab wage if w_papsmear!=. /*DHS sample is women aged 15-49*/
    replace w_papsmear=. if wage<20|wage>49
	
	replace w_mammogram=1 if s1012c==1
    replace w_mammogram=0 if s1012c==0|s1012b==0
    tab wage if w_mammogram!=. /*DHS sample is women aged 15-49*/
    replace w_mammogram=. if wage<40|wage>49
}

if inlist(name,"Jordan2007") {
	replace w_papsmear=(s550d==1)
	replace w_papsmear=. if s550c==.
    tab v012 if w_papsmear!=. /*DHS sample is women aged 15-49*/
	replace w_papsmear=. if v012 < 20
	replace w_mammogram=(s550b==1)
	replace w_mammogram=. if s550b==.|s550b==8
    tab v012 if w_mammogram!=. /*DHS sample is women aged 15-49*/
	replace w_mammogram=. if v012 < 20
}

if inlist(name,"Lesotho2009") {
	replace w_papsmear=0 if !inlist(s1012l,9,.)
	replace w_papsmear=1 if s1012m==1 & inlist(s1012n,1,2) 
	replace w_papsmear=. if s1012n==8 // code . if uncertain about recall period 
    tab v012 if w_papsmear!=. /*DHS sample is women aged 15-49*/
	replace w_papsmear=. if inlist(v012,20,49)
}

if inlist(name,"Peru2004","Peru2007") {
	replace w_papsmear = 0 if !inlist(s490,.,8,9)
	replace w_papsmear = 1 if s491 == 1 
    tab v012 if w_papsmear!=. /*DHS sample is women aged 15-49*/
	replace w_papsmear=. if inlist(v012,20,49)
}

if inlist(name,"Peru2009") {
	replace w_papsmear = 0 if s491!=.
	replace w_papsmear = 1 if s491a == 1 
    tab v012 if w_papsmear!=. /*DHS sample is women aged 15-49*/
	replace w_papsmear=. if inlist(v012,20,49)
}

if inlist(name,"Peru2010","Peru2011","Peru2012") {
	replace w_papsmear = 0 if s485!=.
	replace w_papsmear = 1 if s485a == 1 
    tab v012 if w_papsmear!=. /*DHS sample is women aged 15-49*/
	replace w_papsmear=. if inlist(v012,20,49)
}
//?????
capture confirm variable qs415 qs416u 
if _rc==0 {
    ren qs23 wage
    replace w_mammogram=(qs415==1&qs416u==1)
    replace w_mammogram=. if qs415==.|qs415==8|qs415==9|qs416u==9
    tab wage if w_mammogram!=. /*DHS sample is women aged 15-49*/
    replace w_mammogram=. if wage<50|wage>69
}
// They may be country specific in surveys.


*Add reference period.
//if not in adeptfile, please generate value, otherwise keep it missing. 
//if the preferred recall is not available (3 years for pap, 2 years for mam) use shortest other available recall 

gen w_mammogram_ref = ""  //use string in the list: "1yr","2yr","5yr","ever"; or missing as ""
gen w_papsmear_ref = ""   //use string in the list: "1yr","2yr","3yr","5yr","ever"; or missing as ""


if inlist(name,"Armenia2010", "Bolivia2008","Lesotho2009") {
	replace w_papsmear_ref = "3yr"
}
if inlist(name, "DominicanRepublic2007") {
	replace w_papsmear_ref = "1yr"
	replace w_mammogram_ref = "1yr"
}
if inlist(name, "Colombia2010","Honduras2005") {
	replace w_papsmear_ref = "3yr"
	replace w_mammogram_ref = "ever"
}

if inlist(name, "Honduras2011"){
	replace w_mammogram_ref = "ever" 
	replace w_papsmear_ref = "2yr" 
}
	
if inlist(name, "Jordan2017") {
	replace w_papsmear_ref = "ever"
	replace w_mammogram_ref = "1yr"
}

if inlist(name,"Peru2004","Peru2007","Peru2009","Peru2010","Peru2011","Peru2012") {
	replace w_papsmear_ref = "5yr"
}

* Add Age Group.
//if not in adeptfile, please generate value, otherwise keep it missing. 

gen w_mammogram_age = "" //use string in the list: "20-49","20-59"; or missing as ""
gen w_papsmear_age = ""  //use string in the list: "40-49","20-59"; or missing as ""

if inlist(name, "Armenia2010","Bolivia2008","Lesotho2009") {
	replace w_papsmear_age = "20-49"
}
if inlist(name,"Peru2004","Peru2007","Peru2009","Peru2010","Peru2011","Peru2012") {
	replace w_papsmear_age = "20-49"
}

if inlist(name,"Colombia2010","Honduras2005","DominicanRepublic2007","Honduras2011","Jordan2017" ){
	replace w_papsmear_age = "20-49" 
	replace w_mammogram_age = "40-49" 
}
