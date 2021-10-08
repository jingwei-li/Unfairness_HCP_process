#!/bin/sh

DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

max_seed=400

main() {
    log_dir="$model_dir/logs"
    jname="training_prediction"
    mkdir -p $log_dir

    cmd="matlab -nodesktop -nojvm -nodisplay -r \" addpath('$DIR'); \
        HCP_KRR_training_prediction('$model_dir', $max_seed, '$bhvr_ls', $LITE); exit; \" "

    $CBIG_CODE_DIR/setup/CBIG_pbsubmit -cmd "$cmd" -walltime 02:00:00 -mem 10G \
        -name $jname -joberr $log_dir/$jname.err -jobout $log_dir/$jname.out
}

#############################
# Function usage
#############################
usage() { echo "
NAME:
    HCP_KRR_training_prediction.sh

DESCRIPTION:
    For kernel ridge regression algorithm, calculate the predicted behavioral scores of training subjects.

REQUIRED ARGUMENTS:
    -model_dir <model_dir> : Top level directory of original KRR outputs.
    -bhvr_ls   <bhvr_ls>   : Full path of behavioral measures list.
    -LITE      <LITE>      : true or false. Whether the original KRR models were trained using the LITE 
                             version of CBIG KRR package. (This option affects the folder structures of 
                             functional similarity matrices).
OPTIONAL ARGUMENTS:
    -max_seed  <max_seed>  : Maximal random seed used to split HCP subjects. Default: 400.

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
        -bhvr_ls) bhvr_ls=$1; shift;;
        -LITE) LITE=$1; shift;;
        *)
            echo "Unknown flag: $flag"
            usage; 1>&2; exit 1;;
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
if [ -z "$bhvr_ls" ]; then
    arg1err "-bhvr_ls"
fi
if [ -z "$LITE" ]; then
    arg1err "-LITE"
fi

main
