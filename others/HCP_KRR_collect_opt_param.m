function HCP_KRR_collect_opt_param(model_dir, max_seed, mtch_seed_lsdir, bhvr_ls)

% HCP_KRR_collect_opt_param(model_dir, max_seed, mtch_seed_lsdir, bhvr_ls)
%
% 

proj_dir = fullfile(getenv('HOME'), 'storage', 'MyProject', 'fairAI', 'HCP_race');
if(~exist('bhvr_ls', 'var') || isempty(bhvr_ls))
    bhvr_ls = fullfile(proj_dir, 'scripts', 'lists', ...
        'Cognitive_Personality_Task_Social_Emotion_51_matched.txt');
end

used_seeds = 40;
Nfolds = 10;
[bhvr_nm, nbhvr] = CBIG_text2cell(bhvr_ls);

opt_lambda = zeros(used_seeds, nbhvr, Nfolds);
counts = zeros(nbhvr,1);
for seed = 1:max_seed
    mtch_bhvr_ls = fullfile(mtch_seed_lsdir, ['usable_behaviors_seed' num2str(seed) '.txt']);
    if(~exist(mtch_bhvr_ls, 'file')); continue; end
    mtch_bhvr = CBIG_text2cell(mtch_bhvr_ls);
    for b = 1:nbhvr
        if(any(strcmp(mtch_bhvr, bhvr_nm{b})))
            counts(b) = counts(b) + 1;
            opt = load(fullfile(model_dir, ['randseed_' num2str(seed)], bhvr_nm{b}, ...
                ['final_result_' bhvr_nm{b} '.mat']));
            opt_lambda(counts(b), b, :) = opt.optimal_lambda;
        end
    end
end

mode_lambda = zeros(nbhvr,1);
for b = 1:nbhvr
    tmp = opt_lambda(:,b,:);
    mode_lambda(b) = mode(tmp(:));
end

save(fullfile(model_dir, 'optimal_lambda.mat'), 'opt_lambda', 'mode_lambda')
    
end