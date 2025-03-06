/**************************************
* 3-01-01-Analysis-MainRegression.do
* Author: LSY
* Aim: 
  1. 区县教育信息化采购规模和数量对于学生认知能力的影响
* Input data: $wkdata/ChildWideSample.dta

*****************************************/

clear all
set more off
cap log close

log using "$logs/lsy-3-01-02-Analysis-MainRegression.log", replace

global results = "/Users/liusongyue/Library/CloudStorage/坚果云-201921030023@mail.bnu.edu.cn/1_StudySpace/一平/信息化建设、家庭教育与城乡儿童发展/Results/lsy test results"

use "$wkdata/ChildWideSample.dta", clear
*global sample = "if (BasicEduFlag2018== 1 | BasicEduFlag2020== 1 | BasicEduFlag2022== 1)"
global sample = "if age2018<=15"
global xvars1 = "BECnt14_17persch_lg BEAmt14_17persch_lg BECnt14_17lgrural BEAmt14_17lgrural"
global xvars2 = "BE_Infr_Cnt14_17persch_lg BE_Infr_Amt14_17persch_lg BE_DigRes_Cnt14_17persch_lg BE_DigRes_Amt14_17persch_lg BE_Infr_Cnt14_17lgrural BE_Infr_Amt14_17lgrural BE_DigRes_Cnt14_17lgrural BE_DigRes_Amt14_17lgrural"
global xvars3 = "BECnt14_17persch_lg BEAmt14_17persch_lg BECnt14_17lgrural BEAmt14_17lgrural"
global xvars4 = "BE_Infr_Cnt14_17persch_lg BE_Infr_Amt14_17persch_lg BE_DigRes_Cnt14_17persch_lg BE_DigRes_Amt14_17persch_lg BE_Infr_Cnt14_17lgrural BE_Infr_Amt14_17lgrural BE_DigRes_Cnt14_17lgrural BE_DigRes_Amt14_17lgrural"

global xvars5 = "BEAmt14_17persch_lg  BEAmt14_17lgrural"
global xvars6 = "BE_Infr_Amt14_17persch_lg  BE_Infr_Amt14_17lgrural"
global xvars7 = "BE_DigRes_Amt14_17persch_lg  BE_DigRes_Amt14_17lgrural"
global xvars8 = "BEAmt14_17persch_lg  BEAmt14_17lgrural"
global xvars9 = "BE_Infr_Amt14_17persch_lg  BE_Infr_Amt14_17lgrural"
global xvars10 = "BE_DigRes_Amt14_17persch_lg  BE_DigRes_Amt14_17lgrural"

global xvars11 = "BECnt14_17persch BEAmtTho14_17persch  BECnt14_17rural BEAmtTho14_17rural"
global xvars12 = "BE_Infr_Cnt14_17persch BE_Infr_AmtTho14_17persch  BE_Infr_Cnt14_17rural BE_Infr_AmtTho14_17rural"
global xvars13 = "BE_DigRes_Cnt14_17persch BE_DigRes_AmtTho14_17persch  BE_DigRes_Cnt14_17rural BE_DigRes_AmtTho14_17rural"

global xvars14 = "BECnt14_17 BEAmtMil14_17 BECnt14_17rural BEAmtMil14_17rural"
global xvars15 = "BE_Infr_Cnt14_17 BE_Infr_AmtMil14_17 BE_Infr_Cnt14_17rural BE_Infr_AmtMil14_17rural BE_DigRes_Cnt14_17 BE_DigRes_AmtMil14_17 BE_DigRes_Cnt14_17rural BE_DigRes_AmtMil14_17rural"



global prsncontrols = "mathtest18_14 wordtest18_14 mathtest14_10 wordtest14_10 "
global fmcontrols = "eduyim_m2018 eduyim_f2018 age_f2018 age_m2018"
global prefcontrols = "pref_第二产业增加值占GDP比重2018 pref_第三产业增加值占GDP比重2018 pref_人均地区生产总值元2018"
global cntycontrols = "cnty_普通中小学学校数2018  cnty_第一产业增加值万元2018 cnty_第二产业增加值万元2018 cnty_第三产业增加值万元2018"
local yvars = "mathtest22_18 wordtest22_18"
/*
local i = 1
foreach xc of numlist 11 12 13 {
foreach yvar of local yvars {
    reghdfe `yvar' ${xvars`xc'} $sample
    est store m`i'
    local i = `i' + 1
    reghdfe `yvar' ${xvars`xc'} $prsncontrols $sample
    est store m`i'
    local i = `i' + 1
    reghdfe `yvar' ${xvars`xc'} $prsncontrols $fmcontrols $sample
    est store m`i'
    local i = `i' + 1
    reghdfe `yvar' ${xvars`xc'} $prsncontrols $fmcontrols $prefcontrols $sample
    est store m`i'
    local i = `i' + 1
  }
}
*/
local i = 1
foreach xc of numlist 14 15 {
foreach yvar of local yvars {
    reghdfe `yvar' ${xvars`xc'} $sample
    est store m`i'
    local i = `i' + 1
    reghdfe `yvar' ${xvars`xc'} $prsncontrols $sample
    est store m`i'
    local i = `i' + 1
    reghdfe `yvar' ${xvars`xc'} $prsncontrols $fmcontrols $sample
    est store m`i'
    local i = `i' + 1
    reghdfe `yvar' ${xvars`xc'} $prsncontrols $fmcontrols $prefcontrols $sample
    est store m`i'
    local i = `i' + 1
    reghdfe `yvar' ${xvars`xc'} $prsncontrols $fmcontrols $prefcontrols $cntycontrols $sample
    est store m`i'
    local i = `i' + 1
}
}




esttab m* using "$results/lsy-3-01-02-Analysis-MainRegression.csv", replace se(3) b(3) star(* 0.1 ** 0.05 *** 0.01) nolabel
