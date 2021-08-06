function HCP_violin_LRR_acc_allsubj_matchedBehav(model_dir, maxLRR_iter, metric, outdir, outstem, bhvr_ls, colloq_ls)

% HCP_whisker_LRR_acc_allsubj_matched_Behav(model_dir, maxLRR_iter, metric, outdir, outstem. bhvr_ls, colloq_ls)
%
% Plot the model performance in general (i.e. the accuracy on the whole test sets).

addpath(genpath( fullfile(getenv('HOME'), 'storage', 'from_HOME', 'code', 'plotting_functions')))
colormat = [200, 200, 200]./255;
metrics = {'corr','COD','predictive_COD','MAE','MAE_norm','MSE','MSE_norm'};

proj_dir = fullfile(getenv('HOME'), 'storage', 'MyProject', 'fairAI', 'HCP_race');
if(~exist('bhvr_ls', 'var') || isempty(bhvr_ls))
    bhvr_ls = fullfile(proj_dir, 'scripts', 'lists', 'Cognitive_Personality_Task_Social_Emotion_51_matched.txt');
end
if(~exist('colloq_ls', 'var') || isempty(colloq_ls))
    colloq_ls = fullfile(proj_dir, 'scripts', 'lists', 'colloquial_names_51_matched.txt');
end

[bhvr_nm, nbhvr] = CBIG_text2cell(bhvr_ls);
[colloq_nm, ncolloq] = CBIG_text2cell(colloq_ls);
if(ncolloq ~= nbhvr)
    error('Number of behavioral names is not equal to number of colloquial names.')
end

%% collect the data to plot
data = [];
for b = 1:nbhvr
    curr_avg_stats = [];
    for i = 1:maxLRR_iter
        opt_fname = fullfile(model_dir, ['randseed_' num2str(i)], bhvr_nm{b}, ...
            'results', 'optimal_acc', [bhvr_nm{b} '.mat']);
        if(~exist(opt_fname, 'file'))
            continue
        end
        opt = load(opt_fname);

        Nfolds = length(opt.optimal_statistics);
        curr_stats = zeros(Nfolds, 1);
        for f = 1:Nfolds
            curr_stats(f) = opt.optimal_statistics{f}.(metric);
        end

        curr_avg_stats = cat(1, curr_avg_stats, nanmean(curr_stats, 1));
    end
    data = cat(2, data, curr_avg_stats);
end
[~, idx] = sort(mean(data,1), 'descend');
data = data(:, idx);
bhvr_nm = bhvr_nm(idx);
colloq_nm = colloq_nm(idx);

%% plot
f = figure('visible', 'off');
vio = violinplot(data, [], [], 'ViolinColor', colormat, 'ShowMean', true);
for i = 1:length(vio)
    vio(i).ViolinPlot.LineWidth = 2;
    %vio(i).ScatterPlot.Marker = '.';
    vio(i).ScatterPlot.SizeData = 12;
    vio(i).MedianPlot.SizeData = 18;
end
hold on
xlimit = get(gca, 'xlim');
plot(xlimit, [0 0], ':k');
hold off

pf = get(gcf, 'position');
set(gcf, 'position', [0 0 100+50*nbhvr 900])
set(gca, 'position', [0.35 0.4 0.6 0.5])

switch metric
    case 'corr'
        y_label = 'Cross-validated Pearson''s r';
    case 'predictive_COD'
        y_label = 'Cross-validated predictive COD';
    case 'COD'
        y_label = 'Cross-validated COD';
    otherwise
        error('Unknown metric')
end
yl = ylabel(y_label);
set(yl, 'fontsize', 16, 'linewidth', 2)

set(gca, 'xticklabel', colloq_nm, 'fontsize', 16, 'linewidth', 2);
rotateXLabels( gca(), 45 );
set(gca, 'tickdir', 'out', 'box', 'off')

mkdir(outdir)
outname = fullfile(outdir, [outstem ]);
export_fig(outname, '-png', '-nofontswap', '-a1');
set(gcf, 'color', 'w');
hgexport(f, outname)
close

rmpath(genpath( fullfile(getenv('HOME'), 'storage', 'from_HOME', 'code', 'plotting_functions')))

    
end