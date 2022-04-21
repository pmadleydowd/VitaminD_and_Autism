********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		22 July 2021
* Description: 	Master file to run all do files in the correct order for vitamin d and autism project
********************************************************************************
* Contents
* 1 - Run global.do
* 2 - Create datasets
* 3 - Run descriptive analyses
* 4 - Run observational analyses
* 5 - Run Spline analyses
* 6 - Run sensitivity analyses for spline models
* 7 - Run MR analyses 
* 8 - Run sensitivity analyses for MR models
********************************************************************************
* 1 - Run global.do - sets the directories for project
********************************************************************************
do "YOURPATH\global.do"

********************************************************************************
* 2 - Create datasets
********************************************************************************
do "$Dodir\cr_initial_dataset.do"		// Create the initial ALSPAC sample
do "$Dodir\cr_derived_dataset.do"		// Create all derived variables 

********************************************************************************
* 3 - Run descriptive analyses
********************************************************************************
do "$Dodir\an_flowchart.do"		 		 // Create outputs for flowchart of cohort derivations
do "$Dodir\an_desc_stats.do"			 // Create outputs for descriptive statistics
do "$Dodir\an_missingdata_desc_stats.do" // Create outputs for missing data descriptive statistics
do "$Dodir\an_incexc_desc_stats.do" 	 // Create outputs for descriptive statistics of included versus excluded individuals

********************************************************************************
* 4 - Run observational analyses
********************************************************************************
do "$Dodir\an_observational.do"	
do "$Dodir\an_MI_observational.do"		// analyses using multiple imputation to account for missing data

do "$Dodir\an_observational_catexp.do" // repeat of observational analyses using a categorical exposure variable 

do "$Dodir\an_observational_european.do"	 // repeat of observational analyses restricted to those of european ancestry
do "$Dodir\an_MI_observational_european.do"	 // repeat of observational analyses restricted to those of european ancestry

********************************************************************************
* 5 - Run Spline analyses
********************************************************************************
do "$Dodir\an_spline.do"

********************************************************************************
* 6 - Run sensitivity analyses for spline models
********************************************************************************
do "$Dodir\an_spline_sensitivity.do" // sensitivity analyses using different numbers of knots in the spline models 

********************************************************************************
* 7 - Run MR analyses 
********************************************************************************
do "$Dodir\an_MR.do"
do "$Dodir\an_MR_figures.do"   // create figures for publication (code initially created by Flo Martin - https://github.com/flozoemartin) 

********************************************************************************
* 8 - Run sensitivity analyses for MR models
********************************************************************************
do "$Dodir\an_desc_PRS_conf.do"		// Create descriptives for association of PRS with each confounder


