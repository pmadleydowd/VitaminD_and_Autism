log using "$Logdir\LOG_an_desc_stats.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2021-07-16
* Description: Descriptive statistics of ALSPAC vitamin D data
********************************************************************************
* Contents
************
* 1 Create environment
* 2 Descriptives tables for seasonally adjusted scores
* 3 Descriptives for normally distributed variables
* create formats in each dataset

********************************************************************************
* 1 create environment and load data
*************************************
cd "$Datadir\Descriptives"
use "$Datadir\DERIVED_VitD_dat.dta", clear

keep if flag_mat_white_eth 	== 1
keep if flag_alive1yr 		== 1
keep if flag_singleton		== 1
keep if flag_outcomeany 	== 1
keep if miss_exposure		== 0 



********************************************************************************
* 2 Descriptives tables for seasonally adjusted scores
*******************************************************
capture postutil close 
tempname memhold 

postfile `memhold' str20 stat statlev tabord ///
				   Total Totalbrack ///
				   vitd1 vitd1brack ///
				   vitd2 vitd2brack ///
				   vitd3 vitd3brack ///
				   vitd4 vitd4brack ///
				   vitd5 vitd5brack ///
				   using "Desc_SeasadjVitD.dta", replace

tab quint_seasadjvitD, matcell(matvitDtot)

local stat	 	 = "Total"
local statlev	 = .
local tabord     = 0
local Total 	 = _N
local Totalbrack = .
local vitD1 	 = matvitDtot[1,1]
local vitD1brack = .
local vitD2 	 = matvitDtot[2,1]
local vitD2brack = .
local vitD3 	 = matvitDtot[3,1]
local vitD3brack = .
local vitD4 	 = matvitDtot[4,1]
local vitD4brack = .
local vitD5 	 = matvitDtot[5,1]
local vitD5brack = .

post `memhold' ("`stat'") (`statlev') (`tabord') ///
			   (`Total') (`Totalbrack') ///
			   (`vitD1') (`vitD1brack') ///
			   (`vitD2') (`vitD2brack') ///
			   (`vitD3') (`vitD3brack') ///
			   (`vitD4') (`vitD4brack') ///
			   (`vitD5') (`vitD5brack')			   

foreach stat in male parity_cat mat_smok_bin18wk  matEdDrv finDifDrv manual ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability {
	tab `stat', mis matcell(matcountTotal)
	local nlevs = r(r)

	tab `stat' quint_seasadjvitD, mis matcell(matcountvitD) matrow(statlevs)
	
	local tabord = `tabord' + 1

	forvalues lev = 1(1)`nlevs' {
		disp `lev'
		local statlev = statlevs[`lev',1]
		
		local Total		 = matcountTotal[`lev',1] 
		local Totalbrack = 100*matcountTotal[`lev',1] /_N
		
		local vitD1 	 = matcountvitD[`lev',1]
		local vitD1brack = 100*matcountvitD[`lev',1]/matvitDtot[1,1]
		local vitD2 	 = matcountvitD[`lev',2]
		local vitD2brack = 100*matcountvitD[`lev',2]/matvitDtot[2,1]
		local vitD3 	 = matcountvitD[`lev',3]
		local vitD3brack = 100*matcountvitD[`lev',3]/matvitDtot[3,1]
		local vitD4 	 = matcountvitD[`lev',4]
		local vitD4brack = 100*matcountvitD[`lev',4]/matvitDtot[4,1]
		local vitD5 	 = matcountvitD[`lev',5]
		local vitD5brack = 100*matcountvitD[`lev',5]/matvitDtot[5,1]

	
		post `memhold' ("`stat'") (`statlev') (`tabord') ///
					   (`Total') (`Totalbrack') ///
					   (`vitD1') (`vitD1brack') ///
					   (`vitD2') (`vitD2brack') ///
					   (`vitD3') (`vitD3brack') ///
					   (`vitD4') (`vitD4brack') ///
					   (`vitD5') (`vitD5brack') 	

	}
}

postclose `memhold'


********************************************************************************
* 4 Descriptives for normally distributed variables 
*****************************************************
foreach exposure in quint_seasadjvitD {
    foreach stat in matage prepregBMI sadj_vitd zscore_vd_mom_prs_S13  zscore_vd_child_prs_S13  zmf_asd {
		statsby mean=r(mean) sd=r(sd), by(`exposure') saving("_temp\stats_`stat'_`exposure'", replace) total: summarize `stat'
	}
}

use Desc_SeasadjVitD, clear
summ tabord 
local istart = r(max)
foreach exposure in quint_seasadjvitD {
    local i = `istart'
	foreach stat in matage prepregBMI sadj_vitd zscore_vd_mom_prs_S13  zscore_vd_child_prs_S13  zmf_asd {
	    local i = `i' + 1
	    use "_temp\stats_`stat'_`exposure'.dta", clear
		
		replace `exposure' = 0 if `exposure' == .
		rename mean vitd 
		rename sd vitDbrack
		
		replace vitd = round(vitd, 0.01) 
		replace vitDbrack = round(vitDbrack, 0.01) 
		
		gen id = 1
		reshape wide vitd vitDbrack, i(id) j(`exposure')
		
		rename vitd0 Total
		rename vitDbrack0 Totalbrack
		rename vitDbrack* vitd*brack
		
		drop id
		gen stat = "`stat'"
		gen statlev = 1 
		gen tabord = `i'
		
		order stat statlev tabord
		
		save "_temp\widestats_`stat'_`exposure'.dta", replace
	}
}


foreach exposure in quint_seasadjvitD {
	use "_temp\widestats_matage_`exposure'.dta", clear
	foreach stat in prepregBMI sadj_vitd zscore_vd_mom_prs_S13 zscore_vd_child_prs_S13  zmf_asd {
		append using "_temp\widestats_`stat'_`exposure'.dta"
	}
	save "contDesc_`exposure'.dta", replace
}




********************************************************************************
* create formats in each dataset
**********************************
foreach exp in "seasadjvitD" {
	use "Desc_`exp'.dta", clear
	append  using "contDesc_quint_`exp'.dta"
	do "$Dodir\an_desc_formats.do"

	tostring Total, gen(Total_c) force
	tostring Total, gen(Total_c_cont) format(%5.2f) force
	replace  Total_c=Total_c_cont if tabord > 11 // update #11 if number of variables changes
	tostring Totalbrack, gen(Totalbrack_c) format(%5.2f) force

	tostring vitd1, gen(vitd1_c) force
	tostring vitd1, gen(vitd1_c_cont) format(%5.2f) force
	replace  vitd1_c=vitd1_c_cont if tabord > 11 // update #11 if number of variables changes
	tostring vitd1brack, gen(vitd1brack_c) format(%5.2f) force

	tostring vitd2, gen(vitd2_c) force
	tostring vitd2, gen(vitd2_c_cont) format(%5.2f) force
	replace  vitd2_c=vitd2_c_cont if tabord > 11 // update #11 if number of variables changes
	tostring vitd2brack, gen(vitd2brack_c) format(%5.2f) force

	tostring vitd3, gen(vitd3_c) force
	tostring vitd3, gen(vitd3_c_cont) format(%5.2f) force
	replace  vitd3_c=vitd3_c_cont if tabord > 11 // update #11 if number of variables changes
	tostring vitd3brack, gen(vitd3brack_c) format(%5.2f) force

	tostring vitd4, gen(vitd4_c) force
	tostring vitd4, gen(vitd4_c_cont) format(%5.2f) force
	replace  vitd4_c=vitd4_c_cont if tabord > 11 // update #11 if number of variables changes
	tostring vitd4brack, gen(vitd4brack_c) format(%5.2f) force

	tostring vitd5, gen(vitd5_c) force
	tostring vitd5, gen(vitd5_c_cont) format(%5.2f) force
	replace  vitd5_c=vitd5_c_cont if tabord > 11 // update #11 if number of variables changes
	tostring vitd5brack, gen(vitd5brack_c) format(%5.2f) force



	gen outTotal = Total_c if _n == 1
	replace outTotal = Total_c + " (" + Totalbrack_c + ")" if _n>1

	gen outvitd1 = vitd1_c if _n == 1
	replace outvitd1 = vitd1_c + " (" + vitd1brack_c + ")" if _n>1

	gen outvitd2 = vitd2_c if _n == 1
	replace outvitd2 = vitd2_c + " (" + vitd2brack_c + ")" if _n>1

	gen outvitd3 = vitd3_c if _n == 1
	replace outvitd3 = vitd3_c + " (" + vitd3brack_c + ")" if _n>1

	gen outvitd4 = vitd4_c if _n == 1
	replace outvitd4 = vitd4_c + " (" + vitd4brack_c + ")" if _n>1

	gen outvitd5 = vitd5_c if _n == 1
	replace outvitd5 = vitd5_c + " (" + vitd5brack_c + ")" if _n>1


	keep stat_c statlev_c out*
	rename out* * 
	export delim using "Desc_`exp'.csv", delim(",") replace
}

log close

