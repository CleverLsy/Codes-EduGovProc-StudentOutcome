/**************************************
* 3-01-04-Anlysis-CogVarDis.do
* Author: LSY
* Aim: 看看认知能力mathtest和wordtest的分布
* Input data:  "$wkdata/Child Panel 10_2_22.dta"
* Output data: 
****************************************/

clear all
set more off
cap log close

log using "$logs/lsy-3-01-04-Anlysis-CogVarDis.log", replace
global results = "/Users/liusongyue/Library/CloudStorage/坚果云-201921030023@mail.bnu.edu.cn/1_StudySpace/一平/信息化建设、家庭教育与城乡儿童发展/Results/lsy test results"

use  "$wkdata/Child Panel 10_2_22.dta", clear
global sample = "if BasicEduStudent==1"

foreach yvar of varlist mathtest wordtest {
    histogram `yvar' `sample', bin(10)
    * graph export "$results/`yvar'_histogram.png", replace
}
