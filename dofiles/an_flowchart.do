log using "$Logdir\LOG_an_flowchart.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 02 Sep 2021
* Description: Flow chart of data for ALSPAC vitamin D project
********************************************************************************
* Contents
************
* 1 Create environment and load data
* 2 Descriptives statistics for inclusion in analyses

********************************************************************************
* 1 create environment and load data
*************************************
cd "$Datadir\Inclusion flow chart"
use "$Datadir\DERIVED_VitD_dat.dta", clear

********************************************************************************
* 2 Descriptives statistics for inclusion in analyses
*******************************************************
capture postutil close 
tempname memhold 

postfile `memhold' str50 stat tabord ///
				   tot totbrack /// 
				   totasd totasdbrack ///
				   totscdc totscdcbrack ///	
				   totcohe totcohebrack ///				   
				   totrepb totrepbbrack ///				   
				   totsoci totsocibrack ///				   				   
	using "flowchart_out.dta", replace


* initial counts	
tab ASD,  				matcell(ASDtot)
tab bin_scdc, 		 	matcell(scdctot)
tab bin_coherence, 		matcell(cohetot)
tab bin_repbehaviour, 	matcell(repbtot)
tab bin_sociability, 	matcell(socitot)

local TOT = _N
local TOTASD  = ASDtot[2,1]
local TOTscdc = scdctot[2,1]
local TOTcohe = cohetot[2,1]
local TOTrepb = repbtot[2,1]
local TOTsoci = socitot[2,1]


local stat	 	 	= "Total"
local tabord     	= 0
local tot 		 	= `TOT'
local totbrack 	 	= 100
local totASD 		= `TOTASD'
local totASDbrack 	= 100
local totscdc 		= `TOTscdc'
local totscdcbrack 	= 100
local totcohe 		= `TOTcohe'
local totcohebrack 	= 100
local totrepb 		= `TOTrepb'
local totrepbbrack 	= 100
local totsoci 		= `TOTsoci'
local totsocibrack 	= 100


post `memhold' ("`stat'") 	(`tabord') ///
			   (`tot') 		(`totbrack') /// 
			   (`totASD') 	(`totASDbrack') ///
			   (`totscdc') 	(`totscdcbrack') ///
			   (`totcohe') 	(`totcohebrack') ///
			   (`totrepb') 	(`totrepbbrack') ///
			   (`totsoci') 	(`totsocibrack') 
			   
* counts for exclusions
foreach stat in flag_alive1yr flag_singleton flag_outcomeany flag_exposureany {
	tab `stat', matcell(matstat)
	tab `stat' ASD, 		matcell(matstatASD)  mis
	tab `stat' bin_scdc, 	matcell(matstatscdc) mis 
	tab `stat' bin_cohe, 	matcell(matstatcohe) mis
	tab `stat' bin_repb, 	matcell(matstatrepb) mis
	tab `stat' bin_soci, 	matcell(matstatsoci) mis

	
	local tabord 		= `tabord' + 1
	local tot		 	= matstat[1,1]
	local totbrack 		= round(100*matstat[1,1]/`TOT', 0.01)
	local totASD 		= matstatASD[1,2]
	local totASDbrack	= round(100*matstatASD[1,2]/`TOTASD', 0.01)
	local totscdc 		= matstatscdc[1,2]
	local totscdcbrack	= round(100*matstatscdc[1,2]/`TOTscdc', 0.01)
	local totcohe 		= matstatcohe[1,2]
	local totcohebrack	= round(100*matstatcohe[1,2]/`TOTcohe', 0.01)
	local totrepb 		= matstatrepb[1,2]
	local totrepbbrack	= round(100*matstatrepb[1,2]/`TOTrepb', 0.01)
	local totsoci 		= matstatsoci[1,2]
	local totsocibrack	= round(100*matstatsoci[1,2]/`TOTsoci', 0.01)	

	
	post `memhold' ("`stat'") 	(`tabord') ///
				   (`tot') 		(`totbrack') /// 
				   (`totASD') 	(`totASDbrack') ///
				   (`totscdc') 	(`totscdcbrack') ///
				   (`totcohe') 	(`totcohebrack') ///
				   (`totrepb') 	(`totrepbbrack') ///
				   (`totsoci') 	(`totsocibrack') 

}


* remaining after exclusions
keep if flag_alive1yr 		== 1
keep if flag_singleton		== 1
keep if flag_outcomeany 	== 1
keep if miss_exposure		== 0 

tab ASD,  		matcell(ASDtot)
tab bin_scdc, 	matcell(scdctot)
tab bin_cohe, 	matcell(cohetot)
tab bin_repb, 	matcell(repbtot)
tab bin_soci, 	matcell(socitot)



local stat	 	 	= "Remaining after exclusions"
local tabord     	= `tabord' + 1
local tot 		 	= _N
local totbrack 	 	= round(100*_N/`TOT', 0.01)
local totASD 		= ASDtot[2,1]
local totASDbrack 	= round(100*ASDtot[2,1]/`TOTASD', 0.01)
local totscdc 		= scdctot[2,1]
local totscdcbrack 	= round(100*scdctot[2,1]/`TOTscdc', 0.01)
local totcohe 		= cohetot[2,1]
local totcohebrack 	= round(100*cohetot[2,1]/`TOTcohe', 0.01)
local totrepb 		= repbtot[2,1]
local totrepbbrack 	= round(100*repbtot[2,1]/`TOTrepb', 0.01)
local totsoci 		= socitot[2,1]
local totsocibrack 	= round(100*socitot[2,1]/`TOTsoci', 0.01)

post `memhold' ("`stat'") 	(`tabord') ///
			   (`tot') 		(`totbrack') /// 
			   (`totASD') 	(`totASDbrack') ///
			   (`totscdc') 	(`totscdcbrack') ///
			   (`totcohe') 	(`totcohebrack') ///
			   (`totrepb') 	(`totrepbbrack') ///
			   (`totsoci') 	(`totsocibrack') 
			   
			   
* count for excluded for missing data 			   
tab flag_conf_allnomiss, 	matcell(matstat)
tab flag_cca_asd ASD,	 	matcell(matstatASD) 
tab flag_cca_scdc bin_scdc, matcell(matstatscdc) 
tab flag_cca_cohe bin_cohe, matcell(matstatcohe) 
tab flag_cca_repb bin_repb, matcell(matstatrepb) 
tab flag_cca_soci bin_soci, matcell(matstatsoci) 

local stat	 	 	= "Excluded for missing data in confounder or outcome"
local tabord 		= `tabord' + 1
local tot		 	= matstat[1,1]
local totbrack 		= round(100*matstat[1,1]/`TOT', 0.01)
local totASD 		= matstatASD[1,2]
local totASDbrack	= round(100*matstatASD[1,2]/`TOTASD', 0.01)
local totscdc 		= matstatscdc[1,2]
local totscdcbrack	= round(100*matstatscdc[1,2]/`TOTscdc', 0.01)
local totcohe 		= matstatcohe[1,2]
local totcohebrack	= round(100*matstatcohe[1,2]/`TOTcohe', 0.01)
local totrepb 		= matstatrepb[1,2]
local totrepbbrack	= round(100*matstatrepb[1,2]/`TOTrepb', 0.01)
local totsoci 		= matstatsoci[1,2]
local totsocibrack	= round(100*matstatsoci[1,2]/`TOTsoci', 0.01)

post `memhold' ("`stat'") 	(`tabord') ///
			   (`tot') 		(`totbrack') /// 
			   (`totASD') 	(`totASDbrack') ///
			   (`totscdc') 	(`totscdcbrack') ///
			   (`totcohe') 	(`totcohebrack') ///
			   (`totrepb') 	(`totrepbbrack') ///
			   (`totsoci') 	(`totsocibrack') 



* remaining after exclusions for missing data
local stat	 	 	= "Remaining in complete case analysis"
local tabord 		= `tabord' + 1
local tot		 	= matstat[2,1]
local totbrack 		= round(100*matstat[2,1]/`TOT', 0.01)
local totASD 		= matstatASD[2,2]
local totASDbrack	= round(100*matstatASD[2,2]/`TOTASD', 0.01)
local totscdc 		= matstatscdc[2,2]
local totscdcbrack	= round(100*matstatscdc[2,2]/`TOTscdc', 0.01)
local totcohe 		= matstatcohe[2,2]
local totcohebrack	= round(100*matstatcohe[2,2]/`TOTcohe', 0.01)
local totrepb 		= matstatrepb[2,2]
local totrepbbrack	= round(100*matstatrepb[2,2]/`TOTrepb', 0.01)
local totsoci 		= matstatsoci[2,2]
local totsocibrack	= round(100*matstatsoci[2,2]/`TOTsoci', 0.01)

post `memhold' ("`stat'") 	(`tabord') ///
			   (`tot') 		(`totbrack') /// 
			   (`totASD') 	(`totASDbrack') ///
			   (`totscdc') 	(`totscdcbrack') ///
			   (`totcohe') 	(`totcohebrack') ///
			   (`totrepb') 	(`totrepbbrack') ///
			   (`totsoci') 	(`totsocibrack') 		   


	   

postclose `memhold'

use "flowchart_out.dta", clear
tostring totbrack, format("%5.2f") gen(totbrackc) force
tostring totasdbrack, format("%5.2f") gen(totasdbrackc) force
tostring totscdcbrack, format("%5.2f") gen(totscdcbrackc) force
tostring totcohebrack, format("%5.2f") gen(totcohebrackc) force
tostring totrepbbrack, format("%5.2f") gen(totrepbbrackc) force
tostring totsocibrack, format("%5.2f") gen(totsocibrackc) force


export delim using "flowchart.csv", replace delim(,)


log close