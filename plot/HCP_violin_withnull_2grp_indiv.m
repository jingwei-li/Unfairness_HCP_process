function HCP_violin_withnull_2grp_indiv(data, null_data, colormat, y_label, legends, tit, colloq_nm, ...
    sigdiff_idx, outdir, outstem, metric)

% HCP_violin_withnull_2grp_indiv(data, null_data, colormat, y_label, legends, tit, colloq_nm, ...
%     sigdiff_idx, outdir, outstem, metric)
%
% General violin plot function for plotting the accuracy difference of each individual
% behavioral measure.
%
% Inputs:
% - data
%   A matrix with dimensions: 3 x #random splits x #behavior. data(1,:,:) are the accuracies
%   of group 1 across all random data splits and all behavioral measures. data(2,:,:) are the
%   accuracies of group 2. data(3,:,:) = data(2,:,:) - data(1,:,:).
%
% - null_data
%   #permutations x #behaviors matrix. The null distribution of accuracy difference.
%
% - colormat
%   4 x 3 color mat, each row is the RGB of one group.
%
% - y_label
%   Y-axis label.
%
% - legends
%   A cell with 4 entries. Legend for each group, the actual difference, and the null 
%   distribution of difference.
%
% - tit
%   Figure title.
% 
% - colloq_nm
%   A cell containing the colloquial names of each behavioral measure. Ordering of the names 
%   should be consistent with the ordering in 'data'
% 
% - sigdiff_idx
%   The indices of behavioral measures which showed significant accuracy difference between 
%   AA and WA.
%
% - outdir
%   Output directory (full path).
% 
% - outstem
%   File stem of output figures.
%
% - metric
%   Accuracy metric. Choose from 'predictive_COD' and 'corr'.
%
% Author: Jingwei Li

nbhvr = size(data, 3);

if(~exist('metric', 'var'))
    metric = 'predictive_COD';
end

f = figure;
hold on
step = 0.3; width = 0.12;
if(nbhvr<20)
    med_circle = 16;
    med_line = 2;
    sc_circle = 8;
else
    med_circle = 3;
    med_line = 0.5;
    sc_circle = 2;
end

vio{1} = violinplot(squeeze(data(1,:,:)), [], [1:nbhvr]-step, 'ViolinColor', colormat(1,:), 'ShowMean', true, 'Width', width);
vio{2} = violinplot(squeeze(data(2,:,:)), [], [1:nbhvr], 'ViolinColor', colormat(2,:), 'ShowMean', true, 'Width', width);
vio{4} = violinplot(null_data, [], [1:nbhvr]+step, 'ViolinColor', colormat(4,:), 'ShowMean', true, 'Width', width+0.05, 'PlotPos', 'right');
vio{3} = violinplot(squeeze(data(3,:,:)), [], [1:nbhvr]+step, 'ViolinColor', colormat(3,:), 'ShowMean', true, 'Width', width, 'PlotPos', 'left');

for i = 1:4
    for b = 1:nbhvr
        vio{i}(b).ViolinPlot.LineWidth = 2;
        %vio{i}(b).ScatterPlot.Marker = '.';
        vio{i}(b).ScatterPlot.SizeData = sc_circle;
        vio{i}(b).MedianPlot.SizeData = med_circle;
        vio{i}(b).MedianPlot.LineWidth = med_line;
    end
end

xlimit = get(gca, 'xlim');
plot(xlimit, [0 0], ':k');
hold off

if(nbhvr == 1)
    set(gca, 'xlim', [xlimit(1) xlimit(2)*0.6])
end

pf = get(gcf, 'position');
set(gcf, 'position', [0 0 100+115*nbhvr 900])
set(gca, 'position', [0.35 0.4 0.6 0.5])

if(strfind(metric, 'COD'))
    ylm = get(gca, 'ylim');
    if(ylm(1)<-1)
        ylm(1) = -1;
        warning('There are behaviors with accuracy lower than -1.')
    end
    if(ylm(2)>2)
        ylm(2) = 1;
        warning('There are values higher than 1.')
    end
    set(gca, 'ylim', ylm, 'ytick', [ylm(1):0.2:ylm(2)]);
end
yl = ylabel(y_label);
set(yl, 'fontsize', 16, 'linewidth', 2)

l = legend([vio{1}(1).ViolinPlot vio{2}(1).ViolinPlot vio{3}(1).ViolinPlot vio{4}(1).ViolinPlot], legends);
set(l, 'fontsize', 12, 'linewidth', 2, 'location', 'best', 'box', 'off')

set(gca, 'xticklabel', colloq_nm, 'fontsize', 16, 'linewidth', 2);
if(nbhvr>1)
    rotateXLabels( gca(), 45 );
end
set(gca, 'tickdir', 'out', 'box', 'off')

% plot * on the significant behaviors
if(~isempty(sigdiff_idx))
    ylimvals = get(gca, 'ylim');
    ylimvals_new = ylimvals;
    ylimvals_new(2) = (ylimvals(2)-ylimvals(1))*0.08 + ylimvals(2);
    set(gca, 'ylim', ylimvals_new)
    lp = get(l, 'position');
    if(lp(2)>0.5)
        lp(2) = lp(2) - 0.03;
    end
    set(l, 'position', lp)
    text(sigdiff_idx, repmat(ylimvals(2), size(sigdiff_idx)), '*');
end

if(~isempty(tit))
    title(tit, 'fontsize', 16)
end

outname = fullfile(outdir, [outstem ]);
export_fig(outname, '-png', '-nofontswap', '-a1');
set(gcf, 'color', 'w');
hgexport(f, outname)
close

end
