function HCP_combine_AA_WA_others_folds(AAsplit, WAsplit, other_split, subj_ls, full_bhvr_ls, ...
    matched_bhvr_ls, outdir)

% HCP_combine_AA_WA_others_folds(AAsplit, WAsplit, other_split, subj_ls, full_bhvr_ls, ...
%     matched_bhvr_ls, outdir)
%
% Going through the previous steps, you should have obtained the split folds of selected AA, the matched
% WA, and the folds of the remaining subjects.
% This function combines the 3 types of folds together for each random seed. Write the combined folds
% into a data structure that is adaptive to the kernel regression package.
%
% Inputs:
%   - AAsplit
%     The split folds of selected AA (full path) for the current random repetition.
%     It is the output of `HCP_split_AA_rm_hardtomatch.m`.
%   - WAsplit
%     The folds of WA that were matched to AA for the current random repetition (full path).
%     It is the output of `HCP_match_WA_with_AAfolds.m/.sh`.
%   - other_split
%     The split folds of the remaining subjects except the selected AA and matched WA, for current
%     repetition (full path). It is the output of `HCP_split_except_selectedAAWA.m/.sh`.
%   - subj_ls
%     Full path of the subject list.
%   - full_bhvr_ls
%     The list of all behavioral names (full path).
%   - matched_bhvr_ls
%     For current random repetition, some behavioral measures may not have matched AA and WA. This 
%     contains the behavioral measures which have matched AA and WA.
%     It is the output of `HCP_select_matched_seeds.m`.
%   - outdir
%     Output directory (full path).
%
% Author: Jingwei Li

%% load input variables; sanity checks
load(AAsplit)
load(WAsplit)
load(other_split)

%%%%%%%%%%%%% for the author's debugging purpose
if(~exist('AA_fold', 'var'))
    AA_fold = Afr_fold;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nfolds = length(AA_fold.sub_perfold);
[subjects, nsub] = CBIG_text2cell(subj_ls);
[full_bhvr, nbhvr] = CBIG_text2cell(full_bhvr_ls);
use_bhvr = CBIG_text2cell(matched_bhvr_ls);
[~, use_idx] = intersect(full_bhvr, use_bhvr, 'stable');

assert(length(best_assign) == nbhvr, ...
    'Number of behavioral measures in WAsplit differs from the ones in full_bhvr_ls')
assert(length(best_assign{1}) == nfolds, ...
    'Number of folds in WAsplit differs from the ones in AAsplit')

if(~exist(outdir, 'dir'))
    mkdir(outdir)
end

%% combine the folds of subjects from all races/ethnicities
for b = 1:nbhvr
    if(~ismember(b, use_idx))
        continue;
    end
    
    fold_list = AA_fold.sub_perfold;
    for f = 1:nfolds
        fold_list{f} = [fold_list{f}; best_assign{b}{f}];
        fold_list{f} = [fold_list{f}; fold_others{b}{f}];
        fold_list{f} = sort(fold_list{f});
    end
    curr_sub = intersect(subjects, cat(1, fold_list{:}), 'stable');

    % construct the cross-validation folds structure which is adaptive to the kernel regression package
    fold_index = cell(nfolds, 1);
    for f = 1:nfolds
        fold_index{f} = zeros(length(curr_sub),1);
        for j = 1:size(fold_list{f},1)
            fold_index{f} = fold_index{f} + (strcmp(curr_sub, fold_list{f}{j}));
        end
        fold_index{f} = logical(fold_index{f});
    end
    sub_fold = struct('subject_list', fold_list, 'fold_index', fold_index);
    sub_fold(1).all_subjects = curr_sub;
    save(fullfile(outdir, ['no_relative_' num2str(nfolds) '_fold_sub_list_' behaviors{b} '.mat']), 'sub_fold');
end
    
end