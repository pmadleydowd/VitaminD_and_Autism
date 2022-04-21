capture log close
log using "$Logdir\LOG_an_missingdata_desc_stats.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2021-07-23
* Description: Descriptive statistics of missing data for ALSPAC vitamin D data
********************************************************************************
* Contents
************
* 1 Create environment
* 2 Create missing data descriptive statistics using table1_mc package 
* 3 Create ORs for inclusion
* create formats in each dataset

********************************************************************************
* 1 create environment and load data
*************************************
* load required packages
* ssc install table1_mc


* Load data
cd "$Datadir\Missing data"
use "$Datadir\DERIVED_VitD_dat.dta", clear

keep if flag_inclusion 		== 1



********************************************************************************
* 2 - Create missing data descriptive statistics using table1_mc package 
********************************************************************************
foreach outc in asd scdc soci repb cohe fm {
	table1_mc,  by(flag_cca_`outc') ///
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
				nospace onecol missing total(before) ///
				saving("$Datadir\Missing data\Misdesc_`outc'.xlsx", replace)
}					 



********************************************************************************
* 3 Create ORs for inclusion
*******************************************************
capture postutil close 
tempname memhold 

postfile `memhold' str20 stat statlev ///
				   asdOR asdLCI asdUCI ///
				   scdcOR scdcLCI scdcUCI ///
				   coheOR coheLCI coheUCI ///
				   repbOR repbLCI repbUCI ///
				   sociOR sociLCI sociUCI ///
   				   fmOR   fmLCI   fmUCI ///
				   using "Missdat_ORs.dta", replace


foreach stat in "male" "parity_cat" "mat_smok_bin18wk" "matEdDrv" "finDifDrv" "manual" "matage" "prepregBMI" "sa_7wk_VitDtot_10" "sa_20wk_VitDtot_10" "sa_34wk_VitDtot_10"  "zscore_vd_mom_prs" "zscore_vd_child_prs" "ASD" "bin_scdc" "bin_coherence" "bin_repbehaviour" "bin_sociability" "zmf_asd" "homeowner" "marital" {
	disp "stat = `stat'"	
		
	if "`stat'" == "male" | "`stat'" == "parity_cat" | "`stat'" == "mat_smok_bin18wk" | "`stat'" == "matEdDrv" | "`stat'" == "finDifDrv" | "`stat'" == "manual" | "`stat'" == "ASD" | "`stat'" == "bin_scdc" | "`stat'" == "bin_coherence" | "`stat'" == "bin_repbehaviour" | "`stat'" == "bin_sociability" | "`stat'" == "homeowner" | "`stat'" == "marital" {
		tab `stat', matcell(matcountTotal)
		local nlevs = r(r)
		tab `stat' flag_cca_asd,  matcell(matcountasd) matrow(statlevs)

		logistic flag_cca_asd i.`stat'
		est store A
		logistic flag_cca_scdc i.`stat'
		est store B
		logistic flag_cca_cohe i.`stat'
		est store C
		logistic flag_cca_repb i.`stat'
		est store D
		logistic flag_cca_soci i.`stat'
		est store E
		logistic flag_cca_fm i.`stat'
		est store F	
		

		forvalues lev = 1(1)`nlevs' {
			disp `lev'
			local statlev = statlevs[`lev',1]
			
			est restore A
			local asdOR    	 = exp(e(b)[1,`lev']) 
			local asdLCI 	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev']))
			local asdUCI 	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev']))

			est restore B
			local scdcOR 	 = exp(e(b)[1,`lev'])  
			local scdcLCI 	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev']))
			local scdcUCI 	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev']))

			est restore C
			local coheOR     = exp(e(b)[1,`lev'])  
			local coheLCI    = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
			local coheUCI    = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 

			est restore D	
			local repbOR 	 = exp(e(b)[1,`lev'])  
			local repbLCI  	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
			local repbUCI  	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 

			est restore E		
			local sociOR	 = exp(e(b)[1,`lev'])  
			local sociLCI 	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
			local sociUCI 	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
			
			est restore F		
			local fmOR	     = exp(e(b)[1,`lev'])  
			local fmLCI 	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
			local fmUCI 	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
			
			post `memhold' ("`stat'") (`statlev') ///
						   (`asdOR')  (`asdLCI')  (`asdUCI')  ///
						   (`scdcOR') (`scdcLCI') (`scdcUCI') ///
						   (`coheOR') (`coheLCI') (`coheUCI') ///
						   (`repbOR') (`repbLCI') (`repbUCI') ///
						   (`sociOR') (`sociLCI') (`sociUCI') ///	
						   (`fmOR')   (`fmLCI')   (`fmUCI')

		}
	}
	else if "`stat'" == "matage" | "`stat'" == "prepregBMI" | "`stat'" == "sa_7wk_VitDtot_10" | "`stat'" == "sa_20wk_VitDtot_10" | "`stat'" == "sa_34wk_VitDtot_10" | "`stat'" == "zscore_vd_mom_prs" | "`stat'" == "zscore_vd_child_prs" | "`stat'" == "zmf_asd"  {
		
		logistic flag_cca_asd `stat'
		est store A
		logistic flag_cca_scdc `stat'
		est store B
		logistic flag_cca_cohe `stat'
		est store C
		logistic flag_cca_repb `stat'
		est store D
		logistic flag_cca_soci `stat'
		est store E
		logistic flag_cca_fm `stat'
		est store F	

		est restore A
		local asdOR    	 = exp(e(b)[1,1]) 
		local asdLCI 	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1]))
		local asdUCI 	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1]))

		est restore B
		local scdcOR 	 = exp(e(b)[1,1])  
		local scdcLCI 	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1]))
		local scdcUCI 	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1]))

		est restore C
		local coheOR     = exp(e(b)[1,1])  
		local coheLCI    = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1])) 
		local coheUCI    = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1])) 

		est restore D	
		local repbOR 	 = exp(e(b)[1,1])  
		local repbLCI  	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1])) 
		local repbUCI  	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1])) 

		est restore E		
		local sociOR	 = exp(e(b)[1,1])  
		local sociLCI 	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1])) 
		local sociUCI 	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1])) 
		
		est restore F		
		local fmOR	     = exp(e(b)[1,1])  
		local fmLCI 	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1])) 
		local fmUCI 	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1])) 		
		
		
		post `memhold' ("`stat'") (0) ///
			   (`asdOR')  (`asdLCI')  (`asdUCI')  ///
			   (`scdcOR') (`scdcLCI') (`scdcUCI') ///
			   (`coheOR') (`coheLCI') (`coheUCI') ///
			   (`repbOR') (`repbLCI') (`repbUCI') ///
			   (`sociOR') (`sociLCI') (`sociUCI') ///	
			   (`fmOR')   (`fmLCI')   (`fmUCI')	
		
	}
}

postclose `memhold'



********************************************************************************
* create formats in each dataset
**********************************
use "Missdat_ORs.dta", clear

gen asdORCI  = strofreal(asdOR, "%5.2f") + " (" + strofreal(asdLCI, "%5.2f") + "-" + strofreal(asdUCI, "%5.2f") + ")" if asdOR != 1
replace asdORCI = "Ref" if asdORCI == ""

gen scdcORCI = strofreal(scdcOR, "%5.2f") + " (" + strofreal(scdcLCI, "%5.2f") + "-" + strofreal(scdcUCI, "%5.2f") + ")" if scdcOR != 1
replace scdcORCI = "Ref" if scdcORCI == ""

gen coheORCI = strofreal(coheOR, "%5.2f") + " (" + strofreal(coheLCI, "%5.2f") + "-" + strofreal(coheUCI, "%5.2f") + ")" if coheOR != 1
replace coheORCI = "Ref" if coheORCI == ""

gen repbORCI = strofreal(repbOR, "%5.2f") + " (" + strofreal(repbLCI, "%5.2f") + "-" + strofreal(repbUCI, "%5.2f") + ")" if repbOR != 1
replace repbORCI = "Ref" if repbORCI == ""

gen sociORCI = strofreal(sociOR, "%5.2f") + " (" + strofreal(sociLCI, "%5.2f") + "-" + strofreal(sociUCI, "%5.2f") + ")" if sociOR != 1
replace sociORCI = "Ref" if sociORCI == ""

gen fmORCI = strofreal(fmOR, "%5.2f") + " (" + strofreal(fmLCI, "%5.2f") + "-" + strofreal(fmUCI, "%5.2f") + ")" if fmOR != 1
replace fmORCI = "Ref" if fmORCI == ""

keep stat statlev *ORCI 
export delim using "Missing_data_ORs.csv", delim(",") replace

log close

