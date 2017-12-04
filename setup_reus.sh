#!/bin/bash

# USAGE: ./setup_reus.sh [first win #] [last win #] [win step] [first distance] [last distance] [step distance] [MFP] [source start] [source end] [source step]

# the three source parameters are the numbers that correspond to the files that the starting coordinates are coming from.

MFP=$7
l=$8

for ((i=$1; i<=$2; i+=$3));
do
	mkdir win.$i
	sed -e s/XX/$i/g -e s/MFP/$MFP/g < reus.in > win.$i/reus.w$i.in
	sed -e s/YY/$l/g -e s/XX/$i/g -e s/MFP/$MFP/g < starting_windows.cpptraj > starting_windows.cpptraj.tmp
	cpptraj -i starting_windows.cpptraj.tmp
	((l+=$10))
done

j=$1
for k in $(seq $4 $6 $5)
do
	sed -e s/ZZ/$k/g < restraint_file.rst > win.$j/restraint_$j.rst
	((j+=$3))
done

rm starting_windows.cpptraj.tmp

echo MFP: $MFP
echo First window \#: $1
echo Last window \#: $2
echo Window step: $3
echo First Distance: $4
echo Last Distance: $5
echo Step Distance: $6
