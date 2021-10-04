******************************************************************************
* Author: 	Paul Madley-Dowd
* Date: 	22 July 2021
* Description:  Runs all global macros for the ALSPAC vitamin D and autism project. To be run at the start of all stata sessions. 
******************************************************************************
clear 

global Projectdir "YourPathNameHere"

global Dodir 		"$Projectdir\dofiles"
global Logdir 		"$Projectdir\logfiles"
global Datadir 		"$Projectdir\datafiles"
global Rawdatdir 	"$Projectdir\rawdata"
global Graphdir 	"$Projectdir\graphfiles"

cd "$Projectdir"