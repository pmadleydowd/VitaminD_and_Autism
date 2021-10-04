log using "$Logdir\LOG_an_MR.txt", text replace
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		02 August 2021
* Description: 	MR analysis of vitamin d in pregnancy and autism
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
cd "$Datadir\MR analysis"
use "$Datadir\DERIVED_VitD_dat.dta", clear

keep if flag_mat_white_eth 	== 1
keep if flag_alive1yr 		== 1
keep if flag_singleton		== 1
keep if flag_outcomeany 	== 1
keep if miss_exposure		== 0 

********************************************************************************
* 2 Perform 2 stage residual inclusion (control function estimator) with GMM to correct SEs
********************************************************************************
* Equation 1 for unadjusted models
regress sadj_vitd_10 zscore_vd_mom_prs_S13 
mat a1 = e(b)
predict res1, res

* Equation 1 for models adjusted for child vitamin D PRS
regress sadj_vitd_10 zscore_vd_mom_prs_S13 zscore_vd_child_prs_S13 
mat a2 = e(b)
predict res2, res

capture postutil close 
tempname memhold 

postfile `memhold' str10 outcome N1 str30 ORCI1 N2 str30 ORCI2 ///
	using "$Datadir\MR analysis\MR1samp_output.dta", replace


foreach outcome in ASD bin_scdc bin_coh bin_repbehaviour bin_sociability  {

	** model 1
	logit `outcome' sadj_vitd_10 res1
	mat b = e(b)
	logit, or

	mat from = (a1, b)

	gmm (sadj_vitd_10 - {a1}*zscore_vd_mom_prs_S13 - {a0}) ///
		(`outcome' - invlogit({b1}*sadj_vitd_10 + {b2}*(sadj_vitd_10 - {a1}*zscore_vd_mom_prs_S13 - {a0}) + {b0})), ///
		instruments(1:zscore_vd_mom_prs_S13 ) ///
		instruments(2:sadj_vitd_10 res1) ///
		winitial(unadjusted, independent) ///
		from(from)
		
		* store estimates
	local mod1_n 	= e(N)
		
	lincom _b[/b1], eform // cor	
	
	local mod1_b 	= r(estimate)
	local mod1_lci 	= r(lb)
	local mod1_uci 	= r(ub)	
	

	
	** model 2
	logit `outcome' sadj_vitd_10 res2 zscore_vd_mom_prs_S13
	mat b = e(b)
	logit, or

	mat from = (a2, b)

	gmm (sadj_vitd_10 - {a1}*zscore_vd_mom_prs_S13 - {a2}*zscore_vd_child_prs_S13 - {a0}) ///
		(`outcome' - invlogit({b1}*sadj_vitd_10 + {b2}*(sadj_vitd_10 - {a1}*zscore_vd_mom_prs_S13  - {a2}*zscore_vd_child_prs_S13 - {a0}) + {b3}*zscore_vd_child_prs_S13 + {b0})), ///
		instruments(1:zscore_vd_mom_prs_S13 zscore_vd_child_prs_S13) ///
		instruments(2:sadj_vitd_10 res2 zscore_vd_child_prs_S13) ///
		winitial(unadjusted, independent) ///
		from(from)
		
		* store estimates
	local mod2_n 	= e(N)
		
	lincom _b[/b1], eform // cor	
	
	local mod2_b 	= r(estimate)
	local mod2_lci 	= r(lb)
	local mod2_uci 	= r(ub)	
	

	
	post `memhold' ("`outcome'") ///
				   (`mod1_n') (strofreal(`mod1_b',"%4.2f") + " (" + strofreal(`mod1_lci',"%4.2f") + " - " + strofreal(`mod1_uci',"%4.2f") + ")" ) ///
				   (`mod2_n') (strofreal(`mod2_b',"%4.2f") + " (" + strofreal(`mod2_lci',"%4.2f") + " - " + strofreal(`mod2_uci',"%4.2f") + ")" )


}
postclose `memhold'






*******************************************************************************
* 3 Perform 2SLS model for autism mean factor score 
*******************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' str50 model N str30 RDCI ///
	using "$Datadir\MR analysis\MR1samp_output_afm.dta", replace

* run 2sls model 	
ivregress 2sls zmf_asd (sadj_vitd_10 = zscore_vd_mom_prs_S13), vce(robust)	
	local mod_n 	= e(N)	
	local mod_b 	= r(table)[1,1]
	local mod_lci 	= r(table)[5,1]
	local mod_uci 	= r(table)[6,1]
			   
post `memhold' ("MR ") ///
			   (`mod_n') (strofreal(`mod_b',"%4.2f") + " (" + strofreal(`mod_lci',"%4.2f") + " - " + strofreal(`mod_uci',"%4.2f") + ")" )   
				   
* run 2sls model adjusted for offspring PRS	   
ivregress 2sls zmf_asd zscore_vd_child_prs_S13 (sadj_vitd_10 = zscore_vd_mom_prs_S13 zscore_vd_child_prs_S13), vce(robust)				   
	local mod_n 	= e(N)	
	local mod_b 	= r(table)[1,1]
	local mod_lci 	= r(table)[5,1]
	local mod_uci 	= r(table)[6,1]
	
post `memhold' ("MR adjusted for offspring PRS") ///
			   (`mod_n') (strofreal(`mod_b',"%4.2f") + " (" + strofreal(`mod_lci',"%4.2f") + " - " + strofreal(`mod_uci',"%4.2f") + ")" )



postclose `memhold'





*******************************************************************************
* 4 Prepare dataset and output (binary outcomes)
*******************************************************************************
use "$Datadir\MR analysis\MR1samp_output.dta", clear
replace outcome = "Autism diagnosis" if outcome =="ASD"
replace outcome = "Social communication difficulties" if outcome =="bin_scdc"
replace outcome = "Pragmatic language difficulties" if outcome =="bin_coh"
replace outcome = "Repetitive behaviour" if outcome =="bin_repbeh"
replace outcome = "Sociability" if outcome =="bin_sociab"

export excel "$Datadir\MR analysis\MR1samp_output.xlsx", replace



*******************************************************************************
* 5 Prepare dataset and output (normal outcome)
*******************************************************************************
use "$Datadir\MR analysis\MR1samp_output_afm.dta", clear
export excel "$Datadir\MR analysis\MR1samp_output_afm.xlsx", replace



********************************************************************************
* close log
********************************************************************************
log close

