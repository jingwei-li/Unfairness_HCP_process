function HCP_KRR_acc_unmatchedAAvsWA_matchedBehav( KRR_dir, max_seed, num_test_folds, ...
    use_seed_bhvr_ldir, selected_AAWA_dir, sel_AAWA_subdir, out_pCOD, out_corr, bhvr_ls, subj_ls )

% HCP_KRR_acc_unmatchedAAvsWA_matchedBehav( KRR_dir, max_seed, num_test_folds, ...
%    use_seed_bhvr_ldir, selected_AAWA_dir, sel_AAWA_subdir, out_pCOD, out_corr, bhvr_ls, full_bhvr_ls, subj_ls )
%
% 

if(~exist('num_test_folds', 'var') || isempty(num_test_folds))
    num_test_folds = 10;
end
nseeds = 40;

[bhvr, n_bhvr] = CBIG_text2cell(bhvr_ls);

[subjects, nsub] = CBIG_text2cell(subj_ls);

%%
seed_counts = zeros(1, n_bhvr);
COD_AA = nan(nseeds, n_bhvr);  COD_WA = COD_AA;  COD_comb = COD_AA;
ss_res_AA_all = nan(nseeds, n_bhvr);  ss_res_WA_all = ss_res_AA_all;  
ss_res_comb_all = ss_res_AA_all;  ss_total_all = ss_res_AA_all;
yt_AA_all = cell(nseeds, n_bhvr);  yp_AA_all = yt_AA_all;
yt_WA_all = yt_AA_all;  yp_WA_all = yt_WA_all;
yt_train_AA_all = yt_AA_all;  yt_train_WA_all = yt_AA_all;
yt_AA_match_all = yt_AA_all;  yp_AA_match_all = yt_AA_all;
yt_WA_match_all = yt_AA_all;  yp_WA_match_all = yt_AA_all;

for seed = 1:max_seed
    txt_name = fullfile(use_seed_bhvr_ldir, ['usable_behaviors_seed' num2str(seed) '.txt']);
    if(exist(txt_name, 'file'))
        use_bhvr = CBIG_text2cell(txt_name);
        [~, use_idx] = intersect(bhvr, use_bhvr, 'stable');
    else
        continue
    end

    for b = 1:n_bhvr
        if(~ismember(b, use_idx))
            continue
        end
        seed_counts(b) = seed_counts(b) + 1;
        fprintf('Selected seed %d for behavior %s.\n', seed_counts(b), bhvr{b})

        load(fullfile(selected_AAWA_dir, ['split_seed' num2str(seed)], ...
            sel_AAWA_subdir, [bhvr{b} '.mat']));

        curr_subfold = fullfile(KRR_dir, ['randseed_' num2str(seed)], bhvr{b}, ...
            ['no_relative_10_fold_sub_list_' bhvr{b} '.mat']);
        load(curr_subfold)

        curr_result = fullfile(KRR_dir, ['randseed_' num2str(seed)], bhvr{b}, ...
            ['final_result_' bhvr{b} '.mat']);
        curr_result = load(curr_result);

        yt_AA = []; yp_AA = []; yt_train_AA = []; yt_AA_match = []; yp_AA_match = [];
        yt_WA = []; yp_WA = []; yt_train_WA = []; yt_WA_match = []; yp_WA_match = [];
        for fold = 1:num_test_folds
            load(fullfile(KRR_dir, ['randseed_' num2str(seed)], bhvr{b}, 'y', ...
                ['fold_' num2str(fold)], ['y_regress_' bhvr{b} '.mat']))
            
            [~, Aind] = intersect(subjects, unmatched_AA{fold}, 'stable');
            curr_yt_AA = y_resid(Aind);
            [~, Aind_train] = intersect(subjects, ...
                cat(1, unmatched_AA{setdiff(1:num_test_folds, fold)}), 'stable');
            curr_yt_train_AA = y_resid(Aind_train);
            yt_AA = [yt_AA; curr_yt_AA];
            yt_train_AA = [yt_train_AA; curr_yt_train_AA];
            curr_yp_AA = curr_result.y_predict_concat(Aind);
            yp_AA = [yp_AA; curr_yp_AA];

            [~,~, Aind_match] = intersect(unmatched_AA{fold}, subjects, 'stable');
            curr_yt_AA_match = y_resid(Aind_match);
            curr_yp_AA_match = curr_result.y_predict_concat(Aind_match);
            yt_AA_match = [yt_AA_match; curr_yt_AA_match];
            yp_AA_match = [yp_AA_match; curr_yp_AA_match];
            
            [~, Wind] = intersect(subjects, unmatched_WA{fold}, 'stable');
            curr_yt_WA = y_resid(Wind);
            [~, Wind_train] = intersect(subjects, ...
                cat(1, unmatched_WA{setdiff(1:num_test_folds, fold)}), 'stable');
            curr_yt_train_WA = y_resid(Wind_train);
            yt_WA = [yt_WA; curr_yt_WA];
            yt_train_WA = [yt_train_WA; curr_yt_train_WA];
            curr_yp_WA = curr_result.y_predict_concat(Wind);
            yp_WA = [yp_WA; curr_yp_WA];

            [~,~, Wind_match] = intersect(unmatched_WA{fold}, subjects, 'stable');
            curr_yt_WA_match = y_resid(Wind_match);
            curr_yp_WA_match = curr_result.y_predict_concat(Wind_match);
            yt_WA_match = [yt_WA_match; curr_yt_WA_match];
            yp_WA_match = [yp_WA_match; curr_yp_WA_match];

            clear y_orig y_resid
        end

        ss_res_AA = sum((yp_AA - yt_AA).^2, 1) ./ length(yt_AA);
        ss_res_WA = sum((yp_WA - yt_WA).^2, 1) ./ length(yt_WA);
        ss_res_comb = sum(([yp_AA;yp_WA] - [yt_AA;yt_WA]).^2, 1) ./ length([yt_AA;yt_WA]);
        ss_total = sum(([yt_AA; yt_WA] - mean([yt_train_AA; yt_train_WA], 1)).^2, 1) ./ ...
            length([yt_AA;yt_WA]);

        COD_AA(seed_counts(b), b) = bsxfun(@minus, 1, ss_res_AA./ss_total);
        COD_WA(seed_counts(b), b) = bsxfun(@minus, 1, ss_res_WA./ss_total);
        COD_comb(seed_counts(b), b) = bsxfun(@minus, 1, ss_res_comb./ss_total);

        ss_res_AA_all(seed_counts(b), b) = ss_res_AA;
        ss_res_WA_all(seed_counts(b), b) = ss_res_WA;
        ss_res_comb_all(seed_counts(b), b) = ss_res_comb;
        ss_total_all(seed_counts(b), b) = ss_total;

        corr_AA(seed_counts(b), b) = CBIG_corr(yp_AA, yt_AA);
        corr_WA(seed_counts(b), b) = CBIG_corr(yp_WA, yt_WA);
        corr_comb(seed_counts(b), b) = CBIG_corr([yp_AA; yp_WA], [yt_AA; yt_WA]);

        yt_AA_all{seed_counts(b), b} = yt_AA;
        yp_AA_all{seed_counts(b), b} = yp_AA;
        yt_WA_all{seed_counts(b), b} = yt_WA;
        yp_WA_all{seed_counts(b), b} = yp_WA;
        yt_train_AA_all{seed_counts(b), b} = yt_train_AA;
        yt_train_WA_all{seed_counts(b), b} = yt_train_WA;
        yt_AA_match_all{seed_counts(b), b} = yt_AA_match;
        yp_AA_match_all{seed_counts(b), b} = yp_AA_match;
        yt_WA_match_all{seed_counts(b), b} = yt_WA_match;
        yp_WA_match_all{seed_counts(b), b} = yp_WA_match;

        clear sub_fold curr_result
    end

    clear AA_fold best_assign cost_history highest_cost
end

if(~isempty(out_pCOD))
    save(out_pCOD, 'COD_AA', 'COD_WA', 'COD_comb', 'ss_res_AA_all', 'ss_res_WA_all', ...
        'ss_res_comb_all', 'ss_total_all', 'yt_AA_all', 'yt_WA_all', 'yp_AA_all', ...
        'yp_WA_all', 'yt_train_AA_all', 'yt_train_WA_all', 'yt_AA_match_all', ...
        'yp_AA_match_all', 'yt_WA_match_all', 'yp_WA_match_all')
end
if(~isempty(out_corr))
    save(out_corr, 'corr_AA', 'corr_WA', 'corr_comb', 'yt_AA_all', 'yt_WA_all', ...
        'yp_AA_all', 'yp_WA_all', 'yt_train_AA_all', 'yt_train_WA_all', ...
        'yt_AA_match_all', 'yp_AA_match_all', 'yt_WA_match_all', 'yp_WA_match_all')
end
    
end