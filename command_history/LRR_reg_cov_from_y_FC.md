# Run linear ridge regression

```bash
# bash
cd ./LRR
./HCP_LRR_reg_cov_from_y_FC.sh -outdir \
/home/jingweil/storage/MyProject/fairAI/HCP_race/trained_model/\
LRR/948sub/reg_AgeSexMtEducIcvInc_fr_y_FC
```

## Plot Pearson's correlation accuracy across all test subjects (including AA, WA, other races)

Metric: Pearson's correlation

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_violin_LRR_acc_allsubj_matchedBehav(fullfile(proj_dir, 'trained_model', 'LRR', '948sub', 'reg_AgeSexMtEducIcvInc_fr_y_FC'), 400, ...
    'corr', fullfile(proj_dir, 'figures', 'African_vs_white', ...
    'LRR_948_rm_otl18_reg_AgeSexMtEducIcvInc_from_y_FC'), 'corr_allsubj', ...
    fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'colloquial_names_51_matched.txt'))
```

## Test which behavioral measures were predictable

Use multi-level block permutation test to check which behavioral measures could achieve higher-than-chance prediction accuracies across all test subjects (including all ethnicies/races, not only AA and WA).

### Step 1. generate multi-leel block permutations

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_LRR_predictable_behavior_step1(...
    fullfile(proj_dir, 'trained_model', 'LRR', '948sub', 'reg_AgeSexMtEducIcvInc_fr_y_FC'), 1000, ...
    fullfile(proj_dir, 'scripts', 'lists', 'Multi-level_block_perm_948.csv'), ...
    '/mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/scripts/restricted_hcp_data/RESTRICTED_jingweili_4_12_2017_1200subjects_fill_empty_zygosityGT_by_zygositySR.csv', ...
    fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt'))
```

### Step 2. repeat LRR with permuted y for each behavior

```bash
../LRR/HCP_LRR_predictable_behavior_step2.sh -Nperm 1000
```

### Step 3. compute p values

1. Accuracy metric: predictive COD

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_LRR_predictable_behavior_step3(...
    fullfile(proj_dir, 'trained_model', 'LRR', '948sub', 'reg_AgeSexMtEducIcvInc_fr_y_FC'), 400, 'predictive_COD', ...
    fullfile(proj_dir, 'mat', 'predictability', 'LRR', 'pCOD_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'colloquial_names_51_matched.txt'), 1000)
```

2. Accuracy metric: Pearson's correlation

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_LRR_predictable_behavior_step3(...
    fullfile(proj_dir, 'trained_model', 'LRR', '948sub', 'reg_AgeSexMtEducIcvInc_fr_y_FC'), 400, 'corr', ...
    fullfile(proj_dir, 'mat', 'predictability', 'LRR', 'corr_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'colloquial_names_51_matched.txt'), 1000)
```

## Calculate predictive COD and Pearson's correlation for matched AA and WA separately

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_LRR_acc_AAvsWA_matchedBehavior( ...
    fullfile(proj_dir, 'trained_model', 'LRR', '948sub', 'reg_AgeSexMtEducIcvInc_fr_y_FC'), 400, 10, ...
    fullfile(proj_dir, 'mat', 'split_AA_948_rm_outliers18'), ...
    fullfile(proj_dir, 'mat', 'split_WA_rm_AA_outliers18'), ...
    fullfile(proj_dir, 'mat', 'split_WA_rm_AA_outliers18', 'usable_seeds'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR', 'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR',     'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    fullfile(proj_dir, 'scripts', 'lists',     'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_58.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt') )
```

## Select behavioral measures with above-chance overall prediction accuracy, and with positive accuracy in either matched AA or matched WA

### Get behavioral measures whole correlation accuracy across all subjects was higher than 0.15

```matlab
% matlab
clear
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
model_dir = fullfile(proj_dir, 'trained_model', ...
    'LRR', '948sub', 'reg_AgeSexMtEducIcvInc_fr_y_FC');
[bhvr_nm, nbhvr] = CBIG_text2cell(fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'));
acc = zeros(nbhvr, 40);
for b = 1:nbhvr
    c = 1;
    for i = 1:400
        opt_fname = fullfile(model_dir, ['randseed_' num2str(i)], bhvr_nm{b}, 'results', 'optimal_acc', [bhvr_nm{b} '.mat']);
        if(~exist(opt_fname, 'file')); continue; end;

        opt = load(opt_fname);
        Nfolds = length(opt.optimal_statistics);
        curr_acc = zeros(Nfolds, 1);
        for f = 1:Nfolds
            curr_acc(f) = opt.optimal_statistics{f}.corr;
        end
        acc(b,c) = mean(curr_acc, 1);
        c = c+1;
    end
end
idx = find(mean(acc,2)>0.1);
CBIG_cell2text(bhvr_nm(idx), fullfile(model_dir, 'lists', ...
    ['R_thres0.1_' num2str(length(idx)) 'behaviors.txt']))
```

### find intersection between the above behaviors and behaviors with COD > 0 in either AA or WA, and passed predictability permutation test

1. Accuracy metric: predictive COD

```matlab
% matlab
clear
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
LRR_dir = fullfile(proj_dir, 'trained_model', ...
    'LRR', '948sub', 'reg_AgeSexMtEducIcvInc_fr_y_FC');
R_10 = CBIG_text2cell(fullfile(LRR_dir, 'lists', ['R_thres0.1_8behaviors.txt'])); 

COD_union = CBIG_text2cell(fullfile(LRR_dir, 'lists', ...
    'pCOD_union_pos_behaviors.txt'));
load(fullfile(proj_dir, 'mat', 'predictability', 'LRR', 'pCOD_reg_AgeSexMtEducIcvInc_from_y_FC.mat'))
tmp = intersect(COD_union, sig_behaviors, 'stable');
tmp = intersect(tmp, R_10, 'stable');
CBIG_cell2text(tmp, fullfile(LRR_dir, 'lists', 'pCOD_predictable_behaviors.txt'))
```

2. Accuracy metric: Pearson's correlation

```matlab
% matlab
clear
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
LRR_dir = fullfile(proj_dir, 'trained_model', ...
    'LRR', '948sub', 'reg_AgeSexMtEducIcvInc_fr_y_FC');
R_10 = CBIG_text2cell(fullfile(LRR_dir, 'lists', ['R_thres0.1_8behaviors.txt']));

corr_union = CBIG_text2cell(fullfile(LRR_dir, 'lists', ...
    'corr_union_pos_behaviors.txt'));
load(fullfile(proj_dir, 'mat', 'predictability', 'LRR', 'corr_reg_AgeSexMtEducIcvInc_from_y_FC.mat'))
tmp = intersect(corr_union, sig_behaviors, 'stable');
tmp = intersect(tmp, R_10, 'stable');
CBIG_cell2text(tmp, fullfile(LRR_dir, 'lists', 'corr_predictable_behaviors.txt'))
```

## Statistical test for the accuracy difference between matched AA and WA

### Save the accuracies of only the predictable behavioral measures into a separate file

#### AA vs WA matched for all confounds

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
LRR_dir = fullfile(proj_dir, 'trained_model', ...
    'LRR', '948sub', 'reg_AgeSexMtEducIcvInc_fr_y_FC');

% predictive COD
HCP_LRR_acc_AAvsWA_matchedBehavior( LRR_dir, 400, 10, fullfile(proj_dir, ...
    'mat', 'split_AA_948_rm_outliers18'), fullfile(proj_dir, 'mat', ...
    'split_WA_rm_AA_outliers18'), fullfile(proj_dir, 'mat', ...
    'split_WA_rm_AA_outliers18', 'usable_seeds'), fullfile(proj_dir, 'mat', ...
    'AA_WA_diff', 'LRR', 'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), ...
    [], fullfile(LRR_dir, 'lists', 'pCOD_predictable_behaviors.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_58.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt') )

% Pearson's correlation
HCP_LRR_acc_AAvsWA_matchedBehavior( LRR_dir, 400, 10, fullfile(proj_dir, ...
    'mat', 'split_AA_948_rm_outliers18'), fullfile(proj_dir, 'mat', ...
    'split_WA_rm_AA_outliers18'), fullfile(proj_dir, 'mat', ...
    'split_WA_rm_AA_outliers18', 'usable_seeds'), [], fullfile(proj_dir, 'mat', ...
    'AA_WA_diff', 'LRR', 'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), ...
    fullfile(LRR_dir, 'lists', 'corr_predictable_behaviors.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_58.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt') )
```

### Statistical test for the group difference in prediction accuracy

#### AA vs WA matched for all confounds

1. Accuracy metric: predictive COD

Predictable behaviors only:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_PermTest_AAvsWA(fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR', ...
    'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), ...
    fullfile(proj_dir, 'trained_model', ...
    'LRR', '948sub', 'reg_AgeSexMtEducIcvInc_fr_y_FC', 'lists', ...
    'pCOD_predictable_behaviors.txt'), 'predictive_COD', fullfile(proj_dir, ...
    'mat', 'AA_WA_diff', 'LRR', 'sig_pCODdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'))
```

All 51 measures:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_PermTest_AAvsWA(fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR', ...
    'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), 'predictive_COD', fullfile(proj_dir, ...
    'mat', 'AA_WA_diff', 'LRR', 'sig_pCODdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'))
```

2. Accuracy metric: Pearson's correlation

Predictable behaviors only:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_PermTest_AAvsWA(fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR', ...
    'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), ...
    fullfile(proj_dir, 'trained_model', ...
    'LRR', '948sub', 'reg_AgeSexMtEducIcvInc_fr_y_FC', 'lists', ...
    'corr_predictable_behaviors.txt'), 'corr', fullfile(proj_dir, 'mat', ...
    'AA_WA_diff', 'LRR', 'sig_CORRdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'))
```

All 51 measures:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_PermTest_AAvsWA(fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR', ...
    'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), 'corr', fullfile(proj_dir, ...
    'mat', 'AA_WA_diff', 'LRR', 'sig_CORRdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'))
```

## Plot the accuracy difference (and the significancy) between AA and WA

#### AA vs WA matched for all confounds

1. Accuracy metric: predictive COD

Only plot predictable behavioral measures:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_violin_acc_withnull_AAvsWA(...
    fullfile(proj_dir, 'trained_model', 'LRR', '948sub', 'reg_AgeSexMtEducIcvInc_fr_y_FC', 'lists', 'pCOD_predictable_behaviors.txt'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR', 'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR', 'sig_pCODdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), ...
    'predictive_COD', fullfile(proj_dir, 'figures', 'African_vs_white', ...
    'LRR_948_rm_otl18_reg_AgeSexMtEducIcvInc_from_y_FC'), ...
    'pCOD_sort_by_diff', fullfile(proj_dir, 'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'colloquial_names_51_matched.txt'))
```

All 51 measures:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_violin_acc_withnull_AAvsWA(...
    fullfile(proj_dir, 'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR', 'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR',     'sig_pCODdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    'predictive_COD', fullfile(proj_dir, 'figures', 'African_vs_white',     'LRR_948_rm_otl18_reg_AgeSexMtEducIcvInc_from_y_FC'), ...
    'pCOD_sort_by_diff_51matched', fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'colloquial_names_51_matched.txt'))
```

2. Accuracy metric: Pearson's correlation

Only plot predictable behavioral measures:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_violin_acc_withnull_AAvsWA(...
    fullfile(proj_dir, 'trained_model', 'LRR', '948sub', 'reg_AgeSexMtEducIcvInc_fr_y_FC', 'lists', 'corr_predictable_behaviors.txt'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR',     'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR',     'sig_CORRdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC_predictable.mat'), ...
    'corr', fullfile(proj_dir, 'figures', 'African_vs_white', ...
    'LRR_948_rm_otl18_reg_AgeSexMtEducIcvInc_from_y_FC'), ...
    'corr_sort_by_diff', fullfile(proj_dir, 'scripts', 'lists',     'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'colloquial_names_51_matched.txt'))
```

All 51 measures:

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_violin_acc_withnull_AAvsWA(...
    fullfile(proj_dir, 'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR', 'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR',     'sig_CORRdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    'corr', fullfile(proj_dir, 'figures', 'African_vs_white',     'LRR_948_rm_otl18_reg_AgeSexMtEducIcvInc_from_y_FC'), ...
    'corr_sort_by_diff_51matched', fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'colloquial_names_51_matched.txt'))
```

## Plot "predicted - original behavioral score"

### AA vs WA matched for all confounds

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';

% Are AA-WA differences in terms of "predicted - orginal score" significant?
HCP_PermTest_predVStrue_AAvsWA(fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR', ...
    'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), fullfile(proj_dir, 'mat', ...
    'AA_WA_diff', 'LRR', 'sig_predVStrue_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'))

% Plot
HCP_KRR_violin_predVStrue(fullfile(proj_dir, 'figures', 'African_vs_white', ...
    'LRR_948_rm_otl18_reg_AgeSexMtEducIcvInc_from_y_FC'), 'predVStrue_51matched', fullfile(proj_dir, ...
    'mat', 'AA_WA_diff', 'LRR', 'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), ...
    fullfile(proj_dir, 'mat', 'AA_WA_diff', 'LRR', ...
    'sig_predVStrue_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_FC.mat'), [])
```


## Create table/figure for optimal parameters

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_LRR_collect_opt_param(fullfile(proj_dir, 'trained_model', ...
    'LRR', '948sub', 'reg_AgeSexMtEducIcvInc_fr_y_FC'), 400, ...
    fullfile(proj_dir, 'mat', 'split_WA_rm_AA_outliers18', 'usable_seeds'), [])
```