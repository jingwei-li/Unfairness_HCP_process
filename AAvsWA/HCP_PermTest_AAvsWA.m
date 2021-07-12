function HCP_PermTest_AAvsWA(group_diff, bhvr_ls, metric, outmat)

% HCP_PermTest_AAvsWA(group_diff, bhvr_ls, metric, outmat)
%
% Permutation test for accuracy difference between matched AA and WA.
%
% Inputs:
% - group_diff
%   Full path of a .mat file. This file contains the prediction accuracies of matched AA amd 
%   WA separately. It is the output file of `HCP_KRR_acc_AAvsWA_matchedBehavior.m`.
%
% - bhvr_ls
%   List of the focused behavioral measures (full path).
%
% - metric
%   String, accuracy metric. Choose from 'predictive_COD' or 'corr'.
%
% - outmat
%   Output .mat file, storing the information of which behavioral measures showed significant
%   accuracy difference between matched AA and WA.
%
% Author: Jingwei Li

alpha = 0.5;
nseeds = 40;
nperm = 1000;

grpdif = load(group_diff);
[bhvr_nm, nbhvr] = CBIG_text2cell(bhvr_ls);

switch metric
case 'predictive_COD'
    AA_acc = 'COD_AA';
    WA_acc = 'COD_WA';
case 'corr'
    AA_acc = 'corr_AA';
    WA_acc = 'corr_WA';
otherwise
    error('Unknown metric: %s', metric)
end

acc_diff = grpdif.(WA_acc) - grpdif.(AA_acc);

rng(1, 'twister')
null_acc_AA = nan(nseeds, nbhvr, nperm);  null_acc_WA = null_acc_AA;
for seed = 1:nseeds
    for b = 1:nbhvr
        for i = 1:nperm
            % indices of subjects to exchange ethnic/racial group labels
            curr_ind = round(rand(length(grpdif.yt_AA_all{seed, b}), 1));
            % randomly shuffle the ordering of WA subjects
            shuffle = datasample(1:length(grpdif.yt_WA_match_all{seed,b}), ...
                length(grpdif.yt_WA_match_all{seed,b}), 'replace', false);

            null_yt_AA = grpdif.yt_AA_match_all{seed, b};
            null_yt_AA(curr_ind==1) = grpdif.yt_WA_match_all{seed, b}(shuffle(curr_ind==1));
            null_yp_AA = grpdif.yp_AA_match_all{seed, b};
            null_yp_AA(curr_ind==1) = grpdif.yp_WA_match_all{seed, b}(shuffle(curr_ind==1));

            null_yt_WA = grpdif.yt_WA_match_all{seed, b};
            null_yt_WA(shuffle(curr_ind==1)) = grpdif.yt_AA_match_all{seed, b}(curr_ind==1);
            null_yp_WA = grpdif.yp_WA_match_all{seed, b};
            null_yp_WA(shuffle(curr_ind==1)) = grpdif.yp_AA_match_all{seed, b}(curr_ind==1);

            [null_acc_AA(seed, b, i), null_acc_WA(seed, b, i)] = compute_null(null_yt_AA, ...
                null_yt_WA, null_yp_AA, null_yp_WA, metric, ...
                grpdif.yt_train_AA_all{seed, b}, grpdif.yt_train_WA_all{seed, b});
        end
    end
end

null_acc_diff = null_acc_WA - null_acc_AA;
null_acc_diff = squeeze(nanmean(null_acc_diff, 1));
avg_acc_diff = nanmean(acc_diff);

p_perm = nan(nbhvr,1);
for b = 1:nbhvr
    p_perm(b) = length(find( null_acc_diff(b,:) - mean(null_acc_diff(b,:)) > abs(avg_acc_diff(b)) | ...
        null_acc_diff(b,:) - mean(null_acc_diff(b,:)) < -abs(avg_acc_diff(b)) )) / nperm;
end
p_perm(nbhvr+1) = length(find( mean(null_acc_diff,1) - mean(mean(null_acc_diff,1),2) > abs(mean(avg_acc_diff)) | ...
    mean(null_acc_diff,1) - mean(mean(null_acc_diff,1),2) < -abs(mean(avg_acc_diff)) )) / nperm;

H_perm_all = FDR(p_perm(:), alpha);
H_perm = setdiff(H_perm_all, nbhvr+1);
sig_diff_idx = sort(H_perm);
sig_diff_bhvr = bhvr_nm(sig_diff_idx);

save(outmat, 'p_perm', 'H_perm_all', 'H_perm', 'sig_diff_idx', 'sig_diff_bhvr', ...
    'null_acc_diff', 'avg_acc_diff')
    
end


function [null_acc_AA, null_acc_WA] = compute_null(null_yt_AA, null_yt_WA, null_yp_AA, ...
    null_yp_WA, metric, AA_train, WA_train)

switch metric
    case 'predictive_COD'
        ss_res_AA = sum((null_yt_AA - null_yp_AA).^2, 1) ./ length(null_yt_AA);
        ss_res_WA = sum((null_yt_WA - null_yp_WA).^2, 1) ./ length(null_yt_WA);
        ss_total = sum(([AA_train; WA_train] - mean([AA_train; WA_train])).^2, 1) ./ ...
            length([AA_train; WA_train]);
        
        null_acc_AA = bsxfun(@minus, 1, ss_res_AA ./ ss_total);
        null_acc_WA = bsxfun(@minus, 1, ss_res_WA ./ ss_total);
    case 'corr'
        null_acc_AA = CBIG_corr(null_yp_AA, null_yt_AA);
        null_acc_WA = CBIG_corr(null_yp_WA, null_yt_WA);
    otherwise
        error('Unknown metric')
end

end