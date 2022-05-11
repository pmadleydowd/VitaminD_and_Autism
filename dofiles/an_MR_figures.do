capture log close
log using "$Logdir\LOG_an_MR_figures.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2021-11-11
* Description: Creation of figures for MR analyses  
* Note: Adapted from code written by Flo Martin in the following file:
* 	- https://github.com/flozoemartin/MoD/tree/main/dofiles/6_figures.do
********************************************************************************
* Contents
********************************************************************************
* 1 Create environment 
* 2 Prepare data 
* 3 Output figure of MR analyses 
********************************************************************************
* 1 Create environment 
********************************************************************************
* Change directory for saving graphs
cd "$Graphdir"


********************************************************************************
* 2 Prepare data 
********************************************************************************
import excel "$Datadir\MR analysis\MR1samp_output.xlsx", clear
rename A outcome
rename B mod1_N
rename C mod1_ORCI
rename D mod2_N
rename E mod2_ORCI

gen mod1_or  = substr(mod1_ORCI, 1, strpos(mod1_ORCI,"(")-1)
gen mod1_lci = substr(mod1_ORCI, strpos(mod1_ORCI,"(")+1 , 4)
gen mod1_uci = substr(mod1_ORCI, strpos(mod1_ORCI,"-")+2 , 4)

gen mod2_or  = substr(mod2_ORCI, 1, strpos(mod2_ORCI,"(")-1)
gen mod2_lci = substr(mod2_ORCI, strpos(mod2_ORCI,"(")+1 , 4)
gen mod2_uci = substr(mod2_ORCI, strpos(mod2_ORCI,"-")+2 , 4)

destring mod1_or  , replace
destring mod1_lci  , replace
destring mod1_uci  , replace

destring mod2_or  , replace
destring mod2_lci  , replace
destring mod2_uci  , replace

drop mod1_ORCI mod2_ORCI
save "$Datadir\MR analysis\_temp\MR1samp.dta", replace

keep outcome mod2* 
gen id = 2
rename mod2_* *
save "$Datadir\MR analysis\_temp\MR1samp_mod2.dta", replace

use "$Datadir\MR analysis\_temp\MR1samp.dta",  clear
keep outcome mod1* 
gen id = 1
rename mod1_* *
append using "$Datadir\MR analysis\_temp\MR1samp_mod2.dta"

save "$Datadir\MR analysis\_temp\MR1samp_fig_prepped.dta",  replace


********************************************************************************
* 3 Output figure of MR analyses 
********************************************************************************
set scheme s2mono
mkmat N or lci uci id, mat(dat) // turn dataset into a matrix

local i = 0 
forvalues val=1(1)5 {
	local i = `i'+1

	if `i' == 1 { 
		local out "Autism diagnosis"	// label to identify outcome 
		local tit "Autism" "diagnosis"	// label to print title (done separately to allow text wrapping for longer titles)		
	}
	if `i' == 2 { 
		local out "Social communication difficulties"
		local tit "Social" "communication" 
	}
	if `i' == 3 { 
		local out "Speech coherence"
		local tit "Speech" "coherence"
	}
	if `i' == 4 { 
		local out "Repetitive behaviour"
		local tit "Repetitive" "behaviour"
	}
	if `i' == 5 { 
		local out "Sociability"
		local tit "Sociability" "temperament"
	}
	
	disp `i' " - `out'"
	
	* values for model 1 (unadjusted)
	local n1   = dat[`i',1] // take value from matrix version of dataset
	local or1  = dat[`i',2]
	local lci1 = dat[`i',3]
	local uci1 = dat[`i',4]
	local or1s  = strofreal(`or1', "%5.2f") // create string version of value with correct format
	local lci1s = strofreal(`lci1', "%5.2f")
	local uci1s = strofreal(`uci1', "%5.2f")

	* values for model 2 (adjusted)
	local n2   = dat[`i'+5,1]
	local or2  = dat[`i'+5,2]
	local lci2 = dat[`i'+5,3]
	local uci2 = dat[`i'+5,4]
	local or2s  = strofreal(`or2', "%5.2f")
	local lci2s = strofreal(`lci2', "%5.2f")
	local uci2s = strofreal(`uci2', "%5.2f")


	
	if `i'==1{ // for first graph
		twoway (scatter or id, ms(o) mc(black)) (rcap lci uci id, lc(black))  ///
			if outcome == "`out'" , name(fig`i', replace) 	///
			yscale(log r(0.08 4)) ///
			ylabel(0.2 0.4 0.6 0.8 1 1.2 1.5 2 2.5 3,format(%03.1f) labsize(*0.8) nogrid) ///
			ytitle("Causal odds ratio (95% CI) per 10nmol/L increase in" "maternal 25(OH)D", size(small)) ///
			xscale(r(0.9 2.5)) ///
			xlab(1 `"Adjusted 1"' 2 `"Adjusted 2"', labsize(small) angle(45)) ///
			xtitle("") ///
			title("`tit'", size(small)) ///			
			legend(off) ///
			graphregion(color(white) margin(0 -2 1 1)) ///
			text(`or1' 1.3 "`or1s'", size(3)) text(`lci1' 1.3 "`lci1s'", size(3)) text(`uci1' 1.3 "`uci1s'", size(3)) ///
			text(`or2' 2.3 "`or2s'", size(3)) text(`lci2' 2.3 "`lci2s'", size(3)) text(`uci2' 2.3 "`uci2s'", size(3)) ///
			text(3.5 1.2 "{it:N} = `n1'", size(3)) text(3.5 2.2 "{it:N} = `n2'", size(3)) ///
			yline(1, lp(dash) lc(red)) ///
			fxsize(40) fysize(100)
	}
	
	if `i'>1{ // for all subsequent graphs (removes y axis)
		twoway (scatter or id, ms(o) mc(black)) (rcap lci uci id, lc(black))  ///
			if outcome == "`out'" , name(fig`i', replace) 	///
			yscale(log r(0.08 4) lstyle(none)) ///
			ylabel(, nogrid notick labcolor(white)) ///
			xscale(r(0.9 2.5)) ///
			xlab(1 `"Adjusted 1"' 2 `"Adjusted 2"', labsize(small) angle(45)) ///			
			xtitle("") ///			
			title("`tit'", size(small)) ///
			legend(off) ///
			graphregion(color(white) margin(0 -2 1 1)) ///
			text(`or1' 1.3 "`or1s'", size(3)) text(`lci1' 1.3 "`lci1s'", size(3)) text(`uci1' 1.3 "`uci1s'", size(3)) ///
			text(`or2' 2.3 "`or2s'", size(3)) text(`lci2' 2.3 "`lci2s'", size(3)) text(`uci2' 2.3 "`uci2s'", size(3)) ///
			text(3.5 1.15 "{it:N} = `n1'", size(3)) text(3.5 2.15 "{it:N} = `n2'", size(3)) ///
			yline(1, lp(dash) lc(red)) ///
			fxsize(40) fysize(100)
	}	
}  
    

* Combine the chunks
graph combine fig1 fig2 fig3 fig4 fig5, row(1) ///
	graphregion(color(white)) ///
	name("fig_MR", replace) 

* Save figure as .tif in graphfiles
graph export fig_MR.tif, name(fig_MR) replace
graph export fig_MR.pdf, name(fig_MR) replace
	
********************************************************************************
log close
	

	   
