function splitSlide(app,event)

    app.Data.loader = uiprogressdlg(app.UIFigure,'Title','Plotting sub-clusters',...
        'Message','Loading');
    
    app.SplitChaps.SplitWaves.Visible = 'off';
    app.Data.splitSubclus = [];
    val = event.Value;

    set(app.SplitChaps.SplitLine,'YData',[val val]);
    
    lowval = floor(val);
    
    agg = app.Data.spikes.info.tree;
    
    assigns = app.Data.spikes.info.kmeans.assigns;
    changes = agg(1:lowval,:);
    for c = 1:size(changes,1)
        assigns(assigns == changes(c,2)) = changes(c,1);
    end
    
    % We now have the assigns that would occur if the merge is set to that
    % value. Now need to just subselect the ones that are relevant to the
    % selected unit:
    ids = setdiff(app.Data.clusterSubassigns, unique(changes(:,2)));
    app.Data.splitSubclus = ids;
    
    if app.Settings.Debugging
        disp([9 'IDs: ' num2str(ids)])
    end
    
    app.SplitChaps.SplitWaves.Title = [num2str(length(ids)) ' clusters after step ' num2str(lowval)];
    
    t = (0:size(app.Data.spikes.waveforms,2)-1)/(app.Data.spikes.params.Fs/1e3);
    t = t - app.Data.spikes.params.cross_time;
    
    ch = app.SplitChaps.SplitWaves.Children;
    delete(ch);
    
    % work out height of each plot here etc.
    pos = ((length(ids)-1)*200)+1:-200:1;
    
    if pos(1) < app.SplitChaps.SplitWaves.Position(4)
        hDiff = app.SplitChaps.SplitWaves.Position(4) - pos(1);
        pos = pos + hDiff;
    end

    minV = min(app.Data.spikes.waveforms(app.Data.spikes.assigns == app.Data.splitID,19));
    minV = -minV / app.Data.spikes.info.detect.thresh;
    
    colors = makeColors(app,max(app.Data.spikes.info.tree(:)));
    
    for i = 1:length(ids)
        app.Data.loader.Message = ['Plotting unit ' num2str(i) ' of ' num2str(length(ids))];
            
        inds = assigns == ids(i);
        waveforms = app.Data.spikes.waveforms(inds,:);
        [tt,wvs] = compressSpikes(app,t,waveforms);
        
        ax = uiaxes(app.SplitChaps.SplitWaves);
        ax.Position = [1 pos(i) app.SplitChaps.SplitWaves.Position(3)/3 200];
        disableDefaultInteractivity(ax);
        
        plot(ax, tt, wvs, 'color', colors(i,:));
        ax.XGrid = 'on';
        ax.YGrid = 'on';
        ax.XLim = [min(tt) max(tt)];
        ax.TickLength = [0 0];
        ax.XTickLabel = [];
        title(ax,['Unit ' num2str(ids(i))])
        
        % detection metric
        ax = uiaxes(app.SplitChaps.SplitWaves);
        ax.Position = [(app.SplitChaps.SplitWaves.Position(3)/3)+1 pos(i)+100 app.SplitChaps.SplitWaves.Position(3)/3 100];
        disableDefaultInteractivity(ax);
        plotDetectionCriterion(app,ax,inds);
        ax.XLabel.String = '';
        ax.YLabel.String = '';
        ax.XTick = [];
        ax.YTick = [];
        ax.XLim = [minV 0];
        
        % autocorrelation
        ax = uiaxes(app.SplitChaps.SplitWaves);
        ax.Position = [(app.SplitChaps.SplitWaves.Position(3)/3)+1 pos(i) app.SplitChaps.SplitWaves.Position(3)/3 100];
        disableDefaultInteractivity(ax);
        plotAC(app,ax,inds);
        ax.XLabel.String = '';
        ax.YLabel.String = '';
        ax.XTick = [];
        ax.YTick = [];
        
        % amplitude & firing rate
        ax = uiaxes(app.SplitChaps.SplitWaves);
        ax.Position = [2*(app.SplitChaps.SplitWaves.Position(3)/3)+1 pos(i) (app.SplitChaps.SplitWaves.Position(3)/3)-2 200];
        disableDefaultInteractivity(ax);
        plotFR(app,ax,inds);
        ax.XLabel.String = '';
        ax.YLabel.String = '';
        ax.XTick = [];
        ax.YTick = [];
        yyaxis(ax,'left');
        ax.XLabel.String = '';
        ax.YLabel.String = '';
        ax.XTick = [];
        ax.YTick = [];
        
        drawnow('limitrate');
        app.Data.loader.Value = i/length(ids);
    end
    drawnow(); % Maybe drawnow('limitrate','nocallbacks') %?
    app.SplitChaps.SplitWaves.Visible = 'on';
    close(app.Data.loader);
    app.Data.loader = [];
end