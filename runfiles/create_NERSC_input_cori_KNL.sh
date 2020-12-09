#!/bin/bash


dN=$1
nNs=$2
nNe=$3
runcase=$4
data_location=$5
dirname=$6
filename=$7
para=$8

#equil or continue
type_run=$9 

shift 9
time_hour=$1



printf "\ttype_run = $type_run, time_hour = $time_hour \n"


if [ $type_run == "equil" ];then
	add=""
elif [ $type_run == "continue" ];then
	add="_continue"
else
	printf "type_run error\n"
fi


for (( counter=$nNs; counter<=$nNe; counter++ ))
do
	N=$(($dN * $counter))

	### check dir
	if [ ! -d "$data_location/$dirname$N" ]; then
	    printf "\x1b[31m NO address: $data_location/$dirname$N \x1b[0m\n"
	    exit
	fi



##runcase runfile dir

	##create cori_KNL.in
echo "#!/bin/bash
#SBATCH -J $para$N$add
#SBATCH -C knl
#SBATCH -q regular
#SBATCH -N 1
#SBATCH -t $time_hour:00:00
#SBATCH -o implicit0.o%j


srun -n 1 -c 2 --cpu-bind=cores /global/homes/a/akronfy7/LAMMPS/lammps-3Mar20/build/lmp < in.Chain_implicit_solvent$add > out
	"> $data_location/$dirname$N/$runcase/$filename


done



printf "\tcreated $filename at $data_location/$dirname\$N/$runcase, from $(($nNs*$dN)) to $(($nNe*$dN)) every $dN\n"




