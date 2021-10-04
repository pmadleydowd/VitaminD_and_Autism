log using "$Logdir\LOG_an_desc_PRS_conf.txt", text replace
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		02 August 2021
* Description: 	Descriptive statistics of association of each confounder with PRS 
********************************************************************************
* Contents
* 1 Set up environment and read in data
* 2 Assess association between risk score and categorical confounders 
* 3 Assess association between risk score and exposure/continuous confounders 
* 4 Format and prepare for output 
********************************************************************************
* 1 Set up environment and read in data
*******************************************************************************
cd "$Datadir\MR_sensitivity"
use "$Datadir\DERIVED_VitD_dat.dta", clear

keep if flag_mat_white_eth 	== 1
keep if flag_alive1yr 		== 1
keep if flag_singleton		== 1
keep if flag_outcomeany 	== 1
keep if miss_exposure		== 0 


			
			
********************************************************************************
* 2 Assess association between risk score and categorical confounders 
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' str20 stat statlev tabord ///
				   Diff LCI UCI R2 ///
				   using "Desc_PRS_conf_cat.dta", replace



foreach stat in male parity_cat mat_smok_bin18wk  matEdDrv finDifDrv manual  {
	tab `stat',  matrow(statlevs)
	local nlevs = r(r)
	local tabord = `tabord' + 1

	regress zscore_vd_mom_prs_S13 i.`stat'

	forvalues lev = 1(1)`nlevs' {
		disp `lev'
		local statlev = statlevs[`lev',1]

		local Diff   = e(b)[1,`lev'] 
		local LCI 	 = e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev'])
		local UCI 	 = e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev'])
		local R2 	 = e(r2)
	
		
		post `memhold' ("`stat'") (`statlev') (`tabord') ///
					   (`Diff')   (`LCI')   (`UCI') (`R2')

	}
}

postclose `memhold'

********************************************************************************
* 3 Assess association between risk score and exposure/continuous confounders 
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' str20 stat statlev tabord ///
				   Diff LCI UCI R2 ///
				   using "Desc_PRS_conf_cont.dta", replace



foreach stat in  matage prepregBMI {
	local tabord = `tabord' + 1
	local statlev = 1

	regress zscore_vd_mom_prs_S13 `stat'

	local Diff   = e(b)[1,1] 
	local LCI 	 = e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1])
	local UCI 	 = e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1])
	local R2 	 = e(r2)

	
	post `memhold' ("`stat'") (`statlev') (`tabord') ///
				   (`Diff')   (`LCI')   (`UCI') (`R2')

}

postclose `memhold'


********************************************************************************
* 4 Format and prepare for output 
********************************************************************************
use "Desc_PRS_conf_cat.dta", clear
append using "Desc_PRS_conf_cont.dta"
do "$Dodir/an_desc_formats.do"  

* remove N(%)/mean (SD)
gen pos = strpos(stat_c, ",")
replace stat_c = substr(stat_c, 1, pos-1)


* create mean difference variable
gen out_DiffCI = strofreal(Diff, "%5.2f") + " (" + strofreal(LCI, "%5.2f") + " - " + strofreal(UCI, "%5.2f") + ")"
replace out_DiffCI = "Ref" if Diff == 0

* create R2 variable
gen out_R2 = strofreal(R2, "%5.3f")
bysort tabord: egen seq=seq()
replace out_R2 = "" if seq!=1
replace out_R2 = "<0.001" if out_R2 == "0.000"

keep stat_c statlev_c out*  
rename out_* * 
export delim using "PRS_conf_desc.csv", delim(",") replace




log close	
				
