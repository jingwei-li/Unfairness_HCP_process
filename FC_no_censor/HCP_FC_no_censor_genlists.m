function HCP_FC_no_censor_genlists(outtxt, HCP_dir, subj_ls)

% HCP_FC_no_censor_genlists(outtxt, HCP_dir, subj_ls)
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
lines = {};
for s = 1:nsub
    curr_line = '';
    for ses = 1:2
        for r = 1:length(runs)
            curr_run = ['rfMRI_REST' num2str(ses) '_' runs{r}];
            fMRI_file = fullfile(HCP_dir, subjects{s}, 'MNINonLinear', 'Results', ...
                curr_run, 'postprocessing', 'MSM_reg_wbsgrayordinatecortex', ...
                [curr_run  '_Atlas_MSMAll_hp2000_clean_regress.dtseries.nii']);

            if(exist(fMRI_file, 'file'))
                curr_line = [curr_line ' ' fMRI_file];
            end
        end
    end
    if(~isempty(curr_line))
        lines = [lines; {curr_line}];
    end
end

CBIG_cell2text(lines, outtxt);
    
end