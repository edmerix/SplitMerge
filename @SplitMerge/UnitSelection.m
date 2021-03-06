% Select units in the merge panel:
function UnitSelection(app,event)
    selected = cellfun(@(rep) strrep(rep, 'Unit ',''), event.Value, 'UniformOutput', false);
    app.Data.Selected = cellfun(@str2double,selected);
    cla(app.MergedWaves)
    hold(app.MergedWaves,'on')
    t = (0:size(app.Data.spikes.waveforms,2)-1)/(app.Data.spikes.params.Fs/1e3);
    t = t - app.Data.spikes.params.cross_time;
    mx = 0;
    mn = 0;
    for s = 1:length(app.Data.Selected)
        ids = app.Data.spikes.assigns == app.Data.Selected(s);
        waveforms = app.Data.spikes.waveforms(ids,:);
        [tt,wvs] = compressSpikes(app,t,waveforms);
        if app.Settings.Colorful
            clus_n = unique(app.Data.spikes.assigns) == app.Data.Selected(s);
            line(app.MergedWaves,tt,wvs,'Color',app.Data.colors(clus_n,:));
        else
            line(app.MergedWaves,tt,wvs,'Color',[0.2000 0.4196 0.5294])
        end
        if max(wvs) > mx, mx = max(wvs); end
        if min(wvs) < mn, mn = min(wvs); end
    end
    xlim(app.MergedWaves,[t(1) t(end)]);
    ylim(app.MergedWaves,[mn-10 mx+10])
    app.MergedWaves.XGrid = 'on';
    app.MergedWaves.YGrid = 'on';
    
    if ~isempty(app.Data.Selected)
        plotDetectionCriterion(app,app.MergedMissing);
        plotAC(app,app.MergedAC);
        plotFR(app,app.MergedFR);
        wh = ismember(app.Data.spikes.labels(:,1),app.Data.Selected);
        goodVals = app.Data.spikes.labels(wh,2);
        if min(goodVals) > 1
            % They're all marked as good, so make the button mark them as
            % bad:
            app.GoodButton.ValueChangedFcn = createCallbackFcn(app, @markBad, true);
            app.GoodButton.Value = true;
            app.GoodButton.Tooltip = 'Un-mark selected as good';
        else
            % They're either all marked as bad, or a mixture, so make the
            % button mark them all as good:
            app.GoodButton.ValueChangedFcn = createCallbackFcn(app, @markGood, true);
            app.GoodButton.Value = false;
            app.GoodButton.Tooltip = 'Mark selected as good';
        end        
    end
end