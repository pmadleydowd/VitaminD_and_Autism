capture log close
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
*net install github, from("https://haghish.github.io/github/")
*github install remlapmot/ivonesamplemr

cd "$Datadir\MR analysis"
use "$Datadir\DERIVED_VitD_dat.dta", clear

keep if flag_inclusion 		== 1
keep if flag_mPRS_avail		== 1 // all those with available PRS information are of european ancestry 

********************************************************************************
* 2 Perform 2 stage residual inclusion (control function estimator) with GMM to correct SEs
********************************************************************************
capture postutil close 
tempname memhold 

postfile `memhold' str10 outcome N1 str30 ORCI1 N2 str30 ORCI2 ///
	using "$Datadir\MR analysis\MR1samp_output.dta", replace


foreach outcome in ASD bin_scdc bin_coh bin_repbehaviour bin_sociability  {

	** model 1 - unadjusted
	ivtsri `outcome' pc1_mom pc2_mom pc3_mom pc4_mom pc5_mom pc6_mom pc7_mom pc8_mom pc9_mom pc10_mom (sa_20wk_VitDtot_10 = zscore_vd_mom_prs pc1_mom pc2_mom pc3_mom pc4_mom pc5_mom pc6_mom pc7_mom pc8_mom pc9_mom pc10_mom), link(logit)

		* store estimates
	local mod1_n 	= e(N)
	local mod1_b 	= exp(r(table)[1,13])
	local mod1_lci 	= exp(r(table)[5,13])
	local mod1_uci 	= exp(r(table)[6,13])	
	
	
	** model 2 - adjusted for offspring PRS
	ivtsri `outcome' zscore_vd_child_prs pc1_mom pc2_mom pc3_mom pc4_mom pc5_mom pc6_mom pc7_mom pc8_mom pc9_mom pc10_mom (sa_20wk_VitDtot_10 = zscore_vd_mom_prs zscore_vd_child_prs pc1_mom pc2_mom pc3_mom pc4_mom pc5_mom pc6_mom pc7_mom pc8_mom pc9_mom pc10_mom), link(logit)

		* store estimates
	local mod2_n 	= e(N)
	local mod2_b 	= exp(r(table)[1,14])
	local mod2_lci 	= exp(r(table)[5,14])
	local mod2_uci 	= exp(r(table)[6,14])	
	
	
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
ivregress 2sls zmf_asd pc1_mom pc2_mom pc3_mom pc4_mom pc5_mom pc6_mom pc7_mom pc8_mom pc9_mom pc10_mom (sa_20wk_VitDtot_10 = zscore_vd_mom_prs pc1_mom pc2_mom pc3_mom pc4_mom pc5_mom pc6_mom pc7_mom pc8_mom pc9_mom pc10_mom), vce(robust)	
	local mod_n 	= e(N)	
	local mod_b 	= r(table)[1,1]
	local mod_lci 	= r(table)[5,1]
	local mod_uci 	= r(table)[6,1]
			   
post `memhold' ("MR ") ///
			   (`mod_n') (strofreal(`mod_b',"%4.2f") + " (" + strofreal(`mod_lci',"%4.2f") + " - " + strofreal(`mod_uci',"%4.2f") + ")" )   
				   
* run 2sls model adjusted for offspring PRS	   
ivregress 2sls zmf_asd zscore_vd_child_prs pc1_mom pc2_mom pc3_mom pc4_mom pc5_mom pc6_mom pc7_mom pc8_mom pc9_mom pc10_mom (sa_20wk_VitDtot_10 = zscore_vd_mom_prs zscore_vd_child_prs pc1_mom pc2_mom pc3_mom pc4_mom pc5_mom pc6_mom pc7_mom pc8_mom pc9_mom pc10_mom), vce(robust)				   
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
replace outcome = "Speech coherence" if outcome =="bin_coh"
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

