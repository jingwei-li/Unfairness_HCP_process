function HCP_regress_cov_from_FC(FC_in, cov_ls, subj_ls, FC_out, rstr_csv, unrstr_csv, ...
    FS_csv, FD_file, DV_file)

% HCP_regress_cov_from_FC(FC_in, cov_ls, subj_ls, FC_out, rstr_csv, unrstr_csv, ...
%     FS_csv, FD_file, DV_file)
%
% Regress confounding variables from RSFC.
%
% Inputs:
% - FC_in
%   Full path of the functional connectivity .mat file before regression.
%
% - cov_ls
%   Full path of a list containing all confounding variable names. Each line corresponds to
%   one confounding variable. Except for 'FD' and 'DVARS' (or 'DV'), all variable names should 
%   be reachable in one of the three csv files: <rstr_csv>, <unrstr_csv>, and <FS_csv>.
%
% - subj_ls
%   Full path of the subject list. Each line in this list is one subject ID. Length of the 
%   subject list should be the same as the number of subjects in <FC_in>.
%
% - FC_out
%   Full path of the output file, i.e. functional connectivity .mat file after regression.
% 
% - rstr_csv
%   Full path of the restricted CSV file downloaded from the HCP website.
%
% - unrstr_csv
%   Full path of the unrestricted CSV file downloaded from the HCP website.
%
% - FS_csv
%   Full path of the FreeSurfer CSV file downloaded from the HCP website.
%
% - FD_file
%   If there is a need to regress 'FD' from the behavioral (or demographic) measures, y, 
%   the user should include 'FD' in the "cov_list". In this case, "FD_file" is the full path 
%   of the mean framewise displacement (FD) of all subjects. The number of lines in "FD_file"
%   should be the same as the number of lines in "subj_ls".
%   If the user does not need to regress 'FD' from y, then the input variable 'FD_file' is 
%   not required and the user can pass in 'NONE' to the function.
%
% - DV_file 
%   If there is a need to regress 'DVARS' from the behavioral (or demographic) measures, y, 
%   the user must include the covariate 'DVARS' (or 'DV') in the 'cov_ls'. In this case, 
%   "DV_file" is the full path of the mean DVARS of all subjects. The number of lines in 
%   "DV_file" should be the same as the number of lines in "subj_list". 
%   If the user does not need to regress 'DVARS' from y, then the input variable 'DV_file' is 
%   not required and the user can pass in 'NONE' to the function.
%
% Author: Jingwei Li

load(FC_in)

%% Read covariates from csv files
[cov_names, num_cov] = CBIG_text2cell(cov_ls);
for i = 1:num_cov
    if(strcmp(cov_names{i}, 'Gender') || strcmp(cov_names{i}, 'Race'))
        cov_types{i} = 'categorical';
    else
        cov_types{i} = 'continuous';
    end
end
    
covariates = CBIG_generate_covariates_from_csv( {rstr_csv, unrstr_csv, FS_csv}, 'Subject', ...
    cov_names, cov_types, subj_ls, FD_file, DV_file, 'NONE', ',' );

%% reshape FC from 3D to 2D
s = size(corr_mat);
corr_mat = reshape(corr_mat, s(1)*s(2), s(3));

%% regresssion
corr_mat = CBIG_glm_regress_matrix(corr_mat', bsxfun(@minus, covariates, mean(covariates,1)), -1, []);

%% reshape back
corr_mat = reshape(corr_mat', s);

% save
outdir = fileparts(FC_out);
mkdir(outdir)
save(FC_out, 'corr_mat');
    
end