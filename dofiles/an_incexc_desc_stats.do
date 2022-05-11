capture log close
log using "$Logdir\LOG_an_incexc_desc_stats.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2021-0-23
* Description: Descriptive statistics of included vs excluded participants
********************************************************************************
* Contents
************
* 1 Create environment
* 2 Create inclusion descriptive statistics using table1_mc package 
* 3 Create ORs for inclusion
* create formats in each dataset

********************************************************************************
* 1 create environment and load data
*************************************
cd "$Datadir\Inclusion descriptives"
use "$Datadir\DERIVED_VitD_dat.dta", clear


********************************************************************************
* 2 Descriptives tables for seasonally adjusted scores
*******************************************************
table1_mc,  by(flag_inclusion) ///
				vars( /// 
					 male bin %5.1f \ ///
					 parity_cat cat %5.1f \ ///
					 mat_smok_bin18wk bin %5.1f \ ///
					 matEdDrv cat %5.1f \ ///
					 finDifDrv bin %5.1f \ ///
					 manual bin %5.1f \ ///
					 matage contn %5.1f \ /// 
					 prepregBMI contn %5.1f \ /// 
					 sa_7wk_VitDtot_preg contn %5.1f \ /// 
					 sa_20wk_VitDtot_preg contn %5.1f \ /// 
					 sa_34wk_VitDtot_preg contn %5.1f \ /// 
					 zscore_vd_mom_prs contn %5.1f \ /// 
					 zscore_vd_child_prs contn %5.1f \ /// 
					 ASD bin %5.1f \ ///
					 bin_scdc bin %5.1f \ ///
					 bin_coherence bin %5.1f \ ///
					 bin_repbehaviour bin %5.1f \ ///
					 bin_sociability bin %5.1f \ ///
					 zmf_asd contn %5.1f \ /// 
					 homeowner cat %5.1f \ /// \ /// 
					 marital cat %5.1f \ /// 
					) ///
				nospace onecol missing total(before) test ///
				saving("Desc_incexc.xlsx", replace)
					 

********************************************************************************
* 3 Create ORs for inclusion
*******************************************************
capture postutil close 
tempname memhold 

postfile `memhold' str20 stat statlev ///
				   incOR incLCI incUCI ///
				   using "Desc_incexc_ORs.dta", replace


foreach stat in "male" "parity_cat" "mat_smok_bin18wk" "matEdDrv" "finDifDrv" "manual" "matage" "prepregBMI" "sa_7wk_VitDtot_10" "sa_20wk_VitDtot_10" "sa_34wk_VitDtot_10"  "zscore_vd_mom_prs" "zscore_vd_child_prs" "ASD" "bin_scdc" "bin_coherence" "bin_repbehaviour" "bin_sociability" "zmf_asd" "homeowner" "marital" {
	disp "stat = `stat'"	
		
	if "`stat'" == "male" | "`stat'" == "parity_cat" | "`stat'" == "mat_smok_bin18wk" | "`stat'" == "matEdDrv" | "`stat'" == "finDifDrv" | "`stat'" == "manual" | "`stat'" == "ASD" | "`stat'" == "bin_scdc" | "`stat'" == "bin_coherence" | "`stat'" == "bin_repbehaviour" | "`stat'" == "bin_sociability" | "`stat'" == "homeowner" | "`stat'" == "marital" {
		tab `stat', matcell(matcountTotal)
		local nlevs = r(r)
		tab `stat' flag_cca_asd,  matcell(matcountasd) matrow(statlevs)

		logistic flag_cca_asd i.`stat'		

		forvalues lev = 1(1)`nlevs' {
			disp `lev'
			local statlev = statlevs[`lev',1]
			
			local incOR    	 = exp(e(b)[1,`lev']) 
			local incLCI 	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev']))
			local incUCI 	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev']))

			
			post `memhold' ("`stat'") (`statlev') ///
						   (`incOR')  (`incLCI')  (`incUCI')  

		}
	}
	else if "`stat'" == "matage" | "`stat'" == "prepregBMI" | "`stat'" == "sa_7wk_VitDtot_10" | "`stat'" == "sa_20wk_VitDtot_10" | "`stat'" == "sa_34wk_VitDtot_10" | "`stat'" == "zscore_vd_mom_prs" | "`stat'" == "zscore_vd_child_prs" | "`stat'" == "zmf_asd"  {
		
		logistic flag_cca_asd `stat'
		local incOR    	 = exp(e(b)[1,1]) 
		local incLCI 	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1]))
		local incUCI 	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1]))

		
		
			post `memhold' ("`stat'") (0) ///
						   (`incOR')  (`incLCI')  (`incUCI')  
		
	}
}

postclose `memhold'





********************************************************************************
* create formats in each dataset
**********************************
use "Desc_incexc_ORs.dta", clear

gen incORCI  = strofreal(incOR, "%5.2f") + " (" + strofreal(incLCI, "%5.2f") + "-" + strofreal(incUCI, "%5.2f") + ")" if incOR != 1
replace incORCI = "Ref" if incORCI == ""

keep stat statlev *ORCI 
export delim using "Desc_incexc_ORs.csv", delim(",") replace


log close

