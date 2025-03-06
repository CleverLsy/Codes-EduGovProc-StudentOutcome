use "$cfpscountyid", clear
* 北京市
replace countyname = "东城区" if countyname == "崇文区"
replace code = 110101 if code == 110103  // 崇文区 -> 东城区

* 上海市
replace countyname = "黄浦区" if countyname == "卢湾区"
replace code = 310101 if code == 310103  // 卢湾区 -> 黄浦区

replace countyname = "浦东新区" if countyname == "南汇区"
replace code = 310115 if code == 310119  // 南汇区 -> 浦东新区

* 云南省
replace countyname = "蒙自市" if countyname == "蒙自县"
replace code = 532503 if code == 532522  // 蒙自县 -> 蒙自市

* 江苏省
replace countyname = "江都区" if countyname == "江都市"
replace code = 321012 if code == 321088  // 江都市 -> 江都区

* 浙江省
replace countyname = "玉环市" if countyname == "玉环县"
replace code = 331087 if code == 331021  // 玉环县 -> 玉环市

* 山西省
replace countyname = "上党区" if countyname == "长治县"
replace code = 140404 if code == 140421  // 长治县 -> 上党区

* 山东省
replace countyname = "章丘区" if countyname == "章丘市"
replace code = 370113 if code == 370181  // 章丘市 -> 章丘区

replace countyname = "蓬莱区" if countyname == "蓬莱市"
replace code = 370611 if code == 370684  // 蓬莱市 -> 蓬莱区

replace countyname = "莱芜区" if countyname == "莱城区"
replace code = 370116 if code == 371202  // 莱城区 -> 莱芜区

replace countyname = "陵城区" if countyname == "陵县"
replace code = 371403 if code == 371421  // 陵县 -> 陵城区

replace countyname = "淮阳区" if countyname == "淮阳县"
replace code = 411627 if code == 411626  // 淮阳县 -> 淮阳区

* 河南省
replace countyname = "淮阳区" if countyname == "淮阳县"
replace code = 411627 if code == 411626  // 淮阳县 -> 淮阳区

* 广西壮族自治区
replace countyname = "长洲区" if countyname == "蝶山区"
replace code = 450405 if code == 450404  // 蝶山区 -> 长洲区
duplicates drop code, force
isid code
gen citycode =  floor(code/100) * 100
save "$wkdata/cfpscountyid.dta", replace