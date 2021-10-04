log using "$Logdir\LOG_cr_initial_dataset.txt", text replace
*** Syntax template for direct users preparing datasets using child and parent based datasets.

* Created 29th October 2014 - always create a datafile using the most up to date template.
* Updated 24th May 2018 - mothers questionnaire and clinic data now dealt with separately in order to take into account separate withdrawal of consent requests.
* Updated 1st October 2018 - adding partners withdrawal of control
* Updated 12th October 2018 - cohort profile dataset has been updated and so version number updated to reflect
* Updated 9th November 2018 - ends of file paths for A, B and C files
* Updated 13th February 2019 - added checks in each section for correct withdrawal of consent frequencies
* Updated 21st February 2019 - updated withdrawal of consent frequencies
* Updated 5th March 2019 - updated withdrawal of consent frequencies
* Updated 11th March 2019 - updated withdrawal of consent frequencies
* Updated 9th May 2019 - updated withdrawal of consent frequencies
* Updated 17th March 2019 - updated withdrawal of consent frequencies
* Updated 9th August 2019 - updated withdrawal of consent frequencies
* Updated 4th Sept 2019 - updated withdrawal of consent frequencies
* Updated 24th March 2020 - updated withdrawal of consent frequencies
* Updated 5th August 2020 - updated withdrawal of consent frequencies
* Updated 9th September 2020 - updated withdrawal of consent frequencies
* Updated 25th May 2021 - updated withdrawal of consent frequencies
* Updated 27th May 2021 - updated withdrawal of consent frequencies
* Updated 3rd June 2021 - added clarification of where to inlcude variable lists


****************************************************************************************************************************************************************************************************************************
* This template is based on that used by the data buddy team and they include a number of variables by default.
* To ensure the file works we suggest you keep those in and just add any relevant variables that you need for your project.
* To add data other than that included by default you will need to add the relvant files and pathnames in each of the match commands below.
* There is a separate command for mothers questionnaires, mothers clinics, partner, mothers providing data on the child and data provided by the child themselves.
* Each has different withdrawal of consent issues so they must be considered separately.
* You will need to replace 'YOUR PATHNAME' in each section with your working directory pathname.

*****************************************************************************************************************************************************************************************************************************.

* Mother questionnaire files - in this section the following file types need to be placed:
* Mother completed Qs about herself
* Maternal grandparents social class
* Partner_proxy social class

* ALWAYS KEEP THIS SECTION IF YOU ARE USING MOTHER-BASED DATA EVEN IF ONLY MOTHER CLINIC REQUESTED

clear
set maxvar 32767	
use "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Other\Sample Definition\mz_5a.dta", clear
sort aln
gen in_mz=1
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\a_3e.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\b_4f.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\c_8a.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\d_4b.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Mother\h_6d.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Useful_data\bestgest\bestgest.dta", nogen

keep aln mz001 mz010a mz013 mz014 mz028b ///
a006 a525 ///
b032 b371 b650 b653 b659 b663 - b667 b670 b671 b721 b724 ///
c373 c3834 c525 c645a c666a c755 c765 c765 c800 - c804 ///
dw002 dw003 dw021 ///
h470 /// 
bestgest

* Dealing with withdrawal of consent: For this to work additional variables required have to be inserted before bestgest, so replace the *** line above with additional variables. 
* If none are required remember to delete the *** line.
* An additional do file is called in to set those withdrawing consent to missing so that this is always up to date whenever you run this do file. Note that mother based WoCs are set to .a


order aln mz010a, first
order bestgest, last

do "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Syntax\Withdrawal of consent\mother_quest_WoC.do"

* Check withdrawal of consent frequencies mum quest=21
tab1 mz010a, mis

save "$Datadir\motherQ.dta", replace


********************************************************************************************************
* Mother clinic files - in this section the following file types need to be placed:
* Mother clinc data
* Mother biosamples
* Obstetrics file OB

* If there are no mother clinic files, this section can be starred out *
* NOTE: having to keep mz010a bestgest just to make the withdrawal of consent work - these are dropped for this file as the ones in the Mother questionnaire file are the important ones and should take priority *

use "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Other\Sample Definition\mz_5a.dta", clear
sort aln
gen in_mz=1
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Useful_data\bestgest\bestgest.dta", nogen
merge 1:1 aln using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Other\Samples\Mother\Mother_samples_5b.dta", nogen
merge 1:1 aln using "$Rawdatdir\VitD_postwoc.dta", nogen

keep aln mz001 mz010a ///
VitDd2_preg VitDd3_preg VitDtot_preg VitD_gest VitDt_FOM* crp_FOM* ///
sa_MattotvitDnMol_Sm ///
bestgest

* Removing withdrawl of consent cases *** FOR LARGE DATASETS THIS CAN TAKE A FEW MINUTES
* An additional do file is called in to set those withdrawing consent to missing so that this is always up to date whenever you run this do file. Note that mother based WoCs are set to .a

order aln mz010a, first
order bestgest mz001, last

do "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Syntax\Withdrawal of consent\mother_clinic_WoC.do"

* Check withdrawal of consent frequencies mum clinic=24
tab1 mz010a, mis

save "$Datadir\motherC.dta", replace


*****************************************************************************************************************************************************************************************************************************.
/* PARTNER - ***UNBLOCK SECTION WHEN REQUIRED***
* Partner files - in this section the following file types need to be placed:
* Partner completed Qs about themself
* Partner clinic data
* Partner biosamples data
* Paternal grandparents social class
* Partner_complete social class


* NOTE: having to keep mz010a bestgest just to make the withdrawal of consent work - these are dropped for this file *

use "R:\Data\Current\Other\Sample Definition\mz_5a.dta", clear
sort aln
gen in_mz=1
merge 1:1 aln using "R:\Data\Useful_data\bestgest\bestgest.dta", nogen


keep aln mz001 mz010a ///
/* add your variable list here*/
bestgest

* Removing withdrawl of consent cases *** FOR LARGE DATASETS THIS CAN TAKE A FEW MINUTES
* An additional do file is called in to set those withdrawing consent to missing so that this is always up to date whenever you run this do file. Note that partner based WoCs are set to .c


order aln mz010a, first
order bestgest mz001, last

do "R:\Data\Syntax\Withdrawal of consent\partner_WoC.do"

* Check withdrawal of consent frequencies partner=3
tab1 mz010a, mis

save "YOUR PATHNAME\partner.dta", replace */



*****************************************************************************************************************************************************************************************************************************.
* Child BASED files - in this section the following file types need to be placed:
* Mother completed Qs about YP
* Obstetrics file OA

* ALWAYS KEEP THIS SECTION EVEN IF ONLY CHILD COMPLETED REQUESTED, although you will need to remove the *****

use "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Other\Sample Definition\kz_5c.dta", clear
sort aln qlet
gen in_kz=1
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Other\cohort profile\cp_2b.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Quest\Schools\sabc_1e.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Useful_data\autistic traits\autistic_traits_12.dta", nogen
merge 1:1 aln qlet using "$Rawdatdir\autistic traits and ASD diagnoses_hh20170405.dta", nogen


keep aln qlet kz011b kz021 kz030 ///
sabc010-sabc012 sa031 sa031a sa060 sa061 ///
fm ///
scdc coherence repbehaviour sociability autism_new autism_new_confirmed_hh ///
in_core in_alsp in_phase2 in_phase3 in_phase4 tripquad


* Dealing with withdrawal of consent: For this to work additional variables required have to be inserted before in_core, so replace the ***** line with additional variables.
* If none are required remember to delete the ***** line.
* An additional do file is called in to set those withdrawing consent to missing so that this is always up to date whenever you run this do file. Note that child based WoCs are set to .b


order aln qlet kz021, first
order in_alsp tripquad, last

do "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Syntax\Withdrawal of consent\child_based_WoC.do"

* Check withdrawal of consent frequencies child based=23 (two mums of twins have withdrawn consent)
tab1 kz021, mis

save "$Datadir\childB.dta", replace

*****************************************************************************************************************************************************************************************************************************.
* Child COMPLETED files - in this section the following file types need to be placed:
* YP completed Qs
* Puberty Qs
* Child clinic data
* Child biosamples data
* School Qs
* Obstetrics file OC

* If there are no child completed files, this section can be starred out.
* NOTE: having to keep kz021 tripquad just to make the withdrawal of consent work - these are dropped for this file as the ones in the child BASED file are the important ones and should take priority

use "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Other\Sample Definition\kz_5c.dta", clear
sort aln qlet
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Other\cohort profile\cp_2b.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Clinic\Child\cif_8b.dta", nogen
merge 1:1 aln qlet using "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Current\Clinic\Child\f08_4d.dta", nogen

keep aln qlet kz021 ///
cf800 cf811-cf815 ///
f8ws001 f8ws110-f8ws115 f8ws150 ///
tripquad

* Dealing with withdrawal of consent: For this to work additional variables required have to be inserted before tripquad, so replace the ***** line with additional variables.
* An additional do file is called in to set those withdrawing consent to missing so that this is always up to date whenever you run this do file.  Note that mother based WoCs are set to .b

order aln qlet kz021, first
order tripquad, last

do "\\ads.bris.ac.uk\Filestore\SSCM ALSPAC\Data\Syntax\Withdrawal of consent\child_completed_WoC.do"

* Check withdrawal of consent frequencies child completed=25 
tab1 kz021, mis

drop kz021 tripquad
save "$Datadir\childC.dta", replace

*****************************************************************************************************************************************************************************************************************************.
** Matching all data together and saving out the final file*.
* NOTE: any linkage data should be added here*.

use "$Datadir\childB.dta", clear
merge 1:1 aln qlet using "$Datadir\childC.dta", nogen
merge m:1 aln using "$Datadir\motherQ.dta", nogen
merge m:1 aln using "$Datadir\motherC.dta", nogen 
* IF partner data is required please unstar the following line
/* merge m:1 aln using "YOUR PATHWAY\partner.dta", nogen */


* Remove non-alspac children.
drop if in_alsp!=1.

* Remove trips and quads.
drop if tripquad==1

drop in_alsp tripquad
save "$Datadir\RAW_VitD_dat.dta", replace

*****************************************************************************************************************************************************************************************************************************.
* QC checks*
* Check that there are 15645 records.
count

log close
