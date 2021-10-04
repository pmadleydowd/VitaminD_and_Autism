log using "$Logdir\LOG_an_sens_PRS_check.txt", text replace
********************************************************************************
* Author: 		Christina Dardani
* Date: 		September 2021
* Description:	.do file to assess associations between PRS and maternal vitamin D during pregnancy 
********************************************************************************
* Contents
* 1 Set up environment 
* 2 Assess associations between maternal PRS at different p value thresholds and vitamin D
* 3 Assess associations between child PRS at different p value thresholds and vitamin D

********************************************************************************
* 1 Set up environment 
********************************************************************************
cd "$Datadir\MR_sensitivity"

********************************************************************************
* 2 Assess associations between maternal PRS at different p value thresholds and vitamin D
********************************************************************************
foreach val in S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12 S13  {
	use "$Datadir\DERIVED_VitD_dat.dta", clear

	keep if flag_mat_white_eth 	== 1
	keep if flag_alive1yr 		== 1
	keep if flag_singleton		== 1
	keep if flag_outcomeany 	== 1
	keep if miss_exposure		== 0 


	mark prs
	markout prs zscore_vd_mom_prs_`val' sadj_vitd ///
	pc1_mom pc2_mom pc3_mom pc4_mom pc5_mom pc6_mom pc7_mom pc8_mom pc9_mom pc10_mom male

	regress sadj_vitd zscore_vd_mom_prs_`val' ///
	pc1_mom pc2_mom pc3_mom pc4_mom pc5_mom pc6_mom pc7_mom pc8_mom pc9_mom pc10_mom male if prs==1

	matrix test = r(table)

	scalar b= test[1,1]
	scalar se= test[2,1]
	scalar p= test[4,1]
	scalar ll= test[5,1]
	scalar ul= test[6,1]
	scalar R= e(r2) 
	matrix define `val'= b, se, p, ll, ul, R
	matrix colnames `val' = b se p ll ul R


}

matrix define PRS = S1 \ S2 \ S3 \ S4 \ S5 \ S6 \ S7 \ S8 \ S9 \ S10 \ S11 \ S12 \ S13 
matrix rownames PRS= 0.5 0.4 0.3 0.2 0.1 0.05 0.01 0.001 0.0001 0.00001 0.000001 0.0000001 0.00000005


putexcel set prs_mom_VD_matVDpreg.xlsx, sheet(Sheet1) modify
putexcel A8 = matrix(PRS), names

********************************************************************************
* 3 Assess associations between child PRS at different p value thresholds and vitamin D
********************************************************************************
foreach val in S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12 S13  {
	use "$Datadir\DERIVED_VitD_dat.dta", clear

	keep if flag_mat_white_eth 	== 1
	keep if flag_alive1yr 		== 1
	keep if flag_singleton		== 1
	keep if flag_outcomeany 	== 1
	keep if miss_exposure		== 0 


	mark prs
	markout prs zscore_vd_child_prs_`val' sadj_vitd ///
	pc1_child pc2_child pc3_child pc4_child pc5_child pc6_child pc7_child pc8_child pc9_child pc10_child male

	regress sadj_vitd zscore_vd_child_prs_`val' ///
	pc1_child pc2_child pc3_child pc4_child pc5_child pc6_child pc7_child pc8_child pc9_child pc10_child male if prs==1

	matrix test = r(table)

	scalar b= test[1,1]
	scalar se= test[2,1]
	scalar p= test[4,1]
	scalar ll= test[5,1]
	scalar ul= test[6,1]
	scalar R= e(r2) 
	matrix define `val'= b, se, p, ll, ul, R
	matrix colnames `val' = b se p ll ul R
}

matrix define PRS = S1 \ S2 \ S3 \ S4 \ S5 \ S6 \ S7 \ S8 \ S9 \ S10 \ S11 \ S12 \ S13 
matrix rownames PRS= 0.5 0.4 0.3 0.2 0.1 0.05 0.01 0.001 0.0001 0.00001 0.000001 0.0000001 0.00000005



putexcel set prs_child_VD_matVDpreg.xlsx, sheet(Sheet1) modify
putexcel A8 = matrix(PRS), names


********************************************************************************
log close