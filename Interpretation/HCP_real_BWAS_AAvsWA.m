function HCP_real_BWAS_AAvsWA(model_dir, splitAA_dir, splitWA_dir, max_seed, outmat, ...
    fig_dir, full_FC, bhvr_ls, colloq_ls)


%% Default input arguments
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
bhvr_58 = CBIG_text2cell(fullfile(proj_dir, 'scripts', 'lists', ...
    'Cognitive_Personality_Task_Social_Emotion_58.txt'));

if(~exist('colloq_ls', 'var') || isempty(colloq_ls))
    colloq_ls = fullfile(proj_dir, 'scripts', 'lists', ...
        'colloquial_names_58.txt');
end
[colloq_nm, ncolloq] = CBIG_text2cell(colloq_ls);

assert(nbhvr == ncolloq, 'Number of behaviors and number of colloquial names not equal.')

%% colloct y and FC for each fold, each behavior, and compute 
% cov[FC, raw behavior] for test AA and WA separately
for b = 1:nbhvr
    scount = 0;
    bidx = find(strcmp(bhvr_58, bhvr_nm{b}));
    for seed = 1:max_seed
        KRR_dir = fullfile(model_dir, ['randseed_' num2str(seed)], bhvr_nm{b});
        if(exist(KRR_dir, 'dir'))
            scount = scount + 1;
            load(fullfile(KRR_dir, ['no_relative_10_fold_sub_list_' bhvr_nm{b} '.mat']))
            load(fullfile(splitAA_dir, ['split_seed' num2str(seed) '.mat']))
            load(fullfile(splitWA_dir, ['split_seed' num2str(seed) '.mat']))

            curr_covAA = [];   curr_covWA = [];
            for f = 1:length(sub_fold)
                y = load(fullfile(KRR_dir, 'y', ['fold_' num2str(f)], ['y_regress_' bhvr_nm{b} '.mat']));
                y = y.y_resid;

                test_idx = find(sub_fold(f).fold_index==1);
                [~, AAidx] = intersect(sub_fold(f).subject_list, Afr_fold.sub_perfold{f}, 'stable');
                [~, WAidx] = intersect(sub_fold(f).subject_list, best_assign{bidx}{f}, 'stable');

                FC_AA = corr_mat(:,:, test_idx(AAidx));
                y_AA = y(test_idx(AAidx));
                FC_WA = corr_mat(:,:, test_idx(WAidx));
                y_WA = y(test_idx(WAidx));

                curr_covAA = cat(3, curr_covAA, HCP_cov_FC_behavior(FC_AA, y_AA));
                curr_covWA = cat(3, curr_covWA, HCP_cov_FC_behavior(FC_WA, y_WA));
            end
            cov_testAA(:,:,scount,b) = mean(curr_covAA, 3);
            cov_testWA(:,:,scount,b) = mean(curr_covWA, 3);
        end
    end
end
avg_cov_testAA = squeeze(mean(cov_testAA, 3));
avg_cov_testWA = squeeze(mean(cov_testWA, 3));
%% save
outdir = fileparts(outmat);
mkdir(outdir)
save(outmat, 'cov_testAA', 'avg_cov_testAA', 'cov_testWA', 'avg_cov_testWA', '-v7.3')

%% plot
if(~isempty(fig_dir) && ~strcmpi(fig_dir, 'none'))
    mkdir(fig_dir)
    for b = 1:nbhvr
        if(all(avg_cov_testAA(:,:,b) == 0))
            continue
        end

        CBIG_Plot_Schaefer400_17Networks19SubcorRearrCorrMat_WhiteGrid(avg_cov_testAA(1:200, 1:200, b), ...
            avg_cov_testAA(1:200, 201:400, b), avg_cov_testAA(201:400, 201:400, b), ...
            avg_cov_testAA(1:200, 401:end, b), avg_cov_testAA(201:400, 401:end, b), ...
            avg_cov_testAA(401:end, 401:end, b), 0.75*[min(min(min(avg_cov_testAA(:,:,b))), min(min(avg_cov_testWA(:,:,b))))  ...
            max(max(max(avg_cov_testAA(:,:,b))), max(max(avg_cov_testWA(:,:,b))))], fullfile(fig_dir, [colloq_nm{b} '_testAA']))

        CBIG_Plot_Schaefer400_17Networks19SubcorRearrCorrMat_WhiteGrid(avg_cov_testWA(1:200, 1:200, b), ...
            avg_cov_testWA(1:200, 201:400, b), avg_cov_testWA(201:400, 201:400, b), ...
            avg_cov_testWA(1:200, 401:end, b), avg_cov_testWA(201:400, 401:end, b), ...
            avg_cov_testWA(401:end, 401:end, b), 0.75*[min(min(min(avg_cov_testAA(:,:,b))), min(min(avg_cov_testWA(:,:,b))))  ...
            max(max(max(avg_cov_testAA(:,:,b))), max(max(avg_cov_testWA(:,:,b))))], fullfile(fig_dir, [colloq_nm{b} '_testWA']))

        CBIG_Plot_Schaefer400_17Networks19SubcorRearrCorrMat_WhiteGrid(avg_cov_testWA(1:200, 1:200, b) - avg_cov_testAA(1:200, 1:200, b), ...
            avg_cov_testWA(1:200, 201:400, b) - avg_cov_testAA(1:200, 201:400, b), avg_cov_testWA(201:400, 201:400, b) - avg_cov_testAA(201:400, 201:400, b), ...
            avg_cov_testWA(1:200, 401:end, b) - avg_cov_testAA(1:200, 401:end, b), avg_cov_testWA(201:400, 401:end, b) - avg_cov_testAA(201:400, 401:end, b), ...
            avg_cov_testWA(401:end, 401:end, b) - avg_cov_testAA(401:end, 401:end, b), 0.75*[min(min(avg_cov_testAA(:,:,b) - avg_cov_testWA(:,:,b)))  ...
            max(max(avg_cov_testAA(:,:,b) - avg_cov_testWA(:,:,b)))], fullfile(fig_dir, [colloq_nm{b} '_testAAvsWA']))
    end
end

    
end