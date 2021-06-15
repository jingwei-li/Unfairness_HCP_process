## Run kernel ridge regression

```bash
# bash
cd ../KRR
./HCP_KRR_no_reg.sh -outdir /home/jingweil/storage/MyProject/fairAI/HCP_race/trained_model/split_948sub_AA_matchedWA_rm_AA_outliers18/outputs/l2_0_20_opt_pCOD_no_reg
```

## Plot Pearson's correlation accuracy across all test subjects (including AA, WA, other races)

1. metric: predictive COD

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_violin_KRR_acc_allsubj_matchedBehav(fullfile(proj_dir, 'trained_model', ...
    'split_948sub_AA_matchedWA_rm_AA_outliers18', 'outputs', ...
    'l2_0_20_opt_pCOD_no_reg'), 400, ...
    'predictive_COD', fullfile(proj_dir, 'figures', 'African_vs_white', ...
    '948_rm_otl18_no_reg'), 'pCOD_allsubj', ...
    fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'colloquial_names_51_matched.txt'))
```

2. metric: Pearson's correlation

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_violin_KRR_acc_allsubj_matchedBehav(fullfile(proj_dir, 'trained_model', ...
    'split_948sub_AA_matchedWA_rm_AA_outliers18', 'outputs', ...
    'l2_0_20_opt_pCOD_no_reg'), 400, ...
    'corr', fullfile(proj_dir, 'figures', 'African_vs_white', ...
    '948_rm_otl18_no_reg'), 'corr_allsubj', ...
    fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'colloquial_names_51_matched.txt'))
```

## Test which behavioral measures were predictable

Use multi-level block permutation test to check which behavioral measures could achieve higher-than-chance prediction accuracies across all test subjects (including all ethnicies/races, not only AA and WA).

1. Accuracy metric: predictive COD

```bash
# bash
cd ../KRR
proj_dir='/home/jingweil/storage/MyProject/fairAI/HCP_race'
./HCP_KRR_predictable_behavior.sh -KRR_dir \
$proj_dir/trained_model/split_948sub_AA_matchedWA_rm_AA_outliers18/outputs/l2_0_20_opt_pCOD_no_reg \
-test_metric predictive_COD -intrim_csv $proj_dir/scripts/lists/Multi-level_block_perm_948.csv \
-outmat $proj_dir/mat/predictability/pCOD_no_reg.mat
```

2. Accuracy metric: Pearson's correlation

```bash
# bash
cd ../KRR
proj_dir='/home/jingweil/storage/MyProject/fairAI/HCP_race'
./HCP_KRR_predictable_behavior.sh -KRR_dir \
$proj_dir/trained_model/split_948sub_AA_matchedWA_rm_AA_outliers18/outputs/l2_0_20_opt_pCOD_no_reg \
-test_metric corr -intrim_csv $proj_dir/scripts/lists/Multi-level_block_perm_948.csv \
-outmat $proj_dir/mat/predictability/corr_no_reg.mat
```