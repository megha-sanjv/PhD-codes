#!/bin/bash

direction=x
L=50
interstitials=$(($L*12)) #120 per L=10

atomsk Li2TiO3_unitcell.cif -duplicate ${L} 10 10 Li2TiO3_${direction}_${L}.cif

#select 0.5% of Ti sites and substitute with Li 
atomsk Li2TiO3_${direction}_${L}.cif -select random 0.5% Ti -substitute Ti Li Li2TiO3_w_LiTi2.cif

#add 3 times as many Li interstitials to make up to 1% Li excess
atomsk Li2TiO3_w_LiTi2.cif -add-atom Li random ${interstitials} ${direction}_${L}_Li2TiO3_no_charges.cif

atomsk ${direction}_${L}_Li2TiO3_no_charges.cif LAMMPS

perl add_charges.pl ${direction}_${L}_Li2TiO3_no_charges.lmp > ${direction}_${L}_Li2.02Ti0.995O3.lmp

rm Li2TiO3_${direction}_${L}.cif Li2TiO3_w_LiTi2.cif
