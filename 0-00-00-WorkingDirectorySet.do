/*0. prepare work*/
clear
set more off
capture log close

*定义一些全局宏，便于后续调用源文件

* global root="C:\Users\Yangzhihua\Nutstore\1\FriendsSpace\一平\信息化建设、家庭教育与城乡儿童发展"
global root = "/Users/liusongyue/Library/CloudStorage/坚果云-201921030023@mail.bnu.edu.cn/1_StudySpace/一平/信息化建设、家庭教育与城乡儿童发展"

global rawdata="$root/RawData"
global wkdata="$root/WorkingData"
global temp="$root/TempData"

global codes = "$root/Codes-EduGovProc-StudentOutcome"
global logs="$root/LogFiles"
global tables = "$root/Tables"
global figures = "$root/Figures"
global results = "$root/Results"


  

*【【【CFPS家庭微观调查数据，后续整理
global CFPS = "$rawdata/CFPS/RawData"
global cfps2010adult = "$CFPS/cfps2010adult_202008.dta"
global cfps2010child = "$CFPS/cfps2010child_201906.dta"
global cfps2010comm = "$CFPS/cfps2010comm_201906.dta"
global cfps2010famconf = "$CFPS/cfps2010famconf_202008.dta"
global cfps2010famecon = "$CFPS/cfps2010famecon_202008.dta"
global cfps2012adult = "$CFPS/cfps2012adult_201906.dta"
global cfps2012child = "$CFPS/cfps2012child_201906.dta"
global cfps2012comm = "$CFPS/cfps2012comm_201906.dta"
global cfps2012famconf = "$CFPS/cfps2012famconf_092015.dta"
global cfps2012famecon = "$CFPS/cfps2012famecon_201906.dta"
global cfps2012crossyearid = "$CFPS/cfps2012crossyearid_032015.dta"
global cfps2014adult = "$CFPS/cfps2014adult_201906.dta"
global cfps2014child = "$CFPS/cfps2014child_201906.dta"
global cfps2014comm = "$CFPS/cfps2014comm_201906.dta"
global cfps2014famconf = "$CFPS/cfps2014famconf_170630.dta"
global cfps2014famecon = "$CFPS/cfps2014famecon_201906.dta"
global cfps2014crossyearid = "$CFPS/cfps2014crossyearid_170630.dta"
global cfps2016adult = "$CFPS/cfps2016adult_201906.dta"
global cfps2016child = "$CFPS/cfps2016child_201906.dta"
global cfps2016famconf = "$CFPS/cfps2016famconf_201804.dta"
global cfps2016famecon = "$CFPS/cfps2016famecon_201807.dta"
global cfps2016crossyearid = "$CFPS/cfps2016crossyearid_201807.dta"
global cfps2018person = "$CFPS/cfps2018person_202012.dta"
global cfps2018childproxy = "$CFPS/cfps2018childproxy_202012.dta"
global cfps2018famconf = "$CFPS/cfps2018famconf_202008.dta"
global cfps2018famecon = "$CFPS/cfps2018famecon_202101.dta"
global cfps2018crossyearid = "$CFPS/cfps2018crossyearid_202104.dta"
global cfps2020person = "$CFPS/cfps2020person_202306.dta"
global cfps2020childproxy = "$CFPS/cfps2020childproxy_202306.dta"
global cfps2020famconf = "$CFPS/cfps2020famconf_202306.dta"
global cfps2020famecon = "$CFPS/cfps2020famecon_202306.dta"
global cfps2020crossyearid = "$CFPS/cfps2020crossyearid_202312.dta"
global cfps2022person "$CFPS/cfps2022person_202410.dta"
global cfps2022childproxy "$CFPS/cfps2022childproxy_202410.dta"
global cfps2022famconf "$CFPS/cfps2022famconf_202410.dta"
global cfps2022famecon "$CFPS/cfps2022famecon_202410.dta"
global cfpscountyid = "$CFPS/CFPSCountyCode.dta"