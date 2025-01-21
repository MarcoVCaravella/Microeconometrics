* ============================================================================ *
* Author: Marco Valentino Caravella, Elia Gioele Larcinese

* Date: 15 Dec 2024

* Object: Third Problem Set of Microeconometrics
* ============================================================================ *

clear all
set more off

* ============================================================================ *
						*Part 1: Probit Model*
* ============================================================================ *

*import Data
global ps1 "C:\Users\user\Documents\Unibo\Economics and Econometrics\Second Year\Second Semester\Microeconometrics\Tutorial\Problem Set 3" 
use "life_sat.dta", clear

sort year

* Save dataset for recalling it later
global sorted_data "sorted_data.dta"
save "$sorted_data", replace

* Note that two observations have missing values for phinact and esmoked:
sum // two missing values for phinact and esmoked
sum if phinact == .
sum if esmoked == . // both variables have missing values for the same two observations.
* Using Summarise Statistics we notice that they are not outliers. Thus, since we only have two NA that are not outliers and that probabily will not affect the analysis much, we proceed by dropping the observations related to NA
drop if cjs == .

* 1) 
* Generate time dummy variables
drop mergeid

gen d2011 = 0
replace d2011 = 1 if year == 2011

gen d2013 = 0
replace d2013 = 1 if year == 2013

gen d2015 = 0
replace d2015 = 1 if year == 2015

drop year

* Chose which regressor to include in the model

* Model 1 (baseline model)
global bl_controls "age gender yedu mstat hstatus gali"
probit life_sat income $bl_controls d2013 d2015, r
* The pvalue of the Wald test statistic is 0, meaning that we reject the null hypiothesis that the baseline regressors are jointly insignificant. Hence, the baseline regressors have some explanatory power. The pseudo R2 is 0.0796 (not really interpretable, even though it is low)

predict phat_model1
sum phat_model1
replace phat_model1 = phat_model1>0.5
tab life_sat phat_model1, column
di (2384 + 5633)/12244 //.65476968

* Model 2
* Generate new dummy variables based on previous categorical variables
gen owner = 0
replace owner = 1 if otrf == 1

drop otrf

gen employed = 0
replace employed = 1 if cjs == 2

gen retired = 0
replace retired = 1 if cjs == 1

drop cjs

probit life_sat income $bl_controls owner employed retired d2013 d2015, r

* Evaluate whether adding these dummies improves prediction with respect to the baseline model
predict phat_model2
sum phat_model2
replace phat_model2 = phat_model2>0.5
tab life_sat phat_model2, column

di (2377 + 5715)/12244 //.66089513 --> percentage correctly predicted is higher than in model 1

* Expand model 2 iteratively, by adding controls which are grouped by category

* Category 1: household composition (children and grandchildren may significantly contribute to life satisfaction; also try nursing home)
probit life_sat income $bl_controls owner employed retired htype d2013 d2015, r
probit life_sat income $bl_controls owner employed retired d2013 d2015, r 
probit life_sat income $bl_controls owner employed retired nchild ngrchild d2013 d2015, r 
probit life_sat income $bl_controls owner employed retired nchild ngrchild nursinghome d2013 d2015, r 

* Category 2: household wealth
corr thexp fahc fohc hprf hnetw
probit life_sat income $bl_controls owner employed retired nchild ngrchild hnetw d2013 d2015, r 
probit life_sat income $bl_controls owner employed retired nchild ngrchild hnetw thexp d2013 d2015, r


* Category 3: individual health
probit life_sat income $bl_controls owner employed retired nchild ngrchild thexp hnetw phinact d2013 d2015, r 
probit life_sat income $bl_controls owner employed retired nchild ngrchild thexp hnetw phinact bmi d2013 d2015, r 
probit life_sat income $bl_controls owner employed retired nchild ngrchild thexp hnetw phinact esmoked d2013 d2015, r 
probit life_sat income $bl_controls owner employed retired nchild ngrchild thexp hnetw phinact doctor d2013 d2015, r
probit life_sat income $bl_controls owner employed retired nchild ngrchild thexp hnetw phinact hospital d2013 d2015, r 

* The final model is: 
probit life_sat income $bl_controls owner employed retired nchild ngrchild thexp hnetw phinact d2013 d2015, r 

* Save it 
esttab using "probit.tex", replace ///
    label tex ///
    title("Probit Estimation of Life Satisfaction") ///
    se
*2)
* Drop unused variables
keep id life_sat income $bl_controls owner employed retired nchild ngrchild thexp hnetw phinact d2013 d2015

* Summarise the observations
estpost sum income $bl_controls owner employed retired nchild ngrchild thexp hnetw phinact d2013 d2015
	esttab using "Summary Statistics.tex", cells("count mean sd min max") title("Summary Statistics") label replace  

* Compute the partial effect of income at average values
probit life_sat income $bl_controls owner employed retired nchild ngrchild thexp hnetw phinact d2013 d2015, r 

scalar xb_avg = _b[income]*.3110063 + _b[age]*66.90983 + _b[gender]*1.55178 + _b[yedu]*8.722231 + _b[mstat]*1.916204 + _b[hstatus]*2.751878 + _b[gali]*.4097517 + _b[owner]*.8371447+ _b[employed]*.218066 + _b[retired]*.513231 + _b[nchild]*1.955162 + _b[ngrchild]*2.032424 + _b[thexp]*8403.044 + _b[hnetw]*249674.9 + _b[phinact]*.2114505 + _b[d2013]*.3484156 + _b[d2015]*.3879451 + _b[_cons]
di xb_avg
scalar pdf_value = normalden(xb_avg) //density of the normal at xb_avg
scalar marginal_effect_income = pdf_value * _b[income]
di marginal_effect_income //.02655573 


*3) 
* Compute the partial effect of gali at the average

scalar xb_gali_1 = _b[income]*.3110063 + _b[age]*66.90983 + _b[gender]*1.55178 + _b[yedu]*8.722231 + _b[mstat]*1.916204 + _b[hstatus]*2.751878 + _b[gali]*1 + _b[owner]*.8371447+ _b[employed]*.218066 + _b[retired]*.513231 + _b[nchild]*1.955162 + _b[ngrchild]*2.032424 + _b[thexp]*8403.044 + _b[hnetw]*249674.9 + _b[phinact]*.2114505 + _b[d2013]*.3484156 + _b[d2015]*.3879451 + _b[_cons]

scalar xb_gali_0 = _b[income]*.3110063 + _b[age]*66.90983 + _b[gender]*1.55178 + _b[yedu]*8.722231 + _b[mstat]*1.916204 + _b[hstatus]*2.751878 +  _b[owner]*.8371447+ _b[employed]*.218066 + _b[retired]*.513231 + _b[nchild]*1.955162 + _b[ngrchild]*2.032424 + _b[thexp]*8403.044 + _b[hnetw]*249674.9 + _b[phinact]*.2114505 + _b[d2013]*.3484156 + _b[d2015]*.3879451 + _b[_cons]
di normal(xb_gali_1) - normal(xb_gali_0) //-.0628773

*4)
* Compute the Average Partial Effects (APE)
estpost margins, dydx(_all)
	esttab using "APE.tex", title("Average Partial Effects") label tex replace

* Compute the Partial Effects at the Average (PEA)
probit life_sat income $bl_controls owner employed retired nchild ngrchild thexp hnetw phinact d2013 d2015, r 

estpost margins, dydx(_all) at(income=.3110063 age=66.90983 gender=1.55178 yedu=8.722231 mstat=1.916204 hstatus=2.751878 gali=.4097517 owner=.8371447 employed=.218066  retired=.513231  nchild=1.955162 ngrchild=2.032424 thexp=8403.044 hnetw=249674.9 phinact=.2114505 d2013=.3484156 d2015=.3879451)

* Export margins' results	
esttab using "PEA.tex", title("Partial Effects at the Average") label tex replace

*5)
* Evaluate the goodness of the model through Type I and Type II Errors
probit life_sat income $bl_controls owner employed retired nchild ngrchild thexp hnetw phinact d2013 d2015, r 

predict phat_final_model
sum phat_final_model 
replace phat_final_model = phat_final_model>0.5
tab life_sat phat_final_model, column 

* Type I error: predict life_sat = 1 when life_sat = 0
display 2720 / 5143 //type 1 error rate: .5288742

* Type II error: predict life_sat = 0 when life_sat = 1
display 1381 / 7101 //type 2 error rate: .19447965

* Percentage correctly predicted by the model:
display  (2423 + 5720) /  12244 //.66506044

* Export the tab
estpost tab life_sat phat_final_model, elabels
	esttab using "tab.tex", replace nonumbers  eqlabels(, lhs("Observed Life_Sat")) collabels(none) cells((b) pct(fmt(2)) count(fmt(%9.0g))) unstack noobs nonotes nodepvars  lines nogaps varlabels() mtitles("Predicted Life_Sat")

*6)
* APE for males:
probit life_sat income if gender == 1, r
margins, dydx(income) // .0701868 

* APE for females:
probit life_sat income if gender == 2, r
margins, dydx(income) // .0827362 

* Average Partial Effect across income levels
sum income if gender == 1, detail
sum income if gender == 2, detail

* For males: 
probit life_sat income if gender == 1, r
margins, dydx(income) at(income =  .144) // .0709965  (significant at 1%)
margins, dydx(income) at(income = .204 ) // .0707945  (significant at 1%)
margins, dydx(income) at(income = .3208628) // .0703782  (significant at 1%)
margins, dydx(income) at(income =  2.7) // .0564623 (significant at 1%)
predict phat_males

* For females:
probit life_sat income if gender == 2, r
margins, dydx(income) at(income = .132) // .0833745  (significant at 1%)
margins, dydx(income) at(income = .192) // .083262 (significant at 1%)
margins, dydx(income) at(income = .3) // .0830268 (significant at 1%)
margins, dydx(income) at(income =  2.52) // .0698951 (significant at 1%)
predict phat_females

* Scatter plot:
twoway scatter phat_females income, ///
        title("Predicted Probabilities: Females") ///
		xlabel(0(0.2)4) ///
       saving(females_plot, replace) 


twoway scatter phat_males income, ///
       title("Predicted Probabilities: Males") ///
	   xlabel(0(0.2)4) ///
	   saving(males_plot, replace)
      
twoway (scatter phat_males income) (scatter phat_females income), ytitle("Predicted Life Statisfaction") xtitle("Income Level") xlabel(0(0.2)4) legend(off)
graph export "ScatterPlot.jpg", replace

* bonus) 
* Repeating the previous point adding covariates
global bl_controls_wo_gender "age yedu mstat hstatus gali" // omit "gender" because we will perform an analysis by it

* APE for males
probit life_sat income $bl_controls_wo_gender owner employed retired nchild ngrchild thexp hnetw phinact d2013 d2015 if gender == 1, r 
margins, dydx(income) //.0275018

* APE for females
probit life_sat income $bl_controls_wo_gender owner employed retired nchild ngrchild thexp hnetw phinact d2013 d2015 if gender == 2, r 
margins, dydx(income) //.0191103

* Average Partial Effect across income levels

* For males:
probit life_sat income $bl_controls_wo_gender owner employed retired nchild ngrchild thexp hnetw phinact d2013 d2015 if gender == 1, r 
margins, dydx(income) at(income =  .144) //.0276563  (significant at 10%)
margins, dydx(income) at(income = .204 ) //.0276223 (significant at 10%)
margins, dydx(income) at(income = .3208628) //.0275547 (significant at 10%)
margins, dydx(income) at(income =  2.7) //.0258155  (significant at 5%)
predict phat_males_covariates

* For females:
probit life_sat income $bl_controls_wo_gender owner employed retired nchild ngrchild thexp hnetw phinact d2013 d2015 if gender == 2, r 
margins, dydx(income) at(income = .132) //.019161 (not significant)
margins, dydx(income) at(income = .192) //.0191537 (not significant)
margins, dydx(income) at(income = .3) //.0191402  (not significant)
margins, dydx(income) at(income =  2.52) //.0187505  (not significant)
predict phat_females_covariates

* Scatter plot:
twoway scatter phat_males_covariates income, mcolor(blue) msymbol(smcircle) title("Predicted Probabilities: Males")  xtitle(`"Income Level"') saving(males_plot_covariates, replace) 

twoway scatter phat_females_covariates income , mcolor(pink) msymbol(smtriangle) title("Predicted Probabilities: Females")  xtitle(`"Income Level"') saving(females_plot_covariates, replace) 
	   
graph combine females_plot_covariates.gph males_plot_covariates.gph, ///
       title("Predicted Probabilities by Gender") ///
       col(2)
graph export "ScatterPlot2.jpg", replace

