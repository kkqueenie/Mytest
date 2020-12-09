#!/bin/bash


##time unit :minute
Lammps_location=$1
dN=$2
nNs=$3
nNe=$4
inputfile_name=$5
data_location=$6
number_line=$7
case_name=$8
runcase=$9
shift 9
epsilon=$1
rc=$2
temperature=$3
changing_para=$4
shift 4
para_all=$@
n_para=$#
echo "total num of para = $n_para"
printf "para_all = $para_all \n" 


##
#number_line=6
current_location=$(pwd)
	
	
	replace_tmp=PARA
	
	if [ "$changing_para" == "epsilon" ]; then
		case_name_tmp=${case_name/epsilon$epsilon/epsilon$replace_tmp}
		epsilon_rc_T[0]=$replace_tmp	
	elif [ "$changing_para" == "rc" ]; then
		case_name_tmp=${case_name/rc$rc/rc$replace_tmp}
		epsilon_rc_T[1]=$replace_tmp	
	elif [ "$changing_para" == "temperature" ]; then
		case_name_tmp=${case_name/T$temperature/T$replace_tmp}
		epsilon_rc_T[2]=$replace_tmp
	else 
		echo "Wrong changing_para!"
		return 0
	fi


	
	
RunMultiJob(){
##run with given para

N=$(( $n_count * $dN ))
		# check if n_count in range[nNs:nNe]
	if [ $n_count -lt $nNs ]; then
		exit; 
	fi
	if [ $n_count -gt $nNe ]; then
		exit; 
	fi
	
	
tab_name="$changing_para="
content="printf \"Total jobs: $# \n\";"
job_count=0

for para in $@
do
	job_count=$(($job_count+1))
	case_name_para=${case_name_tmp/$replace_tmp/$para}
	#if runcase folder doesnt exist then skip this 
		if [ ! -d "$data_location/$case_name_para/$runcase" ];
		then
			printf "\x1b[31m \tNO address: $data_location/$case_name_para/$runcase \x1b[0m\n"
	    		continue
		fi
		
	tab_name="$tab_name($para)"
	content="$content cd $data_location/$case_name_para/$runcase; echo \"Job$job_count: position:\"\$(pwd);  printf \"\tsleep $s_time min\n\"; sleep $(( $s_time  ))m; now=\$(date +\"%Y.%m.%d-%H:%M:%S\"); printf \"\tStart time : \$now\n\"; $Lammps_location < $inputfile_name > out; now=\$(date +\"%Y.%m.%d-%H:%M:%S\"); printf \"Job$job_count done: \$now\n\n\"; cd $current_location;"

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
	
printf "\nrun jobs at $data_location\n"


#############################################################
job_per_line=`ceil $n_para/$number_line `
s_time=0
n_count=1




	#: '
	count_para=-1
	for para in ${para_all[@]}
	do
		count_para=$(($count_para+1))
		line_num=$(( `expr $count_para  % $number_line` +1))
		#echo $line_num
		if [ $line_num -eq 1 ]; then
			LINE1=( "${LINE1[@]}" $para )
		elif [ $line_num -eq 2 ]; then
			LINE2=( "${LINE2[@]}" $para )
		elif [ $line_num -eq 3 ]; then
			LINE3=( "${LINE3[@]}" $para )
		elif [ $line_num -eq 4 ]; then
			LINE4=( "${LINE4[@]}" $para )
		elif [ $line_num -eq 5 ]; then
			LINE5=( "${LINE5[@]}" $para )
		elif [ $line_num -eq 6 ]; then
			LINE6=( "${LINE6[@]}" $para )
		elif [ $line_num -eq 7 ]; then
			LINE7=( "${LINE7[@]}" $para )
		elif [ $line_num -eq 8 ]; then
			LINE8=( "${LINE8[@]}" $para )
			
		fi
	done
	
	echo "line1: para = "${LINE1[@]}; RunMultiJob ${LINE1[@]}
	echo "line2: para = "${LINE2[@]}; RunMultiJob ${LINE2[@]}
	echo "line3: para = "${LINE3[@]}; RunMultiJob ${LINE3[@]}
	echo "line4: para = "${LINE4[@]}; RunMultiJob ${LINE4[@]}
	echo "line5: para = "${LINE5[@]}; RunMultiJob ${LINE5[@]}
	echo "line6: para = "${LINE6[@]}; RunMultiJob ${LINE6[@]}
	echo "line7: para = "${LINE7[@]}; RunMultiJob ${LINE7[@]}
	echo "line8: para = "${LINE8[@]}; RunMultiJob ${LINE8[@]}

	
	#'
	




