#!/bin/bash
#-----------------------------------------------------------------------------------------------#
# Script Name:  tc_analysis.sh                                                                  #
# Description:  script to run compro.sh, meanprof.py and combine results 	    	 	#
#		into one file meancompro.dat    				                #
# Author:       Megha Sanjeev                                                                   #
#-----------------------------------------------------------------------------------------------#

#run from inside x/y/z-thermcond directory
#also have compro.sh and meanprof.py in directory. Maybe worth combining them in future. 

inc=100 #increment in temperature
start=100 #start temp
end=1600 #end temp
temp=$start #current temperature
chunks=20 #number of chunks in thermal conductivity calculation
i=1

touch meancompro.dat

until [ $i -gt $chunks ]
do
	echo $i >> meancompro.dat
	((i++))
done

while [ $temp -le $end ]
do
	cd $temp
	sed s/"temp=.*"/"temp=${temp}"/ <../compro.sh > ../comptmp #change temperature in profile combining script
	mv ../comptmp ../compro.sh
	bash ../compro.sh
	sed s/"temp=.*"/"temp=${temp}"/ <../meanprof.py > ../meantmp #change temperature in mean calculating script
	mv ../meantmp ../meanprof.py
	python ../meanprof.py > mp_$temp.dat
	awk '{ print $2 }' mp_$temp.dat > "tmp$temp" #cut column 2 from mean profile for this temperature
	paste "../meancompro.dat" "tmp$temp" > tmpcompro #paste to combined mean profile file using tmp file
	mv tmpcompro ../meancompro.dat
	rm tmp$temp
	echo added temp=$temp
	cd ../
	temp=$(($temp+$inc))
done
	


