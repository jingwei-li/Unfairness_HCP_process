#!/bin/sh
# Wrapper script to apply kernel ridge regression to the HCP dataset. 
# Confounding variables (age, gender, FD, DVARS, education, income, ICV) are regressed
# from both behavioral scores and RSFC.
# Author: Jingwei Li

DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

HCP_dir="/mnt/isilon/CSC1/Yeolab/Data/HCP/S1200"
rstr_csv="$HCP_dir/scripts/restricted_hcp_data/\
RESTRICTED_jingweili_4_12_2017_1200subjects_fill_empty_zygosityGT_by_zygositySR.csv"
unrstr_csv="$HCP_dir/scripts/subject_measures/\
unrestricted_jingweili_12_7_2017_21_0_16_NEO_A_corrected.csv"
FS_csv="$HCP_dir/scripts/Morphometricity/Anat_Sim_Matrix/\
FS_jingweili_5_9_2017_2_2_24.csv"

proj_dir="/home/jingweil/storage/MyProject/fairAI/HCP_race"
subj_ls="$proj_dir/scripts/lists/subjects_wIncome_948.txt"
FD_file="$proj_dir/scripts/lists/FD_948.txt"
DV_file="$proj_dir/scripts/lists/DV_948.txt"
RSFC_file="$proj_dir/mat/RSFC_948.mat"
cov_ls="$proj_dir/scripts/lists/covariates_Age_Sex_MT_Educ_ICV_Income.txt"
sub_fold_dir="$proj_dir/mat/combine_AA_matchedWA_others_rm_AA_outliers18"
use_seed_bhvr_dir="$proj_dir/mat/split_WA_rm_AA_outliers18/usable_seeds"

outdir=

main() {
    lambda_set_file="$DIR/lambda_0_20.mat"
    max_seed=400
    num_test_folds=10
    num_inner_folds=10

    for seed in $(seq 1 1 $max_seed); do
        echo "seed = $seed"
        bhvr_ls="$use_seed_bhvr_dir/usable_behaviors_seed${seed}.txt"
        if [ -f $bhvr_ls ]; then
            behaviors=$(cat $bhvr_ls)

            for y_name in $behaviors; do
                subfold_rel="no_relative_${num_test_folds}_fold_sub_list_${y_name}.mat"
                ln_dir="$outdir/randseed_${seed}/${y_name}"
                if [ ! -L $ln_dir/$subfold_rel ]; then
                    mkdir -p $ln_dir
                    ln -s $sub_fold_dir/split_seed${seed}/$subfold_rel $ln_dir/
                fi

                cmd="$DIR/HCP_KRR_workflow_optimize_COD.sh -subj_ls $subj_ls -RSFC_file $RSFC_file -y_name"
                cmd="$cmd $y_name -cov_ls $cov_ls -cov_X_ls $cov_ls -FD_file $FD_file -DV_file $DV_file -outdir $outdir"
                cmd="$cmd -seed $seed -num_test_folds $num_test_folds -num_inner_folds"
                cmd="$cmd $num_inner_folds -lambda_set_file $lambda_set_file -rstr_csv $rstr_csv"
                cmd="$cmd -unrstr_csv $unrstr_csv -FS_csv $FS_csv"

                jname="KRR_${y_name}"
                work_dir="$outdir/randseed_${seed}"
                #if [ ! -f $outdir/randseed_${seed}/${y_name}/final_result_${y_name}.mat ]; then
                    $CBIG_CODE_DIR/setup/CBIG_pbsubmit -cmd "$cmd" -walltime 06:00:00 -mem 6G \
                        -name $jname -joberr $work_dir/$jname.err -jobout $work_dir/$jname.out
                    sleep 3s
                #fi
            done
        fi
    done
}

#############################
# Function usage
#############################
usage() { echo "
NAME:
    HCP_KRR_reg_cov_from_y.sh

DESCRIPTION:
    Wrapper script to run kernel ridge regression on the HCP dataset. Confounding variables will be
    regressed out from behavioral scores across subjects. 
    This script calls 'HCP_KRR_workflow_optimize_COD.sh'

REQUIRED ARGUMENTS:
    -outdir            <outdir>           : Output directory (full path).

OPTIONAL ARGUMENTS:
    -subj_ls           <subj_ls>          : Subject list (full path). Each line corresponds to one subject.
                                            Default (only for the author's testing purpose):
                                            /home/jingweil/storage/MyProject/fairAI/HCP_race/scripts/lists/\\
                                            subjects_wIncome_948.txt
    -FD_file           <FD_file>          : A text file (full path) containing the framewise displacement 
                                            for each subject in <subj_ls>. Each line in this file corresponds
                                            to one subject. Default (only for the author's testing purpose):
                                            /home/jingweil/storage/MyProject/fairAI/HCP_race/scripts/lists/\\
                                            FD_948.txt
    -DV_file           <DV_file>          : A text file (full path) containing the DVARS of each subject in 
                                            <subj_ls>. Each line in this file corresponds to one subject.
                                            Default (only for the author's testing purpose):
                                            /home/jingweil/storage/MyProject/fairAI/HCP_race/scripts/lists/\\
                                            DV_948.txt
    -RSFC_file         <RSFC_file>        : Full path of the functional connectivity .mat file.
                                            Default (only for the author's testing purpose):
                                            /home/jingweil/storage/MyProject/fairAI/HCP_race/mat/RSFC_948.mat
    -cov_ls            <cov_ls>           : A text file (full path) containing the confounding variables to
                                            be regressed out from both behavioral scores and RSFC. Default 
                                            (only for the author's testing purpose):
                                            /home/jingweil/storage/MyProject/fairAI/HCP_race/scripts/lists/\\
                                            covariates_Age_Sex_MT_Educ_ICV_Income.txt
    -sub_fold_dir      <sub_fold_dir>     : The directory storing the combined folds of matched AA, matched WA,
                                            and the remaining subjects. 
                                            Default (only for the author's testing purpose):
                                            /home/jingweil/storage/MyProject/fairAI/HCP_race/mat/\\
                                            combine_AA_matchedWA_others_rm_AA_outliers18
    -use_seed_bhvr_dir <use_seed_bhvr_dir>: For each behavioral measure, 40 seed were selected with 
                                            matched AA and WA. These (behavior,seed) combinations 
                                            were saved as a text list for each seed (i.e. for current
                                            seed, which behavioral measures were chosen). 
                                            <use_seed_bhvr_dir> is the folder contains these text files.
                                            They are the outputs of '../match_split/HCP_select_matched_seeds.m'
                                            Default (only for the author's testing purpose):
                                            /home/jingweil/storage/MyProject/fairAI/HCP_race/mat/\\
                                            split_WA_rm_AA_outliers18/usable_seeds
    -rstr_csv          <rstr_csv>         : The restricted CSV file downloaded from the HCP website. Default: 
                                            /mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/scripts/restricted_hcp_data/\\
                                            RESTRICTED_jingweili_4_12_2017_1200subjects_fill_empty_zygosityGT_by_zygositySR.csv
    -unrstr_csv        <unrstr_csv>       : The unrestricted CSV file downloaded from the HCP website. Default:
                                            /mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/scripts/subject_measures/\\
                                            unrestricted_jingweili_12_7_2017_21_0_16_NEO_A_corrected.csv
    -FS_csv            <FS_csv>           : The FreeSurfer CSV file downloaded from the HCP website. Default:
                                            /mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/scripts/Morphometricity/\\
                                            Anat_Sim_Matrix/FS_jingweili_5_9_2017_2_2_24.csv
EXAMPLE:
    $DIR/HCP_KRR_reg_cov_from_y.sh -outdir '/your/output/dir/' -subj_ls '/your/subject/list.txt' -FD_file
        '/your/FD.txt' -DV_file '/your/DVARS.txt' -RSFC_file '/your/RSFC.mat' -cov_ls '/your/confounds/list.txt'
        -sub_fold_dir '/your/split/folds/dir/' -use_seed_bhvr_dir '/your/selected/seed_behavior_comb/lists/dir'
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
        -outdir)   # required
            outdir=$1
            shift;;
        -subj_ls)
            subj_ls=$1
            shift;;
        -FD_file)
            FD_file=$1
            shift;;
        -DV_file)
            DV_file=$1
            shift;;
        -RSFC_file)
            RSFC_file=$1
            shift;;
        -cov_ls)
            cov_ls=$1
            shift;;
        -sub_fold_dir)
            sub_fold_dir=$1
            shift;;
        -use_seed_bhvr_dir)
            use_seed_bhvr_dir=$1
            shift;;
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
if [ -z "$outdir" ]; then
	arg1err "-outdir"
fi


main
