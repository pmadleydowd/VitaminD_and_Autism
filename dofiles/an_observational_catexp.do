log using "$Logdir\LOG_an_observational_catexp.txt", text replace
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		12 November 2021
* Description: 	Vit D and Autism project observational analysis using a categorical exposure definition 
********************************************************************************
* Contents
* 1 Complete case analysis 
* 	1.1 - in binary outcomes
* 	1.2 - in continuous outcomes
* 2 Multiple imputation analysis 
* 	2.1 - in binary outcomes
* 	2.2 - in continuous outcomes
* 3 Prepare models for output


********************************************************************************
* 1 Complete case analysis 
********************************************************************************
cd "$Datadir\Catexp Observational analysis"
use "$Datadir\DERIVED_VitD_dat.dta", clear

keep if flag_inclusion == 1

* 1.1 - in binary outcomes
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' _outord _modelord str20 exposure str10 outcome str20 model str20 coef str10 OR str20 OR_CI  ///
	using "Catexp_cca_obs_output_logistic.dta", replace

foreach exposure in sa_7wk_VitD_Cat sa_20wk_VitD_Cat sa_34wk_VitD_Cat { 
	local i = 0
	foreach outcome in ASD bin_scdc bin_coh bin_repbehaviour bin_sociability {
		local i = `i' + 1
		
		logistic `outcome' ib3.`exposure' if miss_confounder == 0 
		matrix list r(table)
		disp r(table)[1,1] , r(table)[5,1] , r(table)[6,1] 
		
		post `memhold' (`i') (1) ("`exposure'") ("`outcome'") ("Unadjusted") ("Deficient") ///
			(strofreal(r(table)[1,1], "%5.2f")) ///
			("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 		
		post `memhold' (`i') (2) ("`exposure'") ("`outcome'") ("Unadjusted") ("Insufficient") ///
			(strofreal(r(table)[1,2], "%5.2f")) ///
			("(" + strofreal(r(table)[5,2],"%5.2f") + "-" + strofreal(r(table)[6,2],"%5.2f") + ")") 		


		
		logistic `outcome' ib3.`exposure' i.male i.matEdDrv i.finDifDrv i.manual prepregBMI matage i.mat_smok_bin18wk i.parity_cat if miss_confounder == 0 
		matrix list r(table)

		post `memhold' (`i') (3) ("`exposure'") ("`outcome'") ("Fully adjusted") ("Deficient") ///
			(strofreal(r(table)[1,1], "%5.2f")) ///
			("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 
		post `memhold' (`i') (4) ("`exposure'") ("`outcome'") ("Fully adjusted") ("Insufficient") ///
			(strofreal(r(table)[1,2], "%5.2f")) ///
			("(" + strofreal(r(table)[5,2],"%5.2f") + "-" + strofreal(r(table)[6,2],"%5.2f") + ")") 
	}
}

	
postclose `memhold'


* 1.2 - in continuous outcomes
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' _outord _modelord str20 exposure str10 outcome str20 model str20 coef str10 MD str20 MD_CI  ///
	using "Catexp_cca_obs_output_linear.dta", replace

foreach exposure in sa_7wk_VitD_Cat sa_20wk_VitD_Cat sa_34wk_VitD_Cat { 
	local i = 0
	foreach outcome in zmf_asd {
		local i = `i' + 1
		
		regress `outcome' ib3.`exposure' if miss_confounder == 0 
		matrix list r(table)
		
		post `memhold' (`i') (1) ("`exposure'") ("`outcome'") ("Unadjusted") ("Deficient") ///
			(strofreal(r(table)[1,1], "%5.2f")) ///
			("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 		
		post `memhold' (`i') (2) ("`exposure'") ("`outcome'") ("Unadjusted") ("Insufficient") ///
			(strofreal(r(table)[1,2], "%5.2f")) ///
			("(" + strofreal(r(table)[5,2],"%5.2f") + "-" + strofreal(r(table)[6,2],"%5.2f") + ")") 		


		
		regress `outcome' ib3.`exposure' i.male i.matEdDrv i.finDifDrv i.manual prepregBMI matage i.mat_smok_bin18wk i.parity_cat if miss_confounder == 0 
		matrix list r(table)
		
		post `memhold' (`i') (3) ("`exposure'") ("`outcome'") ("Fully adjusted") ("Deficient") ///
			(strofreal(r(table)[1,1], "%5.2f")) ///
			("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 
		post `memhold' (`i') (4) ("`exposure'") ("`outcome'") ("Fully adjusted") ("Insufficient") ///
			(strofreal(r(table)[1,2], "%5.2f")) ///
			("(" + strofreal(r(table)[5,2],"%5.2f") + "-" + strofreal(r(table)[6,2],"%5.2f") + ")") 
	}
}
	
postclose `memhold'




********************************************************************************
* 2 Multiple imputation analysis in binary outcomes
********************************************************************************
use "$Datadir\Observational analysis\Imputed_data.dta", clear


* 2.1 - in binary outcomes
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' _outord _modelord str20 exposure str10 outcome str20 model str20 coef str10 OR str20 OR_CI  ///
	using "Catexp_MI_obs_output_logistic.dta", replace

foreach exposure in sa_7wk_VitD_Cat sa_20wk_VitD_Cat sa_34wk_VitD_Cat { 
	local i = 0
	foreach outcome in ASD bin_scdc bin_coh bin_repbehaviour bin_sociability {
		local i = `i' + 1
		
		mi estimate: logistic `outcome' ib3.`exposure' 
		matrix list r(table)
		
		post `memhold' (`i') (1) ("`exposure'") ("`outcome'") ("Unadjusted") ("Deficient") ///
			(strofreal(exp(r(table)[1,1]), "%5.2f")) ///
			("(" + strofreal(exp(r(table)[5,1]),"%5.2f") + "-" + strofreal(exp(r(table)[6,1]),"%5.2f") + ")") 		
		post `memhold' (`i') (2) ("`exposure'") ("`outcome'") ("Unadjusted") ("Insufficient") ///
			(strofreal(exp(r(table)[1,2]), "%5.2f")) ///
			("(" + strofreal(exp(r(table)[5,2]),"%5.2f") + "-" + strofreal(exp(r(table)[6,2]),"%5.2f") + ")") 		


		
		mi estimate: logistic `outcome' ib3.`exposure' i.male i.matEdDrv i.finDifDrv i.manual prepregBMI matage i.mat_smok_bin18wk i.parity_cat 
		matrix list r(table)

		post `memhold' (`i') (3) ("`exposure'") ("`outcome'") ("Fully adjusted") ("Deficient") ///
			(strofreal(exp(r(table)[1,1]), "%5.2f")) ///
			("(" + strofreal(exp(r(table)[5,1]),"%5.2f") + "-" + strofreal(exp(r(table)[6,1]),"%5.2f") + ")") 
		post `memhold' (`i') (4) ("`exposure'") ("`outcome'") ("Fully adjusted") ("Insufficient") ///
			(strofreal(exp(r(table)[1,2]), "%5.2f")) ///
			("(" + strofreal(exp(r(table)[5,2]),"%5.2f") + "-" + strofreal(exp(r(table)[6,2]),"%5.2f") + ")") 
	}
}
	
postclose `memhold'


* 2.2 - in continuous outcomes
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' _outord _modelord str20 exposure str10 outcome str20 model str20 coef str10 MD str20 MD_CI  ///
	using "Catexp_MI_obs_output_linear.dta", replace

foreach exposure in sa_7wk_VitD_Cat sa_20wk_VitD_Cat sa_34wk_VitD_Cat { 
	local i = 0
	foreach outcome in zmf_asd {
		local i = `i' + 1
		
		mi estimate: regress `outcome' ib3.`exposure' 
		matrix list r(table)
		disp r(table)[1,1] , r(table)[5,1] , r(table)[6,1] 
		
		post `memhold' (`i') (1) ("`exposure'") ("`outcome'") ("Unadjusted") ("Deficient") ///
			(strofreal(r(table)[1,1], "%5.2f")) ///
			("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 		
		post `memhold' (`i') (2) ("`exposure'") ("`outcome'") ("Unadjusted") ("Insufficient") ///
			(strofreal(r(table)[1,2], "%5.2f")) ///
			("(" + strofreal(r(table)[5,2],"%5.2f") + "-" + strofreal(r(table)[6,2],"%5.2f") + ")") 		


		
		mi estimate: regress `outcome' ib3.`exposure' i.male i.matEdDrv i.finDifDrv i.manual prepregBMI matage i.mat_smok_bin18wk i.parity_cat 
		matrix list r(table)

		post `memhold' (`i') (3) ("`exposure'") ("`outcome'") ("Fully adjusted") ("Deficient") ///
			(strofreal(r(table)[1,1], "%5.2f")) ///
			("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 
		post `memhold' (`i') (4) ("`exposure'") ("`outcome'") ("Fully adjusted") ("Insufficient") ///
			(strofreal(r(table)[1,2], "%5.2f")) ///
			("(" + strofreal(r(table)[5,2],"%5.2f") + "-" + strofreal(r(table)[6,2],"%5.2f") + ")") 
	}
}
	
postclose `memhold'


********************************************************************************
* 3 Prepare models for output
********************************************************************************
use "Catexp_cca_obs_output_logistic.dta", clear
export delim using "Catexp_cca_obs_output_logistic.csv", delim(",") replace


use "Catexp_cca_obs_output_linear.dta", clear
export delim using "Catexp_cca_obs_output_linear.csv", delim(",") replace


use "Catexp_MI_obs_output_logistic.dta", clear
export delim using "Catexp_MI_obs_output_logistic.csv", delim(",") replace


use "Catexp_MI_obs_output_linear.dta", clear
export delim using "Catexp_MI_obs_output_linear.csv", delim(",") replace



********************************************************************************
* close log
********************************************************************************
log close



