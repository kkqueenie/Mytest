#!/bin/bash


#dN=delda N; nNs=start number; nNe=end  number;
dN=$1
nNs=$2
nNe=$3
runcase=$4
data_location=$5
dirname=$6
inputfile_location=$7
inputfile_name=$8


#### build runcase folder from nNs*dN to nNe*dN every dN
for (( counter=$nNs; counter<=$nNe; counter++ ))
do
	N=$(($dN * $counter))

	### check dir
	if [ ! -d "$data_location/$dirname$N" ]; then
	    printf "\x1b[31m NO address: $data_location/$dirname$N \x1b[0m\n"
	    continue
	fi



	##runcase runfile dir
	if [ ! -d "$data_location/$dirname$N/$runcase" ]; then
	    mkdir $data_location/$dirname$N/$runcase
	fi
	#if [ ! -d "$data_location/$dirname$N/$runcase/dump" ]; then
	#    mkdir $data_location/$dirname$N/$runcase/dump
	#fi
	if [ ! -d "$data_location/$dirname$N/$runcase/restart" ]; then
	    mkdir $data_location/$dirname$N/$runcase/restart
	fi

	##copy inputfile
	cp $inputfile_location/$inputfile_name  $data_location/$dirname$N/$runcase/$inputfile_name 



done
printf "\tbuild runcase folder done: $data_location/$dirname\$N/$runcase, from $(($nNs*$dN)) to $(($nNe*$dN)) every $dN\n"




#' 


