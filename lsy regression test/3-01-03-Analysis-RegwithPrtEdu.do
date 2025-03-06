/*
* Author: Songyue Liu
* Aim: 测试不同父母受教育程度情况如何影响地区教育信息化建设对认知能力的影响
    * 样本范围：基础教育阶段学生
    * 被解释变量
    * 解释变量

    * 控制变量
        个体控制：
        家庭控制
        区县控制变量
        城市控制变量
* Input: 
    panel： "$wkdata/Child Panel 10_2_22.dta"
* Output: 
*/

clear
set more off
cap log close

log using "$logs/lsy-3-01-03-Analysis-RegwithPrtEdu.log", replace
global results = "/Users/liusongyue/Library/CloudStorage/坚果云-201921030023@mail.bnu.edu.cn/1_StudySpace/一平/信息化建设、家庭教育与城乡儿童发展/Results/lsy test results"

use "$wkdata/Child Panel 10_2_22.dta", clear

xtset pid 年份
global sample = "if BasicEduStudent==1 & mathtest>=0 & wordtest>=0"
count $sample
gen BECnt_m = BECnt*eduyim_m
gen BEAmtMil_m = BEAmtMil*eduyim_m
gen BECnt_f = BECnt*eduyim_f
gen BEAmtMil_f = BEAmtMil*eduyim_f
gen BE_Infr_AmtMil_m = BE_Infr_AmtMil*eduyim_m
gen BE_Infr_Cnt_m = BE_Infr_Cnt*eduyim_m
gen BE_DigRes_AmtMil_m = BE_DigRes_AmtMil*eduyim_m
gen BE_DigRes_Cnt_m = BE_DigRes_Cnt*eduyim_m
gen BE_Infr_AmtMil_f = BE_Infr_AmtMil*eduyim_f
gen BE_Infr_Cnt_f = BE_Infr_Cnt*eduyim_f
gen BE_DigRes_AmtMil_f = BE_DigRes_AmtMil*eduyim_f
gen BE_DigRes_Cnt_f = BE_DigRes_Cnt*eduyim_f


global prsncontrols = "gender age"
global fmcontrols =" eduyim_m eduyim_f age_f age_m"
global cntycontrols = "cnty_普通中学在校生数人 cnty_普通中学学校数个 cnty_普通小学在校生数人 cnty_普通小学学校数个"
global prefcontrols = "pref_第一产业增加值占GDP比重 pref_第二产业增加值占GDP比重 pref_第三产业增加值占GDP比重 pref_人均地区生产总值元"

local yvars = "mathtest wordtest"



global xvars1 = "BECnt BEAmtMil eduyim_f eduyim_m"
global xvars2 = "BE_DigRes_AmtMil BE_DigRes_Cnt BE_Infr_AmtMil BE_Infr_Cnt eduyim_f eduyim_m"
* 与父母受教育程度的交互项
global xvars3 = "eduyim_m eduyim_f BECnt BEAmtMil  BECnt_m BEAmtMil_m  BECnt_f BEAmtMil_f BE_Infr_AmtMil BE_Infr_Cnt BE_Infr_AmtMil_m BE_Infr_Cnt_m BE_Infr_AmtMil_f BE_Infr_Cnt_f BE_DigRes_AmtMil BE_DigRes_Cnt BE_DigRes_AmtMil_m BE_DigRes_Cnt_m BE_DigRes_AmtMil_f BE_DigRes_Cnt_f"

local i = 1
foreach yvar of local yvars {
    foreach x in 1 2 3 4 5 {
        reghdfe `yvar' ${xvars`x'}  $sample, absorb(countyid wave) 
        est store m`i'
        local i = `i' + 1
    }
}

estfe m*, labels(countyid  "County FE" wave "Year FE")
return list


local opt "modelwidth(6) nonumber nogaps star(* 0.1 ** 0.05 *** 0.01)"

esttab m* using "$results/3-01-03-RegwithPrtEdu.csv" ///
, ///
`opt' ///
b(3) scalars(N r2_a)  sfmt( %10.0f %10.3f )  ///
indicate( `r(indicate_fe)') replace  nolabel 