/**************************************
* 3-01-01-Analysis-MainRegression.do
* Author: LSY
* Aim: 
  1. 区县教育信息化采购规模和数量对于学生认知能力的影响
  研究样本：6-15岁在读学生schdum==1 且有区县采购数据
  被解释变量：

  控制变量
  1） 确定控制变量和固定效应
  2） 引入教育信息化采购金额的滞后期
* Input data: $wkdata/childrenPanel10_2_22.dta
如何处理效果滞后的问题？
* 加入控制变量 2014相对于2010的认知能力变化
* 差分回归： 2022-2018的认知能力变化 对2014-2017年的教育信息化采购金额回归
需要对数据重新处理成方便回归的形式
*****************************************/

clear all
set more off
cap log close

log using "$logs/lsy-3-01-01-Analysis-MainRegression.log", replace

global results = "/Users/liusongyue/Library/CloudStorage/坚果云-201921030023@mail.bnu.edu.cn/1_StudySpace/一平/信息化建设、家庭教育与城乡儿童发展/Results/lsy test results"
// Load the data
use "$wkdata/childrenPanel10_2_22.dta", clear

global sample = "if schdum==1 & age>=6 & age<=15 & TotalCnt!=. & TotalAmtMil!=. & (wave == 2014 | wave == 2018 | wave == 2022)"

replace BECnt = 0 if BECnt==. & TotalCnt!=.
replace BEAmtMil = 0 if BEAmtMil==. & TotalAmtMil!=.

global xvars1 = "L4.BECnt"
global xvars2 = "L4.BEAmtMil "
global xvars3 = "L4.BECnt  L4.BEAmtMil"

global prsncontrols = "gender age"
global fmcontrols =" eduyim_m eduyim_f age_f age_m"
// global cntycontrol = "cnty_第二产业增加值_万元 cnty_第三产业增加值_万元 cnty_一般公共预算收入_万元"
global prefcontrols = "pref_第二产业增加值占GDP比重 pref_第三产业增加值占GDP比重 pref_人均地区生产总值_元_全市"

local yvars = "mathtest wordtest"  // 2010 2014 2018 2022
local i = 1
keep if pid!=. & (wave == 2010 | wave == 2014 | wave == 2018 | wave == 2022) 
xtset pid 年份
foreach yvar of local yvars {
    foreach x in 1 2 3 {
        reghdfe `yvar'  ${xvars`x'} $sample, absorb(采购人adcode) 
        est store m`i'
        local i = `i' + 1
        reghdfe `yvar' ${xvars`x'} $prsncontrols $sample, absorb(采购人adcode) 
        est store m`i'
        local i = `i' + 1
        reghdfe `yvar' ${xvars`x'} $prsncontrols $fmcontrols $sample, absorb(采购人adcode) 
        est store m`i'
        local i = `i' + 1
        reghdfe `yvar' ${xvars`x'} $prsncontrols $fmcontrols $prefcontrols $sample, absorb(采购人adcode) 
        est store m`i'
        local i = `i' + 1

    }
    
}

* Prepare estimates for -estout-
estfe m*, labels(countyid  "County FE" wave "Year FE")
return list


local opt "modelwidth(6) nonumber nogaps star(* 0.1 ** 0.05 *** 0.01)"

esttab m* using "$results/3-01-01-MainRegression.csv" ///
, ///
`opt' ///
b(3) scalars(N r2_a)  sfmt( %10.0f %10.3f )  ///
indicate( `r(indicate_fe)') replace  nolabel 
* est clear



* 



