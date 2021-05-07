This folder contains the wrapper scripts for applying kernel ridge regression to the HCP data.

## Run kernel ridge regression

The two top-level bash wrappers are `HCP_KRR_reg_cov_from_y.sh` and `HCP_KRR_reg_cov_from_FC.sh`, for regressing confounding variables from behavioral scores and from functional connectivities respectively.

For usage, taking `HCP_KRR_reg_cov_from_y.sh` as an example (bash):

```bash
./HCP_KRR_reg_cov_from_y.sh -outdir '/your/output/dir/' -subj_ls '/your/subject/list.txt' \
    -FD_file '/your/FD.txt' -DV_file '/your/DVARS.txt' -RSFC_file '/your/RSFC.mat' \
    -cov_ls '/your/confounds/list.txt' -sub_fold_dir '/your/split/folds/dir/' \
    -use_seed_bhvr_dir '/your/selected/seed_behavior_comb/lists/dir'
```

Both bash scripts call other scripts in this folder: `HCP_KRR_workflow_optimize_COD.sh`, `HCP_KRR.m`.

## Test if overall accuracies were significantly above chance

Use multi-level block permutation test to check which behavioral measures could achieve higher-than-chance prediction accuracies across all test subjects (including all ethnicies/races, not only AA and WA).

Example (bash):

```bash
./HCP_predictable_behavior.sh -KRR_dir '/your/KRR/output/dir/' -maxKRR_iter 400 \
    -test_metric predictive_COD -intrim_csv '/intermediate/block_design.csv' \
    -outmat '/your/output.mat' -rstr_csv '/your/HCP_restricted.csv' \
    -subj_ls '/your/subject/list.txt' -bhvr_ls '/your/matched/behavioral/list.txt' \
    -colloq_ls '/your/colloquial/names/list.txt'
```