
* ============================================================================ *
* Author: Pietro Bianchini, Marco Valentino Caravella, Elia Gioele Larcinese

* Date: 29 Nov 2024

* Object: First Problem Set of Microeconometrics
* ============================================================================ *

clear all
set more off

* ============================================================================ *
						*Part 1: Data Exploration*
* ============================================================================ *

* 1) Import Data
global ps1 "C:\Users\user\Documents\Unibo\Economics and Econometrics\Second Year\Second Semester\Microeconometrics\Tutorial\Problem Set 1" 
use "$ps1/MLand_jobpol_11.DTA", clear

* Reshape from wide to long form
reshape long unempl_ avg_educ_ size_ econ_conn_ share_imm_ crimes_pc_, i(id_zip) j(year)

* Define the Data as a Panel Data
xtset id_zip year

* The variable that tells us whether the impact of the policy of the Ministry of Labor is positive or not is unempl_. This variable, toghter with id_zip and year, should be used to evaluate the policy.

* 2) What are the characteristics of the sample in 2022?
xtsum if year == 20
sum if year == 20

* Do some of these characteristic change over time?
xtsum 
* Only size_ does not vary over time. It describes characteristics (size of the neighborhood?) of the statistical units of the sample that do not vary much over time. 

* Plot the sample distribution of unempl_ in year 2020
hist unempl_ if year==20, bin(20) start(0) color(navy) lcolor(black) lwidth(medium) ///
			  title("Unemployment 2020 Histogram") subtitle("Distribution of Empl. Rate") ///
			  ylabel(, nogrid) xtitle("Unemployed Percentage") ytitle("Frequency") ///
			  legend(off) graphregion(color(white)) plotregion(margin(zero)) ///
			  addplot((kdensity unempl_, lcolor(red) lwidth(medium))) ///
			  name("unempl", replace)
			
* Plot the sample distribution of unempl_ in year 2024
hist unempl_ if year==24, bin(20) start(0) color(navy) lcolor(black) lwidth(medium) ///
			  title("Unemployment 2024 Histogram") subtitle("Distribution of Empl. Rate") ///
			  ylabel(, nogrid) xtitle("Unemployed Percentage") ytitle("Frequency") ///
			  legend(off) graphregion(color(white)) plotregion(margin(zero)) ///
			  addplot((kdensity unempl_, lcolor(red) lwidth(medium))) ///
			  name("unempl", replace)

* 3) Compute and interpret the overall, within and between variation of unempl_
xtsum unempl_
* The overall mean is the average of unempl_ across the entire sample (average of the N*T observations). The unemployment rate in the entire sample is 18.85%. The between min and max gives the minimum and maximum value of the average of unempl_ across id_zip (units) for each year. The visible difference between these two values is of small importance for our analysis. Finally, within min and max are the minimum and maximum unempl_ average of each unit across time. This measure is of great impact for this analysis. By looking at the output of this measure we can asses that unempl_ varies over time and it does so only positively, that is, unempl_ increase over time (min > 0).

* 4) Considering only data from 2022, check whether neighborhoods where an employment center was implemented or not differ, on average, along any of the observable variables
xtsum if center == 1 & year == 22
xtsum if center == 0 & year == 22

* or
graph bar (mean) unempl_ (mean) econ_conn_ (mean) share_imm_ (mean) crimes_pc_ if year == 22, by(center)
graph bar (mean) avg_educ_ (mean) size_ if year == 22, by(center)