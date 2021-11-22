function HCP_PermTest_predVStrue_AAvsWA(group_diff, bhvr_ls, outmat)

% HCP_PermTest_predVStrue_AAvsWA(group_diff, bhvr_ls, outmat)
%
%

alpha = 0.05;
nseeds = 40;
nperm = 1000;

grpdif = load(group_diff);
[bhvr_nm, nbhvr] = CBIG_text2cell(bhvr_ls);

rng(1, 'twister')
null_ydiff_AA = nan(nseeds, nbhvr, nperm);  null_ydiff_WA = null_ydiff_AA;
ydiff_AA = nan(nseeds, nbhvr);  ydiff_WA = ydiff_AA;
for seed = 1:nseeds
    for b = 1:nbhvr
        ydiff_AA(seed, b) = mean(grpdif.yp_AA_match_all{seed, b} - grpdif.yt_AA_match_all{seed, b}, 1);
        ydiff_WA(seed, b) = mean(grpdif.yp_WA_match_all{seed, b} - grpdif.yt_WA_match_all{seed, b}, 1);
        
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

            null_ydiff_AA(seed, b, i) = mean(null_yp_AA - null_yt_AA);
            null_ydiff_WA(seed, b, i) = mean(null_yp_WA - null_yt_WA);
        end
    end
end

null_ydiff_diff = null_ydiff_WA - null_ydiff_AA;
null_ydiff_diff = squeeze(nanmean(null_ydiff_diff, 1));
avg_ydiff_diff = nanmean(ydiff_WA - ydiff_AA);

p_perm = nan(nbhvr,1);
for b = 1:nbhvr
    p_perm(b) = length(find( null_ydiff_diff(b,:) - mean(null_ydiff_diff(b,:)) > abs(avg_ydiff_diff(b)) | ...
        null_ydiff_diff(b,:) - mean(null_ydiff_diff(b,:)) < -abs(avg_ydiff_diff(b)) )) / nperm;
end
p_perm(nbhvr+1) = length(find( mean(null_ydiff_diff,1) - mean(mean(null_ydiff_diff,1),2) > abs(mean(avg_ydiff_diff)) | ...
    mean(null_ydiff_diff,1) - mean(mean(null_ydiff_diff,1),2) < -abs(mean(avg_ydiff_diff)) )) / nperm;

H_perm_all = FDR(p_perm(:), alpha);
H_perm = setdiff(H_perm_all, nbhvr+1);
sig_diff_idx = sort(H_perm);
sig_diff_bhvr = bhvr_nm(sig_diff_idx);

save(outmat, 'p_perm', 'H_perm_all', 'H_perm', 'sig_diff_idx', 'sig_diff_bhvr', ...
    'null_ydiff_diff', 'avg_ydiff_diff')
    
end