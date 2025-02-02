/* ========================================================================
 * Program: 1-01-01_Clean_CFPS_ChildVar
 * Data:	CFPS 2010-2020
 * Author:  Songyue Liu
 * Aim:  
0. 编码
pid fid cid countyid provcd   
样本： 6-15岁 青少年
1. 个人基本变量：
gender birthy han 
age  hukou urban marriage schdum workdum cfpsXXeduy->eduy  cfpsXXeduy_im->eduyim schstage
  在校生schdum20==1 相关变量
    grade primaryType juniorType seniorType publicschdum modelschdum  classnum gradenum classrank graderank unattendnum nonweekendStudyHour weekendStudyHour talentImp  acdemicStress acdemicSatifaction excellent schoolSatifaction monitorSatifaction MathTeaSatifaction ChineseTeaSatifaction EnglishTeaSatifaction privateTutor schoolTutor schoolTutorHour  tutorExpense
2. 核心解释变量：
    2010有网络模块，2012年没有，2014/16/18年的问法基本一致，2020年进行了微调。其中14/16采用的是共用模块的设置，18/20分为自答问卷和父母待答问卷两部分。
    InternetDummy InternetMinute InternetStudyDummy InternetStudyMinute InternetStudyDaily InternetStudyFreq InternetWorkDummy InternetWorkDaily InternetWorkFreq InternetSocialDummy InternetSocialDaily InternetSocialFreq InternetEntertainmentDummy InternetEntertainmentDaily InternetEntertainmentFreq InternetShoppingDummy InternetShoppingDaily InternetShoppingFreq 
3. 结果变量：
    排名
    学业评价
    认知能力测试： dwr iwr1 iwr2 ns_w ns_wse ns_g（2012 2016 2020）
    非认知能力测试：        
    心理健康：
    网络素养

    其他个人特质
        大五人格 （2018）
            【AI的建议：人格特质通常被认为是相对稳定的个体特征，它们在成年早期形成并在一生中变化不大。需要说明为什么以及如何网络使用和网络学习可能会影响人格特质。这可能包括对现有文献的综述，以及对潜在机制的讨论。而且网络使用和网络学习可能是人格特质的反映（例如，外向性高的人可能更倾向于社交网络的使用），而不是其原因。因此更适合作为调节变量】
        成就影响因素（2020）
        内外化问题行为（2018）
        自尊
        自控（2018）
        控制点（2018）
        流调中心抑郁量表
        责任感量表（2010-16是所有上学人群，18是小学及以上上学人群随机25%，20年，10岁及以上未测量）
    行为或知识测量
        青少年行为测量（2018）
        青少年知识测量（2018）
    私人教育支出
    
    
可能的机制或调节变量：
    亲子关系
        父母教养方式
        对孩子学习的关怀
        教育期望
        职业期望
        与父母关系
    主观态度
        学校满意度
        互联网功能重要性
        信息获取渠道重要性

4. 家庭层面控制变量
家庭资产、家庭收入、父母教育水平、家庭成员数量、父母婚姻情况、户口情况、居住地城乡

 * Revised: 2024-04-24
 * Output: 
    "pid  pid_f pid_m resppid fid fid10 fid12 fid14 fid16 fid18 fid20 fidbaseline cid cid14 cid16 cid18 cid20 countyid countyid 14 countyid16 countyid 18 countyid20 wave indsurvey indsurvey14 indsurvey16 indsurvey18 indsurvey20" 
    "$temp/CFPS_IndividualVar_2014.dta" [pid] fid fid_m fid_f countyid wave
    "$temp/CFPS_IndividualVar_2016.dta" [pid]
    "$temp/CFPS_IndividualVar_2018.dta" [pid]
    "$temp/CFPS_IndividualVar_2020.dta" [pid]
    "$temp/CFPS_IndividualVar_14161820.dta" [pid wave]

    
    "$temp/CFPS_MotherFeature_2014.dta" [pid_m]
    "$temp/CFPS_MotherFeature_2016.dta" [pid_m]
    "$temp/CFPS_MotherFeature_2018.dta" [pid_m]
    "$temp/CFPS_MotherFeature_2020.dta" [pid_m]
    "$temp/CFPS_MotherFeature_14161820.dta" [pid_m wave]

    "$temp/CFPS_FatherFeature_2014.dta" [pid_f]
    "$temp/CFPS_FatherFeature_2016.dta" [pid_f]
    "$temp/CFPS_FatherFeature_2018.dta" [pid_f]
    "$temp/CFPS_FatherFeature_2020.dta" [pid_f]
    "$temp/CFPS_FatherFeature_14161820.dta" [pid_f wave]





    


 ==================================================================== */


/*0. prepare work*/
clear
set more off
capture log close


log using "$logs/1-01-02_Clean_CFPS_PersonVar.log",replace


global id_all = "pid  pid_f pid_m fid*  cid* countyid*  code countyname cityname  provname wave indsurvey*"



* 个人基本特征
global indivDemoVarList2010 = "gender birthy age han hukou urban marriage schdum workdum eduy eduyim schstage"
global indivDemoVarList2012 = "gender birthy age han hukou urban marriage schdum workdum eduy eduyim schstage"
global indivDemoVarList2014 = "gender birthy age han hukou urban marriage schdum workdum eduy eduyim schstage"
global indivDemoVarList2016 = "gender birthy age han hukou urban marriage schdum workdum eduy eduyim schstage grade"
global indivDemoVarList2018 = "gender birthy age han hukou urban marriage schdum workdum eduy eduyim schstage grade"
global indivDemoVarList2020 = "gender birthy age han hukou urban marriage schdum workdum eduy eduyim schstage grade"

* 网络模块
global InternetVarList2010 = ""
global InternetVarList2012 = ""
global internetVarList2014 = "InternetDummy InternetMinute InternetStudyDummy InternetStudy_LastWeek  InternetStudyDaily InternetStudyFreq InternetWorkDummy InternetWorkDaily InternetWorkFreq InternetSocialDummy InternetSocialDaily InternetSocialFreq InternetEntertainmentDummy InternetEntertainment_LastWeek InternetEntertainmentDaily InternetEntertainmentFreq InternetShoppingDummy InternetShoppingDaily InternetShoppingFreq" 
global internetVarList2016 = "InternetDummy InternetMinute InternetStudyDummy  InternetStudy_LastWeek   InternetStudyDaily InternetStudyFreq InternetWorkDummy InternetWorkDaily InternetWorkFreq InternetSocialDummy InternetSocialDaily InternetSocialFreq InternetEntertainmentDummy InternetEntertainment_LastWeek InternetEntertainmentDaily InternetEntertainmentFreq InternetShoppingDummy InternetShoppingDaily InternetShoppingFreq"
global internetVarList2018 = "InternetDummy InternetMinute InternetStudyDummy InternetStudy_LastWeek    InternetStudyDaily InternetStudyFreq InternetWorkDummy InternetWorkDaily InternetWorkFreq InternetSocialDummy InternetSocialDaily InternetSocialFreq InternetEntertainmentDummy InternetEntertainment_LastWeek InternetEntertainmentDaily InternetEntertainmentFreq InternetShoppingDummy InternetShoppingDaily InternetShoppingFreq"
global internetVarList2020 = "InternetDummy InternetMinute InternetStudyDummy InternetStudy_LastWeek   InternetStudyMinute InternetStudyDaily  InternetEntertainmentDummy InternetEntertainment_LastWeek InternetEntertainmentDaily  InternetShoppingDummy InternetShoppingDaily"

* 父母养育观念量表  2014/2020
global parentingBelifsVarList2010 = ""
global parentingBelifsVarList2012 = ""
global parentingBelifsVarList2014 = "we101 we102 we103 we104 we105 we106 we107 we108"
global parentingBelifsVarList2016 = ""
global parentingBelifsVarList2018 = ""
global parentingBelifsVarList2020 = "we101 we102 we103 we104 we105 we106 we107 we108"
* 父母教养方式 
* 2014: 10-12岁
* 2020: 10-18岁
global parentingStyleVarList2010 = ""
global parentingStyleVarList2012 = ""
global parentingStyleVarList2014 = "wm201 wm202 wm203 wm204 wm205 wm206 wm207 wm208 wm209 wm210 wm211 wm212 wm213 wm214"
global parentingStyleVarList2016 = ""
global parentingStyleVarList2018 = ""
global parentingStyleVarList2020 = "wm201 wm202 wm203 wm204 wm205 wm206 wm207 wm208 wm209 wm210 wm211 wm212 wm213 wm214"

*  认知能力测试 需要另外生成
global cognitiveTestVarList2010 = ""
global cognitiveTestVarList2012 = ""
global cognitiveTestVarList2014 = "wordtest mathtest"  
global cognitiveTestVarList2016 = "iwr dwr ns_w"
global cognitiveTestVarList2018 = "wordtest mathtest"  
global cognitiveTestVarList2020 = "iwr dwr ns_w"



* 青少年个体教育支出 需要另外生成
global indivEduExpVarList2010 = "peduexp peduexp_tutor"
global indivEduExpVarList2012 = "peduexp peduexp_tutor peduexp_software"
global indivEduExpVarList2014 = "peduexp peduexp_tutor peduexp_software"
global indivEduExpVarList2016 = "peduexp peduexp_sch peduexp_tutor"
global indivEduExpVarList2018 = "peduexp peduexp_sch peduexp_tutor"
global indivEduExpVarList2020 = "peduexp peduexp_sch peduexp_tutor"

local module = "indivDemoVarList internetVarList cognitiveTestVarList parentingBelifsVarList parentingStyleVarList indivEduExpVarList"
local wave = "2010 2012 2014 2016 2018 2020"
foreach w of local wave{
    global indivVarList`w' = ""
    foreach m of local module {
        local varList = "`m'`w'"
        global indivVarList`w' = "${indivVarList`w'} ${`varList'}"
        
    }
    dis "`w'年的变量有：${indivVarList`w'}"
}



/*              2010年 个人基本特征和核心解释变量数据清理                  */

use "$cfps2020crossyearid", clear
merge 1:1 pid using "$cfps2016crossyearid", force update
keep if _merge!=2
drop _merge
merge 1:1 pid using "$cfps2010adult", force update
drop _merge
merge 1:1 pid using "$cfps2010child", force update
keep if indsurvey10>0  //2014年存在个人问卷
drop _merge
tab indsurvey10
tab indsurvey10, nolabel //1 成人问卷 2 少儿问卷

* 个人基本变量
codebook cid countyid 
gen indsurvey = indsurvey10
* gender
* birthy
* age
cap drop age
gen age = 2010 - birthy
label var age "年龄"

* han
cap drop han
gen han = (ethnicity==1)
label var han "汉族"

* hukou
cap drop hukou
tab hk10
tab hk10, nolabel
recode hk10 (1=1 "农业户口")(3  = 0 "非农户口")(-8 -2 -1 5 79 = .), gen(hukou)
label var hukou "户口类型,农业户口=1, 非农户口=0"

* urban
cap drop urban
tab urban10
tab urban10, nolabel
gen urban = urban10
replace urban = . if urban<0
label var urban "城乡,城镇=1,乡村=0"

* marriage
cap drop marriage
tab marriage_10
tab marriage_10, nolabel
gen marriage = (marriage_10 == 2) // 1 未婚 3 同居 4 离异 5 丧偶
replace marriage = . if marriage_12 < 0
label var marriage "婚姻状况,在婚=1"

* schdum
cap drop schdum
gen schdum = atschool2010
replace schdum = . if atschool2010 < 0
label var schdum "是否在上学"
tab age schdum

* workdum
cap drop workdum
recode qg3  (1=1 "有工作")(0=0 "无工作") (-8 = . ), gen(workdum)
label var workdum "是否在工作，包括务农和个体经营，但不包括家务和志愿劳动。"
tab age workdum

* 最高受教育年限及其插补结果
cap drop eduy eduyim
tab cfps2010eduy
tab  cfps2010eduy_im

gen eduy = cfps2010eduy
replace eduy = . if cfps2010eduy < 0
label var eduy "最高受教育年限"

gen eduyim = cfps2010eduy_im
replace eduyim = . if cfps2010eduy_im < 0
label var eduyim "最高受教育年限(插补后)"
sum eduy eduyim, detail

* 在校生在校阶段（仅考虑schdum==1的样本）
cap drop schstage
tab cfps2010sch if schdum==1
tab cfps2010sch if schdum==1, nolabel
gen schstage = cfps2010sch if schdum==1
replace schstage = . if cfps2010sch < 0
label define schstage 1 "小学以下" 2 "小学" 3 "初中" 4 "高中" 5 "大专" 6 "大学本科" 7 "硕士" 8 "博士"
label values schstage schstage
label var schstage "在校阶段(仅针对在校生schdum==1)"
tab schstage

*个人所在学校情况
*是否寄宿
gen schdorm = wf304
label var schdorm "是否寄宿"
*是否公立学校（101214需recode）
recode kr402 (1/2=1) (3/5=2), generate(schpub)
label var schpub "是否公立学校"
*学校所在地属于城乡
*gen schurban = ws1002
* label define schurban 1 "省会城市（包括直辖市）" 2 "一般城市（包括县级市、地级市)" 3 "县城" 4 "农村（包括乡镇村）"
*是否全日制学校
gen schfull = kr404
label var schfull "是否全日制学校"


* 个人教育支出  
gen peduexp1 = wd510 //代答
gen peduexp2 = ks910  //自答
gen peduexp = peduexp1 if age < 16
replace peduexp = peduexp2 if age >= 16
label var peduexp "个体教育支出加总（元/年）"

gen peduexp1_tutor = wd503
gen peduexp2_tutor = ks903
gen peduexp_tutor = peduexp1_tutor if age < 16
replace peduexp_tutor = peduexp2_tutor if age >= 16
label var peduexp_tutor "个体教育支出-课外辅导/家教费（元/年）"




global indivVarList2010 = ""
foreach m of global module {
    local varList = "${m}2010"
    global indivVarList2010 = "$indivVarList2010 ${`varList'}"
}
dis "${indivVarList2010}"

gen wave = 2010
label var wave "调查年份"
merge m:1 countyid using "$cfpscountyid", update replace  //cityname code countyid countyname provname
keep if _merge!=2
drop _merge
gen resppid =  waproxy
keep $id_all 
order $id_all $indivVarList2010
save "$temp/CFPS_IndividualVar_2010.dta", replace
isid pid

//==================================================================//
/*              2012 个人基本特征和核心解释变量数据清理                  */
//==================================================================//
use "$cfps2020crossyearid", clear
merge 1:1 pid using "$cfps2016crossyearid", force update
keep if _merge!=2
drop _merge
merge 1:1 pid using "$cfps2012adult", force update
keep if indsurvey12>0  //2012年存在个人问卷
drop _merge
merge 1:1 pid using "$cfps2012child", force update
keep if indsurvey12>0  //2012年存在个人问卷
drop _merge
tab indsurvey12
tab indsurvey12, nolabel //1 成人问卷 2 少儿问卷

* age
cap drop age
gen age = 2012 - birthy
label var age "年龄"

* han
cap drop han
gen han = (ethnicity==1)
label var han "汉族"

* hukou
cap drop hukou
tab hk12
tab hk12, nolabel
recode hk12 (1=1 "农业户口")(3  = 0 "非农户口")(-8 -2 -1 5 79 = .), gen(hukou)
label var hukou "户口类型,农业户口=1, 非农户口=0"

* urban
cap drop urban
tab urban12
tab urban12, nolabel
gen urban = urban12
replace urban = . if urban<0
label var urban "城乡,城镇=1,乡村=0"

* marriage
cap drop marriage 
tab marriage_12
tab marriage_12, nolabel
gen marriage = (marriage_12 == 2) // 1 未婚 3 同居 4 离异 5 丧偶
replace marriage = . if marriage_12 < 0
label var marriage "婚姻状况,在婚=1"

* schdum
cap drop schdum
gen schdum = atschool2012
replace schdum = . if atschool2012 < 0
label var schdum "是否在上学"
tab age schdum


* workdum
cap drop workdum
tab employ12
tab employ12, nolabel
gen workdum = 1 if employ12 == 1
replace workdum = 0 if employ12 == 0 | employ12 == 3  //0失业或3退出劳动力市场
replace workdum = 0 if employ12 == -8 //此题不允许回答不知道和拒绝回答，但对于10岁及以下人群和未有过全职工作经历且在校生人群会逻辑跳转出现-8不适用
label var workdum "是否在工作，包括务农和个体经营，但不包括家务和志愿劳动。"
tab age workdum

* 最高受教育年限及其插补结果
cap drop eduy eduyim
tab cfps2012eduy
tab  cfps2012eduy_im

gen eduy = cfps2012eduy
replace eduy = . if cfps2012eduy < 0
label var eduy "最高受教育年限"

gen eduyim = cfps2012eduy_im
replace eduyim = . if cfps2012eduy_im < 0
label var eduyim "最高受教育年限(插补后)"
sum eduy eduyim, detail

* 在校生在校阶段（仅考虑schdum==1的样本）
cap drop schstage
tab cfps2012sch if schdum==1
tab cfps2012sch if schdum==1, nolabel
gen schstage = cfps2012sch if schdum==1
replace schstage = . if cfps2012sch < 0
label define schstage 1 "小学以下" 2 "小学" 3 "初中" 4 "高中" 5 "大专" 6 "大学本科" 7 "硕士" 8 "博士"
label values schstage schstage
label var schstage "在校阶段(仅针对在校生schdum==1)"
tab schstage

* 个体教育支出
* 个体教育支出加总
gen peduexp1 = wd5total_m if wd5total_m>=0
replace peduexp1 = wd5total if wd5ckp == 5

gen ks901_clean = cond(ks901 >= 0, ks901, 0)
gen ks902a_clean = cond(ks902a >= 0, ks902a, 0)
gen ks904_clean = cond(ks904 >= 0, ks904, 0)
gen ks908_clean = cond(ks908 >= 0, ks908, 0)
gen ks903_clean = cond(ks903 >= 0, ks903, 0)
gen ks905m_clean = cond(ks905m >= 0, ks905m, 0)
gen ks906_clean = cond(ks906 >= 0, ks906, 0)
gen ks907_clean = cond(ks907 >= 0, ks907, 0)
gen ks977_clean = cond(ks977 >= 0, ks977, 0)
egen peduexp2 = rowtotal(ks901_clean ks902a_clean ks904_clean ks908_clean ks903_clean ks905m_clean ks906_clean ks907_clean ks977_clean) if ks9ckp == 5
replace peduexp2 = ks9total_m if ks9total_m>=0

gen peduexp = peduexp1 if age < 16
replace peduexp = peduexp2 if age >= 16
label var peduexp "个体教育支出加总（元/年）"

* 个体教育支出-课外辅导/家教费
gen peduexp1_tutor = wd503m
gen peduexp2_tutor = ks903
gen peduexp_tutor = peduexp1_tutor if age < 16
replace peduexp_tutor = peduexp2_tutor if age >= 16
label var peduexp_tutor "个体教育支出-课外辅导/家教费（元/年）"

* 个体教育支出-软件/硬件费
gen peduexp1_software = wd511
gen peduexp2_software = ks906
gen peduexp_software = peduexp1_software if age < 16
replace peduexp_software = peduexp2_software if age >= 16
label var peduexp_software "个体教育支出-软件/硬件费（元/年）"



gen wave = 2012
label var wave "调查年份"
merge m:1 countyid using "$cfpscountyid", update replace  //cityname code countyid countyname provname
keep if _merge!=2
drop _merge

keep $id_all $indivVarList2012
order $id_all  $indivVarList2012
save "$temp/CFPS_IndividualVar_2012.dta", replace
isid pid



//==================================================================//
/*              2014 个人基本特征和核心解释变量数据清理                  */
//==================================================================//

use "$cfps2020crossyearid", clear
merge 1:1 pid using "$cfps2016crossyearid", force update
keep if _merge!=2
drop _merge
merge 1:1 pid using "$cfps2014adult", force update
keep if indsurvey14>0  //2014年存在个人问卷
drop _merge
merge 1:1 pid using "$cfps2014child", force update
keep if indsurvey14>0  //2014年存在个人问卷
drop _merge
tab indsurvey14
tab indsurvey14, nolabel //1 成人问卷 2 少儿问卷

* 个人基本变量
cap drop cid countyid indsurvey
gen cid = cid14
gen countyid = countyid14
gen indsurvey = indsurvey14
* gender
* birthy
* age
cap drop age
gen age = 2014 - birthy
label var age "年龄"

* han
cap drop han
gen han = (ethnicity==1)
label var han "汉族"

* hukou
cap drop hukou
tab hk14
tab hk14, nolabel
recode hk14 (1=1 "农业户口")(3  = 0 "非农户口")(-8 -2 -1 5 79 = .), gen(hukou)
label var hukou "户口类型,农业户口=1, 非农户口=0"

* urban
cap drop urban
tab urban14
tab urban14, nolabel
gen urban = urban14
replace urban = . if urban<0
label var urban "城乡,城镇=1,乡村=0"

* marriage
cap drop marriage
tab marriage_14 
tab marriage_14, nolabel
gen marriage = (marriage_14 == 2) // 1 未婚 3 同居 4 离异 5 丧偶
replace marriage = . if marriage_12 < 0
label var marriage "婚姻状况,在婚=1"

* schdum
cap drop schdum
gen schdum = atschool2014
replace schdum = . if atschool2014 < 0
label var schdum "是否在上学"
tab age schdum

/* 
tab wc01 
tab wc01, nolabel
tab age if wc01<0  
gen schdum = 0 if wc01 == 0 | wf3m == 0  
replace schdum = 1 if wc01 == 1 | wf3m == 1
replace schdum = . if wc01 < 0 & wf3m < 0
* replace schdum = 0 if age >=45
label var schdum "是否在上学"
tab  age schdum
tab schdum 
*/

* workdum
cap drop workdum
tab employ14
tab employ14, nolabel
gen workdum = 1 if employ14 == 1
replace workdum = 0 if employ14 == 0 | employ14 == 3  //0失业或3退出劳动力市场
replace workdum = 0 if employ14 == -8 //此题不允许回答不知道和拒绝回答，但对于10岁及以下人群和未有过全职工作经历且在校生人群会逻辑跳转出现-8不适用
label var workdum "是否在工作，包括务农和个体经营，但不包括家务和志愿劳动。"
tab age workdum

* 最高受教育年限及其插补结果
cap drop eduy eduyim
tab cfps2014eduy
tab  cfps2014eduy_im

gen eduy = cfps2014eduy
replace eduy = . if cfps2014eduy < 0
label var eduy "最高受教育年限"

gen eduyim = cfps2014eduy_im
replace eduyim = . if cfps2014eduy_im < 0
label var eduyim "最高受教育年限(插补后)"
sum eduy eduyim, detail

* 在校生在校阶段（仅考虑schdum==1的样本）
cap drop schstage
tab cfps2014sch if schdum==1
tab cfps2014sch if schdum==1, nolabel
gen schstage = cfps2014sch if schdum==1
replace schstage = . if cfps2014sch < 0
label define schstage 1 "小学以下" 2 "小学" 3 "初中" 4 "高中" 5 "大专" 6 "大学本科" 7 "硕士" 8 "博士"
label values schstage schstage
label var schstage "在校阶段(仅针对在校生schdum==1)"
tab schstage

* 年级： 无相关变量

* 认知能力测试
gen  wordtest = wordtest14
gen mathtest = mathtest14

/* =========* 互联网模块 *=================== */
* 是否上网
cap drop InternetDummy
tab ku2
tab ku2, nolabel
* tab age ku2 if age < 18 & schstage<=4 
tab age if ku2==-8  //10岁以下的样本未提问此问题
gen InternetDummy = 1 if ku2 ==1
replace InternetDummy = 0 if ku2 == 0
label var InternetDummy "是否上网"
tab age InternetDummy 
* tab age InternetDummy if age < 18 & schstage<=4  //基础教育阶段的未成年人


* 上网时长[提问方式是业余上网时长]
cap drop InternetMinute
sum ku250m, detail
gen InternetMinute = ku250m * 60 / 7
replace InternetMinute = . if ku250m < 0
replace InternetMinute = 0 if InternetDummy == 0
label var InternetMinute "上网时长(分钟/天)"
sum InternetMinute, detail

* 上网学习
cap drop InternetStudyDummy
tab ku701
tab ku701, nolabel
recode ku701 (1 2 3 4 5 6=1 "是")(7=0 "否")(-8 -1 = .), gen(InternetStudyDummy)
recode ku701 (1 2 3 4 = 1 "是")(5 6 7=0 "否")(-8 -1 = .), gen(InternetStudy_LastWeek)
replace InternetStudyDummy = 0 if InternetDummy == 0
replace InternetStudy_LastWeek = 0 if InternetDummy == 0
label var InternetStudyDummy "是否利用互联网学习"
label var InternetStudy_LastWeek "上周是否利用互联网学习"
tab age InternetStudyDummy

* 上网学习时长 无相关变量

* 是否每天上网学习
cap drop InternetStudyDaily 
gen InternetStudyDaily = (ku701==1)
replace InternetStudyDaily = . if ku701 < 0
replace InternetStudyDaily = 0 if InternetStudyDummy == 0
label var InternetStudyDaily "是否每天上网学习"

* 上网学习频率
cap drop InternetStudyFreq
gen InternetStudyFreq = ku701
replace InternetStudyFreq = . if ku701 < 0
replace InternetStudyFreq = 7 if InternetStudyDummy == 0
label define InternetFreq 1 "几乎每天"  2 "一周3-4次" 3 "一周1-2次" 4 "一月2-3次" 5 "一月一次" 6 "几个月一次" 7 "从不"  
label values InternetStudyFreq InternetFreq
label var InternetStudyFreq "上网学习频率"
tab age InternetStudyFreq

* 上网工作
cap drop InternetWorkDummy
tab ku702
tab ku702, nolabel
recode ku702 (1 2 3 4 5 6=1 "是")(7=0 "否")(-8 -1 = .), gen(InternetWorkDummy)
replace InternetWorkDummy = 0 if InternetDummy == 0
label var InternetWorkDummy "是否利用互联网工作"


* 是否每天上网工作
cap drop InternetWorkDaily
gen InternetWorkDaily = (ku702==1)
replace InternetWorkDaily = . if ku702 < 0
replace InternetWorkDaily = 0 if InternetWorkDummy == 0
label var InternetWorkDaily "是否每天上网工作"

* 上网工作频率
cap drop InternetWorkFreq
gen InternetWorkFreq = ku702
replace InternetWorkFreq = . if ku702 < 0
replace InternetWorkFreq = 7 if InternetWorkDummy == 0
label value InternetWorkFreq InternetFreq
label var InternetWorkFreq "上网工作频率"
tab age InternetWorkFreq

* 上网社交
cap drop InternetSocialDummy
tab ku703
tab ku703, nolabel
recode ku703 (1 2 3 4 5 6=1 "是")(7=0 "否")(-8 -1 = .), gen(InternetSocialDummy)
replace InternetSocialDummy = 0 if InternetDummy == 0
label var InternetSocialDummy "是否利用互联网社交"


* 是否每天上网社交
cap drop InternetSocialDaily
gen InternetSocialDaily = (ku703==1)
replace InternetSocialDaily = . if ku703 < 0
replace InternetSocialDaily = 0 if InternetSocialDummy == 0
label var InternetSocialDaily "是否每天上网社交"

* 上网社交频率
cap drop InternetSocialFreq
gen InternetSocialFreq = ku703
replace InternetSocialFreq = . if ku703 < 0
replace InternetSocialFreq = 7 if InternetSocialDummy == 0
label value InternetSocialFreq InternetFreq
label var InternetSocialFreq "上网社交频率"
tab age InternetSocialFreq

* 上网娱乐
cap drop InternetEntertainmentDummy
tab ku704
tab ku704, nolabel
recode ku704 (1 2 3 4 5 6=1 "是")(7=0 "否")(-8 -1 = .), gen(InternetEntertainmentDummy)
recode ku704 (1 2 3 4 = 1 "是")(5 6 7=0 "否")(-8 -1 = .), gen(InternetEntertainment_LastWeek)
replace InternetEntertainmentDummy = 0 if InternetDummy == 0
replace InternetEntertainment_LastWeek = 0 if InternetDummy == 0
label var InternetEntertainmentDummy "是否利用互联网娱乐"
label var InternetEntertainment_LastWeek "上周是否利用互联网娱乐"


* 是否每天上网娱乐
cap drop InternetEntertainmentDaily
gen InternetEntertainmentDaily = (ku704==1)
replace InternetEntertainmentDaily = . if ku704 < 0
replace InternetEntertainmentDaily = 0 if InternetEntertainmentDummy == 0
label var InternetEntertainmentDaily "是否每天上网娱乐"

* 上网娱乐频率
cap drop InternetEntertainmentFreq
gen InternetEntertainmentFreq = ku704
replace InternetEntertainmentFreq = . if ku704 < 0
replace InternetEntertainmentFreq = 7 if InternetEntertainmentDummy == 0
label value InternetEntertainmentFreq InternetFreq
label var InternetEntertainmentFreq "上网娱乐频率"
tab age InternetEntertainmentFreq

* 上网购物
cap drop InternetShoppingDummy
tab ku705
tab ku705, nolabel
recode ku705 (1 2 3 4 5 6=1 "是")(7=0 "否")(-8 -1 = .), gen(InternetShoppingDummy)
replace InternetShoppingDummy = 0 if InternetDummy == 0
label var InternetShoppingDummy "是否利用互联网购物"


* 是否每天上网购物
cap drop InternetShoppingDaily
gen InternetShoppingDaily = (ku705==1)
replace InternetShoppingDaily = . if ku705 < 0
replace InternetShoppingDaily = 0 if InternetShoppingDummy == 0
label var InternetShoppingDaily "是否每天上网购物"

* 上网购物频率
cap drop InternetShoppingFreq
gen InternetShoppingFreq = ku705
replace InternetShoppingFreq = . if ku705 < 0
replace InternetShoppingFreq = 7 if InternetShoppingDummy == 0
label value InternetShoppingFreq InternetFreq
label var InternetShoppingFreq "上网购物频率"
tab age InternetShoppingFreq

* 个体教育支出
* 个体教育支出加总
gen peduexp1 = wd5total_m if wd5total_m>=0
replace peduexp1 = wd5total if wd5ckp == 5
gen peduexp2 = ks9total_m if ks9total_m>=0
replace peduexp2 = ks9total if ks9ckp == 5
gen peduexp = peduexp1 if age < 16
replace peduexp = peduexp2 if age >= 16
label var peduexp "个体教育支出加总（元/年）"

* 个体教育支出-课外辅导/家教费
gen peduexp1_tutor = wd503m
gen peduexp2_tutor = ks903
gen peduexp_tutor = peduexp1_tutor if age < 16
replace peduexp_tutor = peduexp2_tutor if age >= 16
label var peduexp_tutor "个体教育支出-课外辅导/家教费（元/年）"

* 个体教育支出-软件/硬件费
gen peduexp1_software = wd511
gen peduexp2_software = ks906
gen peduexp_software = peduexp1_software if age < 16
replace peduexp_software = peduexp2_software if age >= 16
label var peduexp_software "个体教育支出-软件/硬件费（元/年）"


gen wave = 2014
label var wave "调查年份"
merge m:1 countyid using "$cfpscountyid", update replace  //cityname code countyid countyname provname
keep if _merge!=2
drop _merge
keep $id_all $indivVarList2014
order $id_all $indivVarList2014
save "$temp/CFPS_IndividualVar_2014.dta", replace
isid pid

//==================================================================//
/*              2016年 个人基本特征和核心解释变量数据清理                */
//==================================================================//
use "$cfps2020crossyearid", clear
merge 1:1 pid using "$cfps2016crossyearid", force update
keep if _merge!=2
drop _merge
merge 1:1 pid using "$cfps2016adult", force update
keep if indsurvey16>0  //2016年存在个人问卷
drop _merge
merge 1:1 pid using "$cfps2016child", force update
keep if indsurvey16>0  //2016年存在个人问卷
drop _merge
tab indsurvey16  

* 个人基本变量
cap drop cid countyid indsurvey
gen cid = cid16
gen countyid = countyid16
gen indsurvey = indsurvey16
* gender
* birthy
* age
cap drop age
gen age = 2016 - birthy
label var age "年龄"

* han
cap drop han
gen han = (ethnicity==1)
label var han "汉族"

* hukou
cap drop hukou
tab hk16
tab hk16, nolabel
recode hk16 (1=1 "农业户口")(3 7 = 0 "非农户口")(-8 -2 -1 5 79 = .), gen(hukou)
label var hukou "户口类型,农业户口=1, 非农户口=0"

* urban
cap drop urban
tab urban16
tab urban16, nolabel
gen urban = urban16
replace urban = . if urban<0
label var urban "城乡,城镇=1,乡村=0"

* marriage
cap drop marriage   
tab marriage_16
tab marriage_16, nolabel
gen marriage = (marriage_16 == 2) // 1 未婚 3 同居 4 离异 5 丧偶
replace marriage = . if marriage_16 < 0
label var marriage "婚姻状况,在婚=1"

* schdum
cap drop schdum
gen schdum = atschool2016
replace schdum = . if atschool2016 < 0
label var schdum "是否在上学"
tab age schdum

/*
gen schdum = 0 if pc1==0 & pc2==0
replace schdum = 1 if pc1==1 | pc2==1
label var schdum "是否在上学"
tab age schdum
*/

* workdum
cap drop workdum
tab employ16
tab employ16, nolabel
gen workdum = 1 if employ16 == 1
replace workdum = 0 if employ16 == 0 | employ16 == 3
replace workdum = 0 if employ16 == -8
label var workdum "是否在工作，包括务农和个体经营，但不包括家务和志愿劳动。"
tab age workdum

* 最高受教育年限及其插补结果
cap drop eduy eduyim
tab cfps2016eduy
tab  cfps2016eduy_im

gen eduy = cfps2016eduy
replace eduy = . if cfps2016eduy < 0
label var eduy "最高受教育年限"

gen eduyim = cfps2016eduy_im
replace eduyim = . if cfps2016eduy_im < 0
label var eduyim "最高受教育年限(插补后)"
sum eduy eduyim, detail

* 在校生在校阶段（仅考虑schdum==1的样本）
cap drop schstage
tab cfps2016sch if schdum==1
tab cfps2016sch if schdum==1, nolabel
gen schstage = cfps2016sch if schdum==1
replace schstage = . if cfps2016sch < 0
label define schstage 1 "小学以下" 2 "小学" 3 "初中" 4 "高中" 5 "大专" 6 "大学本科" 7 "硕士" 8 "博士"
label values schstage schstage
label var schstage "在校阶段(仅针对在校生schdum==1)"
tab schstage

* 年级
cap drop grade
tab ppc5
gen grade = ppc5
replace grade = . if ppc5 < 0
label var grade "年级"
tab grade

/* =========* 网络模块 *=================== */
* 是否上网
cap drop InternetDummy
gen InternetDummy = 0 if  ku201==0 & ku202==0
replace InternetDummy = 1 if ku201==1 | ku202==1
label var InternetDummy "是否上网"
tab age InternetDummy
tab age ku201 if age < 18 & schstage<=4
tab age InternetDummy if age < 18 & schstage<=4

* 上网时长
cap drop InternetMinute
sum ku250m, detail
gen InternetMinute = ku250m * 60 / 7
replace InternetMinute = . if ku250m < 0
replace InternetMinute = 0 if InternetDummy == 0
label var InternetMinute "上网时长(分钟/天)"
sum InternetMinute, detail

* 上网学习
cap drop InternetStudyDummy
tab ku701
tab ku701, nolabel
recode ku701 (1 2 3 4 5 6=1 "是")(7=0 "否")(-8 -1 = .), gen(InternetStudyDummy)
recode ku701 (1 2 3 4 = 1 "是")(5 6 7=0 "否")(-8 -1 = .), gen(InternetStudy_LastWeek)
replace InternetStudyDummy = 0 if InternetDummy == 0
replace InternetStudy_LastWeek = 0 if InternetDummy == 0
label var InternetStudyDummy "是否利用互联网学习"
label var InternetStudy_LastWeek "上周是否利用互联网学习"
tab age InternetStudyDummy

* 上网学习时长 无相关变量

* 是否每天上网学习
cap drop InternetStudyDaily 
gen InternetStudyDaily = (ku701==1)
replace InternetStudyDaily = . if ku701 < 0
replace InternetStudyDaily = 0 if InternetStudyDummy == 0
label var InternetStudyDaily "是否每天上网学习"

* 上网学习频率
cap drop InternetStudyFreq
gen InternetStudyFreq = ku701
replace InternetStudyFreq = . if ku701 < 0
replace InternetStudyFreq = 7 if InternetStudyDummy == 0
label define InternetFreq 1 "几乎每天"  2 "一周3-4次" 3 "一周1-2次" 4 "一月2-3次" 5 "一月一次" 6 "几个月一次" 7 "从不"  
label values InternetStudyFreq InternetFreq
label var InternetStudyFreq "上网学习频率"
tab age InternetStudyFreq

* 上网工作
cap drop InternetWorkDummy
tab ku702
tab ku702, nolabel
recode ku702 (1 2 3 4 5 6=1 "是")(7=0 "否")(-8 -1 = .), gen(InternetWorkDummy)
replace InternetWorkDummy = 0 if InternetDummy == 0
label var InternetWorkDummy "是否利用互联网工作"


* 是否每天上网工作
cap drop InternetWorkDaily
gen InternetWorkDaily = (ku702==1)
replace InternetWorkDaily = . if ku702 < 0
replace InternetWorkDaily = 0 if InternetWorkDummy == 0
label var InternetWorkDaily "是否每天上网工作"

* 上网工作频率
cap drop InternetWorkFreq
gen InternetWorkFreq = ku702
replace InternetWorkFreq = . if ku702 < 0
replace InternetWorkFreq = 7 if InternetWorkDummy == 0
label value InternetWorkFreq InternetFreq
label var InternetWorkFreq "上网工作频率"
tab age InternetWorkFreq

* 上网社交
cap drop InternetSocialDummy
tab ku703
tab ku703, nolabel
recode ku703 (1 2 3 4 5 6=1 "是")(7=0 "否")(-8 -1 = .), gen(InternetSocialDummy)
replace InternetSocialDummy = 0 if InternetDummy == 0
label var InternetSocialDummy "是否利用互联网社交"


* 是否每天上网社交
cap drop InternetSocialDaily
gen InternetSocialDaily = (ku703==1)
replace InternetSocialDaily = . if ku703 < 0
replace InternetSocialDaily = 0 if InternetSocialDummy == 0
label var InternetSocialDaily "是否每天上网社交"

* 上网社交频率
cap drop InternetSocialFreq
gen InternetSocialFreq = ku703
replace InternetSocialFreq = . if ku703 < 0
replace InternetSocialFreq = 7 if InternetSocialDummy == 0
label value InternetSocialFreq InternetFreq
label var InternetSocialFreq "上网社交频率"
tab age InternetSocialFreq

* 上网娱乐
cap drop InternetEntertainmentDummy
tab ku704
tab ku704, nolabel
recode ku704 (1 2 3 4 5 6=1 "是")(7=0 "否")(-8 -1 = .), gen(InternetEntertainmentDummy)
recode ku704 (1 2 3 4 = 1 "是")(5 6 7=0 "否")(-8 -1 = .), gen(InternetEntertainment_LastWeek)
replace InternetEntertainmentDummy = 0 if InternetDummy == 0
replace InternetEntertainment_LastWeek = 0 if InternetDummy == 0
label var InternetEntertainmentDummy "是否利用互联网娱乐"
label var InternetEntertainment_LastWeek "上周是否利用互联网娱乐"


* 是否每天上网娱乐
cap drop InternetEntertainmentDaily
gen InternetEntertainmentDaily = (ku704==1)
replace InternetEntertainmentDaily = . if ku704 < 0
replace InternetEntertainmentDaily = 0 if InternetEntertainmentDummy == 0
label var InternetEntertainmentDaily "是否每天上网娱乐"

* 上网娱乐频率
cap drop InternetEntertainmentFreq
gen InternetEntertainmentFreq = ku704
replace InternetEntertainmentFreq = . if ku704 < 0
replace InternetEntertainmentFreq = 7 if InternetEntertainmentDummy == 0
label value InternetEntertainmentFreq InternetFreq
label var InternetEntertainmentFreq "上网娱乐频率"
tab age InternetEntertainmentFreq

* 上网购物
cap drop InternetShoppingDummy
tab ku705
tab ku705, nolabel
recode ku705 (1 2 3 4 5 6=1 "是")(7=0 "否")(-8 -1 = .), gen(InternetShoppingDummy)
replace InternetShoppingDummy = 0 if InternetDummy == 0
label var InternetShoppingDummy "是否利用互联网购物"


* 是否每天上网购物
cap drop InternetShoppingDaily
gen InternetShoppingDaily = (ku705==1)
replace InternetShoppingDaily = . if ku705 < 0
replace InternetShoppingDaily = 0 if InternetShoppingDummy == 0
label var InternetShoppingDaily "是否每天上网购物"

* 上网购物频率
cap drop InternetShoppingFreq
gen InternetShoppingFreq = ku705
replace InternetShoppingFreq = . if ku705 < 0
replace InternetShoppingFreq = 7 if InternetShoppingDummy == 0
label value InternetShoppingFreq InternetFreq
label var InternetShoppingFreq "上网购物频率"
tab age InternetShoppingFreq

* 个体教育支出
* 个体教育支出加总
gen peduexp = pd5total_m if pd5total_m>=0
replace peduexp = pd5total if pd5ckp == 5
label var peduexp "个体教育支出加总（元/年）"

* 个体教育支出-课外辅导/家教费
gen peduexp_tutor = pd503r
label var peduexp_tutor "个体教育支出-课外辅导/家教费（元/年）"

* 个体教育支出-学校教育支出
gen peduexp_sch = pd501b
label var peduexp_sch "个体教育支出-学校教育支出（元/年）=学杂费+伙食、住宿、校车+书本及用具+其他学校支出"


gen wave = 2016
label var wave "调查年份"
merge m:1 countyid using "$cfpscountyid", update replace  
keep if _merge!=2
drop _merge
keep $id_all $indivVarList2016
order $id_all $indivVarList2016
save "$temp/CFPS_IndividualVar_2016.dta", replace

//==================================================================//
/*              2018 个人基本特征和核心解释变量数据清理                */
//==================================================================//
use "$cfps2020crossyearid", clear
merge 1:1 pid using "$cfps2018person", force update
keep if indsurvey18>0  //2018年存在个人问卷
drop _merge
merge 1:1 pid using "$cfps2018childproxy", force update
keep if indsurvey18>0  //2018年存在个人问卷
drop _merge
tab indsurvey18
tab indsurvey18, nolabel //3 同时存在 4 只存在个人问卷 5 只存在少儿家长代答问卷

* 个人基本变量
cap drop cid countyid indsurvey
gen cid = cid18
gen countyid = countyid18
gen indsurvey = indsurvey18
* gender
* birthy
* age
cap drop age
gen age = 2018 - birthy
label var age "年龄"

* han
cap drop han
gen han = (ethnicity==1)
label var han "汉族"

* hukou
cap drop hukou
tab hk18
tab hk18, nolabel
recode hk18 (1=1 "农业户口")(3 7 = 0 "非农户口")(-8 -2 -1 5 79 = .), gen(hukou)
label var hukou "户口类型,农业户口=1, 非农户口=0"

* urban
cap drop urban
tab urban18
tab urban18, nolabel
gen urban = urban18
replace urban = . if urban<0
label var urban "城乡,城镇=1,乡村=0"

* marriage
cap drop marriage
tab marriage_18
tab marriage_18, nolabel
gen marriage = (marriage_18 == 2) // 1 未婚 3 同居 4 离异 5 丧偶
replace marriage = . if marriage_18 < 0
label var marriage "婚姻状况,在婚=1"

* schdum
cap drop schdum
gen schdum = 0 if qc1==0 & qc2==0
replace schdum = 0 if wc1_b_2==0 & wc2==0
replace schdum = 1 if qc1==1 | qc2==1
replace schdum = 1 if wc1_b_2==1 | wc2 == 1
label var schdum "是否在上学"
tab age schdum
tab schdum school

* workdum
cap drop workdum
tab employ18
tab employ18, nolabel
gen workdum = 1 if employ18 == 1
replace workdum = 0 if employ18 == 0 | employ18 == 3
replace workdum = 0 if employ18 == -8
label var workdum "是否在工作，包括务农和个体经营，但不包括家务和志愿劳动。"
tab age workdum

* 最高受教育年限及其插补结果
cap drop eduy eduyim
tab cfps2018eduy
tab  cfps2018eduy_im

gen eduy = cfps2018eduy
replace eduy = . if cfps2018eduy < 0
label var eduy "最高受教育年限"

gen eduyim = cfps2018eduy_im
replace eduyim = . if cfps2018eduy_im < 0
label var eduyim "最高受教育年限(插补后)"
sum eduy eduyim, detail

* 在校生在校阶段（仅考虑schdum==1的样本）
cap drop schstage
tab cfps2018sch if schdum==1
tab cfps2018sch if schdum==1, nolabel
gen schstage = cfps2018sch if schdum==1
replace schstage = . if cfps2018sch < 0
label define schstage 1 "小学以下" 2 "小学" 3 "初中" 4 "高中" 5 "大专" 6 "大学本科" 7 "硕士" 8 "博士"
label values schstage schstage
label var schstage "在校阶段(仅针对在校生schdum==1)"
tab schstage

* 年级
cap drop grade
gen grade = qc5
replace grade = wc5_b_2 if grade < 0
replace grade = . if grade < 0
label var grade "年级"
tab grade

* 认知能力测试
gen  wordtest = wordtest18
gen mathtest = mathtest18

/* =========* 网络模块 *=================== */
* 是否上网: 手机和网络模块进入自答问卷。父母代答问卷不包含此问题
cap drop InternetDummy
gen InternetDummy = 0 if  qu201==0 & qu202==0
replace InternetDummy = 1 if qu201==1 | qu202==1
label var InternetDummy "是否上网"
tab age InternetDummy

* 上网时长
cap drop InternetMinute
sum qu250m, detail
gen InternetMinute = qu250m * 60 / 7
replace InternetMinute = . if qu250m < 0
replace InternetMinute = 0 if InternetDummy == 0
label var InternetMinute "上网时长(分钟/天)"
sum InternetMinute, detail

* 上网学习
cap drop InternetStudyDummy
tab qu701
tab qu701, nolabel
recode qu701 (1 2 3 4 5 6=1 "是")(7=0 "否")(-8 -1 = .), gen(InternetStudyDummy)
recode qu701 (1 2 3  = 1 "是")(4 5 6 7=0 "否")(-8 -1 = .), gen(InternetStudy_LastWeek)
replace InternetStudyDummy = 0 if InternetDummy == 0
replace InternetStudy_LastWeek = 0 if InternetDummy == 0
label var InternetStudyDummy "是否利用互联网学习"
label var InternetStudy_LastWeek "上周是否利用互联网学习"
tab age InternetStudyDummy

* 上网学习时长 无相关变量

* 是否每天上网学习
cap drop InternetStudyDaily
gen InternetStudyDaily = (qu701==1)
replace InternetStudyDaily = . if qu701 < 0
replace InternetStudyDaily = 0 if InternetStudyDummy == 0
label var InternetStudyDaily "是否每天上网学习"

* 上网学习频率
cap drop InternetStudyFreq
gen InternetStudyFreq = qu701
replace InternetStudyFreq = . if qu701 < 0
replace InternetStudyFreq = 7 if InternetStudyDummy == 0
label define InternetFreq 1 "几乎每天"  2 "一周3-4次" 3 "一周1-2次" 4 "一月2-3次" 5 "一月一次" 6 "几个月一次" 7 "从不"
label values InternetStudyFreq InternetFreq
label var InternetStudyFreq "上网学习频率"
tab age InternetStudyFreq

* 上网工作
cap drop InternetWorkDummy
tab qu702
tab qu702, nolabel
recode qu702 (1 2 3 4 5 6=1 "是")(7=0 "否")(-8 -1 = .), gen(InternetWorkDummy)
replace InternetWorkDummy = 0 if InternetDummy == 0
label var InternetWorkDummy "是否利用互联网工作"

* 是否每天上网工作
cap drop InternetWorkDaily
gen InternetWorkDaily = (qu702==1)
replace InternetWorkDaily = . if qu702 < 0
replace InternetWorkDaily = 0 if InternetWorkDummy == 0
label var InternetWorkDaily "是否每天上网工作"

* 上网工作频率
cap drop InternetWorkFreq
gen InternetWorkFreq = qu702
replace InternetWorkFreq = . if qu702 < 0
replace InternetWorkFreq = 7 if InternetWorkDummy == 0
label value InternetWorkFreq InternetFreq
label var InternetWorkFreq "上网工作频率"

* 上网社交
cap drop InternetSocialDummy
tab qu703
tab qu703, nolabel
recode qu703 (1 2 3 4 5 6=1 "是")(7=0 "否")(-8 -1 = .), gen(InternetSocialDummy)
replace InternetSocialDummy = 0 if InternetDummy == 0
label var InternetSocialDummy "是否利用互联网社交"

* 是否每天上网社交
cap drop InternetSocialDaily
gen InternetSocialDaily = (qu703==1)
replace InternetSocialDaily = . if qu703 < 0
replace InternetSocialDaily = 0 if InternetSocialDummy == 0
label var InternetSocialDaily "是否每天上网社交"

* 上网社交频率
cap drop InternetSocialFreq
gen InternetSocialFreq = qu703
replace InternetSocialFreq = . if qu703 < 0
replace InternetSocialFreq = 7 if InternetSocialDummy == 0
label value InternetSocialFreq InternetFreq
label var InternetSocialFreq "上网社交频率"

* 上网娱乐
cap drop InternetEntertainmentDummy
tab qu704
tab qu704, nolabel
recode qu704 (1 2 3 4 5 6=1 "是")(7=0 "否")(-8 -1 = .), gen(InternetEntertainmentDummy)
recode qu704 (1 2 3  = 1 "是")(4 5 6 7=0 "否")(-8 -1 = .), gen(InternetEntertainment_LastWeek)
replace InternetEntertainmentDummy = 0 if InternetDummy == 0
replace InternetEntertainment_LastWeek = 0 if InternetDummy == 0
label var InternetEntertainmentDummy "是否利用互联网娱乐"
label var InternetEntertainment_LastWeek "上周是否利用互联网娱乐"

* 是否每天上网娱乐
cap drop InternetEntertainmentDaily
gen InternetEntertainmentDaily = (qu704==1)
replace InternetEntertainmentDaily = . if qu704 < 0
replace InternetEntertainmentDaily = 0 if InternetEntertainmentDummy == 0
label var InternetEntertainmentDaily "是否每天上网娱乐"

* 上网娱乐频率
cap drop InternetEntertainmentFreq
gen InternetEntertainmentFreq = qu704
replace InternetEntertainmentFreq = . if qu704 < 0
replace InternetEntertainmentFreq = 7 if InternetEntertainmentDummy == 0
label value InternetEntertainmentFreq InternetFreq
label var InternetEntertainmentFreq "上网娱乐频率"


* 上网购物
cap drop InternetShoppingDummy
tab qu705
tab qu705, nolabel
recode qu705 (1 2 3 4 5 6=1 "是")(7=0 "否")(-8 -1 = .), gen(InternetShoppingDummy)
replace InternetShoppingDummy = 0 if InternetDummy == 0
label var InternetShoppingDummy "是否利用互联网购物"

* 是否每天上网购物
cap drop InternetShoppingDaily
gen InternetShoppingDaily = (qu705==1)
replace InternetShoppingDaily = . if qu705 < 0
replace InternetShoppingDaily = 0 if InternetShoppingDummy == 0
label var InternetShoppingDaily "是否每天上网购物"

* 上网购物频率
cap drop InternetShoppingFreq
gen InternetShoppingFreq = qu705
replace InternetShoppingFreq = . if qu705 < 0
replace InternetShoppingFreq = 7 if InternetShoppingDummy == 0
label value InternetShoppingFreq InternetFreq
label var InternetShoppingFreq "上网购物频率"

* 个体教育支出
* 个体教育支出加总
gen peduexp1 = wd5total_m if wd5total_m>=0
replace peduexp1 = wd5total if wd5ckp == 5
gen peduexp2 = pd5total_m if pd5total_m>=0
replace peduexp2 = pd5total if pd5ckp == 5
gen peduexp = peduexp1 if age < 16
replace peduexp = peduexp2 if age >= 16
label var peduexp "个体教育支出加总（元/年）"

* 个体教育支出-课外辅导/家教费
gen peduexp1_tutor = wd503r
gen peduexp2_tutor = pd503r
gen peduexp_tutor = peduexp1_tutor if age < 16
replace peduexp_tutor = peduexp2_tutor if age >= 16
label var peduexp_tutor "个体教育支出-课外辅导/家教费（元/年）"

* 个体教育支出-学校教育支出
gen peduexp1_school = wd501b
gen peduexp2_school = pd501b
gen peduexp_sch = peduexp1_school if age < 16
replace peduexp_sch = peduexp2_school if age >= 16
label var peduexp_sch "个体教育支出-学校教育支出（元/年）=学杂费+伙食、住宿、校车+书本及用具+其他学校支出"


gen wave = 2018
label var wave "调查年份"
rename pid_a_f pid_f
label var pid_f "父亲在调查中的样本编码"
rename pid_a_m pid_m
label var pid_m "母亲在调查中的样本编码"
rename respc1pid resppid
label var resppid "代答家长个人id"
drop code
merge m:1 countyid using "$cfpscountyid"  , update replace
keep if _merge!=2
drop _merge
keep $id_all $indivVarList2018
order $id_all  $indivVarList2018
save "$temp/CFPS_IndividualVar_2018.dta", replace





//==================================================================//
/*              2020 个人基本特征和核心解释变量数据清理                */
//==================================================================//
use "$cfps2020crossyearid", clear
merge 1:1 pid using "$cfps2020person", force update
keep if indsurvey20>0  //2020年存在个人问卷
drop _merge
merge 1:1 pid using "$cfps2020childproxy", force update
keep if indsurvey20>0  //2020年存在个人问卷
drop _merge
tab indsurvey20
tab indsurvey20, nolabel //3 同时存在 4 只存在个人问卷 5 只存在少儿家长代答问卷



* 个人基本变量
cap drop cid countyid indsurvey
gen cid = cid20
gen countyid = countyid20
gen indsurvey = indsurvey20
* 性别 gender
* 出生年份 birthy
* 年龄 age
cap drop age 
gen age = 2020 - birthy
label var age "年龄"
* 汉族 han
cap drop han
gen han = (ethnicity==1)
label var han "汉族"
* 户口 hukou
cap drop hukou
recode hk20r (1=1 "农业户口")(3 7 = 0 "非农户口")(-8 -2 -1 5 79 = .), gen(hukou) 
label var hukou "户口类型,农业户口=1, 非农户口=0"
* 城乡 urban
cap drop urban
gen urban = (urban20 == 1)
* 在婚 marriage
cap drop marriage
gen marriage = (marriage_20 == 2) // 1 未婚 3 同居 4 离异 5 丧偶
label var marriage "婚姻状况,在婚=1"
* 是否在上学 schdum
cap drop schdum
gen schdum = 0 if qc1==0 & qc2==0
replace schdum = 1 if (qc1==1) | (qc1==0 & qc2==1)
replace schdum = 0 if wc1 == 5 & wc2==0
replace schdum = 1 if (wc1==1) | (wc1==0 & wc2==1)
label var schdum "是否在上学"
tab schdum school
* 是否在工作 workdum
cap drop workdum
gen workdum = 1 if employ20 == 1
replace workdum = 0 if employ20 == 0 | employ20 == 3
replace workdum = 0 if employ20 == -8 
label var workdum "是否在工作，包括务农和个体经营，但不包括家务和志愿劳动。"
* 最高受教育年限及其插补结果
cap drop eduy eduyim
gen eduy = cfps2020eduy
replace eduy = . if cfps2020eduy < 0
gen eduyim = cfps2020eduy_im
replace eduyim = . if cfps2020eduy_im < 0
label var eduy "最高受教育年限"
label var eduyim "最高受教育年限(插补后)"
sum eduy eduyim, detail
* 在校生在校阶段（仅考虑schdum==1的样本）
cap drop schstage
tab cfps2020sch if schdum==1 
tab cfps2020sch if schdum==1, nolabel
gen schstage = cfps2020sch if schdum==1
replace schstage = . if cfps2020sch < 0
label define schstage 1 "小学以下" 2 "小学" 3 "初中" 4 "高中" 5 "大专" 6 "大学本科" 7 "硕士" 8 "博士"
label values schstage schstage
label var schstage "在校阶段(仅针对在校生schdum==1)"
tab schstage
* 年级
cap drop grade
gen grade = qc5
replace grade = wc5 if grade < 0
replace grade = . if grade < 0
label var grade "年级"
tab grade


/* =========* 核心解释变量 *=================== */
* 是否上网
cap drop InternetDummy
gen  InternetDummy = 0 if (qu201==0 & qu201==0) | wu4==0
replace InternetDummy = 0 if wu1 == 0  // wu1==0即没有使用移动设备或电脑，此时wu4会因为逻辑跳转取值为不适用
replace InternetDummy = 1 if qu201==1 | qu202==1 | wu4==1

label var InternetDummy "是否上网"
tab InternetDummy
tab age InternetDummy if age<18 & schstage<=4
tab age wu4 if age<18 & schstage<=4
tab age qu201 if age<18 & schstage<=4
* 上网时长
// 对于自答问卷的上网时长是有两个问题，一个是移动上网的时长，一个是电脑上网的时长，我本来想着把两者加在一起，这样可以和代答问卷中直接询问上网时长的问题汇总到一起，但是发现加总的方式导致最大时长变成了48h，于是我决定取几类上网时长最大值，这样比较合理。同时保留原先的两个原始变量。
cap drop InternetMinute mobileInternetMinute computerInternetMinute
gen mobileInternetMinute = qu201a
replace mobileInternetMinute = . if qu201a<0
replace mobileInternetMinute = 0 if qu201==0 
label var mobileInternetMinute "移动上网时长(分钟/天)"
gen computerInternetMinute = qu202a
replace computerInternetMinute = . if qu202a<0
replace computerInternetMinute = 0 if qu202==0
label var computerInternetMinute "电脑上网时长(分钟/天)"

egen InternetMinute =rowmax(qu201a qu202a wu401) 
replace InternetMinute = . if InternetMinute < 0
replace InternetMinute =0 if InternetDummy == 0
label var InternetMinute "上网时长(分钟/天)"   //17289/26205
sum InternetMinute mobileInternetMinute computerInternetMinute, detail

* 上网学习
cap drop InternetStudyDummy
gen InternetStudyDummy = 0 if qu94==0 
replace InternetStudyDummy = 1 if qu94==1 | wu5==1  
replace InternetStudyDummy = 0 if InternetDummy == 0
label var InternetStudyDummy "是否利用互联网学习"
gen InternetStudy_LastWeek = InternetStudyDummy
label var InternetStudy_LastWeek "上周是否利用互联网学习"
tab InternetStudyDummy

* 上网学习时长
cap drop InternetStudyMinute
gen InternetStudyMinute = wu501
replace InternetStudyMinute = . if InternetStudyMinute < 0
replace InternetStudyMinute = 0 if InternetStudyDummy == 0
label var InternetStudyMinute "上网学习时长(分钟/天)"
sum InternetStudyMinute if InternetStudyMinute>0
sum InternetStudyMinute, detail  //只有509个样本（）上网学习时长大于0, 平均时长接近一小时

* 是否每天上网学习
cap drop InternetStudyDaily
tab qu941
tab qu941, nolabel
gen InternetStudyDaily = qu941
replace InternetStudyDaily = . if qu941 < 0
replace InternetStudyDaily = 0 if InternetStudyDummy == 0
label var InternetStudyDaily "是否每天上网学习"
tab InternetStudyDaily

* 上网学习频率: 无相关变量

* 上网工作： 无相关变量

* 上网社交： 无相关变量

* 上网娱乐： 包括短视频和游戏
cap drop InternetEntertainmentDummy
gen InternetEntertainmentDummy = 0 if qu91==0 & qu93==0
replace InternetEntertainmentDummy = 1 if qu91==1 | qu93==1
replace InternetEntertainmentDummy = 0 if InternetDummy == 0
label var InternetEntertainmentDummy "是否利用互联网娱乐"
gen InternetEntertainment_LastWeek = InternetEntertainmentDummy
label var InternetEntertainment_LastWeek "上周是否利用互联网娱乐"
tab InternetEntertainmentDummy

* 是否每天上网娱乐
cap drop InternetEntertainmentDaily
gen InternetEntertainmentDaily = (qu911==1 | qu931==1)
replace InternetEntertainmentDaily = . if qu911 < 0 & qu931 < 0
replace InternetEntertainmentDaily = 0 if InternetEntertainmentDummy == 0
label var InternetEntertainmentDaily "是否每天上网娱乐"
tab InternetEntertainmentDaily

* 上网娱乐频率: 无相关变量

* 上网购物
cap drop InternetShoppingDummy
gen InternetShoppingDummy = 0 if qu92==0
replace InternetShoppingDummy = 1 if qu92==1
replace InternetShoppingDummy = 0 if InternetDummy == 0
label var InternetShoppingDummy "是否利用互联网购物"
tab InternetShoppingDummy

* 是否每天上网购物
cap drop InternetShoppingDaily
gen InternetShoppingDaily = (qu921==1)
replace InternetShoppingDaily = . if qu921 < 0
replace InternetShoppingDaily = 0 if InternetShoppingDummy == 0
label var InternetShoppingDaily "是否每天上网购物"
tab InternetShoppingDaily

* 上网购物频率: 无相关变量

* 父母教养方式
gen wm201 = qm201_b_2
gen wm202 = qm202_b_2
gen wm203 = qm203_b_2
gen wm204 = qm204_b_2
gen wm205 = qm205_b_2
gen wm206 = qm206_b_2
gen wm207 = qm207_b_2
gen wm208 = qm208_b_2
gen wm209 = qm209_b_2
gen wm210 = qm210_b_2
gen wm211 = qm211_b_2
gen wm212 = qm212_b_2
gen wm213 = qm213_b_2
gen wm214 = qm214_b_2



* 个体教育支出
* 个体教育支出加总
gen peduexp1 = wd5total_mn if wd5total_mn>=0
replace peduexp1 = wd5total if wd5ckp == 5
gen peduexp2 = pd5total_mn if pd5total_mn>=0
replace peduexp2 = pd5total if pd5ckp == 5
gen peduexp = peduexp1 if age < 16
replace peduexp = peduexp2 if age >= 16
label var peduexp "个体教育支出加总（元/年）"

* 个体教育支出-课外辅导/家教费
gen peduexp1_tutor = wd503r
gen peduexp2_tutor = pd503r
gen peduexp_tutor = peduexp1_tutor if age < 16
replace peduexp_tutor = peduexp2_tutor if age >= 16
label var peduexp_tutor "个体教育支出-课外辅导/家教费（元/年）"

* 个体教育支出-学校教育支出
gen peduexp1_school = wd501b    
gen peduexp2_school = pd501b
gen peduexp_sch = peduexp1_school if age < 16
replace peduexp_sch = peduexp2_school if age >= 16
label var peduexp_sch "个体教育支出-学校教育支出（元/年）=学杂费+伙食、住宿、校车+书本及用具+其他学校支出"


gen wave = 2020
label var wave "调查年份"
rename pid_a_f pid_f
label var pid_f "父亲在调查中的样本编码"
rename pid_a_m pid_m
label var pid_m "母亲在调查中的样本编码"
rename respc1pid resppid
label var resppid "代答家长个人id"
cap drop code
merge m:1 countyid using "$cfpscountyid"  
keep if _merge!=2
drop _merge
keep $id_all $indivVarList2020
order $id_all $indivVarList2020
save "$temp/CFPS_IndividualVar_2020.dta", replace




//==================================================================//
/*              2022 个人基本特征和核心解释变量数据清理                */
//==================================================================//
use "$cfps2020crossyearid", clear
merge 1:1 pid using "$cfps2022person", force update
drop _merge
merge 1:1 pid using "$cfps2022childproxy", force update
drop _merge
* 【个人基本变量】
* gender
* birthy
* age
cap drop age
gen age = 2022 - birthy
label var age "年龄"

* han
cap drop han
gen han = (ethnicity==1)
label var han "汉族"

* hukou
cap drop hukou
tab hk20r
tab hk20r, nolabel
replace hk20r = qa301 if qa301 != .
recode hk20r (1=1 "农业户口")(3  = 0 "非农户口")(-8 -2 -1 5 79 = .), gen(hukou)
label var hukou "户口类型,农业户口=1, 非农户口=0"

* urban
cap drop urban
tab urban22
tab urban22, nolabel
gen urban = urban22
replace urban = . if urban<0
label var urban "城乡,城镇=1,乡村=0"

* marriage
cap drop marriage
tab marriage_20
tab marriage_20, nolabel
replace marriage_20 = marriage_last if marriage_last != .
gen marriage = (marriage_20 == 2) // 1 未婚 3 同居 4 离异 5 丧偶
replace marriage = . if marriage_20 < 0
label var marriage "婚姻状况,在婚=1"

* schdum
cap drop schdum
gen schdum = school
replace schdum = . if school < 0
label var schdum "是否在上学"
tab age schdum

* workdum
cap drop workdum
recode qg101  (1=1 "有工作")(0=0 "无工作") (-8 = . ), gen(workdum)
label var workdum "是否在工作，包括务农和个体经营，但不包括家务和志愿劳动。"
tab age workdum

* 最高受教育年限及其插补结果
cap drop eduy eduyim
tab cfps2022eduy
tab  cfps2022eduy_im

gen eduy = cfps2022eduy
replace eduy = . if cfps2022eduy < 0
label var eduy "最高受教育年限"

gen eduyim = cfps2022eduy_im
replace eduyim = . if cfps2022eduy_im < 0
label var eduyim "最高受教育年限(插补后)"
sum eduy eduyim, detail

* 在校生在校阶段（仅考虑schdum==1的样本）
cap drop schstage
tab cfps2022sch if schdum==1
tab cfps2022sch if schdum==1, nolabel
gen schstage = cfps2022sch if schdum==1
replace schstage = . if cfps2022sch < 0
label define schstage 1 "小学以下" 2 "小学" 3 "初中" 4 "高中" 5 "大专" 6 "大学本科" 7 "硕士" 8 "博士"
label values schstage schstage
label var schstage "在校阶段(仅针对在校生schdum==1)"
tab schstage

*个人所在学校情况
*是否寄宿
gen schdorm = qs1001
label var schdorm "是否寄宿"
*是否公立学校（101214需recode）
gen schpub = qs601
label var schpub "是否公立学校"
*学校所在地属于城乡
gen schurban = qs1002
label define schurban 1 "省会城市（包括直辖市）" 2 "一般城市（包括县级市、地级市)" 3 "县城" 4 "农村（包括乡镇村）"
label var schurban "学校所在地属于城乡"

* 个体教育支出加总
gen peduexp1 = wd5total_mn if wd5total_mn>=0
replace peduexp1 = wd5total if wd5ckp == 5
gen peduexp2 = pd5total_mn if pd5total_mn>=0
replace peduexp2 = pd5total if pd5ckp == 5
gen peduexp = peduexp1 if age < 16
replace peduexp = peduexp2 if age >= 16
label var peduexp "个体教育支出加总（元/年）"

* 个体教育支出-课外辅导/家教费
gen peduexp1_tutor = wd503r
gen peduexp2_tutor = pd503r
gen peduexp_tutor = peduexp1_tutor if age < 16
replace peduexp_tutor = peduexp2_tutor if age >= 16
label var peduexp_tutor "个体教育支出-课外辅导/家教费（元/年）"

* 个体教育支出-学校教育支出
gen peduexp1_school = wd501b    
gen peduexp2_school = pd501b
gen peduexp_sch = peduexp1_school if age < 16
replace peduexp_sch = peduexp2_school if age >= 16
label var peduexp_sch "个体教育支出-学校教育支出（元/年）=学杂费+伙食、住宿、校车+书本及用具+其他学校支出"


*【因变量:个人发展】
* 学业表现
*  学习压力
gen studypr = qs502
label var studypr "学习压力（1没有-5压力大）"
gen wordtest = wordtest22
gen mathtest = mathtest22
* 非认知能力
gen happy = qn416
label var happy "我生活快乐"       
gen happy2 = we301
label var happy2 "这个孩子生性乐观" 


*【互联网模块】
* 是否上网: 手机和网络模块进入自答问卷。父母代答问卷不包含此问题
cap drop InternetDummy
gen InternetDummy = 0 if  qu201==0 & qu202==0
replace InternetDummy = 1 if qu201==1 | qu202==1
label var InternetDummy "是否上网"
tab age InternetDummy

* 上网时长
// 对于自答问卷的上网时长是有两个问题，一个是移动上网的时长，一个是电脑上网的时长，我本来想着把两者加在一起，这样可以和代答问卷中直接询问上网时长的问题汇总到一起，但是发现加总的方式导致最大时长变成了48h，于是我决定取几类上网时长最大值，这样比较合理。同时保留原先的两个原始变量。
cap drop InternetMinute mobileInternetMinute computerInternetMinute
gen mobileInternetMinute = qu201a
replace mobileInternetMinute = . if qu201a<0
replace mobileInternetMinute = 0 if qu201==0 
label var mobileInternetMinute "移动上网时长(分钟/天)"
gen computerInternetMinute = qu202a
replace computerInternetMinute = . if qu202a<0
replace computerInternetMinute = 0 if qu202==0
label var computerInternetMinute "电脑上网时长(分钟/天)"

egen InternetMinute =rowmax(qu201a qu202a wu401) 
replace InternetMinute = . if InternetMinute < 0
replace InternetMinute =0 if InternetDummy == 0
label var InternetMinute "上网时长(分钟/天)"   //17289/26205
sum InternetMinute mobileInternetMinute computerInternetMinute, detail

* 上网学习
cap drop InternetStudyDummy
gen InternetStudyDummy = 0 if qu94==0 
replace InternetStudyDummy = 1 if qu94==1 | wu5==1  
replace InternetStudyDummy = 0 if InternetDummy == 0
label var InternetStudyDummy "是否利用互联网学习"
gen InternetStudy_LastWeek = InternetStudyDummy
label var InternetStudy_LastWeek "上周是否利用互联网学习"
tab InternetStudyDummy

* 上网学习时长
cap drop InternetStudyMinute
gen InternetStudyMinute = wu501
replace InternetStudyMinute = . if InternetStudyMinute < 0
replace InternetStudyMinute = 0 if InternetStudyDummy == 0
label var InternetStudyMinute "上网学习时长(分钟/天)"
sum InternetStudyMinute if InternetStudyMinute>0
sum InternetStudyMinute, detail  //只有509个样本（）上网学习时长大于0, 平均时长接近一小时

* 是否每天上网学习
cap drop InternetStudyDaily
tab qu941
tab qu941, nolabel
gen InternetStudyDaily = qu941
replace InternetStudyDaily = . if qu941 < 0
replace InternetStudyDaily = 0 if InternetStudyDummy == 0
label var InternetStudyDaily "是否每天上网学习"
tab InternetStudyDaily

* 上网学习频率无


* 上网工作： 无相关变量

* 上网社交： 无相关变量

* 上网娱乐： 包括短视频和游戏
cap drop InternetEntertainmentDummy
gen InternetEntertainmentDummy = 0 if qu91==0 & qu93==0
replace InternetEntertainmentDummy = 1 if qu91==1 | qu93==1
replace InternetEntertainmentDummy = 0 if InternetDummy == 0
label var InternetEntertainmentDummy "是否利用互联网娱乐"
gen InternetEntertainment_LastWeek = InternetEntertainmentDummy
label var InternetEntertainment_LastWeek "上周是否利用互联网娱乐"
tab InternetEntertainmentDummy

* 是否每天上网娱乐
cap drop InternetEntertainmentDaily
gen InternetEntertainmentDaily = (qu911==1 | qu931==1)
replace InternetEntertainmentDaily = . if qu911 < 0 & qu931 < 0
replace InternetEntertainmentDaily = 0 if InternetEntertainmentDummy == 0
label var InternetEntertainmentDaily "是否每天上网娱乐"
tab InternetEntertainmentDaily

* 上网娱乐频率: 无相关变量

* 上网购物
cap drop InternetShoppingDummy
gen InternetShoppingDummy = 0 if qu92==0
replace InternetShoppingDummy = 1 if qu92==1
replace InternetShoppingDummy = 0 if InternetDummy == 0
label var InternetShoppingDummy "是否利用互联网购物"
tab InternetShoppingDummy

* 是否每天上网购物
cap drop InternetShoppingDaily
gen InternetShoppingDaily = (qu921==1)
replace InternetShoppingDaily = . if qu921 < 0
replace InternetShoppingDaily = 0 if InternetShoppingDummy == 0
label var InternetShoppingDaily "是否每天上网购物"
tab InternetShoppingDaily

* 上网购物频率: 无相关变量

* 初始化全局变量
global indivVarList2022 ""

* 手动添加所有变量
global indivVarList2022 "pid fidbaseline fid10 fid12 fid14 fid16 fid18 fid20 cid countyid pid_f pid_m eduy eduyim peduexp1_tutor peduexp2_tutor peduexp_tutor peduexp peduexp2 peduexp1 schdum schstage schdorm schpub  wz301 wz302 studypr mathtest22 wf502 wf501 wordtest22 happy happy2 workdum marriage urban hukou han age  gender birthy wf501 wf502 emp_income InternetStudyMinute computerInternetMinute mobileInternetMinute InternetDummy InternetMinute InternetStudyDummy InternetStudy_LastWeek    InternetStudyDaily InternetEntertainmentDummy InternetEntertainment_LastWeek InternetEntertainmentDaily InternetShoppingDummy InternetShoppingDaily"

* 显示最终生成的变量列表
dis "$indivVarList2022"

gen wave = 2022
label var wave "调查年份"
rename pid_a_f pid_f
label var pid_f "父亲在调查中的样本编码"
rename pid_a_m pid_m
label var pid_m "母亲在调查中的样本编码"
rename respc1pid resppid
label var resppid "代答家长个人id"
cap drop code
gen countyid = countyid22
gen cid = cid22
merge m:1 countyid using "$cfpscountyid"  
keep if _merge!=2
drop _merge
keep $id_all $indivVarList2022
order $id_all $indivVarList2022
save "$temp/CFPS_IndividualVar_2022.dta", replace


use "$temp/CFPS_IndividualVar_2010.dta", clear
append using "$temp/CFPS_IndividualVar_2012.dta"
append using "$temp/CFPS_IndividualVar_2014.dta"
append using "$temp/CFPS_IndividualVar_2016.dta"
append using "$temp/CFPS_IndividualVar_2018.dta"
append using "$temp/CFPS_IndividualVar_2020.dta"
append using "$temp/CFPS_IndividualVar_2022.dta"


save "$temp/CFPS_IndividualVar_10_2_22.dta", replace
isid pid wave








//==================================================================//
/*                                父母特征清理                         */
//==================================================================//
local wave = "2010 2012 2014 2016 2018 2020 2022"
local parentsVarList = "pid age han hukou urban marriage workdum eduy eduyim"

foreach w of local wave {
    di "`w'年数据导入"
    use "$temp/CFPS_IndividualVar_`w'.dta", clear
    keep `parentsVarList'
    foreach var of local parentsVarList {
        rename `var'  `var'_f 
    }
    save "$temp/CFPS_FatherFeature_`w'.dta", replace
    dis "`w'年父亲特征保存成功 "
    isid pid_f

    use "$temp/CFPS_IndividualVar_`w'.dta", clear
    keep `parentsVarList'
    foreach v of local parentsVarList {
        rename `v'  `v'_m 
    }
    save "$temp/CFPS_MotherFeature_`w'.dta", replace
    dis "`w'年母亲特征保存成功 "
    isid pid_m
    
}

local wave = "10 12 14 16 18 20 22"
foreach w of local wave {
    use "$temp/CFPS_IndividualVar_20`w'.dta", clear
    merge m:1 pid_f using "$temp/CFPS_FatherFeature_20`w'.dta", update replace
    keep if _merge!=2
    drop _merge
    merge m:1 pid_m using "$temp/CFPS_MotherFeature_20`w'.dta", update replace
    keep if _merge!=2
    drop _merge
    merge m:1 fid`w' using "$temp/FamilyVar_20`w'.dta", update replace
    keep if _merge!=2
    drop _merge
    save "$temp/CFPS_IndivLevel_20`w'.dta", replace
}

use "$temp/CFPS_IndivLevel_2010.dta", clear
append using "$temp/CFPS_IndivLevel_2012.dta"
append using "$temp/CFPS_IndivLevel_2014.dta"
append using "$temp/CFPS_IndivLevel_2016.dta"
append using "$temp/CFPS_IndivLevel_2018.dta"
append using "$temp/CFPS_IndivLevel_2020.dta"
append using "$temp/CFPS_IndivLevel_2022.dta"



gen fid = fid12 if wave == 2012
replace fid = fid14 if wave == 2014
replace fid = fid16 if wave == 2016
replace fid = fid18 if wave == 2018
replace fid = fid20 if wave == 2020
save "$wkdata/CFPS_IndivLevel_1214161820.dta", replace
