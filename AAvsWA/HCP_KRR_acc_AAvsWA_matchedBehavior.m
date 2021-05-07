function HCP_KRR_acc_AAvsWA_matchedBehavior( KRR_dir, max_seed, num_test_folds, split_AAdir, split_WAdir, ...
    use_seed_bhvr_ldir, out_pCOD, out_corr, mtch_bhvr_ls, full_bhvr_ls, subj_ls )

% HCP_KRR_acc_AAvsWA_matchedBehavior( KRR_dir, max_seed, num_test_folds, split_AAdir, split_WAdir, ...
%     use_seed_bhvr_ldir, out-pCOD, out_corr, mtch_bhvr_ls, full_bhvr_ls, subj_ls )
%
% Calculate predictive COD and Pearson's correlation accuracies for the matched AA and WA groups separately. 
% The predition was performed using kernel ridge regression.
%
% Inputs:
% - KRR_dir
%   The top-level output directory of kernel ridge regression. This directory contains one subdirectory 
%   for each random data split. Within each random data split folder, there is a subfolder corresponding
%   to each behavioral measures (for which matdhed AA and WA can be selected).
%
% - max_seed
%   Maximal random seed used to split subjects into folds.
%
% - num_test_folds
%   A string or scalar, the number of training-test cross-validation folds.
%
% - split_AAdir 
%   Full path of the directory storing the split folds of African Americans.
%   It is the output of `../match_split/HCP_split_AA_rm_hardtomatch.m`.
%
% - split_WAdir
%   Full path of the directory storing the white Americans that were matched to African Americans.
%   It is the output of `../match_split/HCP_match_WA_with_AAfolds.sh`.
%
% - use_seed_bhvr_ldir
%   For each behavioral measure, 40 seed were selected with matched AA and WA. These (behavior,seed) 
%   combinations were saved as a text list for each seed (i.e. for current seed, which behavioral 
%   measures were chosen). <use_seed_bhvr_dir> is the folder contains these text files. They are the 
%   outputs of '../match_split/HCP_select_matched_seeds.m'. 
%
% - out_pCOD
%   Full path of the output .mat file saving the predictive COD metric.
%
% - out_corr
%   Full path of the output .mat file saving the Pearson's correlation accuracies.
%
% - mtch_bhvr_ls
%   The list of behavioral measures for which the matched AA and WA can be found.
%
% - full_bhvr_ls
%   The list of all 58 behavioral measures.
%
% - subj_ls
%   Full path of the subject list.
%
% Author: Jingwei Li

if(~exist('num_test_folds', 'var') || isempty(num_test_folds))
    num_test_folds = 10;
end
nseeds = 40;

[mtch_bhvr, n_mtch] = CBIG_text2cell(mtch_bhvr_ls);
full_bhvr = CBIG_text2cell(full_bhvr_ls);
[~,~,b_ind] = intersect(mtch_bhvr, full_bhvr, 'stable');

[subjects, nsub] = CBIG_text2cell(subj_ls);

%%
seed_counts = zeros(1, n_mtch);
COD_AA = nan(nseeds, n_mtch);  COD_WA = COD_AA;  COD_comb = COD_AA;
ss_res_AA_all = nan(nseeds, n_mtch);  ss_res_WA_all = ss_res_AA_all;  
ss_res_comb_all = ss_res_AA_all;  ss_total_all = ss_res_AA_all;
yt_AA_all = cell(nseeds, n_mtch);  yp_AA_all = yt_AA_all;
yt_WA_all = yt_AA_all;  yp_WA_all = yt_WA_all;
yt_train_AA_all = yt_AA_all;  yt_train_WA_all = yt_AA_all;
yt_AA_match_all = yt_AA_all;  yp_AA_match_all = yt_AA_all;
yt_WA_match_all = yt_AA_all;  yp_WA_match_all = yt_AA_all;
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

        yt_AA = []; yp_AA = []; yt_train_AA = []; yt_AA_match = []; yp_AA_match = [];
        yt_WA = []; yp_WA = []; yt_train_WA = []; yt_WA_match = []; yp_WA_match = [];
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

            [~,~, Aind_match] = intersect(AA_fold.sub_perfold{fold}, subjects, 'stable');
            curr_yt_AA_match = y_resid(Aind_match);
            curr_yp_AA_match = curr_result.y_predict_concat(Aind_match);
            yt_AA_match = [yt_AA_match; curr_yt_AA_match];
            yp_AA_match = [yp_AA_match; curr_yp_AA_match];
            
            [~, Wind] = intersect(subjects, best_assign{b_ind(b)}{fold}, 'stable');
            curr_yt_WA = y_resid(Wind);
            [~, Wind_train] = intersect(subjects, ...
                cat(1, best_assign{b_ind(b)}{setdiff(1:num_test_folds, fold)}), 'stable');
            curr_yt_train_WA = y_resid(Wind_train);
            yt_WA = [yt_WA; curr_yt_WA];
            yt_train_WA = [yt_train_WA; curr_yt_train_WA];
            curr_yp_WA = curr_result.y_predict_concat(Wind);
            yp_WA = [yp_WA; curr_yp_WA];

            [~,~, Wind_match] = intersect(best_assign{b_ind(b)}{fold}, subjects, 'stable');
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

%% check which behavioral measures have positive COD
if(~exist(fullfile(KRR_dir, 'lists', 'pCOD_union_pos_behaviors.txt'), 'file'))
    mean_COD_comb = nanmean(COD_comb, 1);
    CBIG_cell2text(mtch_bhvr(mean_COD_comb>0), fullfile(KRR_dir, 'lists', ...
        'pCOD_comb_pos_behaviors.txt'))

    mean_COD_AA = nanmean(COD_AA, 1);
    CBIG_cell2text(mtch_bhvr(mean_COD_AA>0), fullfile(KRR_dir, 'lists', ...
        'pCOD_AA_pos_behaviors.txt'))

    mean_COD_WA = nanmean(COD_WA, 1);
    CBIG_cell2text(mtch_bhvr(mean_COD_WA>0), fullfile(KRR_dir, 'lists', ...
        'pCOD_WA_pos_behaviors.txt'))

    CBIG_cell2text(mtch_bhvr( mean_COD_AA>0 | mean_COD_WA>0 ), ...
        fullfile(KRR_dir, 'lists', 'pCOD_union_pos_behaviors.txt'))
end

%% check which behavioral measures have positive Pearson's correlation
if(~exist(fullfile(KRR_dir, 'lists', 'corr_union_pos_behaviors.txt'), 'file'))
    mean_corr_comb = nanmean(corr_comb, 1);
    CBIG_cell2text(mtch_bhvr(mean_corr_comb>0), fullfile(KRR_dir, 'lists', ...
        'corr_comb_pos_behaviors.txt'))

    mean_corr_AA = nanmean(corr_AA, 1);
    CBIG_cell2text(mtch_bhvr(mean_corr_AA>0), fullfile(KRR_dir, 'lists', ...
        'corr_AA_pos_behaviors.txt'))

    mean_corr_WA = nanmean(corr_WA, 1);
    CBIG_cell2text(mtch_bhvr(mean_corr_WA>0), fullfile(KRR_dir, 'lists', ...
        'corr_WA_pos_behaviors.txt'))

    CBIG_cell2text(mtch_bhvr( mean_corr_AA>0 | mean_corr_WA>0 ), ...
        fullfile(KRR_dir, 'lists', 'corr_union_pos_behaviors.txt'))
end
    
end