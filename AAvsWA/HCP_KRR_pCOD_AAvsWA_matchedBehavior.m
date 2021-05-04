function HCP_KRR_pCOD_AAvsWA_matchedBehavior( KRR_dir, max_seed, num_test_folds, split_AAdir, split_WAdir, ...
    use_seed_bhvr_ldir, outmat, mtch_bhvr_ls, full_bhvr_ls, subj_ls )

% HCP_KRR_pCOD_AAvsWA_matchedBehavior( KRR_dir, max_seed, num_test_folds, split_AAdir, split_WAdir, ...
%     use_seed_bhvr_ldir, outmat, mtch_bhvr_ls, full_bhvr_ls, subj_ls )
%
% 

if(~exist('num_test_folds', 'var') || isempty(num_test_folds))
    num_test_folds = 10;
end
nsseds = 40;

[mtch_bhvr, n_mtch] = CBIG_text2cell(mtch_bhvr_ls);
full_bhvr = CBIG_text2cell(full_bhvr_ls);
[~,~,b_ind] = intersect(mtch_bhvr, full_bhvr, 'stable');

[subjects, nsub] = CBIG_text2cell(subj_ls);

%%
seed_counts = zeros(1, n_mtch);
COD_AA = nan(nsseds, n_mtch);  COD_WA = COD_AA;  COD_comb = COD_AA;
ss_res_AA_all = nan(nsseds, n_mtch);  ss_res_WA_all = ss_res_AA_all;  
ss_res_comb_all = ss_res_AA_all;  ss_total_all = ss_res_AA_all;
for seed = 1:max_seed
    txt_name = fullfile(use_seed_bhvr_ldir, ['usable_behaviors_seed' num2str(seed) '.txt']);
    if(exist(txt_name, 'file'))
        use_bhvr = CBIG_text2cell(txt_name);
        [~, use_idx] = intersect(mtch_bhvr, use_bhvr, 'stable');
    else
        continue
    end

    load(fullfile(split_AAdir, ['split_seed' num2str(seed) '.mat']))
    load(fullfile(split_WAdir, ['split_seed' num2str(seed) '.mat']))
    %%%%%%%%%%% for author's own debugging purpose
    if(~exist('AA_fold', 'var'))
        AA_fold = Afr_fold;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    for b = 1:n_mtch
        if(~ismember(b, use_idx))
            continue
        end
        seed_counts(b) = seed_counts(b) + 1;
        fprintf('Matched seed %d for behavior %s.\n', seed_counts(b), mtch_bhvr{b})

        curr_subfold = fullfile(KRR_dir, ['randseed_' num2str(seed)], mtch_bhvr{b}, ...
            ['no_relative_10_fold_sub_list_' mtch_bhvr{b} '.mat']);
        load(curr_subfold)

        curr_result = fullfile(KRR_dir, ['randseed_' num2str(seed)], mtch_bhvr{b}, ...
            ['final_result_' mtch_bhvr{b} '.mat']);
        curr_result = load(curr_result);

        yt_AA = []; yp_AA = []; yt_train_AA = [];
        yt_WA = []; yp_WA = []; yt_train_WA = [];
        for fold = 1:num_test_folds
            load(fullfile(KRR_dir, ['randseed_' num2str(seed)], mtch_bhvr{b}, 'y', ...
                ['fold_' num2str(fold)], ['y_regress_' mtch_bhvr{b} '.mat']))
            
            [~, Aind] = intersect(subjects, AA_fold.sub_perfold{fold}, 'stable');
            curr_yt_AA = y_resid(Aind);
            [~, Aind_train] = intersect(subjects, ...
                cat(1, AA_fold.sub_perfold{setdiff(1:num_test_folds, fold)}), 'stable');
            curr_yt_train_AA = y_resid(Aind_train);
            yt_AA = [yt_AA; curr_yt_AA];
            yt_train_AA = [yt_train_AA; curr_yt_train_AA];
            curr_yp_AA = curr_result.y_predict_concat(Aind);
            yp_AA = [yp_AA; curr_yp_AA];
            
            [~, Wind] = intersect(subjects, best_assign{b_ind(b)}{fold}, 'stable');
            curr_yt_WA = y_resid(Wind);
            [~, Wind_train] = intersect(subjects, ...
                cat(1, best_assign{b_ind(b)}{setdiff(1:num_test_folds, fold)}), 'stable');
            curr_yt_train_WA = y_resid(Wind_train);
            yt_WA = [yt_WA; curr_yt_WA];
            yt_train_WA = [yt_train_WA; curr_yt_train_WA];
            curr_yp_WA = curr_result.y_predict_concat(Wind);
            yp_WA = [yp_WA; curr_yp_WA];

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

        clear sub_fold curr_result
    end

    clear AA_fold best_assign cost_history highest_cost
end

save(outmat, 'COD_AA', 'COD_WA', 'COD_comb', 'ss_res_AA_all', 'ss_res_WA_all', ...
    'ss_res_comb_all', 'ss_total_all')

%% check which behavioral measures have positive COD
mean_COD_comb = nanmean(COD_comb, 1);
CBIG_cell2text(mtch_bhvr(mean_COD_comb>0), fullfile(KRR_dir, 'pCOD_comb_pos_behaviors.txt'))

mean_COD_AA = nanmean(COD_AA, 1);
CBIG_cell2text(mtch_bhvr(mean_COD_AA>0), fullfile(KRR_dir, 'pCOD_AA_pos_behaviors.txt'))

mean_COD_WA = nanmean(COD_WA, 1);
CBIG_cell2text(mtch_bhvr(mean_COD_WA>0), fullfile(KRR_dir, 'pCOD_WA_pos_behaviors.txt'))

CBIG_cell2text(mtch_bhvr( mean_COD_AA>0 | mean_COD_WA>0 ), ...
    fullfile(KRR_dir, 'pCOD_union_pos_behaviors.txt'))
    
end