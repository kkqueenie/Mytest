#!/bin/bash

file=$1
##create README-logfile

echo `date` > $file
sed -n '/input parameters start/,/input parameters end/p' run.sh >> $file

echo -e '\n\n################################################################\n\n' >> $file
printf "\tREADME.log file createed at $file\n"
#more $file
