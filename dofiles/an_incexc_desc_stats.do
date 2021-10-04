log using "$Logdir\LOG_an_incexc_desc_stats.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2021-0-23
* Description: Descriptive statistics of included vs excluded participants
********************************************************************************
* Contents
************
* 1 Create environment
* 2 Descriptives tables for seasonally adjusted scores
* 3 Descriptives for normally distributed variables
* create formats in each dataset

********************************************************************************
* 1 create environment and load data
*************************************
cd "$Datadir\Inclusion descriptives"
use "$Datadir\DERIVED_VitD_dat.dta", clear


********************************************************************************
* 2 Descriptives tables for seasonally adjusted scores
*******************************************************
capture postutil close 
tempname memhold 

postfile `memhold' str20 stat statlev tabord ///
				   Excluded Excbrack ///
				   Included Incbrack ///
				   OR LCI UCI ///
				   using "Desc_incexc_cat.dta", replace

tab flag_inclusion, matcell(matInctot)

local stat	 	 = "Total"
local statlev	 = .
local tabord     = 0
local Excluded 	 = matInctot[1,1]
local Excbrack = .
local Included 	 = matInctot[2,1]
local Incbrack = .
local OR 		 = .
local LCI 		 = . 
local UCI 		 = . 


post `memhold' ("`stat'") (`statlev') (`tabord') ///
			   (`Excluded') (`Excbrack') ///
			   (`Included') (`Incbrack') ///
			   (`OR') (`LCI') (`UCI')

foreach stat in male parity_cat mat_smok_bin18wk  matEdDrv finDifDrv manual ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability {
	tab `stat', mis matcell(matcountTotal)
	local nlevs = r(r)

	tab `stat' flag_inclusion, mis matcell(matcount) matrow(statlevs)
	
	local tabord = `tabord' + 1

	forvalues lev = 1(1)`nlevs' {
		disp `lev'
		local statlev = statlevs[`lev',1]
		
		local Total		 = matcountTotal[`lev',1] 
		local Totalbrack = 100*matcountTotal[`lev',1] /_N
		
		local Excluded 	 = matcount[`lev',1]
		local Excbrack	 = 100*matcount[`lev',1]/matInctot[1,1]
		local Included 	 = matcount[`lev',2]
		local Incbrack 	 = 100*matcount[`lev',2]/matInctot[2,1]
		
		logistic flag_inclusion i.`stat'
		local OR     = exp(e(b)[1,`lev']) 
		local LCI 	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev']))
		local UCI 	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev']))

	
		post `memhold' ("`stat'") (`statlev') (`tabord') ///
					   (`Excluded') (`Excbrack') ///
					   (`Included') (`Incbrack') ///
					   (`OR') (`LCI') (`UCI')
	

	}
}

postclose `memhold'


********************************************************************************
* 4 Descriptives for normally distributed variables 
*****************************************************
capture postutil close 
tempname memhold 

local tabord = 11 // update if number of categorical variables increases

postfile `memhold' str25 stat statlev tabord ///
				   Excluded Excbrack ///
				   Included Incbrack ///
				   OR LCI UCI ///
				   using "Desc_incexc_cont.dta", replace

foreach stat in matage prepregBMI sadj_vitd_10 zscore_vd_mom_prs_S13  zscore_vd_child_prs_S13  zmf_asd {
	local tabord = `tabord' + 1
	local statlev = 1
	
	summarize `stat' if flag_inclusion==0
	local Excluded		 = r(mean)
	local Excbrack 		 = r(sd)	
		
	summarize `stat' if flag_inclusion==1
	local Included 		 = r(mean)
	local Incbrack   	 = r(sd)	
	
	logistic flag_inclusion `stat'
	local OR    	 = exp(e(b)[1,1]) 
	local LCI 	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1]))
	local UCI 	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1]))	
	
	
	
	post `memhold' ("`stat'") (`statlev') (`tabord') ///
				   (`Excluded') (`Excbrack') ///
				   (`Included') (`Incbrack') ///
				   (`OR') (`LCI') (`UCI')
	
}

postclose `memhold'


********************************************************************************
* create formats in each dataset
**********************************
use "Desc_incexc_cat.dta", clear
append  using "Desc_incexc_cont.dta"
do "$Dodir\an_desc_formats.do"


tostring Excluded, gen(Excluded_c) force
tostring Excluded, gen(Excluded_c_cont) format(%5.2f) force
replace  Excluded_c=Excluded_c_cont if tabord > 11 // update #11 if number of variables changes
tostring Excbrack, gen(Excbrack_c) format(%5.2f) force

tostring Included, gen(Included_c) force
tostring Included, gen(Included_c_cont) format(%5.2f) force
replace  Included_c=Included_c_cont if tabord > 11 // update #11 if number of variables changes
tostring Incbrack, gen(Incbrack_c) format(%5.2f) force


gen outExcluded = Excluded_c if _n == 1
replace outExcluded = Excluded_c + " (" + Excbrack_c + ")" if _n>1

gen outIncluded = Included_c if _n == 1
replace outIncluded = Included_c + " (" + Incbrack_c + ")" if _n>1


gen ORCI  = strofreal(OR, "%5.2f") + " (" + strofreal(LCI, "%5.2f") + "-" + strofreal(UCI, "%5.2f") + ")" if _n>1 & OR != 1
replace ORCI = "Ref" if _n>1 & ORCI == ""


keep stat_c statlev_c out* *ORCI 
rename out* * 
order stat* Excluded Included ORCI
export delim using "IncExc_data_desc.csv", delim(",") replace

log close

