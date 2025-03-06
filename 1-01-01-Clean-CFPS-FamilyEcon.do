/*******************************
Program: GovEduIT Procument and EduOutcome
Input: 
    1. "$cfps2014famecon"
    2. "$cfps2016famecon"
    3. "$cfps2018famecon"
    4. "$cfps2020famecon"
Aim:
    1. 整理家庭经济变量、家庭教育相关变量（父母的教育年限、家庭收入情况、父母的职业、父母对子女的期望） 
    ///////////yyp：父母教育年限不在这个库里
    2. 保存为六个数据集（2012、2014、2016、2018、2020、2022）

*******************************/


/*0. prepare work*/
clear
set more off
capture log close


global hhbasicVar = "familysize"
global hhbasicVarLab = "家庭规模"
global hhincVar = "foperate_1 fwage_1 fproperty_1 ftransfer_1 felse_1 fincome1 fincome1_per"
global hhincVarLab = "家庭经营性收入(元/年)=农业生产和工商业经营的净利润 家庭工资性收入(元/年) 家庭财产性收入(元/年) 家庭转移性收入(元/年)=政府与社捐 家庭其他收入=亲友支持 家庭纯收入(元/年) 家庭人均纯收入"
global hhexpVar = "food dress house daily trco eec feduexp med other pce eptran epwelf mortage expense"
global hhexpVarLab = "家庭食品支出(元/年) 家庭衣着支出(元/年) 家庭居住支出(元/年) 家庭设备及日用品支出(元/年) 家庭交通通讯支出(元/年) 家庭文教娱乐支出(元/年)=文化娱乐支出+旅游支出+教育培训支出(元/年) 家庭教育培训支出(元/年)(元/年) 家庭医疗保健支出(元/年) 家庭其他支出(元/年) 家庭个人消费支出(元/年) 家庭教育支出(元/年) 家庭娱乐文化支出(元/年) 家庭住房支出(元/年) 家庭其他支出(元/年)"
global hhassetVar = "total_asset land_asset fixed_asset agrimachine company"
global hhassetVarLab = "家庭净资产(元)  家庭土地资产(元)  家庭固定资产(元)=农用器械价值+经营资产 家庭农用器械价值（元） 家庭经营资产（元）"

/*   2012年家庭变量清理   */
use "$cfps2012famecon", clear
gen feduexp = fp508
//////////////////////yyp：这里的fp508是什么变量？famecon问卷里没有父母教育相关的变量。
gen fwage_1 = wage_1_adj
local varLists "hhinc hhexp hhasset hhbasic"
foreach varList of local varLists {
    /* Create macros for variable names and labels */
    local varNameList = "${`varList'Var}"
    local varLabelList = "${`varList'VarLab}"
    
    /* Count the number of variables */
    local nvars : word count `varNameList'
    
    /* Loop over each variable and apply its corresponding label */
    forval i = 1/`nvars' {
        local varname : word `i' of `varNameList'
        local varlabel : word `i' of `varLabelList'
        
        label variable `varname' "`varlabel'"
        }
}
gen wave = 2012
keep fid* cid countyid wave $hhincVar $hhexpVar $hhassetVar $hhbasicVar
save "$temp/FamilyVar_2012.dta", replace


/*   2014年家庭变量清理   */
use "$cfps2014famecon", clear
gen feduexp = fp510
local varLists "hhinc hhexp hhasset"
foreach varList of local varLists {
    /* Create macros for variable names and labels */
    local varNameList = "${`varList'Var}"
    local varLabelList = "${`varList'VarLab}"
    
    /* Count the number of variables */
    local nvars : word count `varNameList'
    
    /* Loop over each variable and apply its corresponding label */
    forval i = 1/`nvars' {
        local varname : word `i' of `varNameList'
        local varlabel : word `i' of `varLabelList'
        
        label variable `varname' "`varlabel'"
        }
}
gen wave = 2014
keep fid* cid14 countyid14 wave $hhincVar $hhexpVar $hhassetVar $hhbasicVar
save "$temp/FamilyVar_2014.dta", replace


/*   2016年家庭变量清理   */
use "$cfps2016famecon", clear
gen feduexp = fp510
gen familysize = familysize16
local varLists "hhinc hhexp hhasset hhbasic"
foreach varList of local varLists {
    /* Create macros for variable names and labels */
    local varNameList = "${`varList'Var}"
    local varLabelList = "${`varList'VarLab}"
    
    /* Count the number of variables */
    local nvars : word count `varNameList'
    
    /* Loop over each variable and apply its corresponding label */
    forval i = 1/`nvars' {
        local varname : word `i' of `varNameList'
        local varlabel : word `i' of `varLabelList'
        
        label variable `varname' "`varlabel'"
        }
}
gen wave = 2016
keep fid* cid16 countyid16 wave $hhincVar $hhexpVar $hhassetVar $hhbasicVar
save "$temp/FamilyVar_2016.dta", replace

/*   2018年家庭变量清理   */
use "$cfps2018famecon", clear
gen feduexp = fp510
gen familysize = familysize18
local varLists "hhinc hhexp hhasset hhbasic"
foreach varList of local varLists {
    /* Create macros for variable names and labels */
    local varNameList = "${`varList'Var}"
    local varLabelList = "${`varList'VarLab}"
    
    /* Count the number of variables */
    local nvars : word count `varNameList'
    
    /* Loop over each variable and apply its corresponding label */
    forval i = 1/`nvars' {
        local varname : word `i' of `varNameList'
        local varlabel : word `i' of `varLabelList'
        
        label variable `varname' "`varlabel'"
        }
}
gen wave = 2018
keep fid* cid18 countyid18 wave $hhincVar $hhexpVar $hhassetVar $hhbasicVar
save "$temp/FamilyVar_2018.dta", replace


/*   2020年家庭变量清理   */
use "$cfps2020famecon", clear
gen feduexp = fp510
gen familysize = familysize20
local varLists "hhinc hhexp hhasset hhbasic"
foreach varList of local varLists {
    /* Create macros for variable names and labels */
    local varNameList = "${`varList'Var}"
    local varLabelList = "${`varList'VarLab}"
    
    /* Count the number of variables */
    local nvars : word count `varNameList'
    
    /* Loop over each variable and apply its corresponding label */
    forval i = 1/`nvars' {
        local varname : word `i' of `varNameList'
        local varlabel : word `i' of `varLabelList'
        
        label variable `varname' "`varlabel'"
        }
}
gen wave = 2020
keep fid* cid20 countyid20 wave $hhincVar $hhexpVar $hhassetVar $hhbasicVar
save "$temp/FamilyVar_2020.dta", replace

use "$temp/FamilyVar_2012.dta", clear
append using "$temp/FamilyVar_2014.dta"
append using "$temp/FamilyVar_2016.dta"
append using "$temp/FamilyVar_2018.dta"
append using "$temp/FamilyVar_2020.dta"
gen fid = fid12 if wave == 2012
replace fid = fid14 if wave == 2014
replace fid = fid16 if wave == 2016
replace fid = fid18 if wave == 2018
replace fid = fid20 if wave == 2020

save "$wkdata/FamilyVar_2012-2020.dta", replace