This folder contains the scripts for data split and matching.

## Split African Americans into N folds

Related scripts: `HCP_split_AA_rm_hardtomatch`.

Example:

```matlab
for seed = 1:400
    HCP_split_AA_rm_hardtomatch('/your/full/subject_list.txt', '/your/hard/to/match/AA_list.txt', 10, ...
        seed, '/your/output.mat');
end
```

* The number of repetitions (400) was chosen higher than necessary (40) because not every repetition can find matched AA and WA pairs, especially for the behavioral measures that were hard to match.

## Match White Americans with each fold of selected AA

Related scripts: `HCP_match_WA_with_AAfolds.m`, `HCP_match_WA_with_AAfolds.sh`. The `.sh` file is the wrapper of the `.m` file. The wrapper script submits jobs to the CSC HPC, but external users can easily replace the job-submission line with their own command.

Example:
```bash
./HCP_match_WA_with_AAfolds.sh -max_seed 400  -subj_ls <your_subject_list>  -FD_txt <your_FD_file>  \
    -DV_txt <your_DVARS_file>  -bhvr_ls_rstr <your_restricted_behavioral_list>  -bhvr_ls_unrstr \
    <your_unrestricted_behavioral_list>  -AA_fold_stem <your_full_path_stem_of_AA_split> \
    -outdir <your_output_dir>  -outstem <your_relative_output_stem>  -rstr_csv <your_restricted_csv> \
    -unrstr_csv <your_unrestricted_csv>  -FS_csv <your_FreeSurfer_csv>
```

## Compare the demographic & behavioral distributions between selected AA and WA

Related script: `HCP_AA_WA_match_diff.m`.

Example:
```matlab
HCP_AA_WA_match_diff('/your/AA/splits/dir', '/your/selected/WA/dir', '/your/full/subject_list.txt', ...
    '/your/FD.txt', '/your/DVARS.txt', '/your/restricted_behavioral_list.txt', ...
    '/your/unrestricted_behavioral_list.txt', 400, '/your/output/statistics.mat', ...
    '/your/HCP_restricted.csv', '/your/HCP_unrestricted.csv', '/your/HCP_FreeSurfer.csv')
```

The function above generates a .mat file containing a variable that indicates which (seed, behavior) combination has no significant difference between AA and WA. Using this variable, the following function selects the 40 random splits which have matched AA and WA for each behavioral measure. The selected (seed, behavior) combinations are written in text lists per seed.

```matlab
HCP_select_matched_seeds('/your/AA/splits/dir', '/your/selected/WA/dir', ...
    '/your/AAvsWA/statistics.mat', 400, '/your/behavioral_list.txt', '/your/output/dir');
```

## Split all other subjects (unmatched AA, WA, subjects from other races/ethnicies)

Related scripts: `HCP_split_except_selectedAAWA.sh`, `HCP_split_except_selectedAAWA.m`.

```bash
HCP_split_except_selectedAAWA.sh -max_seed 400 -subj_ls <your_subject_list> -bhvr_ls \
    <your_behavioral_list> -AAsplit_stem <your_AA_split_dir>/split_seed -WAsplit_stem \
    <your_WA_split_dir>/split_seed -restricted_csv <your_HCP_restricted_csv> -outdir <your_output_dir>
```
