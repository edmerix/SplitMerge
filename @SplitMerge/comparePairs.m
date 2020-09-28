function comparePairs(app)
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
        [tt_a,wvs_a] = app.compressSpikes(t,wvs_a);
        ind_a = max(find(unq == app.Data.Selected(a)),1);
        
        txt = uilabel(g,'Text',{'Unit', num2str(app.Data.Selected(a))});
        txt.FontColor = app.Data.colors(ind_a,:);
        txt.FontWeight = 'bold';
        txt.Layout.Row = a+1;
        txt.Layout.Column = 1;
        
        for b = a+1:length(app.Data.Selected)
            wvs_b = app.Data.spikes.waveforms(app.Data.spikes.assigns == app.Data.Selected(b),:);
            [tt_b,wvs_b] = app.compressSpikes(t,wvs_b);
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
            line(ax,tt_a,wvs_a,'color',app.Data.colors(ind_a,:));
            line(ax,tt_b,wvs_b,'color',app.Data.colors(ind_b,:));
            ax.XGrid = 'on';
            ax.YGrid = 'on';
            ax.XLim = [min(t) max(t)];
            disableDefaultInteractivity(ax);
        end
    end
end