#!/usr/bin/python

## USAGE: python metropolis.py [window #1] [window #2] [window #1 restart file] [window #2 restart file]

# load libraries
import sys
import math
import MDAnalysis
import numpy as np
import random

##########################################################
###################### Sub Routines ######################
##########################################################

def computePbcDist2(r1,r2,box):
    dist2 = 0

    for j in range(0,3):
        temp = r1[j]-r2[j]
        if temp < -box[j]/2.0:
            temp += box[j]
        elif temp > box[j]/2.0:
            temp -= box[j]
        dist2 += temp*temp

    return dist2;


def ParseConfigFile(cfg_file):
    global top_file, start_dist, step_dist, spring_constant, T
    f = open(cfg_file)
    for line in f:
        if '#' in line:
            line, comment = line.split('#',1)
        if '=' in line:
            option, value = line.split('=',1)
            option = option.strip()
            value = value.strip()
            #print 'Option:', option, ' Value:', value

            if option.lower()=='topfile':
                top_file = value
            elif option.lower()=='start_dist':
                start_dist = float(value)
            elif option.lower()=='step_dist':
                step_dist = float(value)
            elif option.lower()=='spring_constant':
                spring_constant = float(value)
            elif option.lower()=='temperature':
                T = float(value)
            else:
                print 'Option:', option, ' is not recognized'
    f.close()

##########################################################
###################### Main Program ######################
##########################################################

cfg_file = sys.argv[1]
win1 = sys.argv[2]
win2 = sys.argv[3]
run = sys.argv[4]
MFP = sys.argv[5]

ParseConfigFile(cfg_file)

# compute distance in win1
rst_file_1 = "win."+win1+"/"+MFP+".w"+win1+".run"+run+".rst"

u_1 = MDAnalysis.Universe(top_file, rst_file_1,format='inpcrd')

sel1 = u_1.select_atoms('resid 1')
sel2 = u_1.select_atoms('resid 2')

coms = np.zeros((4,3),dtype=float)
coms[0] = sel1.center_of_mass()
coms[1] = sel2.center_of_mass()

dist_1 = math.sqrt(computePbcDist2(coms[0],coms[1],u_1.dimensions[:3]))

# compute distance in win2
rst_file_2 = "win."+win2+"/"+MFP+".w"+win2+".run"+run+".rst"

u_2 = MDAnalysis.Universe(top_file, rst_file_2,format='inpcrd')

sel3 = u_2.select_atoms('resid 1')
sel4 = u_2.select_atoms('resid 2')

coms[2] = sel3.center_of_mass()
coms[3] = sel4.center_of_mass()

dist_2 = math.sqrt(computePbcDist2(coms[2],coms[3],u_2.dimensions[:3]))

#print dist_1, dist_2

# Metropolis Algorithm
k = 0.001987 # kcal/(mol*K)
kT = k*T

win1f = float(win1)
win2f = float(win2)
r_1 = start_dist + (win1f * step_dist) # restraint 1 equilibrium distance
r_2 = start_dist + (win2f * step_dist) # restraint 2 equilibrium distance

deltaE = spring_constant * (r_1 - r_2) * (dist_1 - dist_2) # Energy after switch - Energy before switch
if deltaE > 0:
    metropolis = np.exp(-deltaE/kT) # compare to random number {0-1}? Greater than => yes, less than => no.
    #print metropolis
    rand = random.random()
    #print rand
    if metropolis >= rand:
        print 1
    else:
        print 0
        #sys.stderr.write('Error in metropolis.py\n') # print error to screen or log file. DOES THIS ACTUALLY MEAN THERE IS AN ERROR???
else:
    print 1
