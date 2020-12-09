#!/bin/bash


#dN=delda N; nNs=start number; nNe=end  number;
dN=$1
nNs=$2
nNe=$3
data_location=$4
dirname=$5
runcase=$6





#### from nNs*dN to nNe*dN every dN
for (( counter=$nNs; counter<=$nNe; counter++ ))
do
N=$(($dN * $counter))

rm $data_location/$dirname$N/$runcase/dump/*

done
printf "\t rm $data_location/$dirname$N/$runcase/dump/*\n"




#' 


