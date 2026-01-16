**优化grant4
*date		num		week	github_id
*22/4/4 	4		15		0xB10C vincenzopalazzo dergoegge brunoerg
*22/5/13	1		20		fanquake
*22/6/30	1		27		adiabat
*22/7/29	1		31		stickies-v
*23/5/4		1		71		fjahr

gen grant_all = 0
replace grant_all = 4 if week == 15 
replace grant_all = 1 if week == 20 
replace grant_all = 1 if week == 27 
replace grant_all = 1 if week == 31 
replace grant_all = 1 if week == 71

drop grant_sum
gen grant_sum = 0
replace grant_sum = 4 if week >= 15 
replace grant_sum = 5 if week >= 20 
replace grant_sum = 6 if week >= 27 
replace grant_sum = 7 if week >= 31 
replace grant_sum = 8 if week >= 71

gen lndonation_grant_all = lndonation * grant_all
gen lndonation_grant_sum = lndonation * grant_sum
xtset id week_new
replace grant_sum = grant_sum / 10
drop lndonation
gen lndonation = ln(donation/1000+1)
replace lndonation_grant_sum = lndonation * grant_sum

gen lnFork = ln(forkevent + 1)
*基准回归
xtreg lnAll L.lnAll lndonation grant_sum lndonation_grant_sum lnVolume return lnFork lnWatch week2-week105 if granted==0  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant_sum lndonation_grant_sum  lnVolume return lnFork lnWatch )replace

xtreg lnCodeCon L.lnCodeCon lndonation grant_sum lndonation_grant_sum  lnVolume return  lnFork lnWatch if granted==0  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant_sum lndonation_grant_sum  lnVolume return lnFork lnWatch)append

xtreg lnCodeRev L.lnCodeRev lndonation grant_sum lndonation_grant_sum  lnVolume return   lnFork lnWatch if granted==0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant_sum lndonation_grant_sum lnVolume return lnFork lnWatch)append

xtreg lnISSUE L.lnISSUE lndonation grant_sum lndonation_grant_sum  lnVolume return  lnFork lnWatch if granted==0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE lndonation grant_sum lndonation_grant_sum  lnVolume return lnFork lnWatch)append

***异质性分析
**所有活动总和
*50 50
xtreg lnAll L.lnAll lndonation grant_sum lndonation_grant_sum lnVolume return lnFork lnWatch week if granted==0 & sumAE>1 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll lndonation grant_sum lndonation_grant_sum lnVolume return lnFork lnWatch)replace
xtreg lnAll L.lnAll lndonation grant_sum lndonation_grant_sum lnVolume return lnFork lnWatch week if granted==0 & sumAE==1 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll lndonation grant_sum lndonation_grant_sum lnVolume return lnFork lnWatch)append
*iv
xtivreg2  lnAll	 l.lnAll (lndonation lndonation_grant_sum = lnsbbgtrend lnsbbgtrend_grant_sum) grant_sum lnVolume return lnFork lnWatch if granted==0 & sumAE>1,ffirst fe robust savefirst savefprefix(st11)
est store s1
xtivreg2  lnAll	 l.lnAll (lndonation lndonation_grant_sum = lnsbbgtrend lnsbbgtrend_grant_sum) grant_sum lnVolume return lnFork lnWatch if granted==0 & sumAE==1,ffirst fe robust savefirst savefprefix(st11)
est store s2
esttab s1 s2  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers

**仓库数量
*50 50
xtreg lnAll L.lnAll lndonation grant_sum lndonation_grant_sum lnVolume return lnFork lnWatch week if granted==0 & RepositoriesCount>=19 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll lndonation grant_sum lndonation_grant_sum lnVolume return lnFork lnWatch)replace
xtreg lnAll L.lnAll lndonation grant_sum lndonation_grant_sum lnVolume return lnFork lnWatch week if granted==0 & RepositoriesCount<19 , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll lndonation grant_sum lndonation_grant_sum lnVolume return lnFork lnWatch)append
*iv
xtivreg2  lnAll	 l.lnAll (lndonation lndonation_grant_sum = lnsbbgtrend lnsbbgtrend_grant_sum) grant_sum lnVolume return lnFork lnWatch if granted==0 & RepositoriesCount>=19,ffirst fe robust savefirst savefprefix(st11)
est store s11
xtivreg2  lnAll	 l.lnAll (lndonation lndonation_grant_sum = lnsbbgtrend lnsbbgtrend_grant_sum) grant_sum lnVolume return lnFork lnWatch if granted==0 & RepositoriesCount<19,ffirst fe robust savefirst savefprefix(st11)
est store s22
esttab s11 s22  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers



***工具变量
**google trend
replace lnsbbgtrend_grant_sum = lnsbbgtrend * grant_sum
*all
xtreg lndonation l.lnAll grant_sum lnsbbgtrend lnVolume return lnFork lnWatch year if granted==0 ,fe robust
est store first1
xtivreg2  lnAll	 l.lnAll (lndonation lndonation_grant_sum = lnsbbgtrend lnsbbgtrend_grant_sum) grant_sum lnVolume return lnFork lnWatch season_dum2-season_dum9 if granted==0 ,ffirst fe robust savefirst savefprefix(st11)
est store second1
esttab first1 second1  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers
*con
xtreg lndonation l.lnCodeCon grant_sum lnsbbgtrend lnVolume return lnFork lnWatch if granted==0,fe robust
est store first2
xtivreg2  lnCodeCon l.lnCodeCon (lndonation lndonation_grant_sum = lnsbbgtrend lnsbbgtrend_grant_sum) grant_sum lnVolume return lnFork lnWatch if granted==0,ffirst fe robust savefirst savefprefix(st11)
est store second2
esttab first2 second2  using codecon.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers
*rev
xtreg lndonation l.lnCodeRev grant_sum lnsbbgtrend lnVolume return lnFork lnWatch if granted==0,fe robust
est store first3
xtivreg2  lnCodeRev	 l.lnCodeRev (lndonation lndonation_grant_sum = lnsbbgtrend lnsbbgtrend_grant_sum) grant_sum lnVolume return lnFork lnWatch if granted==0,ffirst fe robust savefirst savefprefix(st11)
est store second3
esttab first3 second3  using codrev.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers
*iss
xtreg lndonation l.lnISSUE grant_sum lnsbbgtrend lnVolume return lnFork lnWatch if granted==0,fe robust
est store first4
xtivreg2  lnISSUE l.lnISSUE (lndonation lndonation_grant_sum = lnsbbgtrend lnsbbgtrend_grant_sum) grant_sum lnVolume return lnFork lnWatch if granted==0,ffirst fe robust savefirst savefprefix(st11)
est store second4
esttab first4 second4  using issue.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers

**twitter
gen lnbrink_tweet_grant_sum = lnbrink_tweet * grant_sum

xtreg lndonation l.lnAll grant_sum lnbrink_tweet lnVolume return lnCDF lnWatch if granted==0,fe robust
est store first1
xtivreg2  lnAll l.lnAll (lndonation lndonation_grant4 = lnbrink_tweet lnbrink_tweet_grant_sum) grant4 lnVolume return lnCDF lnWatch if granted==0,ffirst fe robust savefirst savefprefix(st11)
est store second1
esttab first1 second1  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers


***event study
*gen grant_all = 0
*replace grant_all = 4 if week == 15 
*replace grant_all = 1 if week == 20 
*replace grant_all = 1 if week == 27 
*replace grant_all = 1 if week == 31 
*replace grant_all = 1 if week == 71
drop grant_sum
gen grant_sum = 0
replace grant_sum = 4 if week >= 15 
replace grant_sum = 5 if week >= 20 
replace grant_sum = 6 if week >= 27 
replace grant_sum = 7 if week >= 31 
replace grant_sum = 8 if week >= 71

drop grant_event
gen grant_event2 = 0
replace grant_event2 = 1 if week == 15 
replace grant_event2 = 1 if week == 20 
replace grant_event2 = 1 if week == 27 
replace grant_event2 = 1 if week == 31 
replace grant_event2 = 1 if week == 71 

replace grant_event2 = 1 if week == 16 
replace grant_event2 = 1 if week == 21 
replace grant_event2 = 1 if week == 28 
replace grant_event2 = 1 if week == 32 
replace grant_event2 = 1 if week == 72 

gen donate_event = 0
replace donate_event = 1 if donation != 0


drop donate_grant_event
gen donate_grant_event2 = donate_event*grant_event2

**基准回归
xtreg lnAll L.lnAll donate_event grant_event donate_grant_event lnVolume return lnFork lnWatch week2-week105 if granted==0  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE donate_event grant_event donate_grant_event  lnVolume return lnFork lnWatch )replace

xtreg lnCodeCon L.lnCodeCon donate_event grant_event donate_grant_event  lnVolume return  lnFork lnWatch if granted==0  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE donate_event grant_event donate_grant_event  lnVolume return lnFork lnWatch)append

xtreg lnCodeRev L.lnCodeRev donate_event grant_event donate_grant_event  lnVolume return   lnFork lnWatch if granted==0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE donate_event grant_event donate_grant_event lnVolume return lnFork lnWatch)append

xtreg lnISSUE L.lnISSUE donate_event grant_event donate_grant_event  lnVolume return  lnFork lnWatch if granted==0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE donate_event grant_event donate_grant_event  lnVolume return lnFork lnWatch)append
**IV
drop lnsbbgtrend_grant_event
gen lnsbbgtrend_grant_event = lnsbbgtrend * grant_event
*all
xtreg donate_event L.lnAll lnsbbgtrend grant_event  lnVolume return lnFork lnWatch week2-week105 if granted==0  , fe robust
est store first1
xtivreg2  lnAll	 l.lnAll (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch week2-week105 if granted==0,ffirst fe robust savefirst savefprefix(st11)
est store second1
esttab first1 second1  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers
*con
xtreg donate_event l.lnCodeCon lnsbbgtrend grant_event  lnVolume return lnFork lnWatch  if granted==0  , fe robust
est store first1
xtivreg2  lnCodeCon	 l.lnCodeCon (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0,ffirst fe robust savefirst savefprefix(st11)
est store second1
esttab first1 second1  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers
*rev
xtreg donate_event l.lnCodeRev lnsbbgtrend grant_event  lnVolume return lnFork lnWatch  if granted==0  , fe robust
est store first1
xtivreg2  lnCodeRev	 l.lnCodeRev (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0,ffirst fe robust savefirst savefprefix(st11)
est store second1
esttab first1 second1  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers
*rev
xtreg donate_event l.lnISSUE lnsbbgtrend grant_event  lnVolume return lnFork lnWatch  if granted==0  , fe robust
est store first1
xtivreg2  lnISSUE l.lnISSUE (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0,ffirst fe robust savefirst savefprefix(st11)
est store second1
esttab first1 second1  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers

twoway line donation_sum week

reg lndonation L.lnAll lnsbbgtrend grant_event  lnVolume return lnFork lnWatch week if granted==0  ,robust
estat imtest,white

gen volume = Volume / 1000000000
gen lnvolume = ln(volume)
reg lndonation L.lnAll lnsbbgtrend grant_event  lnvolume return lnFork lnWatch week if granted==0,robust
xtreg lndonation L.lnAll lnsbbgtrend grant_event  lnvolume return lnFork lnWatch i.week if granted==0, fe robust
xttest3
xtlogit donate_event L.lnAll lnsbbgtrend grant_event  lnVolume return lnFork lnWatch  if granted==0  , fe 


gen donate_event2 = 0
*48425
gen donation_sum = 48425
replace donation_sum = 48425 + 355000 if week >= 2
replace donation_sum = 48425 + 355000 + 300000 if week >= 5
replace donation_sum = 48425 + 355000 + 300000 + 1000000 if week >= 18
replace donation_sum = 48425 + 355000 + 300000 + 1000000 + 25000 if week >= 21
replace donation_sum = 48425 + 355000 + 300000 + 1000000 + 25000 + 50000 if week >= 24
replace donation_sum = 48425 + 355000 + 300000 + 1000000 + 25000 + 50000 + 150000 if week >= 70
replace donation_sum = 48425 + 355000 + 300000 + 1000000 + 25000 + 50000 + 150000 + 100000 if week >= 71
replace donation_sum = 48425 + 355000 + 300000 + 1000000 + 25000 + 50000 + 150000 + 100000 + 100000 if week >= 73
replace donation_sum = 48425 + 355000 + 300000 + 1000000 + 25000 + 50000 + 150000 + 100000 + 100000 + 1550000 if week >= 74
replace donation_sum = 48425 + 355000 + 300000 + 1000000 + 25000 + 50000 + 150000 + 100000 + 100000 + 1550000 + 180000 if week >= 76
replace donation_sum = 48425 + 355000 + 300000 + 1000000 + 25000 + 50000 + 150000 + 100000 + 100000 + 1550000 + 180000 + 5000000 if week >= 77
replace donation_sum = 48425 + 355000 + 300000 + 1000000 + 25000 + 50000 + 150000 + 100000 + 100000 + 1550000 + 180000 + 5000000 + 150000 if week >= 104
replace donation_sum = donation_sum / 10000
gen lndonation_sum = ln(donation_sum)

gen date_m = week_start
format date_m %td
gen ymd=date(date,"YMD")
gen month = month(ymd)
gen month_plus = month
replace month_plus = month + 12 if week_new >= 54
replace month_plus = 0 if week_new == 1
tab month_plus, gen(month_dum)
gen year = 0
replace year = 1 if month_plus >= 13
gen season = 0
replace season = 1 if month_plus >= 1
replace season = 2 if month_plus >= 4
replace season = 3 if month_plus >= 7
replace season = 4 if month_plus >= 10
replace season = 5 if month_plus >= 13
replace season = 6 if month_plus >= 16
replace season = 7 if month_plus >= 19
replace season = 8 if month_plus >= 22
tab season, gen(season_dum)


