function HCP_LRR(rstr_csv, unrstr_csv, FS_csv, subj_ls, RSFC_file, y_name, cov_ls, cov_X_ls, ...
    FD_file, DV_file, outdir, num_test_folds, num_inner_folds, seed)

% HCP_LRR(str_csv, unrstr_csv, FS_csv, subj_ls, RSFC_file, y_name, cov_ls, cov_X_ls, ...
%     FD_file, DV_file, outdir, num_test_folds, num_inner_folds, seed)
%
% 

%% setting up
if(ischar(num_test_folds))
    num_test_folds = str2double(num_test_folds);
end

if(ischar(num_inner_folds))
    num_inner_folds = str2double(num_inner_folds);
end

if(ischar(seed))
    seed = str2double(seed);
end
    
%% Read y
% y types
fprintf('[HCP workflow]: read the measures to be predicted.\n')
if(strcmp(y_name, 'Gender'))
    y_type = 'categorical';
else
    y_type = 'continuous';
end
ystem = ['_' y_name];
if(~exist([outdir '/y' ystem '.mat'], 'file'))
    CBIG_read_y_from_csv( {rstr_csv, unrstr_csv, FS_csv}, 'Subject', {y_name}, {y_type}, ...
        subj_ls, fullfile(outdir, ['y' ystem '.mat']), ',' );
end

%% Read covariates which need to be regressed out from behavioral scores
% covariate types
fprintf('[HCP workflow]: read covariates to be regressed from the behavioral measures.\n')
if(strcmpi(cov_ls, 'none'))
    cov_names = 'NONE';
else
    [cov_names, num_cov] = CBIG_text2cell(cov_ls);
end
cov_stem = '_58behaviors';
if(strcmpi(cov_names, 'none'))
    covariates = 'none';
    save(fullfile(outdir, ['covariates' cov_stem '.mat']), 'covariates');
else
    for i = 1:num_cov
        if(strcmp(cov_names{i}, 'Gender') || strcmp(cov_names{i}, 'Race'))
            cov_types{i} = 'categorical';
        else
            cov_types{i} = 'continuous';
        end
    end
    
    if(~exist(fullfile(outdir, ['covariates' cov_stem '.mat']), 'file'))
        CBIG_generate_covariates_from_csv( {rstr_csv, unrstr_csv, FS_csv}, ...
            'Subject', cov_names, cov_types, subj_ls, FD_file, DV_file, ...
            fullfile(outdir, ['covariates' cov_stem '.mat']), ',' );
    end
end

%% Read covariates which need to be regressed out from RSFC
fprintf('[HCP workflow]: read covariates to be regressed from RSFC.\n')
cov_X_file = fullfile(outdir, ['cov_X' cov_stem '.mat']);
if(strcmpi(cov_X_ls, 'none'))
    covariates = [];
    save(cov_X_file, 'covariates')
else
    [cov_X_names, num_cov_X] = CBIG_text2cell(cov_X_ls);
    for i = 1:num_cov_X
        if(strcmp(cov_X_names{i}, 'Gender') || strcmp(cov_X_names{i}, 'Race'))
            cov_X_types{i} = 'categorical';
        else
            cov_X_types{i} = 'continuous';
        end
    end
    
    if(~exist(cov_X_file, 'file'))
        CBIG_generate_covariates_from_csv( {rstr_csv, unrstr_csv, FS_csv}, ...
            'Subject', cov_X_names, cov_X_types, subj_ls, FD_file, DV_file, ...
            cov_X_file, ',');
    end
end

%% Call elastic net workflow
fprintf('[HCP workflow]: call linear ridge regression workflow ...\n')
sub_fold_file = fullfile(outdir, ['randseed_' num2str(seed)], y_name, ...
    ['no_relative_' num2str(num_test_folds) '_fold_sub_list' ystem '.mat']);

params = load(sub_fold_file, 'sub_fold');
load(RSFC_file); params.feature_mat = corr_mat; clear corr_mat
load(fullfile(outdir, ['covariates' cov_stem '.mat'])); params.covariates = covariates; clear covariates
load(cov_X_file); params.cov_X = covariates; clear covariates
load(fullfile(outdir, ['y' ystem '.mat'])); params.y = y; clear y
params.outdir = fullfile(outdir, ['randseed_' num2str(seed)], y_name);
params.outstem = y_name; params.num_inner_folds = num_inner_folds; params.domain = [3 8];

CBIG_LRR_fitrlinear_workflow_1measure(params)
    
end