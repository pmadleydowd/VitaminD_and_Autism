log using "$Logdir\LOG_an_spline.txt", text replace

********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		02 August 2021
* Description: 	Spline analyses for vit D and autism project
********************************************************************************
* Contents
* 1 Set up environment and read in data
* 2 Perform spline analyses for logistic regression models
* 3 Perform spline analyses for linear regression models

********************************************************************************
* 1 Set up environment and read in data
*******************************************************************************
ssc install xbrcspline

cd "$Datadir\Spline analysis"
use "$Datadir\DERIVED_VitD_dat.dta", clear

keep if flag_mat_white_eth	== 1
keep if flag_alive1yr 		== 1
keep if flag_singleton		== 1
keep if flag_outcomeany 	== 1
keep if miss_exposure		== 0 
	

		
********************************************************************************
* 2 Perform spline analyses for logistic regression models
********************************************************************************
* Create splines
gen rnd_sadj = round(sadj_vitd_10,0.01)	

mkspline sadj_spline = rnd_sadj, nknots(5) cubic displayknots
mat sadj_knots = r(knots)	

* Create model 	
foreach outcome in ASD bin_scdc bin_coh bin_repbehaviour bin_sociability {

	logistic `outcome' sadj_spline* i.male i.matEdDrv i.finDifDrv i.manual prepregBMI matage i.mat_smok_bin18wk i.parity_cat

	levelsof rnd_sadj
	xbrcspline sadj_spline, matknots(sadj_knots) values(`r(levels)') ref(6.13) gen(vitd est1 lci1 uci1) eform 

				
	gen yline=1 if vitd~=. 

	twoway (area uci1 vitd, yscale(log) color(gs10)) (area lci1 vitd, yscale(log) color(white)) || /*
	*/ line est1 vitd, yscale(log) lwidth(thick) lcolor(black) legend(off) /*
	*/ graphregion(color(white) lwidth(large)) /*
	*/ plotregion(color(white) icolor(white) lwidth(large)) /*
	*/ xtitle("{fontface calibri:Adjusted vitamin D, nmol/L}", size(medlarge)) /*
	*/ ytitle("{fontface calibri:Odds ratio with shading for 95% CI}", size(medlarge)) /*
	*/ ylabel(5 "{fontface calibri:5}" 2 "{fontface calibri:2}" 1 "{fontface calibri:1}" /*
	*/ 0.5 "{fontface calibri:0.5}" 0.1 "{fontface calibri:0.1}"  /*
	*/ , angle(0) nogrid) /*
	*/ xlabel(0 "{fontface calibri:0}" /*
	*/  2 "{fontface calibri:20}" /*
	*/  4 "{fontface calibri:40}" /*
	*/  6 "{fontface calibri:60}" /*
	*/  8 "{fontface calibri:80}" /*
	*/  10"{fontface calibri:100}" /*
	*/  12"{fontface calibri:120}" /*
	*/  14"{fontface calibri:140}" /*
	*/  16"{fontface calibri:160}" /*	
	*/  18"{fontface calibri:180}" /*
	*/  20"{fontface calibri:200}" /*
	*/  22"{fontface calibri:220}" /*	
	*/   , angle(0) labsize(medsmall) nogrid) || /*
	*/ line yline vitd, lwidth(med) lcolor(red) lpattern(shortdash)
				
	graph display, ysize(20) xsize(16)
	graph export "$Graphdir\spline_sadj_`outcome'.tif", height(2000) width(1600) replace
		
	drop vitd est1 lci1 uci1 yline
}

		
********************************************************************************
* 3 Perform spline analyses for linear regression models
********************************************************************************
* Create model 	
regress zmf_asd sadj_spline* i.male i.matEdDrv i.finDifDrv i.manual prepregBMI matage i.mat_smok_bin18wk i.parity_cat

levelsof rnd_sadj
xbrcspline sadj_spline, matknots(sadj_knots) values(`r(levels)') ref(6.13) gen(vitd est1 lci1 uci1) 

			
gen yline = 0 if vitd~=. 

twoway (area uci1 vitd, color(gs10)) (area lci1 vitd, color(gs10)) || /*
*/ line est1 vitd, lwidth(thick) lcolor(black) legend(off) /*
*/ graphregion(color(white) lwidth(large)) /*
*/ plotregion(color(white) icolor(white) lwidth(large)) /*
*/ xtitle("{fontface calibri:Adjusted vitamin D, nmol/L}", size(medlarge)) /*
*/ ytitle("{fontface calibri:Mean difference with shading for 95% CI}", size(medlarge)) /*
*/ ylabel(0.3 "{fontface calibri:0.3}" /*
*/ 	 	  0.2 "{fontface calibri:0.2}" /*
*/  	  0.1 "{fontface calibri:0.1}" /*
*/    	  0    "{fontface calibri:0}" /*
*/ 		 -0.1 "{fontface calibri:-0.1}"  /*
*/ 		 -0.2 "{fontface calibri:-0.2}"  /*
*/ , angle(0) nogrid) /*
*/ xlabel(0 "{fontface calibri:0}" /*
*/  	  2 "{fontface calibri:20}" /*
*/  	  4 "{fontface calibri:40}" /*
*/  	  6 "{fontface calibri:60}" /*
*/  	  8 "{fontface calibri:80}" /*
*/       10 "{fontface calibri:100}" /*
*/  	 12 "{fontface calibri:120}" /*
*/  	 14 "{fontface calibri:140}" /*
*/  	 16 "{fontface calibri:160}" /*	
*/  	 18 "{fontface calibri:180}" /*
*/  	 20 "{fontface calibri:200}" /*
*/  	 22 "{fontface calibri:220}" /*	
*/   , angle(0) labsize(medsmall) nogrid) || /*
*/ line yline vitd, lwidth(med) lcolor(red) lpattern(shortdash)
			
graph display, ysize(20) xsize(16)
graph export "$Graphdir\spline_sadj_fm.tif", height(2000) width(1600) replace
	
drop vitd est1 lci1 uci1 yline


********************************************************************************
* close log
********************************************************************************
log close



