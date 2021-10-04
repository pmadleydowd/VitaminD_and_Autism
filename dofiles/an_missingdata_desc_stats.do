log using "$Logdir\LOG_an_missingdata_desc_stats.txt", text replace
********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2021-07-23
* Description: Descriptive statistics of missing data for ALSPAC vitamin D data
********************************************************************************
* Contents
************
* 1 Create environment
* 2 Missing data descriptives tables for categorical variables
* 3 Missing data descriptives tables for normally distributed variables
* create formats in each dataset

********************************************************************************
* 1 create environment and load data
*************************************
cd "$Datadir\Missing data"
use "$Datadir\DERIVED_VitD_dat.dta", clear

keep if flag_mat_white_eth 	== 1
keep if flag_alive1yr 		== 1
keep if flag_singleton		== 1
keep if flag_outcomeany 	== 1
keep if miss_exposure		== 0 

********************************************************************************
* 2 Missing data descriptives tables for categorical variables
*******************************************************
capture postutil close 
tempname memhold 

postfile `memhold' str20 stat statlev tabord ///
				   Total Totalbrack ///
				   asd asdbrack asdOR asdLCI asdUCI ///
				   scdc scdcbrack scdcOR scdcLCI scdcUCI ///
				   cohe cohebrack coheOR coheLCI coheUCI ///
				   repb repbbrack repbOR repbLCI repbUCI ///
				   soci socibrack sociOR sociLCI sociUCI ///
   				   fm   fmbrack   fmOR   fmLCI   fmUCI ///
				   using "Missdat_Cat.dta", replace

tab flag_cca_asd,  matcell(matasdcca)
tab flag_cca_scdc, matcell(matscdccca)
tab flag_cca_cohe, matcell(matcohecca)
tab flag_cca_repb, matcell(matrepbcca)
tab flag_cca_soci, matcell(matsocicca)
tab flag_cca_fm,   matcell(matfmcca)


local stat	 	 = "Total"
local statlev	 = .
local tabord     = 0

local Total 	 = _N
local Totalbrack = .

local asd 		 =  matasdcca[2,1]
local asdbrack   = .
local asdOR    	 = . 
local asdLCI 	 = . 
local asdUCI 	 = . 

	
local scdc 		 = matscdccca[2,1]
local scdcbrack  = . 
local scdcOR 	 = . 
local scdcLCI 	 = .
local scdcUCI 	 = .


local cohe 		 = matcohecca[2,1]
local cohebrack  = . 
local coheOR     = . 
local coheLCI    = . 
local coheUCI    = . 

			
local repb		 = matrepbcca[2,1]
local repbbrack  = . 
local repbOR 	 = . 
local repbLCI  	 = . 
local repbUCI  	 = . 


local soci		 = matsocicca[2,1]
local socibrack  = . 
local sociOR	 = . 
local sociLCI 	 = . 
local sociUCI 	 = . 

local fm		 = matfmcca[2,1]
local fmbrack    = . 
local fmOR	 	 = . 
local fmLCI 	 = . 
local fmUCI 	 = . 


post `memhold' ("`stat'") (`statlev') (`tabord') ///
			   (`Total') (`Totalbrack') ///
			   (`asd') (`asdbrack') (`asdOR') (`asdLCI') (`asdUCI') ///
			   (`scdc') (`scdcbrack') (`scdcOR') (`scdcLCI') (`scdcUCI') ///
			   (`cohe') (`cohebrack') (`coheOR') (`coheLCI') (`coheUCI') ///
			   (`repb') (`repbbrack') (`repbOR') (`repbLCI') (`repbUCI') ///
			   (`soci') (`socibrack') (`sociOR') (`sociLCI') (`sociUCI') ///
			   (`fm ')  (`fmbrack')   (`fmOR')   (`fmLCI')   (`fmUCI')


foreach stat in male parity_cat mat_smok_bin18wk  matEdDrv finDifDrv manual ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability homeowner marital {
	tab `stat', matcell(matcountTotal)
	local nlevs = r(r)

	tab `stat' flag_cca_asd,  matcell(matcountasd) matrow(statlevs)
	tab `stat' flag_cca_scdc, matcell(matcountscdc)	
	tab `stat' flag_cca_cohe, matcell(matcountcohe)
	tab `stat' flag_cca_repb, matcell(matcountrepb)
	tab `stat' flag_cca_soci, matcell(matcountsoci)	
	tab `stat' flag_cca_fm,   matcell(matcountfm)	
	
	
	logistic flag_cca_asd i.`stat'
	est store A
	logistic flag_cca_scdc i.`stat'
	est store B
	logistic flag_cca_cohe i.`stat'
	est store C
	logistic flag_cca_repb i.`stat'
	est store D
	logistic flag_cca_soci i.`stat'
	est store E
	logistic flag_cca_fm i.`stat'
	est store F	
	
	local tabord = `tabord' + 1

	forvalues lev = 1(1)`nlevs' {
		disp `lev'
		local statlev = statlevs[`lev',1]
		
		local Total		 = matcountTotal[`lev',1] 
		local Totalbrack = 100*matcountTotal[`lev',1] /_N
	
		local asd 		 = matcountasd[`lev',2]
		local asdbrack   = 100*matcountasd[`lev',2]/matasdcca[2,1]
		local scdc 		 = matcountscdc[`lev',2]
		local scdcbrack  = 100*matcountscdc[`lev',2]/matscdccca[2,1] 
		local cohe 		 = matcountcohe[`lev',2]
		local cohebrack  = 100*matcountcohe[`lev',2]/matcohecca[2,1] 
		local repb		 = matcountrepb[`lev',2]
		local repbbrack  = 100*matcountrepb[`lev',2]/matrepbcca[2,1] 
		local soci		 = matcountsoci[`lev',2]
		local socibrack  = 100*matcountsoci[`lev',2]/matsocicca[2,1] 
		local fm		 = matcountfm[`lev',2]
		local fmbrack    = 100*matcountfm[`lev',2]/matfmcca[2,1]
		
		est restore A
		local asdOR    	 = exp(e(b)[1,`lev']) 
		local asdLCI 	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev']))
		local asdUCI 	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev']))

		est restore B
		local scdcOR 	 = exp(e(b)[1,`lev'])  
		local scdcLCI 	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev']))
		local scdcUCI 	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev']))

		est restore C
		local coheOR     = exp(e(b)[1,`lev'])  
		local coheLCI    = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
		local coheUCI    = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 

		est restore D	
		local repbOR 	 = exp(e(b)[1,`lev'])  
		local repbLCI  	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
		local repbUCI  	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 

		est restore E		
		local sociOR	 = exp(e(b)[1,`lev'])  
		local sociLCI 	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
		local sociUCI 	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
		
		est restore F		
		local fmOR	     = exp(e(b)[1,`lev'])  
		local fmLCI 	 = exp(e(b)[1,`lev'] - invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
		local fmUCI 	 = exp(e(b)[1,`lev'] + invnormal(0.975)*sqrt(e(V)[`lev',`lev'])) 
		
		post `memhold' ("`stat'") (`statlev') (`tabord') ///
					   (`Total') (`Totalbrack') ///
					   (`asd')  (`asdbrack')  (`asdOR')  (`asdLCI')  (`asdUCI')  ///
					   (`scdc') (`scdcbrack') (`scdcOR') (`scdcLCI') (`scdcUCI') ///
					   (`cohe') (`cohebrack') (`coheOR') (`coheLCI') (`coheUCI') ///
					   (`repb') (`repbbrack') (`repbOR') (`repbLCI') (`repbUCI') ///
					   (`soci') (`socibrack') (`sociOR') (`sociLCI') (`sociUCI') ///	
					   (`fm ')  (`fmbrack')   (`fmOR')   (`fmLCI')   (`fmUCI')

	}
}

postclose `memhold'



********************************************************************************
* 3 Missing data descriptives tables for normally distributed variables
*****************************************************
capture postutil close 
tempname memhold 

postfile `memhold' str25 stat statlev tabord ///
				   Total Totalbrack ///
				   asd asdbrack asdOR asdLCI asdUCI ///
				   scdc scdcbrack scdcOR scdcLCI scdcUCI ///
				   cohe cohebrack coheOR coheLCI coheUCI ///
				   repb repbbrack repbOR repbLCI repbUCI ///
				   soci socibrack sociOR sociLCI sociUCI ///
   				   fm   fmbrack   fmOR   fmLCI   fmUCI ///				   
				   using "Missdat_Cont.dta", replace	   

foreach stat in matage prepregBMI sadj_vitd_10 zscore_vd_mom_prs_S13 zscore_vd_child_prs_S13 zmf_asd {
	local tabord = `tabord' + 1
	local statlev = 1
	
	summarize `stat'
	local Total		 = r(mean)
	local Totalbrack = r(sd)	
		
	summarize `stat' if flag_cca_asd==1
	local asd 		 = r(mean)
	local asdbrack   = r(sd)	
	logistic flag_cca_asd `stat'
	local asdOR    	 = exp(e(b)[1,1]) 
	local asdLCI 	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1]))
	local asdUCI 	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1]))	
	
	
	summarize `stat' if flag_cca_scdc==1	
	local scdc 		 = r(mean)
	local scdcbrack  = r(sd) 
	logistic flag_cca_scdc `stat'
	local scdcOR 	 = exp(e(b)[1,1])  
	local scdcLCI 	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1]))
	local scdcUCI 	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1]))	
	
	summarize `stat' if flag_cca_cohe==1
	local cohe 		 = r(mean)
	local cohebrack  = r(sd) 
	logistic flag_cca_cohe `stat'
	local coheOR     = exp(e(b)[1,1])  
	local coheLCI    = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1])) 
	local coheUCI    = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1])) 
	
	
	summarize `stat' if flag_cca_repb==1
	local repb		 = r(mean)
	local repbbrack  = r(sd) 
	logistic flag_cca_repb `stat'
	local repbOR 	 = exp(e(b)[1,1])  
	local repbLCI  	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1])) 
	local repbUCI  	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1])) 
	
	
	summarize `stat' if flag_cca_soci==1	
	local soci		 = r(mean)
	local socibrack  = r(sd) 
	logistic flag_cca_soci `stat'
	local sociOR	 = exp(e(b)[1,1])  
	local sociLCI 	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1])) 
	local sociUCI 	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1])) 
	
	summarize `stat' if flag_cca_fm==1	
	local fm		 = r(mean)
	local fmbrack    = r(sd) 
	logistic flag_cca_fm `stat'
	local fmOR	     = exp(e(b)[1,1])  
	local fmLCI 	 = exp(e(b)[1,1] - invnormal(0.975)*sqrt(e(V)[1,1])) 
	local fmUCI 	 = exp(e(b)[1,1] + invnormal(0.975)*sqrt(e(V)[1,1])) 

	
	post `memhold' ("`stat'") (`statlev') (`tabord') ///
				   (`Total') (`Totalbrack') ///
				   (`asd')  (`asdbrack')  (`asdOR')  (`asdLCI')  (`asdUCI')  ///
				   (`scdc') (`scdcbrack') (`scdcOR') (`scdcLCI') (`scdcUCI') ///
				   (`cohe') (`cohebrack') (`coheOR') (`coheLCI') (`coheUCI') ///
				   (`repb') (`repbbrack') (`repbOR') (`repbLCI') (`repbUCI') ///
				   (`soci') (`socibrack') (`sociOR') (`sociLCI') (`sociUCI') ///	
				   (`fm ')  (`fmbrack')   (`fmOR')   (`fmLCI')   (`fmUCI')
}

postclose `memhold'


********************************************************************************
* create formats in each dataset
**********************************
use "Missdat_Cat.dta", clear
append  using "Missdat_Cont.dta"
do "$Dodir\an_desc_formats.do"

tostring Total, gen(Total_c) force
tostring Total, gen(Total_c_cont) format(%5.2f) force
replace  Total_c=Total_c_cont if tabord > 13 // update #13 if number of variables changes
tostring Totalbrack, gen(Totalbrack_c) format(%5.2f) force

tostring asd, gen(asd_c) force
tostring asd, gen(asd_c_cont) format(%5.2f) force
replace  asd_c=asd_c_cont if tabord > 13 // update #13 if number of variables changes
tostring asdbrack, gen(asdbrack_c) format(%5.2f) force

tostring scdc, gen(scdc_c) force
tostring scdc, gen(scdc_c_cont) format(%5.2f) force
replace  scdc_c=scdc_c_cont if tabord > 13 // update #13 if number of variables changes
tostring scdcbrack, gen(scdcbrack_c) format(%5.2f) force

tostring cohe, gen(cohe_c) force
tostring cohe, gen(cohe_c_cont) format(%5.2f) force
replace  cohe_c=cohe_c_cont if tabord > 13 // update #13 if number of variables changes
tostring cohebrack, gen(cohebrack_c) format(%5.2f) force

tostring repb, gen(repb_c) force
tostring repb, gen(repb_c_cont) format(%5.2f) force
replace  repb_c=repb_c_cont if tabord > 13 // update #13 if number of variables changes
tostring repbbrack, gen(repbbrack_c) format(%5.2f) force

tostring soci, gen(soci_c) force
tostring soci, gen(soci_c_cont) format(%5.2f) force
replace  soci_c=soci_c_cont if tabord > 13 // update #13 if number of variables changes
tostring socibrack, gen(socibrack_c) format(%5.2f) force

tostring fm, gen(fm_c) force
tostring fm, gen(fm_c_cont) format(%5.2f) force
replace  fm_c=fm_c_cont if tabord > 13 // update #13 if number of variables changes
tostring fmbrack, gen(fmbrack_c) format(%5.2f) force

gen outTotal = Total_c if _n == 1
replace outTotal = Total_c + " (" + Totalbrack_c + ")" if _n>1

gen outasd = asd_c if _n == 1
replace outasd = asd_c + " (" + asdbrack_c + ")" if _n>1

gen outscdc = scdc_c if _n == 1
replace outscdc = scdc_c + " (" + scdcbrack_c + ")" if _n>1

gen outcohe = cohe_c if _n == 1
replace outcohe = cohe_c + " (" + cohebrack_c + ")" if _n>1

gen outrepb = repb_c if _n == 1
replace outrepb = repb_c + " (" + repbbrack_c + ")" if _n>1

gen outsoci = soci_c if _n == 1
replace outsoci = soci_c + " (" + socibrack_c + ")" if _n>1

gen outfm = fm_c if _n == 1
replace outfm = fm_c + " (" + fmbrack_c + ")" if _n>1

gen asdORCI  = strofreal(asdOR, "%5.2f") + " (" + strofreal(asdLCI, "%5.2f") + "-" + strofreal(asdUCI, "%5.2f") + ")" if _n>1 & asdOR != 1
replace asdORCI = "Ref" if _n>1 & asdORCI == ""

gen scdcORCI = strofreal(scdcOR, "%5.2f") + " (" + strofreal(scdcLCI, "%5.2f") + "-" + strofreal(scdcUCI, "%5.2f") + ")" if _n>1 & scdcOR != 1
replace scdcORCI = "Ref" if _n>1 & scdcORCI == ""

gen coheORCI = strofreal(coheOR, "%5.2f") + " (" + strofreal(coheLCI, "%5.2f") + "-" + strofreal(coheUCI, "%5.2f") + ")" if _n>1 & coheOR != 1
replace coheORCI = "Ref" if _n>1 & coheORCI == ""

gen repbORCI = strofreal(repbOR, "%5.2f") + " (" + strofreal(repbLCI, "%5.2f") + "-" + strofreal(repbUCI, "%5.2f") + ")" if _n>1 & repbOR != 1
replace repbORCI = "Ref" if _n>1 & repbORCI == ""

gen sociORCI = strofreal(sociOR, "%5.2f") + " (" + strofreal(sociLCI, "%5.2f") + "-" + strofreal(sociUCI, "%5.2f") + ")" if _n>1 & sociOR != 1
replace sociORCI = "Ref" if _n>1 & sociORCI == ""

gen fmORCI = strofreal(fmOR, "%5.2f") + " (" + strofreal(fmLCI, "%5.2f") + "-" + strofreal(fmUCI, "%5.2f") + ")" if _n>1 & fmOR != 1
replace fmORCI = "Ref" if _n>1 & fmORCI == ""

keep stat_c statlev_c out* *ORCI 
rename out* * 
order stat* Total asd* scdc* cohe* repb* soci* fm*
export delim using "Missing_data_desc.csv", delim(",") replace


log close

