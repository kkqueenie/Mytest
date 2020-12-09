#!/bin/bash


: '  
./run.sh 
./run.sh &

' 
####need modify

dN=$1
nNs=$2
nNe=$3

file=$4
##$data_location $dirname



printf "\nStart Calculating Rg\n"



## Analysis Rg
#: ' 
for (( counter=$nNs; counter<=$nNe; counter++ ))
do
dirname=Chain-N
N=$(($dN * ($nNs+$counter-1)))
if [ ! -f "data/$dirname$N/$file" ];
then
    continue
fi


#analysis



mkdir data/$dirname$N/1_equil/analysis
#cp data/$dirname$N/1_equil/dump/dump_output.0.lammpstrj data/$dirname$N/1_equil/analysis
cp data/$dirname$N/1_equil/dump_Chain_all_time.lammpstrj data/$dirname$N/1_equil/analysis
cp example_test/1_equil/analysis/uniCal_input_interface_alltime  data/$dirname$N/1_equil/analysis


cd data/$dirname$N/1_equil/analysis

gnome-terminal --tab -t “$dirname$N” -- bash -c "pwd;~/bin/Universal_calc_Rg_101920.out  uniCal_input_interface_alltime > out_analysis;"
#~/bin/Universal_calc_Rg_101920.out  uniCal_input_interface_alltime > out_analysis
printf "\n\t analysis data/$dirname$N\n"
#sleep 3s

cd ../../../../




done
printf "\nUnicalc done\n"
sleep 3s



#' 






## Analysis Rg-gnuplot
#
: ' 
rm fit.log

for (( counter=$nNs; counter<=$nNe; counter++ ))
do
dirname=Chain-N
N=$(($dN * $counter))
if [ ! -f "data/$dirname$N/$file" ];
then
    continue
fi
#gnuplot Rg


#' 

##gnuplot -e "f(x)=b;fit [50:] f(x) './data/$dirname$N/1_equil/analysis/CalcData[dump_Chain_all_time.lammpstrj]_rg_COM-group_id-1' u 1:6 via b;"
#gnome-terminal --tab -t “$dirname$N” -- bash -c "gnuplot -e \"f(x)=b;fit [50:] f(x) './data/$dirname$N/1_equil/analysis/CalcData[dump_Chain_all_time.lammpstrj]_rg_COM-group_id-1' u 1:6 via b;\""

#
: ' 

done
printf "\ndone\n"
#cp  fit.log ./Rg/fit.log

cp  fit.log ./Rg/fit.log_Rg-N

sleep 3s
printf "\nFit by gnuplot done\n"

#' 





## Analysis fit.log
  


#
: ' 


cp ./Rg/fit.log_Rg-N ./Rg/fit-copy

file="./Rg/fit-copy"


#' 



#sed -n '/b               =/p' $file | sed 's/b               =//g'| sed 's/+\/-//g' | sed 's/(//g'| sed 's/)//g'  > ./Rg/tmp
#(NR+$nNs-1)
#awk 'BEGIN{printf "%-12s %-12s %-12s %-18s\n" ,"N","Rg","Error","Error%"} {printf "%-12s %-12s %-12s %-18s\n" ,NR*10,$1,$2,$3;}' ./Rg/tmp > ./Rg/Rg~N

#gnuplot -e "f(x)= a*x**B;fit [0:] f(x) './Rg/Rg~N' u ((\$1+$nNs-1)*$dN):2 via a,B;" 
#gnuplot -e "f(x)= a*x**B;fit [0:] f(x) './Rg/Rg~N' u 1:2 via a,B;" 
#
#sed -n '/b               =/p' $file  |  tee ./Rg/tmp | cat -n
#awk '$0=NR*50"\t"$1"\t"$2"\t"$3' ./Rg/tmp > ./Rg/Rg~N
#sed -i '00000' ./Rg/Rg~N
#cat ./Rg/Rg~N



#' 










