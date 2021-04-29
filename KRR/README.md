This folder contains the wrapper scripts for applying kernel ridge regression to the HCP data.

The two top-level bash wrappers are `HCP_KRR_reg_cov_from_y.sh` and `HCP_KRR_reg_cov_from_FC.sh`, for regressing confounding variables from behavioral scores and from functional connectivities respectively.

For usage, taking `HCP_KRR_reg_cov_from_y.sh` as an example:

```bash
./HCP_KRR_reg_cov_from_y.sh -outdir '/your/output/dir/' -subj_ls '/your/subject/list.txt' \
    -FD_file '/your/FD.txt' -DV_file '/your/DVARS.txt' -RSFC_file '/your/RSFC.mat' \
    -cov_ls '/your/confounds/list.txt' -sub_fold_dir '/your/split/folds/dir/' \
    -use_seed_bhvr_dir '/your/selected/seed_behavior_comb/lists/dir'
```

Both bash scripts call the other scripts in this folder: `HCP_KRR_workflow_optimize_COD.sh`, `HCP_KRR.m`.