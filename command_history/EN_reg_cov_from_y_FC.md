# Run elastic net

```bash
# bash
cd ./elasticNet
./HCP_EN_reg_cov_from_y_FC.sh -outdir \
/home/jingweil/storage/MyProject/fairAI/HCP_race/trained_model/\
elasticNet/948sub/reg_AgeSexMtEducIcvInc_fr_y_FC
```

## Plot Pearson's correlation accuracy across all test subjects (including AA, WA, other races)

## Test which behavioral measures were predictable

Use multi-level block permutation test to check which behavioral measures could achieve higher-than-chance prediction accuracies across all test subjects (including all ethnicies/races, not only AA and WA).

1. Accuracy metric: predictive COD

```bash
# bash
cd ../elasticNet
proj_dir='/home/jingweil/storage/MyProject/fairAI/HCP_race'
./HCP_EN_predictable_behavior.sh -EN_dir \
$proj_dir/trained_model/elasticNet/948sub/reg_AgeSexMtEducIcvInc_fr_y_FC \
-test_metric predictive_COD -intrim_csv $proj_dir/scripts/lists/Multi-level_block_perm_948.csv \
-outmat $proj_dir/mat/predictability/elasticNet/pCOD_reg_AgeSexMtEducIcvInc_from_y_FC.mat
```

2. Accuracy metric: Pearson's correlation

```bash
# bash
cd ../elasticNet
proj_dir='/home/jingweil/storage/MyProject/fairAI/HCP_race'
./HCP_EN_predictable_behavior.sh -EN_dir \
$proj_dir/trained_model/elasticNet/948sub/reg_AgeSexMtEducIcvInc_fr_y_FC \
-test_metric corr -intrim_csv $proj_dir/scripts/lists/Multi-level_block_perm_948.csv \
-outmat $proj_dir/mat/predictability/elasticNet/corr_reg_AgeSexMtEducIcvInc_from_y_FC.mat
```

## Calculate predictive COD and Pearson's correlation for matched AA and WA separately

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_EN_acc_AAvsWA_matchedBehavior(fullfile(proj_dir, 'trained_model', 'elasticNet', '948sub', ...
    'reg_AgeSexMtEducIcvInc_fr_y_FC'), 400, 10, fullfile(proj_dir, 'mat', 'split_AA_948_rm_outliers18'), ...
    fullfile(proj_dir, 'mat', 'split_WA_rm_AA_outliers18'), fullfile(proj_dir, 'mat', ...
    'split_WA_rm_AA_outliers18', 'usable_seeds'), fullfile(proj_dir, 'mat', 'AA_WA_diff', 'elasticNet', ...
    'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), fullfile(proj_dir, 'mat', 'AA_WA_diff', ...
    'elasticNet', 'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), fullfile(proj_dir, 'scripts', ...
    'lists', 'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), fullfile(proj_dir, ...
    'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_58.txt'), fullfile(proj_dir, ...
    'scripts', 'lists', 'subjects_wIncome_948.txt'))
```