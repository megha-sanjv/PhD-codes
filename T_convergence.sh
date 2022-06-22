#!/bin/bash
#--------------------------------------------------------------------------------------------------
# Script Name:	T_convergence.sh
# Description:	Script to output plottable data for the temperature convergence factor as calculated with the thermal conductivity
# Author:	Megha Sanjeev
# Date:		15/06/2020
# Version:	1.0
#---------------------------------------------------------------------------------------------------

inc=400 #increment in temperature
start=300 #start temperature
end=400

start_step=100 #in units of increment, here 1000
end_step=300

temp=$start #current temperature

while [ $temp -le $end ]
do
	cd $temp

	#find line where desired data begins
	lineNum="$(grep -n "Step Temp E_pair TotEng f_3_fix v_tdiff f_ave" log.lammps | head -n 1 | cut -d: -f1)"

	#echo $lineNum
	
	#copy desired data to new temporary file
	tail -n +$((${lineNum}+1)) log.lammps | head -n $(($end_step-$start_step+1)) > tmp$temp
	
	#copy desired columns only to new file
	awk '{print $1,$6}' tmp$temp > T_conv_$temp.dat
	cp T_conv_$temp.dat ../	
	rm tmp$temp
	cd ../
	temp=$(($temp+$inc))
done
