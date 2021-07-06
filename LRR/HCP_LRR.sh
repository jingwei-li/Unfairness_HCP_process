#!/bin/sh
# Author: Jingwei Li

DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

HCP_dir="/mnt/isilon/CSC1/Yeolab/Data/HCP/S1200"
rstr_csv="$HCP_dir/scripts/restricted_hcp_data/\
RESTRICTED_jingweili_4_12_2017_1200subjects_fill_empty_zygosityGT_by_zygositySR.csv"
unrstr_csv="$HCP_dir/scripts/subject_measures/\
unrestricted_jingweili_12_7_2017_21_0_16_NEO_A_corrected.csv"
FS_csv="$HCP_dir/scripts/Morphometricity/Anat_Sim_Matrix/\
FS_jingweili_5_9_2017_2_2_24.csv"

num_test_folds=10
num_inner_folds=10

main() {
    ##########################
    # Echo parameters
    ##########################
    mkdir -p $outdir/logs/randseed_${seed}
    LF="$outdir/logs/randseed_${seed}/${y_name}.log"
    if [ -f $LF ]; then rm $LF; fi

    echo "restricted_csv = $rstr_csv" >> $LF
    echo "unrestricted_csv = $unrstr_csv" >> $LF
    echo "FS_csv = $FS_csv" >> $LF
    echo "subj_ls = $subj_ls" >> $LF
    echo "RSFC_file = $RSFC_file" >> $LF
    echo "y_name = $y_name" >> $LF
    echo "cov_ls = $cov_ls" >> $LF
    echo "cov_X_ls = $cov_X_ls" >> $LF
    echo "FD_file = $FD_file" >> $LF
    echo "DV_file = $DV_file" >> $LF
    echo "outdir = $outdir" >> $LF
    echo "num_test_folds = $num_test_folds" >> $LF
    echo "num_inner_folds = $num_inner_folds" >> $LF
    echo "seed = $seed" >> $LF

    matlab -nodesktop -nosplash -nodisplay -r " addpath $DIR; HCP_LRR( '$rstr_csv', \
        '$unrstr_csv', '$FS_csv', '$subj_ls', '$RSFC_file', '$y_name', '$cov_ls', '$cov_X_ls', \
        '$FD_file', '$DV_file', '$outdir', $num_test_folds, $num_inner_folds, $seed ); exit " >> $LF 2>&1
}

#############################
# Function usage
#############################
usage() { echo "
NAME:
    HCP_LRR.sh

DESCRIPTION:
    Call HCP_LRR.m to run linear ridge regression on the HCP data.

REQUIRED ARGUMENTS:
    -subj_ls         <subj_ls>        : Subject list (full path). Each line corresponds to one subject.
    -RSFC_file       <RSFC_file>      : Full path of the functional connectivity .mat file.
    -y_name          <y_name>         : The behavioral name to be predicted. The name should correspond to one of 
                                        the headers in either rstr_csv or unrstr_csv.
    -cov_ls          <cov_ls>         : A text file (full path) containing the confounding variables to be 
                                        regressed out from behavioral measures.
    -cov_X_ls        <cov_X_ls>       : A text file (full path) containing the confounding variables to be 
                                        regressed out from RSFC. Pass in NONE if nothing should be regressed from
                                        RSFC.
    -FD_file         <FD_file>        : A text file (full path) containing the framewise displacement for each 
                                        subject in <subj_ls>. Each line in this file corresponds to one subject.
    -DV_file         <DV_file>        : A text file (full path) containing the DVARS of each subject in <subj_ls>. 
                                        Each line in this file corresponds to one subject.
    -outdir          <outdir>         : Output directory (full path).
    -seed            <seed>           : The random seed used for cross-validation fold split.

OPTIONAL ARGUMENTS:
    -num_test_folds  <num_test_folds> : Number of training-test cross-validation folds. Default: 10.
    -num_inner_folds <num_inner_folds>: Number of inner-loop cross-validation folds. Default: 10.
    -rstr_csv        <rstr_csv>       : The restricted CSV file downloaded from the HCP website. Default: 
                                        /mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/scripts/restricted_hcp_data/\\
                                        RESTRICTED_jingweili_4_12_2017_1200subjects_fill_empty_zygosityGT_by_zygositySR.csv
    -unrstr_csv      <unrstr_csv>     : The unrestricted CSV file downloaded from the HCP website. Default:
                                        /mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/scripts/subject_measures/\\
                                        unrestricted_jingweili_12_7_2017_21_0_16_NEO_A_corrected.csv
    -FS_csv          <FS_csv>         : The FreeSurfer CSV file downloaded from the HCP website. Default:
                                        /mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/scripts/Morphometricity/\\
                                        Anat_Sim_Matrix/FS_jingweili_5_9_2017_2_2_24.csv

EXAMPLE:

" 1>&2; exit 1; }

##########################################
# ERROR message
##########################################	
arg1err() {
	echo "ERROR: flag $flag requires one argument"
	exit 1
}

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
        -subj_ls) subj_ls=$1; shift;;
        -RSFC_file) RSFC_file=$1; shift;;
        -y_name) y_name=$1; shift;;
        -cov_ls) cov_ls=$1; shift;;
        -cov_X_ls) cov_X_ls=$1; shift;;
        -FD_file) FD_file=$1; shift;;
        -DV_file) DV_file=$1; shift;;
        -outdir) outdir=$1; shift;;
        -seed) seed=$1; shift;;
        -num_test_folds) num_test_folds=$1; shift;;
        -num_inner_folds) num_inner_folds=$1; shift;;
        -rstr_csv) rstr_csv=$1; shift;;
        -unrstr_csv) unrstr_csv=$1; shift;;
        -FS_csv) FS_csv=$1; shift;;
        *)
            echo "Unknown flag $flag"
            usage; 1>&2; exit 1;;
    esac
done

##########################################
# Check Parameters
##########################################

if [ "$subj_ls" == "" ]; then
    echo "ERROR: subject list not specified."
    exit 1
fi
if [ "$RSFC_file" == "" ]; then
    echo "ERROR: RSFC file not specified."
    exit 1
fi
if [ "$y_name" == "" ]; then
    echo "ERROR: behavioral name to be predicted not specified."
    exit 1
fi
if [ "$cov_ls" == "" ]; then
    echo "ERROR: list of confounding variables to be regressed out from behavioral measures not specified."
    exit 1
fi
if [ "$cov_X_ls" == "" ]; then
    echo "ERROR: list of confounding variables to be regressed out from RSFC not specified."
    exit 1
fi
if [ "$FD_file" == "" ]; then
    echo "ERROR: framewise displacement file not specified."
    exit 1
fi
if [ "$DV_file" == "" ]; then
    echo "ERROR: DVARS file not specified."
    exit 1
fi
if [ "$outdir" == "" ]; then
    echo "ERROR: output directory not specified."
    exit 1
fi

main
