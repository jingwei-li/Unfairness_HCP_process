function HCP_create_fake_discard_frame_lists(outdir, HCP_dir, subj_ls)

% HCP_create_fake_discard_frame_lists(outdir, HCP_dir, subj_ls)
%
% 

if(~exist('HCP_dir', 'var') || isempty(HCP_dir))
    HCP_dir = '/mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/individuals';
end
if(~exist('subj_ls', 'var') || isempty(subj_ls))
    subj_ls = '/home/jingweil/storage/MyProject/fairAI/HCP_race/scripts/lists/subjects_wIncome_948.txt';
end

[subjects, nsub] = CBIG_text2cell(subj_ls);
runs = {'rfMRI_REST1_LR', 'rfMRI_REST1_RL', 'rfMRI_REST2_LR', 'rfMRI_REST2_RL'};

%% step1: pick the (subject, run) with shortest frames
N_keep = 1200;  % maximal length of timeseries
for s = 1:nsub
    for r = 1:4
        censor_ls = fullfile(HCP_dir, subjects{s}, 'MNINonLinear', 'Results', runs{r}, ...
            'postprocessing', 'MSM_reg_wbsgrayordinatecortex', 'scripts', [runs{r} '_FD0.2_DV75_censoring.txt']);
        fMRI_file = fullfile(HCP_dir, subjects{s}, 'MNINonLinear', 'Results', ...
            runs{r}, 'postprocessing', 'MSM_reg_wbsgrayordinatecortex', ...
            [runs{r}  '_Atlas_MSMAll_hp2000_clean_regress.dtseries.nii']);
        if(exist(fMRI_file, 'file'))
            outliers = dlmread(censor_ls);
            N_keep_new = length(find(outliers == 1));
            if(N_keep_new < N_keep)
                N_keep = N_keep_new;
                shortest_subj = subjects{s};
                shortest_run = runs{r};
            end
        end
    end
end

fprintf('Shortest subject: %s, run %s, with %d frames\n', shortest_subj, shortest_run, N_keep)

%% step2: truncate every run to be the same length as N_keep
for s = 1:nsub
    for r = 1:4
        censor_ls = fullfile(HCP_dir, subjects{s}, 'MNINonLinear', 'Results', runs{r}, ...
            'postprocessing', 'MSM_reg_wbsgrayordinatecortex', 'scripts', [runs{r} '_FD0.2_DV75_censoring.txt']);
        fMRI_file = fullfile(HCP_dir, subjects{s}, 'MNINonLinear', 'Results', ...
            runs{r}, 'postprocessing', 'MSM_reg_wbsgrayordinatecortex', ...
            [runs{r}  '_Atlas_MSMAll_hp2000_clean_regress.dtseries.nii']);
        if(exist(fMRI_file, 'file'))
            outliers = dlmread(censor_ls);
            N_keep_new = length(find(outliers == 1));
            outtxt = fullfile(outdir, subjects{s}, [runs{r} '_truncate_censoring.txt']);
            if(~exist(fullfile(outdir, subjects{s}), 'dir'))
                mkdir(fullfile(outdir, subjects{s}))
            end
            if(N_keep_new > N_keep)
                idx = find(outliers==1);
                len_diff = N_keep_new - N_keep;   % how many frames need to be truncated
                fprintf('%s %s, N_keep: %d, N_keep_new: %d, trunctate from: %d\n', ...
                    subjects{s}, runs{r}, N_keep, N_keep_new, idx(length(idx)-len_diff+1))
                outliers_new = outliers;
                outliers_new(idx( (length(idx)-len_diff+1):end )) = 0;
                dlmwrite(outtxt, outliers_new);
            else
                system(sprintf('rsync -avz %s %s', censor_ls, outtxt));
            end
        end
    end
end
    
end