function HCP_KRR_violin_predVStrue(outdir, outstem, acc_diff, perm_fname, colloq_ls)

% HCP_KRR_violin_predVStrue(outdir, outstem, acc_diff, perm_fname, colloq_ls)
%
% 

if(~exist('colloq_ls', 'var') || isempty(colloq_ls))
    colloq_ls = fullfile(getenv('HOME'), 'storage', 'MyProject', 'fairAI', 'HCP_race', ...
        'scripts', 'lists', 'colloquial_names_51_matched.txt');
end

[colloq_nm, nbhvr] = CBIG_text2cell(colloq_ls);
for b = 1:nbhvr
    curr_colloq = strsplit(colloq_nm{b}, '_');
    colloq_nm{b} = strjoin(curr_colloq, ' ');
end

grpdif = load(acc_diff);
assert(size(grpdif.yp_AA_all, 2) == nbhvr, 'Number of behaviors does not match between acc_diff and colloq_ls.')
nseeds = size(grpdif.yp_AA_all, 1);

%% load permutation test results, if any
if(exist('perm_fname', 'var') && ~isempty(perm_fname))
    load(perm_fname)
    IA = sig_diff_idx;
else
    IA = [];
end

for b = 1:nbhvr
    ydiff_AA = []; ydiff_WA = [];
    for seed = 1:nseeds
        ydiff_AA = [ydiff_AA; mean(grpdif.yp_AA_all{seed,b} - grpdif.yt_AA_all{seed,b}, 1)];
        ydiff_WA = [ydiff_WA; mean(grpdif.yp_WA_all{seed,b} - grpdif.yt_WA_all{seed,b}, 1)];
    end
    data{b} = [ydiff_AA ydiff_WA];
end

%% create plot
colormat = [114 147 203; 132 186 91; 211 94 96]./255;
HCP_violin_predVStrue(data, IA, colormat, 'Predicted - original behavioral score', {'AA', 'WA'}, [], colloq_nm, outdir, outstem)
    
end


function HCP_violin_predVStrue(data, sig_idx, colormat, y_label, legends, tit, colloq_nm, outdir, outstem)

    % HCP_violin_predVStrue(data, colormat, y_label, legends, tit, colloq_nm, outdir, outstem)
    %
    % - data: A cell array with the length of #behaviors
    
    nbhvr = length(data);
    
    if(nbhvr<20)
        med_circle = 16;
        med_line = 2;
    else
        med_circle = 3;
        med_line = 0.5;
    end
    
    f = figure;
    pf = get(gcf, 'position');
    
    th = 18;
    if(nbhvr<=th)
        H = 1; W = nbhvr;
        label_font = 15;
        legend_font = 12;
        subplot_width = 0.03;
        step = 0.08; width = 0.06;
        set(gcf, 'position', [0 0 100+110*nbhvr 600])
    else
        W = th; H = ceil(nbhvr / W);
        label_font = 14;
        legend_font = 11;
        subplot_width = 0.03;
        step = 0.06; width = 0.05;
        set(gcf, 'position', [0 0 100+125*W 500*H])
    end
    
    for b = 1:nbhvr
        subplot(H, W, b);
        curr_row = ceil(b/W); curr_col = mod(b, W);
        gca_pos = get(gca, 'position');
        gca_pos(4) = 0.5/H; gca_pos(2) = (0.4 + (H - curr_row))/H; gca_pos(3) = subplot_width;
        set(gca, 'position', gca_pos)
        hold on
        vio{1} = violinplot(squeeze(data{b}(:,1)), [], 1-step, 'ViolinColor', colormat(1,:), 'ShowMean', true, 'Width', width);
        vio{2} = violinplot(squeeze(data{b}(:,2)), [], 1+step, 'ViolinColor', colormat(2,:), 'ShowMean', true, 'Width', width);
    
        for i = 1:2
            vio{i}(1).ViolinPlot.LineWidth = 2;
            %vio{i}(1).ScatterPlot.Marker = '.';
            vio{i}(1).MedianPlot.SizeData = med_circle;
            vio{i}(1).MedianPlot.LineWidth = med_line;
        end
    
        xlimit = get(gca, 'xlim');
        plot(xlimit, [0 0], ':k');
        hold off

        % plot * on the significant behaviors
        if(any(ismember(sig_idx, b)))
            ylimvals = get(gca, 'ylim');
            ylimvals_new = ylimvals;
            %ylimvals_new(2) = (ylimvals(2)-ylimvals(1))*0.08 + ylimvals(2);
            set(gca, 'ylim', ylimvals)
            text(1, ylimvals(2), '*');
        end
    
        if(curr_col == 1)
            yl = ylabel(y_label);
            set(yl, 'fontsize', label_font, 'linewidth', 2)
        end
        set(gca, 'xticklabel', colloq_nm{b}, 'fontsize', label_font, 'linewidth', 2);
        rotateXLabels( gca(), 45 );
        set(gca, 'tickdir', 'out', 'box', 'off')
    end
    l = legend([vio{1}(1).ViolinPlot vio{2}(1).ViolinPlot], legends);
    set(l, 'fontsize', legend_font, 'linewidth', 2, 'location', 'best', 'box', 'off')
    if(~isempty(tit))
        title(tit, 'fontsize', 16)
    end
    
    outname = fullfile(outdir, [outstem ]);
    export_fig(outname, '-png', '-nofontswap', '-a1');
    set(gcf, 'color', 'w');
    hgexport(f, outname)
    close
        
end