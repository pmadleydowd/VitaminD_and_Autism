capture log close
log using "$Logdir\LOG_an_observational_european.txt", text replace
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		04 November 2021
* Description: 	Vit D and Autism project observational analysis among those with european ancestry
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

keep if flag_inclusion 		== 1
keep if flag_mPRS_avail		== 1 // all those with available PRS information are of european ancestry 

	
********************************************************************************
* 2 Perform logistic regression observational analyses
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' _outord _modelord str20 exposure str10 outcome str50 model str10 OR str20 OR_CI  ///
	using "$Datadir\Observational analysis\Obs_output_logistic_european.dta", replace

foreach exposure in sa_7wk_VitDtot_10 sa_20wk_VitDtot_10 sa_34wk_VitDtot_10 { 	
	local i = 0
	foreach outcome in ASD bin_scdc bin_coh bin_repbehaviour bin_sociability {
		local i = `i' + 1
		
		logistic `outcome' `exposure' if miss_confounder == 0 
		post `memhold' (`i') (1) ("`exposure'") ("`outcome'") ("Unadjusted") ///
			(strofreal(r(table)[1,1], "%5.2f")) ///
			("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 		

		logistic `outcome' `exposure' i.male if miss_confounder == 0 
		post `memhold' (`i') (2) ("`exposure'") ("`outcome'") ("Adjusted 1") ///
			(strofreal(r(table)[1,1], "%5.2f")) ///
			("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 		

		logistic `outcome' `exposure' i.matEdDrv i.finDifDrv i.manual  if miss_confounder == 0 
		post `memhold' (`i') (3) ("`exposure'") ("`outcome'") ("Adjusted 2") ///
			(strofreal(r(table)[1,1], "%5.2f")) ///
			("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 

		logistic `outcome' `exposure'  prepregBMI matage i.mat_smok_bin18wk i.parity_cat if miss_confounder == 0 
		post `memhold' (`i') (4) ("`exposure'") ("`outcome'") ("Adjusted 3") ///
			(strofreal(r(table)[1,1], "%5.2f")) ///
			("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 
		
		logistic `outcome' `exposure' i.male i.matEdDrv i.finDifDrv i.manual prepregBMI matage i.mat_smok_bin18wk i.parity_cat if miss_confounder == 0 
		post `memhold' (`i') (5) ("`exposure'") ("`outcome'") ("Fully adjusted") ///
			(strofreal(r(table)[1,1], "%5.2f")) ///
			("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 
	}
}
	
postclose `memhold'

	

********************************************************************************
* 3 Perform linear regression observational analyses
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' _modelord str20 exposure str10 outcome str50 model str10 OR str20 OR_CI  ///
	using "$Datadir\Observational analysis\Obs_output_linear_european.dta", replace


foreach exposure in sa_7wk_VitDtot_10 sa_20wk_VitDtot_10 sa_34wk_VitDtot_10 { 		
	regress zmf_asd `exposure' if miss_confounder == 0 
	post `memhold' (1) ("`exposure'") ("`outcome'") ("Unadjusted") ///
		(strofreal(r(table)[1,1], "%5.2f")) ///
		("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 		

	regress zmf_asd `exposure' i.male if miss_confounder == 0 
	post `memhold' (2) ("`exposure'") ("`outcome'") ("Adjusted 1") ///
		(strofreal(r(table)[1,1], "%5.2f")) ///
		("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 		

	regress zmf_asd `exposure' i.matEdDrv i.finDifDrv i.manual  if miss_confounder == 0 
	post `memhold' (3) ("`exposure'") ("`outcome'") ("Adjusted 2") ///
		(strofreal(r(table)[1,1], "%5.2f")) ///
		("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 

	regress zmf_asd `exposure'  prepregBMI matage i.mat_smok_bin18wk i.parity_cat if miss_confounder == 0 
	post `memhold' (4) ("`exposure'") ("`outcome'") ("Adjusted 3") ///
		(strofreal(r(table)[1,1], "%5.2f")) ///
		("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 

	regress zmf_asd `exposure' i.male i.matEdDrv i.finDifDrv i.manual prepregBMI matage i.mat_smok_bin18wk i.parity_cat if miss_confounder == 0 
	post `memhold' (5) ("`exposure'") ("`outcome'") ("Fully adjusted") ///
		(strofreal(r(table)[1,1], "%5.2f")) ///
		("(" + strofreal(r(table)[5,1],"%5.2f") + "-" + strofreal(r(table)[6,1],"%5.2f") + ")") 
}	
postclose `memhold'


********************************************************************************
* 4 Prepare models for output
********************************************************************************
use "$Datadir\Observational analysis\Obs_output_logistic_european.dta", clear
export delim using "$Datadir\Observational analysis\Observational_out_logistic_european.csv", delim(",") replace


use "$Datadir\Observational analysis\Obs_output_linear_european.dta", clear
export delim using "$Datadir\Observational analysis\Observational_out_linear_european.csv", delim(",") replace



********************************************************************************
* close log
********************************************************************************
log close



