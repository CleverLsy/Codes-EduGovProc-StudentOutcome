/*************************
Author: Liu Songyue
Aim: To merge the children panel
Input：
1. 个体面板【pid， 年份】：微观数据
2. 县域教育信息化采购数据【采购人adcode， 年份】
    县域宏观信息也在这个数据中
Output: 
"$wkdata/Child Panel 10_2_22.dta"
$wkdata/ChildWideSample.dta
**************************/

/************************************************
* 青少年面板数据： "$wkdata/Child Panel 10_2_22.dta"


************************************************/
* childrenPanel10_2_22
use "$wkdata/CFPS_IndivLevel_10_2_22.dta", clear
merge m:1  countyid  using "$wkdata/cfpscountyid.dta"
drop _merge
* 生成基本教育标志变量
gen BasicEduFlag = 1 if schstage == 1 | schstage == 2 | schstage == 3 | schstage == 4
* 生成变量 
bysort pid: egen BasicEduStudent = max(BasicEduFlag)


gen 采购人adcode = code
gen 年份 = wave
save "$temp/CFPS child panel_10_2_22 matched with countyid.dta", replace

* 教育信息化采购
use "$wkdata/CountyEduGovProc_IT.dta", clear
keep if 采购人adcode!=.
replace 采购人省代码 = floor(采购人adcode/10000)*10000 if 采购人省代码==.
replace 采购人市代码 = floor(采购人adcode/100)*100 if 采购人市代码==.
keep 采购人省份 采购人省代码 采购人城市 采购人市代码 采购人区县 采购人adcode 年份 BE_Train_Cnt BE_Train_AmtMil BE_Infr_Cnt BE_Infr_AmtMil BE_DigRes_Cnt BE_DigRes_AmtMil BECnt BEAmtMil TotalCnt TotalAmtMil VocCnt VocAmtMil Voc_DigRes_AmtMil Voc_DigRes_Cnt Voc_Infr_AmtMil Voc_Infr_Cnt Voc_Train_AmtMil Voc_Train_Cnt  
gen code = 采购人adcode
merge m:1 code using "$wkdata/cfpscountyid.dta"
keep if _merge ==3
drop _merge

isid 采购人adcode 年份
save "$temp/CountyEduGovProc_IT panel matched with countyid.dta", replace

* 匹配县域变量
use "$rawdata/城市县域变量/学术严选 中国县域年鉴面板数据2000-2022年.dta", clear
ds 年份 行政区划代码, not
local varlist = r(varlist)
foreach var of local varlist {
    rename `var' cnty_`var'
}
keep if 年份>=2008 & 年份<=2022
gen 采购人adcode = 行政区划代码
gen code = 行政区划代码
isid 行政区划代码 年份

merge m:1 code using "$wkdata/cfpscountyid.dta"
keep if _merge==3
drop _merge
save "$temp/xueshuyanxuan CntyVar panel matched with CFPS County.dta", replace

use "$rawdata/城市县域变量/1999~2022年县市社会经济指标.dta", clear
keep if 年份>=2008 & 年份<=2022
keep if 县代码!=.
replace 省代码 = floor(县代码/10000)*10000 if 省代码==.
replace 市代码 = floor(县代码/100)*100 if 市代码==.
rename 普通中学在校学生数_人 普通中学在校生数人
rename 小学在校学生数_人 小学在校生数人
rename 中等职业教育学校在校学生数_人 中等职业教育在校生数人
keep 省 省代码 市 市代码 县 县代码 年份 普通中学在校生数人 小学在校生数人 中等职业教育在校生数人 
foreach v of varlist 普通中学在校生数人 小学在校生数人 中等职业教育在校生数人 {
    rename `v' cnty_`v'
}
gen 采购人省代码 =省代码
gen 采购人市代码 = 市代码
gen 采购人adcode = 县代码
gen code = 采购人adcode
isid code 年份
merge m:1 code using "$wkdata/cfpscountyid.dta"
keep if _merge==3
drop _merge
save "$temp/RStata CntyVar panel matched with CFPS County.dta", replace



* 匹配城市变量
use "$rawdata/城市县域变量/学术严选 中国城市统计年鉴（更新到2022年）.dta", clear
keep if 年份>=2010 & 年份<=2022
ds 年份 行政区划代码, not
local varlist = r(varlist)
foreach var of local varlist {
    rename `var' pref_`var'
}
gen 市代码 = 行政区划代码
gen citycode = 市代码
isid citycode 年份
save "$temp/xueshuyanxuan PrefVar panel.dta", replace

use "$rawdata/城市县域变量/1998～2022年中国城市统计年鉴地级市面板数据.dta", clear
keep if 年份>=2010 & 年份<=2022
drop if 省=="北京市" & 市=="天津市"
rename 第一产业占地区生产总值的比重_全市 第一产业增加值占GDP比重
rename 第二产业占地区生产总值的比重_全市 第二产业增加值占GDP比重
rename 第三产业占地区生产总值的比重_全市 第三产业增加值占GDP比重
rename 人均地区生产总值_元_全市 人均地区生产总值元
rename 普通中学在校学生数_人_全市 普通中学在校学生数人
rename 普通中学_所_全市 普通中学学校数所
rename 普通小学_所_全市 普通小学学校数所
rename 普通小学在校学生数_人_全市 普通小学在校学生数人
keep 省 省代码 市 市代码 年份 第一产业增加值占GDP比重 第二产业增加值占GDP比重 第三产业增加值占GDP比重 人均地区生产总值元 普通中学在校学生数人 普通中学学校数所 普通小学学校数所 普通小学在校学生数人
foreach v of varlist 第一产业增加值占GDP比重 第二产业增加值占GDP比重 第三产业增加值占GDP比重 人均地区生产总值元 普通中学在校学生数人 普通中学学校数所 普通小学学校数所 普通小学在校学生数人 {
    rename `v' pref_`v'
}
gen citycode = 市代码
duplicates drop citycode 年份, force
isid citycode 年份
save "$temp/RStata PrefVar panel.dta", replace


use "$temp/CFPS child panel_10_2_22 matched with countyid.dta", clear
merge m:1 code 年份 using "$temp/CountyEduGovProc_IT panel matched with countyid.dta"
keep if _merge!=2
drop _merge

merge m:1 code 年份 using "$temp/xueshuyanxuan CntyVar panel matched with CFPS County.dta", update
keep if _merge!=2
drop _merge

merge m:1 code 年份 using "$temp/RStata CntyVar panel matched with CFPS County.dta", update
keep if _merge!=2
drop _merge

merge m:1 citycode 年份 using "$temp/xueshuyanxuan PrefVar panel.dta", update
keep if _merge!=2
drop _merge

merge m:1 citycode 年份 using "$temp/RStata PrefVar panel.dta", update
keep if _merge!=2
drop _merge

xtset pid 年份  
save "$wkdata/Child Panel 10_2_22.dta", replace




/************************************************
* ChildWideSample

如何处理效果滞后的问题：
    差分回归： 2022-2018的认知能力变化 对2014-2017年的教育信息化采购金额回归
    需要对数据重新处理成方便回归的形式

************************************************/

use "$wkdata/CFPS_IndivLevel_10_2_22.dta", clear
merge m:1  countyid  using "$wkdata/cfpscountyid.dta"
keep if _merge!=2
drop _merge



gen BasicEduFlag = 1 if schstage == 1 | schstage == 2 | schstage == 3 | schstage == 4
keep if fid!=. 
keep pid fid countyname code provname wave urban mathtest wordtest BasicEduFlag gender age eduyim_m eduyim_f age_f age_m

ds pid wave, not
local varlist = r(varlist)
display "`varlist'"
reshape wide `varlist', i(pid) j(wave)
global sample = "if BasicEduFlag2018== 1 | BasicEduFlag2020== 1 | BasicEduFlag2022== 1"
count $sample
gen mathtest22_18 = (mathtest2022 / mathtest2018 - 1 )* 100
label var mathtest22_18 "2022-2018的数学测试成绩变化"
gen wordtest22_18 = (wordtest2022 / wordtest2018 - 1 )* 100
label var wordtest22_18 "2022-2018的语文测试成绩变化"
gen mathtest18_14 = (mathtest2018 / mathtest2014 - 1 )* 100
label var mathtest18_14 "2018-2014的数学测试成绩变化"
gen wordtest18_14 = (wordtest2018 / wordtest2014 - 1 )* 100
label var wordtest18_14 "2018-2014的语文测试成绩变化"
gen mathtest14_10 = (mathtest2014 / mathtest2010 - 1 )* 100
label var mathtest14_10 "2014-2010的数学测试成绩变化"
gen wordtest14_10 = (wordtest2014 / wordtest2010 - 1 )* 100
label var wordtest14_10 "2014-2010的语文测试成绩变化"
sum mathtest22_18 mathtest18_14 mathtest14_10 wordtest22_18 wordtest18_14 wordtest14_10 $sample
order pid fid2010 fid2012 fid2014 fid2016 fid2018 fid2020 fid2022 countyname2010 countyname2012 countyname2014 countyname2016 countyname2018 countyname2020 countyname2022  code2010  code2012 code2014 code2016 code2018 code2020 code2022 provname2010 provname2012 provname2014 provname2016 provname2018 provname2020 provname2022 mathtest2010 mathtest2012 mathtest2014 mathtest2016 mathtest2018 mathtest2020 mathtest2022 wordtest2010 wordtest2012 wordtest2014 wordtest2016 wordtest2018 wordtest2020 wordtest2022 BasicEduFlag2010 BasicEduFlag2012 BasicEduFlag2014 BasicEduFlag2016 BasicEduFlag2018 BasicEduFlag2020 BasicEduFlag2022 gender2010 gender2012 gender2014 gender2016 gender2018 gender2020 gender2022 age2010 age2012 age2014 age2016 age2018 age2020 age2022 eduyim_m2010 eduyim_m2012  eduyim_m2014 eduyim_m2016 eduyim_m2018 eduyim_m2020  eduyim_m2022 eduyim_f2010 eduyim_f2012 eduyim_f2014 eduyim_f2016 eduyim_f2018 eduyim_f2020  eduyim_f2022 age_f2010 age_f2012 age_f2014 age_f2016 age_f2018 age_f2020 age_f2022 age_m2010 age_m2012 age_m2014 age_m2016 age_m2018 age_m2020 age_m2022

* 2018-2022年间所待的地区
gen adcode = code2022
replace adcode = code2020 if code2020!=.
replace adcode = code2018 if code2018!=.
sum adcode if (BasicEduFlag2018== 1 | BasicEduFlag2020== 1 | BasicEduFlag2022== 1) & mathtest22_18!=. & wordtest22_18!=. & mathtest18_14!=. & wordtest18_14!=.

rename adcode 采购人adcode
label var 采购人adcode "2018-2022年间所待的地区"
gen code = 采购人adcode
save "$temp/CFPS_Child_Wide.dta", replace



* 县域信息化采购数据
use "$wkdata/CountyEduGovProc_IT.dta", clear
keep if 采购人adcode!=.
replace 采购人省代码 = floor(采购人adcode/10000)*10000 if 采购人省代码==.
replace 采购人市代码 = floor(采购人adcode/100)*100 if 采购人市代码==.
keep 采购人省份 采购人省代码 采购人城市 采购人市代码 采购人区县 采购人adcode 年份 BE_Train_Cnt BE_Train_AmtMil BE_Infr_Cnt BE_Infr_AmtMil BE_DigRes_Cnt BE_DigRes_AmtMil BECnt BEAmtMil TotalCnt TotalAmtMil VocCnt VocAmtMil Voc_DigRes_AmtMil Voc_DigRes_Cnt Voc_Infr_AmtMil Voc_Infr_Cnt Voc_Train_AmtMil Voc_Train_Cnt  
reshape wide TotalCnt TotalAmtMil  BE_Train_Cnt BE_Train_AmtMil BE_Infr_Cnt BE_Infr_AmtMil BE_DigRes_Cnt BE_DigRes_AmtMil BECnt BEAmtMil VocCnt VocAmtMil Voc_DigRes_AmtMil Voc_DigRes_Cnt Voc_Infr_AmtMil Voc_Infr_Cnt Voc_Train_AmtMil Voc_Train_Cnt, i(采购人省份 采购人省代码 采购人城市 采购人市代码 采购人区县  采购人adcode) j(年份)


gen code = 采购人adcode
merge 1:1 code using "$wkdata/cfpscountyid.dta"
keep if _merge ==3
drop _merge

isid 采购人adcode
save "$temp/CountyEduGovProc_IT_Wide.dta", replace

use "$wkdata/cfpscountyid.dta", clear
merge 1:1 code using "$temp/CountyEduGovProc_IT_Wide.dta"
keep if _merge !=2
drop _merge
isid code
ds 采购人省份 采购人省代码 采购人市代码 采购人城市 采购人区县 采购人adcode provname countyname countyid code cityname citycode, not
foreach var of varlist `r(varlist)' {
    replace `var' = 0 if `var'==.
}

egen TotalCnt14_17 = rowtotal(TotalCnt2014 TotalCnt2015 TotalCnt2016 TotalCnt2017)
egen TotalAmtMil14_17 = rowtotal(TotalAmtMil2014 TotalAmtMil2015 TotalAmtMil2016 TotalAmtMil2017)
egen BE_Train_Cnt14_17 = rowtotal(BE_Train_Cnt2014 BE_Train_Cnt2015 BE_Train_Cnt2016 BE_Train_Cnt2017)
egen BE_Train_AmtMil14_17 = rowtotal(BE_Train_AmtMil2014 BE_Train_AmtMil2015 BE_Train_AmtMil2016 BE_Train_AmtMil2017)
egen BE_Infr_Cnt14_17 = rowtotal(BE_Infr_Cnt2014 BE_Infr_Cnt2015 BE_Infr_Cnt2016 BE_Infr_Cnt2017)
egen BE_Infr_AmtMil14_17 = rowtotal(BE_Infr_AmtMil2014 BE_Infr_AmtMil2015 BE_Infr_AmtMil2016 BE_Infr_AmtMil2017)
egen BE_DigRes_Cnt14_17 = rowtotal(BE_DigRes_Cnt2014 BE_DigRes_Cnt2015 BE_DigRes_Cnt2016 BE_DigRes_Cnt2017)
egen BE_DigRes_AmtMil14_17 = rowtotal(BE_DigRes_AmtMil2014 BE_DigRes_AmtMil2015 BE_DigRes_AmtMil2016 BE_DigRes_AmtMil2017)
egen BECnt14_17 = rowtotal(BECnt2014 BECnt2015 BECnt2016 BECnt2017)
egen BEAmtMil14_17 = rowtotal(BEAmtMil2014 BEAmtMil2015 BEAmtMil2016 BEAmtMil2017)
egen VocCnt14_17 = rowtotal(VocCnt2014 VocCnt2015 VocCnt2016 VocCnt2017)
egen VocAmtMil14_17 = rowtotal(VocAmtMil2014 VocAmtMil2015 VocAmtMil2016 VocAmtMil2017)
egen Voc_DigRes_Cnt14_17 = rowtotal(Voc_DigRes_Cnt2014 Voc_DigRes_Cnt2015 Voc_DigRes_Cnt2016 Voc_DigRes_Cnt2017)
egen Voc_DigRes_AmtMil14_17 = rowtotal(Voc_DigRes_AmtMil2014 Voc_DigRes_AmtMil2015 Voc_DigRes_AmtMil2016 Voc_DigRes_AmtMil2017)
egen Voc_Infr_Cnt14_17 = rowtotal(Voc_Infr_Cnt2014 Voc_Infr_Cnt2015 Voc_Infr_Cnt2016 Voc_Infr_Cnt2017)
egen Voc_Infr_AmtMil14_17 = rowtotal(Voc_Infr_AmtMil2014 Voc_Infr_AmtMil2015 Voc_Infr_AmtMil2016 Voc_Infr_AmtMil2017)
egen Voc_Train_Cnt14_17 = rowtotal(Voc_Train_Cnt2014 Voc_Train_Cnt2015 Voc_Train_Cnt2016 Voc_Train_Cnt2017)
egen Voc_Train_AmtMil14_17 = rowtotal(Voc_Train_AmtMil2014 Voc_Train_AmtMil2015 Voc_Train_AmtMil2016 Voc_Train_AmtMil2017)
save "$temp/CountyEduGovProc_IT_Wide Matched with CFPS County.dta", replace



* 匹配区县变量
use "$rawdata/城市县域变量/1999~2022年县市社会经济指标.dta", clear
keep if 年份>=2010 & 年份<=2022
keep if 县代码!=.
replace 省代码 = floor(县代码/10000)*10000 if 省代码==.
replace 市代码 = floor(县代码/100)*100 if 市代码==.
rename 普通中学在校学生数_人 普通中学在校生数人
rename 小学在校学生数_人 小学在校生数人
rename 中等职业教育学校在校学生数_人 中等职业教育在校生数人
keep 省 省代码 市 市代码 县 县代码 年份 普通中学在校生数人 小学在校生数人 中等职业教育在校生数人 
foreach var in 普通中学在校生数人 小学在校生数人 中等职业教育在校生数人 {
    rename `var' cnty_`var'
}
reshape wide cnty_普通中学在校生数人 cnty_小学在校生数人 cnty_中等职业教育在校生数人, i(省 省代码 市 市代码 县 县代码) j(年份)
gen 采购人省代码 =省代码
gen 采购人市代码 = 市代码
gen 采购人adcode = 县代码
gen code = 采购人adcode
merge 1:1 code using "$wkdata/cfpscountyid.dta"
br provname cityname countyname if _merge==2
keep if _merge==3
drop _merge
save "$temp/RStata CntyVar Wide matched with CFPS County.dta", replace

use "$rawdata/城市县域变量/学术严选 中国县域年鉴面板数据2000-2022年.dta", clear
keep if 年份>=2010 & 年份<=2022

keep 行政区划代码  年份 地区生产总值万元 年末总人口万人 人均地区生产总值元人  第一产业增加值万元 第二产业增加值万元 第三产业增加值万元 地方财政一般预算收入万元 地方财政一般预算支出万元  普通小学学校数个 普通小学在校生数人 普通小学专任教师数人 普通中学学校数个 普通中学在校学生数人 普通中学专任教师数人    中等职业教育学校在校学生数人
foreach var in 地区生产总值万元 年末总人口万人 人均地区生产总值元人  第一产业增加值万元 第二产业增加值万元 第三产业增加值万元 地方财政一般预算收入万元 地方财政一般预算支出万元  普通小学学校数个 普通小学在校生数人 普通小学专任教师数人 普通中学学校数个 普通中学在校学生数人 普通中学专任教师数人    中等职业教育学校在校学生数人 {
    rename `var' cnty_`var'
}
reshape wide cnty_地区生产总值万元 cnty_年末总人口万人 cnty_人均地区生产总值元人 cnty_第一产业增加值万元 cnty_第二产业增加值万元 cnty_第三产业增加值万元 cnty_地方财政一般预算收入万元 cnty_地方财政一般预算支出万元 cnty_普通小学学校数个 cnty_普通小学在校生数人 cnty_普通小学专任教师数人 cnty_普通中学学校数个 cnty_普通中学在校学生数人 cnty_普通中学专任教师数人 cnty_中等职业教育学校在校学生数人, i(行政区划代码) j(年份)

gen 采购人adcode = 行政区划代码
gen code = 行政区划代码
isid 行政区划代码
merge 1:1 code using "$wkdata/cfpscountyid.dta"
drop _merge
save "$temp/xueshuyanxuan CntyVar Wide matched with CFPS County.dta", replace

use "$wkdata/cfpscountyid.dta", clear
merge 1:1 code using "$temp/xueshuyanxuan CntyVar Wide matched with CFPS County.dta", update
keep if _merge!=2
drop _merge
merge 1:1 code using "$temp/RStata CntyVar Wide matched with CFPS County.dta", update
keep if _merge!=2
drop _merge

egen cnty_普通中小学学校数2014 = rowtotal(cnty_普通小学学校数个2014 cnty_普通中学学校数个2014)
egen cnty_普通中小学学校数2015 = rowtotal(cnty_普通小学学校数个2015 cnty_普通中学学校数个2015)
egen cnty_普通中小学学校数2016 = rowtotal(cnty_普通小学学校数个2016 cnty_普通中学学校数个2016)
egen cnty_普通中小学学校数2017 = rowtotal(cnty_普通小学学校数个2017 cnty_普通中学学校数个2017)
egen cnty_普通中小学学校数2018 = rowtotal(cnty_普通小学学校数个2018 cnty_普通中学学校数个2018)
egen cnty_普通中小学学校数2019 = rowtotal(cnty_普通小学学校数个2019 cnty_普通中学学校数个2019)
egen cnty_普通中小学学校数2020 = rowtotal(cnty_普通小学学校数个2020 cnty_普通中学学校数个2020)
egen cnty_普通中小学学校数2021 = rowtotal(cnty_普通小学学校数个2021 cnty_普通中学学校数个2021)
egen cnty_普通中小学学校数2022 = rowtotal(cnty_普通小学学校数个2022 cnty_普通中学学校数个2022)
egen cnty_普通中小学在校生数2014 = rowtotal(cnty_普通小学在校生数人2014 cnty_普通中学在校学生数人2014)
egen cnty_普通中小学在校生数2015 = rowtotal(cnty_普通小学在校生数人2015 cnty_普通中学在校学生数人2015)
egen cnty_普通中小学在校生数2016 = rowtotal(cnty_普通小学在校生数人2016 cnty_普通中学在校学生数人2016)
egen cnty_普通中小学在校生数2017 = rowtotal(cnty_普通小学在校生数人2017 cnty_普通中学在校学生数人2017)
egen cnty_普通中小学在校生数2018 = rowtotal(cnty_普通小学在校生数人2018 cnty_普通中学在校学生数人2018)
egen cnty_普通中小学在校生数2019 = rowtotal(cnty_普通小学在校生数人2019 cnty_普通中学在校学生数人2019)
egen cnty_普通中小学在校生数2020 = rowtotal(cnty_普通小学在校生数人2020 cnty_普通中学在校学生数人2020)
egen cnty_普通中小学在校生数2021 = rowtotal(cnty_普通小学在校生数人2021 cnty_普通中学在校学生数人2021)
egen cnty_普通中小学在校生数2022 = rowtotal(cnty_普通小学在校生数人2022 cnty_普通中学在校学生数人2022)


save "$temp/CntyVar Wide matched with CFPS County.dta", replace


/*
merge 1:1 采购人adcode using "$temp/CountyEduGovProc_IT_Wide.dta"
keep if _merge!= 1
drop _merge
save "$temp/CntyVar matched with CFPS County.dta", replace
*/
* 匹配城市变量
use "$rawdata/城市县域变量/学术严选 中国城市统计年鉴（更新到2022年）.dta", clear
keep if 年份>=2010 & 年份<=2022
gen 市代码 = 行政区划代码
keep 市代码 年份  地区生产总值万元 户籍人口万人 常住人口  年平均人口万人 人均地区生产总值元  第一产业增加值占GDP比重 第一产业增加值万元 第二产业增加值占GDP比重 第二产业增加值万元 第三产业增加值占GDP比重 第三产业增加值万元  电信业务总量万元 国际互联网用户数户   本地电话年末用户数万户 教育支出万元 小学学校数所 小学在校学生数万人 小学专任教师数人 普通中学学校数所 普通中学在校学生数万人 普通中学专任教师数人 每万人在校中等职业学生数人 中等职业教育学校数所 中等职业技术学校在校学生数人 中等职业教育学校专任教师数人 高中阶段在校学生数人 普通高等学校学校数所 普通高等学校在校学生数人 普通高等学校专任教师数人 普通本专科在校学生数人   每万人在校大学生数人
foreach var in 地区生产总值万元 户籍人口万人 常住人口  年平均人口万人 人均地区生产总值元  第一产业增加值占GDP比重 第一产业增加值万元 第二产业增加值占GDP比重 第二产业增加值万元 第三产业增加值占GDP比重 第三产业增加值万元  电信业务总量万元 国际互联网用户数户   本地电话年末用户数万户 教育支出万元 小学学校数所 小学在校学生数万人 小学专任教师数人 普通中学学校数所 普通中学在校学生数万人 普通中学专任教师数人 每万人在校中等职业学生数人 中等职业教育学校数所 中等职业技术学校在校学生数人 中等职业教育学校专任教师数人 高中阶段在校学生数人 普通高等学校学校数所 普通高等学校在校学生数人 普通高等学校专任教师数人 普通本专科在校学生数人   每万人在校大学生数人  {
    rename `var' pref_`var'
}
reshape wide pref_地区生产总值万元 pref_户籍人口万人 pref_常住人口  pref_年平均人口万人  pref_人均地区生产总值元  pref_第一产业增加值占GDP比重 pref_第一产业增加值万元 pref_第二产业增加值占GDP比重 pref_第二产业增加值万元 pref_第三产业增加值占GDP比重 pref_第三产业增加值万元  pref_电信业务总量万元 pref_国际互联网用户数户  pref_本地电话年末用户数万户 pref_教育支出万元 pref_小学学校数所 pref_小学在校学生数万人 pref_小学专任教师数人 pref_普通中学学校数所 pref_普通中学在校学生数万人 pref_普通中学专任教师数人 pref_每万人在校中等职业学生数人 pref_中等职业教育学校数所 pref_中等职业技术学校在校学生数人 pref_中等职业教育学校专任教师数人 pref_高中阶段在校学生数人 pref_普通高等学校学校数所 pref_普通高等学校在校学生数人 pref_普通高等学校专任教师数人 pref_普通本专科在校学生数人  pref_每万人在校大学生数人, i(市代码) j(年份)
gen citycode = 市代码
save "$temp/xueshuyanxuan PrefVar Wide.dta", replace




use "$rawdata/城市县域变量/1998～2022年中国城市统计年鉴地级市面板数据.dta", clear
keep if 年份>=2010 & 年份<=2022
drop if 省=="北京市" & 市=="天津市"
rename 第一产业占地区生产总值的比重_全市 第一产业增加值占GDP比重
rename 第二产业占地区生产总值的比重_全市 第二产业增加值占GDP比重
rename 第三产业占地区生产总值的比重_全市 第三产业增加值占GDP比重
rename 人均地区生产总值_元_全市 人均地区生产总值元
rename 普通中学在校学生数_人_全市 普通中学在校学生数人
rename 普通中学_所_全市 普通中学学校数所
rename 普通小学_所_全市 普通小学学校数所
rename 普通小学在校学生数_人_全市 普通小学在校学生数人
keep 省 省代码 市 市代码 年份 第一产业增加值占GDP比重 第二产业增加值占GDP比重 第三产业增加值占GDP比重 人均地区生产总值元 普通中学在校学生数人 普通中学学校数所 普通小学学校数所 普通小学在校学生数人
foreach var in 第一产业增加值占GDP比重 第二产业增加值占GDP比重 第三产业增加值占GDP比重 人均地区生产总值元 普通中学在校学生数人 普通中学学校数所 普通小学学校数所 普通小学在校学生数人 {
    rename `var' pref_`var'
}
reshape wide pref_第一产业增加值占GDP比重 pref_第二产业增加值占GDP比重 pref_第三产业增加值占GDP比重 pref_人均地区生产总值元 pref_普通中学在校学生数人 pref_普通中学学校数所 pref_普通小学学校数所 pref_普通小学在校学生数人, i(省 省代码 市 市代码) j(年份)
gen citycode = 市代码
duplicates drop citycode, force
isid citycode
save "$temp/RStata PrefVar Wide.dta", replace



use "$wkdata/cfpscountyid.dta", clear
merge m:1 citycode using "$temp/xueshuyanxuan PrefVar Wide.dta", update
keep if _merge!=2
drop _merge
merge m:1 citycode  using "$temp/RStata PrefVar Wide.dta", update
keep if _merge!=2
drop _merge

save "$temp/PrefVar Wide matched with CFPS County.dta", replace



use "$temp/CFPS_Child_Wide.dta", clear
merge m:1 code using "$temp/CountyEduGovProc_IT_Wide Matched with CFPS County.dta"
keep if _merge!=2
drop _merge
merge m:1 code using "$temp/PrefVar Wide matched with CFPS County.dta"
keep if _merge!=2
drop _merge
merge m:1 code using "$temp/CntyVar Wide matched with CFPS County.dta"
keep if _merge!=2
drop _merge




global sample = "if (BasicEduFlag2018== 1 | BasicEduFlag2020== 1 | BasicEduFlag2022== 1) & mathtest22_18!=. & wordtest22_18!=. & mathtest18_14!=. & wordtest18_14!=. & mathtest14_10!=. & wordtest14_10!=. & TotalCnt14_17!=. & TotalAmtMil14_17!=. & BECnt14_17!=. & BEAmtMil14_17!=.  "
count $sample

gen BECnt14_17persch = BECnt14_17 / cnty_普通中小学学校数2014 
gen BEAmtTho14_17persch = BEAmtMil14_17 / cnty_普通中小学学校数2014 * 1000
gen BE_Infr_Cnt14_17persch = BE_Infr_Cnt14_17 / cnty_普通中小学学校数2014 
gen BE_Infr_AmtTho14_17persch = BE_Infr_AmtMil14_17 / cnty_普通中小学学校数2014 * 1000
gen BE_DigRes_Cnt14_17persch = BE_DigRes_Cnt14_17 / cnty_普通中小学学校数2014
gen BE_DigRes_AmtTho14_17persch = BE_DigRes_AmtMil14_17 / cnty_普通中小学学校数2014 * 1000

gen BECnt14_17persch_lg = ln(1+ BECnt14_17persch)
gen BEAmt14_17persch_lg = ln(1+ BEAmtTho14_17persch*1000)
gen BE_Infr_Cnt14_17persch_lg = ln(1 + BE_Infr_Cnt14_17persch)
gen BE_Infr_Amt14_17persch_lg = ln(1 + BE_Infr_AmtTho14_17persch * 1000)
gen BE_DigRes_Cnt14_17persch_lg = ln(1 + BE_DigRes_Cnt14_17persch)
gen BE_DigRes_Amt14_17persch_lg = ln(1 + BE_DigRes_AmtTho14_17persch * 1000)


gen rural2018 = (urban2018==0)

gen BECnt14_17rural  = BECnt14_17 * rural2018
gen BEAmtMil14_17rural = BEAmtMil14_17*rural2018
gen BE_Infr_Cnt14_17rural = BE_Infr_Cnt14_17*rural2018
gen BE_Infr_AmtMil14_17rural = BE_Infr_AmtMil14_17*rural2018
gen BE_DigRes_Cnt14_17rural = BE_DigRes_Cnt14_17*rural2018
gen BE_DigRes_AmtMil14_17rural = BE_DigRes_AmtMil14_17*rural2018

gen BECnt14_17perschrural = BECnt14_17persch*rural2018
gen BE_Infr_Cnt14_17perschrural = BE_Infr_Cnt14_17persch *rural2018
gen BE_DigRes_Cnt14_17perschrural = BE_DigRes_Cnt14_17persch *rural2018
gen BEAmtTho14_17perschrural = BEAmtTho14_17persch*rural2018
gen BE_Infr_AmtTho14_17perschrural = BE_Infr_AmtTho14_17persch*rural2018
gen BE_DigRes_AmtTho14_17perschrural = BE_DigRes_AmtTho14_17persch*rural2018

gen BECnt14_17perschlgrural = BECnt14_17persch_lg*rural2018
gen BEAmt14_17perschlgrural = BEAmt14_17persch_lg*rural2018
gen BE_Infr_Cnt14_17perschlgrural = BE_Infr_Cnt14_17persch_lg*rural2018
gen BE_Infr_Amt14_17perschlgrural = BE_Infr_Amt14_17persch_lg*rural2018
gen BE_DigRes_Cnt14_17perschlgrural = BE_DigRes_Cnt14_17persch_lg*rural2018
gen BE_DigRes_Amt14_17perschlgrural = BE_DigRes_Amt14_17persch_lg*rural2018

save "$wkdata/ChildWideSample.dta", replace
cap erase "$temp"
