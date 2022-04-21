README file for https://github.com/pmadleydowd/VitaminD_and_Autism.git

*******************************************************************************************
Description of repository:  
*******************************************************************************************
This repository contains the file structure needed for replicating the project and all Stata .do files used. 
* dofiles/master.do, the master file, runs all .do files in order, including data extraction from ALSPAC, data derivations and all analyses. This file should be used as a guide for running each .do file. 
* dofiles/global.do sets all the global macros used to set the working directories required by each .do file. This is called as part of the master file. If this is run then no working directories contained in .do files will need to be changed. This file also describes the purpose of each folder in the folder structure. 

All folders other than the dofiles folder are empty. No data are contained in this repository. 

To gain access to the ALSPAC data resource you will need to make a project proposal and submit to the ALSPAC exec via the online system here - https://proposals.epi.bristol.ac.uk/ 
The project identifier for this project is B2866.
