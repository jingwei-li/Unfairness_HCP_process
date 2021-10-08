function HCP_KRR_training_prediction(model_dir, max_seed, bhvr_ls, LITE)

% HCP_KRR_training_prediction(model_dir, max_seed, bhvr_ls, LITE)
%
%


%% KRR default parameters
with_bias = 1;
bin_flag= 0;
metrics = {'corr','COD','predictive_COD','MAE','MAE_norm','MSE','MSE_norm'};
ker_param.type = 'corr';
ker_param.scale = NaN;

%% default input arguments
if(~exist('LITE', 'var') || isempty(LITE))
    LITE = true;
end

[bhvr_nm, nbhvr] = CBIG_text2cell(bhvr_ls);

if(ischar(max_seed))
    max_seed = str2num(max_seed);
end

for seed = 1:max_seed
    for b = 1:nbhvr
        KRR_dir = fullfile(model_dir, ['randseed_' num2str(seed)], bhvr_nm{b});
        if(exist(KRR_dir, 'dir'))
            % load sub_fold, load KRR optimal parameters
            opt = load(fullfile(KRR_dir, ['final_result_' bhvr_nm{b} '.mat']));
            load(fullfile(KRR_dir, ['no_relative_10_fold_sub_list_' bhvr_nm{b} '.mat']))

            % Load FSM. If file doesn't exist, create on fly.
            if(LITE)
                FSM_name = fullfile(KRR_dir, 'FSM', 'FSM_corr.mat')
                load(FSM_name)
                size(FSM)
            end

            for f = 1:length(sub_fold)
                % load regressed y, select the training subjects
                y = load(fullfile(KRR_dir, 'y', ['fold_' num2str(f)], ['y_regress_' bhvr_nm{b} '.mat']));
                y_resid = y.y_resid(sub_fold(f).fold_index==0);
                y_orig = y.y_orig(sub_fold(f).fold_index==0);

                % select FSM among training subjects
                length(sub_fold(f).fold_index)
                if(LITE)
                    kernel_train = FSM(sub_fold(f).fold_index==0, sub_fold(f).fold_index==0);
                else
                    FSM_name = fullfile(KRR_dir, 'FSM_innerloop', ['fold_' num2str(f)], 'FSM_corr.mat');
                    load(FSM_name)
                    kernel_train = FSM; clear FSM;
                end

                % train KRR with optimal hyperparameters, and predict behaviors of training subjects
                [y_p, y_t, acc, pred_stats] = CBIG_KRR_test_cv_training_scores( bin_flag, kernel_train, ...
                    y_resid, y_orig, with_bias, opt.optimal_lambda(f), opt.optimal_threshold(f), metrics );

                % save prediction results of training subjects
                outdir = fullfile(KRR_dir, 'test_cv', ['fold_' num2str(f)]);
                save(fullfile(outdir, ['opt_training_set_' bhvr_nm{b}, '.mat']), 'y_p', 'y_t', 'acc', 'pred_stats')
            end
        end
    end
end

    
end