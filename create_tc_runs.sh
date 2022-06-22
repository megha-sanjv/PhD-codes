#!/bin/bash
#-----------------------------------------------------------------------------------------------#
# Script Name:	create_tc_runs.sh								#
# Description:	automate creation and submission of thermal conductivity calculations 		#
#		in x, y, z orientations, for increasing temperatures between a set range.	#
# Author:	Megha Sanjeev									#
#-----------------------------------------------------------------------------------------------#


#---ESSENTIAL INPUT REQUIRED HERE-------------------------------------------------------------#

direction=x  #ORIENTATION FOR THERMAL CONDUCTIVITY CALCULATIONS
config=../../Li2TiO3_40x10x10.lmp #ENTER LOCATION FOR CORRECT CONFIG FILE

#---------------------------------------------------------------------------------------------#

dir=${direction}_thermcond #head directory name automated

#copy in essential files: input and submission script. Change locations if necessary!
mkdir $dir
cp Li2TiO3.input $dir
cp submit.sh $dir

#set temperature range
cd $dir
inc=200
start=100
end=1300
temp=$start

#point to configuration file
sed s:"^read_data.*":"read_data ${config}": <Li2TiO3.input >tmp1

#ensure thermal conductivity calculation is in chosen direction
sed s:"^compute layers all chunk.*":"compute layers all chunk/atom bin/1d ${direction} lower 0.05 units reduced": <tmp1 >tmp2
sed s:"^fix 3_fix all thermal/conductivity.*":"fix 3_fix all thermal/conductivity 10 ${direction} 20": <tmp2 >tmp3
sed s:"^fix     3_fix all thermal/conductivity.*":"fix 3_fix all thermal/conductivity 10 ${direction} 20": <tmp3 >tmp4
mv tmp4 Li2TiO3.input
rm tmp* #clean up

#create directories and copy and edit files for desired temperatures. NB: Be careful of autosubmit command
while [ $temp -le $end ]
do
	mkdir $temp
	sed s/"variable T equal.*"/"variable T equal ${temp}.0"/ <Li2TiO3.input >Li2TiO3_temp.input
	mv Li2TiO3_temp.input $temp/Li2TiO3.input
	cp submit.sh $temp
	cd $temp
	sed s/"#$ -N.*"/"#$ -N ${direction}_${temp}"/ <submit.sh >submit_temp.sh
	mv submit_temp.sh submit.sh
	#qsub submit.sh #AUTOSUBMISSION HERE 
	cd ../
	temp=$(($temp+$inc))

done
