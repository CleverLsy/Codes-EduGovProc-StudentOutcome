/*************************
Author: Liu Songyue
Aim: To merge the children panel

Output: $wkdata/childrenPanel10_2_22.dta

**************************/

use "$wkdata/CFPS_IndivLevel_10_2_22.dta", clear
merge m:1  countyid  using $cfpscountyid
drop _merge

gen 采购人adcode = code
gen 年份 = wave
merge m:1 采购人adcode 年份 using "$wkdata/CountyEduGovProc_IT.dta"
drop _merge


save "$wkdata/childrenPanel10_2_22.dta", replace

