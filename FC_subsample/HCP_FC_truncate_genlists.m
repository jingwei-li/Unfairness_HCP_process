function HCP_FC_truncate_genlists(out_fMRI_ls, out_censor_ls, fake_censor_dir, HCP_dir, subj_ls)

% HCP_FC_truncate_genlists(out_fMRI_ls, out_censor_ls, fake_censor_dir, HCP_dir, subj_ls)
%
% 

if(~exist('HCP_dir', 'var') || isempty(HCP_dir))
    HCP_dir = '/mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/individuals';
end
if(~exist('subj_ls', 'var') || isempty(subj_ls))
    subj_ls = '/home/jingweil/storage/MyProject/fairAI/HCP_race/scripts/lists/subjects_wIncome_948.txt';
end

[subjects, nsub] = CBIG_text2cell(subj_ls);

runs = {'LR', 'RL'};
lines_censor = {};
lines_fMRI = {};
for s = 1:nsub
    curr_line_censor = '';
    curr_line_fMRI = '';
    for ses = 1:2
        for r = 1:length(runs)
            curr_run = ['rfMRI_REST' num2str(ses) '_' runs{r}];
            fMRI_file = fullfile(HCP_dir, subjects{s}, 'MNINonLinear', 'Results', ...
                curr_run, 'postprocessing', 'MSM_reg_wbsgrayordinatecortex', ...
                [curr_run  '_Atlas_MSMAll_hp2000_clean_regress.dtseries.nii']);
            censor_ls = fullfile(fake_censor_dir, subjects{s}, [curr_run  '_truncate_censoring.txt']);
            if(exist(fMRI_file, 'file'))
                curr_line_fMRI = [curr_line_fMRI ' ' fMRI_file];
                curr_line_censor = [curr_line_censor ' ' censor_ls];
            end
        end
    end
    if(~isempty(curr_line_fMRI))
        lines_censor = [lines_censor; {curr_line_censor}];
        lines_fMRI = [lines_fMRI; {curr_line_fMRI}];
    end
end

CBIG_cell2text(lines_fMRI, out_fMRI_ls);
CBIG_cell2text(lines_censor, out_censor_ls);
    
end