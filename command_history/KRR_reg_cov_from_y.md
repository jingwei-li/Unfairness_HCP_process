## Run kernel ridge regression

```bash
# bash
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
# bash
cd ../KRR
proj_dir='/home/jingweil/storage/MyProject/fairAI/HCP_race'
./HCP_KRR_predictable_behavior.sh -KRR_dir \
    $proj_dir/trained_model/split_948sub_AA_matchedWA_rm_AA_outliers18/outputs/l2_0_20_opt_pCOD_reg_AgeSexMtEducIcvInc_from_y \
    -test_metric predictive_COD -intrim_csv $proj_dir/scripts/lists/Multi-level_block_perm_948.csv \
    -outmat $proj_dir/mat/predictability/pCOD_reg_AgeSexMtEducIcvInc_from_y.mat
```

2. Accuracy metric: Pearson's correlation

```bash
# bash
cd ../KRR
proj_dir='/home/jingweil/storage/MyProject/fairAI/HCP_race'
./HCP_KRR_predictable_behavior.sh -KRR_dir \
    $proj_dir/trained_model/split_948sub_AA_matchedWA_rm_AA_outliers18/outputs/l2_0_20_opt_pCOD_reg_AgeSexMtEducIcvInc_from_y \
    -test_metric corr -intrim_csv $proj_dir/scripts/lists/Multi-level_block_perm_948.csv \
    -outmat $proj_dir/mat/predictability/corr_reg_AgeSexMtEducIcvInc_from_y.mat
```

## Calculate predictive COD and Pearson's correlation for matched AA and WA separately

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_KRR_acc_AAvsWA_matchedBehavior( fullfile(proj_dir, 'trained_model', ...
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

## Select behavioral measures with above-chance overall prediction accuracy, and with positive accuracy in either matched AA or matched WA

### Get behavioral measures whole correlation accuracy across all subjects was higher than 0.15

```matlab
% matlab
clear
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
model_dir = fullfile(proj_dir, 'trained_model', ...
    'split_948sub_AA_matchedWA_rm_AA_outliers18', 'outputs', ...
    'l2_0_20_opt_pCOD_reg_AgeSexMtEducIcvInc_from_y');
[bhvr_nm, nbhvr] = CBIG_text2cell(fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'));
acc = zeros(nbhvr, 40);
for b = 1:nbhvr
    c = 1;
    for i = 1:234
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
    'split_948sub_AA_matchedWA_rm_AA_outliers18', 'outputs', ...
    'l2_0_20_opt_pCOD_reg_AgeSexMtEducIcvInc_from_y');
R_15 = CBIG_text2cell(fullfile(KRR_dir, 'lists', ['R_thres0.15_9behaviors.txt']));

COD_union = CBIG_text2cell(fullfile(KRR_dir, 'lists', ...
    'COD_union_positive_behaviors.txt'));
load(fullfile(proj_dir, 'mat', 'predictability', 'pCOD_reg_AgeSexMtEducIcvInc_from_y.mat'))
tmp = intersect(COD_union, sig_behaviors, 'stable');
tmp = intersect(tmp, R_15, 'stable');
CBIG_cell2text(tmp, fullfile(KRR_dir, 'lists', 'COD_predictable_behaviors.txt'))
```

2. Accuracy metric: Pearson's correlation

```matlab
% matlab
clear
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
KRR_dir = fullfile(proj_dir, 'trained_model', ...
    'split_948sub_AA_matchedWA_rm_AA_outliers18', 'outputs', ...
    'l2_0_20_opt_pCOD_reg_AgeSexMtEducIcvInc_from_y');
R_15 = CBIG_text2cell(fullfile(KRR_dir, 'lists', ['R_thres0.15_9behaviors.txt']));

corr_union = CBIG_text2cell(fullfile(KRR_dir, 'lists', ...
    'corr_union_positive_behaviors.txt'));
load(fullfile(proj_dir, 'mat', 'predictability', 'corr_reg_AgeSexMtEducIcvInc_from_y.mat'))
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
    'split_948sub_AA_matchedWA_rm_AA_outliers18', 'outputs', ...
    'l2_0_20_opt_pCOD_reg_AgeSexMtEducIcvInc_from_y');

% predictive COD
HCP_KRR_acc_AAvsWA_matchedBehavior( KRR_dir, 400, 10, fullfile(proj_dir, ...
    'mat', 'split_AA_948_rm_outliers18'), fullfile(proj_dir, 'mat', ...
    'split_WA_rm_AA_outliers18'), fullfile(proj_dir, 'mat', ...
    'split_WA_rm_AA_outliers18', 'usable_seeds'), fullfile(proj_dir, 'mat', ...
    'AA_WA_diff', 'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_predictable.mat'), ...
    [], fullfile(KRR_dir, 'lists', 'COD_predictable_behaviors.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_58.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt') )

% Pearson's correlation
HCP_KRR_acc_AAvsWA_matchedBehavior( KRR_dir, 400, 10, fullfile(proj_dir, ...
    'mat', 'split_AA_948_rm_outliers18'), fullfile(proj_dir, 'mat', ...
    'split_WA_rm_AA_outliers18'), fullfile(proj_dir, 'mat', ...
    'split_WA_rm_AA_outliers18', 'usable_seeds'), [], fullfile(proj_dir, 'mat', ...
    'AA_WA_diff', 'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_predictable.mat'), ...
    fullfile(KRR_dir, 'lists', 'corr_predictable_behaviors.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_58.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt') )
```

### Statistical test for the group difference in prediction accuracy

1. Accuracy metric: predictive COD

```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_PermTest_AAvsWA(fullfile(proj_dir, 'mat', 'AA_WA_diff', ...
    'pCOD_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_predictable.mat'), fullfile(proj_dir, ...
    'trained_model', 'split_948sub_AA_matchedWA_rm_AA_outliers18', 'outputs', ...
    'l2_0_20_opt_pCOD_reg_AgeSexMtEducIcvInc_from_y', 'lists', ...
    'COD_predictable_behaviors.txt'), 'predictive_COD', fullfile(proj_dir, 'mat', ...
    'AA_WA_diff', 'sig_pCODdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_predictable.mat'))
```

2. Accuracy metric: Pearson's correlation
 
```matlab
% matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_PermTest_AAvsWA(fullfile(proj_dir, 'mat', 'AA_WA_diff', ...
    'corr_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_predictable.mat'), fullfile(proj_dir, ...
    'trained_model', 'split_948sub_AA_matchedWA_rm_AA_outliers18', 'outputs', ...
    'l2_0_20_opt_pCOD_reg_AgeSexMtEducIcvInc_from_y', 'lists', ...
    'corr_predictable_behaviors.txt'), 'corr', fullfile(proj_dir, 'mat', ...
    'AA_WA_diff', 'sig_CORRdiff_AAvsWA_reg_AgeSexMtEducIcvInc_from_y_predictable.mat'))
```