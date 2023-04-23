
** 1. Merge the datasets **

** Step 1: Capitalize letters in datatask_treat to ensure merging **

use "/Users/beatricemaule/Desktop/applicant_packet/datatask_treat.dta"

replace prov_id = upper(prov_id)


** Step 2: Merge **

use "/Users/beatricemaule/Desktop/applicant_packet/datatask_main.dta"

merge m:1 prov_id using"/Users/beatricemaule/Desktop/applicant_packet/datatask_treat.dta"

** 2. Create Saidin Index Score ** 

** Step 1: organize tech_x data in order**
order tech_*, sequential


** Create loop to sum each tech_x variable by year **

foreach x of varlist tech_1-tech_31 {
  di "Processing variable `x'"
 egen tot_`x'=total(`x'), by(year)
}

foreach x of varlist tech_1-tech_31 {
  di "Processing variable `x'"
gen a_`x'=1-(tot_`x'/13050)
}

foreach x of varlist tech_1-tech_31 {
  di "Processing variable `x'"
gen s_`x'=a_`x'*`x'
}

egen saidin=rowtotal(s_tech_1-s_tech_31)

order year prov_id teach beds nonprof govt treat
order _merge, last


** 3. Questions and graphs **
drop if year< 2004 
drop if year>2004
** a **
hist saidin 
** b **
hist saidin if nonprof==1 
hist saidin if govt==1
hist saidin if teach==1
** c ** 
graph twoway (lfit saidin bed) (scatter saidin bed)
clear
** 4. Estimates **
use "/Users/beatricemaule/Desktop/applicant_packet/datatask_saidin.dta"
order year prov_id  teach  nonprof govt beds treat

replace treat=0 if treat==.
replace treat=0 if year<2004

replace prov_id= subinstr(prov_id, "Z", "0", .)
destring prov_id, replace 

replace treat=0 if year<2004

xtset prov_id year
parmby "xtreg saidin treat ib2004.year,vce(cluster prov_id)", saving (maule_beatrice_estimates.dta,replace)

** AN: I had never used parmby before. I unsuccessfully tried multiple ways to save the variables I needed, so I ended up just using the below commands. I realize it is not as efficient. If I had generated the results with parmby, I would have merged the two files **

mean saidin if treat==0|year==2001
mean saidin if treat==0|year==2002
mean saidin if treat==0|year==2003
mean saidin if treat==0|year==2004
mean saidin if treat==0|year==2005
mean saidin if treat==0|year==2006
mean saidin if treat==0|year==2007
mean saidin if treat==0|year==2008
mean saidin if treat==0|year==2009
mean saidin if treat==0|year==2010

clear 

** AN: I tried to use parmby for the above results but couldn't figure it out. This resulted in the lenghty code below. I realize it is not very efficient  **

use "/Users/beatricemaule/Documents/GitHub/Beatrice_Maule_datatask/applicant_packet/beatrice_maule_estimates.dta", clear



drop p
drop z
drop stderr
drop if parmseq==1
drop if parmseq==12
drop parm
drop parmseq
gen year=(2000+_n)
order year
rename min95 tr_lo
rename max95 tr_hi
rename estimate tr_effect

generate cr_mean = 0
replace cr_mean =  6.323165 in 1
replace cr_mean = 6.323165 in 2
replace cr_mean = 6.323165 in 3
replace cr_mean = 6.325565 in 4
replace cr_mean = 6.33049 in 5
replace cr_mean = 6.332527 in 6
replace cr_mean = 6.334574 in 7
replace cr_mean = 6.337566 in 8
replace cr_mean = 6.341218 in 9
replace cr_mean = 6.342709 in 10

gen cr_low=.
gen cr_high=.
replace cr_low = 6.244678 in 1
replace cr_high = 6.401651 in 1
replace cr_low = 6.244678 in 2
replace cr_high = 6.401651 in 2
replace cr_low = 6.244678 in 3
replace cr_high = 6.401651 in 3
replace cr_low = 6.247185 in 4
replace cr_high = 6.403946 in 4
replace cr_low = 6.252054 in 5
replace cr_high = 6.408926 in 5
replace cr_low = 6.254032 in 6
replace cr_high = 6.411021 in 6
replace cr_low = 6.255987 in 7
replace cr_high = 6.413162 in 7
replace cr_low = 6.258925 in 8
replace cr_high = 6.416207 in 8
replace cr_low = 6.262474 in 9
replace cr_high = 6.419961 in 9
replace cr_low = 6.263901 in 10
replace cr_high = 6.421516 in 10



gen tr_mean=cr_mean+tr_effect
gen tr_mean_low=cr_low+tr_lo
gen tr_mean_high=cr_hig+tr_hi


twoway rcap tr_mean_high tr_mean_low year || line cr_mean tr_mean year

 graph export "/Users/beatricemaule/Desktop/applicant_packet/Graph_q5.pdf", as(pdf) name("Graph")
 
