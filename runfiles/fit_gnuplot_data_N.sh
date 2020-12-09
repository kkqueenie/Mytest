#!/bin/bash

#quick_fit quick_plot
fit_type=$1
data_name=$2
Ns=$3
Ne=$4
filelocation=$5
filename=$6
filename_start_in=6

#num_file=$(($#-$filename_start_in+1))
shift 5

#echo "input number= $#"
echo "plot file number = $#"

if [ $data_name == 'Rg-N' ];then
	### Fit Rg
	if [ $fit_type == 'quick_fit' ];then
		printf "quick_fit:\n"
		gnuplot -e "f(x)= a*x**B;fit [$Ns:$Ne] f(x) '$filelocation/$filename' u 1:2 via a,B;" 
		
	elif [ $fit_type == 'quick_plot' ];then
		printf "quick_plot\n"
		gnuplot -p  <<- EOF
			set autoscale
			set logscale x 
			set logscale y
			set xlabel "N" font "Verdana,15"
			set ylabel "Rg/{/Symbol s}" font "Verdana,15";
			set key font "Verdana,15"
			set key at 900,2

			set xrange [$Ns:$Ne]
			#set yrange [01:50]
			set title "Rg~N"  font "Verdana,15"
			
			p '$filelocation/$filename' u 1:2:3 lw 1.7 lc rgb "#2B60DE" title "Rg_{xyz}" with yerrorlines;

		EOF
		
		#gnuplot example: https://blog.csdn.net/cusi77914/article/details/107113825
	elif [ $fit_type == 'multi_plot' ];then
		printf "multi_plot\n"
		config_filename=data_gnuplot.conf
		echo "	
			set autoscale
			set logscale x 
			set logscale y
			set xlabel \"N\" font \"Verdana,15\"
			set ylabel \"Rg/{/Symbol s}\" font \"Verdana,15\";
			set key font \"Verdana,5\"
			set key at 50,80

			set xrange [$Ns:$Ne]
			#set yrange [01:50]
			set title \"Rg-N\"  font \"Verdana,15\"
			
			 " > $filelocation/$config_filename
		
		printf "p " >> $filelocation/$config_filename
		
		

		for file in $@
		do
			
			#| sed 's/_//g'  sed 's/_//g'   || tr '_' ' '| sed 's/.*pair//' | sed 's/-.*//2g'
			file_tmp=`echo $file | sed 's/_/ /g'  | sed 's/.*N//'| sed 's/-data.*//' `
			
			printf " '$filelocation/$file' u 1:2:3 lw 1.7  title \"Rg-$file_tmp\" with yerrorlines," >> $filelocation/$config_filename
		done
		
		echo " " >> $filelocation/$config_filename
		
		cat $filelocation/$config_filename | gnuplot -p
		echo "cat $filelocation/$config_filename | gnuplot -p"

		
	fi





elif [ $data_name == 'superposition' ];then

	if [ $fit_type == 'quick_fit' ];then
		printf "quick_fit:\n"
		gnuplot -e "f(x)= a*x**B;fit [$Ns:$Ne] f(x) '$filelocation/$filename' u 1:2 via a,B;" 
		
	elif [ $fit_type == 'quick_plot' ];then
		printf "quick_plot\n"
		gnuplot -p  <<- EOF


		EOF
		
		#gnuplot example: https://blog.csdn.net/cusi77914/article/details/107113825
	elif [ $fit_type == 'multi_plot' ];then
		printf "multi_plot\n"
		config_filename=data_gnuplot.conf
		echo "	
			set autoscale

			set xlabel \"excluded volume\" font \"Verdana,15\"
			set ylabel \"Rg/{/Symbol s}\" font \"Verdana,15\";
			set key font \"Verdana,5\"
			#set key at 50,80

			#set xrange [$Ns:$Ne]
			#set xrange [-17:]
			#set yrange [01:50]
			set title \"Rg-para\"  font \"Verdana,15\"
			
			 " > $filelocation/$config_filename
		
		printf "p " >> $filelocation/$config_filename
		
		for file in $@
		do
			
			#| sed 's/_//g'  sed 's/_//g'   || tr '_' ' '| sed 's/.*pair//' | sed 's/-.*//2g'
			file_tmp=`echo $file | sed 's/_/ /g'  | sed 's/.*N//'| sed 's/-data.*//' `
			
			printf " '$filelocation/$file' u 2:(\$3**2):4 lw 1.7  title \"Rg-$file_tmp\" with yerrorlines," >> $filelocation/$config_filename
			#printf " '$filelocation/$file' u 1:(\$3**2):4 lw 1.7  title \"Rg-$file_tmp\" with yerrorlines," >> $filelocation/$config_filename
		done
		
		echo " " >> $filelocation/$config_filename
		
		cat $filelocation/$config_filename | gnuplot -p
		echo "cat $filelocation/$config_filename | gnuplot -p"

		
	fi










fi













: '
for FILE in *; do
    gnuplot <<- EOF
        set xlabel "Label"
        set ylabel "Label2"
        set title "Graph title"   
        set term png
        set output "${FILE}.png"
        plot "${FILE}" using 1:2:3:4 with errorbars
EOF
done
'
