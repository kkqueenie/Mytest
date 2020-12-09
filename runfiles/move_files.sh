#!/bin/bash


#dN=delda N; nNs=start number; nNe=end  number;
dN=$1
nNs=$2
nNe=$3
data_location=$4
dirname=$5
#flag = move or remove
flag=$6
name1=$7
name2=$8





#### from nNs*dN to nNe*dN every dN
for (( counter=$nNs; counter<=$nNe; counter++ ))
do
N=$(($dN * $counter))

	if [ $flag == "move" ];then
		mv $data_location/$dirname$N/$name1 $data_location/$dirname$N/$name2
	elif	[ $flag == 'remove' ];then
		rm $data_location/$dirname$N/$name1 -r
	fi

done

	if [ $flag == 'move' ];then
		printf "\tmoved file/directory $name1 to $name2\n"
	elif	[ $flag == 'remove' ];then
		printf "\tremove file/directory $name1 \n"
	fi



#' 


