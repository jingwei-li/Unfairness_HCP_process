#!/bin/sh

DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

########################################
# The following paths are only for the author's own replication purpose.
# External users please pass in your own data. Then it will overwrite these default settings.
########################################
proj_dir='/home/jingweil/storage/MyProject/fairAI/HCP_race'
subj_ls="$proj_dir/scripts/lists/subjects_wIncome_948.txt"
bhvr_ls="$proj_dir/scripts/lists/Cognitive_Personality_Task_Social_Emotion_58.txt"
AAsplit_stem="$proj_dir/mat/split_AA_948_rm_outliers18/split_seed"
WAsplit_stem="$proj_dir/mat/split_WA_rm_AA_outliers18/split_seed"
restricted_csv=     # use matlab function's default

########################################
# main commands to be submitted to jobs
########################################
main(){
    work_dir=$outdir/logs
    mkdir $work_dir
    jname="split_others"

    for seed in $(seq 1 1 $max_seed); do
        cmd="matlab -nodesktop -nodisplay -nojvm -r \" addpath $DIR; HCP_split_except_selectedAAWA('$subj_ls', \
            '$bhvr_ls', $seed, ['$AAsplit_stem' '$seed' '.mat'], ['$WAsplit_stem' '$seed' '.mat'], \
            fullfile('$outdir', ['split_seed' '$seed' '.mat']), '$restricted_csv'); exit; \" "
        $CBIG_CODE_DIR/setup/CBIG_pbsubmit -cmd "$cmd" -walltime 01:00:00 -mem 2G \
            -name $jname -joberr $work_dir/$jname.err -jobout $work_dir/$jname.out
        sleep 3s
    done

}

#############################
# Function usage
#############################
usage() { echo "
NAME:
    HCP_split_except_selectedAAWA.sh

DESCRIPTION:
    Split the subjects except the matched AA & WA. This script calls the matlab function 
    `HCP_split_except_selectedAAWA.m`.

ARGUMENTS:
    -max_seed       <max_seed>      : The maximal random repetition for spliting. It is consistent with
                                      the maximal seed used for 'HCP_split_AA_rm_hardtomatch.m'
    -subj_ls        <subj_ls>       : The list of all subject IDs involved in this project (full path).
    -bhvr_ls        <bhvr_ls>       : The list of all behavioral measures (full path).
    -AAsplit_stem   <AAsplit_stem>  : The directory storing the selected AA, which have been split into
                                      folds with multiple random repetitions. It is the output directory
                                      of 'HCP_split_AA_rm_hardtomatch.m'
    -WAsplit_stem   <WAsplit_stem>  : The directory storing the selected WA, which matched with the AA
                                      folds. It is the output directory of 'HCP_match_WA_with_AAfolds.sh'
    -outdir         <outdir>        : Output directory, full path.
    -restricted_csv <restricted_csv>: HCP restricted CSV file (full path).

EXAMPLE:
    <path_to_this_script>/HCP_split_except_selectedAAWA.sh -max_seed 400 -subj_ls /your/subject_list.txt \
        -bhvr_ls /your/behavioral_list.txt -AAsplit_stem /path/to/AA/splits/split_seed -WAsplit_stem \
        /path/to/WA/splits/split_seed -restricted_csv /your/HCP_restricted.csv -outdir /your/output/dir
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
        -bhvr_ls)
            bhvr_ls=$1
            shift;;
        -AAsplit_stem)
            AAsplit_stem=$1
            shift;;
        -WAsplit_stem)
            WAsplit_stem=$1
            shift;;
        -outdir)
            outdir=$1
            shift;;
        -restricted_csv)
            restricted_csv=$1
            shift;;
        *) 
			echo "Unknown flag $flag"
			usage; 1>&2; exit 1
            ;;
    esac
done

main