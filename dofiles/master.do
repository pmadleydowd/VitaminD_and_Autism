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
do "C:\Users\pm0233\OneDrive - University of Bristol\Documents\Projects\Vit D\Analysis\dofiles\global.do"

********************************************************************************
* 2 - Create datasets
********************************************************************************
do "$Dodir\cr_compilevitdPRS.do"		// Puts the PRS data into .dta format
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

********************************************************************************
* 8 - Run sensitivity analyses for MR models
********************************************************************************
do "$Dodir\an_desc_PRS_conf.do"		// Create descriptives for association of PRS with each confounder
do "$Dodir\an_sens_PRS_check.do"	// Perform sensitivity analyses to check different p-value thresholds
do "$Dodir\an_MR_sensitivity.do" // Perform sensitivity analyses with genetic risk scores created using different p value thresholds

