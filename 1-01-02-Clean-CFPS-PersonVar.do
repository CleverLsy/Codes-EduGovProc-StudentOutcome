/*========================================================================
 * Program: 1-01-02_Clean_CFPS_PersonVar
 * Data:	CFPS 2010-2022
 * Author:  Yiping Yang, Songyue Liu
 * Aim: 需要整理出几类变量
 0. 个人id编码：未来使用countyid与区县层面教育信息化数据匹配
 pid fid cid countyid provcd
 样本：6-15岁青少年
 1. 控制变量：个人基本信息

 2. 因变量：儿童发展
    （1）学业表现：
    （2）认知和非认知结果：

 3. 调节变量：家庭因素

 4. 控制变量：家庭层面
 家庭资产、家庭收入、父母教育水平、家庭成员数量、父母婚姻情况、户口情况、居住地城乡

 5. 机制变量：孩子上网频率；上网娱乐频率；上网学习频率
========================================================================*/

/*0. prepare work*/
clear
set more off
capture log close //尝试关闭任何打开的日志文件

//将当前工作目录更改为由全局宏变量 CFPS 指定的路径
global id_all "pid  pid_f pid_m fid*  cid* countyid*   wave indsurvey*"
 


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




/////////////////////////////////
*2010年 个人基本特征和核心解释变量数据清理              *////////////////////////////////

use "$cfps2020crossyearid", clear
merge 1:1 pid using "$cfps2016crossyearid", force update   
//为什么要把16、20的crossid合并在一起呢？为了防止信息缺漏。crossyearid提取个人信息，包括性别民族等，样本是全的但变量不是全的。
keep if _merge!=2
//只保留那些在合并过程中在主用数据集中有匹配的观测，16年没有的变量不要。
drop _merge
merge 1:1 pid using "$cfps2010adult", force update
//都不添加，保留A的情况；update如果A存在缺失值，会被B替换，其他冲突不管；//都不添加，保留A的情况；update如果A存在缺失值，会被B替换，其他冲突不管； replace是冲突时以B为准
drop _merge
merge 1:1 pid using "$cfps2010child", force update
//目的是合成一个2010的全面版，包含全部成人、少儿的id，及他们在2010年的个人信息//目的是合成一个2010的全面版，包含全部成人、少儿的id，及他们在2010年的个人信息
keep if indsurvey10>0  //cfps2010的个人数据集类型，有部分不存在个人问卷的个体
drop _merge
tab indsurvey10
tab indsurvey10, nolabel //1 成人问卷 2 少儿问卷

* 【个人基本变量】
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

* 父母养育观念量表
gen parcon1 = we101
label var parcon1 "养育观念量表-离婚对孩子有害"
gen parcon2 = we102
label var parcon2 "养育观念量表-为孩子幸福也不应离婚"
gen parcon3 = we103
label var parcon3 "养育观念量表-应节衣缩食支付教育费"
gen parcon4 = we104
label var parcon4 "养育观念量表-成绩好坏父母有责"
gen parcon5 = we105
label var parcon5 "养育观念量表-经济自立父母有责"
gen parcon6 = we106
label var parcon6 "养育观念量表-孩子家庭和睦父母有责"
gen parcon7 = we107
label var parcon7 "养育观念量表-感情幸福父母有责"
gen parcon8 = we108
label var parcon8 "养育观念量表-遭遇车祸父母有责"

* 成就影响因素量表
gen achcon1 = we401
label var achcon1 "成就影响因素量表-家庭社会地位对孩子未来成就有多重要"
gen achcon2 = we402
label var achcon2 "成就影响因素量表-家庭经济条件对孩子未来成就有多重要"
gen achcon3 = we403
label var achcon3 "成就影响因素量表-受教育程度对孩子未来成就有多重要"
gen achcon4 = we404
label var achcon4 "成就影响因素量表-天赋对孩子未来成就有多重要"
gen achcon5 = we405
label var achcon5 "成就影响因素量表-努力程度对孩子未来成就有多重要"
gen achcon6 = we406
label var achcon6 "成就影响因素量表-运气对孩子未来成就有多重要"
gen achcon7 = we407
label var achcon7 "成就影响因素量表-家庭社会关系对孩子未来成就有多重要"

* 父母教养方式
gen parsty1 = wm201
label var parsty1 "当你做得不对时，家长会问清楚原因，并与你讨论该怎样做"
gen parsty2 = wm202
label var parsty2 "家长鼓励你努力去做事情"
gen parsty3 = wm203
label var parsty3 "家长在跟你说话的时候很和气"
gen parsty4 = wm204
label var parsty4 "家长鼓励你独立思考问题"
gen parsty5 = wm205
label var parsty5 "家长对你的要求很严格"
gen parsty6 = wm206
label var parsty6 "家长喜欢跟你交谈"
gen parsty7 = wm207
label var parsty7 "家长问你学校的情况"
gen parsty8 = wm208
label var parsty8 "家长检查你的作业"
gen parsty9 = wm209
label var parsty9 "家长辅导你的功课"
gen parsty10 = wm210
label var parsty10 "家长给你讲故事"
gen parsty11 = wm211
label var parsty11 "家长和你一起玩乐"
gen parsty12 = wm212
label var parsty12 "家长表扬你"
gen parsty13 = wm213
label var parsty13 "家长批评你"
gen parsty14 = wm214
label var parsty14 "父母参加家长会"
gen parsty15 = wf601
label var parsty15 "您会经常放弃看您自己喜欢的电视节目以免影响其学习吗"
gen parsty16 = wf602
label var parsty16 "您经常和这个孩子讨论学校里的事情"
gen parsty17 = wf603
label var parsty17 "您经常要求这个孩子完成家庭作业"
gen parsty18 = wf604
label var parsty18 "您经常检查这个孩子的家庭作业"
gen parsty19 = wf605
label var parsty19 "您经常阻止或终止这个孩子看电视"
gen parsty20 = wf606
label var parsty20 "您经常限制这个孩子所看电视节目的类型"
gen parsty21 = wd2
label var parsty21 "您希望孩子受教育程度"
gen parsty22 = wd4
label var parsty22 "过去12个月为孩子教育存钱（元）"
gen parsty23 = wz301
label var parsty23 "家庭的环境（孩子的画报、图书或其他学习材料）表明父母关心孩子的教育"
gen parsty24 = wz302
label var parsty24 "父母主动与孩子沟通和交流"
gen parsty25 = wn2
label var parsty25 "过去一个月与父母争吵次数"
gen parsty26 = wn3
label var parsty26 "过去一个月父母之间争吵次数"
*gen parsty27 = 
*label var parsty27 "过去一个月与父母谈心次数" //不对应要小心

* 父母其他观念，最后清理父母信息时单独列出来
gen paroth1 = qm701
label var paroth1 "经济繁荣要拉大收入差距"
gen paroth2 = qm702
label var paroth2 "公平竞争才有和谐人际"
gen paroth3 = qm703
label var paroth3 "财富反映个人成就"
gen paroth4 = qm704
label var paroth4 "努力工作能有回报"
gen paroth5 = qm705
label var paroth5 "聪明才干能得回报"
*gen paroth6 = qm706
*label var paroth6 "成大事难免腐败" //2010没有
gen paroth7 = qm707
label var paroth7 "有关系比有能力重要"
*gen paroth8 = qm708
*label var paroth8 "提高生活水平机会很大" //2010没有


*【因变量:个人发展】
* 学业表现
*  学习压力
gen studypr = ks502
label var studypr "学习压力（1没有-5压力大）"
* 认知能力
*  字词测试wordtest
replace wordtest = . if wordtest < 0
*  数学测试mathtest
replace mathtest = . if mathtest < 0
*  数列测试
* gen sqtest = ns_w
* label var sqtest "数列测试" //2010没有
*  即时记忆测试
* gen imtest = iwr
* label var imtest "即时记忆测试" //2010没有
*  延时记忆测试
* gen dmtest = dwr
* label var dmtest "延时记忆测试" //2010没有

* 非认知能力
* gen happy = qn416
* label var happy "我生活快乐" //2010没有
gen happy2 = we301
label var happy2 "这个孩子生性乐观"

* 凯斯勒心理疾患量表
gen kessler1 = qq601
label var kessler1 "凯斯勒量表-最近1个月，你感到情绪沮丧、郁闷、做什么事情都不能振奋的频率"
gen kessler2 = qq602
label var kessler2 "凯斯勒量表-最近1个月，你感到精神紧张的频率"
gen kessler3 = qq603
label var kessler3 "凯斯勒量表-最近1个月，你感到坐卧不安、难以保持平静的频率"
gen kessler4 = qq604
label var kessler4 "凯斯勒量表-最近1个月，你感到未来没有希望的频率"
gen kessler5 = qq605
label var kessler5 "凯斯勒量表-最近1个月，你做任何事情都感到困难的频率"
gen kessler6 = qq606
label var kessler6 "凯斯勒量表-最近1个月，你认为生活没有意义的频率"


* 手动添加
global indivVarList2010 "pid fidbaseline fid10 fid12 fid14 fid16 fid18 fid20 fid cid countyid pid_f pid_m feduc meduc eduy eduyim peduexp1 peduexp2 peduexp peduexp1_tutor peduexp2_tutor peduexp_tutor schdum schstage schdorm schpub schfull parcon1 parcon2 parcon3 parcon4 parcon5 parcon6 parcon7 parcon8 achcon1 achcon2 achcon3 achcon4 achcon5 achcon6 achcon7 parsty1 parsty2 parsty3 parsty4 parsty5 parsty6 parsty7 parsty8 parsty9 parsty10 parsty11 parsty12 parsty13 parsty14 parsty15 parsty16 parsty17 parsty18 parsty19 parsty20 parsty21 parsty22 parsty23 parsty24 parsty25 parsty26 paroth1 paroth2 paroth3 paroth4 paroth5 paroth7 kessler1 kessler2 kessler3 kessler4 kessler5 kessler6 wz301 wz302 wz201 wz202 wz203 wz204 wz205 wz206 wz207 wz208 wz209 wz210 wz211 wz212 studypr happy2 workdum marriage urban hukou han age indsurvey gender birthy wordtest mathtest income"


gen wave = 2010
label var wave "调查年份"
* merge m:1 countyid using "$cfpscountyid", update replace  //cityname code countyid countyname provname
* keep if _merge!=2
* drop _merge
gen resppid =  waproxy

keep $id_all $indivVarList2010
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

* 【个人基本变量】
codebook cid countyid 
gen indsurvey = indsurvey12
* gender
* birthy
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
gen urban = urban10
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
recode qg101  (1=1 "有工作")(0=0 "无工作") (-8 = . ), gen(workdum)
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

*个人所在学校情况
*是否寄宿
gen schdorm = wf304
label var schdorm "是否寄宿"
*是否公立学校（101214需recode）
recode kr402m (1=1) (2/6=2), generate(schpub)
label var schpub "是否公立学校"
*学校所在地属于城乡
gen schurban = kra2
label define schurban 1 "省会城市（包括直辖市）" 2 "一般城市（包括县级市、地级市)" 3 "县城" 4 "农村（包括乡镇村）"
*是否全日制学校
* gen schfull = kr404
* label var schfull "是否全日制学校"//12年没有


*【家庭因素】
* 个人教育支出  
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


* 父母养育观念量表
gen parcon1 = we101
label var parcon1 "养育观念量表-离婚对孩子有害"
gen parcon2 = we102
label var parcon2 "养育观念量表-为孩子幸福也不应离婚"
gen parcon3 = we103
label var parcon3 "养育观念量表-应节衣缩食支付教育费"
gen parcon4 = we104
label var parcon4 "养育观念量表-成绩好坏父母有责"
gen parcon5 = we105
label var parcon5 "养育观念量表-经济自立父母有责"
gen parcon6 = we106
label var parcon6 "养育观念量表-孩子家庭和睦父母有责"
gen parcon7 = we107
label var parcon7 "养育观念量表-感情幸福父母有责"
gen parcon8 = we108
label var parcon8 "养育观念量表-遭遇车祸父母有责"

* 成就影响因素量表
gen achcon1 = we401
label var achcon1 "成就影响因素量表-家庭社会地位对孩子未来成就有多重要"
gen achcon2 = we402
label var achcon2 "成就影响因素量表-家庭经济条件对孩子未来成就有多重要"
gen achcon3 = we403
label var achcon3 "成就影响因素量表-受教育程度对孩子未来成就有多重要"
gen achcon4 = we404
label var achcon4 "成就影响因素量表-天赋对孩子未来成就有多重要"
gen achcon5 = we405
label var achcon5 "成就影响因素量表-努力程度对孩子未来成就有多重要"
gen achcon6 = we406
label var achcon6 "成就影响因素量表-运气对孩子未来成就有多重要"
gen achcon7 = we407
label var achcon7 "成就影响因素量表-家庭社会关系对孩子未来成就有多重要"

* 父母教养方式
gen parsty1 = wm201
label var parsty1 "当你做得不对时，家长会问清楚原因，并与你讨论该怎样做"
gen parsty2 = wm202
label var parsty2 "家长鼓励你努力去做事情"
gen parsty3 = wm203
label var parsty3 "家长在跟你说话的时候很和气"
gen parsty4 = wm204
label var parsty4 "家长鼓励你独立思考问题"
gen parsty5 = wm205
label var parsty5 "家长对你的要求很严格"
gen parsty6 = wm206
label var parsty6 "家长喜欢跟你交谈"
gen parsty7 = wm207
label var parsty7 "家长问你学校的情况"
gen parsty8 = wm208
label var parsty8 "家长检查你的作业"
gen parsty9 = wm209
label var parsty9 "家长辅导你的功课"
gen parsty10 = wm210
label var parsty10 "家长给你讲故事"
gen parsty11 = wm211
label var parsty11 "家长和你一起玩乐"
gen parsty12 = wm212
label var parsty12 "家长表扬你"
gen parsty13 = wm213
label var parsty13 "家长批评你"
gen parsty14 = wm214
label var parsty14 "父母参加家长会"
gen parsty15 = wf601m
label var parsty15 "您会经常放弃看您自己喜欢的电视节目以免影响其学习吗"
gen parsty16 = wf602m
label var parsty16 "您经常和这个孩子讨论学校里的事情"
gen parsty17 = wf603m
label var parsty17 "您经常要求这个孩子完成家庭作业"
gen parsty18 = wf604m
label var parsty18 "您经常检查这个孩子的家庭作业"
gen parsty19 = wf605m
label var parsty19 "您经常阻止或终止这个孩子看电视"
gen parsty20 = wf606m
label var parsty20 "您经常限制这个孩子所看电视节目的类型"
gen parsty21 = wd2
label var parsty21 "您希望孩子受教育程度"
gen parsty22 = wd4
label var parsty22 "过去12个月为孩子教育存钱（元）"
gen parsty23 = wz301
label var parsty23 "家庭的环境（孩子的画报、图书或其他学习材料）表明父母关心孩子的教育"
gen parsty24 = wz302
label var parsty24 "父母主动与孩子沟通和交流"
gen parsty25 = wn2
label var parsty25 "过去一个月与父母争吵次数"
gen parsty26 = wn3
label var parsty26 "过去一个月父母之间争吵次数"


* 父母其他观念，最后清理父母信息时单独列出来
gen paroth1 = kv101
label var paroth1 "经济繁荣要拉大收入差距"
gen paroth2 = kv102
label var paroth2 "公平竞争才有和谐人际"
gen paroth3 = kv103
label var paroth3 "财富反映个人成就"
gen paroth4 = kv104
label var paroth4 "努力工作能有回报"
gen paroth5 = kv105
label var paroth5 "聪明才干能得回报"
gen paroth6 = kv106
label var paroth6 "成大事难免腐败" 
gen paroth7 = kv107
label var paroth7 "有关系比有能力重要"
gen paroth8 = kv108
label var paroth8 "提高生活水平机会很大"


*【因变量:个人发展】
* 学业表现
*  学习压力
gen studypr = ks502
label var studypr "学习压力（1没有-5压力大）"
* 认知能力
*  字词测试wordtest
*  数学测试mathtest
*  数列测试
gen sqtest = ns_w
label var sqtest "数列测试" 
*  即时记忆测试
gen imtest = iwr
label var imtest "即时记忆测试"
*  延时记忆测试
gen dmtest = dwr
label var dmtest "延时记忆测试" 

* 非认知能力
gen happy = qq60112
label var happy "我生活快乐" 
gen happy2 = we301
label var happy2 "这个孩子生性乐观"

/* 凯斯勒心理疾患量表
gen kessler1 = qq601
label var kessler1 "凯斯勒量表-最近1个月，你感到情绪沮丧、郁闷、做什么事情都不能振奋的频率"
gen kessler2 = qq602
label var kessler2 "凯斯勒量表-最近1个月，你感到精神紧张的频率"
gen kessler3 = qq603
label var kessler3 "凯斯勒量表-最近1个月，你感到坐卧不安、难以保持平静的频率"
gen kessler4 = qq604
label var kessler4 "凯斯勒量表-最近1个月，你感到未来没有希望的频率"
gen kessler5 = qq605
label var kessler5 "凯斯勒量表-最近1个月，你做任何事情都感到困难的频率"
gen kessler6 = qq606
label var kessler6 "凯斯勒量表-最近1个月，你认为生活没有意义的频率"
*/



* 手动添加所有变量
global indivVarList2012 "pid fidbaseline fid10 fid12 fid14 fid16 fid18 fid20 cid countyid pid_f pid_m eduy eduyim peduexp1 peduexp2 peduexp peduexp1_tutor peduexp2_tutor peduexp_tutor schdum schstage schdorm schpub parcon1 parcon2 parcon3 parcon4 parcon5 parcon6 parcon7 parcon8 achcon1 achcon2 achcon3 achcon4 achcon5 achcon6 achcon7 parsty1 parsty2 parsty3 parsty4 parsty5 parsty6 parsty7 parsty8 parsty9 parsty10 parsty11 parsty12 parsty13 parsty14 parsty15 parsty16 parsty17 parsty18 parsty19 parsty20 parsty21 parsty22 parsty23 parsty24 parsty25 parsty26 paroth1 paroth2 paroth3 paroth4 paroth5 paroth6 paroth7 wz301 wz302 qz201 qz202 qz203 qz204 qz205 qz206 qz207 qz208 qz209 qz210 qz211 qz212 studypr happy2 workdum marriage urban hukou han age indsurvey gender birthy wf501 wf502 income"

* 显示最终生成的变量列表
dis "$indivVarList2012"

gen wave = 2012
label var wave "调查年份"
* merge m:1 countyid using "$cfpscountyid", update replace  //cityname code countyid countyname provname
* keep if _merge!=2
* drop _merge
* gen resppid =  waproxy  //12年的没有【问师姐】
keep $id_all $indivVarList2012
order $id_all $indivVarList2012
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
keep if indsurvey14>0  //2012年存在个人问卷
drop _merge
merge 1:1 pid using "$cfps2014child", force update
keep if indsurvey14>0  //2012年存在个人问卷
drop _merge
tab indsurvey14
tab indsurvey14, nolabel //1 成人问卷 2 少儿问卷

* 【个人基本变量】
gen countyid = countyid14
gen cid = cid14
codebook cid14 countyid 
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
gen urban = urban10
replace urban = . if urban<0
label var urban "城乡,城镇=1,乡村=0"

* marriage
cap drop marriage
tab marriage_14
tab marriage_14, nolabel
gen marriage = (marriage_16 == 2) // 1 未婚 3 同居 4 离异 5 丧偶
replace marriage = . if marriage_14 < 0
label var marriage "婚姻状况,在婚=1"

* schdum
cap drop schdum
gen schdum = atschool2014
replace schdum = . if atschool2014 < 0
label var schdum "是否在上学"
tab age schdum

* workdum
cap drop workdum
recode qg101  (1=1 "有工作")(0=0 "无工作") (-8 = . ), gen(workdum)
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

*个人所在学校情况
*是否寄宿
gen schdorm = wf304
label var schdorm "是否寄宿"
*是否公立学校（101214需recode）
recode kr402m (1=1) (2/6=2), generate(schpub)
label var schpub "是否公立学校"
*学校所在地属于城乡
gen schurban = kra2
label define schurban 1 "省会城市（包括直辖市）" 2 "一般城市（包括县级市、地级市)" 3 "县城" 4 "农村（包括乡镇村）"
*是否全日制学校
* gen schfull = kr404
* label var schfull "是否全日制学校"//1214年没有


*【家庭因素】

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


* 父母养育观念量表
gen parcon1 = we101
label var parcon1 "养育观念量表-离婚对孩子有害"
gen parcon2 = we102
label var parcon2 "养育观念量表-为孩子幸福也不应离婚"
gen parcon3 = we103
label var parcon3 "养育观念量表-应节衣缩食支付教育费"
gen parcon4 = we104
label var parcon4 "养育观念量表-成绩好坏父母有责"
gen parcon5 = we105
label var parcon5 "养育观念量表-经济自立父母有责"
gen parcon6 = we106
label var parcon6 "养育观念量表-孩子家庭和睦父母有责"
gen parcon7 = we107
label var parcon7 "养育观念量表-感情幸福父母有责"
gen parcon8 = we108
label var parcon8 "养育观念量表-遭遇车祸父母有责"

* 成就影响因素量表
gen achcon1 = we401
label var achcon1 "成就影响因素量表-家庭社会地位对孩子未来成就有多重要"
gen achcon2 = we402
label var achcon2 "成就影响因素量表-家庭经济条件对孩子未来成就有多重要"
gen achcon3 = we403
label var achcon3 "成就影响因素量表-受教育程度对孩子未来成就有多重要"
gen achcon4 = we404
label var achcon4 "成就影响因素量表-天赋对孩子未来成就有多重要"
gen achcon5 = we405
label var achcon5 "成就影响因素量表-努力程度对孩子未来成就有多重要"
gen achcon6 = we406
label var achcon6 "成就影响因素量表-运气对孩子未来成就有多重要"
gen achcon7 = we407
label var achcon7 "成就影响因素量表-家庭社会关系对孩子未来成就有多重要"

* 父母教养方式
gen parsty1 = wm201
label var parsty1 "当你做得不对时，家长会问清楚原因，并与你讨论该怎样做"
gen parsty2 = wm202
label var parsty2 "家长鼓励你努力去做事情"
gen parsty3 = wm203
label var parsty3 "家长在跟你说话的时候很和气"
gen parsty4 = wm204
label var parsty4 "家长鼓励你独立思考问题"
gen parsty5 = wm205
label var parsty5 "家长对你的要求很严格"
gen parsty6 = wm206
label var parsty6 "家长喜欢跟你交谈"
gen parsty7 = wm207
label var parsty7 "家长问你学校的情况"
gen parsty8 = wm208
label var parsty8 "家长检查你的作业"
gen parsty9 = wm209
label var parsty9 "家长辅导你的功课"
gen parsty10 = wm210
label var parsty10 "家长给你讲故事"
gen parsty11 = wm211
label var parsty11 "家长和你一起玩乐"
gen parsty12 = wm212
label var parsty12 "家长表扬你"
gen parsty13 = wm213
label var parsty13 "家长批评你"
gen parsty14 = wm214
label var parsty14 "父母参加家长会"
gen parsty15 = wf601m
label var parsty15 "您会经常放弃看您自己喜欢的电视节目以免影响其学习吗"
gen parsty16 = wf602m
label var parsty16 "您经常和这个孩子讨论学校里的事情"
gen parsty17 = wf603m
label var parsty17 "您经常要求这个孩子完成家庭作业"
gen parsty18 = wf604m
label var parsty18 "您经常检查这个孩子的家庭作业"
gen parsty19 = wf605m
label var parsty19 "您经常阻止或终止这个孩子看电视"
gen parsty20 = wf606m
label var parsty20 "您经常限制这个孩子所看电视节目的类型"
gen parsty21 = wd2
label var parsty21 "您希望孩子受教育程度"
gen parsty22 = wd4
label var parsty22 "过去12个月为孩子教育存钱（元）"
gen parsty23 = wz301
label var parsty23 "家庭的环境（孩子的画报、图书或其他学习材料）表明父母关心孩子的教育"
gen parsty24 = wz302
label var parsty24 "父母主动与孩子沟通和交流"
gen parsty25 = wn2
label var parsty25 "过去一个月与父母争吵次数"
gen parsty26 = wn3
label var parsty26 "过去一个月父母之间争吵次数"

* 父母其他观念，最后清理父母信息时单独列出来
gen paroth1 = wv101
label var paroth1 "经济繁荣要拉大收入差距"
gen paroth2 = wv102
label var paroth2 "公平竞争才有和谐人际"
gen paroth3 = wv103
label var paroth3 "财富反映个人成就"
gen paroth4 = wv104
label var paroth4 "努力工作能有回报"
gen paroth5 = wv105
label var paroth5 "聪明才干能得回报"
gen paroth6 = wv106
label var paroth6 "成大事难免腐败" //2010没有
gen paroth7 = wv107
label var paroth7 "有关系比有能力重要"
gen paroth8 = wv108
label var paroth8 "提高生活水平机会很大" //2010没有


*【因变量:个人发展】
* 学业表现
*  学习压力
gen studypr = ks502
label var studypr "学习压力（1没有-5压力大）"
* 认知能力
*  字词测试wordtest
gen wordtest = wordtest14
replace wordtest = . if wordtest < 0
*  数学测试mathtest
gen mathtest = mathtest14
replace mathtest = . if mathtest < 0
/*  数列测试
gen sqtest = ns_w
label var sqtest "数列测试" //2010没有
*  即时记忆测试
gen imtest = iwr
label var imtest "即时记忆测试" //2010没有
*  延时记忆测试
gen dmtest = dwr
label var dmtest "延时记忆测试" //2010没有
*/
* 非认知能力
* gen happy = qq60112
* label var happy "我生活快乐" //2010 14没有
gen happy2 = we301
label var happy2 "这个孩子生性乐观"

* 凯斯勒心理疾患量表 
gen kessler1 = qq601
label var kessler1 "凯斯勒量表-最近1个月，你感到情绪沮丧、郁闷、做什么事情都不能振奋的频率"
gen kessler2 = qq602
label var kessler2 "凯斯勒量表-最近1个月，你感到精神紧张的频率"
gen kessler3 = qq603
label var kessler3 "凯斯勒量表-最近1个月，你感到坐卧不安、难以保持平静的频率"
gen kessler4 = qq604
label var kessler4 "凯斯勒量表-最近1个月，你感到未来没有希望的频率"
gen kessler5 = qq605
label var kessler5 "凯斯勒量表-最近1个月，你做任何事情都感到困难的频率"
gen kessler6 = qq606
label var kessler6 "凯斯勒量表-最近1个月，你认为生活没有意义的频率"


*【互联网模块】
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



* 手动添加所有变量
global indivVarList2014 "pid fidbaseline fid10 fid12 fid14 fid16 fid18 fid20 cid countyid pid_f pid_m eduy eduyim peduexp1 peduexp2 peduexp peduexp1_tutor peduexp_tutor schdum schstage schdorm schpub parcon1 parcon2 parcon3 parcon4 parcon5 parcon6 parcon7 parcon8 achcon1 achcon2 achcon3 achcon4 achcon5 achcon6 achcon7 parsty1 parsty2 parsty3 parsty4 parsty5 parsty6 parsty7 parsty8 parsty9 parsty10 parsty11 parsty12 parsty13 parsty14 parsty15 parsty16 parsty17 parsty18 parsty19 parsty20 parsty21 parsty22 parsty23 parsty24 parsty25 parsty26 paroth1 paroth2 paroth3 paroth4 paroth5 paroth6 paroth7 wz301 wz302 qz201 qz202 qz203 qz204 qz205 qz206 qz207 qz208 qz209 qz210 qz211 qz212 kessler1 kessler2 kessler3 kessler4 kessler5 kessler6 studypr wordtest mathtest happy2 workdum marriage urban hukou han age indsurvey gender birthy wf501 wf502 income InternetDummy InternetMinute InternetStudyDummy InternetStudy_LastWeek  InternetStudyDaily InternetStudyFreq InternetWorkDummy InternetWorkDaily InternetWorkFreq InternetSocialDummy InternetSocialDaily InternetSocialFreq InternetEntertainmentDummy InternetEntertainment_LastWeek InternetEntertainmentDaily InternetEntertainmentFreq InternetShoppingDummy InternetShoppingDaily InternetShoppingFreq"


gen wave = 2014
label var wave "调查年份"
* merge m:1 countyid using "$cfpscountyid", update replace  //cityname code countyid countyname provname
* keep if _merge!=2
* drop _merge
* gen resppid =  waproxy //12年的没有【问师姐】
keep $id_all $indivVarList2014
order $id_all $indivVarList2014
save "$temp/CFPS_IndividualVar_2014.dta", replace
isid pid



//==================================================================//
/*              2016 个人基本特征和核心解释变量数据清理                  */
//==================================================================//
use "$cfps2020crossyearid", clear
merge 1:1 pid using "$cfps2016crossyearid", force update
keep if _merge!=2
drop _merge
merge 1:1 pid using "$cfps2016adult", force update
keep if indsurvey16>0  //2012年存在个人问卷
drop _merge
merge 1:1 pid using "$cfps2016child", force update
keep if indsurvey16>0  //2012年存在个人问卷
drop _merge
tab indsurvey16
tab indsurvey16, nolabel //1 成人问卷 2 少儿问卷

* 【个人基本变量】
codebook cid16 countyid16 
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
recode hk16 (1=1 "农业户口")(3  = 0 "非农户口")(-8 -2 -1 5 79 = .), gen(hukou)
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
gen marriage = (marriage_18 == 2) // 1 未婚 3 同居 4 离异 5 丧偶
replace marriage = . if marriage_16 < 0
label var marriage "婚姻状况,在婚=1"

* schdum
cap drop schdum
gen schdum = atschool2016
replace schdum = . if atschool2016 < 0
label var schdum "是否在上学"
tab age schdum

* workdum
cap drop workdum
recode qg101  (1=1 "有工作")(0=0 "无工作") (-8 = . ), gen(workdum)
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
gen schstage = cfps2014sch if schdum==1
replace schstage = . if cfps2016sch < 0
label define schstage 1 "小学以下" 2 "小学" 3 "初中" 4 "高中" 5 "大专" 6 "大学本科" 7 "硕士" 8 "博士"
label values schstage schstage
label var schstage "在校阶段(仅针对在校生schdum==1)"
tab schstage

*个人所在学校情况
*是否寄宿
gen schdorm = ps1001
label var schdorm "是否寄宿"
*是否公立学校（101214需recode）
gen schpub = ps601
label var schpub "是否公立学校"
*学校所在地属于城乡
gen schurban = ps1002
label define schurban 1 "省会城市（包括直辖市）" 2 "一般城市（包括县级市、地级市)" 3 "县城" 4 "农村（包括乡镇村）"
*是否全日制学校
* gen schfull = kr404
* label var schfull "是否全日制学校"//1214年没有


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



/* 父母养育观念量表，16没有
gen parcon1 = we101
label var parcon1 "养育观念量表-离婚对孩子有害"
gen parcon2 = we102
label var parcon2 "养育观念量表-为孩子幸福也不应离婚"
gen parcon3 = we103
label var parcon3 "养育观念量表-应节衣缩食支付教育费"
gen parcon4 = we104
label var parcon4 "养育观念量表-成绩好坏父母有责"
gen parcon5 = we105
label var parcon5 "养育观念量表-经济自立父母有责"
gen parcon6 = we106
label var parcon6 "养育观念量表-孩子家庭和睦父母有责"
gen parcon7 = we107
label var parcon7 "养育观念量表-感情幸福父母有责"
gen parcon8 = we108
label var parcon8 "养育观念量表-遭遇车祸父母有责"

* 成就影响因素量表，16没有
gen achcon1 = we401
label var achcon1 "成就影响因素量表-家庭社会地位对孩子未来成就有多重要"
gen achcon2 = we402
label var achcon2 "成就影响因素量表-家庭经济条件对孩子未来成就有多重要"
gen achcon3 = we403
label var achcon3 "成就影响因素量表-受教育程度对孩子未来成就有多重要"
gen achcon4 = we404
label var achcon4 "成就影响因素量表-天赋对孩子未来成就有多重要"
gen achcon5 = we405
label var achcon5 "成就影响因素量表-努力程度对孩子未来成就有多重要"
gen achcon6 = we406
label var achcon6 "成就影响因素量表-运气对孩子未来成就有多重要"
gen achcon7 = we407
label var achcon7 "成就影响因素量表-家庭社会关系对孩子未来成就有多重要"

* 父母教养方式，16没有
gen parsty1 = wm201
label var parsty1 "当你做得不对时，家长会问清楚原因，并与你讨论该怎样做"
gen parsty2 = wm202
label var parsty2 "家长鼓励你努力去做事情"
gen parsty3 = wm203
label var parsty3 "家长在跟你说话的时候很和气"
gen parsty4 = wm204
label var parsty4 "家长鼓励你独立思考问题"
gen parsty5 = wm205
label var parsty5 "家长对你的要求很严格"
gen parsty6 = wm206
label var parsty6 "家长喜欢跟你交谈"
gen parsty7 = wm207
label var parsty7 "家长问你学校的情况"
gen parsty8 = wm208
label var parsty8 "家长检查你的作业"
gen parsty9 = wm209
label var parsty9 "家长辅导你的功课"
gen parsty10 = wm210
label var parsty10 "家长给你讲故事"
gen parsty11 = wm211
label var parsty11 "家长和你一起玩乐"
gen parsty12 = wm212
label var parsty12 "家长表扬你"
gen parsty13 = wm213
label var parsty13 "家长批评你"
gen parsty14 = wm214
label var parsty14 "父母参加家长会"
gen parsty15 = wf601
label var parsty15 "您会经常放弃看您自己喜欢的电视节目以免影响其学习吗"
gen parsty16 = wf602
label var parsty16 "您经常和这个孩子讨论学校里的事情"
gen parsty17 = wf603
label var parsty17 "您经常要求这个孩子完成家庭作业"
gen parsty18 = wf604
label var parsty18 "您经常检查这个孩子的家庭作业"
gen parsty19 = wf605
label var parsty19 "您经常阻止或终止这个孩子看电视"
gen parsty20 = wf606
label var parsty20 "您经常限制这个孩子所看电视节目的类型"
*/
gen parsty21 = wd2
label var parsty21 "您希望孩子受教育程度"
gen parsty22 = wd4
label var parsty22 "过去12个月为孩子教育存钱（元）"
gen parsty23 = wz301
label var parsty23 "家庭的环境（孩子的画报、图书或其他学习材料）表明父母关心孩子的教育"
gen parsty24 = wz302
label var parsty24 "父母主动与孩子沟通和交流"
gen parsty25 = wn2
label var parsty25 "过去一个月与父母争吵次数"
gen parsty26 = wn3
label var parsty26 "过去一个月父母之间争吵次数"

/*
* 父母其他观念，最后清理父母信息时单独列出来，16没有
gen paroth1 = wv101
label var paroth1 "经济繁荣要拉大收入差距"
gen paroth2 = wv102
label var paroth2 "公平竞争才有和谐人际"
gen paroth3 = wv103
label var paroth3 "财富反映个人成就"
gen paroth4 = wv104
label var paroth4 "努力工作能有回报"
gen paroth5 = wv105
label var paroth5 "聪明才干能得回报"
gen paroth6 = wv106
label var paroth6 "成大事难免腐败" //2010没有
gen paroth7 = wv107
label var paroth7 "有关系比有能力重要"
gen paroth8 = wv108
label var paroth8 "提高生活水平机会很大" //2010没有
*/

*【因变量:个人发展】
* 学业表现
*  学习压力
gen studypr = ks502
label var studypr "学习压力（1没有-5压力大）"
* 认知能力
*  字词测试wordtest
*  数学测试mathtest
*  数列测试
gen sqtest = ns_w
label var sqtest "数列测试" 
*  即时记忆测试
gen imtest = iwr
label var imtest "即时记忆测试" 
*  延时记忆测试
gen dmtest = dwr
label var dmtest "延时记忆测试" 

* 非认知能力
 gen happy = pn416
 label var happy "我生活快乐" //2010 14没有
* gen happy2 = we301
* label var happy2 "这个孩子生性乐观" //16没有

/* 凯斯勒心理疾患量表 //1216没有
gen kessler1 = qq601
label var kessler1 "凯斯勒量表-最近1个月，你感到情绪沮丧、郁闷、做什么事情都不能振奋的频率"
gen kessler2 = qq602
label var kessler2 "凯斯勒量表-最近1个月，你感到精神紧张的频率"
gen kessler3 = qq603
label var kessler3 "凯斯勒量表-最近1个月，你感到坐卧不安、难以保持平静的频率"
gen kessler4 = qq604
label var kessler4 "凯斯勒量表-最近1个月，你感到未来没有希望的频率"
gen kessler5 = qq605
label var kessler5 "凯斯勒量表-最近1个月，你做任何事情都感到困难的频率"
gen kessler6 = qq606
label var kessler6 "凯斯勒量表-最近1个月，你认为生活没有意义的频率"
*/

*【互联网模块】
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


* 手动添加所有变量
global indivVarList2016 "pid fidbaseline fid10 fid12 fid14 fid16 fid18 fid20 cid countyid pid_f pid_m eduy eduyim  peduexp peduexp_tutor schdum schstage schdorm schpub  wz301 wz302 parsty21 parsty22 parsty23 parsty24 parsty25 parsty26 studypr happy workdum marriage urban hukou han age indsurvey gender birthy wf501 wf502 income InternetDummy InternetMinute InternetStudyDummy  InternetStudy_LastWeek   InternetStudyDaily InternetStudyFreq InternetWorkDummy InternetWorkDaily InternetWorkFreq InternetSocialDummy InternetSocialDaily InternetSocialFreq InternetEntertainmentDummy InternetEntertainment_LastWeek InternetEntertainmentDaily InternetEntertainmentFreq InternetShoppingDummy InternetShoppingDaily InternetShoppingFreq"


* 显示最终生成的变量列表
dis "$indivVarList2016"

gen wave = 2016
label var wave "调查年份"
gen countyid = countyid16
gen cid = cid16
* merge m:1 countyid using "$cfpscountyid", update replace  //cityname code countyid countyname provname
* keep if _merge!=2
* drop _merge
* gen resppid =  waproxy 
keep $id_all $indivVarList2016
order $id_all $indivVarList2016
save "$temp/CFPS_IndividualVar_2016.dta", replace
isid pid



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

* 【个人基本变量】
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
recode hk18 (1=1 "农业户口")(3  = 0 "非农户口")(-8 -2 -1 5 79 = .), gen(hukou)
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
gen marriage = (marriage_20 == 2) // 1 未婚 3 同居 4 离异 5 丧偶
replace marriage = . if marriage_18 < 0
label var marriage "婚姻状况,在婚=1"

* schdum
cap drop schdum
gen schdum = school
replace schdum = 1 if school == 5 //学期间假期中
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
*是否全日制学校
* gen schfull = kr404
* label var schfull "是否全日制学校"//1214年没有


*【家庭因素】
* 个人教育支出  
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


/* 父母养育观念量表，1618没有
gen parcon1 = we101
label var parcon1 "养育观念量表-离婚对孩子有害"
gen parcon2 = we102
label var parcon2 "养育观念量表-为孩子幸福也不应离婚"
gen parcon3 = we103
label var parcon3 "养育观念量表-应节衣缩食支付教育费"
gen parcon4 = we104
label var parcon4 "养育观念量表-成绩好坏父母有责"
gen parcon5 = we105
label var parcon5 "养育观念量表-经济自立父母有责"
gen parcon6 = we106
label var parcon6 "养育观念量表-孩子家庭和睦父母有责"
gen parcon7 = we107
label var parcon7 "养育观念量表-感情幸福父母有责"
gen parcon8 = we108
label var parcon8 "养育观念量表-遭遇车祸父母有责"

* 成就影响因素量表，1618没有
gen achcon1 = we401
label var achcon1 "成就影响因素量表-家庭社会地位对孩子未来成就有多重要"
gen achcon2 = we402
label var achcon2 "成就影响因素量表-家庭经济条件对孩子未来成就有多重要"
gen achcon3 = we403
label var achcon3 "成就影响因素量表-受教育程度对孩子未来成就有多重要"
gen achcon4 = we404
label var achcon4 "成就影响因素量表-天赋对孩子未来成就有多重要"
gen achcon5 = we405
label var achcon5 "成就影响因素量表-努力程度对孩子未来成就有多重要"
gen achcon6 = we406
label var achcon6 "成就影响因素量表-运气对孩子未来成就有多重要"
gen achcon7 = we407
label var achcon7 "成就影响因素量表-家庭社会关系对孩子未来成就有多重要"

* 父母教养方式，1618没有
gen parsty1 = wm201
label var parsty1 "当你做得不对时，家长会问清楚原因，并与你讨论该怎样做"
gen parsty2 = wm202
label var parsty2 "家长鼓励你努力去做事情"
gen parsty3 = wm203
label var parsty3 "家长在跟你说话的时候很和气"
gen parsty4 = wm204
label var parsty4 "家长鼓励你独立思考问题"
gen parsty5 = wm205
label var parsty5 "家长对你的要求很严格"
gen parsty6 = wm206
label var parsty6 "家长喜欢跟你交谈"
gen parsty7 = wm207
label var parsty7 "家长问你学校的情况"
gen parsty8 = wm208
label var parsty8 "家长检查你的作业"
gen parsty9 = wm209
label var parsty9 "家长辅导你的功课"
gen parsty10 = wm210
label var parsty10 "家长给你讲故事"
gen parsty11 = wm211
label var parsty11 "家长和你一起玩乐"
gen parsty12 = wm212
label var parsty12 "家长表扬你"
gen parsty13 = wm213
label var parsty13 "家长批评你"
gen parsty14 = wm214
label var parsty14 "父母参加家长会"
gen parsty15 = wf601
label var parsty15 "您会经常放弃看您自己喜欢的电视节目以免影响其学习吗"
gen parsty16 = wf602
label var parsty16 "您经常和这个孩子讨论学校里的事情"
gen parsty17 = wf603
label var parsty17 "您经常要求这个孩子完成家庭作业"
gen parsty18 = wf604
label var parsty18 "您经常检查这个孩子的家庭作业"
gen parsty19 = wf605
label var parsty19 "您经常阻止或终止这个孩子看电视"
gen parsty20 = wf606
label var parsty20 "您经常限制这个孩子所看电视节目的类型"
*/
gen parsty21 = wd2
label var parsty21 "您希望孩子受教育程度"
gen parsty22 = wd4
label var parsty22 "过去12个月为孩子教育存钱（元）"
gen parsty23 = wz301
label var parsty23 "家庭的环境（孩子的画报、图书或其他学习材料）表明父母关心孩子的教育"
gen parsty24 = wz302
label var parsty24 "父母主动与孩子沟通和交流"
gen parsty25 = qn2
label var parsty25 "过去一个月与父母争吵次数"
gen parsty26 = qn3
label var parsty26 "过去一个月父母之间争吵次数"


* 父母其他观念，最后清理父母信息时单独列出来，16没有
gen paroth1 = wv101
label var paroth1 "经济繁荣要拉大收入差距"
gen paroth2 = wv102
label var paroth2 "公平竞争才有和谐人际"
gen paroth3 = wv103
label var paroth3 "财富反映个人成就"
gen paroth4 = wv104
label var paroth4 "努力工作能有回报"
gen paroth5 = wv105
label var paroth5 "聪明才干能得回报"
gen paroth6 = wv106
label var paroth6 "成大事难免腐败" 
gen paroth7 = wv107
label var paroth7 "有关系比有能力重要"
gen paroth8 = wv108
label var paroth8 "提高生活水平机会很大" 


*【因变量:个人发展】
* 学业表现
*  学习压力
gen studypr = qs502
label var studypr "学习压力（1没有-5压力大）"
* 认知能力
*  字词测试wordtest
gen wordtest = wordtest18
replace wordtest = . if wordtest < 0
*  数学测试mathtest
gen mathtest = mathtest18
replace mathtest = . if mathtest < 0
/* *  数列测试
gen sqtest = ns_w
label var sqtest "数列测试" //2010没有
*  即时记忆测试
gen imtest = iwr
label var imtest "即时记忆测试" //2010没有
*  延时记忆测试
gen dmtest = dwr
label var dmtest "延时记忆测试" //2010没有
*/
* 非认知能力
gen happy = qn416
label var happy "我生活快乐" //2010 14没有
* gen happy2 = we301
* label var happy2 "这个孩子生性乐观" //16 18没有

/* 凯斯勒心理疾患量表 //121618没有
gen kessler1 = qq601
label var kessler1 "凯斯勒量表-最近1个月，你感到情绪沮丧、郁闷、做什么事情都不能振奋的频率"
gen kessler2 = qq602
label var kessler2 "凯斯勒量表-最近1个月，你感到精神紧张的频率"
gen kessler3 = qq603
label var kessler3 "凯斯勒量表-最近1个月，你感到坐卧不安、难以保持平静的频率"
gen kessler4 = qq604
label var kessler4 "凯斯勒量表-最近1个月，你感到未来没有希望的频率"
gen kessler5 = qq605
label var kessler5 "凯斯勒量表-最近1个月，你做任何事情都感到困难的频率"
gen kessler6 = qq606
label var kessler6 "凯斯勒量表-最近1个月，你认为生活没有意义的频率"
*/

*【互联网模块】
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

* 初始化全局变量
global indivVarList2018 ""

rename pid_a_f pid_f 
rename pid_a_m pid_m

* 手动添加所有变量
global indivVarList2018 "pid fidbaseline fid10 fid12 fid14 fid16 fid18 fid20 cid countyid pid_f pid_m eduy eduyim peduexp1_tutor peduexp2_tutor peduexp_tutor peduexp peduexp2 peduexp1 schdum schstage schdorm schpub  wz301 wz302 parsty21 parsty22 parsty23 parsty24 parsty25 parsty26 paroth1 paroth2 paroth3 paroth4 paroth5 paroth7  studypr happy workdum marriage urban hukou han age indsurvey gender birthy wf501 wf502 income mathtest mathtest18_sc2 wordtest wordtest18_sc2 InternetDummy InternetMinute InternetStudyDummy InternetStudy_LastWeek    InternetStudyDaily InternetStudyFreq InternetWorkDummy InternetWorkDaily InternetWorkFreq InternetSocialDummy InternetSocialDaily InternetSocialFreq InternetEntertainmentDummy InternetEntertainment_LastWeek InternetEntertainmentDaily InternetEntertainmentFreq InternetShoppingDummy InternetShoppingDaily InternetShoppingFreq"

* 显示最终生成的变量列表
dis "$indivVarList2018"

gen wave = 2018
label var wave "调查年份"
gen countyid = countyid18
gen cid = cid18
* merge m:1 countyid using "$cfpscountyid", update replace  //cityname code countyid countyname provname
* keep if _merge!=2
* drop _merge
keep $id_all $indivVarList2018
order $id_all $indivVarList2018
save "$temp/CFPS_IndividualVar_2018.dta", replace
isid pid


//==================================================================//
/*              2020 个人基本特征和核心解释变量数据清理                */
//==================================================================//
use "$cfps2020crossyearid", clear
merge 1:1 pid using "$cfps2020person", force update
keep if indsurvey20>0  //2018年存在个人问卷
drop _merge
merge 1:1 pid using "$cfps2020childproxy", force update
keep if indsurvey20>0  //2018年存在个人问卷
drop _merge
tab indsurvey20
tab indsurvey20, nolabel //3 同时存在 4 只存在个人问卷 5 只存在少儿家长代答问卷

* 【个人基本变量】
gen indsurvey = indsurvey20
* gender
* birthy
* age
cap drop age
gen age = 2020 - birthy
label var age "年龄"

* han
cap drop han
gen han = (ethnicity==1)
label var han "汉族"

* hukou
cap drop hukou
tab hk20r
tab hk20r, nolabel
recode hk20r (1=1 "农业户口")(3  = 0 "非农户口")(-8 -2 -1 5 79 = .), gen(hukou)
label var hukou "户口类型,农业户口=1, 非农户口=0"

* urban
cap drop urban
tab urban20
tab urban20, nolabel
gen urban = urban20
replace urban = . if urban<0
label var urban "城乡,城镇=1,乡村=0"

* marriage
cap drop marriage
tab marriage_20
tab marriage_20, nolabel
gen marriage = (marriage_20 == 2) // 1 未婚 3 同居 4 离异 5 丧偶
replace marriage = . if marriage_18 < 0
label var marriage "婚姻状况,在婚=1"

* schdum
cap drop schdum
gen schdum = school
replace schdum = 1 if school == 5 //学期间假期中
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
tab cfps2020eduy
tab  cfps2020eduy_im

gen eduy = cfps2020eduy
replace eduy = . if cfps2020eduy < 0
label var eduy "最高受教育年限"

gen eduyim = cfps2020eduy_im
replace eduyim = . if cfps2020eduy_im < 0
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



*【家庭因素】
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

* 父母养育观念量表，1618没有
gen parcon1 = we101
label var parcon1 "养育观念量表-离婚对孩子有害"
gen parcon2 = we102
label var parcon2 "养育观念量表-为孩子幸福也不应离婚"
gen parcon3 = we103
label var parcon3 "养育观念量表-应节衣缩食支付教育费"
gen parcon4 = we104
label var parcon4 "养育观念量表-成绩好坏父母有责"
gen parcon5 = we105
label var parcon5 "养育观念量表-经济自立父母有责"
gen parcon6 = we106
label var parcon6 "养育观念量表-孩子家庭和睦父母有责"
gen parcon7 = we107
label var parcon7 "养育观念量表-感情幸福父母有责"
gen parcon8 = we108
label var parcon8 "养育观念量表-遭遇车祸父母有责"

* 成就影响因素量表，1618没有
gen achcon1 = we401
label var achcon1 "成就影响因素量表-家庭社会地位对孩子未来成就有多重要"
gen achcon2 = we402
label var achcon2 "成就影响因素量表-家庭经济条件对孩子未来成就有多重要"
gen achcon3 = we403
label var achcon3 "成就影响因素量表-受教育程度对孩子未来成就有多重要"
gen achcon4 = we404
label var achcon4 "成就影响因素量表-天赋对孩子未来成就有多重要"
gen achcon5 = we405
label var achcon5 "成就影响因素量表-努力程度对孩子未来成就有多重要"
gen achcon6 = we406
label var achcon6 "成就影响因素量表-运气对孩子未来成就有多重要"
gen achcon7 = we407
label var achcon7 "成就影响因素量表-家庭社会关系对孩子未来成就有多重要"

* 父母教养方式，1618没有
gen parsty1 = qm201_b_2
label var parsty1 "当你做得不对时，家长会问清楚原因，并与你讨论该怎样做"
gen parsty2 = qm202_b_2
label var parsty2 "家长鼓励你努力去做事情"
gen parsty3 = qm203_b_2
label var parsty3 "家长在跟你说话的时候很和气"
gen parsty4 = qm204_b_2
label var parsty4 "家长鼓励你独立思考问题"
gen parsty5 = qm205_b_2
label var parsty5 "家长对你的要求很严格"
gen parsty6 = qm206_b_2
label var parsty6 "家长喜欢跟你交谈"
gen parsty7 = qm207_b_2
label var parsty7 "家长问你学校的情况"
gen parsty8 = qm208_b_2
label var parsty8 "家长检查你的作业"
gen parsty9 = qm209_b_2
label var parsty9 "家长辅导你的功课"
gen parsty10 = qm210_b_2
label var parsty10 "家长给你讲故事"
gen parsty11 = qm211_b_2
label var parsty11 "家长和你一起玩乐"
gen parsty12 = qm212_b_2
label var parsty12 "家长表扬你"
gen parsty13 = qm213_b_2
label var parsty13 "家长批评你"
gen parsty14 = qm214_b_2
label var parsty14 "父母参加家长会"
* gen parsty15 = 
* label var parsty15 "您会经常放弃看您自己喜欢的电视节目以免影响其学习吗"//20没有
gen parsty16 = wf602m
label var parsty16 "您经常和这个孩子讨论学校里的事情"
gen parsty17 = wf603m
label var parsty17 "您经常要求这个孩子完成家庭作业"
gen parsty18 = wf604m
label var parsty18 "您经常检查这个孩子的家庭作业"
gen parsty19 = wf605mn
label var parsty19 "您经常阻止或终止这个孩子看电视"
gen parsty20 = wf606mn
label var parsty20 "您经常限制这个孩子所看电视节目的类型"
gen parsty21 = wd2
label var parsty21 "您希望孩子受教育程度"
gen parsty22 = wd4
label var parsty22 "过去12个月为孩子教育存钱（元）"
gen parsty23 = wz301
label var parsty23 "家庭的环境（孩子的画报、图书或其他学习材料）表明父母关心孩子的教育"
gen parsty24 = wz302
label var parsty24 "父母主动与孩子沟通和交流"
gen parsty25 = qn2
label var parsty25 "过去一个月与父母争吵次数"
gen parsty26 = qn3
label var parsty26 "过去一个月父母之间争吵次数"


* 父母其他观念，最后清理父母信息时单独列出来，16没有
gen paroth1 = wv101
label var paroth1 "经济繁荣要拉大收入差距"
gen paroth2 = wv102
label var paroth2 "公平竞争才有和谐人际"
gen paroth3 = wv103
label var paroth3 "财富反映个人成就"
gen paroth4 = wv104
label var paroth4 "努力工作能有回报"
gen paroth5 = wv105
label var paroth5 "聪明才干能得回报"
gen paroth6 = wv106
label var paroth6 "成大事难免腐败" //2010没有
gen paroth7 = wv107
label var paroth7 "有关系比有能力重要"
gen paroth8 = wv108
label var paroth8 "提高生活水平机会很大" //2010没有


*【因变量:个人发展】
* 学业表现
*  学习压力
gen studypr = qs502
label var studypr "学习压力（1没有-5压力大）"
* 认知能力
*  字词测试wordtest
*  数学测试mathtest
*  数列测试
gen sqtest = ns_w
label var sqtest "数列测试" //2010没有
*  即时记忆测试
gen imtest = iwr
label var imtest "即时记忆测试" //2010没有
*  延时记忆测试
gen dmtest = dwr
label var dmtest "延时记忆测试" //2010没有

* 非认知能力
gen happy = qn416
label var happy "我生活快乐" //2010 14没有
* gen happy2 = we301
* label var happy2 "这个孩子生性乐观" //16 18 20没有

/* 凯斯勒心理疾患量表 //12161820没有
gen kessler1 = qq601
label var kessler1 "凯斯勒量表-最近1个月，你感到情绪沮丧、郁闷、做什么事情都不能振奋的频率"
gen kessler2 = qq602
label var kessler2 "凯斯勒量表-最近1个月，你感到精神紧张的频率"
gen kessler3 = qq603
label var kessler3 "凯斯勒量表-最近1个月，你感到坐卧不安、难以保持平静的频率"
gen kessler4 = qq604
label var kessler4 "凯斯勒量表-最近1个月，你感到未来没有希望的频率"
gen kessler5 = qq605
label var kessler5 "凯斯勒量表-最近1个月，你做任何事情都感到困难的频率"
gen kessler6 = qq606
label var kessler6 "凯斯勒量表-最近1个月，你认为生活没有意义的频率"
*/
*【互联网模块】
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



* 手动添加所有变量
global indivVarList2020 "pid fidbaseline fid10 fid12 fid14 fid16 fid18 fid20 cid countyid pid_f pid_m eduy eduyim peduexp1_tutor peduexp2_tutor peduexp_tutor peduexp peduexp2 peduexp1 schdum schstage schdorm schpub  wz301 wz302 parcon1 parcon2 parcon3 parcon4 parcon5 parcon6 parcon7 parcon8 paroth1 paroth2 paroth3 paroth4 paroth5 paroth7 achcon1 achcon2 achcon3 achcon4 achcon5 achcon6 achcon7 parsty1 parsty2 parsty3 parsty4 parsty5 parsty6 parsty7 parsty8 parsty9 parsty10 parsty11 parsty12 parsty13 parsty14 parsty16 parsty17 parsty18 parsty19 parsty20 parsty21 parsty22 parsty23 parsty24 parsty25 parsty26 studypr sqtest imtest dmtest happy workdum marriage urban hukou han age indsurvey gender birthy wf501 wf502 emp_income InternetStudyMinute computerInternetMinute mobileInternetMinute InternetDummy InternetMinute InternetStudyDummy InternetStudy_LastWeek    InternetStudyDaily InternetEntertainmentDummy InternetEntertainment_LastWeek InternetEntertainmentDaily InternetShoppingDummy InternetShoppingDaily"


gen wave = 2020
label var wave "调查年份"
rename pid_a_f pid_f
label var pid_f "父亲在调查中的样本编码"
rename pid_a_m pid_m
label var pid_m "母亲在调查中的样本编码"
rename respc1pid resppid
label var resppid "代答家长个人id"
cap drop code
gen countyid = countyid20
gen cid = cid20
* merge m:1 countyid using "$cfpscountyid"  
* keep if _merge!=2
* drop _merge
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
* codebook cid countyid 
* gen indsurvey = indsurvey20
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
replace schdum = 1 if school == 5 //学期间假期中
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



*【家庭因素】
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

/* 父母养育观念量表，161822没有
gen parcon1 = we101
label var parcon1 "养育观念量表-离婚对孩子有害"
gen parcon2 = we102
label var parcon2 "养育观念量表-为孩子幸福也不应离婚"
gen parcon3 = we103
label var parcon3 "养育观念量表-应节衣缩食支付教育费"
gen parcon4 = we104
label var parcon4 "养育观念量表-成绩好坏父母有责"
gen parcon5 = we105
label var parcon5 "养育观念量表-经济自立父母有责"
gen parcon6 = we106
label var parcon6 "养育观念量表-孩子家庭和睦父母有责"
gen parcon7 = we107
label var parcon7 "养育观念量表-感情幸福父母有责"
gen parcon8 = we108
label var parcon8 "养育观念量表-遭遇车祸父母有责"

* 成就影响因素量表，161822没有
gen achcon1 = we401
label var achcon1 "成就影响因素量表-家庭社会地位对孩子未来成就有多重要"
gen achcon2 = we402
label var achcon2 "成就影响因素量表-家庭经济条件对孩子未来成就有多重要"
gen achcon3 = we403
label var achcon3 "成就影响因素量表-受教育程度对孩子未来成就有多重要"
gen achcon4 = we404
label var achcon4 "成就影响因素量表-天赋对孩子未来成就有多重要"
gen achcon5 = we405
label var achcon5 "成就影响因素量表-努力程度对孩子未来成就有多重要"
gen achcon6 = we406
label var achcon6 "成就影响因素量表-运气对孩子未来成就有多重要"
gen achcon7 = we407
label var achcon7 "成就影响因素量表-家庭社会关系对孩子未来成就有多重要"

* 父母教养方式，161822没有
gen parsty1 = qm201_b_2
label var parsty1 "当你做得不对时，家长会问清楚原因，并与你讨论该怎样做"
gen parsty2 = qm202_b_2
label var parsty2 "家长鼓励你努力去做事情"
gen parsty3 = qm203_b_2
label var parsty3 "家长在跟你说话的时候很和气"
gen parsty4 = qm204_b_2
label var parsty4 "家长鼓励你独立思考问题"
gen parsty5 = qm205_b_2
label var parsty5 "家长对你的要求很严格"
gen parsty6 = qm206_b_2
label var parsty6 "家长喜欢跟你交谈"
gen parsty7 = qm207_b_2
label var parsty7 "家长问你学校的情况"
gen parsty8 = qm208_b_2
label var parsty8 "家长检查你的作业"
gen parsty9 = qm209_b_2
label var parsty9 "家长辅导你的功课"
gen parsty10 = qm210_b_2
label var parsty10 "家长给你讲故事"
gen parsty11 = qm211_b_2
label var parsty11 "家长和你一起玩乐"
gen parsty12 = qm212_b_2
label var parsty12 "家长表扬你"
gen parsty13 = qm213_b_2
label var parsty13 "家长批评你"
gen parsty14 = qm214_b_2
label var parsty14 "父母参加家长会"
gen parsty15 = 
label var parsty15 "您会经常放弃看您自己喜欢的电视节目以免影响其学习吗"//20没有
gen parsty16 = wf602
label var parsty16 "您经常和这个孩子讨论学校里的事情"
gen parsty17 = wf603
label var parsty17 "您经常要求这个孩子完成家庭作业"
gen parsty18 = wf604
label var parsty18 "您经常检查这个孩子的家庭作业"
gen parsty19 = wf605
label var parsty19 "您经常阻止或终止这个孩子看电视"
gen parsty20 = wf606
label var parsty20 "您经常限制这个孩子所看电视节目的类型"
*/
gen parsty21 = wd2
label var parsty21 "您希望孩子受教育程度"
gen parsty22 = wd4
label var parsty22 "过去12个月为孩子教育存钱（元）"
gen parsty23 = wz301
label var parsty23 "家庭的环境（孩子的画报、图书或其他学习材料）表明父母关心孩子的教育"
gen parsty24 = wz302
label var parsty24 "父母主动与孩子沟通和交流"
gen parsty25 = qn2
label var parsty25 "过去一个月与父母争吵次数"
gen parsty26 = qn3
label var parsty26 "过去一个月父母之间争吵次数"


* 父母其他观念，最后清理父母信息时单独列出来，16没有
gen paroth1 = wv101
label var paroth1 "经济繁荣要拉大收入差距"
gen paroth2 = wv102
label var paroth2 "公平竞争才有和谐人际"
gen paroth3 = wv103
label var paroth3 "财富反映个人成就"
gen paroth4 = wv104
label var paroth4 "努力工作能有回报"
gen paroth5 = wv105
label var paroth5 "聪明才干能得回报"
gen paroth6 = wv106
label var paroth6 "成大事难免腐败" //2010没有
gen paroth7 = wv107
label var paroth7 "有关系比有能力重要"
gen paroth8 = wv108
label var paroth8 "提高生活水平机会很大" //2010没有


*【因变量:个人发展】
* 学业表现
*  学习压力
gen studypr = qs502
label var studypr "学习压力（1没有-5压力大）"
* 认知能力
*  字词测试wordtest
gen wordtest = wordtest22
replace wordtest = . if wordtest < 0
*  数学测试mathtest
gen mathtest = mathtest22
replace mathtest = . if mathtest < 0
/*  数列测试
gen sqtest = ns_w
label var sqtest "数列测试" //201022没有
*  即时记忆测试
gen imtest = iwr
label var imtest "即时记忆测试" //201022没有
*  延时记忆测试
gen dmtest = dwr
label var dmtest "延时记忆测试" //201022没有
*/
* 非认知能力
gen happy = qn416
label var happy "我生活快乐" //2010 14没有
gen happy2 = we301
label var happy2 "这个孩子生性乐观" //16 18 20没有

/* 凯斯勒心理疾患量表 //1216182022没有
gen kessler1 = qq601
label var kessler1 "凯斯勒量表-最近1个月，你感到情绪沮丧、郁闷、做什么事情都不能振奋的频率"
gen kessler2 = qq602
label var kessler2 "凯斯勒量表-最近1个月，你感到精神紧张的频率"
gen kessler3 = qq603
label var kessler3 "凯斯勒量表-最近1个月，你感到坐卧不安、难以保持平静的频率"
gen kessler4 = qq604
label var kessler4 "凯斯勒量表-最近1个月，你感到未来没有希望的频率"
gen kessler5 = qq605
label var kessler5 "凯斯勒量表-最近1个月，你做任何事情都感到困难的频率"
gen kessler6 = qq606
label var kessler6 "凯斯勒量表-最近1个月，你认为生活没有意义的频率"
*/

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



* 手动添加所有变量
global indivVarList2022 "pid fidbaseline fid10 fid12 fid14 fid16 fid18 fid20 cid countyid pid_f pid_m eduy eduyim peduexp1_tutor peduexp2_tutor peduexp_tutor peduexp peduexp2 peduexp1 schdum schstage schdorm schpub  wz301 wz302 parsty21 parsty22 parsty23 parsty24 parsty25 parsty26 paroth1 paroth2 paroth3 paroth4 paroth5 paroth6 paroth7 paroth8 studypr mathtest wf502 wf501 wordtest happy happy2 workdum marriage urban hukou han age gender birthy wf501 wf502 emp_income InternetStudyMinute computerInternetMinute mobileInternetMinute InternetDummy InternetMinute InternetStudyDummy InternetStudy_LastWeek    InternetStudyDaily InternetEntertainmentDummy InternetEntertainment_LastWeek InternetEntertainmentDaily InternetShoppingDummy InternetShoppingDaily"



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
* merge m:1 countyid using "$cfpscountyid"  
* keep if _merge!=2
* drop _merge
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

save "$temp/CFPS_IndividualVar_10121416182022.dta", replace
isid pid wave



//==================================================================//
/*                                父母特征清理                         */
//==================================================================//
local wave = "2010 2012 2014 2016 2018 2020 2022"
local parentsVarList16 = "pid age han hukou urban marriage workdum eduy eduyim"
local parentsVarList =  "pid age han hukou urban marriage workdum eduy eduyim paroth1 paroth2 paroth3 paroth4 paroth5 paroth7"

foreach w of local wave {
    if "`w'"=="2016" {
        di "`w'年数据导入"
        use "$temp/CFPS_IndividualVar_`w'.dta", clear
        keep `parentsVarList16'
        foreach var of local parentsVarList16 {
            rename `var'  `var'_f 
        }
        save "$temp/CFPS_FatherFeature_`w'.dta", replace
        dis "`w'年父亲特征保存成功 "
        isid pid_f

        use "$temp/CFPS_IndividualVar_`w'.dta", clear
        keep `parentsVarList16'
        foreach v of local parentsVarList16 {
            rename `v'  `v'_m
        }
        save "$temp/CFPS_MotherFeature_`w'.dta", replace
        dis "`w'年母亲特征保存成功 "
        isid pid_m
    }
    else {
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
}

local wave = "10 12 14 16 18 20 22"
foreach w of local wave {
        use "$temp/CFPS_IndividualVar_20`w'.dta", clear
        merge m:1 pid_f using "$temp/CFPS_FatherFeature_20`w'.dta", update replace 
        //m：1  m是指master数据集里面，pidf不是唯一识别的（一个爸两个孩）。但在merge上去的数据集里是唯一识别的)
        keep if _merge!=2
        drop _merge
        merge m:1 pid_m using "$temp/CFPS_MotherFeature_20`w'.dta", update replace
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


replace fid = fid10 if wave == 2010
replace fid = fid12 if wave == 2012
replace fid = fid14 if wave == 2014
replace fid = fid16 if wave == 2016
replace fid = fid18 if wave == 2018
replace fid = fid20 if wave == 2020
replace fid = fid22 if wave == 2022
save "$wkdata/CFPS_IndivLevel_10_2_22.dta", replace