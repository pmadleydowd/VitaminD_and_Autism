This folder contains all of the do files required to replicate the project

* master.do, the master file, runs all .do files in order, including data extraction from ALSPAC, data derivations and all analyses. This file should be used as a guide for running each .do file.
* global.do sets all the global macros used to set the working directories required by each .do file. This is called as part of the master file. If this is run then no working directories contained in .do files will need to be changed. This file also describes the purpose of each folder in the folder structure.
