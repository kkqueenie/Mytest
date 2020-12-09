#!/bin/bash


##time unit :minute
Lammps_location=$1
dN=$2
nNs=$3
nNe=$4
inputfile_name=$5
data_location_dirname=$6
number_line=$7
runcase=$8


current_location=$(pwd)

####function to run job at $data_location_dirname$N/$runcase
		
RunMultiJob(){
##run with given n_count and s_time(sleep time) 
	
tab_name="N="
content="printf \"Total jobs: $# \n\";"
job_count=0

for n_count_tmp in $@
do
	N=$(( $n_count_tmp * $dN ))
	
	# check if n_count in range[nNs:nNe]
	if [ $n_count_tmp -lt $nNs ]; then
		exit; 
	elif [ $n_count_tmp -gt $nNe ]; then
		exit; 
	fi
	
	job_count=$(($job_count+1))
	
	#if runcase folder doesnt exist then skip this 
		if [ ! -d "$data_location_dirname$N/$runcase" ];
		then
			printf "\x1b[31m \tNO address: $data_location_dirname$N/$runcase \x1b[0m\n"
	    		continue
		fi
		
	tab_name="$tab_name($N)"
	content="$content cd $data_location_dirname$N/$runcase; echo \"Job$job_count: position:\"\$(pwd);  printf \"\tsleep $s_time min\n\"; sleep $(( $s_time  ))m; now=\$(date +\"%Y.%m.%d-%H:%M:%S\"); printf \"\tStart time : \$now\n\"; $Lammps_location < $inputfile_name > out; now=\$(date +\"%Y.%m.%d-%H:%M:%S\"); printf \"Job$job_count done: \$now\n\n\"; cd $current_location;"

done
		### run job in new tab
		if [ "$content" == "printf \"Total jobs: 0 \n\";" ];
		then
			return 0
		fi
		gnome-terminal --tab -t “$tab_name” -- bash -c  "$content exec bash;"
		#exec bash"
	}
	

function ceil(){
  floor=`echo "scale=0;$1/1"|bc -l ` # 
  add=`awk -v num1=$floor -v num2=$1 'BEGIN{print(num1<num2)?"1":"0"}'`
  echo `expr $floor  + $add`
}	
	
	
	
############################################################################################################
### run jobs in parallel	
	
printf "\nrun jobs at $data_location_dirname\$N/$runcase\n"
	
n_N=$(($nNe-$nNs+1))
job_per_line=`ceil $n_N/$number_line `


##run from nNe to nNs
#: '
	###calculate n,N
	n_count=$(( $nNe+1 ))

	count_line=-1
	for (( counter=$nNe; counter>=$nNs; counter--))
	do	
		s_time=0
		n_count=$(( $n_count - 1 ))
		
		count_line=$(($count_line+1))
		line_num=$(( `expr $count_line  % $number_line` +1))
		
		if [ $line_num -eq 1 ]; then
			LINE1=( "${LINE1[@]}" $n_count )
		elif [ $line_num -eq 2 ]; then
			LINE2=( "${LINE2[@]}" $n_count )
		elif [ $line_num -eq 3 ]; then
			LINE3=( "${LINE3[@]}" $n_count )
		elif [ $line_num -eq 4 ]; then
			LINE4=( "${LINE4[@]}" $n_count )
		elif [ $line_num -eq 5 ]; then
			LINE5=( "${LINE5[@]}" $n_count )
		elif [ $line_num -eq 6 ]; then
			LINE6=( "${LINE6[@]}" $n_count )
		elif [ $line_num -eq 7 ]; then
			LINE7=( "${LINE7[@]}" $n_count )
		elif [ $line_num -eq 8 ]; then
			LINE8=( "${LINE8[@]}" $n_count )
		fi
	done
	

#'	
	


	echo 'N=$(( $n_count * $dN ))'
	echo "dN=$dN"
	echo "line1: n_count = "${LINE1[@]}; RunMultiJob ${LINE1[@]}
	echo "line2: n_count = "${LINE2[@]}; RunMultiJob ${LINE2[@]}
	echo "line3: n_count = "${LINE3[@]}; RunMultiJob ${LINE3[@]}
	echo "line4: n_count = "${LINE4[@]}; RunMultiJob ${LINE4[@]}
	echo "line5: n_count = "${LINE5[@]}; RunMultiJob ${LINE5[@]}
	echo "line6: n_count = "${LINE6[@]}; RunMultiJob ${LINE6[@]}
	echo "line7: n_count = "${LINE7[@]}; RunMultiJob ${LINE7[@]}
	echo "line8: n_count = "${LINE8[@]}; RunMultiJob ${LINE8[@]}

