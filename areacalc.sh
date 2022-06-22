#!/bin/bash
direction=x
equil=50000
touch area_$direction.dat

temp=100
end=1600
inc=100

#  Step Temp Volume Press PotEng KinEng TotEng Cella Cellb Cellc CellAlpha CellBeta CellGamma
while [ $temp -le $end ]
do

	sed -n "/^\s*${equil}.*/{p;q;}" <$temp/log.lammps >ac_$temp.dat

	cella="$(awk '{ print $8 }' ac_$temp.dat)"
	cellb="$(awk '{ print $9 }' ac_$temp.dat)"
	cellc="$(awk '{ print $10 }' ac_$temp.dat)"
	alpha="$(awk '{ print $11 }' ac_$temp.dat)"
	beta="$(awk '{ print $12 }' ac_$temp.dat)"
	gamma="$(awk '{ print $13 }' ac_$temp.dat)"

	#echo $cella $cellb $cellc $alpha $beta $gamma

	pi=`echo "4*a(1)" | bc -l`
	alpha=`echo "$alpha*($pi/180)" | bc -l`
	beta=`echo "$beta*($pi/180)" | bc -l`
	gamma=`echo "$gamma*($pi/180)" | bc -l`

	#echo $pi $alpha $beta $gamma

	#sinbeta=`echo "s($beta)" | bc -l`

	lx=$cella
	ly=$cellb
	lz=`echo "$cellc*s($beta)" | bc -l`

	#echo $lx $ly $lz

	if [ $direction == 'x' ]
	then
		A=`echo "$ly*$lz" | bc -l`
		L=$lx
	elif [ $direction == 'y' ]
	then	
		A=`echo "$lx*$lz" | bc -l`
		L=$ly
	elif [ $direction == 'z' ]
	then
		A=`echo "$lx*$ly" | bc -l`
		L=$lz
	else
		echo direction incorrect
	fi
	
	echo $A >> area_$direction.dat
	echo $L >> L_$direction.dat
	rm ac_$temp.dat
	temp=$(($temp+$inc))
done
