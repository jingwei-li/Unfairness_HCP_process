function HCP_select_matched_seeds(split_AAdir, split_WAdir, stats_fname, nseeds, bhvr_ls, outdir)

% HCP_select_matched_seeds(split_AAdir, split_WAdir, stats_fname, nseeds, bhvr_ls, outdir)
%
% Transform the statistical testing results of `HCP_AA_WA_match_diff.m` into lists of behavrioal 
% measures which can find matched WA with AA for each random split.
% Note that for each behavioral measure, 40 random splits with matched AA & WA are needed. Hence
% the first 40 seeds with matched AA & WA will be written into the lists. 
%
% Inputs:
%   - split_AAdir
%     Full path of the directory storing the split folds of African Americans.
%     It is the output of `HCP_split_AA_rm_hardtomatch.m`.
%   - split_WAdir
%     Full path of the directory storing the white Americans that were matched to African Americans.
%     It is the output of `HCP_match_WA_with_AAfolds.sh`.
%   - stats_fname
%     Full path of the statistical testing for the significance of demographic & behavioral 
%     distribution difference between AA and WA. It is the output .mat file of 
%     `HCP_AA_WA_match_diff.m`.
%   - nseeds
%     Total number of random repetitions of data splitting. It needs to be consistent with the 
%     maximal seed used for `HCP_split_AA_rm_hardtomatch`.
%   - bhvr_ls
%     Full path of the list of behavioral measures. 
%   - outdir
%     Output directory (full path).
%
% Author: Jingwei Li

%% settup; load input data
stats = load(stats_fname);

%%%%%%% for the author's debugging purpose
if(~isfield(stats, 'matched_mtx'))
    stats.matched_mtx = stats.usable_mtx;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(size(stats.matched_mtx, 1) ~= nseeds)
    error('Number of seeds in stats file deviates from the expected.')
end

[behaviors, nbehav] = CBIG_text2cell(bhvr_ls);
seeds_need = 40;
if(~exist(outdir, 'dir'))
    mkdir(outdir);
end

%% find the behavioral measures which have >=40 random splits with matched AA & WA
Nmatched = sum(stats.matched_mtx, 1);
avail_behav = behaviors(Nmatched>=seeds_need);
behav_perseed = cell(nseeds, 1);
Nmatched_new = Nmatched(Nmatched>=seeds_need);
Nmatched_new = ones(1, length(avail_behav)) * seeds_need;
matched_mtx = stats.matched_mtx(:, Nmatched>=seeds_need);

%% for each seed, write the behavioral names with matched AA & WA into a list
count = 0;
for seed = 1:nseeds
    for b = 1:length(avail_behav)
        if(matched_mtx(seed, b) == 1 && Nmatched_new(b)>0)
            count = count + 1;
            behav_perseed{seed} = [behav_perseed{seed} avail_behav(b)];
            Nmatched_new(b) = Nmatched_new(b) - 1;
        end
    end
    
    if(~isempty(behav_perseed{seed}))
        ofile = fullfile(outdir, ['usable_behaviors_seed' num2str(seed) '.txt']);
        CBIG_cell2text(behav_perseed{seed}, ofile);
    end
    
    if(all(Nmatched_new == 0))
        break;
    end
end

end