**描述统计**
summarize AllEvent CodeContribution CodeReview IssueDiscussion donation donate_event grant_sum grant_event sbbgtrend volume return forkevent watchevent 

****ICSE25.4.15
*01变量
***FE
**基准回归
xtreg lnAll L.lnAll donate_event grant_event donate_grant_event lnVolume return lnFork lnWatch year if granted==0  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE donate_event grant_event donate_grant_event  lnVolume return lnFork lnWatch i.year)replace

xtreg lnCodeCon L.lnCodeCon donate_event grant_event donate_grant_event  lnVolume return  lnFork lnWatch year if granted==0  , fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE donate_event grant_event donate_grant_event  lnVolume return lnFork lnWatch i.year)append

xtreg lnCodeRev L.lnCodeRev donate_event grant_event donate_grant_event  lnVolume return   lnFork lnWatch year if granted==0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE donate_event grant_event donate_grant_event lnVolume return lnFork lnWatch i.year)append

xtreg lnISSUE L.lnISSUE donate_event grant_event donate_grant_event  lnVolume return  lnFork lnWatch year if granted==0, fe robust
outreg2 using bitcoindonation.doc, tstat bdec(3) tdec(2) keep(L.lnAll L.lnCodeCon L.lnCodeRev L.lnISSUE donate_event grant_event donate_grant_event  lnVolume return lnFork lnWatch i.year)append

**IV
drop lnsbbgtrend_grant_event
gen lnsbbgtrend_grant_event = lnsbbgtrend * grant_event
*all
xtreg donate_event L.lnAll lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0  , fe 
est store first1
xtivreg2  lnAll	 l.lnAll (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0,ffirst fe  savefirst savefprefix(st11)
est store second1
hausman first1 second1
esttab first1 second1  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers

*con
xtreg donate_event l.lnCodeCon lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0  , fe 
est store first2
xtivreg2  lnCodeCon	 l.lnCodeCon (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0,ffirst fe  savefirst savefprefix(st11)
est store second2
hausman first2 second2
esttab first1 second1  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers

*rev
xtreg donate_event l.lnCodeRev lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0  , fe 
est store first3
xtivreg2  lnCodeRev	 l.lnCodeRev (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0,ffirst fe  savefirst savefprefix(st11)
est store second3
esttab first1 second1  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers
hausman first1 second1
*iss
xtreg donate_event l.lnISSUE lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0  , fe 
est store first4
xtivreg2  lnISSUE l.lnISSUE (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0,ffirst fe  savefirst savefprefix(st11)
est store second4
hausman first4 second4
esttab first1 second1  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers
esttab second1 second2 second3 second4  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers

xtreg donate_event L.lnAll lnsbbgtrend grant_event  lnVolume return lnFork lnWatch if granted==0  , robust fe 
est store first1
xtreg donate_event l.lnCodeCon lnsbbgtrend grant_event  lnVolume return lnFork lnWatch if granted==0 , robust fe 
est store first2
xtreg donate_event l.lnCodeRev lnsbbgtrend grant_event  lnVolume return lnFork lnWatch if granted==0  , robust fe 
est store first3
xtreg donate_event l.lnISSUE lnsbbgtrend grant_event  lnVolume return lnFork lnWatch if granted==0  , robust fe 
est store first4
esttab first1 first2 first3 first4  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers


***num 稳健性检验
*all
xtreg lndonation l.lnAll grant_sum lnsbbgtrend lnVolume return lnFork lnWatch year if granted==0 ,fe 
est store first1
xtivreg2  lnAll	 l.lnAll (lndonation lndonation_grant_sum = lnsbbgtrend lnsbbgtrend_grant_sum) grant_sum lnVolume return lnFork lnWatch year if granted==0 ,ffirst fe  savefirst savefprefix(st11)
est store second1
esttab first1 second1  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers
hausman first1 second1
est store hausman1
*con
xtreg lndonation l.lnCodeCon grant_sum lnsbbgtrend lnVolume return lnFork lnWatch year if granted==0,fe 
est store first2
xtivreg2  lnCodeCon l.lnCodeCon (lndonation lndonation_grant_sum = lnsbbgtrend lnsbbgtrend_grant_sum) grant_sum lnVolume return lnFork lnWatch year if granted==0,ffirst fe  savefirst savefprefix(st11)
est store second2
esttab first2 second2  using codecon.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers
hausman first2 second2
est store hausman2
*rev
xtreg lndonation l.lnCodeRev grant_sum lnsbbgtrend lnVolume return lnFork lnWatch year if granted==0,fe 
est store first3
xtivreg2  lnCodeRev	 l.lnCodeRev (lndonation lndonation_grant_sum = lnsbbgtrend lnsbbgtrend_grant_sum) grant_sum lnVolume return lnFork lnWatch year if granted==0,ffirst fe  savefirst savefprefix(st11)
est store second3
esttab first3 second3  using codrev.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers
hausman first3 second3
est store hausman3
*iss
xtreg lndonation l.lnISSUE grant_sum lnsbbgtrend lnVolume return lnFork lnWatch year if granted==0,fe 
est store first4
xtivreg2  lnISSUE l.lnISSUE (lndonation lndonation_grant_sum = lnsbbgtrend lnsbbgtrend_grant_sum) grant_sum lnVolume return lnFork lnWatch year if granted==0,ffirst fe  savefirst savefprefix(st11)
est store second4
hausman first4 second4
est store hausman4
*esttab first1 first2 first3 first4 using issue.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers
esttab second1 second2 second3 second4 using issue.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers




log using results.log, replace
***异质性分析
**所有活动总和 sumAE>1
*all
xtreg donate_event l.lnAll lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & sumAE>1, fe 
est store first
xtivreg2  lnAll	 l.lnAll (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch year if granted==0 & sumAE>1,ffirst fe  savefirst savefprefix(st11)
est store first1
hausman first first1
est store hausman11
xtreg donate_event l.lnAll lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & sumAE==1 , fe 
est store first
xtivreg2  lnAll	 l.lnAll (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch year if granted==0 & sumAE==1,ffirst fe  savefirst savefprefix(st11)
est store second1
hausman first second1
est store hausman12

*con
xtreg donate_event l.lnCodeCon lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & sumAE>1, fe 
est store first
xtivreg2  lnCodeCon	 l.lnCodeCon (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch year if granted==0 & sumAE>1,ffirst fe  savefirst savefprefix(st11)
est store first2
hausman first first2
est store hausman21
xtreg donate_event l.lnCodeCon lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & sumAE==1, fe 
est store first
xtivreg2  lnCodeCon	 l.lnCodeCon (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & sumAE==1,ffirst fe  savefirst savefprefix(st11)
est store second2
hausman first second2
est store hausman22

*rev
xtreg donate_event l.lnCodeRev lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & sumAE==1, fe 
est store first
xtivreg2  lnCodeRev	 l.lnCodeRev (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch year if granted==0 & sumAE>1,ffirst fe  savefirst savefprefix(st11)
est store first3
hausman first first3
est store hausman31

xtreg donate_event l.lnCodeRev lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & sumAE>1, fe 
est store first
xtivreg2  lnCodeRev	 l.lnCodeRev (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & sumAE==1,ffirst fe  savefirst savefprefix(st11)
est store second3
hausman first second3
est store hausman32

*iss
xtreg donate_event l.lnISSUE lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & sumAE>1, fe 
est store first
xtivreg2  lnISSUE l.lnISSUE (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & sumAE>1,ffirst fe  savefirst savefprefix(st11)
est store first4
hausman first first4
est store hausman41
xtreg donate_event l.lnISSUE lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & sumAE==1, fe 
est store first
xtivreg2  lnISSUE l.lnISSUE (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & sumAE==1,ffirst fe  savefirst savefprefix(st11)
est store second4
hausman first second4
est store hausman42

esttab hausman11 hausman21 hausman31 hausman41 hausman12 hausman22 hausman32 hausman42 using results1.rtf, replace
esttab first1 first2 first3 first4 second1 second2 second3 second4  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers
log close
**仓库数量 RepositoriesCount>=19
*all
xtreg donate_event l.lnAll lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & RepositoriesCount>=19, fe 
est store first
xtivreg2  lnAll	 l.lnAll (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & RepositoriesCount>=19,ffirst fe  savefirst savefprefix(st11)
est store first1
hausman first first1
est store hausman11
xtreg donate_event l.lnAll lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & RepositoriesCount<19 , fe 
est store first
xtivreg2  lnAll	 l.lnAll (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & RepositoriesCount<19,ffirst fe  savefirst savefprefix(st11)
est store second1
hausman first second1
est store hausman12

*con
xtreg donate_event l.lnCodeCon lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & RepositoriesCount>=19, fe 
est store first
xtivreg2  lnCodeCon	 l.lnCodeCon (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & RepositoriesCount>=19,ffirst fe  savefirst savefprefix(st11)
est store first2
hausman first first2
est store hausman21
xtreg donate_event l.lnCodeCon lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & RepositoriesCount<19, fe 
est store first
xtivreg2  lnCodeCon	 l.lnCodeCon (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & RepositoriesCount<19,ffirst fe  savefirst savefprefix(st11)
est store second2
hausman first second2
est store hausman22

*rev
xtreg donate_event l.lnCodeRev lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & RepositoriesCount>=19, fe 
est store first
xtivreg2  lnCodeRev	 l.lnCodeRev (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & RepositoriesCount>=19,ffirst fe  savefirst savefprefix(st11)
est store first3
hausman first first3
est store hausman31

xtreg donate_event l.lnCodeRev lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & RepositoriesCount<19, fe 
est store first
xtivreg2  lnCodeRev	 l.lnCodeRev (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & RepositoriesCount<19,ffirst fe  savefirst savefprefix(st11)
est store second3
hausman first second3
est store hausman32

*iss
xtreg donate_event l.lnISSUE lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & RepositoriesCount>=19, fe 
est store first
xtivreg2  lnISSUE l.lnISSUE (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & RepositoriesCount>=19,ffirst fe  savefirst savefprefix(st11)
est store first4
hausman first first4
est store hausman41
xtreg donate_event l.lnISSUE lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & RepositoriesCount<19, fe 
est store first
xtivreg2  lnISSUE l.lnISSUE (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & RepositoriesCount<19,ffirst fe  savefirst savefprefix(st11)
est store second4
hausman first second4
est store hausman42

esttab hausman11 hausman21 hausman31 hausman41 hausman12 hausman22 hausman32 hausman42 using results1.rtf, replace
esttab first1 first2 first3 first4 second1 second2 second3 second4  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers

tsset id week
xtreg lnAll donate_event if FollowersCount>=37 & granted==0, fe robust
**粉丝数量 FollowersCount>=38
*all
xtreg donate_event l.lnAll lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & FollowersCount>=38, fe 
est store first
xtivreg2  lnAll	 l.lnAll (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & FollowersCount>=38,ffirst fe  savefirst savefprefix(st11)
est store first1
hausman first first1
est store hausman11
xtreg donate_event l.lnAll lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & FollowersCount<38 , fe 
est store first
xtivreg2  lnAll	 l.lnAll (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & FollowersCount<38,ffirst fe  savefirst savefprefix(st11)
est store second1
hausman first second1
est store hausman12

*con
xtreg donate_event l.lnCodeCon lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & FollowersCount>=38, fe 
est store first
xtivreg2  lnCodeCon	 l.lnCodeCon (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & FollowersCount>=38,ffirst fe  savefirst savefprefix(st11)
est store first2
hausman first first2
est store hausman21
xtreg donate_event l.lnCodeCon lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & FollowersCount<38, fe 
est store first
xtivreg2  lnCodeCon	 l.lnCodeCon (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & FollowersCount<38,ffirst fe  savefirst savefprefix(st11)
est store second2
hausman first second2
est store hausman22

*rev
xtreg donate_event l.lnCodeRev lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & FollowersCount>=38, fe 
est store first
xtivreg2  lnCodeRev	 l.lnCodeRev (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & FollowersCount>=38,ffirst fe  savefirst savefprefix(st11)
est store first3
hausman first first3
est store hausman31

xtreg donate_event l.lnCodeRev lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & FollowersCount<38, fe 
est store first
xtivreg2  lnCodeRev	 l.lnCodeRev (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & FollowersCount<38,ffirst fe  savefirst savefprefix(st11)
est store second3
hausman first second3
est store hausman32

*iss
xtreg donate_event l.lnISSUE lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & FollowersCount>=38, fe 
est store first
xtivreg2  lnISSUE l.lnISSUE (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & FollowersCount>=38,ffirst fe  savefirst savefprefix(st11)
est store first4
hausman first first4
est store hausman41
xtreg donate_event l.lnISSUE lnsbbgtrend grant_event  lnVolume return lnFork lnWatch year if granted==0 & FollowersCount<38, fe 
est store first
xtivreg2  lnISSUE l.lnISSUE (donate_event donate_grant_event = lnsbbgtrend lnsbbgtrend_grant_event) grant_event lnVolume return lnFork lnWatch if granted==0 & FollowersCount<38,ffirst fe  savefirst savefprefix(st11)
est store second4
hausman first second4
est store hausman42

esttab hausman11 hausman21 hausman31 hausman41 hausman12 hausman22 hausman32 hausman42 using results1.rtf, replace
esttab first1 first2 first3 first4 second1 second2 second3 second4  using all.rtf, replace varwidth(25) nogap star(* 0.1 ** 0.05 *** 0.01) b(%8.3f) stats(N N_g F r2_a idstat widstat, fmt(%12.0f %12.0f %9.3f %9.3f %9.3f %9.3f)) nonumbers






