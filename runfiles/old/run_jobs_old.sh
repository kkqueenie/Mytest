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
time_slope=$9

##
#number_line=6
current_location=$(pwd)

####function to run job at $data_location_dirname$N/$runcase
RunSingleJob(){
##run with given n_count and s_time(sleep time)
		N=$(( $n_count * $dN ))
		# check if n_count in range[nNs:nNe]
			if [ $n_count -lt $nNs ]; then
				exit; 
			fi
			if [ $n_count -gt $nNe ]; then
				exit; 
			fi
		#if runcase folder doesnt exist then skip this N
		if [ ! -d "$data_location_dirname$N/$runcase" ];
		then
			printf "\x1b[31m \tNO address: $data_location_dirname$N/$runcase \x1b[0m\n"
	    		return 0
	    		
		fi
		### run job in new tab
		cd $data_location_dirname$N/$runcase
		gnome-terminal --tab -t “$data_location_dirname$N” -- bash -c "pwd; printf \"\nsleep $s_time min\n\"; sleep $(( $s_time  ))m; printf \"\nStart\n\"; now=\$(date +\"%T\"); echo \"Current time : \$now\"; $Lammps_location < $inputfile_name > out;"
		#exec bash"
	
		printf "\t$data_location_dirname$N/$runcase: sleep $s_time min \n"
		cd $current_location

	}
	
	
function runJob_given_n_count(){

   	s_time=0
	for i in $@
	do
		n_count=$i; 	
		RunSingleJob;
		##set sleep time for next job on this node
		s_time=$(( $s_time + $time_slope * n_count));
	done

}
	
	
		
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
	
printf "\nrun jobs at $data_location_dirname\$N/$runcase\n"
	

if [ $nNs -eq 1 ] && [[ $nNe -eq 20 ]]  && [[ $number_line -eq 6 ]];
then
 
 
#: '
####	20 10 1 4	####	
	runJob_given_n_count 20 10 4 1

####	19 9 7	####	
	runJob_given_n_count 19 9 7
	
####	18 14 3	####	
	runJob_given_n_count 18 14 3
	
####	17 11 5 2	####	
	runJob_given_n_count 17 11 5 2
	
####	16 13 6	####	
	runJob_given_n_count 16 13 6

####	15 12 8	####	
	runJob_given_n_count 15 12 8
#'



else
##run from nNe to nNs
#: '
	###calculate n,N
	n_count=$(( $nNe+1 ))

	for (( counter=1; counter<=$number_line; counter++ ))
	do	
		s_time=0
		n_count=$(( $n_count - 1 ))
		RunSingleJob
	done
	
	s_time=$(( ($nNe-$number_line+1) * $time_slope ))
	### runloop
	for (( counter=n_count; counter>=1; counter-- ))
	do
		n_count=$(( $n_count - 1 ))
		RunSingleJob
		s_time=$(( $s_time + $time_slope * 1))

	done
#'	
	
##run from nNs to nNe
#
: '
	
#'
fi








