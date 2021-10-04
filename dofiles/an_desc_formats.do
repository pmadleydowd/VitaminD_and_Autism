********************************************************************************
* Author: Paul Madley-Dowd
* Date: 2021-07-20
* Description: Formats for descriptive tables for ALSPAC vitamin D study
********************************************************************************
* variable name 
gen stat_c = stat in 1
replace stat_c = "Sex, N(%)"                           			 		if stat == "male"
replace stat_c = "Parity, N(%)"                        			 		if stat == "parity_cat" 
replace stat_c = "Maternal smoking in pregnancy, N(%)" 			 		if stat == "mat_smok_bin18wk"
replace stat_c = "Maternal education, N(%)"    		 			 		if stat == "matEdDrv" 
replace stat_c = "Financial difficulties, N(%)"  		 		 		if stat == "finDifDrv"
replace stat_c = "Maternal occupation, N(%)"		 	 		 		if stat == "manual"
replace stat_c = "Autism diagnosis, N(%)"		  		 		 		if stat == "ASD"
replace stat_c = "Social communication difficulties, N(%)"  	 		if stat == "bin_scdc"
replace stat_c = "Pragmatic language difficulties, N(%)"  		 		if stat == "bin_coherence"
replace stat_c = "Repetitive behaviour, N(%)"  		 			 		if stat == "bin_repbehaviour"
replace stat_c = "Sociability, N(%)"  				 			 		if stat == "bin_sociability"
replace stat_c = "Maternal age, mean(SD)"						 		if stat == "matage"
replace stat_c = "Pre-pregnancy BMI, mean(SD)"					 		if stat == "prepregBMI"
replace stat_c = "Maternal adjusted vitamin D, mean(SD)"				if stat == "sadj_vitd"
replace stat_c = "Maternal adjusted vitamin D (10 nmol/L), mean(SD)"	if stat == "sadj_vitd_10"
replace stat_c = "Maternal vitamin D genetic risk score, mean(SD)"		if stat == "zscore_vd_mom_prs_S13"
replace stat_c = "Offspring vitamin D genetic risk score, mean(SD)"		if stat == "zscore_vd_child_prs_S13"
replace stat_c = "Standardised autism factor mean score, mean(SD)"		if stat == "zmf_asd"
replace stat_c = "Maternal marital status, N(%)"				 		if stat == "marital"
replace stat_c = "Home ownership status, N(%)"					 		if stat == "homeowner"

bysort tabord: replace stat_c = "" if _n>1

* levels of variable
tostring statlev, gen(statlevntoc)

gen statlev_c = "No" if statlev == 0 & inlist(stat, "mat_smok_bin18wk", "finDifDrv", "ASD", "bin_scdc", "bin_coherence", "bin_repbehaviour", "bin_sociability")

replace statlev_c = "Yes" if statlev == 1 & inlist(stat, "mat_smok_bin18wk", "finDifDrv", "ASD", "bin_scdc", "bin_coherence", "bin_repbehaviour", "bin_sociability")

replace statlev_c = "Missing" if statlev == . & stat != "Total"

replace statlev_c = "Male"   if statlev == 1 & stat == "male"
replace statlev_c = "Female" if statlev == 0 & stat == "male"

replace statlev_c = statlevntoc if inlist(statlev, 0, 1)  & stat == "parity_cat"
replace statlev_c = "2+" if statlev == 2 & stat == "parity_cat"

replace statlev_c = "Vocational" 		if statlev == 1 & stat == "matEdDrv" 
replace statlev_c = "CSE/O level"  		if statlev == 2 & stat == "matEdDrv"
replace statlev_c = "A level/Degree" 	if statlev == 3 & stat == "matEdDrv"

replace statlev_c = "Manual"   	 if statlev == 1 & stat == "manual"
replace statlev_c = "Non-manual" if statlev == 0 & stat == "manual"

replace statlev_c = "Never married" 							if statlev == 1 & stat == "marital"
replace statlev_c = "Previously married (currently unmarried)"  if statlev == 2 & stat == "marital"
replace statlev_c = "1st marriage" 								if statlev == 3 & stat == "marital"
replace statlev_c = "2nd or 3rd marriage" 						if statlev == 4 & stat == "marital"

replace statlev_c = "Owned/mortgaged" 							if statlev == 1 & stat == "homeowner"
replace statlev_c = "Council rented" 							if statlev == 2 & stat == "homeowner"
replace statlev_c = "Privately rented" 							if statlev == 3 & stat == "homeowner"
replace statlev_c = "Other" 									if statlev == 4 & stat == "homeowner"


