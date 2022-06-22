#!/bin/bash
#make Li-Poor supercells
excess=Ti
direction=x
L=100
Lmax=100

while [ $L -le $Lmax ]
do

echo creating L = ${L} perfect supercell...
if [ $direction == 'x' ]
then
	atomsk Li2TiO3_unitcell.cif -duplicate ${L} 10 10 Li2TiO3_${direction}_${L}.cif
	echo L along x-direction
elif [ $direction == 'y' ]
then 
        atomsk Li2TiO3_unitcell.cif -duplicate 10 ${L} 10 Li2TiO3_${direction}_${L}.cif
	echo L along y-direction
elif [ $direction == 'z' ]
then 
        atomsk Li2TiO3_unitcell.cif -duplicate 10 10 ${L} Li2TiO3_${direction}_${L}.cif
	echo L along z-direction
else
	echo direction incorrect
fi


echo adding defects...
#select 0.25% of Li sites and substitute with Ti to make 0.5% Ti excess --- each defect 3+ charge
atomsk Li2TiO3_${direction}_${L}.cif -select random 0.25% Li -substitute Li Ti Li2TiO3_tmp.cif

#now include 3 times are many Li vacancies to balance charge from substitutions --- each defect 1- charge
vacancies=$(($L*12)) #3*40=120 atoms per L=10
atomsk Li2TiO3_tmp.cif -select random ${vacancies} Li -remove-atoms select ${direction}_${L}_Li2TiO3_no_charges.cif

#and now we have 1% Li loss, convert to LAMMPS
atomsk ${direction}_${L}_Li2TiO3_no_charges.cif LAMMPS

echo adding charges...
#add charges with perl script
filename="\"${direction}_${L}_Li2TiO3_no_charges.lmp\""
error_message="\"Can't open file\""
sed s/"open INFILE.*"/"open INFILE, ${filename} or die ${error_message};"/ < add_charges.pl > chargetmp #change filename
mv chargetmp add_charges.pl 
perl add_charges.pl ${direction}_${L}_Li2TiO3_no_charges.lmp > ${direction}_${L}_Li1.98Ti1.005O3.lmp

#cleanup
rm Li2TiO3_${direction}_${L}.cif Li2TiO3_tmp.cif
rm *_no_charges.lmp

echo created configuration for excess $excess, L = $L, along $direction 

L=$(($L+10))
done
