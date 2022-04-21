capture log close
log using "$Logdir\LOG_an_desc_stats.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2021-07-16
* Description: Descriptive statistics of ALSPAC vitamin D data
********************************************************************************
* Contents
************
* 1 Create environment and load data
* 2 Create descriptive statistics using table1_mc package 

********************************************************************************
* 1 create environment and load data
*************************************
* load required packages
* ssc install table1_mc

* load data
cd "$Datadir\Descriptives"
use "$Datadir\DERIVED_VitD_dat.dta", clear
keep if flag_inclusion 		== 1

********************************************************************************
* 2 Create descriptive statistics using table1_mc package 
********************************************************************************
foreach week in 7 20 34 {
	table1_mc,  by(quint_savitd_`week'wk) ///
				vars( /// 
					 male bin %5.1f \ ///
					 parity_cat cat %5.1f \ ///
					 mat_smok_bin18wk bin %5.1f \ ///
					 matEdDrv cat %5.1f \ ///
					 finDifDrv bin %5.1f \ ///
					 manual bin %5.1f \ ///
					 matage contn %5.1f \ /// 
					 prepregBMI contn %5.1f \ /// 
					 sa_7wk_VitDtot_preg contn %5.1f \ /// 
					 sa_20wk_VitDtot_preg contn %5.1f \ /// 
					 sa_34wk_VitDtot_preg contn %5.1f \ /// 
					 zscore_vd_mom_prs contn %5.1f \ /// 
					 zscore_vd_child_prs contn %5.1f \ /// 
					 ASD bin %5.1f \ ///
					 bin_scdc bin %5.1f \ ///
					 bin_coherence bin %5.1f \ ///
					 bin_repbehaviour bin %5.1f \ ///
					 bin_sociability bin %5.1f \ ///
					 zmf_asd contn %5.1f \ /// 
					 homeowner cat %5.1f \ /// \ /// 
					 marital cat %5.1f \ /// 
					) ///
				nospace onecol missing total(before) test ///
				saving("$Datadir\Descriptives\Desc_sadj_week`week'.xlsx", replace)
}					 




log close

