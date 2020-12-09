#!/bin/bash


epsilon=$1
rc=$2
fene_epsilon=$epsilon
temperature=$3
damp=$4
tstep=$5
step_per_dump=$6
b_loop=$7
dump_frequency=$8
address=$9
shift 9
inputfile_name=$1
read_data_location=$2
if [ "$read_data_location" == "" ]; then
    read_data_location=../data.chain
fi	



current_location=$(pwd)
thermo_frequency=10000

if [ ! -d "$address" ]; then
    printf "\x1b[31m \tcreate imput implicit --- NO address: $address \x1b[0m\n"
    exit
fi

if [  -f "$address/$inputfile_name" ]; then
    rm $address/$inputfile_name
fi	

 
echo "
###############################################
# LAMMPS script for a single chain in an implicit solvent
# LAMMPS version 3 Mar 2020 & 29 Oct 2020
# Oct 2020 Kun
###############################################





# Box and units  (use LJ units and periodic boundaries)

units 		lj 		# use lennard-jones (i.e. dimensionless) units
atom_style	bond 
boundary 	p p p		# all boundaries are periodic



# Pair interactions require lists of neighbours to be calculated

neighbor 	1.9 bin
neigh_modify 	every 1 delay 1 check yes 


#processors	2 2 2


# READ initial configuration data file 
read_data $read_data_location


# Define groups 
group chain type 1  #(atom type 1 is group 'chain')




# Set up interaction potentials
pair_style  lj/cut 2.5
pair_modify shift yes

pair_coeff      1 1 $epsilon 1.0 $rc
#  pair_coeff for LJ, specify 4:
#    * atom type interacting with
#    * atom type
#    * energy
#    * mean diameter of the two atom types
#    * cutoff



bond_style  fene
special_bonds fene #<=== I M P O R T A N T prevents LJ from being counted twice
bond_coeff 1 30.0 1.5 $fene_epsilon 1.0
# For style FENE, specify:
#   * bond type
#   * K (energy/distance^2) 
#   * R0 (distance)
#   * epsilon
#   * sigma


#angle_style  none


### Set up fixes

variable seed equal 54654651     # a seed for the thermostat

fix 1 all nve                             # NVE integrator
fix 2 all langevin   $temperature $temperature $damp \${seed}  # langevin thermostat



#velocity    	all create 1.0 1234567

#minimize initial energy
minimize 1.0e-8 1.0e-10 100000 1000000


#### relax long chain
variable chain_length equal atoms
variable box_volume equal vol
variable box_density equal 0.001
variable aim_box_volume equal atoms/\${box_density}
variable aim_box_length equal \${aim_box_volume}^(1/3)
variable tmp_length equal 0.5*\${aim_box_length} 
variable volume_dif equal \${box_volume}-\${aim_box_volume}


if \"\${volume_dif} < 1000\" then \"jump SELF break_relax\"

##variable denpend on how u build box
variable displace equal 200

if \"\${chain_length}>2000\" then \"variable relax_time equal 10000000\" &
else \"variable relax_time equal 100000\"


fix relax all deform 1 x delta \${displace} -\${displace} y delta \${displace} -\${displace} z delta \${displace} -\${displace} remap x
run \${relax_time}
unfix relax

label break_relax

fix relaxend all deform 1  x final -\${tmp_length} \${tmp_length}  y final -\${tmp_length} \${tmp_length} z final -\${tmp_length} \${tmp_length} remap x 
run 1
unfix relaxend





## Reset timestep 
reset_timestep 0 


##### Output thermodynamic info to screen  #################################
thermo $thermo_frequency
#thermo_style   custom   step  temp  epair  emol  press  vol
thermo_style    multi
#thermo_modify   flush yes
############################################################################



##### Output thermodynamic info to file  ###################################
variable ts equal step
#variable mytemp equal temp
#variable myepair equal epair
#variable myetotal equal etotal
variable mycpu equal cpu


#fix mythermofile all print $thermo_frequency \"\${ts} \${mytemp} \${myetotal} \${myepair} \${mycpu}\" file thermo_output.lammpsdump screen no
fix mythermofile all print $thermo_frequency \"\${ts}  \${mycpu}\" file thermo_output.lammpsdump screen no
############################################################################


##compute rg for chain 
compute rg chain gyration
fix rg chain ave/time $dump_frequency  1 $dump_frequency c_rg c_rg[1] c_rg[2] c_rg[3]  c_rg[4]  c_rg[5]  c_rg[6] file Rg.lammpsdump


##compute end to end distance for chain 
variable atom_end1 equal 1
variable atom_end2 equal atoms
variable Re equal  sqrt((x[\${atom_end1}]-x[\${atom_end2}])^2+(y[\${atom_end1}]-y[\${atom_end2}])^2+(z[\${atom_end1}]-z[\${atom_end2}])^2)
fix Re chain ave/time 10000  1 10000 v_Re file Re.lammpsdump


# set timestep of integrator
timestep 	$tstep 


#output for dump file
dump		2 all custom $dump_frequency dump_Chain_all_time.lammpstrj id type x y z ix iy iz


variable        a equal $step_per_dump
variable        b loop $b_loop
variable        c equal step

label           loop

variable        t equal \$c


#Generate RESTART file to store state of simulation at regular intervals
restart		10000000 restart


#Dump configurations at regular intervals 
#dump		1 all custom $dump_frequency ./dump/dump_output.\$t.lammpstrj id type x y z ix iy iz



# Run the simulation for some time steps 
run             \$a

#undump          1
next            b

jump            $inputfile_name loop




#### write a final restart file
write_restart final.restart



" > $address/$inputfile_name
sleep 1s


printf "\tcreated epsilon=$epsilon rc=$rc temperature=$temperature input at $address/$inputfile_name\n"





: '  


############################################################################


#fix    1 all npt temp 1.0 1.0 100 iso 1.0 1.0 5
#fix	2 all wall/harmonic zlo EDGE 1.0e4 0.0 2.0  zhi EDGE 1.0e4 0.0 2.0 pbc yes
#fix     3 all ave/time 4 250 1000 c_thermo_press[1] c_thermo_press[2] c_thermo_press[3] file pave.dat ave running



'
: '
#### relax long chain
variable atom_chain equal atoms
variable box_volume equal vol
variable box_density equal 0.001
variable aim_box_volume equal atoms/\${box_density}
variable aim_box_length equal \${aim_box_volume}^(1/3)
variable tmp_length equal 0.5*$\{aim_box_length} 


print "box_volume =  \${box_volume}, aim_box_volume = \${aim_box_volume}, aim_box_length = \${aim_box_length}" screen yes universe yes 

if \"(\${box_volume} == \${aim_box_volume})\" then \"jump SELF break_relax\"

if \"(\${atom_chain}<500)\" then &
	\"dump 1 all custom 10000 dump_balance_box.lammpstrj id type x y z ix iy iz\"   \"run 0\"  &
elif \"(\${atom_chain}<=1000)\"  &
	\"dump 1 all custom 10000 dump_balance_box.lammpstrj id type x y z ix iy iz\"   \"run 1000000\" &
elif \"(\${atom_chain}>1000)\"  &
	\"dump 1 all custom 10000 dump_balance_box.lammpstrj id type x y z ix iy iz\"   \"run 2000000\" 
undump 1
 
label break_relax
 
change_box all x final -\${tmp_length} \${tmp_length}  y final -\${tmp_length} \${tmp_length} z final -\${tmp_length} \${tmp_length}

#### relax long ring chains
variable box_volume equal vol
variable box_density equal 0.001
variable aim_box_volume equal atoms/${box_density}
variable aim_box_length equal ${aim_box_volume}^(1/3)
variable tmp_length equal 0.5*${aim_box_length} 


if "${box_volume} == ${aim_box_volume}" then "jump SELF break"


print """box_volume =  ${box_volume}, aim_box_volume = ${aim_box_volume}, aim_box_length = ${aim_box_length}""" screen yes universe yes file test
print "test if box need relaxation" screen yes universe yes append test

########
compute 	rg_relax chain gyration
fix 		rg_relax chain ave/time 1000  1 1000 c_rg_relax
variable 	rg_check equal c_rg_relax
run 10000

if "${rg_check} < ${aim_box_length}" then "print '
#box need relaxation
: ' screen yes universe yes append test" "jump SELF break" 
dump 1 all custom 10000 dump_balance_box.lammpstrj id type x y z ix iy iz
 
label loop_relax

variable n_balance loop 100
print "n_balance = ${n_balance}, run 1000000" screen yes universe yes append test
run 1000000
if "${c_rg_relax} < ${aim_box_length} " then "jump SELF break"
next n_balance
jump SELF loop_relax
 
label break
undump 1

unfix 		rg_relax
uncompute 	rg_relax
 
change_box all x final -${tmp_length} ${tmp_length}  y final -${tmp_length} ${tmp_length} z final -${tmp_length} ${tmp_length}



#' 


