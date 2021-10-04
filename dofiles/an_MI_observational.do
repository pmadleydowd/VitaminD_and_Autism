log using "$Logdir\LOG_an_MI_observational.txt", text replace
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		12 August 2021
* Description: 	Vit D and Autism project observational analysis using multiple imputation 
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

keep if flag_mat_white_eth 	== 1
keep if flag_alive1yr 		== 1
keep if flag_singleton		== 1
keep if flag_outcomeany 	== 1
keep if miss_exposure		== 0 

********************************************************************************
* 3 Create imputed datasets
********************************************************************************
mi set wide
mi register imputed ASD bin_scdc bin_coh bin_repbehaviour bin_sociability zmf_asd parity_cat mat_smok_bin18wk matEdDrv finDifDrv manual prepregBMI marital homeowner 
mi register regular sadj_vitd_10 male matage

mi impute chained (regress) zmf_asd prepregBMI ///
				  (logit) ASD bin_scdc bin_coh bin_repbehaviour bin_sociability mat_smok_bin18wk finDifDrv manual ///
				  (ologit) parity_cat ///
				  (mlogit) matEdDrv marital homeowner /// 
				  = sadj_vitd_10 male matage ///
				  , add(100) rseed(484286) dots 


save "$Datadir\Observational analysis\Imputed_data.dta", replace
	
********************************************************************************
* 3 Perform logistic regression observational analyses
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' _outord _modelord str10 outcome str50 model str10 OR str20 OR_CI  ///
	using "$Datadir\Observational analysis\MI_Obs_output_logistic.dta", replace

local i = 0
local exposure sadj_vitd_10 
foreach outcome in ASD bin_scdc bin_coh bin_repbehaviour bin_sociability {
	local i = `i' + 1
	
	mi estimate: logistic `outcome' `exposure' 
	post `memhold' (`i') (1) ("`outcome'") ("Unadjusted") ///
		(strofreal(exp(r(table)[1,1]), "%5.2f")) ///
		("(" + strofreal(exp(r(table)[5,1]),"%5.2f") + " - " + strofreal(exp(r(table)[6,1]),"%5.2f") + ")") 		

	mi estimate: logistic `outcome' `exposure' i.male 
	post `memhold' (`i') (2) ("`outcome'") ("Adjusted 1") ///
		(strofreal(exp(r(table)[1,1]), "%5.2f")) ///
		("(" + strofreal(exp(r(table)[5,1]),"%5.2f") + " - " + strofreal(exp(r(table)[6,1]),"%5.2f") + ")") 		

	mi estimate: logistic `outcome' `exposure' i.matEdDrv i.finDifDrv i.manual  
	post `memhold' (`i') (3) ("`outcome'") ("Adjusted 2") ///
		(strofreal(exp(r(table)[1,1]), "%5.2f")) ///
		("(" + strofreal(exp(r(table)[5,1]),"%5.2f") + " - " + strofreal(exp(r(table)[6,1]),"%5.2f") + ")") 

	mi estimate: logistic `outcome' `exposure'  prepregBMI matage i.mat_smok_bin18wk i.parity_cat
	post `memhold' (`i') (4) ("`outcome'") ("Adjusted 3") ///
		(strofreal(exp(r(table)[1,1]), "%5.2f")) ///
		("(" + strofreal(exp(r(table)[5,1]),"%5.2f") + " - " + strofreal(exp(r(table)[6,1]),"%5.2f") + ")") 
	
	mi estimate: logistic `outcome' `exposure' i.male i.matEdDrv i.finDifDrv i.manual prepregBMI matage i.mat_smok_bin18wk i.parity_cat 
	post `memhold' (`i') (5) ("`outcome'") ("Fully adjusted") ///
		(strofreal(exp(r(table)[1,1]), "%5.2f")) ///
		("(" + strofreal(exp(r(table)[5,1]),"%5.2f") + " - " + strofreal(exp(r(table)[6,1]),"%5.2f") + ")") 
}

	
postclose `memhold'

	

********************************************************************************
* 4 Perform linear regression observational analyses
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' _modelord str10 outcome str50 model str10 meandiff str20 CI  ///
	using "$Datadir\Observational analysis\MI_Obs_output_linear.dta", replace

local exposure sadj_vitd_10 
	
mi estimate: regress zmf_asd `exposure' 
post `memhold' (1) ("`outcome'") ("Unadjusted") ///
	(strofreal(r(table)[1,1], "%5.2f")) ///
	("(" + strofreal(r(table)[5,1],"%5.2f") + " - " + strofreal(r(table)[6,1],"%5.2f") + ")") 		

mi estimate: regress zmf_asd `exposure' i.male 
post `memhold' (2) ("`outcome'") ("Adjusted 1") ///
	(strofreal(r(table)[1,1], "%5.2f")) ///
	("(" + strofreal(r(table)[5,1],"%5.2f") + " - " + strofreal(r(table)[6,1],"%5.2f") + ")") 		

mi estimate: regress zmf_asd `exposure' i.matEdDrv i.finDifDrv i.manual  
post `memhold' (3) ("`outcome'") ("Adjusted 2") ///
	(strofreal(r(table)[1,1], "%5.2f")) ///
	("(" + strofreal(r(table)[5,1],"%5.2f") + " - " + strofreal(r(table)[6,1],"%5.2f") + ")") 

mi estimate: regress zmf_asd `exposure'  prepregBMI matage i.mat_smok_bin18wk i.parity_cat
post `memhold' (4) ("`outcome'") ("Adjusted 3") ///
	(strofreal(r(table)[1,1], "%5.2f")) ///
	("(" + strofreal(r(table)[5,1],"%5.2f") + " - " + strofreal(r(table)[6,1],"%5.2f") + ")") 

mi estimate: regress zmf_asd `exposure' i.male i.matEdDrv i.finDifDrv i.manual prepregBMI matage i.mat_smok_bin18wk i.parity_cat 
post `memhold' (5) ("`outcome'") ("Fully adjusted") ///
	(strofreal(r(table)[1,1], "%5.2f")) ///
	("(" + strofreal(r(table)[5,1],"%5.2f") + " - " + strofreal(r(table)[6,1],"%5.2f") + ")") 
	
postclose `memhold'


********************************************************************************
* 5 Prepare models for output
********************************************************************************
use "$Datadir\Observational analysis\MI_Obs_output_logistic.dta", clear
export delim using "$Datadir\Observational analysis\MI_Observational_out_logistic.csv", delim(",") replace


use "$Datadir\Observational analysis\MI_Obs_output_linear.dta", clear
export delim using "$Datadir\Observational analysis\MI_Observational_out_linear.csv", delim(",") replace




********************************************************************************
* close log
********************************************************************************
log close



