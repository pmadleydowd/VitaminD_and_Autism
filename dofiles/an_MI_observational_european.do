log using "$Logdir\LOG_an_MI_observational_european.txt", text replace
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		04 November 2021
* Description: 	Vit D and Autism project observational analysis using multiple imputation among those with european ancestry
********************************************************************************
* Contents
* 1 Set up environment and read in data
* 2 Create imputed datasets
* 3 Perform logistic regression observational analyses
* 4 Perform linear regression observational analyses
* 5 Prepare models for output

********************************************************************************
* 1 Set up environment and read in data
*******************************************************************************
cd "$Datadir\Observational analysis"
use "$Datadir\DERIVED_VitD_dat.dta", clear

keep if flag_inclusion 		== 1
keep if flag_mPRS_avail		== 1 // all those with available PRS information are of european ancestry 



********************************************************************************
* 3 Create imputed datasets
********************************************************************************
mi set wide
mi register imputed ASD bin_scdc bin_coh bin_repbehaviour bin_sociability zmf_asd parity_cat mat_smok_bin18wk matEdDrv finDifDrv manual prepregBMI matage 
mi register regular sa_7wk_VitDtot_10 sa_20wk_VitDtot_10 sa_34wk_VitDtot_10 male 

mi impute chained (regress) zmf_asd prepregBMI matage ///
				  (logit) ASD bin_scdc bin_coh bin_repbehaviour bin_sociability mat_smok_bin18wk finDifDrv manual ///
				  (ologit) parity_cat ///
				  (mlogit) matEdDrv  /// 
				  = sa_7wk_VitDtot_10 sa_20wk_VitDtot_10 sa_34wk_VitDtot_10 male  ///
				  , add(100) rseed(484286) dots 


save "$Datadir\Observational analysis\Imputed_data_european.dta", replace
	
********************************************************************************
* 3 Perform logistic regression observational analyses
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' _outord _modelord str20 exposure str10 outcome str50 model str10 OR str20 OR_CI  ///
	using "$Datadir\Observational analysis\MI_Obs_output_logistic_european.dta", replace

foreach exposure in sa_7wk_VitDtot_10 sa_20wk_VitDtot_10 sa_34wk_VitDtot_10 { 	
	local i = 0
	foreach outcome in ASD bin_scdc bin_coh bin_repbehaviour bin_sociability {
		local i = `i' + 1
		
		mi estimate: logistic `outcome' `exposure' 
		post `memhold' (`i') (1) ("`exposure'") ("`outcome'") ("Unadjusted") ///
			(strofreal(exp(r(table)[1,1]), "%5.2f")) ///
			("(" + strofreal(exp(r(table)[5,1]),"%5.2f") + " - " + strofreal(exp(r(table)[6,1]),"%5.2f") + ")") 		

		mi estimate: logistic `outcome' `exposure' i.male 
		post `memhold' (`i') (2) ("`exposure'") ("`outcome'") ("Adjusted 1") ///
			(strofreal(exp(r(table)[1,1]), "%5.2f")) ///
			("(" + strofreal(exp(r(table)[5,1]),"%5.2f") + " - " + strofreal(exp(r(table)[6,1]),"%5.2f") + ")") 		

		mi estimate: logistic `outcome' `exposure' i.matEdDrv i.finDifDrv i.manual  
		post `memhold' (`i') (3) ("`exposure'") ("`outcome'") ("Adjusted 2") ///
			(strofreal(exp(r(table)[1,1]), "%5.2f")) ///
			("(" + strofreal(exp(r(table)[5,1]),"%5.2f") + " - " + strofreal(exp(r(table)[6,1]),"%5.2f") + ")") 

		mi estimate: logistic `outcome' `exposure'  prepregBMI matage i.mat_smok_bin18wk i.parity_cat
		post `memhold' (`i') (4) ("`exposure'") ("`outcome'") ("Adjusted 3") ///
			(strofreal(exp(r(table)[1,1]), "%5.2f")) ///
			("(" + strofreal(exp(r(table)[5,1]),"%5.2f") + " - " + strofreal(exp(r(table)[6,1]),"%5.2f") + ")") 
		
		mi estimate: logistic `outcome' `exposure' i.male i.matEdDrv i.finDifDrv i.manual prepregBMI matage i.mat_smok_bin18wk i.parity_cat 
		post `memhold' (`i') (5) ("`exposure'") ("`outcome'") ("Fully adjusted") ///
			(strofreal(exp(r(table)[1,1]), "%5.2f")) ///
			("(" + strofreal(exp(r(table)[5,1]),"%5.2f") + " - " + strofreal(exp(r(table)[6,1]),"%5.2f") + ")") 
	}
}
	
postclose `memhold'

	

********************************************************************************
* 4 Perform linear regression observational analyses
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' _modelord str20 exposure str10 outcome str50 model str10 meandiff str20 CI  ///
	using "$Datadir\Observational analysis\MI_Obs_output_linear_european.dta", replace

foreach exposure in sa_7wk_VitDtot_10 sa_20wk_VitDtot_10 sa_34wk_VitDtot_10 { 	
	
	mi estimate: regress zmf_asd `exposure' 
	post `memhold' (1) ("`exposure'") ("`outcome'") ("Unadjusted") ///
		(strofreal(r(table)[1,1], "%5.2f")) ///
		("(" + strofreal(r(table)[5,1],"%5.2f") + " - " + strofreal(r(table)[6,1],"%5.2f") + ")") 		

	mi estimate: regress zmf_asd `exposure' i.male 
	post `memhold' (2) ("`exposure'") ("`outcome'") ("Adjusted 1") ///
		(strofreal(r(table)[1,1], "%5.2f")) ///
		("(" + strofreal(r(table)[5,1],"%5.2f") + " - " + strofreal(r(table)[6,1],"%5.2f") + ")") 		

	mi estimate: regress zmf_asd `exposure' i.matEdDrv i.finDifDrv i.manual  
	post `memhold' (3) ("`exposure'") ("`outcome'") ("Adjusted 2") ///
		(strofreal(r(table)[1,1], "%5.2f")) ///
		("(" + strofreal(r(table)[5,1],"%5.2f") + " - " + strofreal(r(table)[6,1],"%5.2f") + ")") 

	mi estimate: regress zmf_asd `exposure'  prepregBMI matage i.mat_smok_bin18wk i.parity_cat
	post `memhold' (4) ("`exposure'") ("`outcome'") ("Adjusted 3") ///
		(strofreal(r(table)[1,1], "%5.2f")) ///
		("(" + strofreal(r(table)[5,1],"%5.2f") + " - " + strofreal(r(table)[6,1],"%5.2f") + ")") 

	mi estimate: regress zmf_asd `exposure' i.male i.matEdDrv i.finDifDrv i.manual prepregBMI matage i.mat_smok_bin18wk i.parity_cat 
	post `memhold' (5) ("`exposure'") ("`outcome'") ("Fully adjusted") ///
		(strofreal(r(table)[1,1], "%5.2f")) ///
		("(" + strofreal(r(table)[5,1],"%5.2f") + " - " + strofreal(r(table)[6,1],"%5.2f") + ")") 
}		
postclose `memhold'


********************************************************************************
* 5 Prepare models for output
********************************************************************************
use "$Datadir\Observational analysis\MI_Obs_output_logistic_european.dta", clear
export delim using "$Datadir\Observational analysis\MI_Observational_out_logistic_european.csv", delim(",") replace


use "$Datadir\Observational analysis\MI_Obs_output_linear_european.dta", clear
export delim using "$Datadir\Observational analysis\MI_Observational_out_linear_european.csv", delim(",") replace




********************************************************************************
* close log
********************************************************************************
log close



