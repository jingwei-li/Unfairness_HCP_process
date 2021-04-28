function HCP_pheno_var_AAvsWA_matched(split_AAdir, split_WAdir, outname, full_subj_ls, mtch_bhvr_ls, ...
    full_bhvr_ls, max_seed, mtch_lists_dir, restricted_csv, unrestricted_csv)

% HCP_pheno_var_AAvsWA_matched(split_AAdir, split_WAdir, outname, full_subj_ls, mtch_bhvr_ls, ...
%     full_bhvr_ls, max_seed, mtch_lists_dir, restricted_csv, unrestricted_csv)
%
% Conduct Levene's test to compare the variances of behavioral scores between matched
% AA and WA.
%
% Inputs:
%   - split_AAdir
%     The directory which contains the split folds of selected AA (full path).
%   - split_WAdir
%     The directory containing the matched WA (full path).
%   - outname
%
%   - full_subj_ls
%     Full path of the list containing all subject IDs.
%   - mtch_bhvr_ls
%     Full path of the list of behavioral measures for which matched AA & WA can be found.
%   - full-bhvr_ls
%     Full path of the list of all behavioral measures, including the ones for which matched
%     AA & WA cannot be found.
%   - max_seed
%     The maximal repetitions of data splitting. It should be the same as the maximal seed 
%     used for 'HCP_split_AA_rm_hardtomatch.m'.
%   - mtch_lists_dir
%     The directory containing the selected (seed, behavior) combinations where the AA and WA
%     were matched. It is the output directory of 'HCP_select_matched_seeds.m'.
%   - restricted_csv (optional)
%     Full path of the HCP restricted CSV file. Default (on the CSC server):
%     '/mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/scripts/restricted_hcp_data/...
%     RESTRICTED_jingweili_4_12_2017_1200subjects_fill_empty_zygosityGT_by_zygositySR.csv'
%   - unrestricted_csv (optional)
%     Full path of the HCP unrestricted CSV file. Default (on the CSC server):
%     '/mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/scripts/subject_measures/...
%     unrestricted_jingweili_12_7_2017_21_0_16_NEO_A_corrected.csv'
%
% Author: Jingwei Li

%% set default parameters
HCP_dir = '/mnt/isilon/CSC1/Yeolab/Data/HCP';
if(~exist('restricted_csv', 'var') || isempty(restricted_csv))
    restricted_csv = fullfile(HCP_dir, 'S1200', 'scripts', 'restricted_hcp_data', ...
        'RESTRICTED_jingweili_4_12_2017_1200subjects_fill_empty_zygosityGT_by_zygositySR.csv');
end
if(~exist('unrestricted_csv', 'var') || isempty(unrestricted_csv))
    unrestricted_csv = fullfile(HCP_dir, 'S1200', 'scripts', 'subject_measures', ...
        'unrestricted_jingweili_12_7_2017_21_0_16_NEO_A_corrected.csv');
end

alpha = 0.05;
n_valid_seeds = 40;

%% read input data
[full_subj, nsub] = CBIG_text2cell(full_subj_ls);
[mtch_bhvr, n_mtch] = CBIG_text2cell(mtch_bhvr_ls);
[full_bhvr, nbhvr] = CBIG_text2cell(full_bhvr_ls);
[~, ~, b_idx] = intersect(mtch_bhvr, full_bhvr, 'stable');

categories = cell(1, nbhvr);
categories(:) = {'continuous'};
[y] = CBIG_read_y_from_csv( {restricted_csv, unrestricted_csv}, 'Subject', ...
    mtch_bhvr, categories, full_subj_ls, 'NONE', ',' );

%% read behavioral scores of AA and WA; conduct Levene's test
seed_per_bhvr = zeros(n_mtch, 1);
p = zeros(n_mtch, n_valid_seeds);
stats = zeros(n_mtch, n_valid_seeds);
for seed = 1:max_seed
    mtch_txt = fullfile(mtch_lists_dir, ['usable_behaviors_seed' num2str(seed) '.txt']);
    if(~exist(mtch_txt, 'file'))
        % if no behavioral measure was selected for the current seed, skip
        continue
    end
    usable_bhvr = CBIG_text2cell(mtch_txt);

    load(fullfile(split_AAdir, ['split_seed' num2str(seed) '.mat']))
    %%%%%%%%%%% for the author's own debugging purpose
    if(~exist('AA_fold', 'var'))
        AA_fold = Afr_fold;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    AA = cat(1, AA_fold.sub_perfold{:});
    [~, idxAA] = intersect(full_subj, AA, 'stable');

    for b = 1:n_mtch
        % only operate on the matched behavioral measures
        if(any(strcmp(usable_bhvr, mtch_bhvr{b})))
            seed_per_bhvr(b) = seed_per_bhvr(b) + 1;

            % collect behavioral scores for WA and AA separately
            load(fullfile(split_WAdir, ['split_seed' num2str(seed), '.mat']))
            best_assign = best_assign(b_idx);
            WA = cat(1, best_assign{b}{:});
            [~, idxWA] = intersect(full_subj, WA, 'stable');
            mWA = y(idxWA, b);
            mAA = y(idxAA, b);

            % Levene's test
            [curr_p, curr_stats] = vartestn([mWA; mAA], [ones(length(mWA),1); 2.*ones(length(mAA),1)], ...
                'TestType', 'LeveneAbsolute', 'Display', 'off');
            p(b, seed_per_bhvr(b)) = curr_p;
            stats(b, seed_per_bhvr(b)) = curr_stats.fstat;
        end
    end
end

%% FDR correction
H_idx = FDR(p(:), alpha);
H_FDR = zeros(size(p));
H_FDR(H_idx) = 1;

outdir = fileparts(outname);
if(~exist(outdir, 'dir'))
    mkdir(outdir)
end
save(outname, 'p', 'stats', 'H_FDR', 'y', 'alpha')

end