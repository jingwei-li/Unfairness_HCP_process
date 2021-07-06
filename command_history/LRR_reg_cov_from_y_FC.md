# Run linear ridge regression

```bash
# bash
cd ./LRR
./HCP_LRR_reg_cov_from_y_FC.sh -outdir \
/home/jingweil/storage/MyProject/fairAI/HCP_race/trained_model/\
LRR/948sub/reg_AgeSexMtEducIcvInc_fr_y_FC
```

## Plot Pearson's correlation accuracy across all test subjects (including AA, WA, other races)

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

1. Accuracy metric: predictive COD



2. Accuracy metric: Pearson's correlation