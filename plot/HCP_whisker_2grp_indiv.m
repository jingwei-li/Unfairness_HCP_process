function HCP_whisker_2grp_indiv(data, colormat, y_label, legends, tit, colloq_nm, ...
    sigdiff_idx, outdir, outstem, metric)

% HCP_whisker_2grp_indiv(data, colormat, y_label, legends, tit, colloq_nm, ...
%     sigdiff_idx, outdir, outstem, metric)
%
% General whisker plot function for plotting the accuracy difference of each individual
% behavioral measure.
%
% Inputs:
% - data
%   A matrix with dimensions: #random splits x 3 x #behavior. data(:,1,:) are the accuracies
%   of group 1 across all random data splits and all behavioral measures. data(:,2,:) are the
%   accuracies of group 2. data(:,3,:) = data(:,2,:) - data(:,1,:).
%
% - colormat
%   3 x 3 color mat, each row is the RGB of one group.
%
% - y_label
%   Y-axis label.
%
% - legends
%   A cell with 3 entries. Legend for each group and the difference.
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

f = figure('visible', 'off');
if(nbhvr == 1)
    aboxplot(cat(3, data, zeros(size(data))), 'colormap', colormat);
    colloq_nm = [colloq_nm {'N.A.'}];
else
    aboxplot(data, 'colormap', colormat)
end
hold on
xlimit = get(gca, 'xlim');
plot(xlimit, [0 0], ':k');
hold off

if(nbhvr == 1)
    set(gca, 'xlim', [xlimit(1) xlimit(2)*0.6])
end

pf = get(gcf, 'position');
set(gcf, 'position', [0 0 100+90*nbhvr 900])
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

l = legend(legends);
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
