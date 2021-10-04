log using "$Logdir\LOG_an_MR_sensitivity.txt", text replace
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		02 August 2021
* Description: 	Sensitivity of MR analyses with genetic risk scores created using different p value thresholds
********************************************************************************
* Contents
* 1 Set up environment and read in data
* 2 Perform 2 stage residual inclusion (control function estimator) with GMM to correct SEs
* 3 Perform 2SLS model for autism mean factor score 
* 4 Prepare dataset and output (binary outcomes)
* 5 Prepare dataset and output (normal outcome)

********************************************************************************
* 1 Set up environment and read in data
********************************************************************************
cd "$Datadir\MR_sensitivity"
use "$Datadir\DERIVED_VitD_dat.dta", clear

keep if flag_mat_white_eth 	== 1
keep if flag_alive1yr 		== 1
keep if flag_singleton		== 1
keep if flag_outcomeany 	== 1
keep if miss_exposure		== 0 

********************************************************************************
* 2 Perform 2 stage residual inclusion (control function estimator) with GMM to correct SEs
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' str3 threshold str10 outcome N str30 ORCI OR LCI UCI ///
	using "sens_MR1samp_output.dta", replace

foreach outcome in ASD bin_scdc bin_coh bin_repbehaviour bin_sociability  {
	foreach val in S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12 S13  {

		* Equation 1 for unadjusted models
		regress sadj_vitd_10 zscore_vd_mom_prs_`val' 
		mat a1 = e(b)
		predict res1`val', res

		* Equation 1 for models adjusted for child vitamin D PRS
		regress sadj_vitd_10 zscore_vd_mom_prs_`val' zscore_vd_child_prs_`val' 
		mat a2 = e(b)
		predict res2`val', res


		** model 1
		logit `outcome' sadj_vitd_10 res1`val'
		mat b = e(b)
		logit, or

		mat from = (a1, b)

		gmm (sadj_vitd_10 - {a1}*zscore_vd_mom_prs_`val' - {a0}) ///
			(`outcome' - invlogit({b1}*sadj_vitd_10 + {b2}*(sadj_vitd_10 - {a1}*zscore_vd_mom_prs_`val' - {a0}) + {b0})), ///
			instruments(1:zscore_vd_mom_prs_`val' ) ///
			instruments(2:sadj_vitd_10 res1`val') ///
			winitial(unadjusted, independent) ///
			from(from)
			
			* store estimates
		local mod1_n 	= e(N)
			
		lincom _b[/b1], eform // cor	
		
		local mod1_b 	= r(estimate)
		local mod1_lci 	= r(lb)
		local mod1_uci 	= r(ub)	
		


		
		post `memhold' ("`val'") ("`outcome'") ///
					   (`mod1_n') ///
					   (strofreal(`mod1_b',"%4.2f") + " (" + strofreal(`mod1_lci',"%4.2f") + " - " + strofreal(`mod1_uci',"%4.2f") + ")" ) ///
					   (`mod1_b') (`mod1_lci') (`mod1_uci')



	}
	drop res*
}
postclose `memhold'






*******************************************************************************
* 3 Perform 2SLS model for autism mean factor score 
*******************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' str3 threshold str50 outcome N str30 RDCI RD LCI UCI ///
	using "sens_MR1samp_output_afm.dta", replace

foreach val in S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12 S13  {
	
		
	* run 2sls model 	
	ivregress 2sls zmf_asd (sadj_vitd_10 = zscore_vd_mom_prs_`val'), vce(robust)	
		local mod_n 	= e(N)	
		local mod_b 	= r(table)[1,1]
		local mod_lci 	= r(table)[5,1]
		local mod_uci 	= r(table)[6,1]
				   
	post `memhold' ("`val'") ("Autism factor mean score") ///
				   (`mod_n') ///
				   (strofreal(`mod_b',"%4.2f") + " (" + strofreal(`mod_lci',"%4.2f") + " - " + strofreal(`mod_uci',"%4.2f") + ")" )   ///
				   (`mod_b') (`mod_lci') (`mod_uci')
					   
}

postclose `memhold'





*******************************************************************************
* 4 Prepare dataset and output (binary outcomes)
*******************************************************************************
use "sens_MR1samp_output.dta", clear
replace outcome = "Autism diagnosis" if outcome =="ASD"
replace outcome = "Social communication difficulties" if outcome =="bin_scdc"
replace outcome = "Pragmatic language difficulties" if outcome =="bin_coh"
replace outcome = "Repetitive behaviour" if outcome =="bin_repbeh"
replace outcome = "Sociability" if outcome =="bin_sociab"

replace threshold = "0.5"  			if threshold == "S1"
replace threshold = "0.4" 			if threshold == "S2"
replace threshold = "0.3" 			if threshold == "S3"
replace threshold = "0.2" 			if threshold == "S4"
replace threshold = "0.1" 			if threshold == "S5"
replace threshold = "0.05" 			if threshold == "S6"
replace threshold = "0.01" 			if threshold == "S7"
replace threshold = "0.001" 		if threshold == "S8"
replace threshold = "0.0001"		if threshold == "S9"
replace threshold = "0.00001"		if threshold == "S10"
replace threshold = "0.000001"		if threshold == "S11"
replace threshold = "0.0000001"		if threshold == "S12"
replace threshold = "0.00000005"	if threshold == "S13"

export delim "sens_MR1samp_output.csv", replace

*******************************************************************************
* 5 Prepare dataset and output (normal outcome)
*******************************************************************************
use "sens_MR1samp_output_afm.dta", clear

replace threshold = "0.5"  			if threshold == "S1"
replace threshold = "0.4" 			if threshold == "S2"
replace threshold = "0.3" 			if threshold == "S3"
replace threshold = "0.2" 			if threshold == "S4"
replace threshold = "0.1" 			if threshold == "S5"
replace threshold = "0.05" 			if threshold == "S6"
replace threshold = "0.01" 			if threshold == "S7"
replace threshold = "0.001" 		if threshold == "S8"
replace threshold = "0.0001"		if threshold == "S9"
replace threshold = "0.00001"		if threshold == "S10"
replace threshold = "0.000001"		if threshold == "S11"
replace threshold = "0.0000001"		if threshold == "S12"
replace threshold = "0.00000005"	if threshold == "S13"



export delim "sens_MR1samp_output_afm.csv", replace



********************************************************************************
* close log
********************************************************************************
log close

