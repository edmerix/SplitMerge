function comparePairs(app,meanPlot)
    if nargin < 2 || isempty(meanPlot)
        meanPlot = false;
    end
    if length(app.Data.Selected) < 2
        uialert(app.UIFigure,'Must select at least 2 clusters to compare','Cannot show merge options');
        return;
    end
    
    bonusFig = uifigure('Name','Waveform comparisons | SplitMerge');
    bonusFig.Position(3:4) = [1024 700];
    %bonusFig.AutoResizeChildren = 'on';
    bonusFig.Scrollable = 'on';
    
    g = uigridlayout(bonusFig);
    g.RowHeight = {20,'1x'};
    g.ColumnWidth = {30,'1x'};
    unq = unique(app.Data.spikes.assigns);
    
    t = (0:size(app.Data.spikes.waveforms,2)-1)/(app.Data.spikes.params.Fs/1e3);
    t = t - app.Data.spikes.params.cross_time;
    
    for a = 1:length(app.Data.Selected)-1
        wvs_a = app.Data.spikes.waveforms(app.Data.spikes.assigns == app.Data.Selected(a),:);
        if meanPlot
            mnWv_a = mean(wvs_a);
            sdWv_a = std(wvs_a);
        else
            [tt_a,wvs_a] = app.compressSpikes(t,wvs_a);
        end
        ind_a = max(find(unq == app.Data.Selected(a)),1);
        
        txt = uilabel(g,'Text',{'Unit', num2str(app.Data.Selected(a))});
        txt.FontColor = app.Data.colors(ind_a,:);
        txt.FontWeight = 'bold';
        txt.Layout.Row = a+1;
        txt.Layout.Column = 1;
        
        for b = a+1:length(app.Data.Selected)
            wvs_b = app.Data.spikes.waveforms(app.Data.spikes.assigns == app.Data.Selected(b),:);
            if meanPlot
                mnWv_b = mean(wvs_b);
                sdWv_b = std(wvs_b);
            else
                [tt_b,wvs_b] = app.compressSpikes(t,wvs_b);
            end
            ind_b = max(find(unq == app.Data.Selected(b)),1);
        
            txt = uilabel(g,'Text',['Unit ' num2str(app.Data.Selected(b))]);
            txt.FontColor = app.Data.colors(ind_b,:);
            txt.FontWeight = 'bold';
            txt.Layout.Row = 1;
            txt.Layout.Column = b;
            
            ax = uiaxes(g);
            ax.Layout.Row = a+1;
            ax.Layout.Column = b;
            hold(ax,'on');
            if meanPlot
                xdata = [t t(end:-1:1)];
                patch(ax,'XData',xdata,...
                    'YData',[mnWv_a+(2*sdWv_a) mnWv_a(end:-1:1)-(2*sdWv_a(end:-1:1))],...
                    'FaceColor',app.Data.colors(ind_a,:))
                patch(ax,'XData',xdata,...
                    'YData',[mnWv_b+(2*sdWv_b) mnWv_b(end:-1:1)-(2*sdWv_b(end:-1:1))],...
                    'FaceColor',app.Data.colors(ind_b,:))
                alpha(ax,0.6);
                plot(ax,t,mnWv_a,'color',app.Data.colors(ind_a,:),'linewidth',2)
                plot(ax,t,mnWv_b,'color',app.Data.colors(ind_b,:),'linewidth',2)
            else
                line(ax,tt_a,wvs_a,'color',app.Data.colors(ind_a,:));
                line(ax,tt_b,wvs_b,'color',app.Data.colors(ind_b,:));
            end
            ax.XGrid = 'on';
            ax.YGrid = 'on';
            ax.XLim = [min(t) max(t)];
            title(ax,[num2str(app.Data.Selected(a)) ' vs. ' num2str(app.Data.Selected(b))])
            disableDefaultInteractivity(ax);
        end
    end
end