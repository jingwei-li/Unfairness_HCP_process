#!/bin/sh

DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

proj_dir="/home/jingweil/storage/MyProject/fairAI/HCP_race"
outmat="$proj_dir/RSFC_subsample/RSFC_948_truncate.mat"
fMRI_ls="$proj_dir/RSFC_subsample/fMRI_list.txt"
fake_censor_ls="$proj_dir/RSFC_subsample/discard_list.txt"
ROI_file="$(dirname $DIR)/FC_no_censor/Schaefer2016_400Parcels_17Networks_colors_19_09_16_subcortical.dlabel.nii"

main() {
    work_dir=$proj_dir/RSFC_subsample/logs/
    mkdir -p $work_dir
    LF=$work_dir/FC_truncate.log
    cmd="matlab -nodesktop -nojvm -nodisplay -r \" addpath $DIR; HCP_FC_truncate('$outmat', '$fMRI_ls', '$fake_censor_ls', '$ROI_file'); exit; \" > $LF 2>&1"

    jname=HCP_FC_truncate
    $CBIG_CODE_DIR/setup/CBIG_pbsubmit -cmd "$cmd" -walltime 40:00:00 -mem 6G \
        -name $jname -joberr $work_dir/$jname.err -jobout $work_dir/$jname.out
}

#############################
# Function usage
#############################
usage() { echo "
NAME:
" 1>&2; exit 1; }

##########################################
# Parse Arguments 
##########################################
# Display help message if no argument is supplied

while [[ $# -gt 0 ]]; do
	flag=$1; shift;
	
	case $flag in
        -h)  usage; 1>&2; exit 1;;
        -outmat) outmat=$1; shift;;
        -fMRI_ls) fMRI_ls=$1; shift;;
        -fake_censor_ls) fake_censor_ls=$; shift;;
        -ROI_file) ROI_file=$1; shift;;
        *)
            echo "Unknown flag: $flag"
            usage; 1>&2; exit 1
			;;
    esac
done


main
