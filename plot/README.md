This folder contains the scripts to create figures.

## Plot histograms of matched AA and WA

Related script: `HCP_hist_matchedY_AA_WA.m`. See usage in the `README.md` of folder `../match_split`.

## Create whisker plots for comparing prediction accuracies between AA and WA

Top-level script: `HCP_whisker_acc_AAvsWA.m`. It call another two scripts: `HCP_whisker_2grp_indiv.m` and `HCP_whisker_2grp_avg.m`.

Example (matlab):

```matlab
HCP_whisker_acc_AAvsWA('/list/of/behavioral/measures/to/be/plotted.txt', ...
    '/AAvsWA/accuracy.mat', '/significancy/of/acuracy/difference.mat', ...
    'predictive_COD', '/output/figure/directory/', '<output_filestem>', ...
    '/ALL/matched/behavioral/list.txt', ...
    '/ALL/matched/behavioral/colloquial/names/list.txt')
```

`'/AAvsWA/accuracy.mat'` is the output file of `../AAvsWA/HCP_KRR_acc_AAvsWA_matchedBehavior.m`. `'/significancy/of/acuracy/difference.mat'` is the output file of `../AAvsWA/HCP_PermTest_AAvsWA.m`. `'predictive_COD'` can be replaced with `'corr'` if the accuracy of interest is Pearson's correlation. `'<output_filestem>'` represents a shared string used for all output filenames. 

