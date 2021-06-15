function HCP_violin_2grp_avg(avg_data, colormat, y_label, x_labels, outdir, outstem)

% HCP_violin_2grp_avg(avg_data, colormat, y_label, x_labels, outdir, outstem)
%
% Inputs:
% - avg_data
%   A matrix with dimensions: 3 x #random splits. avg_data(1,:) are the accuracies of group 1
%   averaged across behavioral measures. avg_data(2,:) are the averaged accuracies of group 2.
%   avg_data(3,:) = avg_data(2,:) - avg_data(1,:).
%
% - colormat
%   3 x 3 color mat, each row is the RGB of one group.
%
% - y_label
%   Y-axis label.
% 
% - x_labels
%   A cell with 3 entries. X-axis name for each group and the difference.
%
% - outdir
%   Output directory (full path).
% 
% - outstem
%   File stem of output figures.
%
% Author: Jingwei Li

f = figure('visible', 'off');
hold on
vio = violinplot(avg_data, [], [], 'ShowMean', true);
for i = 1:length(vio)
    vio(i).ViolinPlot.LineWidth = 2;
    vio(i).ScatterPlot.Marker = '.';
    vio(i).MedianPlot.SizeData = 15;
    vio(i).ViolinPlot.FaceColor = colormat(i,:);
end
xlimit = get(gca, 'xlim');
plot(xlimit, [0 0], ':k');
hold off

pf = get(gcf, 'position');
set(gcf, 'position', [0 0 300 800]);
set(gca, 'position', [0.3 0.3 0.6 0.6])
ylm = get(gca, 'ylim');
%set(gca, 'ytick', ylm(1):0.2:ylm(2))
yl = ylabel(y_label, 'fontsize', 16, 'linewidth', 2);

set(gca, 'XTickLabel', x_labels, 'fontsize', 16, 'linewidth', 2)
rotateXLabels( gca(), 45 );
set(gca, 'tickdir', 'out', 'box', 'off');

outname = fullfile(outdir, ['Mean_' outstem]);
export_fig(outname, '-png', '-nofontswap', '-a1');
set(gcf, 'color', 'w');
hgexport(f, outname)
close
   
end