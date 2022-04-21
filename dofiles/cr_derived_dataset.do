capture log close
log using "$Logdir\LOG_cr_derived_dataset.txt", replace text 
********************************************************************************
* Author: 		Paul Madley-Dowd
* Date: 		14/07/2021
* Description: 	Data derivations for vitamin D and autism project 
********************************************************************************
* Contents
* 1 Create environment
* 2 Prepare exposure information
* 3 Prepare outcome information
* 4 Prepare confounder information
* 5 Merge propensity score information
* 6 Create exclusion flags
* 7 Create flags for inclusion in CCA
* 8 Create quintiles of vitamin D in the eligible sample
* 9 Derive auxiliary variables for multiple imputation

* Create labels
* Restrict to only necessary variables
* Save data
********************************************************************************
* 1 Create environment
********************************************************************************
* load data
use "$Datadir\RAW_VitD_dat.dta", clear 


********************************************************************************
* 2 Prepare exposure information
********************************************************************************
* create date of delivery in days (assume 1st of month as day of birth)
gen Tdeliv = mdy(mz024a, 1, mz024b)
format %d Tdeliv 

* create difference in gestational age at delivery and measure of vitamin d 
replace VitD_gest = . if VitD_gest < 0
gen dif_gest = bestgest - round(VitD_gest)
gen dif_gest_days = dif_gest * 7

* calulate date variable for measure of vitamin d
gen TVitD = Tdeliv - dif_gest_days
format %d TVitD

* clean Vit D measure 
replace VitDtot_preg = . if VitDtot_preg == - 1
replace VitDtot_preg = . if dif_gest < 0 // removing those who may have been measured after pregnancy 
gen flag_VitD_measafterpreg = 1 if dif_gest < 0 // flag to indicate those who may have been measured after pregnancy 



* Derive seasonally and gestational age adjusted measures of vitamin D
sort aln qlet
	* time variables for plotting:
gen day = doy(TVitD)
gen year = year(TVitD)
gen date= year+ day/365

					
	* Index variable indicating day of study scaled from 0 to 1 where 0=1st July 1990 and 1=30th June 1993:
local s= date("7-1-1990", "MDY")
local e= date("6-30-1993", "MDY")
gen Tcal=(TVitD - `s')/(`e'-`s')
summ Tcal								

	* logged vit D for modelling
gen lnVitDtot_preg = ln(VitDtot_preg)

	* Cosine functions
forvalues i = 1/6	{
	gen sin`i' = sin(`i'*2*_pi*Tcal)
	gen cos`i' = cos(`i'*2*_pi*Tcal)
					}
	* Adjust tot vit D for season
regress lnVitDtot_preg sin1 cos1 sin2 cos2 sin3 cos3 sin4 cos4 
	testparm sin4 cos4
	predict xb
	predict sa_lnVitDtot_preg_S , residual
	gen exb = exp(xb)
	gen sa_VitDtot_preg_S=VitDtot_preg-exb
	summ lnVitDtot_preg
	gen sa_VitDtot_preg_Sm=sa_VitDtot_preg_S+exp(r(mean))
	label variable sa_VitDtot_preg_S "seas.adj (MattotvitDnMol-e^xb)"
	label variable sa_lnVitDtot_preg_S "seas.adj res (lnMattotvitDnMol)"
	label variable sa_VitDtot_preg_Sm "seas.adj ((MattotvitDnMol-e^xb)+antlog geometric mean"
	predict res1 , residual
	predict r , rstandard


	* Plot of seasonally adjusted measures:
di mdy(7, 1, 1990)
set scheme s1color
scatter lnVitDtot_preg TVitD , msize(tiny) mcolor(gs12) || line xb TVitD , sort(Tcal)  || 	///
		, ytitle(log 25(OH)D (nMol/l)) xtitle(Date(days)) legend(off) name(a , replace) xlabel(11139 "01 July 1990" 11504 "01 July 1991" 11870 "01 July 1992")
		
scatter VitDtot_preg TVitD , msize(tiny) mcolor(gs12) || line exb TVitD , sort(Tcal)  || 	///
		, ytitle(Vit D (nMol/l)) xtitle(date) legend(off) name(b , replace) xlabel(11139 "01 July 1990" 11504 "01 July 1991" 11870 "01 July 1992")
		
hist sa_lnVitDtot_preg_S , name(d , replace) xtitle(residual)
graph combine a  d , cols(1)
graph export "$Graphdir\SeasAdj_VitD.tif", as(tif) replace

line exb Tcal , sort lcolor(black)  yscale(range(20 120)) ytitle(vitD nmolL) xtitle(date)
capture drop xb exb res1 r



	* Adjust all measures to 34 weeks:
gen D=(7 - round(VitD_gest))*7
local S= 1/(date("6-30-1993", "MDY")-date("7-1-1990", "MDY")) // conversion factor 1day=Sunits on standardised date scale
gen T=Tcal+D*`S'		// calendar date (standardised) to which we adjust to for each individual
forvalues i = 1/6	{ // cosine terms for T which go in the model to adjust		
	g Tsin`i' = sin(`i'*2*_pi*T)
	g Tcos`i' = cos(`i'*2*_pi*T)
					} 		
gen sa_7wk_VitDtot_preg=exp(_b[_cons] + _b[sin1]*Tsin1 + _b[sin2]*Tsin2 + _b[sin3]*Tsin3 + _b[sin4]*Tsin4 +	_b[cos1]*Tcos1 + _b[cos2]*Tcos2 + _b[cos3]*Tcos3 + _b[cos4]*Tcos4 +	sa_lnVitDtot_preg_S)
label variable  sa_7wk_VitDtot_preg "Maternal 25(OH)D (nMol/L) adjusted to 7 weeks"
drop D Tsin* Tcos* T
gen ln_sa_7wk_VitDtot_preg=ln(sa_7wk_VitDtot_preg)
label variable ln_sa_7wk_VitDtot_preg "ln(Maternal 25(OH)D (nMol/L) adjusted to 7 weeks)"


	* Adjust all measures to 20 weeks:
gen D=(20 - round(VitD_gest))*7
local S= 1/(date("6-30-1993", "MDY")-date("7-1-1990", "MDY")) // conversion factor 1day=Sunits on standardised date scale
gen T=Tcal+D*`S'		// calendar date (standardised) to which we adjust to for each individual
forvalues i = 1/6	{ // cosine terms for T which go in the model to adjust		
	g Tsin`i' = sin(`i'*2*_pi*T)
	g Tcos`i' = cos(`i'*2*_pi*T)
					} 		
gen sa_20wk_VitDtot_preg=exp(_b[_cons] + _b[sin1]*Tsin1 + _b[sin2]*Tsin2 + _b[sin3]*Tsin3 + _b[sin4]*Tsin4 +	_b[cos1]*Tcos1 + _b[cos2]*Tcos2 + _b[cos3]*Tcos3 + _b[cos4]*Tcos4 +	sa_lnVitDtot_preg_S)
label variable  sa_20wk_VitDtot_preg "Maternal 25(OH)D (nMol/L) adjusted to 20 weeks"
drop D Tsin* Tcos* T
gen ln_sa_20wk_VitDtot_preg=ln(sa_20wk_VitDtot_preg)
label variable ln_sa_20wk_VitDtot_preg "ln(Maternal 25(OH)D (nMol/L) adjusted to 20 weeks)"

	* Adjust all measures to 34 weeks:
gen D=(34 - round(VitD_gest))*7
local S= 1/(date("6-30-1993", "MDY")-date("7-1-1990", "MDY")) // conversion factor 1day=Sunits on standardised date scale
gen T=Tcal+D*`S'		// calendar date (standardised) to which we adjust to for each individual
forvalues i = 1/6	{ // cosine terms for T which go in the model to adjust		
	g Tsin`i' = sin(`i'*2*_pi*T)
	g Tcos`i' = cos(`i'*2*_pi*T)
					} 		
gen sa_34wk_VitDtot_preg=exp(_b[_cons] + _b[sin1]*Tsin1 + _b[sin2]*Tsin2 + _b[sin3]*Tsin3 + _b[sin4]*Tsin4 +	_b[cos1]*Tcos1 + _b[cos2]*Tcos2 + _b[cos3]*Tcos3 + _b[cos4]*Tcos4 +	sa_lnVitDtot_preg_S)
label variable  sa_34wk_VitDtot_preg "Maternal 25(OH)D (nMol/L) adjusted to 34 weeks"
drop D Tsin* Tcos* T
gen ln_sa_34wk_VitDtot_preg=ln(sa_34wk_VitDtot_preg)
label variable ln_sa_34wk_VitDtot_preg "ln(Maternal 25(OH)D (nMol/L) adjusted to 34 weeks)"


* create categorical measures 
recode sa_7wk_VitDtot_preg (0/24.999 = 1) (25/50 = 2) (50.001/max = 3) , gen(sa_7wk_VitD_Cat)
recode sa_20wk_VitDtot_preg (0/24.999 = 1) (25/50 = 2) (50.001/max = 3) , gen(sa_20wk_VitD_Cat)
recode sa_34wk_VitDtot_preg (0/24.999 = 1) (25/50 = 2) (50.001/max = 3) , gen(sa_34wk_VitD_Cat)

label define lb_vitdcats 1 "Deficient" 2 "Insufficient" 3 "Sufficient"
label values sa_7wk_VitD_Cat sa_20wk_VitD_Cat sa_34wk_VitD_Cat lb_vitdcats


* create variable indicating 10 nmolL change in vitD at each time point 
gen sa_7wk_VitDtot_10 =  sa_7wk_VitDtot_preg/10 
gen sa_20wk_VitDtot_10 = sa_20wk_VitDtot_preg/10 
gen sa_34wk_VitDtot_10 = sa_34wk_VitDtot_preg/10

label variable sa_7wk_VitDtot_10 "Maternal 25(OH)D (10 nMol/L) adjusted to 7 weeks"
label variable sa_20wk_VitDtot_10 "Maternal 25(OH)D (10 nMol/L) adjusted to 20 weeks"
label variable sa_34wk_VitDtot_10 "Maternal 25(OH)D (10 nMol/L) adjusted to 34 weeks"

hist sa_20wk_VitDtot_preg, 
graph export "$Graphdir\SeasAdj_VitD20wk_hist.tif", as(tif) replace


********************************************************************************
* 3 Prepare outcome information
********************************************************************************
* Derive autistic trait measures to match https://www.nature.com/articles/srep46179.pdf
	* scdc 
gen scdc = kr554b 
replace scdc = . if kr554b == -6 

	* speech coherence 
gen coherence = ku506b
replace coherence = . if coherence < 0 | coherence == .b

	* repetitive behaviour 
gen _rb1 = kn3110
gen _rb2 = kn3111
gen _rb3 = kn3112
gen _rb4 = kn5140
forvalues i = 1/4 {
	replace _rb`i' = . if _rb`i'<1
}	
replace _rb4 = 3 if _rb4 == 7 
recode _rb1 (3=1) (1=3)
recode _rb2 (3=1) (1=3)
recode _rb3	(3=1) (1=3)
gen repbehaviour = _rb1 + _rb2 + _rb3 + _rb4

	* sociability
gen sociability = kg623b
replace sociability = . if inlist(sociability, -6, -5, ., .b)
	

* create binary variable for each trait to match https://www.nature.com/articles/srep46179.pdf 
gen bin_scdc = scdc > 5 if scdc != . 
gen bin_coherence = coherence < 34 if coherence != . 
gen bin_repbehaviour = repbehaviour > 4 if repbehaviour != .
gen bin_sociability = sociability < 15 if sociability != . 

label var bin_scdc "Social Communication Trait"
label var bin_coherence "Speech Coherence Trait"
label var bin_repbehaviour "Repetitive Behaviour Trait"
label var bin_sociability "Sociability Temperament Trait"


* rename autism variable 
rename autism_new_confirmed_ ASD
replace ASD = . if ASD == .a | ASD == .b
label var ASD "Diagnosed Autism"


*Inverse autism factor mean scores so that positive scores reflect more ASD difficulties
rename clon207 fm
replace fm = . if fm <-100
summarize fm
gen mf1= fm*(-1) if fm>0 & fm!=. 
gen mf2= abs(fm) if fm<0 & fm!=.

gen mf_asd = max(mf1, mf2) 

*Standardize
egen zmf_asd= std(mf_asd)
label var zmf_asd "Mean Autism Factor Score"


********************************************************************************
* 4 Prepare confounder information
********************************************************************************
* maternal smoking at 18 weeks 
replace b650 = . if b650 < 0  // replace missing questionnaire value with missing value (general) 
replace b659 = . if b659 < 0
replace b670 = . if b670 < 0
replace b671 = . if b671 < 0

gen mat_curr_smok = b650 == 1 & b659 != 1 if missing(b650) == 0 // defining current smoker as reporting having been a smoker and not reporting they have now stopped
gen mat_rep_smok = 1 if ( b670 > 0 & missing(b670) == 0 ) ///
						| ( b671 > 0 & missing(b671) == 0 ) 
replace mat_rep_smok = 0 if b670 == 0 & b671 == 0  ///
						| b670 == 0 & missing(b671) == 1 ///
						| missing(b670) == 1 & b671 == 0

gen mat_smok_bin18wk = mat_curr_smok == 1  | mat_rep_smok ==1 if missing(mat_curr_smok) + missing(mat_rep_smok) < 2	
label var mat_smok_bin18wk "Any maternal smoking at 18 weeks gestation"


* male sex
gen male = 1 if kz021 == 1
replace male = 0 if kz021 == 2
label var male "Offspring male sex"


* parity 
rename b032		parity
egen parity_cat = cut(parity), at(-7,0,1,2,25) 
replace parity_cat=. if parity<0
lab var parity_cat "Parity"


* pre pregnancy BMI
replace dw002 = . if dw002 < 0  // replace missing questionnaire value with missing value (general) 
replace dw021 = . if dw021 < 0 
gen prepregBMI = dw002/((dw021/100)^2)
label variable prepregBMI "Maternal pre-pregnancy BMI"


* socioeconomic status variables 
	* maternal highest education
rename c645a 	matEd
gen 	matEdDrv = 1 if matEd == 2 // vocational 
replace matEdDrv = 2 if matEd == 1 | matEd ==3 // CSE/Olevel
replace matEdDrv = 3 if matEd == 4 | matEd == 5  // A level/Degree
replace matEdDrv=. 	  if matEd<0
lab var matEdDrv "Maternal highest educational qualification" 

	* maternal age 
rename mz028b 	matage
replace matage = . if matage < 0
label var matage "Maternal age at delivery"

	* financial difficulty
rename c525 finDif
replace finDif = . if finDif < 0
xtile finDifDec = finDif, n(10)
gen finDifDrv = finDifDec == 10 if finDifDec !=.
label variable finDifDrv "Financial difficulties in pregnancy"

	* maternal manual occupational class
recode c755 (1/3=0) (4/6=1) (-1=.) (65=.), gen(manual)
replace manual = . if manual == .a
label variable manual "Maternal manual occupation"



********************************************************************************
* 5 Merge polygenic risk score information for vitamin d
********************************************************************************
merge m:1 aln using "$Rawdatdir\MotherPRS.dta", nogen keep(1 3)
merge 1:1 aln qlet using "$Rawdatdir\ChildPRS.dta", nogen keep(1 3)
merge m:1 aln using "$Rawdatdir\mat_PCs.dta", nogen keep(1 3)

egen zscore_vd_mom_prs = std(VitD_mPRS)
egen zscore_vd_child_prs = std(VitD_cPRS)

label variable  zscore_vd_mom_prs "Maternal Standardised Genetic 25(OH)D score"
label variable  zscore_vd_child_prs "Offspring Standardised Genetic 25(OH)D score"

********************************************************************************
* 6 Create exclusion flags
********************************************************************************
* derive flag for maternal white ethnicity
replace c800 = . if c800==.a
replace c800 = . if c800==-1
gen flag_mat_white_eth = 1 if c800==1
replace flag_mat_white_eth = 0 if c800!=1 & c800 != . 
gen flag_nomiss_mateth = flag_mat_white_eth !=. // indicates that maternal ethnicity is not missing

* alive at one year 
gen flag_alive1yr = kz011b == 1 

* singleton
gen flag_singleton = mz010a == 1

* any outcome information
egen miss_outcome = rowmiss(ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability zmf_asd)
gen flag_outcomeany = miss_outcome < 6 

* any exposure information
egen miss_exposure = rowmiss(sa_20wk_VitDtot_preg)
gen flag_exposureany = miss_exposure < 1 

* missing any confounder information 
egen miss_confounder = rowmiss(mat_smok_bin18wk male parity_cat prepregBMI matEdDrv matage finDifDrv manual)
gen flag_conf_allnomiss = miss_conf<1
gen miss_prepreg = missing(prepregBMI)
gen miss_matage = missing(matage)

* missing autism factor mean score
gen miss_afm = missing(zmf_asd)
gen flag_afm = 1 - miss_afm

* PRS score available  
gen flag_mPRS_avail = 1 - missing(zscore_vd_mom_prs)
gen flag_cPRS_avail = 1 - missing(zscore_vd_child_prs)


* meet inclusion criteria sample
gen flag_inclusion =  flag_alive1yr 	 	== 1 & ///
					  flag_singleton		== 1 & ///
					  flag_outcomeany 		== 1 & ///
					  miss_exposure			== 0 
						  



********************************************************************************
* 7 Create flags for inclusion in CCA
********************************************************************************
* Create missing data flags
gen miss_asd  = missing(ASD)
gen miss_scdc = missing(bin_scdc)
gen miss_soci = missing(bin_sociability)
gen miss_repb = missing(bin_repbehaviour)
gen miss_cohe = missing(bin_coherence)
gen miss_fm   = missing(zmf_asd)


* Create flags for inclusion in complete case analysis for each outcome
gen flag_cca_asd  = miss_confounder == 0 & miss_exposure ==0 & miss_asd ==0 
gen flag_cca_scdc = miss_confounder == 0 & miss_exposure ==0 & miss_scdc ==0 
gen flag_cca_soci = miss_confounder == 0 & miss_exposure ==0 & miss_soci ==0 
gen flag_cca_repb = miss_confounder == 0 & miss_exposure ==0 & miss_repb ==0 
gen flag_cca_cohe = miss_confounder == 0 & miss_exposure ==0 & miss_cohe ==0 
gen flag_cca_fm   = miss_confounder == 0 & miss_exposure ==0 & miss_fm ==0 



********************************************************************************
* 8 Create quintiles of vitamin D in the eligible sample
********************************************************************************
* create quintiles of exposure for vitamin d variables
xtile quint_savitd_7wk  = sa_7wk_VitDtot_preg  if flag_inclusion == 1 , n(5)
xtile quint_savitd_20wk = sa_20wk_VitDtot_preg if flag_inclusion == 1 , n(5)
xtile quint_savitd_34wk = sa_34wk_VitDtot_preg if flag_inclusion == 1 , n(5)


********************************************************************************
* 9 Derive auxiliary variables for multiple imputation
********************************************************************************
* Home ownership status
gen homeowner = a006 if a006 >=0  & !missing(a006)
recode homeowner (0/1=1) (2=2) (3/5=3) (6=4) // 1 = owned/mortgaged, 2 = council rented, 3 = privately rented, 4 = other
lab var homeowner "Home ownership status"

* Marital status
gen marital = a525 if a525 >= 0 & !missing(a525)
recode marital (-1 = .) (1=1) (2/4=2) (5=3) (6=4) // 1 = never married, 2 = previously married (currently unmarried), 3 = 1st marriage, 4 = 2nd or 3rd marriage
lab var marital "Marital status"


********************************************************************************
* Create labels
********************************************************************************
label define lb_binYN 1 "Yes" 0 "No"
label values ASD mat_smok_bin18wk finDifDrv lb_binYN

label define lab_sex 0 "Female" 1 "Male"
label values male lab_sex

lab define lab_ed 1 "Vocational" 2 "CSE/O level" 3 "A level/Degree"
lab values matEdDrv lab_ed

lab define lab_parity 0 "0" 1 "1" 2 "2+" 
lab values parity_cat lab_parity

lab define lab_sclass 0"Non-Manual" 1"Manual" 
lab values manual lab_sclass

lab define lab_homeowner 1 "Owned/mortgaged" 2 "Council rented" 3 "Privately rented" 4 "Other"
lab values homeowner lab_homeowner

lab define lab_marital 1 "Never married" 2 "Previously married (currently unmarried)" 3 "1st marriage" 4 "2nd or 3rd marriage"
lab values marital lab_marital

lab define lab_cca 1 "Included in complete case analysis" 0 "Excluded for missing data"
lab values flag_cca* lab_cca

lab define lab_inc 1 "Included in analysis sample" 0 "Excluded from analysis sample"
lab values flag_inclusion lab_inc

********************************************************************************
*  Restrict to only necessary variables
********************************************************************************
keep aln qlet ///
sa_7* sa_20* sa_34* quint* ///
ASD zmf_asd scdc coherence repbehaviour sociability bin*  ///
mat_smok_bin18wk male parity_cat prepregBMI matEdDrv matage finDifDrv manual ///
zscore* pc* ///
flag* miss* ///
homeowner marital 



********************************************************************************
* Save data
********************************************************************************
save "$Datadir\DERIVED_VitD_dat.dta", replace

log close
