log using "$Logdir\LOG_an_observational.txt", text replace
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		22 July 2021
* Description: 	Vit D and Autism project observational analysis
********************************************************************************
* Contents
* 1 Set up environment and read in data
* 2 Perform logistic regression observational analyses
* 3 Perform linear regression observational analyses
* 4 Prepare models for output

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
* 2 Perform logistic regression observational analyses
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' _outord _modelord str10 outcome str50 model str10 OR str20 OR_CI  ///
	using "$Datadir\Observational analysis\Obs_output_logistic.dta", replace

local i = 0
local exposure sadj_vitd_10 
foreach outcome in ASD bin_scdc bin_coh bin_repbehaviour bin_sociability {
	local i = `i' + 1
	
	logistic `outcome' `exposure' if miss_confounder == 0 
	post `memhold' (`i') (1) ("`outcome'") ("Unadjusted") ///
		(strofreal(r(table)[1,1], "%5.2f")) ///
		("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 		

	logistic `outcome' `exposure' i.male if miss_confounder == 0 
	post `memhold' (`i') (2) ("`outcome'") ("Adjusted 1") ///
		(strofreal(r(table)[1,1], "%5.2f")) ///
		("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 		

	logistic `outcome' `exposure' i.matEdDrv i.finDifDrv i.manual  if miss_confounder == 0 
	post `memhold' (`i') (3) ("`outcome'") ("Adjusted 2") ///
		(strofreal(r(table)[1,1], "%5.2f")) ///
		("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 

	logistic `outcome' `exposure'  prepregBMI matage i.mat_smok_bin18wk i.parity_cat if miss_confounder == 0 
	post `memhold' (`i') (4) ("`outcome'") ("Adjusted 3") ///
		(strofreal(r(table)[1,1], "%5.2f")) ///
		("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 
	
	logistic `outcome' `exposure' i.male i.matEdDrv i.finDifDrv i.manual prepregBMI matage i.mat_smok_bin18wk i.parity_cat if miss_confounder == 0 
	post `memhold' (`i') (5) ("`outcome'") ("Fully adjusted") ///
		(strofreal(r(table)[1,1], "%5.2f")) ///
		("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 
}

	
postclose `memhold'

	

********************************************************************************
* 3 Perform linear regression observational analyses
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' _modelord str10 outcome str50 model str10 OR str20 OR_CI  ///
	using "$Datadir\Observational analysis\Obs_output_linear.dta", replace

local exposure sadj_vitd_10 
	
regress zmf_asd `exposure' if miss_confounder == 0 
post `memhold' (1) ("`outcome'") ("Unadjusted") ///
	(strofreal(r(table)[1,1], "%5.2f")) ///
	("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 		

regress zmf_asd `exposure' i.male if miss_confounder == 0 
post `memhold' (2) ("`outcome'") ("Adjusted 1") ///
	(strofreal(r(table)[1,1], "%5.2f")) ///
	("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 		

regress zmf_asd `exposure' i.matEdDrv i.finDifDrv i.manual  if miss_confounder == 0 
post `memhold' (3) ("`outcome'") ("Adjusted 2") ///
	(strofreal(r(table)[1,1], "%5.2f")) ///
	("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 

regress zmf_asd `exposure'  prepregBMI matage i.mat_smok_bin18wk i.parity_cat if miss_confounder == 0 
post `memhold' (4) ("`outcome'") ("Adjusted 3") ///
	(strofreal(r(table)[1,1], "%5.2f")) ///
	("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 

regress zmf_asd `exposure' i.male i.matEdDrv i.finDifDrv i.manual prepregBMI matage i.mat_smok_bin18wk i.parity_cat if miss_confounder == 0 
post `memhold' (5) ("`outcome'") ("Fully adjusted") ///
	(strofreal(r(table)[1,1], "%5.2f")) ///
	("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 
	
postclose `memhold'


********************************************************************************
* 4 Prepare models for output
********************************************************************************
use "$Datadir\Observational analysis\Obs_output_logistic.dta", clear
export delim using "$Datadir\Observational analysis\Observational_out_logistic.csv", delim(",") replace


use "$Datadir\Observational analysis\Obs_output_linear.dta", clear
export delim using "$Datadir\Observational analysis\Observational_out_linear.csv", delim(",") replace



********************************************************************************
* close log
********************************************************************************
log close



