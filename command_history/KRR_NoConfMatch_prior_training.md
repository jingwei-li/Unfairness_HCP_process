## Split subjects

### Split AA

```matlab
proj_dir = '/home/jingweil/storage/MyProject/fairAI/HCP_race';
for seed = 1:400
HCP_split_AA_rm_hardtomatch(fullfile(proj_dir, 'scripts', 'lists', 'subjects_wIncome_948.txt'), 'none', 10, seed, fullfile(proj_dir, 'mat', 'only_match_behavior', 'split_AA', ['split_seed' num2str(seed)]), '/mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/scripts/restricted_hcp_data/RESTRICTED_jingweili_4_12_2017_1200subjects_fill_empty_zygosityGT_by_zygositySR.csv')
end
```

### Within each AA fold, find matched WA

```bash
# bash
ssh headnode
cd ~/storage/MyProject/fairAI/HCP_race/scripts/Unfairness_HCP_process/match_split
./HCP_match_WA_with_AAfolds.sh -max_seed 400 -outdir \
    /home/jingweil/storage/MyProject/fairAI/HCP_race/mat/only_match_behavior/split_WA \
    -AA_fold_stem /home/jingweil/storage/MyProject/fairAI/HCP_race/mat/only_match_behavior/split_AA/split_seed -match_ls NONE
```