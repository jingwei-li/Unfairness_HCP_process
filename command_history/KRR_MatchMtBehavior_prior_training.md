## Split subjects

### Step 1. Split AA

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
for seed = 1:400
    HCP_split_AA_rm_hardtomatch(fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt'), ...
        fullfile(proj_dir, 'scripts', 'lists', 'hard_to_match_AA_MtBehavior.txt'), 10, seed, ...
        fullfile(proj_dir, 'mat', 'MatchMtBehavior', 'split_AA_rm_otl', ['split_seed' num2str(seed)]), ...
        '/mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/scripts/restricted_hcp_data/RESTRICTED_jingweili_4_12_2017_1200subjects_fill_empty_zygosityGT_by_zygositySR.csv')
end
```

### Step 2. Within each AA fold, find matched WA

```bash
# bash
ssh headnode
cd ~/storage/MyProject/fairAI/HCP_race/scripts/Unfairness_HCP_process/match_split
./HCP_match_WA_with_AAfolds.sh -max_seed 400 -outdir \
    /home/jingweil/storage/MyProject/fairAI/HCP_race/mat/MatchMtBehavior/split_WA_rmAAotl \
    -AA_fold_stem /home/jingweil/storage/MyProject/fairAI/HCP_race/mat/MatchMtBehavior/split_AA_rm_otl/split_seed -match_ls /home/jingweil/storage/MyProject/fairAI/HCP_race/scripts/lists/covariates_MT.txt
```

### Step 3. Check if the difference in behavioral distributions between AA & WA were significant

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_AA_WA_match_diff(...
    fullfile(proj_dir, 'mat', 'MatchMtBehavior', 'split_AA_rm_otl'), ...
    fullfile(proj_dir, 'mat', 'MatchMtBehavior', 'split_WA_rmAAotl'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'FD_948.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'FD_948.txt'), 'NONE', ...
    fullfile(proj_dir, 'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_58.txt'), 400, ...
    fullfile(proj_dir, 'mat', 'MatchMtBehavior', 'split_WA_rmAAotl', 'stats_ks_tt.mat'), [], [], [], ...
    fullfile(proj_dir, 'scripts', 'lists', 'covariates_MT.txt'))
```

For each behavioral measures, the first 40 random splits with matched AA & WA were selected. The selected (seed, behavior) combinations were saved as text lists by the following script:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_select_matched_seeds(...
    fullfile(proj_dir, 'mat', 'MatchMtBehavior', 'split_AA_rm_otl'), ...
    fullfile(proj_dir, 'mat', 'MatchMtBehavior', 'split_WA_rmAAotl'), ...
    fullfile(proj_dir, 'mat', 'MatchMtBehavior', 'split_WA_rmAAotl', 'stats_ks_tt.mat'), 400, ...
    fullfile(proj_dir, 'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_58.txt'), ...
    fullfile(proj_dir, 'mat', 'MatchMtBehavior', 'split_WA_rmAAotl', 'usable_seeds'))
```

### Step 4: split the remaining subjects

```bash
# bash
ssh headnode
cd ~/storage/MyProject/fairAI/HCP_race/scripts/Unfairness_HCP_process/match_split
./HCP_split_except_selectedAAWA.sh -max_seed 400 -outdir \
    /home/jingweil/storage/MyProject/fairAI/HCP_race/mat/MatchMtBehavior/split_exceptAAWA_rmAAotl \
    -AAsplit_stem /home/jingweil/storage/MyProject/fairAI/HCP_race/mat/MatchMtBehavior/split_AA_rm_otl/split_seed \
    -WAsplit_stem /home/jingweil/storage/MyProject/fairAI/HCP_race/mat/MatchMtBehavior/split_WA_rmAAotl/split_seed
```

### Step 5: combine the splits of AA, splits of matched WA, and splits of other subjects

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
for seed = 1:400
    matched_bhvr_ls = fullfile(proj_dir, 'mat', 'MatchMtBehavior', 'split_WA_rmAAotl', ...
        'usable_seeds', ['usable_behaviors_seed' num2str(seed) '.txt']); 
    if(exist(matched_bhvr_ls, 'file')) 
        HCP_combine_AA_WA_others_folds(fullfile(proj_dir, 'mat', 'MatchMtBehavior', 'split_AA_rm_otl', ...
            ['split_seed' num2str(seed) '.mat']), fullfile(proj_dir, 'mat', 'MatchMtBehavior', ...
            'split_WA_rmAAotl', ['split_seed' num2str(seed) '.mat']), ...
            fullfile(proj_dir, 'mat', 'MatchMtBehavior', 'split_exceptAAWA_rmAAotl', ...
            ['split_seed' num2str(seed) '.mat']), fullfile(proj_dir, 'scripts', 'lists', ...
            'subjects_wIncome_948.txt'), fullfile(proj_dir, 'scripts', 'lists', ...
            'Cognitive_Personality_Task_Social_Emotion_58.txt'), matched_bhvr_ls, ...
            fullfile(proj_dir, 'mat', 'MatchMtBehavior', 'combine_AA_matchedWA_others_rmAAotl', ...
            ['split_seed' num2str(seed)]))
    end
end
```

##  Run kernel ridge regression

```bash
# bash
cd ../KRR
proj_dir="/home/jingweil/storage/MyProject/fairAI/HCP_race"
./HCP_KRR_reg_cov_from_y_FC.sh -outdir \
$proj_dir/trained_model/split_948sub_MatchMtBehavior_rmAAotl/reg_AgeSexMtEducIcvInc_from_y_FC \
-sub_fold_dir $proj_dir/mat/MatchMtBehavior/combine_AA_matchedWA_others_rmAAotl \
-use_seed_bhvr_dir $proj_dir/mat/MatchMtBehavior/split_WA_rmAAotl/usable_seeds
```

## Plot Pearson's correlation accuracy across all test subjects (including AA, WA, other races)

1. metric: Pearson's correlation

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_violin_KRR_acc_allsubj_matchedBehav(fullfile(proj_dir, 'trained_model', ...
    'split_948sub_MatchMtBehavior_rmAAotl', 'reg_AgeSexMtEducIcvInc_from_y_FC'), 400, ...
    'corr', fullfile(proj_dir, 'figures', 'African_vs_white', ...
    'MatchMtBehavior_reg_AgeSexMtEducIcvInc_from_y_FC'), 'corr_allsubj', ...
    fullfile(proj_dir, 'scripts', 'lists', 'behaviors_55matchedMtBehavior.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'colloquial_names_55_matchedMtBehavior.txt'))
```

## Test which behavioral measures were predictable

Use multi-level block permutation test to check which behavioral measures could achieve higher-than-chance prediction accuracies across all test subjects (including all ethnicies/races, not only AA and WA).

1. Accuracy metric: predictive COD

```bash
# bash
cd ../KRR
proj_dir='/home/jingweil/storage/MyProject/fairAI/HCP_race'
./HCP_KRR_predictable_behavior.sh -KRR_dir \
$proj_dir/trained_model/split_948sub_MatchMtBehavior_rmAAotl/reg_AgeSexMtEducIcvInc_from_y_FC \
-test_metric predictive_COD -intrim_csv $proj_dir/scripts/lists/Multi-level_block_perm_948.csv \
-outmat $proj_dir/mat/predictability/KRR/MatchMtBehavior/pCOD_reg_AgeSexMtEducIcvInc_from_y_FC.mat \
-bhvr_ls $proj_dir/scripts/lists/behaviors_55matchedMtBehavior.txt -colloq_ls \
$proj_dir/scripts/lists/colloquial_names_55_matchedMtBehavior.txt
```

2. Accuracy metric: Pearson's correlation

```bash
# bash
cd ../KRR
proj_dir='/home/jingweil/storage/MyProject/fairAI/HCP_race'
./HCP_KRR_predictable_behavior.sh -KRR_dir \
$proj_dir/trained_model/split_948sub_MatchMtBehavior_rmAAotl/reg_AgeSexMtEducIcvInc_from_y_FC \
-test_metric corr -intrim_csv $proj_dir/scripts/lists/Multi-level_block_perm_948.csv \
-outmat $proj_dir/mat/predictability/KRR/MatchMtBehavior/corr_reg_AgeSexMtEducIcvInc_from_y_FC.mat \
-bhvr_ls $proj_dir/scripts/lists/behaviors_55matchedMtBehavior.txt -colloq_ls \
$proj_dir/scripts/lists/colloquial_names_55_matchedMtBehavior.txt
```

## Calculate predictive COD and Pearson's correlation for matched AA and WA separately

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_KRR_acc_AAvsWA_matchedBehavior( fullfile(proj_dir, 'trained_model', ...
    'split_948sub_MatchMtBehavior_rmAAotl', 'reg_AgeSexMtEducIcvInc_from_y_FC'), 400, 10, ...
    fullfile(proj_dir, 'mat', 'MatchMtBehavior', 'split_AA_rm_otl'), fullfile(proj_dir, 'mat', ...
    'MatchMtBehavior', 'split_WA_rmAAotl'), fullfile(proj_dir, 'mat', ...
    'MatchMtBehavior', 'split_WA_rmAAotl', 'usable_seeds'), fullfile(proj_dir, 'mat', ...
    'AA_WA_diff', 'KRR', 'MatchMtBehavior', 'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), fullfile(proj_dir, 'scripts', 'lists', ...
    'behaviors_55matchedMtBehavior.txt'), fullfile(proj_dir, ...
    'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_58.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt') )
```

## Select behavioral measures with above-chance overall prediction accuracy, and with positive accuracy in either matched AA or matched WA

### Get behavioral measures whole correlation accuracy across all subjects was higher than 0.15

```matlab
% matlab
clear
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
model_dir = fullfile(proj_dir, 'trained_model', ...
    'split_948sub_MatchMtBehavior_rmAAotl', 'reg_AgeSexMtEducIcvInc_from_y_FC');
[bhvr_nm, nbhvr] = CBIG_text2cell(fullfile(proj_dir, 'scripts', 'lists', ...
    'behaviors_55matchedMtBehavior.txt'));
acc = zeros(nbhvr, 40);
for b = 1:nbhvr
    c = 1;
    for i = 1:400
        opt_fname = fullfile(model_dir, ['randseed_' num2str(i)], bhvr_nm{b}, ['final_result_' bhvr_nm{b} '.mat']);
        if(~exist(opt_fname, 'file')); continue; end;

        opt = load(opt_fname);
        acc(b,c) = mean(opt.optimal_acc, 1);
        c = c+1;
    end
end
idx = find(mean(acc,2)>0.15);
CBIG_cell2text(bhvr_nm(idx), fullfile(model_dir, 'lists', ...
    ['R_thres0.15_' num2str(length(idx)) 'behaviors.txt']))
```

### find intersection between the above behaviors and behaviors with COD > 0 in either AA or WA, and passed predictability permutation test

1. Accuracy metric: predictive COD

```matlab
% matlab
clear
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
KRR_dir = fullfile(proj_dir, 'trained_model', ...
    'split_948sub_MatchMtBehavior_rmAAotl', 'reg_AgeSexMtEducIcvInc_from_y_FC');
R_15 = CBIG_text2cell(fullfile(KRR_dir, 'lists', ['R_thres0.15_12behaviors.txt']));

COD_union = CBIG_text2cell(fullfile(KRR_dir, 'lists', ...
    'pCOD_union_pos_behaviors.txt'));
load(fullfile(proj_dir, 'mat', 'predictability', 'KRR', 'MatchMtBehavior', 'pCOD_reg_AgeSexMtEducIcvInc_from_y_FC.mat'))
tmp = intersect(COD_union, sig_behaviors, 'stable');
tmp = intersect(tmp, R_15, 'stable');
CBIG_cell2text(tmp, fullfile(KRR_dir, 'lists', 'pCOD_predictable_behaviors.txt'))
```

2. Accuracy metric: Pearson's correlation

```matlab
% matlab
clear
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
KRR_dir = fullfile(proj_dir, 'trained_model', ...
    'split_948sub_MatchMtBehavior_rmAAotl', 'reg_AgeSexMtEducIcvInc_from_y_FC');
R_15 = CBIG_text2cell(fullfile(KRR_dir, 'lists', ['R_thres0.15_12behaviors.txt']));

corr_union = CBIG_text2cell(fullfile(KRR_dir, 'lists', ...
    'corr_union_pos_behaviors.txt'));
load(fullfile(proj_dir, 'mat', 'predictability', 'KRR', 'MatchMtBehavior', 'corr_reg_AgeSexMtEducIcvInc_from_y_FC.mat'))
tmp = intersect(corr_union, sig_behaviors, 'stable');
tmp = intersect(tmp, R_15, 'stable');
CBIG_cell2text(tmp, fullfile(KRR_dir, 'lists', 'corr_predictable_behaviors.txt'))
```

## Statistical test for the accuracy difference between matched AA and WA

### Save the accuracies of only the predictable behavioral measures into a separate file

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
KRR_dir = fullfile(proj_dir, 'trained_model', ...
    'split_948sub_MatchMtBehavior_rmAAotl', 'reg_AgeSexMtEducIcvInc_from_y_FC');

% predictive COD
HCP_KRR_acc_AAvsWA_matchedBehavior( KRR_dir, 400, 10, fullfile(proj_dir, ...
    'mat', 'MatchMtBehavior', 'split_AA_rm_otl'), fullfile(proj_dir, 'mat', ...
    'MatchMtBehavior', 'split_WA_rmAAotl'), fullfile(proj_dir, 'mat', ...
    'MatchMtBehavior', 'split_WA_rmAAotl', 'usable_seeds'), fullfile(proj_dir, 'mat', ...
    'AA_WA_diff', 'KRR', 'MatchMtBehavior', 'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), ...
    [], fullfile(KRR_dir, 'lists', 'pCOD_predictable_behaviors.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_58.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt') )

% Pearson's correlation
HCP_KRR_acc_AAvsWA_matchedBehavior( KRR_dir, 400, 10, fullfile(proj_dir, ...
    'mat', 'MatchMtBehavior', 'split_AA_rm_otl'), fullfile(proj_dir, 'mat', ...
    'MatchMtBehavior', 'split_WA_rmAAotl'), fullfile(proj_dir, 'mat', ...
    'MatchMtBehavior', 'split_WA_rmAAotl', 'usable_seeds'), [], fullfile(proj_dir, 'mat', ...
    'AA_WA_diff', 'KRR', 'MatchMtBehavior', 'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), ...
    fullfile(KRR_dir, 'lists', 'corr_predictable_behaviors.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_58.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt') )
```

### Statistical test for the group difference in prediction accuracy

1. Accuracy metric: predictive COD

Predictable behaviors only:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_PermTest_AAvsWA(fullfile(proj_dir, 'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), ...
    fullfile(proj_dir, 'trained_model', 'split_948sub_MatchMtBehavior_rmAAotl', ...
    'reg_AgeSexMtEducIcvInc_from_y_FC', 'lists', 'pCOD_predictable_behaviors.txt'), 'predictive_COD', ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'sig_pCODdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'))
```

All 53 measures:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_PermTest_AAvsWA(fullfile(proj_dir, 'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'behaviors_55matchedMtBehavior.txt'), 'predictive_COD', ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'sig_pCODdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'))
```

2. Accuracy metric: Pearson's correlation

Predictable behaviors only:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_PermTest_AAvsWA(fullfile(proj_dir, 'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), ...
    fullfile(proj_dir, 'trained_model', 'split_948sub_MatchMtBehavior_rmAAotl', ...
    'reg_AgeSexMtEducIcvInc_from_y_FC', 'lists', 'corr_predictable_behaviors.txt'), 'corr', ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'sig_CORRdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'))
```

All 53 measures:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_PermTest_AAvsWA(fullfile(proj_dir, 'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'behaviors_55matchedMtBehavior.txt'), 'corr', ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'sig_CORRdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'))
```

## Plot the accuracy difference (and the significancy) between AA and WA

1. Accuracy metric: predictive COD

Predictable behaviors only:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_violin_acc_AAvsWA(fullfile(proj_dir, 'trained_model', 'split_948sub_MatchMtBehavior_rmAAotl', ...
    'reg_AgeSexMtEducIcvInc_from_y_FC', 'lists', 'pCOD_predictable_behaviors.txt'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), fullfile(proj_dir, ...
    'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'sig_pCODdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), 'predictive_COD', ...
    fullfile(proj_dir, 'figures', 'African_vs_white', ...
    'MatchMtBehavior_reg_AgeSexMtEducIcvInc_from_y_FC'), 'pCOD_sort_by_diff', ...
    fullfile(proj_dir, 'scripts', 'lists', 'behaviors_55matchedMtBehavior.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'colloquial_names_55_matchedMtBehavior.txt'))
```

All 53 measures:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_violin_acc_AAvsWA(fullfile(proj_dir, 'scripts', 'lists', 'behaviors_55matchedMtBehavior.txt'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), fullfile(proj_dir, ...
    'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'sig_pCODdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    'predictive_COD', fullfile(proj_dir, 'figures', 'African_vs_white', ...
    'MatchMtBehavior_reg_AgeSexMtEducIcvInc_from_y_FC'), 'pCOD_sort_by_diff_55matched', ...
    fullfile(proj_dir, 'scripts', 'lists', 'behaviors_55matchedMtBehavior.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'colloquial_names_55_matchedMtBehavior.txt'))
```

2. Accuracy metric: Pearson's correlation

Predictable behaviors only:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_violin_acc_AAvsWA(fullfile(proj_dir, 'trained_model', 'split_948sub_MatchMtBehavior_rmAAotl', ...
    'reg_AgeSexMtEducIcvInc_from_y_FC', 'lists', 'corr_predictable_behaviors.txt'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), fullfile(proj_dir, ...
    'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'sig_CORRdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), 'corr', ...
    fullfile(proj_dir, 'figures', 'African_vs_white', ...
    'MatchMtBehavior_reg_AgeSexMtEducIcvInc_from_y_FC'), 'corr_sort_by_diff', ...
    fullfile(proj_dir, 'scripts', 'lists', 'behaviors_55matchedMtBehavior.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'colloquial_names_55_matchedMtBehavior.txt'))
```

All 53 measures:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_violin_acc_AAvsWA(fullfile(proj_dir, 'scripts', 'lists', 'behaviors_55matchedMtBehavior.txt'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), fullfile(proj_dir, ...
    'mat', 'AA_WA_diff', 'KRR', 'MatchMtBehavior', ...
    'sig_CORRdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    'corr', fullfile(proj_dir, 'figures', 'African_vs_white', ...
    'MatchMtBehavior_reg_AgeSexMtEducIcvInc_from_y_FC'), 'corr_sort_by_diff_55matched', ...
    fullfile(proj_dir, 'scripts', 'lists', 'behaviors_55matchedMtBehavior.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'colloquial_names_55_matchedMtBehavior.txt'))
```
