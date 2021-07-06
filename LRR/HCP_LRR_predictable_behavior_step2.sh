#!/bin/sh

DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

proj_dir=/home/jingweil/storage/MyProject/fairAI/HCP_race
LRR_dir=$proj_dir/trained_model/LRR/948sub/reg_AgeSexMtEducIcvInc_fr_y_FC
FC_file=$proj_dir/mat/RSFC_948.mat
maxLRR_iter=400
Nperm=1000

bhvr_ls=$proj_dir/scripts/lists/Cognitive_Personality_Task_Social_Emotion_51_matched.txt

main() {
    for bhvr_nm in $(cat $bhvr_ls); do
        log_dir=$LRR_dir/logs/predictability
        mkdir -p $log_dir
        work_dir=$log_dir/HPC

        end_iters=(34 $maxLRR_iter)
        i=0
        for start_iter in 1 35; do
            LF=$log_dir/step2_${bhvr_nm}_start${start_iter}.log
            if [ -f $LF ]; then rm $LF; fi

            echo "FC_file = $FC_file" >> $LF
            echo "LRR_dir = $LRR_dir" >> $LF
            echo "maxLRR_iter = $maxLRR_iter" >> $LF
            echo "Nperm = $Nperm" >> $LF
            echo "bhvr_nm = $bhvr_nm" >> $LF
            cmd="matlab -nodesktop -nojvm -nodisplay -r \" addpath $DIR; \
                HCP_LRR_predictable_behavior_step2('$FC_file', '$LRR_dir', $start_iter, ${end_iters[$i]}, \
                $Nperm, '$bhvr_nm'); exit; \" >> $LF 2>&1"
        
            jname=HCP_LRR_predictability_step2_${bhvr_nm}_start${start_iter}
            $CBIG_CODE_DIR/setup/CBIG_pbsubmit -cmd "$cmd" -walltime 70:00:00 -mem 20G -ncpus 1 \
                -name $jname -joberr $work_dir/$jname.err -jobout $work_dir/$jname.out
            sleep 3s
            i=$((i + 1))
        done
    done
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
if [ $# -eq 0 ]; then
	usage; 1>&2; exit 1
fi

while [[ $# -gt 0 ]]; do
	flag=$1; shift;
	
	case $flag in
        -LRR_dir)        # optional
            LR_dir=$1; shift;;
        -FC_file)        # optional
            FC_file=$1; shift;;
        -maxLRR_iter)    # optional
            maxLRR_iter=$1; shift;;
        -Nperm)          # optional
            Nperm=$1; shift;;
        -bhvr_ls)        # optional
            bhvr_ls=$1; shift;;
		*) 
			echo "Unknown flag $flag"
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


main
