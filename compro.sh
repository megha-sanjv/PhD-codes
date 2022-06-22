#!/bin/bash
#----------------------------------------------------------------------------------------------#
# Script Name:  compro.sh                                                                      #
# Description:  script to combine each timestep of profile for a plottable result	       #
# Author:       Megha Sanjeev                                                                  #
# Date:		15/06/2020
# Version:	2.0 (fixed spacing error in output and added transposed output)
#----------------------------------------------------------------------------------------------#


temp=700
var=5 #column of desired data where first column is empty (to be fixed)
i=5 #length of header
steps=20

tot=$(($i+$steps))

start=51 #starting timestep in units of increment (e.g. thousand)
final=2100 #final timestep in units of increment

num=$(($final-$start)) #how many sets of data

tr -s " " < "profile.dat" | cut -d " " -f $var > "tmp$temp" 

touch tmp$(($tot-$steps-1))

while [ $start -le $final ]
do
	sed $i,$tot'!d' tmp$temp > "tmp$tot" #cut profile of timestep
	j=$(($tot-$steps-1))
	paste "tmp$j" "tmp$tot" > "tmp_$tot" #paste to combined file using a tmp file
	mv tmp_$tot tmp$tot
	i=$(($tot+1))
	tot=$(($i+$steps)) 
	start=$(($start+1))
done

end=$(($num*($steps+1)+4))
#column -t tmp$end > tp_$temp.dat
#mv tmp$end tp_$temp.dat
cat tmp$end | tr -s '[:space:]' > tp_$temp.dat

datamash transpose < tp_$temp.dat > chunks_$temp.dat --no-strict #requires GNU datamash

rm tmp* #cleanup


