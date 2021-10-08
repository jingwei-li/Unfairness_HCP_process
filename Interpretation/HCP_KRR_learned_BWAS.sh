#!/bin/sh

DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

proj_dir="$HOME/storage/MyProject/fairAI/HCP_race"
full_FC="$proj_dir/mat/RSFC_948.mat"

max_seed=400


main() {
    mkdir -p $fig_dir
    outmat="$mat_dir/learned_BWAS.mat"

    log_dir="$mat_dir/logs"
    mkdir -p $log_dir
    jname="HCP_learned_BWAS"
    cmd="matlab -nodesktop -nodisplay -r \" addpath('$DIR'); HCP_KRR_learned_BWAS(\
        '$model_dir', $max_seed, '$outmat', '$fig_dir', '$full_FC', '$bhvr_ls', \
        '$colloq_ls'); exit; \" "

    echo $cmd
    $CBIG_CODE_DIR/setup/CBIG_pbsubmit -cmd "$cmd" -walltime 10:00:00 -mem 30G \
        -name $jname -joberr $log_dir/$jname.err -jobout $log_dir/$jname.out
}

#############################
# Function usage
#############################
usage() { echo "
NAME: 
    HCP_KRR_learned_BWAS.sh

DESCRIPTIOM:
    For kernel ridge regression algorithm, calculate the model-learned brain-behavioral 
    association (by Haufe transformation).

REQUIRED ARGUMENTS:
    -model_dir <model_dir> : Top level directory which contains the original KRR outputs.
    -mat_dir   <mat_dir>   : The directory to store the calculated brain-behavioral 
                             association matrices.
    -fig_dir   <fig_dir>   : The directory to store the output figures.
    -bhvr_ls   <bhvr_ls>   : Full path of the behavioral measures list.
    -colloq_ls <colloq_ls> : Full path of the colloquial names of behavioral measures list.
    
OPTIONAL ARGUMENTS:
    -full_FC   <full_FC>   : Full path of the RSFC matrix across all subjects.
    -max_seed  <max_seed>  : Maximal random seed used for spliting HCP subjects.

" 1>&2; exit 1; }

##########################################
# Parse Arguments 
##########################################
# Display help message if no argument is supplied
if [ $# -eq 0 ]; then
	usage; 1>&2; exit 1
fi

while [[ $# -gt 0 ]]; do
	flag=$1; shift;
	
	case $flag in
        -model_dir) model_dir=$1; shift;;
        -mat_dir) mat_dir=$1; shift;;
        -fig_dir) fig_dir=$1; shift;;
        -bhvr_ls) bhvr_ls=$1; shift;;
        -colloq_ls) colloq_ls=$1; shift;;
        -full_FC) full_FC=$1; shift;;
        -max_seed) max_seed=$1; shift;;
        *)
            echo "Unknown flag: $flag"
            usage; 1>&2; exit 1
			;;
    esac
done

##########################################
# ERROR message
##########################################	
arg1err() {
	echo "ERROR: flag $1 requires one argument"
	exit 1
}

###############################
# check parameters
###############################
if [ -z "$model_dir" ]; then
	arg1err "-model_dir"
fi
if [ -z "$mat_dir" ]; then
	arg1err "-mat_dir"
fi
if [ -z "$fig_dir" ]; then
	arg1err "-fig_dir"
fi
if [ -z "$bhvr_ls" ]; then
    arg1err "-bhvr_ls"
fi
if [ -z "$colloq_ls" ]; then
    arg1err "-colloq_ls"
fi

main
