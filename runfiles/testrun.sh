#!/bin/bash


Lammps_location=$1
testrun_location=$2
inputfile_location=$3
inputfile_name=$4
current_location=$(pwd)

if [ ! -d "$testrun_location" ]; then
    mkdir $testrun_location
    printf "\t $testrun_location created\n"
fi


cp $inputfile_location/$inputfile_name $testrun_location
cd $testrun_location

##prepare testrun
if [ ! -d "dump" ]; then
    mkdir dump
fi

if [ ! -d "restart" ]; then
    mkdir restart
fi

##start testrun in a new tab
gnome-terminal --tab -t “testrun: $testrun_location” -- bash -c "pwd;$Lammps_location  <  $inputfile_name > out; exec bash"


cd $current_location

printf "\ttestrun started at $testrun_location\n"
















