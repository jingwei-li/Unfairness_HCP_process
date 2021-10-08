function HCP_KRR_learned_BWAS(model_dir, max_seed, outmat, fig_dir, full_FC, bhvr_ls, colloq_ls)

% HCP_KRR_learned_BWAS(model_dir, max_seed, outmat, fig_dir, full_FC, bhvr_ls, colloq_ls)
% 
% Calculate the model-learned brain-behavior association.
%
% Input:
%   - model_dir
%     Full path to the directory of KRR models. It contains a subfolder for each random
%     seed, and each see subfolder contains subfolders for each behavior.
%   - max_seed
%     Maximal number of trial seeds for data split. Some seed+behavior combinations 
%     are not used for KRR because the matching was not successful.
%   - outmat
%     Absolute name of output .mat file.
%   - fig_dir
%     Absolute path to the output figure directory.
%   - full_FC (optional)
%     Absolute path to the RSFC file. Default:
%     $HOME/storage/MyProject/fairAI/HCP_race/mat/RSFC_948.mat
%   - bhvr_ls (optional)
%     Full path of the behavior list. Default:
%     $HOME/storage/MyProject/fairAI/HCP_race/scripts/lists/Cognitive_Personality_Task_Social_Emotion_58.txt
%   - colloq_ls (optional)
%     Full path of the colloquial name list. Default:
%     $HOME/storage/MyProject/fairAI/HCP_race/scripts/lists/colloquial_names_58.txt
%


%% default input arguments
proj_dir = fullfile(getenv('HOME'), 'storage', 'MyProject', 'fairAI', 'HCP_race');
if(~exist('full_FC', 'var') || isempty(full_FC))
    full_FC = fullfile(proj_dir, 'mat', 'RSFC_948.mat');
end
load(full_FC)

if(~exist('bhvr_ls', 'var') || isempty(bhvr_ls))
    bhvr_ls = fullfile(proj_dir, 'scripts', 'lists', ...
        'Cognitive_Personality_Task_Social_Emotion_58.txt');
end
[bhvr_nm, nbhvr] = CBIG_text2cell(bhvr_ls);

if(~exist('colloq_ls', 'var') || isempty(colloq_ls))
    colloq_ls = fullfile(proj_dir, 'scripts', 'lists', ...
        'colloquial_names_58.txt');
end
[colloq_nm, ncolloq] = CBIG_text2cell(colloq_ls);

assert(nbhvr == ncolloq, 'Number of behaviors and number of colloquial names not equal.')

%% collect FC and behavior for the training set of each fold split, and compute covariance
for b = 1:nbhvr
    scount = 0;
    for seed = 1:max_seed
        KRR_dir = fullfile(model_dir, ['randseed_' num2str(seed)], bhvr_nm{b});
        if(exist(KRR_dir, 'dir'))
            scount = scount + 1;

            load(fullfile(KRR_dir, ['no_relative_10_fold_sub_list_' bhvr_nm{b} '.mat']))

            curr_cov = [];
            for f = 1:length(sub_fold)
                training = load(fullfile(KRR_dir, 'test_cv', ['fold_' num2str(f)], ...
                    ['opt_training_set_' bhvr_nm{b}, '.mat']));
                FC = corr_mat(:,:, sub_fold(f).fold_index==0);
                curr_y = training.y_p{1};
                curr_cov = cat(3, curr_cov, HCP_cov_FC_behavior(FC, curr_y));
            end
            learned_cov(:, :, scount, b) = mean(curr_cov, 3);
        end
    end
end
avg_learned_cov = squeeze(mean(learned_cov, 3));
%% save
outdir = fileparts(outmat);
mkdir(outdir)
save(outmat, 'learned_cov', 'avg_learned_cov', '-v7.3')

%% Plot
if(~isempty(fig_dir) && ~strcmpi(fig_dir, 'none'))
    mkdir(fig_dir)
    for b = 1:nbhvr
        if(all(avg_learned_cov(:,:,b) == 0))
            continue
        end
        CBIG_Plot_Schaefer400_17Networks19SubcorRearrCorrMat_WhiteGrid(avg_learned_cov(1:200, 1:200, b), ...
            avg_learned_cov(1:200, 201:400, b), avg_learned_cov(201:400, 201:400, b), ...
            avg_learned_cov(1:200, 401:end, b), avg_learned_cov(201:400, 401:end, b), ...
            avg_learned_cov(401:end, 401:end, b), [min(min(avg_learned_cov(:,:,b)))  ...
            max(max(avg_learned_cov(:,:,b)))], fullfile(fig_dir, colloq_nm{b}))
    end
end
    

end