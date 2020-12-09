#!/bin/bash


#dN=delda N; nNs=start number; nNe=end  number;
dN=$1
nNs=$2
nNe=$3
initial_file_location=$4
data_location=$5
dirname=$6
#type_cat = ring_size or ring_num
type_cat=$7
type_cat_para=$8

build_folder=build_catenated
location_now=$(pwd)




## data address
if [ ! -d "$data_location" ]; then
    mkdir $data_location
fi


#### prepare chain from nNs*dN to nNe*dN every dN
for (( counter=$nNs; counter<=$nNe; counter++ ))
do
N=$(($dN * $counter))

if [ $type_cat == "ring_size" ]; then
	ring_size=$type_cat_para
	n_ring=$(( $N / $ring_size))
	
elif [ $type_cat == "ring_num" ]; then
	n_ring=$type_cat_para
	ring_size=$(( $N / $n_ring))
else
	printf "wrong cat_type!\n\n"
fi

### make dir
if [ ! -d "$data_location/$dirname$N" ]; then
    mkdir $data_location/$dirname$N
fi


#### create datafiles
cp $initial_file_location/$build_folder  $data_location/$dirname$N -r

echo "Pychain Input File

Total number of chain \"links\"/\"rings\"
$n_ring

Are the chain \"links\"/\"rings\" identical or non-identical (different number of points per chain/distance between points)
Y

Axis
X

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
Enter number of points that compose one chain link and distance between points in the following format: 4 64
Use one line per chain link in the above format (one space between)                                     distance(A), # points
If chain links are identical, use the following format:


Chains
0.5 $ring_size

If chain links are nonidentical, use the following format:


Chain_1
2.7 12
Chain_2
3 36
Chain_3
4.1222 64
Chain_4
5 25

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
If you change the formatting/spacing or text instructions in this file, the script may not work. Trim trailing spaces.
" > $data_location/$dirname$N/$build_folder/pychain_input

cd $data_location/$dirname$N/$build_folder
python3 pychain2-4.py pychain_input

cd $location_now
cp  $data_location/$dirname$N/$build_folder/data.chain $data_location/$dirname$N/data.chain

done
printf "\tbuild catenated chain done: $(($nNs*$dN)) to $(($nNe*$dN)) every $dN\n"




#' 


