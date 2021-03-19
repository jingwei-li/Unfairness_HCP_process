#!/bin/sh

DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

########################################
# The following paths are only for the author's own replication purpose.
# External users please pass in your own data. Then it will overwrite these default settings.
########################################
proj_dir='/home/jingweil/storage/MyProject/fairAI/HCP_race'
subj_ls="$proj_dir/scripts/lists/subjects_wIncome_948.txt"
FD_txt="$proj_dir/scripts/lists/FD_948.txt"
DV_txt="$proj_dir/scripts/lists/DV_948.txt"
bhvr_ls_rstr='NONE'
bhvr_ls_unrstr="$proj_dir/scripts/lists/Cognitive_Personality_Task_Social_Emotion_58.txt"
AA_fold_stem="$proj_dir/mat/split_AA_948_rm_outliers18/split_seed"
outstem='split_seed'
restricted_csv=        # use matlab function's default
unrestricted_csv=      # use matlab function's default
FS_csv=                # use matlab function's default

########################################
# main commands to be submitted to jobs
########################################
main(){
    work_dir=$outdir/logs
    mkdir $work_dir
    jname='match_WA_AA'

    for seed in $(seq 1 1 $max_seed); do
        cmd="matlab -nodesktop -nosplash -nodisplay -r \" addpath('$DIR'); HCP_match_WA_with_AAfolds('$subj_ls', \
            '$FD_txt', '$DV_txt', '$bhvr_ls_rstr', '$bhvr_ls_unrstr', ['$AA_fold_stem' '$seed' '.mat'], '$outdir', \
            ['$outstem' '$seed'], '$restricted_csv', '$unrestricted_csv', '$FS_csv'); exit;\" "
        $CBIG_CODE_DIR/setup/CBIG_pbsubmit -cmd "$cmd" -walltime 14:00:00 -mem 3G \
            -name $jname -joberr $work_dir/$jname.err -jobout $work_dir/$jname.out
            sleep 4m
    done
}

#############################
# Function usage
#############################
usage() { echo "
NAME:
    HCP_match_WA_with_AAfolds.sh

DESCRIPTION:
    Using Hungarian matching to select matched WA with each AA fold.

ARGUMENTS:
    -max_seed       <max_seed>      : The maximal random repetition for spliting. It is consistent with
                                      the maximal seed used for 'HCP_split_AA_rm_hardtomatch.m'
    -subj_ls        <subj_ls>       : The list of all subject IDs involved in this project (full path).
    -FD_txt         <FD_txt>        : The text file containing each subject's framewise displacement
                                      (full path).
    -DV_txt         <DV_txt>        : The text file containing each subject's DVARS (full path).
    -bhvr_ls_rstr   <bhvr_ls_rstr>  : Full path of the list of behavioral measures which were included
                                      in the HCP restricted CSV.
    -bhvr_ls_unrstr <bhvr_ls_unstr> : Full path of the list of behavioral measures which were included 
                                      in the HCP unrestricted CSV.
    -AA_fold_stem   <AA_fold_stem>  : The file stem of the split AA folds, i.e. the outputs of 
                                      'HCP_split_AA_rm_hardtomatch.m'. For example, if the AA split using
                                      seed 1 is '<abs_path>/split_seed1.mat', then 'AA_fold_stem' is 
                                      '<abs_path>/split_seed'.
    -outdir         <outdir>        : Output directory (full path).
    -outstem        <outstem>       : Filename stem for the output .mat files. For example, if your output
                                      filename for seed 1 is '<outdir>/split_seed1.mat', then outstem is
                                      'split_seed'.
    -rstr_csv       <rstr_csv>      : Full path of the HCP restricted CSV file.
    -unrstr_csv     <unrstr_csv>    : Full path of the HCP unrestricted CSV file.
    -FS_csv         <FS_csv>        : Full path of the HCP FreeSurfer CSV file.

EXAMPLE:
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
        -max_seed)
            max_seed=$1
            shift;;
        -subj_ls)
            subj_ls=$1
            shift;;
        -FD_txt)
            FD_txt=$1
            shift;;
        -DV_txt)
            DV_txt=$1
            shift;;
        -bhvr_ls_rstr)
            bhvr_ls_rstr=$1
            shift;;
        -bhvr_ls_unrstr)
            bhvr_ls_unrstr=$1
            shift;;
        -AA_fold_stem)
            AA_fold_stem=$1
            shift;;
        -outdir)
            outdir=$1
            shift;;
        -outstem)
            outstem=$1
            shift;;
        -rstr_csv)
            restricted_csv=$1
            shift;;
        -unrstr_csv)
            unrestricted_csv=$1
            shift;;
        -FS_csv)
            FS_csv=$1
            shift;;
        *) 
			echo "Unknown flag $flag"
			usage; 1>&2; exit 1
            ;;
    esac
done

main