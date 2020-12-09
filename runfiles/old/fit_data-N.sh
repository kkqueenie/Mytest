#!/bin/bash


dN=$1
nNs=$2
nNe=$3
analysis_data_location=$4
runcase=$5
data_name=$6
data_location=$7

## Analysis fit.log
  
  


#: ' 


logfile=$analysis_data_location/fit.log_data-N_$data_location-$runcase
outfile_name=$analysis_data_location/$data_name~N_$data_location-$runcase
tmp=$analysis_data_location/tmp


#
sed -n '/b               =/p' $logfile | sed 's/b               =//g'| sed 's/+\/-//g' | sed 's/(//g'| sed 's/)//g'  > $tmp


awk 'BEGIN{printf "%-12s %-12s %-12s %-18s\n" ,"N","'$data_name'","Error","Error%"} {printf "%-12s %-12s %-12s %-18s\n" ,(NR+'"$nNs"'-1)*"'$dN'",$1,$2,$3;}' $tmp > $outfile_name

gnuplot -e "f(x)= a*x**B;fit [0:] f(x) '$outfile_name' u 1:2 via a,B;" 


rm $logfile
rm $tmp





