#!/bin/bash

runs=20000
start_run=0
ngpu=1
windows=39
MFP=PDI3p
exchange_out=reus.exchange.log
cpptraj_combine=combine_trajectories.cpptraj
cpptraj_freq=1000

############################################################################
./print_MDAnalysis_version.py
i=0
declare -i win; win=$windows-1
declare -i exchange_count; exchange_count=0
declare -i runsA; runsA=0
declare -i runsB; runsB=0
rm $exchange_out
declare -i cpp_count; cpp_count=0

for ((run=$start_run; run<$runs; run++)); do
	declare -i next_run; next_run=$run+1
	echo Starting Run $run
	while [ $i -lt $ngpu ]
	do
		./run_reus.sh $i $windows $ngpu $run $MFP &
		((i++))
	done
	wait

	# choose direction of exchange attempt
	if [ $exchange_count -eq 0 ]; then # Run A
		declare -i j; j=1
		for ((k=0;k<=$win;k+=2)); do
			if [ "$j" -gt $win ]; then
				# will always accept
				cp win.$k/$MFP.w$k.run$run.rst win.$k/$MFP.w$k.run$next_run.rst
				echo Exchange Accept $k $k Run $run >> $exchange_out
			else
				var=$(./metropolis.py metropolis.cfg $k $j $run $MFP)
				if [ "$var" -eq 1 ]; then
					cp win.$k/$MFP.w$k.run$run.rst win.$j/$MFP.w$j.run$next_run.rst
					cp win.$j/$MFP.w$j.run$run.rst win.$k/$MFP.w$k.run$next_run.rst
					echo Exchange Accept $k $j Run $run >> $exchange_out
				elif [ "$var" -eq 0 ]; then
					echo Exchange Deny $k $j Run $run >> $exchange_out
				fi
			fi
			((j+=2))
		done
		declare -i exchange_count; exchange_count=1
		((runsA++))
	else # Run B
		declare -i j; j=2
		for ((k=0;k<=$win;k+=2)); do
			if [ "$k" -eq 0 ]; then
				# will always accept
				cp win.$k/$MFP.w$k.run$run.rst win.$k/$MFP.w$k.run$next_run.rst
				echo Exchange Accept $k $k Run $run >> $exchange_out
				((k=-1))
			elif [ "$j" -gt $win ]; then
				# will always accept
				cp win.$k/$MFP.w$k.run$run.rst win.$k/$MFP.w$k.run$next_run.rst
				echo Exchange Accept $k $k Run $run >> $exchange_out
			else
				var=$(./metropolis.py metropolis.cfg $k $j $run $MFP)
				if [ "$var" -eq 1 ]; then
					cp win.$k/$MFP.w$k.run$run.rst win.$j/$MFP.w$j.run$next_run.rst
					cp win.$j/$MFP.w$j.run$run.rst win.$k/$MFP.w$k.run$next_run.rst
					echo Exchange Accept $k $j Run $run >> $exchange_out
				elif [ "$var" -eq 0 ]; then
					echo Exchange Deny $k $j Run $run >> $exchange_out
				fi
				((j+=2))
			fi
		done
		declare -i exchange_count; exchange_count=0
		((runsB++))
	fi

	echo Run $run Finished
	i=0

	## Generate cpptrajed files
	if [ $run -gt 0 ] && [ $(($run % $cpptraj_freq)) -eq 0 ];then
        for ((w=0; w<=$win; w++)); do
            echo "parm $MFP.prmtop" > $cpptraj_combine

            declare -i cpp_initial; cpp_initial=$run-$cpptraj_freq
            for ((cpp=$cpp_initial; cpp<$run; cpp++)); do
                echo "trajin win.$w/$MFP.w$w.run$cpp.mdcrd" >> $cpptraj_combine
                cat win.$w/$MFP.w$w.run$cpp.log >> win.$w/$MFP.w$w.sorted$cpp_count.log
                awk 'NR > 2 {print NR-3 "     " $2}' win.$w/$MFP.w$w.run$cpp.dat >> win.$w/$MFP.w$w.sorted$cpp_count.dat
            done

            echo "trajout win.$w/$MFP.w$w.sorted$cpp_count.nc netcdf" >> $cpptraj_combine
            echo "autoimage" >> $cpptraj_combine
            echo "go" >> $cpptraj_combine
            cpptraj -i $cpptraj_combine
            rm -v $cpptraj_combine
            ## Remove all but the latest files so that next run has reference files.
            for ((R=$cpp_initial; R<$run; R++)); do
                rm -v win.$w/$MFP.w$w.run$R.mdcrd
                rm -v win.$w/$MFP.w$w.run$R.inf
                rm -v win.$w/$MFP.w$w.run$R.rst
                rm -v win.$w/$MFP.w$w.run$R.log
                rm -v win.$w/$MFP.w$w.run$R.dat
            done
        done
        ((cpp_count++))
	fi
done
echo Calculating exhcange probabilities
./exchange_prob.sh $exchange_out $runsA $runsB $windows >> $exchange_out
echo All Done!
