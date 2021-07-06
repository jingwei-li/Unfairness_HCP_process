#!/bin/sh

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

main() {
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

                cmd="$DIR/HCP_elasticNet.sh -rstr_csv $rstr_csv -unrstr_csv $unrstr_csv -FS_csv $FS_csv \
-subj_ls $subj_ls -RSFC_file $RSFC_file -y_name $y_name -cov_ls $cov_ls -cov_X_ls $cov_ls -FD_file $FD_file \
-DV_file $DV_file -outdir $outdir -seed $seed"

                jname="EN_${y_name}"
                work_dir="$outdir/logs/randseed_${seed}/HPC"
                mkdir -p $work_dir
                $CBIG_CODE_DIR/setup/CBIG_pbsubmit -cmd "$cmd" -walltime 02:00:00 -mem 8G \
                    -name $jname -joberr $work_dir/$jname.err -jobout $work_dir/$jname.out
                sleep 3s
            done
        fi
    done
}

#############################
# Function usage
#############################
usage() { echo "
NAME:
    HCP_EN_reg_cov_from_y_FC.sh

DESCRIPTION:

REQUIRED ARGUMENTS:

OPTIONAL ARGUMENTS:

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
        -outdir)   # required
            outdir=$1
            shift;;
        -subj_ls) subj_ls=$1; shift;;
        -FD_file) FD_file=$1; shift;;
        -DV_file) DV_file=$1; shift;;
        -RSFC_file) RSFC_file=$1; shift;;
        -cov_ls) cov_ls=$1; shift;;
        -sub_fold_dir) sub_fold_dir=$1; shift;;
        -use_seed_bhvr_dir) use_seed_bhvr_dir=$1; shift;;
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
if [ -z "$outdir" ]; then
	arg1err "-outdir"
fi


main