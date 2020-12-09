#!/bin/bash


dN=$1
nNs=$2
nNe=$3
runcase=$4
data_location=$5
dirname=$6
filename=$7
para=$8

Lammps_location=/home/kq4/LAMMPS/lammps-3Mar20/src/lmp_mpi
#equil or continue
type_run=$9 
printf "\ttype_run = $type_run \n"


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


##PBS -l nodes=3:ppn=8
##PBS -l nodes=3:ppn=8:node
##create 

echo "#!/bin/bash

#PBS -l nodes=compute-0-13:ppn=1
#PBS -q default
#PBS -N $para$N-$runcase
#PBS -m abe
##PBS -r n
#PBS -V
cd \$PBS_O_WORKDIR

mpirun -np 1 $Lammps_location < in.Chain_implicit_solvent$add >out


	"> $data_location/$dirname$N/$runcase/$filename


done



printf "\tcreated $filename at $data_location/$dirname\$N/$runcase, from $(($nNs*$dN)) to $(($nNe*$dN)) every $dN\n"



: '

mpirun -np 1 /home/kq4/LAMMPS/lammps-3Mar20/src/lmp_mpi < in.Chain_implicit_solvent$add >out
mpirun -np 1 /home/kq4/LAMMPS/lammps-7Aug19_cpu/src/lmp_mpi < in.Chain_implicit_solvent$add >out
#mpirun -np 8 /home/kq4/LAMMPS/lammps-7Aug19_gpu/src/lmp_mpi -sf gpu -pk gpu 2 < in.ChainAtInterface >out
##mpirun -np 1 ~/lmp_mpi < in.Chain_implicit_solvent >out

'
