#!/bin/bash


#dN=delda N; nNs=start number; nNe=end  number;
dN=$1
nNs=$2
nNe=$3
initial_file_location=$4
data_location=$5
dirname=$6


## build data in "atom_style bond" style
gfortran $initial_file_location/build/chain_bond.f -o $initial_file_location/build/chain_bond.out


## data address
if [ ! -d "$data_location" ]; then
    mkdir $data_location
fi


#### prepare chain from nNs*dN to nNe*dN every dN
for (( counter=$nNs; counter<=$nNe; counter++ ))
do
N=$(($dN * $counter))

### make dir
if [ ! -d "$data_location/$dirname$N" ]; then
    mkdir $data_location/$dirname$N
fi


#### create datafiles
cp $initial_file_location/build  $data_location/$dirname$N -r

echo "Polymer chain definition

0.001          rhostar
592984          random # seed (8 digits or less)
1               # of sets of chains (blank line + 6 values for each set)
0               molecule tag rule: 0 = by mol, 1 = from 1 end, 2 = from 2 ends

1            number of chains
$N             monomers/chain
1               type of monomers (for output into LAMMPS file)
1               type of bonds (for output into LAMMPS file)
0.97            distance between monomers (in reduced units)
1.02            no distance less than this from site i-1 to i+1 (reduced unit)" > $data_location/$dirname$N/build/chain.def

$data_location/$dirname$N/build/chain_bond.out < $data_location/$dirname$N/build/chain.def > $data_location/$dirname$N/build/chain.dat
cp  $data_location/$dirname$N/build/chain.dat $data_location/$dirname$N/data.chain

done
printf "\tbuild chain done: $(($nNs*$dN)) to $(($nNe*$dN)) every $dN\n"




#' 


