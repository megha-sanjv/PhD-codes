# createVoid2.py----------------------------------------------------------------------------------------------
# create charge neutral spherical void in center of supercell of Li2TiO3
# Megha Sanjeev 
# Version #2: Last updated: 18/07/2021
#------------------------------------------------------------------------------------------------------------

import numpy as np
import pandas as pd
import datetime
import os

# inputs ----------------------------------------------------------------------------------------------------
direction = 'z'
L = 30
r_inner = 10 #radius of void /Angstroms
r_outer = 11 #outer shell of atoms to pick atoms to balance charge of void

header = 18 #header of config file

# organise config data --------------------------------------------------------------------------------------

if direction == 'x':
	filename="configs/Li2TiO3_%ix10x10.lmp" % (L) #perfect config
elif direction == 'y':
	filename="configs/Li2TiO3_10x%ix10.lmp" % (L) #perfect config
elif direction == 'z':	
	filename="configs/Li2TiO3_10x10x%i.lmp" % (L) #perfect config
else:
	print("invalid direction input")

print("original filename: %s" % filename)

newfilename="rad-%sA/%s_%i_Void_LMT.lmp" % (r_inner, direction, L) #name for new config

newfilename2="rad-%sA/%s_%i_no_charge.lmp" % (r_inner, direction, L) #for making cif file for visualising

f = open('myatoms.txt','wb') #create text file for all atoms
f.write("N molecule-tag q x y z\n") #header for atoms file
 
with open ('%s' % filename, 'rt') as myfile:
	for i, myline in enumerate(myfile):
		if i >= header: #get atoms
			f.write(myline)

f.close()

# find center of supercell -------------------------------------------------------------------------------

myatoms = pd.read_csv('myatoms.txt', delimiter=" ")

lengths = []
minlengths = []

for column, in myatoms[['x', 'y', 'z']]:
	lengths.append(myatoms[column].max() - myatoms[column].min())	
	minlengths.append(myatoms[column].min())
#print(minlengths)
#print(lengths)

midlengths = []

for i in range(len(lengths)):
	midlengths.append(lengths[i]/2)
#print(midlengths)

midpoints = []

for i in range(len(midlengths)):
	midpoints.append(minlengths[i] + midlengths[i])
print("center of supercell is:")
print(midpoints)

# use equation of sphere (x - a)^2 + (y - b)^2 + (z - c)^2 = r^2 ----------------------------------------------
x2 = (myatoms.iloc[:]['x']-midpoints[0])**2
y2 = (myatoms.iloc[:]['y']-midpoints[1])**2
z2 = (myatoms.iloc[:]['z']-midpoints[2])**2
r = (x2 + y2 + z2)**0.5

myatoms['r'] = r
myatoms['count'] = 1 #acts as counter

innerSphere = myatoms.loc[myatoms['r'] <= r_inner] #dataframe of atoms in inner sphere
innerSphere = pd.DataFrame(data=innerSphere)

outerSphere = myatoms.loc[(myatoms['r'] <= r_outer) & (myatoms['r'] > r_inner)] #dataframe of atoms in outer shell
outerSphere = pd.DataFrame(data=outerSphere)
#print(outerSphere)

#print(innerSphere.groupby(['q']).sum()) #see how many of each atom in sphere

outerSphere = outerSphere.sort_values('r') #sort by r so we choose nearest atoms to void
#outerSphere = outerSphere.reset_index(drop=True)
#print(outerSphere)

# Balance charge of proposed void -----------------------------------------------------------------------------
innerCharge = innerSphere.iloc[:]['q'].sum(axis=0) #charge of proposed void
#print(innerCharge)

#outerCharge = outerSphere.iloc[:]['q'].sum(axis=0)
#print(outerCharge)

charge = innerCharge 
balanceCharge = []
balanceCharge = pd.DataFrame()

unit_charge = 0.549 #divide into units of charge for easy maths

charge_Li = 1 #CHECK molecules tags are in same order in any new input scripts 
charge_O = 2 #(negative)
charge_Ti = 4

Sphere_Li = outerSphere.loc[(outerSphere['molecule-tag'] == 1)] #isolate each atom type in outer shell 
Sphere_O = outerSphere.loc[(outerSphere['molecule-tag'] == 2)]
Sphere_Ti = outerSphere.loc[(outerSphere['molecule-tag'] == 3)]

if charge < 0: #need to compensate with +ve charges, i.e. Li and Ti. Choose max Ti and finish excess with Li
	print("Charge of proposed void is %f" % charge)
	print("Compensate negative with...")
	units = abs(charge/unit_charge)
	units_Li = int(round(units)) % charge_Ti #int to get rid of trailing floating points
	units_Ti = int(round(units)) // charge_Ti
	print("%i Ti" % units_Ti)
	print("%i Li" % units_Li)
	if units_Ti == 0:
		for i in range(1, units_Li+1):
			charge = charge + Sphere_Li.iloc[i]['q'] 
			balanceCharge = balanceCharge.append(Sphere_Li.iloc[i])
		print("Charge of new void is %f" % charge)
	if units_Ti != 0:
		for i in range(1, units_Ti+1):
			charge = charge + Sphere_Ti.iloc[i]['q']
			balanceCharge = balanceCharge.append(Sphere_Ti.iloc[i])
		if units_Li != 0:
			for i in range(1, units_Li+1):
        	                charge = charge + Sphere_Li.iloc[i]['q']
	                        balanceCharge = balanceCharge.append(Sphere_Li.iloc[i])
		print("Charge of new void is %f" % charge)

elif charge > 0: #need to compensate with -ve charges, i.e. O. Also include case needing one Li+ to balance to zero. 
	print("Charge of proposed void is %f" % charge)
	print("Compensate positive charge with...")
	units = abs(charge/unit_charge)	
	units_O = int(round(units)) // charge_O
	check = round(units) / charge_O
	check2 = check % 1
	if check2 != 0:
		units_O = units_O + 1
		units_Li = 1
		print("%i Li" % units_Li)
		charge = charge + Sphere_Li.iloc[1]['q']
		balanceCharge = balanceCharge.append(Sphere_Li.iloc[1])
	print("%i O" % units_O)
	for i in range(1, units_O+1):
		charge = charge + Sphere_O.iloc[i]['q']
		balanceCharge = balanceCharge.append(Sphere_O.iloc[i])
	print("Charge of new void is %f" % charge)

elif round(charge) == 0:
	print("Charge of proposed void is... already balanced!")

#print(balanceCharge) #print list of atoms to add to void

newSphere = innerSphere.append(balanceCharge, sort=True) #add new atoms to void
#print(newSphere) #all atoms in void
print("%i atoms in new void" % len(newSphere))

# make new config files -------------------------------------------------------------------------------

newatoms = myatoms #make copy of original perfect config to edit

atoms_w_void = pd.merge(newatoms,newSphere, indicator=True, how='outer').query('_merge=="left_only"').drop('_merge', axis=1)
atoms_w_void.reset_index(drop=True, inplace=True)
atoms = atoms_w_void.groupby(['molecule-tag']).sum()

total_atoms=len(atoms_w_void)
N_atoms = pd.DataFrame({'new-N': range(1, total_atoms+1, 1)})
#print(N_atoms)
atoms_w_void['new-N'] = N_atoms['new-N'].astype('object') #renumber atoms for lammps
atoms_w_void = atoms_w_void[['new-N', 'molecule-tag', 'q', 'x', 'y', 'z']] #rearrange and choose columns
atoms_no_charge = atoms_w_void[['new-N', 'molecule-tag', 'x', 'y', 'z']]
#print(atoms_w_void)

atoms_w_void.to_csv('atoms_w_void.txt', index=False, sep=' ', header=None, float_format='%.8f')
atoms_no_charge.to_csv('atoms_no_charge.txt', index=False, sep=' ', header=None, float_format='%.8f')

#print(atoms_w_void.sum()) #check final config charge

with open ('%s' % filename, 'rt') as orig:
	with open('%s' % newfilename, 'wb') as config:
		config.write('# Configuration edited by M. Sanjeev to include spherical void on %s\n' % (datetime.date.today()))
		config.write("# Original config: %s, Void radius: %f, Void atoms: %i\n" % (filename, r_inner, len(newSphere)))
		config.write("\t# Li %i, O %i, Ti %i\n" % (atoms.iloc[0]['count'], atoms.iloc[1]['count'], atoms.iloc[2]['count']))
		config.write("\t%s atoms\n" % (total_atoms))
		for i, line in enumerate(orig):
			if 3 <= i < header:
				config.write(line)
		with open('atoms_w_void.txt', 'rt') as atoms:
			for i, line in enumerate(atoms):
				config.write(line)
with open ('%s' % filename, 'rt') as orig:
	with open ('%s'	% newfilename2, 'wb') as nocharge:
		nocharge.write('# Spherical Void, radius: %f, original config: %s\n' % (r_inner, filename))
		nocharge.write("\t%s atoms\n" % (total_atoms))
		for j, line in enumerate(orig):
			if 3 <= j < header:
				nocharge.write(line)
		with open('atoms_no_charge.txt', 'rt') as atoms:
			for i, line in enumerate(atoms):
				nocharge.write(line)

# clean up ------------------------------------------------------------------------------------------------

os.remove("myatoms.txt")
os.remove("atoms_w_void.txt")
os.remove("atoms_no_charge.txt")

#----------------------------------------------------------------------------------------------------------
