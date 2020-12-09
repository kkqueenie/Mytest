#!/bin/bash


inputfile_location=$1
inputfile_name=$2
inputfile_name_continue=$3
runcase=$4
running_loop=$5
restart_filename=$6

current_location=$(pwd)
inputfile=$inputfile_location/$inputfile_name
inputfile_cotinue=$inputfile_location/$inputfile_name_continue
restartfile=../$runcase/restart/$restart_filename
restartfile=../$runcase/$restart_filename

sed -n '1,$p' $inputfile |sed '/read_data/aread_restart '$restartfile'' |sed 's/read_data/#&/' |sed 's/reset_timestep/#&/'|sed 's/minimize/#&/' |sed 's/variable        b/#&/' |sed '/b loop/avariable        b loop '$running_loop'' |sed 's/'$inputfile_name'/'$inputfile_name_continue'/' > $inputfile_cotinue

#more $inputfile_cotinue

printf "\tmodified $inputfile to $inputfile_cotinue\t\n"


