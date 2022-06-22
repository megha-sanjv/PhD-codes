#! /usr/bin/env python
#----------------------------------------------------------------------------------------------#
# Script Name:	meanprof.py	                                                       	       #
# Description:	script to average the results from each chunk from each timestep	       #
# 		to be used in conjuction with compro.sh
# Author:	Megha Sanjeev
# Version:	09/09/2019                                                                  #
#----------------------------------------------------------------------------------------------#

import csv
from collections import defaultdict
columns = defaultdict(list)
temp=300
with open("tp_%d.dat" % temp) as f:
	reader = csv.reader(f, delimiter="\t", quoting=csv.QUOTE_NONNUMERIC)
	for row in reader:
		for (i,v) in enumerate(row):
			(columns[i]).append(v)
r = 0
n_col = 400-51 #number of columns (number of sets of data in profile)
#colf = c + n_col
n_chunks = 20

k = 0.00008617 #boltzmann k in eV

i = 1
 #change to where you want to average from. Look at where data converges. 
aveStart_step = 400-350
aveStart = n_col -aveStart_step
tot = 0
j = aveStart
while r < n_chunks:
	while j <= n_col:
		tot = tot  + columns[j][r] 
		j = j + 1
		ave = tot/(n_col-aveStart+1) #calculate average
		ave = ave/k #unit conversion
	print(i), 
	print((ave)) 
	tot = 0
	j = aveStart
	i = i + 1
	r = r + 1


