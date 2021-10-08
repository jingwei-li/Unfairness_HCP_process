function HCP_violin_acc_withnull_AAvsWA(bhvr_ls, group_diff, perm_fname, metric, outdir, outstem, ...
    mtch_bhvr_ls, mtch_colloq_ls)

% HCP_violin_acc_withnull_AAvsWA(bhvr_ls, group_diff, perm_fname, metric, outdir, outstem, ...
%     full_bhvr_ls, full_colloq_ls)
%
% Create violin plot to show the accuracy differences between AA and WA.
%
% Inputs:
% - bhvr_ls
%   List of behavioral measures (full path). The behavioral measures contained in this list
%   should be consistent with that in 'group_diff'.
%
% - group_diff
%   Full path of a .mat file. This file contains the prediction accuracy difference between 
%   AA and WA. It is the output file of `../AAvsWA/HCP_KRR_acc_AAvsWA_matchedBehavior.m`.
% 
% - perm_fname
%   A .mat file (full path) contains the information about which behavioral measures showed 
%   significant accuracy differences between AA and WA. It is the output file of 
%   `../AAvsWA/HCP_PermTest_AAvsWA.m`.
%
% - metric
%   Accurace metric. Choose from 'predictive_COD' and 'corr'.
%
% - outdir
%   Output directory for the created figures (full path).
%
% - outstem
%   File stem of the output figures.
%
% - mtch_bhvr_ls
%   List of ALL matched behavioral measures (full path.
%
% - mtch_colloq_ls
%   List of colloquial names, which correspond to the behavioral measures in 'mtch_bhvr_ls'.
%
% Author: Jingwei Li

%% common figure parameters
colormat = [114 147 203; 132 186 91; 211 94 96; 180 180 180]./255;
colormat_comb = [180 180 180] ./ 255;

legends = {'AA', 'WA', 'Differece', 'Null difference'};

%% determine variable names based on metric type
switch metric
case 'predictive_COD'
    y_label = 'Cross-validated predictive COD';
    y_label_avg = 'Mean cross-validated predictive COD';
    AA_acc = 'COD_AA';
    WA_acc = 'COD_WA';
case 'corr'
    y_label = 'Cross-validated Pearson''s r';
    y_label_avg = 'Mean cross-validated Pearson''s r';
    AA_acc = 'corr_AA';
    WA_acc = 'corr_WA';
otherwise
    error('Unknown accuracy metric: %s', metric)
end

%% read behavioral lists
ls_dir = fullfile(getenv('HOME'), 'storage', 'MyProject', 'fairAI', 'HCP_race', 'scripts', 'lists');
if(~exist('mtch_bhvr_ls', 'var') || isempty(mtch_bhvr_ls))
    mtch_bhvr_ls = fullfile(ls_dir, 'Cognitive_Personality_Task_Social_Emotion_51_matched.txt');
end
if(~exist('mtch_colloq_ls', 'var') || isempty(mtch_colloq_ls))
    mtch_colloq_ls = fullfile(ls_dir, 'colloquial_names_51_matched.txt');
end

[mtch_bhvr, n_mtch] = CBIG_text2cell(mtch_bhvr_ls);
mtch_colloq = CBIG_text2cell(mtch_colloq_ls);
if(length(mtch_colloq) ~= n_mtch)
    error('Behavioral measures in mtch_bhvr_ls and mtch_colloq_ls are not one-to-one corresponded.')
end
[bhvr_nm, nbhvr] = CBIG_text2cell(bhvr_ls);

%% load accuracy differences
grpdif = load(group_diff);
if(size(grpdif.(AA_acc), 2) ~= nbhvr)
    error('Behavioral measures in group_diff and bhvr_ls differ!')
end

[~, ~, b_ind] = intersect(bhvr_nm, mtch_bhvr, 'stable');
colloq_nm = mtch_colloq(b_ind);

% sort accuracy difference
acc_diff = grpdif.(WA_acc) - grpdif.(AA_acc);
nseeds = size(acc_diff, 1);
alldata = cat(1, reshape(grpdif.(AA_acc), 1, nseeds, nbhvr), ...
    reshape(grpdif.(WA_acc), 1, nseeds, nbhvr), reshape(acc_diff, 1, nseeds, nbhvr));
[~, sort_idx] = sort(mean(acc_diff, 1), 'descend');
data_sort = alldata(:,:,sort_idx);
bhvr_nm_sort = bhvr_nm(sort_idx);
colloq_nm_sort = colloq_nm(sort_idx);

%% load permutation test results, if any
load(perm_fname)
[~, IA, IB] = intersect(sort_idx, sig_diff_idx, 'stable');
null_data = null_acc_diff(sort_idx, :);

if(~exist(outdir, 'dir'))
    mkdir(outdir)
end

%% plot for each behavior
HCP_violin_withnull_2grp_indiv(data_sort, null_data', colormat, y_label, legends, [], ...
	colloq_nm_sort, IA, outdir, [outstem '_withnull'])

%% plot the average
avg_data = mean(data_sort, 3)';
HCP_violin_2grp_avg(avg_data, colormat, y_label, legends, outdir, outstem)
