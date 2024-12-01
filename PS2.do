* ============================================================================ *
* Author: Pietro Bianchini, Marco Valentino Caravella, Elia Gioele Larcinese

* Pietro Bianchini - 001135241
* Marco Valentino Caravella - 0001134954
* Elia Gioele Larcinese - 0001133075


* Date: 29 Nov 2024

* Object: First Problem Set of Microeconometrics
* ============================================================================ *

clear all
set more off

* ============================================================================ *
						*Part 1: Data Exploration*
* ============================================================================ *

* 1) 
*import Data
global ps1 "C:\\Users\\user\\OneDrive - Alma Mater Studiorum Università di Bologna\\Desktop\\LMEC - 2nd year\\2nd period\\microeconometrics\\PS 1" 
use "$ps1\\MLand_jobpol_11.DTA", clear

* Reshape from wide to long form
reshape long unempl_ avg_educ_ size_ econ_conn_ share_imm_ crimes_pc_, i(id_zip) j(year)

* Define the Data as a Panel Data
xtset id_zip year

* Save dataset in its version as panel data for recalling it later
global pd "$ps1\\panel_data.dta"
save "$pd", replace


* 2) 
*check characteristics of the sample in 2022
xtsum if year == 22
sum if year == 22

* check whether some of these characteristics change over time
tab year //to check whether panel is balanced or not
xtsum 

* this piece of code reproduces table 1 in the pdf 
tabstat unempl_-crimes_pc_, by(year) statistics(mean sd min max) long 

* plot the sample distribution of unempl_ in year 2022
hist unempl_ if year==22, bin(60) start(0) color(navy) lcolor(black) lwidth(medium) ///
			  title("Unemployment 2022 Histogram") subtitle("Distribution of Empl. Rate") ///
			  ylabel(, nogrid) xtitle("Unemployed Percentage") ytitle("Frequency") ///
			  legend(off) graphregion(color(white)) plotregion(margin(zero)) ///
			  addplot((kdensity unempl_, lcolor(red) lwidth(medium))) ///
			  name("unempl_2022", replace)
			
* plot the sample distribution of unempl_ in year 2024
hist unempl_ if year==24, bin(60) start(0) color(navy) lcolor(black) lwidth(medium) ///
			  title("Unemployment 2024 Histogram") subtitle("Distribution of Empl. Rate") ///
			  ylabel(, nogrid) xtitle("Unemployed Percentage") ytitle("Frequency") ///
			  legend(off) graphregion(color(white)) plotregion(margin(zero)) ///
			  addplot((kdensity unempl_, lcolor(red) lwidth(medium))) ///
			  name("unempl_2024", replace)
			  
* thus piece of code reproduces figure 1 in pthe pdf		  
graph combine unempl_2022 unempl_2024, col(2)	
graph export "unemployment_combined.png", replace 
		  
			  
* 3) 
*this piece of code produces table 2 in the pdf
xtsum unempl_
*this piece of code reproduces figure 2 in the pdf
collapse (mean) unempl_, by(year)
twoway (line unempl_ year), title("Average Unemployment Rate Over Time") xtitle("Year") ytitle("Unemployment Rate")
graph export "avg_unemployment_over_years.png", replace
		  
* 4) 
clear all
set more off
use "$pd"

* Compute summary statistics for center == 1 and year == 22. This code produces table 3 in the pdf
summarize unempl_ avg_educ_ size_ econ_conn_ share_imm_ crimes_pc_ if center == 1 & year == 22

* Compute summary statistics for center == 0 and year == 22. this code produces table 4 in the pdf
summarize unempl_ avg_educ_ size_ econ_conn_ share_imm_ crimes_pc_ if center == 0 & year == 22

*using a two-sample t-test to test whether means for the two groups are significantly different for each variable
ttest unempl_ if year == 22, by(center)
ttest avg_educ_ if year == 22, by(center)
ttest size_ if year == 22, by(center)
ttest econ_conn_ if year == 22, by(center)
ttest share_imm_ if year == 22, by(center)
ttest crimes_pc_ if year == 22, by(center)

* ============================================================================ *
						*Part 2: Impact Evaluation*
* ============================================================================ *

*1) 
clear all
set more off
use "$pd"

* loop through each year to store coefficients
gen beta_center = .

foreach year in 23 24 25 {
    reg unempl_ center if year == `year'
    replace beta_center = _b[center] if year == `year'
}

* Plot the coefficents on center by year
graph twoway scatter beta_center year if inlist(year, 23, 24, 25), /// 
    title("Effect of Center on Unemployment by Year") /// 
    ytitle("Coefficient on Center") xtitle("Year") /// 
    ylabel(-0.10(0.02)0.10, angle(0) format(%5.2f)) /// Set y-axis range and steps 
    xlabel(23 24 25, angle(0)) ///
    yline(0, lcolor(black) lpattern(dash))  // Add dotted line at y = 0

* this code reproduces figure 3 in the pdf	
graph export "center_coefficients_by_year.jpg", replace
	
	   
*2)

clear all
set more off
use "$pd"

* Calculate average unemployment rate by year for the treatment group and the control group
collapse (mean) unempl_, by(year center) 

keep if inlist(year, 20, 21, 22)

twoway (line unempl_ year if center == 0, lcolor(blue) lwidth(medium) ///
        legend(label(1 "Control Group (Center = 0)"))) ///
       (line unempl_ year if center == 1, lcolor(red) lwidth(medium) ///
        legend(label(2 "Treatment Group (Center = 1)"))) ///
// this piece of code reproduces figure 4 in the pdf
graph export "unemployment_pre2023_trends.png", replace
       
	   
* 3) 
clear all
set more off
use "$pd"
* Consider the first period
mean unempl_ if year < 23 & center == 0 // Average unemployment before '23 non-treated
mat a = e(b)
mean unempl_ if year < 23 & center == 1 // Average unemployment before '23 treated
mat b = e(b)

mean unempl_ if year >= 23 & center == 0 // Average unemployment after '23 non-treated
mat c = e(b)
mean unempl_ if year >= 23 & center == 1 // Average unemployment after '23 treated
mat d = e(b)

* we now compute the double difference between averages
mat e = (d - c) - (b - a)
mat list e
* ( d - c) - ( b - a) = (.2234296 - .2198283) - (.2264166 -  .1264641 ) = -0.0963512
* The coefficient of the treatment effect is -9.64%

* 4) 
clear all
set more off
use "$pd"

* Generate a dummy equal to 1 if post policy
gen post =  0 
replace post = 1 if year >= 23

* Compute the mean of unempl_ in the overall sample
bysort id_zip post: egen avg_unempl = mean(unempl_)

* Generate a variable containing the mean of unempl_ pre-policy
gen avg_unempl_pre = avg_unempl if post == 0 
bysort id_zip (post): replace avg_unempl_pre = avg_unempl[1] if missing(avg_unempl_pre)

* Generate a variable containing the mean of unempl_ post-policy
gen avg_unempl_post = avg_unempl if post == 1 
bysort id_zip (post): replace avg_unempl_post = avg_unempl[6] if missing(avg_unempl_post)

* Compute the difference for the dependent variable (First Differencing)
bysort id_zip: gen diff = avg_unempl_post - avg_unempl_pre

* First Differencing Regression
reg diff center

* this piece of code reproduces table 5 in the pdf
outreg using table5, tex  note(Table 5: Coefficients of the DiD First Difference Regression) replace






