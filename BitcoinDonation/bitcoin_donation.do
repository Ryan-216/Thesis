****************面板数据*********************
append using C:\Users\RHY\Desktop\研一下\bitcoin_donation\completedata\bitcoin_e_d_t_2022.dta

gen date = date(Created_at,"YMD")
format date %td

gen week_start = date(date,"YMD")
format week_start %td
sort week_start
gen week = _n
drop if week>105

order date, before(Created_at)
gen date = Created_at
format date %td

gen date = Date
format date %td

merge m:1 week using C:\Users\RHY\Desktop\论文修改\补充面板数据\tweet_counts.dta
drop if _merge != 3
drop _merge
merge m:1 date using C:\Users\RHY\Desktop\研一下\bitcoin_donation\bgtrend.dta
drop if _merge != 3
drop _merge
merge m:1 date using C:\Users\RHY\Desktop\研一下\bitcoin_donation\bcirculation.dta
drop if _merge != 3
drop _merge

gen Username = developer

merge m:1 Username using C:\Users\RHY\Desktop\研一下\bitcoin_donation\completedata\user_infos.dta
drop if _merge != 3
drop _merge

encode developer, generate(id)

xtset id date

twoway line FollowersCount id

gen lnPRE = ln(PullRequestEvent+1)
gen lnCCE = ln(CommitCommentEvent+1)
gen lnICE = ln(IssueCommentEvent+1)
gen lnIE = ln(IssuesEvent+1)
gen lnPRRCE = ln(PullRequestReviewCommentEvent+1)
gen lnPE = ln(PushEvent+1)
gen lnPRRE = ln(PullRequestReviewEvent+1)

gen lnClose = ln(Close)
gen lnVolume = ln(Volume)
gen return=ln(Close/Open)
gen lngtrend = ln(gtrend)
gen lncircu = ln(total)

** FollowersCount FollowingCount StarsCount RepositoriesCount
**94.44118
summarize FollowersCount if FollowersCount >= 0 
**69.02336
summarize FollowingCount if FollowingCount >= 0 
**101.987
summarize StarsCount if StarsCount >= 0 
**40.74334
summarize RepositoriesCount if RepositoriesCount >= 0 




replace FollowersCount = 94.44118 if FollowersCount < 0
replace FollowingCount = 69.02336 if FollowingCount < 0
replace StarsCount = 101.987 if StarsCount < 0
replace RepositoriesCount = 40.74334 if RepositoriesCount < 0

gen lnFingc = ln(FollowingCount+1)
gen lnFerc = ln(FollowersCount+1)
gen lnStarc = ln(StarsCount+1)
gen lnRepoc = ln(RepositoriesCount+1)

pwcorr_a lnPRE lnCCE lnICE lnIE lnPRRE

**lnRepoc 与 lnStarc lnPRRE 相关性过高
pwcorr_a lnPRE lnCCE lnICE lnIE lnPRRE lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc lndonation days
 
pwcorr_a lnFingc lnFerc lnStarc 
 

gen develop = CommitCommentEvent + PullRequestEvent
replace review = PullRequestReviewEvent
gen comment = IssueCommentEvent + IssuesEvent

gen lndevelop = ln(develop+1)
gen lnreview = ln(review+1)
gen lncomment = ln(comment+1)

pwcorr_a lndevelop lnreview lncomment lnClose lnVolume return lngtrend treatmem

reg lnPRE lnClose lnVolume return lngtrend id date,r
reg lnCCE lnClose lnVolume return lngtrend id date,r
reg lnICE lnClose lnVolume return lngtrend id date,r
reg lnIE lnClose lnVolume return lngtrend id date,r
reg lnPRRE lnClose lnVolume return lngtrend id date,r

reg lndevelop lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc id date,r
reg lnreview lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc id date,r
reg lncomment lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc id date,r
estat vif

xtreg lndevelop lnClose lnVolume return lngtrend date, fe vce(cluster id)
xtreg lnreview lnClose lnVolume return lngtrend date, fe vce(cluster id)

xtreg lncomment lnClose lnVolume return lngtrend date, fe
esti store fe
xtreg lncomment lnClose lnVolume return lngtrend date, re
esti store re
hausman fe re,constant sigmamore

*豪斯曼检验
quietly xtreg lncomment lnClose lnVolume return lngtrend date,re r 
xtoverid

gen basedate=date("2022-1-1","YMD")
format basedate %td
gen days = date - basedate
*初始
xtreg lndevelop lnClose lnVolume return lngtrend days, re r
xtreg lnreview lnClose lnVolume return lngtrend days, re r
xtreg lncomment lnClose lnVolume return lngtrend days, re r
*增加控制变量
xtreg lndevelop lnClose lnVolume return lngtrend treatmem lnFingc lnFerc lnStarc days, re r
xtreg lnreview lnClose lnVolume return lngtrend treatmem lnFingc lnFerc lnStarc days, re r
xtreg lncomment lnClose lnVolume return lngtrend treatmem lnFingc lnFerc lnStarc days, re r
*滞后一期
xtreg lndevelop l.lnClose l.lnVolume l.return lngtrend lnFingc lnFerc lnStarc days, re r
xtreg lnreview l.lnClose l.lnVolume l.return lngtrend lnFingc lnFerc lnStarc days, re r
xtreg lncomment l.lnClose l.lnVolume l.return lngtrend lnFingc lnFerc lnStarc days, re r


* reghdfe lncomment lnClose lnVolume return lngtrend, absorb(id, date)

gen year = year(date)
gen month = month(date)

reg lndevelop lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc id date if year == 2023,r
reg lnreview lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc id date,r
reg lncomment lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc id date if year == 2023 & id >= 703 & month >= 7,r


twoway line lndevelop date
twoway line lnreview date
twoway line lncomment date
twoway line lnClose date
twoway line lnVolume date
twoway line return date
twoway line lngtrend date
twoway line lnFingc date
twoway line lnFerc date
twoway line lnStarc date

xtunitroot ht lndevelop , demean
xtunitroot ht lnreview , demean
xtunitroot ht lncomment , demean
xtunitroot ht lnFingc , demean
xtunitroot ht lnFerc , demean
xtunitroot ht lnStarc , demean

xtunitroot ht lnClose , trend demean
xtunitroot ht lnVolume , trend demean
xtunitroot ht lngtrend , trend demean


xtunitroot ht return , noconstant demean

****捐赠对开发者活动的影响****

*19个bitcoin core member
*achow101
*aureleoules
*darosior
*dergoegge
*fanquake
*furszy
*glozow
*hebasto
*ismaelsadeeq
*jamesob
*jarolrod
*josibake
*kallewoof
*laanwj
*luke-jr
*naumenkogs
*sipsorcery
*Sjors
*sr-gi

*31个bitcoin member
*achow101
*adamjonas
*ariard
*aureleoules
*darosior
*dergoegge
*Empact
*fanquake
*furszy
*glozow
*hebasto
*instagibbs
*ismaelsadeeq
*jamesob
*jarolrod
*josibake
*kallewoof
*laanwj
*luke-jr
*maflcko
*morcos
*naumenkogs
*pablomartin4btc
*pinheadmz
*promag
*sdaftuar
*sipa
*sipsorcery
*Sjors
*sr-gi
*


gen treatcore = 0
replace treatcore = 1 if developer=="achow101"
replace treatcore = 1 if developer=="aureleoules"
replace treatcore = 1 if developer=="darosior"
replace treatcore = 1 if developer=="dergoegge"
replace treatcore = 1 if developer=="fanquake"
replace treatcore = 1 if developer=="furszy"
replace treatcore = 1 if developer=="glozow"
replace treatcore = 1 if developer=="hebasto"
replace treatcore = 1 if developer=="ismaelsadeeq"
replace treatcore = 1 if developer=="jamesob"
replace treatcore = 1 if developer=="josibake"
replace treatcore = 1 if developer=="kallewoof"
replace treatcore = 1 if developer=="laanwj"
replace treatcore = 1 if developer=="luke-jr"
replace treatcore = 1 if developer=="naumenkogs"
replace treatcore = 1 if developer=="sipsorcery"
replace treatcore = 1 if developer=="Sjors"
replace treatcore = 1 if developer=="sr-gi"
replace treatcore = 1 if developer=="jarolrod"

gen treatmem = 0
replace treatmem = 1 if developer=="achow101"
replace treatmem = 1 if developer=="adamjonas"
replace treatmem = 1 if developer=="ariard"
replace treatmem = 1 if developer=="aureleoules"
replace treatmem = 1 if developer=="darosior"
replace treatmem = 1 if developer=="dergoegge"
replace treatmem = 1 if developer=="Empact"
replace treatmem = 1 if developer=="fanquake"
replace treatmem = 1 if developer=="furszy"
replace treatmem = 1 if developer=="glozow"
replace treatmem = 1 if developer=="hebasto"
replace treatmem = 1 if developer=="instagibbs"
replace treatmem = 1 if developer=="ismaelsadeeq"
replace treatmem = 1 if developer=="jamesob"
replace treatmem = 1 if developer=="jarolrod"
replace treatmem = 1 if developer=="josibake"
replace treatmem = 1 if developer=="kallewoof"
replace treatmem = 1 if developer=="laanwj"
replace treatmem = 1 if developer=="luke-jr"
replace treatmem = 1 if developer=="maflcko"
replace treatmem = 1 if developer=="morcos"
replace treatmem = 1 if developer=="naumenkogs"
replace treatmem = 1 if developer=="pablomartin4btc"
replace treatmem = 1 if developer=="pinheadmz"
replace treatmem = 1 if developer=="promag"
replace treatmem = 1 if developer=="sdaftuar"
replace treatmem = 1 if developer=="sipa"
replace treatmem = 1 if developer=="sipsorcery"
replace treatmem = 1 if developer=="Sjors"
replace treatmem = 1 if developer=="sr-gi"

*被资助者
*brunoerg
*dergoegge
*Vincenzo Palazzo
*0xB10C · bit/coin
gen treatspon = 0
replace treatspon = 1 if developer=="brunoerg"
replace treatspon = 1 if developer=="dergoegge"
replace treatspon = 1 if developer=="Vincenzo Palazzo"
replace treatspon = 1 if developer=="0xB10C"

xtreg lncomment anno lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days if treatspon==1, re r

drop ATm
drop anno

*公告一年期
gen anno_1y = 0
replace anno_1y = 1 if days >= 93 & days <= 458

*公告无限期
gen anno = 0
replace anno = 1 if days >= 93

*捐赠无限期
gen dona = 0
replace dona = 1 if days >= 530

gen ATm_1y = anno_1y * treatmem
gen ATm = anno * treatmem
gen DTm = dona * treatmem

pwcorr_a anno_1y days
pwcorr_a anno days
pwcorr_a dona days

xtset id date
*公告一年期
xtreg lndevelop treatmem anno_1y ATm_1y lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re r
xtreg lnreview treatmem anno_1y ATm_1y lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re r
xtreg lncomment treatmem anno_1y ATm_1y lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re r
*公告无限期
reg lndevelop treatmem anno ATm lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, r

xtreg lndevelop treatmem anno ATm lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re r
xtreg lnreview treatmem anno ATm lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re r
xtreg lncomment treatmem anno ATm lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re r
*异质性
xtreg lndevelop anno lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days if treatmem==0, re r
xtreg lnreview anno lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days if treatmem==0, re r
xtreg lncomment anno lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days if treatmem==0, re r

*捐赠无限期
gen DTc = dona*treatcore
reg lndevelop treatcore dona DTc lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, r

xtreg lndevelop treatmem dona DTm lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re r
xtreg lnreview treatmem dona DTm lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re r
xtreg lncomment treatmem dona DTm lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re r

xtreg lndevelop treatcore dona DTm lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re r
xtreg lnreview treatcore dona DTm lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re r
xtreg lncomment treatcore dona DTm lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re r

*方差膨胀因子
reg lncomment treatmem dona DTm lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days,r
estat vif

**完整捐赠数据
/*
721	150000
654	597333.3333
530	5000000
522	180000
508	50000
506	500000
503	1000000
482	150000
500	100000
487	100000
411	597333.3333
156	50000
140	25000
116	1000000
26	300000
5	350000
3	5000	
*/

gen donation = 0
replace donation = 150000 if days == 721
replace donation = 597333.3333 if days == 654
replace donation = 5000000 if days == 530
replace donation = 180000 if days == 522
replace donation = 50000 if days == 508
replace donation = 500000 if days == 506
replace donation = 1000000 if days == 503
replace donation = 150000 if days == 482
replace donation = 100000 if days == 500
replace donation = 100000 if days == 487
replace donation = 597333.3333 if days == 411
replace donation = 50000 if days == 156
replace donation = 25000 if days == 140
replace donation = 1000000 if days == 116
replace donation = 300000 if days == 26
replace donation = 350000 if days == 5
replace donation = 5000 if days == 3

drop donation
drop lndonation

merge m:1 days using C:\Users\RHY\Desktop\研一下\bitcoin_donation\completedata\donation.dta
drop if _merge != 3
drop _merge

gen lndonation = ln(donation+1)

pwcorr_a lndevelop lnreview lncomment lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc lndonation days
 

xtreg lndevelop lndonation lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re r
xtreg lnreview lndonation lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days , re r
xtreg lncomment lndonation lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re r

xtreg lndevelop lndonation lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days if treatcore==1, re r




















****固定效应模型 完善变量设置****
replace donation = 0 if donation == .
replace if_dona = 0 if if_dona == .
replace grant = 0 if grant == .

merge m:1 days using C:\Users\RHY\Desktop\研一下\bitcoin_donation\completedata\donation.dta
drop if _merge != 3
drop _merge

gen lndonation = ln(donation+1)
xtset id days

gen dona5M = 0
replace dona5M = 1 if days>=530

reg lndevelop dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, robust
xtreg lndevelop dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lnreview dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lncomment dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust

**一次dona+一次grant
**dona5M显著
gen dona5M_grant4 = dona5M*grant4
*固定效应模型
xtreg lndevelop dona5M grant4 dona5M_grant4 treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lnreview dona5M grant4 dona5M_grant4 treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lncomment dona5M grant4 dona5M_grant4 treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
*随机效应模型
xtreg lndevelop dona5M grant4 dona5M_grant4 treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re robust
xtreg lnreview dona5M grant4 dona5M_grant4 treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re robust
xtreg lncomment dona5M grant4 dona5M_grant4 treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re robust


reg lndevelop grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, robust


**双重差分
*有过pr的为实验组
gen treatp = 0
replace treatp = 1 if developer =="sdaftuar"
replace treatp = 1 if developer =="brunoerg"
replace treatp = 1 if developer =="hhhogannwo"
replace treatp = 1 if developer =="shaavan"
replace treatp = 1 if developer =="sipa"
replace treatp = 1 if developer =="fjahr"
replace treatp = 1 if developer =="fanquake"
replace treatp = 1 if developer =="jnewbery"
replace treatp = 1 if developer =="theStack"
replace treatp = 1 if developer =="prayank23"
replace treatp = 1 if developer =="LarryRuane"
replace treatp = 1 if developer =="gregwebs"
replace treatp = 1 if developer =="S3RK"
replace treatp = 1 if developer =="klementtan"
replace treatp = 1 if developer =="dougEfresh"
replace treatp = 1 if developer =="kallewoof"
replace treatp = 1 if developer =="theuni"
replace treatp = 1 if developer =="pinheadmz"
replace treatp = 1 if developer =="dunxen"
replace treatp = 1 if developer =="t-bast"
replace treatp = 1 if developer =="kristapsk"
replace treatp = 1 if developer =="sh15h4nk"
replace treatp = 1 if developer =="kcalvinalvin"
replace treatp = 1 if developer =="Duongxuantuan2345"
replace treatp = 1 if developer =="stratospher"
replace treatp = 1 if developer =="sinetek"
replace treatp = 1 if developer =="john-moffett"
replace treatp = 1 if developer =="jarolrod"
replace treatp = 1 if developer =="bvbfan"
replace treatp = 1 if developer =="vincenzopalazzo"
replace treatp = 1 if developer =="Empact"
replace treatp = 1 if developer =="PastaPastaPasta"
replace treatp = 1 if developer =="promag"
replace treatp = 1 if developer =="Rspigler"
replace treatp = 1 if developer =="willcl-ark"
replace treatp = 1 if developer =="russeree"
replace treatp = 1 if developer =="satsie"
replace treatp = 1 if developer =="ishaanam"
replace treatp = 1 if developer =="gruve-p"
replace treatp = 1 if developer =="dhruv"
replace treatp = 1 if developer =="petertodd"
replace treatp = 1 if developer =="martinus"
replace treatp = 1 if developer =="yancyribbens"
replace treatp = 1 if developer =="mruddy"
replace treatp = 1 if developer =="roconnor-blockstream"
replace treatp = 1 if developer =="bubelov"
replace treatp = 1 if developer =="kouloumos"
replace treatp = 1 if developer =="sstone"
replace treatp = 1 if developer =="andrewtoth"
replace treatp = 1 if developer =="amadeuszpawlik"
replace treatp = 1 if developer =="prusnak"
replace treatp = 1 if developer =="real-or-random"
replace treatp = 1 if developer =="ZenulAbidin"
replace treatp = 1 if developer =="kiminuo"
replace treatp = 1 if developer =="JeremyRand"
replace treatp = 1 if developer =="sdulfari"
replace treatp = 1 if developer =="rex4539"
replace treatp = 1 if developer =="llazzaro"
replace treatp = 1 if developer =="yusufsahinhamza"
replace treatp = 1 if developer =="RF5"
replace treatp = 1 if developer =="suhailsaqan"
replace treatp = 1 if developer =="phyBrackets"
replace treatp = 1 if developer =="michaelfolkson"
replace treatp = 1 if developer =="miles170"
replace treatp = 1 if developer =="anibilthare"
replace treatp = 1 if developer =="kdmukai"
replace treatp = 1 if developer =="KevinMusgrave"
replace treatp = 1 if developer =="chinggg"
replace treatp = 1 if developer =="benthecarman"
replace treatp = 1 if developer =="rnapoles"
replace treatp = 1 if developer =="natanleung"
replace treatp = 1 if developer =="jacobpfickes"
replace treatp = 1 if developer =="0xB10C"
replace treatp = 1 if developer =="brokenprogrammer"
replace treatp = 1 if developer =="davidgumberg"
replace treatp = 1 if developer =="AaronDewes"
replace treatp = 1 if developer =="sogoagain"
replace treatp = 1 if developer =="Crypt-iQ"
replace treatp = 1 if developer =="nancy728"
replace treatp = 1 if developer =="uvhw"
replace treatp = 1 if developer =="robigan"
replace treatp = 1 if developer =="junderw"
replace treatp = 1 if developer =="amovfx"
replace treatp = 1 if developer =="bitcoinhodler"
replace treatp = 1 if developer =="pg156"
replace treatp = 1 if developer =="ayush933"
replace treatp = 1 if developer =="virtu"
replace treatp = 1 if developer =="david-bakin"
replace treatp = 1 if developer =="RandyMcMillan"
replace treatp = 1 if developer =="Eunoia1729"
replace treatp = 1 if developer =="danielabrozzoni"
replace treatp = 1 if developer =="Md-Shamim-Ahmmed"
replace treatp = 1 if developer =="scgbckbone"
replace treatp = 1 if developer =="freelancerstudio"
replace treatp = 1 if developer =="tuanggolt"
replace treatp = 1 if developer =="whiteh0rse"
replace treatp = 1 if developer =="Chres-SC"
replace treatp = 1 if developer =="MiranDaniel"
replace treatp = 1 if developer =="bhaskarvilles"
replace treatp = 1 if developer =="TheCharlatan"
replace treatp = 1 if developer =="jb55"
replace treatp = 1 if developer =="Kvaciral"
replace treatp = 1 if developer =="ViralTaco"
replace treatp = 1 if developer =="jbrr"
replace treatp = 1 if developer =="da2ce7"
replace treatp = 1 if developer =="rodentrabies"
replace treatp = 1 if developer =="murrayn"
replace treatp = 1 if developer =="jessebarton"
replace treatp = 1 if developer =="SatoshiNakamotoBitcoin"
replace treatp = 1 if developer =="SergioDemianLerner"
replace treatp = 1 if developer =="DIGITALMININGOP"
replace treatp = 1 if developer =="johnoseni1"
replace treatp = 1 if developer =="karnetmp"
replace treatp = 1 if developer =="suriyaa"
replace treatp = 1 if developer =="TheQuantumPhysicist"
replace treatp = 1 if developer =="AlexeiKharchev"
replace treatp = 1 if developer =="dscotese"
replace treatp = 1 if developer =="Thomodachi"
replace treatp = 1 if developer =="thonkle"
replace treatp = 1 if developer =="dontbyte"
replace treatp = 1 if developer =="MarnixCroes"
replace treatp = 1 if developer =="akankshakashyap"
replace treatp = 1 if developer =="dimapv"
replace treatp = 1 if developer =="BTCsource2"
replace treatp = 1 if developer =="jodhqesh"
replace treatp = 1 if developer =="hdutra"
replace treatp = 1 if developer =="samuelkim7"
replace treatp = 1 if developer =="tulio150"
replace treatp = 1 if developer =="herculepoirot42"
replace treatp = 1 if developer =="Smlep"
replace treatp = 1 if developer =="nob788"
replace treatp = 1 if developer =="JohhnyBTC"
replace treatp = 1 if developer =="hobhsy"
replace treatp = 1 if developer =="ux3257"
replace treatp = 1 if developer =="brydinh"
replace treatp = 1 if developer =="seejee"
replace treatp = 1 if developer =="vadpert"
replace treatp = 1 if developer =="muxator"
replace treatp = 1 if developer =="atErik"
replace treatp = 1 if developer =="acktsap"
replace treatp = 1 if developer =="ebraminio"
replace treatp = 1 if developer =="TomLisankie"
replace treatp = 1 if developer =="amanciojsilvajr"
replace treatp = 1 if developer =="dynamo-foundation"
replace treatp = 1 if developer =="Adlai-Holler"
replace treatp = 1 if developer =="telberrak"
replace treatp = 1 if developer =="inclusive-coding-bot"
replace treatp = 1 if developer =="Bushstar"
replace treatp = 1 if developer =="SecurityBTC"
replace treatp = 1 if developer =="erenalyoruk"
replace treatp = 1 if developer =="rag-hav"
replace treatp = 1 if developer =="mmikeww"
replace treatp = 1 if developer =="lazvegas13"
replace treatp = 1 if developer =="elichai"
replace treatp = 1 if developer =="KuroGuo"
replace treatp = 1 if developer =="rsogllc"
replace treatp = 1 if developer =="jdjkelly"
replace treatp = 1 if developer =="dev7ba"
replace treatp = 1 if developer =="trizko"
replace treatp = 1 if developer =="git-sgmoore"
replace treatp = 1 if developer =="tehelsper"
replace treatp = 1 if developer =="nymkappa"
replace treatp = 1 if developer =="prakash1512"
replace treatp = 1 if developer =="adityagupta26"
replace treatp = 1 if developer =="JoaoAJMatos"
replace treatp = 1 if developer =="amogyisabogy1"
replace treatp = 1 if developer =="Zphyero"
replace treatp = 1 if developer =="rojarsmith"
replace treatp = 1 if developer =="whitslack"
replace treatp = 1 if developer =="thecodeMD"
replace treatp = 1 if developer =="Mr-Leshiy"
replace treatp = 1 if developer =="TheTpyicalCoder"
replace treatp = 1 if developer =="SatoshiBTCXBT"
replace treatp = 1 if developer =="Thateazy4"
replace treatp = 1 if developer =="vertiond"
replace treatp = 1 if developer =="iwoskerlonne"
replace treatp = 1 if developer =="BlackcoinDev"
replace treatp = 1 if developer =="Breadcorn"
replace treatp = 1 if developer =="WikiExchange"
replace treatp = 1 if developer =="uJhin"
replace treatp = 1 if developer =="Magazineiwwj"
replace treatp = 1 if developer =="mxaddict"
replace treatp = 1 if developer =="q2000official"
replace treatp = 1 if developer =="PublicResourceLicense"
replace treatp = 1 if developer =="mutatrum"
replace treatp = 1 if developer =="atuta"
replace treatp = 1 if developer =="ZeuZZueZ"
replace treatp = 1 if developer =="satoshinakamoto007"
replace treatp = 1 if developer =="omahs"
replace treatp = 1 if developer =="maxraustin"
replace treatp = 1 if developer =="SkiingIsFun123"
replace treatp = 1 if developer =="melissamforbs"
replace treatp = 1 if developer =="co-fraternaldragon"
replace treatp = 1 if developer =="Willtech"
replace treatp = 1 if developer =="aguycalled"
replace treatp = 1 if developer =="wangalan0118"
replace treatp = 1 if developer =="mehdis34"
replace treatp = 1 if developer =="ucallmerk"
replace treatp = 1 if developer =="Kuplynx"
replace treatp = 1 if developer =="ZhiqingQu"
replace treatp = 1 if developer =="SsNiPeR1"
replace treatp = 1 if developer =="tfomyuk"
replace treatp = 1 if developer =="anshu-khare-design"
replace treatp = 1 if developer =="div72"
replace treatp = 1 if developer =="JhonZuluaga007"
replace treatp = 1 if developer =="David9941"
replace treatp = 1 if developer =="BradleyC"
replace treatp = 1 if developer =="GithubOxSwapps"
replace treatp = 1 if developer =="danyalsarwar"
replace treatp = 1 if developer =="KolbyML"
replace treatp = 1 if developer =="SeenHit"
replace treatp = 1 if developer =="torimoore4"
replace treatp = 1 if developer =="kathy129"
replace treatp = 1 if developer =="zbtzbtzbt"
replace treatp = 1 if developer =="tristanhcole"
replace treatp = 1 if developer =="Andreasjuette"
replace treatp = 1 if developer =="R-Y-M-R"
replace treatp = 1 if developer =="RottenCoin"
replace treatp = 1 if developer =="hunglun"
replace treatp = 1 if developer =="mohamedshafiqjaffer"
replace treatp = 1 if developer =="Randy808"
replace treatp = 1 if developer =="ryihan"
replace treatp = 1 if developer =="SmashedFrenzy16"
replace treatp = 1 if developer =="xternet"
replace treatp = 1 if developer =="antoinedesbois"
replace treatp = 1 if developer =="BlueeeMoon"
replace treatp = 1 if developer =="Arka18syahputra"
replace treatp = 1 if developer =="coffescript"
replace treatp = 1 if developer =="dimitris-t"
replace treatp = 1 if developer =="Amaranese"
replace treatp = 1 if developer =="YAKSHIT-22"
replace treatp = 1 if developer =="vidrobysh"
replace treatp = 1 if developer =="BhinbahadurUK"
replace treatp = 1 if developer =="Ivanoffinvest"
replace treatp = 1 if developer =="Vinodwickrama"
replace treatp = 1 if developer =="anipaul2"
replace treatp = 1 if developer =="Aw761678"
replace treatp = 1 if developer =="CodeMaster7000"
replace treatp = 1 if developer =="bl0cknumber"
replace treatp = 1 if developer =="Sjors"
replace treatp = 1 if developer =="Xekyo"
replace treatp = 1 if developer =="w0xlt"
replace treatp = 1 if developer =="ariard"
replace treatp = 1 if developer =="furszy"
replace treatp = 1 if developer =="glozow"
replace treatp = 1 if developer =="laanwj"
replace treatp = 1 if developer =="vasild"
replace treatp = 1 if developer =="ajtowns"
replace treatp = 1 if developer =="hebasto"
replace treatp = 1 if developer =="jamesob"
replace treatp = 1 if developer =="luke-jr"
replace treatp = 1 if developer =="achow101"
replace treatp = 1 if developer =="darosior"
replace treatp = 1 if developer =="dongcarl"
replace treatp = 1 if developer =="jonatack"
replace treatp = 1 if developer =="josibake"
replace treatp = 1 if developer =="dergoegge"
replace treatp = 1 if developer =="mzumsande"
replace treatp = 1 if developer =="ryanofsky"
replace treatp = 1 if developer =="MarcoFalke"
replace treatp = 1 if developer =="instagibbs"
replace treatp = 1 if developer =="naumenkogs"
replace treatp = 1 if developer =="stickies-v"
replace treatp = 1 if developer =="JeremyRubin"
replace treatp = 1 if developer =="aureleoules"
replace treatp = 1 if developer =="1440000bytes"

reg lndevelop treatp dona5M treatp_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, robust

reg lnreview treatp dona5M treatp_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, robust

reg lncomment treatp dona5M treatp_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, robust

gen treatp_dona5M = treatp * dona5M
xtreg lnreview treatp dona5M treatp_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lnreview treatp dona5M treatp_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lncomment treatp dona5M treatp_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust

gen treatp_grant4 = treatp * grant4
xtreg lndevelop treatp grant4 treatp_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lnreview treatp grant4 treatp_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lncomment treatp grant4 treatp_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust

***被资助者为对照***不显著
drop treatgranted
gen treatgranted = 0
replace treatgranted = 1 if developer =="glozow"
replace treatgranted = 1 if developer =="jesseposner"
replace treatgranted = 1 if developer =="afilini"
replace treatgranted = 1 if developer =="hebasto"
replace treatgranted = 1 if developer =="LarryRuane"
replace treatgranted = 1 if developer =="theStack"
replace treatgranted = 1 if developer =="mzumsande"
replace treatgranted = 1 if developer =="0xB10C"
replace treatgranted = 1 if developer =="vincenzopalazzo"
replace treatgranted = 1 if developer =="dergoegge"
replace treatgranted = 1 if developer =="brunoerg"
replace treatgranted = 1 if developer =="fanquake"
replace treatgranted = 1 if developer =="adiabat"
replace treatgranted = 1 if developer =="stickies-v"
replace treatgranted = 1 if developer =="fjahr"

gen treatgranted = 1
replace treatgranted = 0 if developer =="glozow"
replace treatgranted = 0 if developer =="jesseposner"
replace treatgranted = 0 if developer =="afilini"
replace treatgranted = 0 if developer =="hebasto"
replace treatgranted = 0 if developer =="LarryRuane"
replace treatgranted = 0 if developer =="theStack"
replace treatgranted = 0 if developer =="mzumsande"
replace treatgranted = 0 if developer =="0xB10C"
replace treatgranted = 0 if developer =="vincenzopalazzo"
replace treatgranted = 0 if developer =="dergoegge"
replace treatgranted = 0 if developer =="brunoerg"
replace treatgranted = 0 if developer =="fanquake"
replace treatgranted = 0 if developer =="adiabat"
replace treatgranted = 0 if developer =="stickies-v"
replace treatgranted = 0 if developer =="fjahr"

drop treatgranted_dona5M

gen treatgranted_dona5M = treatgranted * dona5M

reg lndevelop treatgranted dona5M treatgranted_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, robust

reg lnreview treatgranted dona5M treatgranted_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, robust

reg lndevelop treatgranted dona5M treatgranted_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, robust

xtreg lndevelop treatgranted dona5M treatgranted_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lnreview treatgranted dona5M treatgranted_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lncomment treatgranted dona5M treatgranted_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust















***多次dona+grant_total 不好
xtset id days

drop grant_total

gen grant_total= 7
replace grant_total = 6 if date >= date("2022-3-31","YMD")
replace grant_total = 10 if date >= date("2022-4-4","YMD")
replace grant_total = 11 if date >= date("2022-5-13","YMD")
replace grant_total = 12 if date >= date("2022-6-30","YMD")
replace grant_total = 11 if date >= date("2022-7-15","YMD")
replace grant_total = 12 if date >= date("2022-7-29","YMD")
replace grant_total = 11 if date >= date("2022-10-22","YMD")
replace grant_total = 10 if date >= date("2023-3-31","YMD")
replace grant_total = 7 if date >= date("2023-4-4","YMD")
replace grant_total = 8 if date >= date("2023-5-4","YMD")
replace grant_total = 7 if date >= date("2023-6-30","YMD")

twoway line grant_total days

**lndonation
*固定效应
gen lngrant_total = ln(grant_total)
gen lndonation_lngrant_total =lndonation * lngrant_total 

xtreg lndevelop lndonation lngrant_total lndonation_lngrant_total treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lnreview lndonation lngrant_total lndonation_lngrant_total treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lncomment lndonation lngrant_total lndonation_lngrant_total treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust

*随机效应
xtreg lndevelop lndonation grant_total  treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re robust
xtreg lnreview lndonation grant_total  treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re robust
xtreg lncomment lndonation grant_total  treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re robust

***一次dona+grant连续
gen dona5M_grant_total = dona5M * grant_total

xtreg lndevelop dona5M grant_total dona5M_grant_total  treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lnreview dona5M  grant_total  dona5M_grant_total treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lncomment dona5M grant_total  dona5M_grant_total treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust





***多次dona+一次grant 效果不好
**lndonation
gen lndonation_grant4 = lndonation*grant4
*固定效应
xtreg lndevelop lndonation grant4 lndonation_grant4 treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lnreview lndonation grant4 lndonation_grant4 treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lncomment lndonation grant4 lndonation_grant4 treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
*随机效应
xtreg lndevelop lndonation grant4 lndonation_grant4 treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re robust
xtreg lnreview lndonation grant4 lndonation_grant4 treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re robust
xtreg lncomment lndonation grant4 lndonation_grant4 treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re robust
**if_dona
gen if_dona_grant4 = if_dona * grant4
*固定效应
xtreg F2.lndevelop i.if_dona grant4 if_dona_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg F2.lnreview i.if_dona grant4 if_dona_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg F2.lncomment i.if_dona grant4 if_dona_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
*随机效应
xtreg lndevelop i.if_dona grant4 if_dona_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re robust
xtreg lnreview i.if_dona grant4 if_dona_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re robust
xtreg lncomment i.if_dona grant4 if_dona_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, re robust

***单变量
**lndonation
xtreg F2.lndevelop lndonation lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg F2.lnreview lndonation lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg F2.lncomment lndonation lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
**if_dona 显著性不好
xtreg F2.lndevelop i.if_dona lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg F2.lnreview i.if_dona lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg F2.lncomment i.if_dona lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
**grant 
xtreg F7.lndevelop grant lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg F7.lnreview grant lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg F7.lncomment grant lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
**grant4
gen grant4 = 0
replace grant4 = 1 if days>=93

xtreg lndevelop grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lnreview grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust
xtreg lncomment grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc days, fe robust





















***************周数据******************
gen date = Created_at
format date %td

logout, save(test1) word replace: tabstat CommitCommentEvent PullRequestEvent PullRequestReviewCommentEvent develop review if_dona donation grant4 return Volume gtrend if granted==0, s (N mean sd min max) f (%12.3f) c (s)

summarize CommitCommentEvent PullRequestEvent PullRequestReviewCommentEvent Idonation grant4 Close Volume gtrend 

gen basedate=date("2022-1-1","YMD")
format basedate %td
gen days = date - basedate

merge m:1 days using C:\Users\RHY\Desktop\研一下\bitcoin_donation\completedata\donation-grant.dta
drop if _merge != 3
drop _merge


merge m:1 week_start using C:\Users\RHY\Desktop\研一下\bitcoin_donation\completedata\bgtrend-w.dta
drop if _merge != 3
drop _merge

merge m:1 week_start using C:\Users\RHY\Desktop\研一下\bitcoin_donation\completedata\btc-usd-w.dta
drop if _merge != 3
drop _merge

gen Username=developer
merge m:1 Username using C:\Users\RHY\Desktop\研一下\bitcoin_donation\completedata\user_infos.dta
drop if _merge != 3
drop _merge

** FollowersCount FollowingCount StarsCount RepositoriesCount
**94.44118
summarize FollowersCount if FollowersCount >= 0 
**69.02336
summarize FollowingCount if FollowingCount >= 0 
**101.987
summarize StarsCount if StarsCount >= 0 
**40.74334
summarize RepositoriesCount if RepositoriesCount >= 0 

replace FollowersCount = 94.44118 if FollowersCount < 0
replace FollowingCount = 69.02336 if FollowingCount < 0
replace StarsCount = 101.987 if StarsCount < 0
replace RepositoriesCount = 40.74334 if RepositoriesCount < 0


gen lnPRE = ln(PullRequestEvent+1)
gen lnCCE = ln(CommitCommentEvent+1)
gen lnICE = ln(IssueCommentEvent+1)
gen lnIE = ln(IssuesEvent+1)
gen lnPRRCE = ln(PullRequestReviewCommentEvent+1)
gen lnPE = ln(PushEvent+1)
gen lnPRRE = ln(PullRequestReviewEvent+1)

gen lnClose = ln(Close)
gen lnVolume = ln(Volume)
gen return=ln(Close/Open)
gen lngtrend = ln(gtrend)

gen lnFingc = ln(FollowingCount+1)
gen lnFerc = ln(FollowersCount+1)
gen lnStarc = ln(StarsCount+1)
gen lnRepoc = ln(RepositoriesCount+1)

pwcorr_a  lnCCE lnPRE lnPRRE lnIE 

gen treatcore = 0
replace treatcore = 1 if developer=="achow101"
replace treatcore = 1 if developer=="aureleoules"
replace treatcore = 1 if developer=="darosior"
replace treatcore = 1 if developer=="dergoegge"
replace treatcore = 1 if developer=="fanquake"
replace treatcore = 1 if developer=="furszy"
replace treatcore = 1 if developer=="glozow"
replace treatcore = 1 if developer=="hebasto"
replace treatcore = 1 if developer=="ismaelsadeeq"
replace treatcore = 1 if developer=="jamesob"
replace treatcore = 1 if developer=="josibake"
replace treatcore = 1 if developer=="kallewoof"
replace treatcore = 1 if developer=="laanwj"
replace treatcore = 1 if developer=="luke-jr"
replace treatcore = 1 if developer=="naumenkogs"
replace treatcore = 1 if developer=="sipsorcery"
replace treatcore = 1 if developer=="Sjors"
replace treatcore = 1 if developer=="sr-gi"
replace treatcore = 1 if developer=="jarolrod"

gen treatmem = 0
replace treatmem = 1 if developer=="achow101"
replace treatmem = 1 if developer=="adamjonas"
replace treatmem = 1 if developer=="ariard"
replace treatmem = 1 if developer=="aureleoules"
replace treatmem = 1 if developer=="darosior"
replace treatmem = 1 if developer=="dergoegge"
replace treatmem = 1 if developer=="Empact"
replace treatmem = 1 if developer=="fanquake"
replace treatmem = 1 if developer=="furszy"
replace treatmem = 1 if developer=="glozow"
replace treatmem = 1 if developer=="hebasto"
replace treatmem = 1 if developer=="instagibbs"
replace treatmem = 1 if developer=="ismaelsadeeq"
replace treatmem = 1 if developer=="jamesob"
replace treatmem = 1 if developer=="jarolrod"
replace treatmem = 1 if developer=="josibake"
replace treatmem = 1 if developer=="kallewoof"
replace treatmem = 1 if developer=="laanwj"
replace treatmem = 1 if developer=="luke-jr"
replace treatmem = 1 if developer=="maflcko"
replace treatmem = 1 if developer=="morcos"
replace treatmem = 1 if developer=="naumenkogs"
replace treatmem = 1 if developer=="pablomartin4btc"
replace treatmem = 1 if developer=="pinheadmz"
replace treatmem = 1 if developer=="promag"
replace treatmem = 1 if developer=="sdaftuar"
replace treatmem = 1 if developer=="sipa"
replace treatmem = 1 if developer=="sipsorcery"
replace treatmem = 1 if developer=="Sjors"
replace treatmem = 1 if developer=="sr-gi"

pwcorr_a lnPRE lnCCE lnIE lnPRRE lnICE lnPE lnPRRCE
pwcorr_a lnPRE lnCCE lnIE lnPRRE 

gen develop = CommitCommentEvent + PullRequestEvent
gen review = PullRequestReviewEvent
gen comment = IssuesEvent
gen CIPP =  CommitCommentEvent + PullRequestEvent + PullRequestReviewEvent + IssuesEvent
gen lnCIPP = ln(CIPP+1)

gen lndevelop = ln(develop+1)
gen lnreview = ln(review+1)
gen lncomment = ln(comment+1)

gen lndonation = ln(donation+1)
drop lndonation
gen lndonation = ln(donation/1000+1)

donation grant4

pwcorr_a lndevelop lnreview lncomment
 
pwcorr_a lndevelop lnreview lncomment lnClose lnVolume return lngtrend lnFingc  lnFerc lnStarc lnRepoc lndonation

replace if_dona = 1 if if_dona >= 1

encode developer, generate(id) 

drop date
gen date = week_start
format date %td

drop week
bysort id:gen week=_n

gen grant4 = 0
replace grant4 = 1 if week >= 15
xtset  id week

***************************grant4****ICIS核心**************************
**lndonation lnreview 期望失验理论

bys id (week): gen createsum = sum(CreateEvent)
bys id (week): gen createsum = sum(DeleteEvent)
bys id (week): gen createsum = sum(CreateEvent)
DeleteEvent


gen granted = 0
replace granted = 1 if developer =="0xB10C"
replace granted = 1 if developer =="vincenzopalazzo"
replace granted = 1 if developer =="dergoegge"
replace granted = 1 if developer =="brunoerg"
replace granted = 1 if developer =="fanquake"
replace granted = 1 if developer =="adiabat"
replace granted = 1 if developer =="stickies-v"
replace granted = 1 if developer =="fjahr"

** FollowersCount FollowingCount StarsCount RepositoriesCount
**94.44118
summarize FollowersCount if FollowersCount >= 0 
replace FollowersCount = 1 if FollowersCount == 94.441177
**69.02336
summarize FollowingCount if FollowingCount >= 0 
**101.987
summarize StarsCount if StarsCount >= 0 
**40.74334
summarize RepositoriesCount if RepositoriesCount >= 0 

gen lndonation_grant4 = lndonation*grant4

pwcorr_a PullRequestEvent CommitCommentEvent IssueCommentEvent IssuesEvent PullRequestReviewCommentEvent PushEvent PullRequestReviewEvent

gen PUSHPULL = PullRequestEvent+PullRequestReviewCommentEvent+PushEvent +PullRequestReviewEvent
gen ISSUE = IssuesEvent
gen COMMRNT =  CommitCommentEvent + IssueCommentEvent
pwcorr_a PUSHPULL  ISSUE COMMRNT
rename COMMRNT COMMENT
gen lnPUSHPULL = ln(PUSHPULL+1)
gen lnISSUE = ln(ISSUE+1)
gen lnCOMMENT = ln(COMMENT+1)

gen CodeContribution = PushEvent+CreateEvent+DeleteEvent+CommitCommentEvent+PullRequestEvent
gen CodeReview = PullRequestReviewEvent+PullRequestReviewCommentEvent
gen IssueDiscussion = IssuesEvent+IssueCommentEvent
gen AllEvent = CodeContribution+CodeReview+IssueDiscussion


drop sumWithoutissue
egen sumCodeCon = sum(CodeContribution),by(id)
egen sumCodeRev = sum(CodeReview),by(id)
gen sumWithoutissue = sumCodeCon+sumCodeRev


gen lnCodeCon = ln(CodeContribution+1)
gen lnCodeRev = ln(CodeReview+1)
gen lnIssueDis = ln(IssueDiscussion+1)
gen lnAll = ln(AllEvent+1)

summarize CodeContribution CodeReview IssueDiscussion
pwcorr_a lnCodeCon lnCodeRev lnIssueDis

***
drop if granted==1
summarize AllEvent CodeContribution CodeReview IssueDiscussion donation if_dona grant4 Close Volume return gtrend 




***工具变量2sls

drop _merge
merge 1:1 week using E:\ICIS2024BitcoinDonation\bitcoin_donationstata\completedata\bgtrend-w.dta
merge 1:1 week using E:\ICIS2024BitcoinDonation\bitcoin_donationstata\completedata\btc-usd-w-105.dta
merge 1:1 week using E:\ICIS2024BitcoinDonation\bitcoin_donationstata\completedata\lndonation-w.dta

merge 1:1 developer week_start using E:\BitcoinDonaiton\ICIS2024BitcoinDonation\bitcoin_donationstata\completedata\CDFW-w.dta

replace createevent = 0 if _merge==1
replace deleteevent = 0 if _merge==1
replace forkevent = 0 if _merge==1
replace watchevent = 0 if _merge==1

gen CDF = createevent + deleteevent + forkevent
gen lnCDF = ln(CDF+1)
gen lnWatch = ln(watchevent+1)


gen date_stata = date(date, "YMD")
format date_stata %td
ipolate bbgtrend date_stata, gen(bbgtrend_smoothed)
drop date_stata

drop week_start
gen date1 = clock(date,"YMDhms")
format date1 %tc

gen week_count =
rename date1 week_start
tsset week_start
gen week=_n

drop _merge
xtset id week
merge m:1 week using E:\ICIS2024BitcoinDonation\bitcoin_donationstata\completedata\sbbgtrend.dta
drop sbbgtrend
drop lnsbbgtrend

gen lnsbbgtrend = ln(sbbgtrend)
gen sbbgtrend_grant4 = sbbgtrend * grant4
gen lnsbbgtrend_grant4 = lnsbbgtrend * grant4

tsset week
tsset day
dfuller donation

dfuller lndonation 
dfuller lnsbbgtrend
dfuller lnClose
dfuller lnVolume
dfuller return
dfuller lngtrend
dfuller 
xtunitroot llc lndonation, 
trend noconstant demean


ssc install xtivreg2
ssc install estout, replace
ssc install esttab
tab week,gen(week)

gen lnbbgtrend = ln(bbgtrend+1)

pwcorr_a  lnsbbgtrend lnClose lnVolume return lngtrend

tsset week
reg l.lndonation lnsbbgtrend lnVolume return week , robust

grant4 lnClose lnVolume return lngtrend week if granted==0,robust
xtreg lndonation l.lndonation l.lnAll lnbbgtrend grant4 lnClose lnVolume return lngtrend week if granted==0, fe robust
est store first1
//final
xtreg lndonation l.lnAll grant4 lnsbbgtrend lnVolume return week if granted==0,fe robust
est store first1

xtivreg2  lnAll l.lnAll (lndonation lndonation_grant4 = lnsbbgtrend lnsbbgtrend_grant4) grant4 lnVolume return week1-week105 if granted==0,ffirst fe robust savefirst savefprefix(st11)
est store second1

xtreg lndonation l.lnCodeCon grant4 lnsbbgtrend lnVolume return week if granted==0,fe robust
est store first2

xtivreg2  lnCodeCon l.lnCodeCon (lndonation lndonation_grant4 = lnsbbgtrend lnsbbgtrend_grant4) grant4 lnVolume return week1-week105 if granted==0,ffirst fe robust savefirst savefprefix(st11)
est store second2

xtreg lndonation l.lnCodeRev grant4 lnsbbgtrend lnVolume return week if granted==0,fe robust
est store first3

xtivreg2  lnCodeRev l.lnCodeRev (lndonation lndonation_grant4 = lnsbbgtrend lnsbbgtrend_grant4) grant4 lnVolume return week1-week105 if granted==0,ffirst fe robust savefirst savefprefix(st11)
est store second3

xtreg lndonation l.lnISSUE grant4 lnsbbgtrend lnVolume return week if granted==0,fe robust
est store first4

xtivreg2  lnISSUE l.lnISSUE (lndonation lndonation_grant4 = lnsbbgtrend lnsbbgtrend_grant4) grant4 lnVolume return week1-week105 if granted==0,ffirst fe robust savefirst savefprefix(st11)
est store second4

esttab first2 second2  using codcon.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers

esttab first3 second3 using codrev.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers

esttab first4 second4 using issue.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers


*1
reg  lndonation l.lndonation lnsbbgtrend return, r
lnClose lnVolume return lngtrend week if granted==0  , r



xtreg lndonation l.lnAll lnsbbgtrend lnClose lnVolume return lngtrend week if granted==0  , fe robust

*2
outreg2 using bitcoindonation21.doc, tstat bdec(3) tdec(2) keep(lndonation l.lndonation lnsbbgtrend )replace

xtreg lnAll l.lnAll  lnsbbgtrend grant4 lnsbbgtrend_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lnsbbgtrend grant4 lnsbbgtrend_grant4 lnClose lnVolume return lngtrend)replace

xtreg lnCodeCon L.lnCodeCon lnsbbgtrend grant4 lnsbbgtrend_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lnsbbgtrend grant4 lnsbbgtrend_grant4 lnClose lnVolume return lngtrend)append

xtreg lnCodeRev L.lnCodeRev lnsbbgtrend grant4 lnsbbgtrend_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lnsbbgtrend grant4 lnsbbgtrend_grant4 lnClose lnVolume return lngtrend)append

xtreg lnISSUE L.lnISSUE lnsbbgtrend grant4 lnsbbgtrend_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lnsbbgtrend grant4 lnsbbgtrend_grant4 lnClose lnVolume return lngtrend)append


***robust
xtreg lnAll L.lnAll if_dona grant4 if_dona_grant4 lnVolume return lnFingc lnFerc lnStarc week if granted==0  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE if_dona grant4 if_dona_grant4 lnVolume return )replace

xtreg lnCodeCon L.lnCodeCon if_dona grant4 if_dona_grant4  lnVolume return  lnFingc lnFerc lnStarc week if granted==0  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE if_dona grant4 if_dona_grant4  lnVolume return )append

xtreg lnCodeRev L.lnCodeRev if_dona grant4 if_dona_grant4  lnVolume return  lnFingc lnFerc lnStarc week if granted==0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE if_dona grant4 if_dona_grant4 lnVolume return )append

xtreg lnISSUE L.lnISSUE if_dona grant4 if_dona_grant4  lnVolume return  lnFingc lnFerc lnStarc week if granted==0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE if_dona grant4 if_dona_grant4  lnVolume return )append

xtset id week
***根据活动含义划分DV
xtreg lnAll L.lnAll lndonation grant4 lndonation_grant4 lnVolume return lnCDF lnWatch week if granted==0  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4  lnVolume return lnCDF lnWatch )replace

**活动类型异质性
xtreg lnCodeCon L.lnCodeCon lndonation grant4 lndonation_grant4  lnVolume return  lnCDF lnWatch week if granted==0  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4  lnVolume return lnCDF lnWatch)append

xtreg lnCodeRev L.lnCodeRev lndonation grant4 lndonation_grant4  lnVolume return   lnCDF lnWatch week if granted==0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4 lnVolume return lnCDF lnWatch)append

xtreg lnISSUE L.lnISSUE lndonation grant4 lndonation_grant4  lnVolume return  lnCDF lnWatch week if granted==0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4  lnVolume return lnCDF lnWatch)append

**开发者身份异质性
*week 105
xtset id week
drop PRREsum
egen sumPRRE = sum(PullRequestReviewEvent),by(id)
egen sumCCE = sum(CommitCommentEvent),by(id)

*FollowersCount mean+2*sd = 1059.16918
summarize FollowersCount

*sumCCE mean+2*sd = 1.3835413
summarize sumCCE

*StarsCount 102+299*2 = 700
*RepositoriesCount 41+131*2 = 303
summarize StarsCount RepositoriesCount

summarize IssueDiscussion
*根据
xtreg lnAll lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)replace

xtreg lnCodeCon lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if PRREsum==0  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append

xtreg lnCodeRev lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if PRREsum==0  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append

xtreg lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if IssueDiscussion>4 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append

**根据sumAE
summarize sumAE
egen sumAE = sum(AllEvent),by(id)

xtreg lnAll lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week  if granted==0 & sumAE>6 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)replace

xtreg lnCodeCon lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & sumAE<=6, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append

xtreg lnCodeRev lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & sumAE<=6, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append

xtreg lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & sumAE<=6, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append
*t-1
xtreg lnAll L.lnAll lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & sumAE<=6 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)replace

xtreg lnCodeCon L.lnCodeCon lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & sumAE<=6 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append

xtreg lnCodeRev L.lnCodeRev lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & sumAE<=6, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append

xtreg lnISSUE L.lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & sumAE<=6, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append
*根据sumPRRE
xtreg lnAll lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week  if granted==0 & sumCodeRev>0 & sumWithoutissue > 0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4)replace

xtreg lnCodeCon lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & sumCodeRev>0  & sumWithoutissue > 0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4)append

xtreg lnCodeRev lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & sumCodeRev>0  & sumWithoutissue > 0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4)append

xtreg lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if sumPRRE==0 & sumWithoutissue > 0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4)append

summarize sumCodeCon
*根据sumCCE
xtreg lnAll lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week  if granted==0 & sumCodeCon<=1 &  sumWithoutissue > 0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)replace

xtreg lnCodeCon lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & sumCodeCon<=1 & sumWithoutissue > 0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append

xtreg lnCodeRev lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & sumCodeCon<=1 & sumWithoutissue > 0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append

xtreg lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if sumCCE>1.3815413 & sumWithoutissue > 0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append

summarize FollowersCount
*根据FollowerCount  94.44118     482.364 
xtreg lnAll lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week  if granted==0 & FollowersCount<=36, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4)replace

xtreg lnCodeCon lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & FollowersCount<=36 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4)append

xtreg lnCodeRev lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & FollowersCount>176 &  sumWithoutissue > 0 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4)append

xtreg lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & FollowersCount<=36 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4)append

*StarsCount 102+299*2 = 700
xtreg lnAll l.lnAll  lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & StarsCount>=2  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)replace

xtreg lnCodeCon l.lnCodeCon  lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & StarsCount>=2  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append

xtreg lnCodeRev l.lnCodeRev  lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & StarsCount>=2  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append

xtreg lnISSUE l.lnISSUE  lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & StarsCount>=2  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append
*RepositoriesCount 41+131*2 = 303
*根据RepositoriesCount 
xtreg lnAll lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week  if granted==0 & RepositoriesCount<8, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)replace

xtreg lnAll lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week  if granted==0 & RepositoriesCount>=8 & RepositoriesCount<40 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append
xtreg lnAll lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week  if granted==0 & RepositoriesCount>=40 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append
*
xtreg lnCodeCon lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & RepositoriesCount>=3, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4  lnClose lnVolume return lngtrend)append

xtreg lnCodeRev lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & RepositoriesCount>=3, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4  lnClose lnVolume return lngtrend)append

xtreg lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if  granted==0 & RepositoriesCount>=3 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4  lnClose lnVolume return lngtrend)append
*t-1
xtreg lnAll L.lnAll lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & RepositoriesCount<=19 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)replace

xtreg lnCodeCon L.lnCodeCon lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & RepositoriesCount<=19 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append

xtreg lnCodeRev L.lnCodeRev lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0& RepositoriesCount<=19, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append

xtreg lnISSUE L.lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted==0 & RepositoriesCount<=19, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend)append

pwcorr_a RepositoriesCount sumAE



*原始三种活动
xtreg lndevelop lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week  , fe robust

outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4)replace

xtreg lnreview lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week   , fe robust

outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4)append

xtreg lncomment lndonation grant4 lndonation_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted == 0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(lndonation grant4 lndonation_grant4)append




**if_dona lnreview 期望失验理论 稳健性检验
gen if_dona_grant4 = if_dona * grant4

xtreg lnAll if_dona grant4 if_dona_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted == 0, fe robust
outreg2 using bitcoindonation1.doc, tstat bdec(3) tdec(2) keep(if_dona grant4 if_dona_grant4)replace

xtreg lnCodeCon if_dona grant4 if_dona_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted == 0, fe robust
outreg2 using bitcoindonation1.doc, tstat bdec(3) tdec(2) keep(if_dona grant4 if_dona_grant4)append

xtreg lnCodeRev if_dona grant4 if_dona_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted == 0, fe robust
outreg2 using bitcoindonation1.doc, tstat bdec(3) tdec(2) keep(if_dona grant4 if_dona_grant4)append

xtreg lnIssueDis if_dona grant4 if_dona_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week if granted == 0, fe robust
outreg2 using bitcoindonation1.doc, tstat bdec(3) tdec(2) keep(if_dona grant4 if_dona_grant4)append


**dona5M 
gen dona5M_grant4 = dona5M*grant4

xtreg lndevelop dona5M grant4 dona5M_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust
xtreg lnreview dona5M grant4 dona5M_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust
xtreg lncomment dona5M grant4 dona5M_grant4 lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust

**if_dona grant_total
gen if_dona_grant_total = if_dona*grant_total

xtreg lndevelop if_dona grant_total if_dona_grant_total lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust
xtreg lnreview if_dona grant_total if_dona_grant_total lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust
xtreg lncomment if_dona grant_total if_dona_grant_total lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust



gen grant_total= 7
replace grant_total = 6 if week >= 14
replace grant_total = 10 if week >= 15
replace grant_total = 11 if week >= 20
replace grant_total = 12 if week >= 27
replace grant_total = 11 if week >= 29
replace grant_total = 12 if week >= 31
replace grant_total = 11 if week >= 43
replace grant_total = 10 if week >= 66
replace grant_total = 7 if week >= 67
replace grant_total = 8 if week >= 71
replace grant_total = 7 if week >= 79


**lndonation grant_total
gen lndonation_grant_total = lndonation*grant_total

xtreg lndevelop lndonation grant_total treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust
xtreg lnreview lndonation grant_total  treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust
xtreg lncomment lndonation grant_total treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust

**dona5M grant_total
gen dona5M = 0
replace dona5M = 1 if week >= 77
gen dona5M_grant_total = dona5M*grant_total

xtreg lndevelop dona5M grant_total dona5M_grant_total  treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust
xtreg lnreview dona5M grant_total dona5M_grant_total  treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust
xtreg lncomment dona5M grant_total dona5M_grant_total treatmem lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust


***被资助者为对照***
drop treatgranted
gen treatgranted = 0
replace treatgranted = 1 if developer =="glozow"
replace treatgranted = 1 if developer =="jesseposner"
replace treatgranted = 1 if developer =="afilini"
replace treatgranted = 1 if developer =="hebasto"
replace treatgranted = 1 if developer =="LarryRuane"
replace treatgranted = 1 if developer =="theStack"
replace treatgranted = 1 if developer =="mzumsande"
replace treatgranted = 1 if developer =="0xB10C"
replace treatgranted = 1 if developer =="vincenzopalazzo"
replace treatgranted = 1 if developer =="dergoegge"
replace treatgranted = 1 if developer =="brunoerg"
replace treatgranted = 1 if developer =="fanquake"
replace treatgranted = 1 if developer =="adiabat"
replace treatgranted = 1 if developer =="stickies-v"
replace treatgranted = 1 if developer =="fjahr"

gen treatgranted = 1
replace treatgranted = 0 if developer =="glozow"
replace treatgranted = 0 if developer =="jesseposner"
replace treatgranted = 0 if developer =="afilini"
replace treatgranted = 0 if developer =="hebasto"
replace treatgranted = 0 if developer =="LarryRuane"
replace treatgranted = 0 if developer =="theStack"
replace treatgranted = 0 if developer =="mzumsande"
replace treatgranted = 0 if developer =="0xB10C"
replace treatgranted = 0 if developer =="vincenzopalazzo"
replace treatgranted = 0 if developer =="dergoegge"
replace treatgranted = 0 if developer =="brunoerg"
replace treatgranted = 0 if developer =="fanquake"
replace treatgranted = 0 if developer =="adiabat"
replace treatgranted = 0 if developer =="stickies-v"
replace treatgranted = 0 if developer =="fjahr"

drop treatgranted
drop treatgranted_dona5M

gen treatgranted_dona5M = treatgranted * dona5M

xtreg lndevelop treatgranted dona5M treatgranted_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust
xtreg lnreview treatgranted dona5M treatgranted_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust
xtreg lncomment treatgranted dona5M treatgranted_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust

gen treatp_dona5M = treatp * dona5M

xtreg lndevelop treatp dona5M treatp_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust
xtreg lnreview treatp dona5M treatp_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust
xtreg lncomment treatp dona5M treatp_dona5M lnClose lnVolume return lngtrend lnFingc lnFerc lnStarc week, fe robust

