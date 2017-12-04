#!/bin/bash

i=$1
export CUDA_VISIBLE_DEVICES=$i
windows=$2
di=$3
run=$4
run_prv=$(($4 - 1))
MFP=$5
if [ $run -eq 0 ]; then
    while [ $i -lt $windows ]
    do
        cd win.$i
        echo Starting Window $i
        time $AMBERHOME/bin/pmemd.cuda -O -i reus.w$i.in -o $MFP.w$i.run$run.log -p ../$MFP.prmtop -c $MFP.w$i.start.rst -r $MFP.w$i.run$run.rst -x $MFP.w$i.run$run.mdcrd -inf $MFP.w$i.run$run.inf

        echo Finished Window $i
        mv $MFP.w$i.runYY.dat $MFP.w$i.run$run.dat
        ((i+=$di))
        cd ..
    done
else
    while [ $i -lt $windows ]
    do
        cd win.$i
        echo Starting Window $i
        time $AMBERHOME/bin/pmemd.cuda -O -i reus.w$i.in -o $MFP.w$i.run$run.log -p ../$MFP.prmtop -c $MFP.w$i.run$run_prv.rst -r $MFP.w$i.run$run.rst -x $MFP.w$i.run$run.mdcrd -inf $MFP.w$i.run$run.inf

        echo Finished Window $i
        mv -vf $MFP.w$i.runYY.dat $MFP.w$i.run$run.dat
        ((i+=$di))
        cd ..
    done
fi
