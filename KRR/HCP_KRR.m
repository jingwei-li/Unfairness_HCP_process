function HCP_KRR(rstr_csv, unrstr_csv, FS_csv, subj_ls, RSFC_file, y_name, cov_ls, FD_file, ...
    DV_file, outdir, num_test_folds, num_inner_folds, seed, with_bias, ker_param_file, ...
    lambda_set_file, threshold_set_file, opt_metric)

% HCP_KRR(rstr_csv, unrstr_csv, FS_csv, subj_ls, RSFC_file, y_name, cov_ls, FD_file, ...
%     DV_file, outdir, num_test_folds, num_inner_folds, seed, with_bias, ker_param_file, ...
%     lambda_set_file, threshold_set_file, opt_metric)
%
% This function performs kernel ridge regression for prediting a single behavioral measure 
% (y_name) in the HCP dataset. It first reads in the behavioral scores, confounding variables 
% to be regressed out, RSFC matrix, and calls `CBIG_KRR_workflow.m` in CBIG repository: 
% https://github.com/ThomasYeoLab/CBIG.
% The prediction accuracy using the optimal hyperparameters will be saved in 
% `fullfile(outdir, 'final_result.mat')`.
%
% Inputs:
%   - rstr_csv
%     Full path of the restricted CSV file downloaded from the HCP website.
%
%   - unrstr_csv
%     Full path of the unrestricted CSV file downloaded from the HCP website.
%
%   - FS_csv
%     Full path of the FreeSurfer CSV file downloaded from the HCP website.
%
%   - subj_ls
%     Full path of the subject ID list. Each line in this list corresponds to one subject ID.
%
%   - RSFC_file
%     Full path of the resting-state functional connectivity (RSFC) matrix. The .mat file 
%     should contains a 3D matrix with dimensions of #ROIs x #ROIs x #subjects.
%
%   - y_name
%     The behavioral name to be predicted. The name should correspond to one of the headers in 
%     either `rstr_csv` or `unrstr_csv`.
%
%   - cov_ls
%     Full path to a text file stating all covariate names. Each line corresponds to one 
%     covariate name. The covariate names should exist as header in either `rstr_csv` or 
%     `unrstr_csv`, except for 'FD' and 'DVARS'.
%
%   - FD_file (optional)
%     If there is a need to regress 'FD' from the behavioral (or demographic) measures, y, 
%     the user should include 'FD' in the "cov_list". In this case, "FD_file" is the full path 
%     of the mean framewise displacement (FD) of all subjects. The number of lines in "FD_file"
%     should be the same as the number of lines in "subj_ls".
%     If the user does not need to regress 'FD' from y, then the input variable 'FD_file' is 
%     not required and the user can pass in 'NONE' to the function.
%     If "cov_list" does not contain FD, this argument will be ignored.
%
%   - DV_file (optional)
%     If there is a need to regress 'DVARS' from the behavioral (or demographic) measures, y, 
%     the user must include the covariate 'DVARS' (or 'DV') in the 'cov_ls'. In this case, 
%     "DV_file" is the full path of the mean DVARS of all subjects. The number of lines in 
%     "DV_file" should be the same as the number of lines in "subj_list". 
%     If the user does not need to regress 'DVARS' from y, then the input variable 'DV_file' is 
%     not required and the user can pass in 'NONE' to the function.
%     If "cov_ls" does not contain DV (or DVARS), this argument will be ignored.
% 
%   - outdir
%     The full path of output directory. A subfolder fullfile(outdir, ['randseed_' seed], y_name) 
%     will be created to save all output files generated using the current random seed for the 
%     current behavioral measure.
%
%   - num_test_folds
%     A string or scalar, the number of training-test cross-validation folds.
% 
%   - num_inner_folds
%     A string or scalar.
%     To select optimal hyperparameters, each training fold will be split randomly into 
%     "num_inner_folds" inner-loop cross-validation folds.
% 
%   - seed
%     A string or scalar, the random seed used to split the data into training-test 
%     cross-validation folds.
%
%   - with_bias (optional)
%     A scalar (choose from 0 or 1).
%     - with_bias = 0 means the algorithm is to minimize 
%     (y - K*alpha)^2 + (regularization of alpha);
%     - with_bias = 1 means the algorithm is to minimize
%     (y - K*alpha - beta)^2 + (regularization of alpha), 
%     where beta is a constant bias for every subject, estimated from the data.
%     If not passed in, the default is 0, meaning there will be no bias term.
% 
%   - ker_param_file (optional)
%     Full path of the kernel parameter file (.mat). A structure "ker_param" is assumed to be 
%     saved in this file.
%     "ker_param" is a K x 1 structure with two fields: type and scale. K denotes the number 
%     of kernels.
%     ker_param(k).type is a string of the type of k-th kernel. Choose from
%                       'corr'        - Pearson's correlation;
%                       'Gaussian'    - Gaussian kernel;
%                       'Exponential' - exponential kernel.
%     ker_param(k).scale is a scalar specifying the scale of k-th kernel (for Gaussian kernel 
%     or exponential kernel). If ker_param(k).type == 'corr', ker_param(k).scale = NaN.
%     If this argument is not passed in (or passed in as 'NONE'), then ker_param will be set as 
%     default:     ker_param.type = 'corr';
%                  ker_param.scale = NaN.
%  
%   - lambda_set_file (optional)
%     Full path of the regularization parameter file (.mat). A vector 
%     "lambda_set" is assumed to be saved in this file.
%     "lambda_set" is a vector of numbers for grid search of lambda (the
%     regularization parameter). If this file is not passed in (or passed
%     in as 'NONE'), it will be set as default:
%     [ 0 0.00001 0.0001 0.001 0.004 0.007 0.01 0.04 0.07 0.1 0.4 0.7 1 1.5 2 2.5 3 3.5 4 5 ...
%      10 15 20]
% 
%   - threshold_set_file (optional)
%     Full path of the file (.mat) storing the set of threshold used to binarize the predicted 
%     score when the original y is binary. A vector "threshold_set" is assumed to be saved in 
%     this file.
%     "threshold_set" is a vector used for grid search of optimal "threshold". If this file is 
%     not passed in (or passed in as 'NONE'),
%     or "threshold_set" is 'NONE', it will be set as default: [-1:0.1:1].
%
%   - opt_metric (optional)
%     A string indicating the metric used to define prediction loss. The
%     loss is used to choose hyperparameters. Default: 'predictive_COD'.
%     Choose from:
%       'corr'              - Pearson's correlation;
%       'COD'               - Coefficient of determination. Defined as
%                             1-||y_pred-y_test||^2/||mean(y_test)-y_test||^2,
%                             where y_pred is the prediction of the test data, 
%                             y_test is the groud truth of the test data, 
%                             and mean(y_test) is the mean of test data
%       'predictive_COD'    - Predictive coefficient of determination. Defined as
%                             1-||y_pred-y_test||^2/||mean(y_train)-y_test||^2,
%                             where y_pred is the prediction of the test data, 
%                             y_test is the groud truth of the test data, 
%                             and mean(y_train) is the mean of training data
%       'MAE'               - mean absolute error
%       'MAE_norm'          - mean absolute error divided by the standard
%                             derivation of the target variable of the training set
%       'MSE'               - mean squared error
%       'MSE_norm'          - mean squared error divided by the variance
%                             of the target variable of the training set
% 
% Author: Jingwei Li

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

if(~exist('with_bias', 'var') || isempty(with_bias))
    with_bias = 1;
end

if(~exist('ker_param_file', 'var') || isempty(ker_param_file) || ...
        strcmpi(ker_param_file, 'none'))
    ker_param_file = [];
end

if(~exist('lambda_set_file', 'var') || isempty(lambda_set_file) || ...
        strcmpi(lambda_set_file, 'none'))
    lambda_set_file = [];
end

if(~exist('threshold_set_file', 'var') || isempty(threshold_set_file) || ...
        strcmpi(threshold_set_file, 'none'))
    threshold_set_file = [];
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
rstr_csv
unrstr_csv
FS_csv
if(~exist([outdir '/y' ystem '.mat'], 'file'))
    CBIG_read_y_from_csv( {rstr_csv, unrstr_csv, FS_csv}, 'Subject', {y_name}, {y_type}, ...
        subj_ls, fullfile(outdir, ['y' ystem '.mat']), ',' );
end

%% Read covariates
% covariate types
fprintf('[HCP workflow]: read covariates to be regressed from the measures.\n')
[cov_names, num_cov] = CBIG_text2cell(cov_ls);
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

%% Call kernel regression workflow utility function
fprintf('[HCP workflow]: call kernel regression workflow ...\n')
sub_fold_file = fullfile(outdir, ['randseed_' num2str(seed)], y_name, ...
    ['no_relative_' num2str(num_test_folds) '_fold_sub_list' ystem '.mat']);
CBIG_KRR_workflow_LITE( '', 0, sub_fold_file, fullfile(outdir, ['y' ystem '.mat']), ...
    fullfile(outdir, ['covariates' cov_stem '.mat']), RSFC_file, num_inner_folds, ...
    fullfile(outdir, ['randseed_' num2str(seed)], y_name), y_name, 'with_bias', with_bias, ...
    'ker_param_file', ker_param_file, 'lambda_set_file', lambda_set_file, ...
    'threshold_set_file', threshold_set_file, 'metric', opt_metric);
    
end