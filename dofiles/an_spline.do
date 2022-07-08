cap log using "$Logdir\LOG_an_spline.txt", text replace

********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		02 August 2021
* Description: 	Spline analyses for vit D and autism project
********************************************************************************
* Contents
* 1 Set up environment and read in data
* 2 Perform spline analyses for logistic regression models
* 3 Perform spline analyses for linear regression models
* 4 Combine plots

********************************************************************************
* 1 Set up environment and read in data
*******************************************************************************
ssc install xbrcspline

use "$Datadir\DERIVED_VitD_dat.dta", clear

keep if flag_inclusion 		== 1

		
********************************************************************************
* 2 Perform spline analyses for logistic regression models
********************************************************************************
set scheme s2mono
* Create splines
gen rnd_sadj = round(sa_20wk_VitDtot_10,0.01)	

mkspline sadj_spline = rnd_sadj, nknots(5) cubic displayknots
mat sadj_knots = r(knots)	

* Create model 
local i = 0	
foreach outcome in ASD bin_scdc bin_coh bin_repbehaviour bin_sociability {

	local i = `i'+ 1
	
	logistic `outcome' sadj_spline* i.male i.matEdDrv i.finDifDrv i.manual prepregBMI matage i.mat_smok_bin18wk i.parity_cat

	levelsof rnd_sadj
	xbrcspline sadj_spline, matknots(sadj_knots) values(`r(levels)') ref(5.87) gen(vitd est1 lci1 uci1) eform 

				
	gen yline=1 if vitd~=. 
	
	if "`outcome'" == "ASD" {
		local tit = "Diagnosed Autism"
	}
	else if "`outcome'" == "bin_scdc" {
		local tit = "Social Communication Trait"
	}
	else if "`outcome'" == "bin_coh" {
		local tit = "Speech Coherence Trait"
	}
	else if "`outcome'" == "bin_repbehaviour" {
		local tit = "Repetitive Behaviour Trait"
	}
	else if "`outcome'" == "bin_sociability" {
		local tit = "Sociability Temperament Trait"
	}
	

	twoway (rarea lci1 uci1 vitd, yscale(log range(0.2 8)) color(gs10))  || /*
	*/ line est1 vitd, yscale(log) lwidth(medium) lcolor(black) legend(off) /*
	*/ graphregion(color(white) lwidth(large)) /*
	*/ plotregion(color(white) icolor(white) lwidth(large)) /*
	*/ title("`tit'", size(small)) /*
	*/ xtitle("{fontface calibri:Maternal 25(OH)D (nMol/L)}" "{fontface calibri: adjusted to 20 weeks}", size(med)) /*
	*/ ytitle("{fontface calibri:Odds ratio and 95% CI}", size(medlarge)) /*
	*/ ylabel(5 "{fontface calibri:5}" 2 "{fontface calibri:2}" 1 "{fontface calibri:1}" /*
	*/ 0.5 "{fontface calibri:0.5}" 0.2 "{fontface calibri:0.2}"  /*
	*/ , angle(0) nogrid) /*
	*/ xlabel(0 "{fontface calibri:0}" /*
	*/  4 "{fontface calibri:40}" /*
	*/  8 "{fontface calibri:80}" /*
	*/  12"{fontface calibri:120}" /*
	*/  16"{fontface calibri:160}" /*	
	*/  20"{fontface calibri:200}" /*
	*/  24 "{fontface calibri:240}" /*	
	*/  28 "{fontface calibri:280}" /*		
	*/   , angle(45) labsize(medsmall) nogrid) || /*
	*/ line yline vitd, lwidth(med) lcolor(red) lpattern(shortdash) /*
	*/ name(fig`i', replace)
				
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
xbrcspline sadj_spline, matknots(sadj_knots) values(`r(levels)') ref(5.87) gen(vitd est1 lci1 uci1) 

	

			
gen yline = 0 if vitd~=. 

twoway (rarea lci1 uci1 vitd, color(gs10))  || /*
*/ line est1 vitd, lwidth(medium) lcolor(black) legend(off) /*
*/ graphregion(color(white) lwidth(large)) /*
*/ plotregion(color(white) icolor(white) lwidth(large)) /*
*/ title("Autism Factor Mean Score", size(small)) 	/*
*/ xtitle("{fontface calibri:Maternal 25(OH)D (nMol/L)}" "{fontface calibri: adjusted to 20 weeks}", size(med)) /*
*/ ytitle("{fontface calibri:Mean difference and 95% CI}", size(medlarge)) /*
*/ ylabel(0.4 "{fontface calibri:0.4}" /*
*/		  0.3 "{fontface calibri:0.3}" /*
*/ 	 	  0.2 "{fontface calibri:0.2}" /*
*/  	  0.1 "{fontface calibri:0.1}" /*
*/    	  0    "{fontface calibri:0}" /*
*/ 		 -0.1 "{fontface calibri:-0.1}"  /*
*/ 		 -0.2 "{fontface calibri:-0.2}"  /*
*/ , angle(0) nogrid) /*
*/ xlabel(0 "{fontface calibri:0}" /*
*/  	  4 "{fontface calibri:40}" /*
*/  	  8 "{fontface calibri:80}" /*
*/  	 12 "{fontface calibri:120}" /*
*/  	 16 "{fontface calibri:160}" /*	
*/  	 20 "{fontface calibri:200}" /*
*/  	 24 "{fontface calibri:240}" /*	
*/	     28 "{fontface calibri:280}" /*	
*/   , angle(45) labsize(medsmall) nogrid) || /*
*/ line yline vitd, lwidth(med) lcolor(red) lpattern(shortdash) /*
*/ name(fig6, replace)
			
graph display, ysize(20) xsize(16)
graph export "$Graphdir\spline_sadj_fm.tif", height(2000) width(1600) replace
	
drop vitd est1 lci1 uci1 yline


********************************************************************************
* 4 Combine plots
********************************************************************************

graph combine fig1 fig2 fig3 fig4 fig5 fig6 , cols(3)
graph export "$Graphdir\spline_combined.tif", height(2000) width(3000) replace



********************************************************************************
* close log
********************************************************************************
log close



