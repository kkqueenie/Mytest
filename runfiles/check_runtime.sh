#!/bin/bash


: '  
./run.sh 
./run.sh &

' 
#dN=delda N   nNs=start number nNe=end  number
dN=$1
nNs=$2
nNe=$3
data_location_dir=$4
checkfile=$5
outfile=$6




#: ' 

rm $outfile 

for (( counter=$nNs; counter<=$nNe; counter++ ))
do

N=$(($dN * $counter))

 ### make dir
echo -e "$N \t\c">> $outfile
tail -1  $data_location_dir$N/$checkfile | sed 's/Total wall time: //g'|awk '{print $1" \t"$1 }' | sed 's/:/ /3g' >> $outfile



done

printf "check runtime  $outfile done\n"




gnuplot -p -e " set xlabel \"N\"; set ylabel \"min\"; p '$outfile' u 1:(\$3*60+\$4+\$5/60); f(x)= a*x+b;fit f(x) '$outfile' u 1:(\$3*60+\$4+\$5/60) via a,b; rep f(x)-b;"


#gnuplot -p -e "set ydata time; set timefmt \"%H:%M:%S\"; set format y \"(\$%H*60+\$%M+\$%S/60)\"; p '$outfile' u 1:2;f(x)= a*x+b;fit [:] f(x) '$outfile' u 1:2 via a,b;"


#gnome-terminal --tab -t “check_runtime” -- bash -c "gnuplot ;""
#' 
###gnuplot note
#https://blog.csdn.net/liyuanbhu/article/details/8497582
#https://my.oschina.net/u/2265334/blog/1609964
#https://stackoverrun.com/cn/q/9669219

