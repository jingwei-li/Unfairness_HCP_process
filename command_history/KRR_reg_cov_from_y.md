## Run kernel ridge regression

```bash
cd ../KRR
./HCP_KRR_reg_cov_from_y.sh -outdir \
    /home/jingweil/storage/MyProject/fairAI/HCP_race/\ 
    trained_model/split_948sub_AA_matchedWA_rm_AA_outliers18/\
    outputs/l2_0_20_opt_pCOD_reg_AgeSexMtEducIcvInc_from_y
```

## Test which behavioral measures were predictable

Use multi-level block permutation test to check which behavioral measures could achieve higher-than-chance prediction accuracies across all test subjects (including all ethnicies/races, not only AA and WA).

1. Accuracy metric: predictive COD

```bash
cd ../KRR
proj_dir='/home/jingweil/storage/MyProject/fairAI/HCP_race'
./HCP_KRR_predictable_behavior.sh -KRR_dir \
    $proj_dir/trained_model/split_948sub_AA_matchedWA_rm_AA_outliers18/outputs/l2_0_20_opt_pCOD_reg_AgeSexMtEducIcvInc_from_y \
    -test_metric predictive_COD -intrim_csv $proj_dir/scripts/lists/Multi-level_block_perm_948.csv \
    -outmat $proj_dir/mat/predictability/pCOD_reg_AgeSexMtEducIcvInc_from_y.mat
```

2. Accuracy metric: Pearson's correlation

```bash
cd ../KRR
proj_dir='/home/jingweil/storage/MyProject/fairAI/HCP_race'
./HCP_KRR_predictable_behavior.sh -KRR_dir \
    $proj_dir/trained_model/split_948sub_AA_matchedWA_rm_AA_outliers18/outputs/l2_0_20_opt_pCOD_reg_AgeSexMtEducIcvInc_from_y \
    -test_metric corr -intrim_csv $proj_dir/scripts/lists/Multi-level_block_perm_948.csv \
    -outmat $proj_dir/mat/predictability/corr_reg_AgeSexMtEducIcvInc_from_y.mat
```

## Calculate predictive COD and Pearson's correlation for matched AA and WA separately

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_KRR_pCOD_AAvsWA_matchedBehavior( fullfile(proj_dir, 'trained_model', ...
    'split_948sub_AA_matchedWA_rm_AA_outliers18', 'outputs', ...
    'l2_0_20_opt_pCOD_reg_AgeSexMtEducIcvInc_from_y'), 400, 10, fullfile(proj_dir, ...
    'mat', 'split_AA_948_rm_outliers18'), fullfile(proj_dir, 'mat', ...
    'split_WA_rm_AA_outliers18'), fullfile(proj_dir, 'mat', ...
    'split_WA_rm_AA_outliers18', 'usable_seeds'), fullfile(proj_dir, 'mat', ...
    'AA_WA_diff', 'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y.mat'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', ...
    'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y.mat'), fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), fullfile(proj_dir, ...
    'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_58.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt') )
```