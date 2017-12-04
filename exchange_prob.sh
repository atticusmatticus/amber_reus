#!/bin/bash

## Prints total number of exchanges followed by the ratio of exchanges to exchange attempts between those pairs

exchange_out=$1
runsA=$2
runsB=$3
windows=$4

declare -i win; win=$windows-1
declare -i j; j=1
for ((i=0;i<=$win;i+=2));
do
	if [ "$j" -gt $win ]; then
		var=$(cat $exchange_out | grep -o "Accept $i $i" | wc -l)
		ratioA=$(echo "$var / $runsA" | bc -l)
		echo Acceptance : \# : Ratio ---  $i $i : $var : $ratioA
	else
		var=$(cat $exchange_out | grep -o "Accept $i $j" | wc -l)
		ratioA=$(echo "$var / $runsA" | bc -l)
		echo Acceptance : \# : Ratio ---  $i $j : $var : $ratioA
	fi
	((j+=2))
done

echo '---- Other exchange direction ----'

declare -i j; j=2
for ((i=0;i<=$win;i+=2));
do
	if [ "$i" -eq 0 ]; then
		var=$(cat $exchange_out | grep -o "Accept $i $i" | wc -l)
		ratioB=$(echo "$var / $runsB" | bc -l)
		echo Acceptance : \# : Ratio ---  $i $i : $var : $ratioB
		((i=-1))
	elif [ "$j" -gt $win ]; then
		var=$(cat $exchange_out | grep -o "Accept $i $i" | wc -l)
		ratioB=$(echo "$var / $runsB" | bc -l)
		echo Acceptance : \# : Ratio ---  $i $i : $var : $ratioB
	else
		var=$(cat $exchange_out | grep -o "Accept $i $j" | wc -l)
		ratioB=$(echo "$var / $runsB" | bc -l)
		echo Acceptance : \# : Ratio ---  $i $j : $var : $ratioB
		((j+=2))
	fi
done
