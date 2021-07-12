function HCP_LRR_predictable_behavior_step3(LRR_dir, maxLRR_iter, test_metric, outmat, bhvr_ls, colloq_ls, Nperm)

% HCP_LRR_predictable_behavior_step3(LRR_dir, maxLRR_iter, test_metric, outmat, bhvr_ls, colloq_ls)
%
% Test the true accuracy against the accuracy distributions after permutation. 
% 
% Inputs:
%   - LRR_dir
%     The directory which contains the elastic net trained models and testing results.
%   - maxLRR_iter
%     Maximal random seed used to split the training-test folds for performing elastic net, e.g. 400.
%   - test_metric
%     The accuracy metric used to perform statistical testing. Choose from 'predictive_COD' and 'corr'.
%   - outmat
%     Full path of the output mat file storing the behaviors whose actual prediction accuracy was significantly
%     above chance.
%   - bhvr_ls 
%     List of behavioral measures for which matched AA and matched WA can be found (absolute path).
%   - colloq_ls
%     List of colloquial names of behavioral variables. The colloquial names should correspond to the
%     behavioral names in "bhvr_ls".
% 
% Author: Jingwei Li

%% load shared files
[bhvr_nm, nbhvr] = CBIG_text2cell(bhvr_ls);
[colloq_nm, ncolloq] = CBIG_text2cell(colloq_ls);
if(ncolloq ~= nbhvr)
    error('Number of behavioral names is not equal to number of colloquial names.')
end

alpha_FDR = 0.05;

%% calculate p value for each behavior
p_perm = zeros(nbhvr, 1);
avg_stats = [];
avg_null_stats = []
for b = 1:nbhvr
    curr_avg_stats = [];
    curr_avg_null_stats = [];
    for i = 1:maxLRR_iter
        opt_fname = fullfile(LRR_dir, ['randseed_' num2str(i)], bhvr_nm{b}, 'results', 'optimal_acc', ...
            [bhvr_nm{b} '_final_acc.mat']);
        if(~exist(opt_fname, 'file'))
            continue
        end
        opt = load(opt_fname);
        Nfolds = length(opt.original_statistics);
        orig_stats = zeros(Nfolds, 1);
        for f = 1:Nfolds
            orig_stats(f) = opt.optimal_statistics{f}.(test_metric);
        end

        acc_out = fullfile(LRR_dir, ['randseed_' num2str(i)], bhvr_nm{b}, 'perm.mat');
        load(acc_out)

        curr_avg_stats = cat(1, curr_avg_stats, mean(orig_stats, 1));
        curr_avg_null_stats = cat(1, curr_avg_null_stats, mean(stats_perm.(test_metric), 1));
    end

    avg_stats = cat(2, avg_stats, curr_avg_stats);
    avg_null_stats = cat(3, avg_null_stats, curr_avg_null_stats);
    p_perm(b) = length(find( mean(curr_avg_null_stats,1) > mean(curr_avg_stats,1) )) ./ Nperm;
end

%% multiple comparisons correction
H = FDR(p_perm, alpha_FDR);
sig_perm_idx = sort(H);
sig_behaviors = bhvr_nm(sig_perm_idx);
sig_perm_colloq = colloq_nm(sig_perm_idx);

switch test_metric
case 'predictive_COD'
    sig_COD = sig_perm_idx;
    p_COD_perm = p_perm;
    save(outmat, 'p_COD_perm', 'H', 'sig_COD', 'sig_behaviors', 'avg_stats', 'avg_null_stats');
case 'corr'
    sig_corr = sig_perm_idx;
    p_corr_perm = p_perm;
    save(outmat, 'p_corr_perm', 'H', 'sig_corr', 'sig_behaviors', 'avg_stats', 'avg_null_stats');
end
    
end