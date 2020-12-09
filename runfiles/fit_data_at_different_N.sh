#!/bin/bash



dN=$1
nNs=$2
nNe=$3

#flag=calc of dump
flag=$4
data_location=$5
dirname=$6
analysis_data_location=$7
runcase=$8
data_filename=$9
shift 9
skip_step=$1
flag_case=$2
changing_para=$3

data_location_dir=$data_location/$dirname
#data_location=`echo $data_location_dir | cut -d "/" -f 1 `

data_name=`echo ${data_filename%.*}`

printf "\nStart fitting data\n"

echo $flag_case

## Analysis data-gnuplot
#: ' 
rm fit.log

for (( counter=$nNs; counter<=$nNe; counter++ ))
do
	N=$(($dN * $counter))
	if [ "$flag_case" == "normal" ]; then
		runcase_position=$data_location_dir$N/$runcase
	elif [ "$flag_case" == "superposition" ]; then
		runcase_position=$data_location/$runcase
	fi

	if [ $flag == calc ]; ###this part need modify
	then
		gnuplot -e "f(x)=b;fit [50:] f(x) '$runcase_position/analysis/CalcData[dump_Chain_all_time.lammpstrj]_rg_COM-group_id-1' u 1:6 via b;"
		#gnome-terminal --tab -t “$dirname$N” -- bash -c "gnuplot -e \"f(x)=b;fit [50:] f(x) '$runcase_position/analysis/CalcData[dump_Chain_all_time.lammpstrj]_rg_COM-group_id-1' u 1:6 via b;\""


	elif [ $flag == dump ];
	then
		echo $runcase_position/$data_filename
		gnuplot -e "f(x)=b;fit [$skip_step:] f(x) '$runcase_position/$data_filename' u 1:2 via b;"
	fi



done
printf "\nfit data at $data_location_dir\$N/$runcase/$data_filename from $nNs to $nNe every $dN done\n"



logfile=$analysis_data_location/fit.log_$data_name_$data_location-$runcase
cp  fit.log $analysis_data_location/fit.log_$data_name_$data_location-$runcase
rm fit.log
#sleep 3s
#printf "\nCopy gnuplot log to $analysis_data_location/fit.log_$data_name-N_$data_location-$runcase\n\n"

#' 







##https://segmentfault.com/a/1190000020613397
#https://zhidao.baidu.com/question/438085968979462404.html
#https://www.thinbug.com/q/9210270


#egrep 'data read|b               =' $logfile
#awk '/data read|b               =/' $logfile
#grep -E 'data read|b               =' $logfile | sed 's/b               =//g'| sed 's/+\/-//g' | sed 's/(//g'| sed 's/)//g'  | sed "s/FIT:    data read from //g" | sed "s/$data_location//g" | sed "s/$runcase//g"   | sed 's/\///g'  | sed "s/$data_name.lammpsdump//g"   | sed "s/$dirname//g" | sed 's/://' 
#| sed -r 's/.{3}$//'
  

tmp=$analysis_data_location/tmp

 	if [ "$flag_case" == "normal" ]; then
 		outfile_name=$analysis_data_location/$data_name~N_$data_location-$runcase
		grep -E 'data read|b               =' $logfile | sed 's/b               =//g'| sed 's/+\/-//g' | sed 's/(//g'| sed 's/)//g'    |sed 's/.*N//g'|sed 's/\/.*//g'  | tr '\n' ' ' | sed 's/% /%\n/g' > $tmp
		awk 'BEGIN{printf "%-12s %-12s %-12s %-18s\n" ,"N","'$data_name'","Error","Error%"} {printf "%-12s %-12s %-12s %-18s\n" ,$1,$2,$3,$4;}' $tmp > $outfile_name
		
	elif [ "$flag_case" == "superposition" ]; then
		outfile_name=$analysis_data_location/$data_name~"$changing_para"_$data_location-$runcase
		grep -E 'data read|b               =' $logfile | sed 's/b               =//g'| sed 's/+\/-//g' | sed 's/(//g'| sed 's/)//g'   |sed "s/.*"$changing_para"//g"| sed 's/-.*//g' |sed 's/\/.*//g' | tr '\n' ' ' | sed 's/% /%\n/g'  |sed "s/FIT:    data read from '//g"  > $tmp
		if [ $changing_para == "temperature" ];then
			#cat  $tmp | sed "s/"$changing_para"/T/g"  >  $tmp
			grep -E 'data read|b               =' $logfile | sed 's/b               =//g'| sed 's/+\/-//g' | sed 's/(//g'| sed 's/)//g'   |sed "s/.*T//g"| sed 's/-.*//g' |sed 's/\/.*//g' | tr '\n' ' ' | sed 's/% /%\n/g'  |sed "s/FIT:    data read from '//g"   > $tmp
		fi
		awk 'BEGIN{printf "%-12s %-12s %-12s %-18s\n" ,"'$changing_para'","'$data_name'","Error","Error%"} {printf "%-12s %-12s %-12s %-18s\n" ,$1,$2,$3,$4;}' $tmp > $outfile_name
		
	
	fi
	
 cat $tmp 





####other way
#sed -n '/b               =/p' $logfile | sed 's/b               =//g'| sed 's/+\/-//g' | sed 's/(//g'| sed 's/)//g'  > $tmp
#awk 'BEGIN{printf "%-12s %-12s %-12s %-18s\n" ,"N","'$data_name'","Error","Error%"} {printf "%-12s %-12s %-12s %-18s\n" ,(NR+'"$nNs"'-1)*"'$dN'",$1,$2,$3;}' $tmp > $outfile_name


#fit $outfile_name
gnuplot -e "f(x)= a*x**B;fit [0:] f(x) '$outfile_name' u 1:2 via a,B;" 


rm $logfile
rm $tmp
rm fit.log

printf "\nCollected $data_name data at $outfile_name\n\n"




