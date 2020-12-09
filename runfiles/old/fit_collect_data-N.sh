#!/bin/bash


dN=$1
nNs=$2
nNe=$3
analysis_data_location=$4
runcase=$5
data_filename=$6
data_location=$7
dirname=$8

data_name=`echo ${data_filename%.*}`

## Analysis fit.log
  
  


#: ' 
#tmp_str=`echo ${data_location/'/'/'-'}`

logfile=$analysis_data_location/fit.log_$data_name-N_$data_location-$runcase
outfile_name=$analysis_data_location/$data_name~N_$data_location-$runcase
tmp=$analysis_data_location/tmp

##https://segmentfault.com/a/1190000020613397
#https://zhidao.baidu.com/question/438085968979462404.html
#https://www.thinbug.com/q/9210270


#egrep 'data read|b               =' $logfile
#awk '/data read|b               =/' $logfile
#grep -E 'data read|b               =' $logfile | sed 's/b               =//g'| sed 's/+\/-//g' | sed 's/(//g'| sed 's/)//g'  | sed "s/FIT:    data read from //g" | sed "s/$data_location//g" | sed "s/$runcase//g"   | sed 's/\///g'  | sed "s/$data_name.lammpsdump//g"   | sed "s/$dirname//g" | sed 's/://' 
#| sed -r 's/.{3}$//'
  
  
grep -E 'data read|b               =' $logfile | sed 's/b               =//g'| sed 's/+\/-//g' | sed 's/(//g'| sed 's/)//g'    |sed 's/.*N//g'|sed 's/\/.*//g'  | tr '\n' ' ' | sed 's/% /%\n/g' > $tmp
 
 #cat $tmp 

awk 'BEGIN{printf "%-12s %-12s %-12s %-18s\n" ,"N","'$data_name'","Error","Error%"} {printf "%-12s %-12s %-12s %-18s\n" ,$1,$2,$3,$4;}' $tmp > $outfile_name




####other way
#sed -n '/b               =/p' $logfile | sed 's/b               =//g'| sed 's/+\/-//g' | sed 's/(//g'| sed 's/)//g'  > $tmp
#awk 'BEGIN{printf "%-12s %-12s %-12s %-18s\n" ,"N","'$data_name'","Error","Error%"} {printf "%-12s %-12s %-12s %-18s\n" ,(NR+'"$nNs"'-1)*"'$dN'",$1,$2,$3;}' $tmp > $outfile_name


#fit $outfile_name
gnuplot -e "f(x)= a*x**B;fit [0:] f(x) '$outfile_name' u 1:2 via a,B;" 


rm $logfile
rm $tmp

# sort and join
#https://blog.csdn.net/lliumt/article/details/21017335


