#!/bin/bash

#============================================================================================================
###input parameters start for this run
: '  
#### created by KunQ 2020 ####
to run this file put this in command line: ./run.sh or ./run.sh &

######## NOTICE ########
All the parameters are modified at the end: main control


' 


########constant########

###LAMMPS details
	#LAMMPS_location=~/bin/lmp-3Mar20_102920
	##tg## LAMMPS_location=~/bin/lmp_29Oct20_110620
	LAMMPS_location=~/bin/lmp_29Oct20_110920

###runing details: timestep; running lentgh	
	tstep=0.01 
	step_per_dump=1000000
	time_per_dump=$(bc<<<"$tstep * $step_per_dump /1")
	dump_frequency=10000

###others
	current_location=$(pwd)
	initial_file_location=$current_location/initial_files
	testrun_location=$initial_file_location/testrun
	runfiles_location=$current_location/runfiles
	inputfile_location=$initial_file_location
	analysis_data_folder_name=analysis_data
	analysis_data_location=$current_location/$analysis_data_folder_name	
	dirname=Chain-N
	

#------------------------------------------------------------------------------------------------------------	
#### Other parameters need changes in functions
	
#------------------------------------------------------------------------------------------------------------
			
#------------------------------------------------------------------------------------------------------------

#============================================================================================================

#============================================================================================================
##################### run from runfile ###########################


#------------------------------------------------------------------------------------------------------------

######	parameters  ######
##### get parameter fuctions

function get_parameters_dN_nNs-nNe(){	

# global parameters	
	running_loop=$5; total_tau=$(( $time_per_dump * $running_loop/1000/1000))M
	runcase=$6_tau-$total_tau
	dN=$2; nNs=$3; nNe=$4; data_location=data_$(($dN * $nNs))-$(($dN ))-$(($dN * $nNe))



### equilibrum parameters
	inputfile_name_equil=in.Chain_implicit_solvent
### continue parameters	
	inputfile_name_continue=in.Chain_implicit_solvent_continue
	restart_runcase=$7


#run_type = equil or continue
	run_type=$1
	if [ $run_type == "equil" ]; then
		inputfile_name=$inputfile_name_equil
	elif [ $run_type == "continue" ]; then
		inputfile_name=$inputfile_name_continue
	fi
}



########################
###chose one parameter case




#------------------------------------------------------------------------------------------------------------
####### Preparation #######

function Preparation_equil(){
#### create_input, testrun, build chains, create log 
	###create_input epsilon, rc, address
	$runfiles_location/create_input_implicit.sh $epsilon $rc $temperature $damp $tstep $step_per_dump $running_loop $dump_frequency $inputfile_location $inputfile_name

	##run test run
	$runfiles_location/testrun.sh $LAMMPS_location $testrun_location $inputfile_location $inputfile_name

	
	if [ $chain_type == "linear" ]; then
		##build linear chains
		$runfiles_location/build_chain_linear.sh $dN $nNs $nNe $initial_file_location $data_location $dirname
		
	elif [ $chain_type == "catenated" ]; then
		##build catnated chains ## type_cat = ring_size or ring_num
		$runfiles_location/build_chain_catenated.sh $dN $nNs $nNe $initial_file_location $data_location $dirname $cat_type $cat_para
	elif [ $chain_type == "ring" ]; then
		##build ring chains ## type_cat = ring_size or ring_num
		$runfiles_location/build_chain_catenated.sh $dN $nNs $nNe $initial_file_location $data_location $dirname $cat_type $cat_para
		
	else
		printf "wrong chain_type!\n\n"
	fi
	
	##build runcase folder and copy inputfile
	$runfiles_location/build_runcase.sh $dN $nNs $nNe $runcase $data_location $dirname $inputfile_location $inputfile_name 
		
	##create README-logfile #filename
	#$runfiles_location/create_README.log.sh $data_location/README.log-$runcase

}



function Preparation_continue(){
	###restartfile location: ../$restart_runcase/restart/final.restart	
	$runfiles_location/create_input_continue.sh $inputfile_location $inputfile_name_equil $inputfile_name_continue $restart_runcase $running_loop final.restart	
	
	##build runcase folder and copy inputfile
	$runfiles_location/build_runcase.sh $dN $nNs $nNe $runcase $data_location $dirname $inputfile_location $inputfile_name
}


function Preparation_stoped_continue(){
	echo "create pair input_equil"
	$runfiles_location/create_input_implicit.sh $epsilon $rc $temperature $damp $tstep $step_per_dump $running_loop $dump_frequency $inputfile_location $inputfile_name >/dev/null
	get_parameters_dN_nNs-nNe continue $dN $nNs $nNe $running_loop $runcase-continue $runcase 
	$runfiles_location/build_runcase.sh $dN $nNs $nNe $runcase $data_location $dirname $inputfile_location $inputfile_name  >/dev/null
	runcase_tmp=$runcase
	running_loop_tmp=$running_loop
	echo "restart_runcase=$restart_runcase"
	
#: '	
	for (( counter=$nNs; counter<=$nNe; counter++ ))
	do
		N=$(( $dN * counter ))
		restart_location=$data_location/$dirname$N/$restart_runcase/restart
		for file in $(ls $restart_location)
		do
			#mv $restart_location/$file `echo $restart_location/$file|sed 's/restart_equil/restart/'`
			if [ ! -s $restart_location/$file ];then
				#echo "$file is 0"
				rm $restart_location/$file
			fi
		done
		restart_filename=restart.`ls $restart_location | sed 's/restart.//' | sort -n | tail -1 | head -1`
		loop_now=$(( $(( `ls $restart_location | sed 's/restart.//' | sort -n | tail -1 | head -1`)) / $step_per_dump ))
		if [ $loop_now == $running_loop_tmp ];then
			#printf "\t$data_location/$dirname$N was finised: rm $data_location/$dirname$N/$runcase_tmp \n"
			#rm $data_location/$dirname$N/$runcase_tmp -r
			continue
		fi
		
		
		get_parameters_dN_nNs-nNe continue $dN $nNs $nNe $(($running_loop_tmp-loop_now)) $restart_runcase-continue $restart_runcase 
		runcase=$runcase_tmp;  #runcase_tmp=restart_runcase-continue+end

		$runfiles_location/create_input_continue.sh $inputfile_location $inputfile_name_equil $inputfile_name_continue $restart_runcase $running_loop $restart_filename	>/dev/null
		
		cp $inputfile_location/$inputfile_name_continue $data_location/$dirname$N/$runcase/
		
		printf "\n\t$data_location/$dirname$N/$restart_runcase was not finised: \n\tloop_now is $loop_now and rest running_loop is $running_loop\n\t$data_location/$dirname$N/$runcase_tmp created\n\tinput_continue modified from input\n"
		: '
		rm $data_location/$dirname$N/$runcase_tmp -r
		mkdir $data_location/../../tmp_folder/$CASE_location
		cp $data_location/$dirname$N/ -r  $data_location/../../tmp_folder/$CASE_location
		'
	done
#'	
}



########################
#Preparation_equil
#Preparation_continue


#------------------------------------------------------------------------------------------------------------
#####create_nersc_input cori_KNL.sh	#equil or continue

	
function Create_nersc_input(){
#time_hour=$9
	#$runfiles_location/create_NERSC_input_cori_KNL.sh	$dN $nNs $nNe $runcase $data_location $dirname cori_KNL.sh $2 $1 
	$runfiles_location/create_NERSC_input_cori_KNL.sh	$3 $4 $5 $runcase $data_location $dirname cori_KNL.sh $2 $1 	$6
	
}

########################
#Create_nersc_input equil	$chain_type$rc-C	$dN $nNs $nNe $time_hour
#Create_nersc_input continue	$chain_type$rc-C	$dN $nNs $nNe $time_hour


#------------------------------------------------------------------------------------------------------------
#######create_aedin_JobSubmission_script	#equil or continue

function Create_aedin_input(){
	$runfiles_location/create_aedin_JobSubmission_script.sh	$dN $nNs $nNe $runcase $data_location $dirname JobSubmission.in $2 $1
}
########################
#Create_aedin_input equil	$chain_type$rc-C
#Create_aedin_input continue 	$chain_type$rc-C


#------------------------------------------------------------------------------------------------------------
###### run jobs ######

function Run_jobs_N(){

## run_dN is not related to data_location
	run_dN=$1; run_nNs=$2; run_nNe=$3
## number_line is the max num of job runing at same time
	number_line=$4
		
##$LAMMPS_location $run_dN $run_nNs $run_nNe $inputfile $data_location $dirname $runcase
	$runfiles_location/run_jobs_N.sh $LAMMPS_location $run_dN $run_nNs $run_nNe $inputfile_name $data_location/$dirname $number_line $runcase 

}



########################

#Run_jobs $dN $nNs $nNe 6


#------------------------------------------------------------------------------------------------------------
#### old methold to fit Rg
###
#$runfiles_location/calculate_Rg_local.sh $dN $nNs $nNe 1_equil/dump_Chain_all_time.lammpstrj 
#$runfiles_location/fit_Rg_at_different_N.sh $dN $nNs $nNe calc

#------------------------------------------------------------------------------------------------------------
###### Collect RgRe~N ###### 
function Get_data-RgRe~N(){
	##data_location cant have "/", cause it will be included in file name
	
	dN=$1; nNs=$2; nNe=$3; skip_para=$4
	
#skip first 1/skip_para  such as 1/10
	skip_step=$(( $step_per_dump * $running_loop / $skip_para ))



	for data_filename in Re.lammpsdump Rg.lammpsdump 
	do
	###skip first $skip_step step 
	$runfiles_location/fit_data_at_different_N.sh $dN $nNs $nNe dump $data_location $dirname $analysis_data_location $runcase $data_filename $skip_step $flag_case $changing_para
	done
	
	if [ "$flag_case" == "normal" ]; then
		paste -d "\t" $analysis_data_location/Rg~N_$data_location-$runcase $analysis_data_location/Re~N_$data_location-$runcase > $analysis_data_location/Rg-Re~N_$data_location-$runcase
		rm  $analysis_data_location/Rg~N_$data_location-$runcase
		rm  $analysis_data_location/Re~N_$data_location-$runcase
	elif [ "$flag_case" == "superposition" ]; then
		paste -d "\t" $analysis_data_location/Rg~"$changing_para"_$data_location-$runcase $analysis_data_location/Re~"$changing_para"_$data_location-$runcase > $analysis_data_location/Rg-Re~"$changing_para"_$data_location-$runcase
		rm  $analysis_data_location/Rg~"$changing_para"_$data_location-$runcase
		rm  $analysis_data_location/Re~"$changing_para"_$data_location-$runcase
		
	fi
##combine Rg and Re data
#$data_name~N_$data_location-$runcase

}




#------------------------------------------------------------------------------------------------------------
###### Fit RgRe data~N ###### 

function fit_gnuplot_data_N(){

	#fit_type=$1; data_name=$2; Ns=$3;Ne=$4; filelocation=$5;filename=$6
	#$runfiles_location/fit_gnuplot_data_N.sh $fit_type $data_name $Ns $Ne $filelocation $filename
	$runfiles_location/fit_gnuplot_data_N.sh $@
	
}



#------------------------------------------------------------------------------------------------------------


######	other fuctions  ######

## move file or directory to new name
function move_runcase(){
	$runfiles_location/move_files.sh	$dN $nNs $nNe $data_location $dirname move	$1  $2 
	#$runfiles_location/move_files.sh	$dN $nNs $nNe $data_location $dirname 'runcase=longrun_tau-11M'  longrun_tau-11M
}
	
function remove_runcase(){
	$runfiles_location/move_files.sh	$dN $nNs $nNe $data_location $dirname remove	$1  

}
	
# check runtime 

function check_runtime(){
	### checkfile=screen file location
	### $dN $nNs $nNe $data_location $checkfile $outfile
	$runfiles_location/check_runtime.sh $dN $nNs $nNe $data_location/$dirname $runcase/out $data_location/runtime_$runcase.txt
}	


	
# check runtime 

function combine_file(){
	newfilename=test
	#cat test
	cat $@ >> $newfilename
}	
	
function rm_dumpfolder_content(){
	
	data_location=$1; runcase=$2
	$runfiles_location/rm_dumpfolder_content.sh $dN $nNs $nNe $data_location $dirname $runcase
}	




function Collect_data_from_runcase_to_folder(){

	if [ -d $runcase_location ];then
		# mkdir data collect forlder 
		mkdir -p $runcase_location/$data_collect_foldername 
		mkdir -p $organized_runcase_location
		mkdir -p $organized_runcase_location/$data_collect_foldername
		
		#remove existed data collected file
		rm $runcase_location/$data_collect_foldername/$data_name  >/dev/null 2>&1

		#collect data to $data_collect_foldername
		for folder in $(ls $runcase_location)
		do	
			#exclude $data_collect_foldername
			if [[ $folder != $data_collect_foldername ]]; then
				#if data exist in this folder then transfer data
				if [ -f $runcase_location/$folder/$data_name ]; then
					cat $runcase_location/$folder/$data_name >> $runcase_location/$data_collect_foldername/$data_name
					printf "\tadd $runcase_location/$folder/$data_name to $runcase_location/$data_collect_foldername/$data_name\n"
				fi

				### rm dump folder
				# 
				: '
				if [ -d $runcase_location/$folder/dump ]; then
					printf " $runcase_location/$folder/dump exsit\n"
					rm -r $runcase_location/$folder/dump
				fi 
				#'
				### zip all the dumpfiles
				#https://www.cnblogs.com/joshua317/p/6170839.html
				#
				: '
				if [ -f $runcase_location/$folder/*.lammpstrj ]; then
					for dumpfile in $(ls $runcase_location/$folder/*.lammpstrj)
					do
						printf " $runcase_location/$folder/$dumpfile exsit\n"
						#tar -zcvf
						#tar -jcvf $runcase_location/$folder/$dumpfile.tar.bz2 $runcase_location/$folder/$dumpfile
					#rm -r $runcase_location/$folder/dump
					done
				fi
				#'
							
			fi
		done
		cp $runcase_location/$data_collect_foldername/$data_name $organized_runcase_location/$data_collect_foldername/$data_name
		
	fi

}

function Collect_datas_from_runcases_to_folder_of_different_rc(){
	
	
	chain_type_data_location=data_"$chain_type"_finished
	mkdir -p $organized_data_location/$chain_type_data_location
	
	for rc in ${rc_array[@]}
	do
		
		data_location=$chain_type_data_location/"$chain_type"_pair_1-1-$rc
		mkdir -p $organized_data_location/$data_location
		
		for data_name in Rg.lammpsdump Re.lammpsdump
		do
			for (( counter=$nNs; counter<=$nNe; counter++ ))
			do
				N=$(( $dN * counter ))
				runcase_location=$data_location/$dirname$N
				organized_runcase_location=$organized_data_location/$data_location/$dirname$N
				Collect_data_from_runcase_to_folder	
			done
		done
	done
}


function Get_data_from_Collected_file(){

	runcase=$data_collect_foldername
	
	cd $organized_data_location/$chain_type_data_location
	
	for rc in ${rc_array[@]}
	do
		data_location="$chain_type"_pair_1-1-$rc
		
		skiping_loop=50
		running_loop=$skiping_loop;  Get_data-RgRe~N 	$dN $nNs $nNe 	1

	done
}



function Organize_data_from_different_chain_type_N(){

	func=$1
	shift 1
	organized_data_location=$current_location/$data_collect_foldername
	mkdir -p $organized_data_location
	echo "organized_data_location="$organized_data_location
	
	for chain_type in $@
	do
		chain_type_data_location=data_"$chain_type"_finished
		
		if [ "$func" == collect ]; then
			###Collect_datas_from_runcases_to_folder_of_different_rc to $data_collect_foldername
			Collect_datas_from_runcases_to_folder_of_different_rc 
			
		elif [ "$func" == get ]; then

			###Get_data-RgRe~N for different rc
			Get_data_from_Collected_file 
		fi
		cd $current_location
	done
}



function Multi_plot_organized_data_dif_Chaintype_N_rc(){
	tmp_filename=("")
	for chain_type in $@
	do
		for rc in ${rc_array[@]}
		do	
			datafile=Rg-Re~N_"$chain_type"_pair_1-1-$rc-$data_collect_foldername
			
			tmp_filename=(${tmp_filename[@]} $datafile)
		done
	done
	fit_gnuplot_data_N	multi_plot	Rg-N 	10 3000 $analysis_data_location ${tmp_filename[@]} 
	 

}


function batch_different_rc(){

: '
	chain_type=ring; cat_type=ring_num; cat_para=1
	dN=10; nNs=1; nNe=9; 
	run_type=equil; 	runcase=1_equil; 	running_loop=100;  restart_runcase="";

'
		chain_type_save=$chain_type; cat_type_save=$cat_type; cat_para_save=$cat_para;	
		dN_save=$dN; nNs_save=$nNs; nNe_save=$nNe; 
		run_type_save=$run_type; runcase_save=$runcase; running_loop_save=$running_loop; restart_runcase_save=$restart_runcase;

	for rc in $@
	do
		chain_type=$chain_type_save; cat_type=$cat_type_save; cat_para=$cat_para_save
		dN=$dN_save; nNs=$nNs_save; nNe=$nNe_save; 
		run_type=$run_type_save; runcase=$runcase_save; running_loop=$running_loop_save; restart_runcase=$restart_runcase_save;
		
		get_parameters_dN_nNs-nNe	$run_type $dN $nNs $nNe $running_loop $runcase $restart_runcase
		
		CASE_location="$chain_type"_pair_1-1-$rc
		data_location=$current_location/$CASE_location/$data_location
			
		#mkdir $CASE_location	
		cd $CASE_location		
		printf "\n$CASE_location\n"
		
		#Preparation_stoped_continue
		#move_runcase 2_coninue_tau-10M  2_continue_tau-10M
		
		#rm data_100-50-1000 -r
		#Preparation_equil
		#Preparation_continue
		#
		: '
		Preparation_continue
		remove_runcase 1_equil_tau-1M
		remove_runcase data.chain
		remove_runcase build_linear
		remove_runcase build_catenated
		#'
		
		#mkdir $current_location/tmp_folder
		#mkdir $current_location/tmp_folder/$CASE_location
		#cp $data_location $current_location/tmp_folder/$CASE_location/ -r
		
		Run_jobs_N $dN $nNs $nNe 2
		
		
		cd $current_location
		
	done
}



######	superposition  ######

function create_para_value.txt(){
	echo "excluded_volume	epsilon	rc	temperature" > para_values.txt
	for (( i=0; i<=$para_num-1; i++ )) 
	do
		#if [ $excluded_volume_values == ]
		echo "${excluded_volume_values[$i]}	${epsilon_values[$i]}	${rc_values[$i]}	${temperature_values[$i]}"  >>  para_values.txt

	done
}

function build_superposition_Chain(){	
	mkdir -p superposition  #>/dev/null 2>&1
	mkdir superposition/"$chain_type"Chain-N$N >/dev/null 2>&1
	$runfiles_location/build_chain_linear.sh $N $nNs $nNe $initial_file_location  superposition "$chain_type"Chain-N
}
	
	
	
function build_superposition_case(){
	
	replace_tmp=PARA
	
	epsilon_rc_T=( $epsilon $rc $temperature )
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
	
	mkdir superposition/"$chain_type"Chain-N$N/changing_$changing_para >/dev/null 2>&1
	data_location_SP=$current_location/superposition/"$chain_type"Chain-N$N/changing_$changing_para
	data_location=$data_location_SP
	
	get_parameters_dN_nNs-nNe	$run_type $dN $nNs $nNe $running_loop $runcase $restart_runcase
	
	for para in ${para_values[@]}
	do
		
		data_location=$data_location_SP
		case_name_para=${case_name_tmp/$replace_tmp/$para}
		
		
		mkdir $data_location/$case_name_para >/dev/null 2>&1
		mkdir $data_location/$case_name_para/$runcase >/dev/null 2>&1
		
		epsilon=${epsilon_rc_T[0]/"$replace_tmp"/"$para"}
		rc=${epsilon_rc_T[1]/"$replace_tmp"/"$para"}
		temperature=${epsilon_rc_T[2]/"$replace_tmp"/"$para"}
		$runfiles_location/create_input_implicit.sh $epsilon $rc $temperature $damp $tstep $step_per_dump $running_loop $dump_frequency $inputfile_location $inputfile_name ../../../data.chain
		cp $inputfile_location/$inputfile_name $data_location/$case_name_para/$runcase
		echo "cp to case:$data_location/$case_name_para/$runcase"; echo ""
		
	done
}
	
	function Run_jobs_superposition(){
	
	get_parameters_dN_nNs-nNe	$run_type $dN $nNs $nNe $running_loop $runcase $restart_runcase
	data_location_SP=$current_location/superposition/"$chain_type"Chain-N$N/changing_$changing_para
	data_location=$data_location_SP

## run_dN is not related to data_location
	run_dN=$1; run_nNs=1; run_nNe=1
## number_line is the max num of job runing at same time
	number_line=$2
		
	$runfiles_location/run_jobs_superposition.sh $LAMMPS_location $run_dN $run_nNs $run_nNe $inputfile_name $data_location $number_line $case_name $runcase $epsilon $rc $temperature $changing_para ${para_values[@]}

}


function Organize_data_superposition(){

	func=$1
	shift 1
	organized_data_location=$current_location/$data_collect_foldername
	mkdir -p $organized_data_location
	printf "\n\norganized_data_location="$organized_data_location"\n"
	
	#for chain_type in $chain_type
	for changing_para in ${changing_para_tmp[@]}
	do
		chain_type_data_location=superposition/"$chain_type"Chain-N$N
		mkdir -p $organized_data_location/superposition
		mkdir -p $organized_data_location/superposition/"$chain_type"Chain-N$N
		printf "chain_type_data_location="$chain_type_data_location"\n"
		
		#for changing_para in ${changing_para_tmp[@]}
		replace_tmp=PARA
		#case_name=pair_sigma"$sigma"-epsilon"$epsilon"-rc"$rc"-T"$temperature"
		if [ "$changing_para" == "epsilon" ]; then
			case_name_tmp=${case_name/epsilon$epsilon/epsilon$replace_tmp}
			para_values=${epsilon_values[@]}
			para_list_num=2
		
		elif [ "$changing_para" == "rc" ]; then
			case_name_tmp=${case_name/rc$rc/rc$replace_tmp}
			para_values=${rc_values[@]} 
			para_list_num=3
		
		elif [ "$changing_para" == "temperature" ]; then
			case_name_tmp=${case_name/T$temperature/T$replace_tmp}
			para_values=${temperature_values[@]} 
			para_list_num=4
			
		else 
			echo "Wrong changing_para!"
			return 0
		fi
	
		if [ "$func" == collect ]; then
			###Collect_datas_from_runcases_to_folder to $data_collect_foldername

			for para in ${para_values[@]}
			do
				data_location=$chain_type_data_location/changing_$changing_para
				mkdir -p $organized_data_location/$data_location
				case_name_para=${case_name_tmp/$replace_tmp/$para}
				runcase_location=$data_location/$case_name_para
				organized_runcase_location=$organized_data_location/$data_location/$case_name_para
				
				for data_name in Rg.lammpsdump Re.lammpsdump
				do
					Collect_data_from_runcase_to_folder	
				done
				
			done
			
			
		elif [ "$func" == get ]; then
			
			###Get_data-RgRe~N for different rc
			runcase=$data_collect_foldername
	
			cd $organized_data_location/$chain_type_data_location/changing_$changing_para
			analysis_filename=Rg-Re~"$changing_para"_Chain$N
			
			for para in ${para_values[@]}
			do
				case_name_para=${case_name_tmp/$replace_tmp/$para}
				data_location=$case_name_para
				
				skiping_loop=10
				running_loop=$skiping_loop;  Get_data-RgRe~N 	$dN $nNs $nNe 	1

			done
			
			flag_tmp=0
			rm $analysis_data_location/$analysis_filename
			for file in $(ls $analysis_data_location/"Rg-Re~"$changing_para*"")
			do
				if [ $flag_tmp -eq 0 ];then
					head -n 1 $file  > $analysis_data_location/$analysis_filename
					flag_tmp=1
				fi
				cat $file | sed -n '2p'  >> $analysis_data_location/$analysis_filename
				rm $file
			done
		
			awk '{print $'$para_list_num',$1}' $current_location/para_values.txt  | sort > $analysis_data_location/tmp_"$analysis_filename"_1
			sort $analysis_data_location/"$analysis_filename" > $analysis_data_location/tmp_"$analysis_filename"_2
			join $analysis_data_location/tmp_"$analysis_filename"_1 $analysis_data_location/tmp_"$analysis_filename"_2 > $analysis_data_location/EV_"$analysis_filename"
			rm $analysis_data_location/tmp_"$analysis_filename"_1; rm $analysis_data_location/tmp_"$analysis_filename"_2
			
			printf "changing_para=$changing_para, Rg-Re data at $analysis_data_location/$analysis_filename\n"
		fi
				
		cd $current_location
	done
}


########################	
	
#check_runtime
#move_runcase 2_coninue_tau-1M  2_continue_tau-1M-save


#============================================================================================================



	#============================================================================================================
##################### main control ###########################
#Mark

###simulation details: LJ potential; fene bond-fene_epsilon=$epsilon;

	#rc=1.1225	v=4.409446248273919	g=0.0514318202
	#rc=1.4872 	v=0.07063468820263308	g=200.43055781
	#rc=1.4913 	v=0.002383219973885686 g=176064.476549
	#rc=1.4957	v=-0.07067830921376927	g=200.183232
	#rc=2.5	v=-8.343741655587149	g=0.01436409611

##################################################################
	#epsilon=1.0
	#temperature=1.0
	#damp=1.0
	
###choose rc	
	#rc=1.1225; rc=1.4872; rc=1.4913; rc=1.4957; rc=2.5; 
	
###choose chain type = linear or catenated or ring		## type_cat = ring_size or ring_num
	
	#chain_type=linear
	#chain_type=catenated; 	cat_type=ring_num; cat_para=2
	#chain_type=ring; 		cat_type=ring_num; cat_para=1
	
###choose Chain N to run ##chain from nNs*dN to nNe*dN every dN
	#dN=10; nNs=1; nNe=9;
	
###choose runcase

	###run_type = equil or continue
	
	##equil
	#run_type=equil;
	
	#runcase=longrun;	running_loop=1100;	restart_runcase="";
	#runcase=1_equil;	running_loop=100;	restart_runcase="";
	
	##continue
	#run_type=continue;
	
	#runcase=2_continue;				running_loop=1000; restart_runcase=1_equil_tau-1M; 
	#runcase=longrun_tau-11M-continue; 		running_loop=1100; restart_runcase=longrun_tau-11M; 
	

	
##########	existed parameter case	############

	flag_case=normal
	#rc=1.1225; #rc=1.4872; #rc=1.4913; #rc=1.4957; #rc=2.5; 
	#rc_array=( 1.1225 1.4872 1.4913 1.4957 2.5 )
	rc_array=( 1.4872 1.4957 )
	
	#chain_type=linear
	chain_type=catenated; 		cat_type=ring_num; cat_para=2
	#chain_type=ring; 		cat_type=ring_num; cat_para=1

	dN=10; nNs=1; nNe=9; 
	#dN=50; nNs=2; nNe=20;
	#dN=1000; nNs=2; nNe=3;
	#dN=1000; nNs=3; nNe=3;
	#dN=1500; nNs=1; nNe=1;
	#dN=200; nNs=6; nNe=9;
	
	#run_type=equil; runcase=1_equil; running_loop=100; restart_runcase=".";
	#run_type=equil; runcase=longrun; running_loop=1100; restart_runcase=".";
	run_type=continue; runcase=2_continue; running_loop=1000; restart_runcase=1_equil_tau-1M; 	
	#run_type=continue; runcase=longrun_tau-11M-continue; running_loop=1100; restart_runcase=longrun_tau-11M; 
	
	##need modified to apply purpose
	#batch_different_rc ${rc_array[@]}


##########	get parameter from above input	############

	#get_parameters_dN_nNs-nNe	$run_type $dN $nNs $nNe $running_loop $runcase $restart_runcase	
	
##########	Preparation	############

	#Preparation_equil
	#Preparation_continue
	###Preparation_stoped_continue need original restart para
	#Preparation_stoped_continue


##########	NERSC		############
	#Create_nersc_input 	equil		$chain_type$rc-C	$dN $nNs $nNe 	$time_hour
	#Create_nersc_input 	continue	$chain_type$rc-C	$dN $nNs $nNe 	$time_hour
	
	
##########	Aedin		############

	#Create_aedin_input	equil		$chain_type$rc-C
	#Create_aedin_input 	continue 	$chain_type$rc-C
	

##########	Run Jobs 	############

#-----	run_dN=$1; run_nNs=$2; run_nNe=$3 number_line=$4	
	#Run_jobs_N $dN $nNs $nNe 4


###########	Calculations	############

#----------	Collect RgRe~N -------------
#	dN=$1; nNs=$2; nNe=$3; skip_para=$4 (1/10)
	#Get_data-RgRe~N 	$dN $nNs $nNe 	10
	#Get_data-RgRe~N 	$dN $nNs $nNe 	20
	#combine_file $analysis_data_location/Rg-Re~N_data_10-10-90-longrun_tau-11M  $analysis_data_location/Rg-Re~N_data_10-10-90-longrun_tau-11M
	
#----------	Fit data RgRe~N -------------
	#fit_type=$1; data_name=$2; Ns=$3;Ne=$4;filename=$5	
	#fit_gnuplot_data_N	quick_fit	Rg-N 	0 1000 $analysis_data_location	Rg-Re~N_$data_location-$runcase
	#fit_gnuplot_data_N	quick_plot	Rg-N 	100 2000 $analysis_data_location	Rg-Re~N_$data_location-$runcase
	#fit_gnuplot_data_N	quick_plot	Rg-N	10 1000 $analysis_data_location	Rg-Re~N_data_10-10-90-longrun_tau-11M
	#fit_gnuplot_data_N	multi_plot	Rg-N	10 1000 $analysis_data_location	0

##########	Others 	############

	#check_runtime
	#move_runcase 2_coninue_tau-10M  2_continue_tau-10M
	#remove_runcase longrun_tau-11M-continue_tau-0M
	#remove_runcase longrun_tau-11M-continue_tau-11M/cori_KNL.sh
	#combine_file $analysis_data_location/Rg-Re~N_data_10-10-90-longrun_tau-11M  $analysis_data_location/Rg-Re~N_data_10-10-90-longrun_tau-11M
	#rm_dumpfolder_content $data_location $runcase
	#Collect_data_from_runcase_to_folder	$data_location 	$dN $nNs $nNe	Rg.lammpsdump

##########	orgnaze 	############
#
	
	data_collect_foldername=data_collect;	dN=10; nNs=1; nNe=300;
	###chain_type=linear or catenated or ring
	#chain_type_tmp=(linear catenated ring)
	#chain_type_tmp=(linear catenated)
	
	
	##collect or get 
	chain_type_tmp=( linear catenated ring ); rc_array=( 1.1225 1.4872 1.4913 1.4957 2.5 );
	#chain_type_tmp=( linear); rc_array=( 1.1225  );
	#Organize_data_from_different_chain_type_N 	collect 	${chain_type_tmp[@]}  
	#Organize_data_from_different_chain_type_N 	get 		${chain_type_tmp[@]} 
	
	
	#>/dev/null #>/dev/null 2>&1
	
	#chain_type_tmp=(linear catenated ring); 
	#Multi_plot_organized_data_dif_Chaintype_N_rc ${chain_type_tmp[@]} 
	
	
	#https://blog.csdn.net/u012836354/article/details/78908436
	#fit_gnuplot_data_N	quick_fit	Rg-N 	500 2000 $analysis_data_location	Rg-Re~N_ring_pair_1-1-1.4957-data_collect
	
	
	
	
	
##########  	excluded volume superposition	############

	
: '

Steinhauser_JCP_2005
Excluded Volume	eps=T=1
Lambda	v	Rc
0	4.409446311	1.1225
0.2	3.240122591	1.28846
0.4	1.862156413	1.38027
0.6	0.234704405	1.47738
0.7	-0.687572248	1.53343
0.8	-1.691396582	1.59811
0.9	-2.784497873	1.67574
1	-3.975361247	1.7736


'
#-----------------Choose parameters---------------------
	analysis_data_location=$current_location/analysis_data_superposition
	data_collect_foldername=data_collect_superposition
	flag_case=superposition
	
	LAMMPS_location=~/bin/lmp_3Mar20
	
	##runcase and N
	chain_type=linear; run_type=equil; runcase=1_equil; running_loop=100; restart_runcase=".";
	dN=16; nNs=1; nNe=1; N=$dN

	
	##default parameters and case name
	sigma=1.0; epsilon=1.0; rc=2.5; temperature=1.0; damp=1.0
	case_name=pair_sigma"$sigma"-epsilon"$epsilon"-rc"$rc"-T"$temperature"
	
	
### changing_para=rc or epsilon or temperature
	para_num=8
	rc_values=(1.1225 1.28846 1.38027 1.47738 1.53343 1.59811 1.67574 1.7736)
	epsilon_values=( na 0.145 0.3329 0.3564 0.4225 0.51288 0.60484 0.6987)
	temperature_values=( na 6.9 3.004 2.8058 2.367 1.95 1.653 1.431)
	excluded_volume_values=( 4.409446311 3.240122591 1.862156413 0.234704405 -0.687572248 -1.691396582 -2.784497873 -3.975361247 )
	#excluded_volume_values=( 0 0.2 0.4 0.6 0.7 0.8 0.9 1 )
	create_para_value.txt
	
	changing_para=rc; para_values=(${rc_values[@]})
	#changing_para=epsilon; para_values=(${epsilon_values[@]} )
	#changing_para=temperature; para_values=(${temperature_values[@]} )

#--------------------------------------------------------------------------------
	## run only once for each N
		#build_superposition_Chain
		
	## build runfolder for different para
		#build_superposition_case
		
	## Run_jobs_superposition 
		#Run_jobs_superposition $N  6 	
	
	## organize data Rg Re
		changing_para_tmp=( rc epsilon temperature )
		#Organize_data_superposition	collect 
		Organize_data_superposition	get 	
	
		#fit_gnuplot_data_N	multi_plot	superposition 	0 10 $analysis_data_location	EV_Rg-Re~epsilon_Chain16 EV_Rg-Re~rc_Chain16 EV_Rg-Re~temperature_Chain16 
		#fit_gnuplot_data_N	multi_plot	superposition 	0 10 $analysis_data_location	EV_Rg-Re~epsilon_Chain16

		
		
		
		
<< 'MULTILINE-COMMENT'	
MULTILINE-COMMENT
		#tmp_location=superposition/linearChain-N16/changing_epsilon/test/1_run_same-ts-tau
		#tmp_location=superposition/linearChain-N16/changing_epsilon/test/1_run
		#tmp_location=superposition/linearChain-N16/changing_epsilon/test/1_run_0.01ts_10Mtau
		#tmp_location=superposition/linearChain-N16/changing_epsilon/test/1_run_0.001ts_1Mtau
		
		case_tmp=1_run_0.001ts_0.1Mtau
		case_tmp=1_run_0.001ts_1Mtau
		tmp_location=superposition/linearChain-N16/changing_epsilon/test/$case_tmp
		
		changing_para=epsilon; para_values=(${epsilon_values[@]} )
		
		rm tmp
		
		for (( i=0; i<=$(($para_num-1)); i++ )) 
		do
		rm fit.log
		
		gnuplot -e "a=10**8;f(x)=b; fit [(0.1*a):] f(x) '$tmp_location/Rg_"$changing_para"_${para_values[$i]}.lammpsdump' u 1:2 via b;" 
		grep -E 'data read|b               =' fit.log | sed 's/b               =//g' | sed 's/+\/-//g' | sed 's/(//g'| sed 's/)//g' |sed "s/FIT:    data read from '//g"  |sed "s/".lam".*/\t/g"  |sed 's/.*\///g' | tr '\n' ' ' | sed 's/% /%\n/g' |sed "s/.*Rg_"$changing_para"_/"${excluded_volume_values[$i]}"\t/g" | awk '{printf "%-15s%-15s%-15s%-15s%-15s\n",$1,$2,$3,$4,$5}' >> tmp
		
		done
		awk 'BEGIN{printf "%-15s%-15s%-15s%-15s%-15s\n" ,"ExcludedVolume","'$changing_para'","Rg","Error","Error%"} {printf "%-15s%-15s%-15s%-15s%-15s\n",$1,$2,$3,$4,$5}' tmp > $analysis_data_location/test_Rg-Re~epsilon_Chain16_$case_tmp
		rm tmp

		gnuplot -p  <<- EOF
		
p '$analysis_data_location/EV_Rg-Re~epsilon_Chain16' u 2:(\$3**2) pointsize 5,\
'$analysis_data_location/test_Rg-Re~epsilon_Chain16_1_run_0.001ts_0.1Mtau' u 1:(\$3**2) pointsize 5,\
'$analysis_data_location/test_Rg-Re~epsilon_Chain16_1_run_0.001ts_1Mtau' u 1:(\$3**2) pointsize 5,\

#'$analysis_data_location/test_Rg-Re~epsilon_Chain16_$case_tmp' u 1:(\$3**2) pointsize 5

#a=10**8;f(x)=b; fit [(0.05*a):] f(x) 'Rg.lammpsdump' u 1:2 via b; c=b**2; print c
		
		EOF




##########  	############	
<< 'MULTILINE-COMMENT'	
	
'$analysis_data_location/test_Rg-Re~epsilon_Chain16_1_run' u 1:(\$3**2) pointsize 5,\
'$analysis_data_location/test_Rg-Re~epsilon_Chain16_1_run_same-ts-tau' u 1:(\$3**2) pointsize 5,\
'$analysis_data_location/test_Rg-Re~epsilon_Chain16_1_run_0.01ts_10Mtau' u 1:(\$3**2) pointsize 5,\
'$analysis_data_location/test_Rg-Re~epsilon_Chain16_1_run_0.001ts_1Mtau' u 1:(\$3**2) pointsize 5,\
MULTILINE-COMMENT
	
	
	
	

	
	
###input parameters end
