* ============================================================================ *
* Author: Pietro Bianchini, Marco Valentino Caravella, Elia Gioele Larcinese

* Pietro Bianchini - 001135241
* Marco Valentino Caravella - 0001134954
* Elia Gioele Larcinese - 0001133075


* Date: 6 Dec 2024

* Object: Second Problem Set of Microeconometrics
* ============================================================================ *

clear all
set more off

* ============================================================================ *
						*Part 1: Data Exploration*
* ============================================================================ *

* Import Data
global ps1 "C:\Users\user\Documents\Unibo\Economics and Econometrics\Second Year\Second Semester\Microeconometrics\Tutorial\Problem Set 2" 
use "PS29.DTA", clear

* 1) What are the main characteristics of the sample? Provide a table that displays the mean, standard deviation, minimum, and maximum value of all the variables available. Comment on it.
sum age-pol_kn, separator(3)

* 2) Compute the t-test 
estpost ttest age educ fem party empl pol_kn0 app pol_kn, by(enc)

* Export them (table2)
esttab . using "table2.tex", cells("mu_1 mu_2 se t p_l p p_u") replace