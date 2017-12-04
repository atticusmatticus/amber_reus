#!/bin/bash

MFP=PDI3p

for ((i=0;i<=38;i++)); do
	rm win.$i/$MFP.w$i.run*
	rm win.$i/$MFP.w$i.sorted*
done
