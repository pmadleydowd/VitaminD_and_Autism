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
use "$Datadir\RAW_VitD_dat.dta", clear 


********************************************************************************
* 2 Prepare exposure information
********************************************************************************
rename sa_MattotvitDnMol_Sm sadj_vitd
gen sadj_vitd_10 = sadj_vitd/10



********************************************************************************
* 3 Prepare outcome information
********************************************************************************
* create binary variable for top decile of autism traits
foreach var in scdc coherence repbehaviour sociability{
  xtile dec_`var' = `var' , n(10)  
  gen bin_`var' = dec_`var' == 10 if dec_`var' != .  
} 

rename autism_new_confirmed_ ASD
replace ASD = . if ASD == .a | ASD == .b

*Inverse autism factor mean scores so that positive scores reflect more ASD difficulties
summarize fm
gen mf1= fm*(-1) if fm>0 & fm!=. 
gen mf2= abs(fm) if fm<0 & fm!=.

gen mf_asd = max(mf1, mf2) 

*Standardize

egen zmf_asd= std(mf_asd)


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
label var mat_smok_bin18wk "Any maternal smoking during pregnancy (Y/N) "


* male sex
gen male = 1 if kz021 == 1
replace male = 0 if kz021 == 2


* parity 
rename b032		parity
egen parity_cat = cut(parity), at(-7,0,1,2,25) 
replace parity_cat=. if parity<0
lab var parity_cat "Parity Categories (0,1,2+)"


* pre pregnancy BMI
replace dw002 = . if dw002 < 0  // replace missing questionnaire value with missing value (general) 
replace dw021 = . if dw021 < 0 
gen prepregBMI = dw002/((dw021/100)^2)


* socioeconomic status variables 
	* maternal highest education
rename c645a 	matEd
gen 	matEdDrv = 1 if matEd == 2 // vocational 
replace matEdDrv = 2 if matEd == 1 | matEd ==3 // CSE/Olevel
replace matEdDrv = 3 if matEd == 4 | matEd == 5  // A level/Degree
replace matEdDrv=. 	  if matEd<0
lab var matEdDrv "Maternal highest educational qualification (recoded)" 

	* maternal age 
rename mz028b 	matage
replace matage = . if matage < 0

	* financial difficulty
rename c525 finDif
replace finDif = . if finDif < 0
xtile finDifDec = finDif, n(10)
gen finDifDrv = finDifDec == 10 if finDifDec !=.

	* maternal manual occupational class
recode c755 (1/3=0) (4/6=1) (-1=.) (65=.), gen(manual)
replace manual = . if manual == .a



********************************************************************************
* 5 Merge polygenic risk score information for vitamin d
********************************************************************************
* add on PRSs used in sensitvity analyses derived by Christina Dardani
merge  1:1 aln qlet using "$Rawdatdir\PRS.dta"

* Variable = pvalue threshold
*	S1  = 0.5
* 	S2  = 0.4 
* 	S3  = 0.3
*	S4  = 0.2
*	S5  = 0.1
*	S6  = 0.05
*	S7  = 0.01
*	S8  = 0.001 
* 	S9  = 0.0001
* 	S10 = 0.00001
* 	S11 = 0.000001
* 	S12 = 0.0000001
*  	S13 = 0.00000005  = GWAS significant treshold


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
egen miss_outcome = rowmiss(ASD bin_scdc bin_coherence bin_repbehaviour bin_sociability)
gen flag_outcomeany = miss_outcome < 5 

* any exposure information
egen miss_exposure = rowmiss(sadj_vitd)
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
gen flag_mPRS = missing(zscore_vd_mom_prs_S13 )
gen flag_cPRS = missing(zscore_vd_child_prs_S13 )


* meet inclusion criteria sample
gen flag_inclusion =  flag_mat_white_eth 	== 1 & ///
					  flag_alive1yr 	 	== 1 & ///
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
xtile quint_seasadjvitD = sadj_vitd if flag_mat_white_eth == 1 & flag_alive1yr == 1 & flag_singleton	== 1 & flag_outcomeany == 1 & miss_exposure == 0  , n(5)


********************************************************************************
* 9 Derive auxiliary variables for multiple imputation
********************************************************************************
* Home ownership status
gen homeowner = a006 if a006 >=0 
recode homeowner (0/1=1) (2=2) (3/5=3) (6=4) // 1 = owned/mortgaged, 2 = council rented, 3 = privately rented, 4 = other

* Marital status
gen marital = a525 if a525 >= 0 
recode marital (-1 = .) (1=1) (2/4=2) (5=3) (6=4) // 1 = never married, 2 = previously married (currently unmarried), 3 = 1st marriage, 4 = 2nd or 3rd marriage



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

********************************************************************************
*  Restrict to only necessary variables
********************************************************************************
keep aln qlet ///
sadj_vitd* quint* ///
ASD zmf_asd  scdc coherence repbehaviour sociability dec* bin*  ///
mat_smok_bin18wk male parity_cat prepregBMI matEdDrv matage finDifDrv manual ///
zscore* pc* ///
flag* miss* ///
homeowner marital 



********************************************************************************
* Save data
********************************************************************************
save "$Datadir\DERIVED_VitD_dat.dta", replace

log close
