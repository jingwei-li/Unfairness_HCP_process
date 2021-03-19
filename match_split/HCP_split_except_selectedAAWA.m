function HCP_split_except_selectedAAWA(full_subj_ls, bhvr_ls, seed, AAsplit, WAsplit, outmat, restricted_csv)

% HCP_split_except_selectedAAWA(full_subj_ls, bhvr_ls, seed, AAsplit, WAsplit, outmat, restricted_csv)
%
% Split the subjects from other ethnic/racial groups and the unselected AA and WA into 10 folds.
%
% Inputs:
%   - full_subj_ls
%     Full path of the list of all subject IDs.
%   - bhvr_ls
%     Full paht of the behavioral names list.
%   - seed
%     The current random seed used for data split. The seed range should be within the range used for
%     `HCP_split_AA_rm_hardtomatch.m`.
%   - AAsplit
%     Full path of the .mat containing the split AA for current random seed.
%     It is the output file of `HCP_split_AA_rm_hardtomatch.m`.
%   - WAsplit
%     Full path of the .mat containing the selected WA to match with AA, for current random seed.
%     It is the output file of `HCP_match_WA_AAfolds.m`.
%   - outmat
%     Full path of the output .mat file.
%   - restricted_csv (optional)
%     Full path of the HCP restricted CSV file. Default (on CSC HPC):
%     '/mnt/isilon/CSC1/Yeolab/Data/HCP/S1200/scripts/restricted_hcp_data/...
%     RESTRICTED_jingweili_4_12_2017_1200subjects_fill_empty_zygosityGT_by_zygositySR.csv'
%
% Author: Jingwei Li

%% load input data; sanity check
HCP_dir = '/mnt/isilon/CSC1/Yeolab/Data/HCP/S1200';
if(~exist('restricted_csv', 'var') || isempty(restricted_csv))
    restricted_csv = fullfile(HCP_dir, 'scripts', 'restricted_hcp_data', ...
        'RESTRICTED_jingweili_4_12_2017_1200subjects_fill_empty_zygosityGT_by_zygositySR.csv');
end

outdir = fileparts(outmat);
if(~exist(outdir, 'dir'))
    mkdir(outdir)
end

nfolds = 10;
load(AAsplit)
load(WAsplit)

%%%%%%% for the author's debugging purpose
if(~exist('AA_fold', 'var'))
    AA_fold = Afr_fold;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[behaviors, nbhvr] = CBIG_text2cell(bhvr_ls);
assert(length(best_assign) == nbhvr, ...
    '#behaviors in best_assign differs from #behaviors in bhvr_ls')

[subjects, nsubs] = CBIG_text2cell(full_subj_ls);
[y] = CBIG_parse_delimited_txtfile(restricted_csv, {'Race', 'Family_ID'}, ...
    [], 'Subject', subjects, ',');
Race = y(:,1);
FamilyID = y(:,2);

%% split other subjects for each behavioral measure
for b = 1:nbhvr
    % get list of subjects that were not selected as matched AA, WA
    selected_sub = cat(1, AA_fold.sub_perfold{:});
    selected_sub = cat(1, selected_sub, cat(1, best_assign{b}{:}));
    
    [~, isselected] = intersect(subjects, selected_sub, 'stable');
    isothers = setdiff(1:nsubs, isselected);
    other_sub = subjects(isothers);
    other_fam = FamilyID(isothers);
    uniq_Ofam = unique(other_fam);
    num_Ofam = length(uniq_Ofam);
    
    Osub_perfam = cell(num_Ofam, 1);
    for i = 1:num_Ofam
        fam_ind = strcmp(other_fam, uniq_Ofam{i})==1;
        Osub_perfam{i} = other_sub(fam_ind)';
    end
    
    % split families into folds with random seed
    fold_others{b} = cell(nfolds,1);
    subfold_amount = ceil(length(isothers)/nfolds);
    rng(seed);
    index = randperm(num_Ofam);
    curr_fold = 0;
    i=1;
    assigned = zeros(num_Ofam, 1);
    niter = 0;
    while i <= num_Ofam && any(assigned==0)
        % the first iteration to assign unselected subjects to folds
        if(niter == 0)
            curr_fold = mod(curr_fold,nfolds) + 1;
            while size(fold_others{b}{curr_fold},1)>=subfold_amount
                curr_fold = mod(curr_fold,nfolds) + 1;
            end
            
            % get the families of matched AA in the other 9 folds
            curr_AA = cat(1, AA_fold.sub_perfold{setdiff(1:nfolds, curr_fold)});
            [~,curr_Aind] = intersect(subjects, curr_AA);
            curr_Afam = FamilyID(curr_Aind);
            curr_uniq_fam = unique(curr_Afam);
            
            % get the families of matched WA in the other 9 folds
            curr_WA = cat(1, best_assign{b}{setdiff(1:nfolds, curr_fold)});
            [~,curr_Wind] = intersect(subjects, curr_WA);
            curr_Wfam = FamilyID(curr_Wind);
            curr_uniq_fam = [curr_uniq_fam; unique(curr_Wfam)];
        end

        % if some unselected subjects were not assigned during the first iter, more iterations are needed.
        if(niter>=1)
            non_overlap = [];
            non_overlap_nsub = [];
            for cfold = 1:10
                % get the families of matched AA in the other 9 folds
                cAA = cat(1, AA_fold.sub_perfold{setdiff(1:nfolds, cfold)});
                [~,cAind] = intersect(subjects, cAA);
                cAfam = FamilyID(cAind);
                cuniq_fam{cfold} = unique(cAfam);
                % get the families of matched WA in the other 9 folds
                cWA = cat(1, best_assign{b}{setdiff(1:nfolds, cfold)});
                [~,cWind] = intersect(subjects, cWA);
                cWfam = FamilyID(cWind);
                cuniq_fam{cfold} = [cuniq_fam{cfold}; unique(cWfam)]; 
                % find all folds which have no overlap between 
                % selected AA&WA families and the current family of unselected subjects
                if(~any(strcmp(cuniq_fam{cfold}, uniq_Ofam{index(i)})))
                    non_overlap = [non_overlap cfold];
                    non_overlap_nsub = [non_overlap_nsub size(fold_others{b}{cfold},1)];
                end
            end
            % choose the smallest fold to assign current family
            [~, min_ind] = min(non_overlap_nsub);
            curr_fold = non_overlap(min_ind);
            curr_uniq_fam = cuniq_fam{curr_fold};
        end
        
        % avoid families that were already selected in training folds
        if(~any(strcmp(curr_uniq_fam, uniq_Ofam{index(i)})))
            fold_others{b}{curr_fold} = [fold_others{b}{curr_fold}; Osub_perfam{index(i)}];
            assigned(i) = 1;
        end
        if(any(assigned==0))
            if(i == num_Ofam || i == max(find(assigned==0)))
                i = min(find(assigned==0));
                niter = niter + 1;
            else
                i = i + min(find(assigned(i+1:end)==0));
            end
        else
            break
        end
    end
    
end

save(outmat, 'fold_others');
    
end