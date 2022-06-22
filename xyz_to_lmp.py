import numpy as np
import pandas as pd
import datetime
import os
import sys

filename="cas_480000.xyz"
newfilename="cas_480000.lmp"
header=2

charge1 = 1.5
charge2 = 1.9
charge3 = 1.4
charge4 = -1.3

xhi=232.803
yhi=236.468
zhi=236.266

no_atoms = 936000
no_atom_types = 4

f = open('myatoms.txt', 'w')
f.write("molecule-tag x y z\n") #header for atoms file
with open ('%s' % filename, 'rt') as myfile:
        for i, myline in enumerate(myfile):
                if i >= header: #get atoms
                        f.write(myline)

f.close()

myatoms = pd.read_csv('myatoms.txt', delimiter=" ")
total_atoms=len(myatoms)
N_atoms = pd.DataFrame({'N': range(1, total_atoms+1, 1)})
#print(N_atoms)
myatoms['N'] = N_atoms['N'].astype('object') #renumber atoms for lammps

myatoms.loc[myatoms['molecule-tag'] == 1, 'q'] = charge1
myatoms.loc[myatoms['molecule-tag'] == 2, 'q'] = charge2
myatoms.loc[myatoms['molecule-tag'] == 3, 'q'] = charge3
myatoms.loc[myatoms['molecule-tag'] == 4, 'q'] = charge4
#print(myatoms)
finalatoms = myatoms[['N', 'molecule-tag', 'q', 'x', 'y', 'z']]

pd.set_option('display.max_rows', None)

original_stdout = sys.stdout # Save a reference to the original standard output
with open('YBCO_cas_anneal.lmp', 'w') as f:
	sys.stdout = f # Change the standard output to the file we created
	print("#YBa2Cu3O7 cascade final frame converted from xyz to lmp\n")
	print("	%i atoms" % (no_atoms))
	print("	%i atom types\n" % (no_atom_types))
	print("	0.000000 %f xlo xhi" % (xhi))
	print("	0.000000 %f ylo yhi" % (yhi))
	print("	0.000000 %f zlo zhi" % (zhi))
	print("	0 0 0 xy xz yz")
	print("Atoms\n")
	print(finalatoms.to_string(index=False, header=False))
	sys.stdout = original_stdout # Reset the standard output to its original value

os.remove("myatoms.txt")
