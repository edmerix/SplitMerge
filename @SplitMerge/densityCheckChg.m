function densityCheckChg(app,~)
    val = app.DensityCheck.Value;
    if val ~= app.Settings.Density
        app.Settings.Density = val;
        unq = unique(app.Data.spikes.assigns);
        if app.Settings.Density
            t = (0:size(app.Data.spikes.waveforms,2)-1)/(app.Data.spikes.params.Fs/1e3);
            t = t - app.Data.spikes.params.cross_time;
            for u = 1:length(unq)
                if ~isempty(app.SpikePanels{unq(u)}) && ~isempty(app.SpikePanels{unq(u)}.Children)
                    %app.SpikePanels{unq(u)}.Children(1).Color = app.Data.colors(u,:);
                    [dens,y] = app.spikeHist(app.Data.spikes.waveforms(app.Data.spikes.assigns == unq(u),:));
                    hold(app.SpikePanels{unq(u)},'on');
                    imagesc(app.SpikePanels{unq(u)},t,y,dens)
                    alpha(app.SpikePanels{unq(u)},0.7);
                    colormap(app.SpikePanels{unq(u)},'hot');
                end
            end
        else
            for u = 1:length(unq)
                if ~isempty(app.SpikePanels{unq(u)}) && ~isempty(app.SpikePanels{unq(u)}.Children)
                    ch = app.SpikePanels{unq(u)}.Children;
                    for c = 1:length(ch) % why no vectorization of graphics objects in matlab?
                        if strcmpi(ch(c).Type,'image')
                            ch(c).delete;
                        end
                    end
                end
            end
        end
    end
end
