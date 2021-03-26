
Command to add paths in matlab:

```matlab
cd ~/storage/MyProject/fairAI/HCP_race/scripts/Unfairness_HCP_process
HCP_addpath
```

## Step 1: Split AA into 10 folds

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
for seed = 1:400
    HCP_split_AA_rm_hardtomatch(fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt'), ...
        fullfile(proj_dir, 'scripts', 'lists', 'hard_to_match_AA.txt'), 10, seed, ...
        fullfile(proj_dir, 'mat', 'split_AA_948_rm_outliers18', ['split_seed' num2str(seed) '.mat']));
end
```

## Step 2: Within each AA fold, find matched WA

```bash
ssh headnode
cd ~/storage/MyProject/fairAI/HCP_race/scripts/Unfairness_HCP_process/match_split
./HCP_match_WA_with_AAfolds.sh -max_seed 400 -outdir \
    /home/jingweil/storage/MyProject/fairAI/HCP_race/mat/split_WA_rm_AA_outliers18
```

## Step 3: Check if the difference in demographic & behavioral distributions between AA & WA were significant

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_AA_WA_match_diff(fullfile(proj_dir, 'mat', 'split_AA_948_rm_outliers18'), ...
    fullfile(proj_dir, 'mat', 'split_WA_rm_AA_outliers18'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'FD_948.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'FD_948.txt'), 'NONE', ...
    fullfile(proj_dir, 'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_58.txt'), 400, ...
    fullfile(proj_dir, 'mat', 'split_WA_rm_AA_outliers18', 'stats_ks_tt.mat'))
```

For each behavioral measures, the first 40 random splits with matched AA & WA were selected. The selected (seed, behavior) combinations were saved as text lists by the following script:

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_select_matched_seeds(fullfile(proj_dir, 'mat', 'split_AA_948_rm_outliers18'), ...
    fullfile(proj_dir, 'mat', 'split_WA_rm_AA_outliers18'), ...
    fullfile(proj_dir, 'mat', 'split_WA_rm_AA_outliers18', 'stats_ks_tt.mat'), 400, ...
    fullfile(proj_dir, 'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_58.txt'), ...
    fullfile(proj_dir, 'mat', 'split_WA_rm_AA_outliers18', 'usable_seeds');
```

## Step 4: split the remaining subjects

```bash
ssh headnode
cd ~/storage/MyProject/fairAI/HCP_race/scripts/Unfairness_HCP_process/match_split
./HCP_split_except_selectedAAWA.sh -max_seed 400 -outdir \
    /home/jingweil/storage/MyProject/fairAI/HCP_race/mat/split_except_AA_WA_rm_AA_outliers18
```


## Step N: compare variances of true behavioral scores between matched AA and WA (Levene's test)

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
HCP_pheno_var_AAvsWA_matched(fullfile(proj_dir, 'mat', 'split_AA_948_rm_outliers18'), ...
    fullfile(proj_dir, 'mat', 'split_WA_rm_AA_outliers18'), ...
    fullfile(proj_dir, 'mat', 'split_WA_rm_AA_outliers18', 'AAvsWA_var_Levene.mat'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_51_matched.txt'), ...
    fullfile(proj_dir, 'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_58.txt'), 400, ...
    fullfile(proj_dir, 'mat', 'split_WA_rm_AA_outliers18', 'usable_seeds'))
```

