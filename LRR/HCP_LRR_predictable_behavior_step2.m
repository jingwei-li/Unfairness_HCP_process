function HCP_LRR_predictable_behavior_step2(FC_file, LRR_dir, start_iter, maxLRR_iter, Nperm, bhvr_nm)

    % HCP_LRR_predictable_behavior_step2(FC_file, LRR_dir, start_iter, maxLRR_iter, Nperm, bhvr_nm)
    %
    % Inputs:
    %   - FC_file
    %     The RSFC mat file (full path) of all subjects involved in the cross-validation.
    %   - LRR_dir
    %     The directory which contains the elastic net trained models and testing results.
    %   - maxLRR_iter
    %     Maximal random seed used to split the training-test folds for performing elastic net, e.g. 400.
    %   - Nperm
    %     Number of premutations.
    %   - bhvr_nm
    %     Current behavioral measure.
    %
    % Author: Jingwei Li

    %% load and reshape RSFC 
    load(FC_file)
    features = reshape3d_to_2d(corr_mat);

    %% Read covariates which need to be regressed out from RSFC
    cov_X = load(fullfile(LRR_dir, 'cov_X_58behaviors.mat'));

    %% calculate permuted elastic net accuracies
    load(fullfile(LRR_dir, 'Pset.mat'))
    metrics = {'corr','COD','predictive_COD','MAE','MAE_norm','MSE','MSE_norm'};
    LRR_perm(features, cov_X.covariates, LRR_dir, start_iter, maxLRR_iter, Nperm, Pset, bhvr_nm, metrics)

end


function LRR_perm(features, cov_X, LRR_dir, start_iter, maxLRR_iter, Nperm, Pset, bhvr_nm, metrics)

    % LRR_perm(features, cov_X, LRR_dir, maxLRR_iter, Nperm, Pset, bhvr_nm, metrics)
    %
    % 

    for i = start_iter:maxLRR_iter
        subdir = fullfile(LRR_dir, ['randseed_' num2str(i)], bhvr_nm);
        if(~exist(subdir, 'dir'))
            continue
        end

        fprintf('seed: %d, %s\n', i, bhvr_nm)
        load(fullfile(LRR_dir, ['randseed_' num2str(i)], bhvr_nm, ...
            ['no_relative_10_fold_sub_list_' bhvr_nm '.mat']));
        Nfolds = length(sub_fold);

        acc_out = fullfile(LRR_dir, ['randseed_' num2str(i)], bhvr_nm, 'perm.mat');
        if(exist(acc_out, 'file'))
            continue
        end

        for f = 1:Nfolds
            test_ind = sub_fold(f).fold_index==1;
            train_ind = ~test_ind;

            %% load cross-validatedly regressed behavioral scores
            y_reg = load(fullfile(LRR_dir, ['randseed_' num2str(i)], bhvr_nm, 'y', ...
                ['fold_' num2str(f)], ['y_regress_' bhvr_nm '.mat']));

            %% split training vs test data for RSFC
            feat_train = features(:, train_ind);
            feat_test = features(:, test_ind);

            %% do confound regression from features, if necessary
            if(~isempty(cov_X) && ~strcmpi(cov_X, 'none'))
                cov_X_mean = mean(cov_X(train_ind, :), 1);
                [feat_train, beta] = CBIG_regress_X_from_y_train(feat_train', ...
                    cov_X(train_ind, :));
                beta_pre = load(fullfile(LRR_dir, ['randseed_' num2str(i)], bhvr_nm, ...
                    'params', ['fold_' num2str(f)], 'feature_regress_beta.mat'));
                if(max(abs(beta(:) - beta_pre.beta(:))) > 1e-8)
                    error('[Regression from RSFC]: beta differred from original elastic net results')
                end

                feat_test = CBIG_regress_X_from_y_test(feat_test', ...
                    cov_X(test_ind, :), beta, cov_X_mean);
                feat_train = feat_train';  feat_test = feat_test';
            end

            %% load optimal parameters selected in inner-loops
            params_file = fullfile(LRR_dir, ['randseed_' num2str(i)], bhvr_nm, 'params', ...
                ['fold_' num2str(f)], ['selected_parameters_' bhvr_nm '.mat']);
            opt_params = load(params_file)

            %% multilevel block permute y, run elastic net based on permuted y
            for p = 2:Nperm+1
                rng('default')
                rng(1)

                % permute y
                y_perm = y_reg.y_resid(Pset(:,p));
                y_train = y_perm(train_ind);
                y_test = y_perm(test_ind);

                % select features
                if opt_params.curr_threshold ~= 1
                    [feat_train, feat_test] = CBIG_FC_FeatSel( feat_train, feat_test, y_train, ...
                        opt_params.curr_threshold );
                end

                Mdl = fitrlinear(feat_train, y_train, 'ObservationsIn', 'columns', 'Lambda', ...
                    opt_params.curr_lambda, 'Learner', 'leastsquares', 'Regularization','ridge');
                y_p = predict(Mdl, feat_test, 'ObservationsIn', 'columns');

                for k = 1:length(metrics)
                    stats_perm.(metrics{k})(f,p-1) = ...
                        CBIG_compute_prediction_acc_and_loss(y_p, y_test, metrics{k}, y_train);
                end
            end
        end
        save(acc_out, 'stats_perm')
        system(sprintf('ls -l %s', acc_out))
    end
    
end


function out = reshape3d_to_2d(features)
    % reshapes a #ROI x #ROI x #subjects matrix into
    % #ROI x #subjects by extracting the lower triangle
    % of the correlation
    temp = ones(size(features,1), size(features,2));
    tril_ind = tril(temp, -1);
    features_reshaped = reshape(features, size(features,1)*size(features,2), size(features, 3));
    out = features_reshaped(tril_ind==1, :);
end