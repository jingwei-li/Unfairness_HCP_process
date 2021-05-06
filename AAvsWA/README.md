This folder contains the scripts used for comparing prediction accuracies between matched AA and WA.

## Calculate accuracy metrics for matched AA and WA separately

Related function: `HCP_KRR_pCOD_AAvsWA_matchedBehavior.m`. Example:

```matlab
HCP_KRR_pCOD_AAvsWA_matchedBehavior( '/your/kernel/regression/output/dir/', 400, 10, ...
   '/your/AA/splits/dir/', '/your/WA/splits/dir/', '/your/selected/seed_behavior_comb/lists/dir/', ...
   '/output/predictive_COD.mat', '/output/Pearson_correlation.mat', ...
   '/list/of/behaviors/with/enough/matched_AAandWA/txt', '/full/behavior/list.txt', ...
   '/full/subject/list.txt' )
```

